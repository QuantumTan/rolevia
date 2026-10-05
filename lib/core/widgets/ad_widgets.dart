import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../design/colors.dart';
import '../design/motion.dart';
import '../design/radius.dart';
import '../design/spacing.dart';
import '../design/typography.dart';
import '../services/ad_service.dart';
import 'adaptive_button.dart';
import 'adaptive_card.dart';
import 'adaptive_toast.dart';
import 'pressable.dart';

/// Shows an engaging interactive sponsored ad dialog when AdMob video ads
/// are unavailable or running on desktop/web environments.
Future<bool?> showInteractiveSponsoredAd(
  BuildContext context, {
  required VoidCallback onRewardEarned,
}) {
  AppMotion.selectionHaptic();
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => InteractiveSponsoredAdDialog(
      onRewardEarned: onRewardEarned,
    ),
  );
}

class InteractiveSponsoredAdDialog extends StatefulWidget {
  const InteractiveSponsoredAdDialog({
    super.key,
    required this.onRewardEarned,
  });

  final VoidCallback onRewardEarned;

  @override
  State<InteractiveSponsoredAdDialog> createState() =>
      _InteractiveSponsoredAdDialogState();
}

class _InteractiveSponsoredAdDialogState
    extends State<InteractiveSponsoredAdDialog> {
  int _secondsLeft = 5;
  Timer? _timer;
  bool _claimed = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          _secondsLeft = 0;
          timer.cancel();
          AppMotion.selectionHaptic();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _claim() {
    if (_claimed) return;
    _claimed = true;
    AppMotion.selectionHaptic();
    widget.onRewardEarned();
    Navigator.of(context).pop(true);
    showGlassToast(context, '+1 Scan granted');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final progress = (5 - _secondsLeft) / 5.0;

    return Dialog(
      backgroundColor: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderSubtle, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header tag & close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.paleIndigoSurface,
                      borderRadius: BorderRadius.circular(AppRadius.capsule),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.campaign_rounded,
                          size: 13,
                          color: colors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SPONSORED PARTNER AD',
                          style: AppTypography.monoBadge.copyWith(
                            color: colors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: colors.labelTertiary,
                    tooltip: 'Close',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Visual Creative Box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.paleIndigoSurface,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.rocket_launch_rounded,
                            color: colors.accent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rolevia Career Accelerator',
                                style: AppTypography.headline.copyWith(
                                  color: colors.labelPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tech & BPO Pathways Philippines',
                                style: AppTypography.caption.copyWith(
                                  color: colors.labelSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Match with verified IT, software engineering, and technical customer support openings in Metro Manila, Cebu, and remote setups across the Philippines.',
                      style: AppTypography.footnote.copyWith(
                        color: colors.labelSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Progress bar and countdown timer
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.capsule),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: colors.borderSubtle,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _secondsLeft == 0 ? colors.diffAddedText : colors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _secondsLeft == 0
                        ? 'Reward ready to claim'
                        : 'Watching sponsored promo',
                    style: AppTypography.caption.copyWith(
                      color: colors.labelTertiary,
                    ),
                  ),
                  Text(
                    _secondsLeft == 0 ? 'Ready' : '${_secondsLeft}s left',
                    style: AppTypography.monoScore.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _secondsLeft == 0
                          ? colors.diffAddedText
                          : colors.labelSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Action button
              if (_secondsLeft == 0)
                AdaptiveButton.primary(
                  isFullWidth: true,
                  label: 'Claim +1 Free Match Scan',
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  onPressed: _claim,
                )
              else
                AdaptiveButton.secondary(
                  isFullWidth: true,
                  label: 'Please wait ${_secondsLeft}s for reward',
                  onPressed: null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A clean, high-density banner ad widget that displays a native Google Mobile Ads
/// banner on Android/iOS (with official test units) or an engineered sponsored
/// partner banner on desktop/web/fallbacks.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final EdgeInsetsGeometry padding;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _adLoaded = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
    try {
      final banner = BannerAd(
        adUnitId: AdService.testBannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!_isDisposed && mounted) {
              setState(() {
                _bannerAd = ad as BannerAd;
                _adLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (!_isDisposed && mounted) {
              setState(() {
                _bannerAd = null;
                _adLoaded = false;
              });
            }
          },
        ),
      );
      await banner.load();
    } catch (_) {
      // Gracefully fall back to sponsored creative
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (_adLoaded && _bannerAd != null) {
      return Padding(
        padding: widget.padding,
        child: Container(
          width: double.infinity,
          height: _bannerAd!.size.height.toDouble(),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    // Engineered sponsored fallback banner for desktop, web, or offline/no-fill
    return Padding(
      padding: widget.padding,
      child: PressableScale(
        onPressed: () {
          AppMotion.selectionHaptic();
          showGlassToast(
            context,
            'Rolevia Partner Network: Accelerating Philippine tech careers',
          );
        },
        child: AdaptiveCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.paleIndigoSurface,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Text(
                  'AD',
                  style: AppTypography.monoBadge.copyWith(
                    color: colors.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Philippine Tech & BPO Career Partner',
                      style: AppTypography.caption.copyWith(
                        color: colors.labelPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Local-first ATS resume checks & interview prep.',
                      style: AppTypography.caption.copyWith(
                        color: colors.labelSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.open_in_new_rounded,
                size: 14,
                color: colors.labelTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
