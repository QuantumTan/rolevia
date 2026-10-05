import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/colors.dart';
import '../core/design/motion.dart';
import '../core/design/radius.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/widgets/adaptive_button.dart';
import '../core/widgets/adaptive_card.dart';
import '../core/widgets/adaptive_text_field.dart';
import '../core/widgets/adaptive_toast.dart';
import '../core/widgets/pressable.dart';
import '../models/models.dart';
import '../state/app_state.dart';

class CareerPreferencesScreen extends ConsumerStatefulWidget {
  const CareerPreferencesScreen({super.key, this.isOnboarding = false});

  final bool isOnboarding;

  @override
  ConsumerState<CareerPreferencesScreen> createState() =>
      _CareerPreferencesScreenState();
}

class _CareerPreferencesScreenState
    extends ConsumerState<CareerPreferencesScreen> {
  static const _presetRoles = [
    'Flutter Developer',
    'Frontend Developer',
    'Backend Developer',
    'Full Stack Developer',
    'QA / Tester',
    'Customer Support / BPO',
    'Virtual Assistant',
    'Data Analyst',
    'UI/UX Designer',
    'Mobile Engineer',
  ];

  static const _presetLocations = [
    'Taguig / BGC',
    'Makati City',
    'Cebu IT Park',
    'Davao City',
    'Quezon City',
    'City of Manila',
    'Remote / Worldwide',
  ];

  late final Set<String> _selectedRoles;
  late String _selectedLocation;
  WorkMode? _selectedMode;
  late final TextEditingController _customRoleController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(appControllerProvider).profile;
    _selectedRoles = Set<String>.from(
      profile.targetRoles.isNotEmpty
          ? profile.targetRoles
          : ['Flutter Developer'],
    );
    _selectedLocation = profile.location.isNotEmpty
        ? profile.location
        : 'Taguig / BGC';
    _selectedMode = profile.preferredWorkMode;
    _customRoleController = TextEditingController();
  }

  @override
  void dispose() {
    _customRoleController.dispose();
    super.dispose();
  }

  void _addCustomRole() {
    final text = _customRoleController.text.trim();
    if (text.isNotEmpty && !_selectedRoles.contains(text)) {
      AppMotion.selectionHaptic();
      setState(() {
        _selectedRoles.add(text);
        _customRoleController.clear();
      });
    }
  }

  Future<void> _handleSave() async {
    if (_selectedRoles.isEmpty) {
      showGlassToast(context, 'Please select at least one target role.');
      return;
    }

    setState(() => _isSaving = true);
    final currentProfile = ref.read(appControllerProvider).profile;
    final updatedProfile = currentProfile.copyWith(
      targetRoles: _selectedRoles.toList(),
      location: _selectedLocation,
      preferredWorkMode: _selectedMode,
    );

    ref.read(appControllerProvider.notifier).updateProfile(updatedProfile);

    // Trigger Jooble search tailored to new preferences
    await ref.read(appControllerProvider.notifier).searchJobs(
          keywords: _selectedRoles.first,
          location: _selectedLocation,
          forceRefresh: true,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);
    showGlassToast(
      context,
      'Preferences saved! Feed updated.',
      icon: Icons.check_circle_rounded,
    );

    if (widget.isOnboarding) {
      ref.read(appControllerProvider.notifier).completeOnboarding();
      ref.read(appControllerProvider.notifier).signIn();
      context.go('/discover');
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/discover');
    }
  }

  void _handleSkip() {
    if (widget.isOnboarding) {
      ref.read(appControllerProvider.notifier).completeOnboarding();
      ref.read(appControllerProvider.notifier).signIn();
      context.go('/discover');
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/discover');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isOnboarding ? 'Set Up Your Feed' : 'Career Preferences',
          style: AppTypography.headline.copyWith(
            color: colors.labelPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: (!widget.isOnboarding && context.canPop())
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.labelPrimary, size: 20),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Personalize Your Discovery',
                style: AppTypography.largeTitle.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tell us what roles and locations you want so your real-time feed recommends the right jobs.',
                style: AppTypography.body.copyWith(
                  color: colors.labelSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 1. Target Roles
              Text(
                'Target Roles',
                style: AppTypography.headline.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select one or more roles to curate your feed:',
                style: AppTypography.caption.copyWith(
                  color: colors.labelTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AdaptiveCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: {
                        ..._presetRoles,
                        ..._selectedRoles,
                      }.map((role) {
                        final isSelected = _selectedRoles.contains(role);
                        return PressableScale(
                          onPressed: () {
                            AppMotion.selectionHaptic();
                            setState(() {
                              if (isSelected) {
                                if (_selectedRoles.length > 1) {
                                  _selectedRoles.remove(role);
                                }
                              } else {
                                _selectedRoles.add(role);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary
                                  : colors.paleIndigoSurface,
                              borderRadius: BorderRadius.circular(
                                AppRadius.capsule,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  role,
                                  style: AppTypography.footnote.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : colors.labelPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: AdaptiveTextField(
                            controller: _customRoleController,
                            hintText: 'Add another role (e.g. DevOps)',
                            onSubmitted: (_) => _addCustomRole(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AdaptiveButton.secondary(
                          onPressed: _addCustomRole,
                          label: 'Add',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Preferred Work Mode
              Text(
                'Preferred Work Mode',
                style: AppTypography.headline.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AdaptiveCard(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    (null, 'Any Work Mode'),
                    (WorkMode.remote, 'Remote'),
                    (WorkMode.hybrid, 'Hybrid'),
                    (WorkMode.onSite, 'On-site'),
                  ].map((entry) {
                    final isSelected = _selectedMode == entry.$1;
                    return PressableScale(
                      onPressed: () {
                        AppMotion.selectionHaptic();
                        setState(() => _selectedMode = entry.$1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary
                              : colors.paleIndigoSurface,
                          borderRadius: BorderRadius.circular(AppRadius.capsule),
                        ),
                        child: Text(
                          entry.$2,
                          style: AppTypography.footnote.copyWith(
                            color: isSelected
                                ? Colors.white
                                : colors.labelPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Preferred Location
              Text(
                'Preferred Location',
                style: AppTypography.headline.copyWith(
                  color: colors.labelPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AdaptiveCard(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _presetLocations.map((loc) {
                    final isSelected = _selectedLocation == loc;
                    return PressableScale(
                      onPressed: () {
                        AppMotion.selectionHaptic();
                        setState(() => _selectedLocation = loc);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary
                              : colors.paleIndigoSurface,
                          borderRadius: BorderRadius.circular(AppRadius.capsule),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              loc.contains('Remote')
                                  ? Icons.public_rounded
                                  : Icons.location_on_outlined,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : colors.labelSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              loc,
                              style: AppTypography.footnote.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : colors.labelPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save Button
              AdaptiveButton.primary(
                isFullWidth: true,
                onPressed: _isSaving ? null : _handleSave,
                label: _isSaving ? 'Updating feed…' : 'Save & Personalize Feed',
                icon: const Icon(Icons.tune_rounded, size: 20),
              ),
              const SizedBox(height: AppSpacing.sm),
              AdaptiveButton.tertiary(
                isFullWidth: true,
                onPressed: _handleSkip,
                label: widget.isOnboarding ? 'Skip for now' : 'Cancel',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
