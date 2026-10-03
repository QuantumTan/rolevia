import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';

final adServiceProvider = Provider<AdService>((ref) => AdService());

class AdService {
  AdService({String? adUnitId})
      : _adUnitId = adUnitId ?? AppConfig.rewardedAdUnitId;

  final String _adUnitId;
  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get isAdAvailable => _rewardedAd != null;

  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_isInitialized) return;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await MobileAds.instance.initialize();
        _isInitialized = true;
      }
    } catch (e) {
      debugPrint('AdMob initialization skipped or failed: $e');
    }
  }

  Future<bool> loadRewardedAd({String? userId}) async {
    if (kIsWeb) return false;
    if (_isLoading || _rewardedAd != null) return _rewardedAd != null;
    _isLoading = true;

    await initialize();

    final completer = Completer<bool>();

    try {
      await RewardedAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoading = false;

            if (userId != null) {
              final nonce = const Uuid().v4();
              ad.setServerSideOptions(
                ServerSideVerificationOptions(
                  userId: userId,
                  customData: jsonEncode({'userId': userId, 'nonce': nonce}),
                ),
              );
            }

            completer.complete(true);
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _isLoading = false;
            debugPrint('RewardedAd failed to load: $error');
            completer.complete(false);
          },
        ),
      );
    } catch (e) {
      _isLoading = false;
      debugPrint('Error loading rewarded ad: $e');
      completer.complete(false);
    }

    return completer.future;
  }

  Future<bool> showRewardedAd({
    required BuildContextCallback? onUserEarnedReward,
    VoidCallback? onAdDismissed,
    void Function(String error)? onAdFailedToShow,
  }) async {
    final ad = _rewardedAd;
    if (ad == null) {
      onAdFailedToShow?.call('No ads available.');
      return false;
    }

    final completer = Completer<bool>();
    var rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed?.call();
        if (!completer.isCompleted) completer.complete(rewardEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onAdFailedToShow?.call(error.message);
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await ad.show(onUserEarnedReward: (adWithoutView, reward) {
        rewardEarned = true;
        onUserEarnedReward?.call(reward);
      });
    } catch (e) {
      _rewardedAd = null;
      onAdFailedToShow?.call(e.toString());
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}

typedef BuildContextCallback = void Function(RewardItem reward);
