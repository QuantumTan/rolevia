import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';

final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService();
  ref.onDispose(service.dispose);
  return service;
});

class AdService {
  AdService({String? adUnitId})
      : _adUnitId = adUnitId ?? AppConfig.rewardedAdUnitId;

  final String _adUnitId;
  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get isAdAvailable => _rewardedAd != null;

  /// Official Google Mobile Ads sample/test rewarded ad unit IDs
  /// Guaranteed to always load test ads on Android and iOS without error 3 (no-fill).
  static String get testRewardedAdUnitId {
    if (!kIsWeb && Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return 'ca-app-pub-3940256099942544/5224354917';
  }

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
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return false;
    if (_isLoading || _rewardedAd != null) return _rewardedAd != null;
    _isLoading = true;

    await initialize();

    final targetUnit = _adUnitId.isNotEmpty ? _adUnitId : testRewardedAdUnitId;
    return _loadWithUnit(targetUnit, userId: userId);
  }

  Future<bool> _loadWithUnit(
    String adUnitId, {
    String? userId,
    bool allowFallback = true,
  }) async {
    final completer = Completer<bool>();

    try {
      await RewardedAd.load(
        adUnitId: adUnitId,
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
          onAdFailedToLoad: (error) async {
            debugPrint('RewardedAd failed to load with unit $adUnitId: $error');
            if (allowFallback && adUnitId != testRewardedAdUnitId) {
              debugPrint('Retrying with official Google Test Rewarded Ad Unit ($testRewardedAdUnitId)...');
              final fallbackSuccess = await _loadWithUnit(
                testRewardedAdUnitId,
                userId: userId,
                allowFallback: false,
              );
              completer.complete(fallbackSuccess);
            } else {
              _rewardedAd = null;
              _isLoading = false;
              completer.complete(false);
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading rewarded ad: $e');
      if (allowFallback && adUnitId != testRewardedAdUnitId) {
        debugPrint('Exception loading ad; retrying with Google Test Unit...');
        final fallbackSuccess = await _loadWithUnit(
          testRewardedAdUnitId,
          userId: userId,
          allowFallback: false,
        );
        completer.complete(fallbackSuccess);
      } else {
        _isLoading = false;
        completer.complete(false);
      }
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
