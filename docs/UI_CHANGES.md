# UI changes

2 October 2026. UI work retains Riverpod, GoRouter, SharedPreferences and the existing local-demo behavior. No changes were made to models, fixtures, repository, controller, API contracts or sync logic. Existing UI changes were preserved and incorporated; the pre-existing `.metadata` and Gradle wrapper edits remain outside these commits.

## Design decisions

ENERGY 2 / RHYTHM 2 / MOTION 2, following the supplied brief. Indigo identifies actions; amber calls attention to scarce scans; score bands communicate outcomes with words as well as color. Document and Kanban artwork illustrates the actual workflow. Content cards stay solid while navigation, headers and sheets use blur. Glass has a high-contrast/manual solid fallback. Typography uses bundled Inter, with its SIL Open Font License included.

Dark text and icons use a lighter indigo than the action fill. Warning text is darker in light mode than the supplied yellow to remain legible. Buttons retain white on indigo. Scores use tabular figures. Cards, capsule controls and sheets have distinct corner treatments. No decorative gradients, remote avatars, company logos or stock imagery were introduced.

## Screens and navigation

- Shell: floating nav inset 16, scroll minimization, preserved branch state and scroll positions, 200 ms cross-fade, platform-specific pushed transitions, scroll behind the bar and keyboard-aware visibility. Large layouts retain the navigation rail.
- Match: profile-name greeting, working clipboard Paste/Clear, count, existing resume selection, Run Analysis/Save for later, disabled-input handling, scarce-scan warning, zero-quota demo-ad action, dismissible tip, animated offline banner. Existing cancel/refund/queue behavior is unchanged.
- Analysis: existing timed progress plus pulsing/skeleton result placeholders. Reduced motion freezes the skeleton pulse. The demo timings are retained.
- Results: shared band-colored ring with 800 ms count-up, verdict and stable score semantics, one 24-particle burst at 85+, Hero from history, staggered missing keywords, actual clipboard confirmation and animated matched-skills expansion.
- Rewrites: muted strikethrough before, tinted after, emphasized verbs and numeric metrics, connecting arrow, swipe/page controls and dots, Copied confirmation. Templates remain explicitly labeled examples requiring verified outcomes.
- Discover: deterministic initials avatars, saved-job toggle through the existing controller, shared score bands, restrained list entrance and avatar Hero. Search/filter behavior is preserved. Fixture jobs remain labeled fictional/sample.
- Vault: dashed upload treatment, validation/loading/error feedback, Active label, overflow menu for supported actions, directional swipe to activate/delete with existing confirmation. Existing last-resume protection is preserved.
- Tracker: horizontal stage swipes, animated selected edge, stage counts, long-press drag to stage tabs, highlighted targets, lift and haptics, relative dates, company initials. Notes use a 350 ms UI debounce and indicate local updates; closing flushes pending text through the existing update operation.
- Dashboard: count-up local totals, weekly CustomPainter chart derived from stored application dates, shared history badges and illustration for empty history. Existing five-second reward demo remains honest about its purpose.
- Interview: distinct question/answer surfaces, user label rather than a fixed name, reduced-motion-aware scroll to recorded answer and existing coaching. Setup reflows at larger text sizes.
- Profile: grouped controls, accessible reflow, System/Light/Dark selection through existing preferences, shared transparency setting, existing destructive confirmation and honest demo storage/sync notices.
- Onboarding/sign-in: original paste/match/track illustrations, scroll-safe content, reduced-motion dots, existing inline validation/loading and accessible action colors.

## Shared UI

Theme entry points under `lib/core/theme` reuse the existing design tokens and add a surface-preference ThemeExtension. New/reused widgets include BandScoreRing, MatchBadge/MatchBand, CompanyAvatar, CopyButton, Celebration, ActivityChart, AnimatedCount, ProductIllustration, StaggeredEntrance, RewriteCarousel, ResumeActions, OfflineBanner, StageDropTarget, DashedFrame, BranchContainer and appPage transitions. Adaptive widgets retain keyboard activation, focus outlines, semantic labels and minimum 44-pixel actions.

Motion is finite and generally 100/200/300 ms; the requested score ring uses 800 ms. Inactive branches disable tickers. Reduced motion disables celebration and movement; skeletons become still. List items never use BackdropFilter. Transparent UI can be switched to solid in Preferences; high contrast also forces solid surfaces.

## Assets and dependencies

All product illustrations/icons/branding were drawn as SVG, Flutter painting, or original Python geometry. `tools/generate_branding.py` reproducibly renders the bolt/check for native generators and web icons.

- Illustrations: onboarding_paste, onboarding_match, onboarding_track; empty_vault, empty_tracker, empty_history, empty_search, empty_offline; error_generic, success_check, ad_reward.
- Icons: ats_pass, ats_warn, keyword_missing, star_method, scan_token, each 24 x 24 with rounded 2-pixel strokes.
- Branding: 1024 SVG/source raster, transparent adaptive/themed foreground, splash mark, generated Android density/Android 12 resources, iOS assets/storyboard and matching web icons/splash.
- Inter variable font from the official Google Fonts repository, accompanied by OFL.txt. This licensed font is the only downloaded visual dependency.
- `flutter_svg 2.3.0`: render the original vectors.
- `flutter_launcher_icons 0.14.4` (dev): produce iOS and Android adaptive/themed icons.
- `flutter_native_splash 2.4.8` (dev): produce light/dark launch resources including Android 12.

Lottie JSON was replaced with built-in animation controllers and CustomPainter equivalents for pulse, confirmation and confetti. No lottie, shimmer, flutter_animate or chart dependency is needed. Some provided vectors remain available assets rather than forcing decorative imagery into every screen.

## Validation

- Baseline: analyzer clean; 34 tests passed.
- Final analyzer: no issues.
- Final suite: 46 tests pass, including ScoreRing count/semantics, badge band boundaries, actionable empty state, nav switching, real clipboard confirmation, reduced motion, text/action token contrast and pushed routes at 360 x 640 with text scale 1.3 in light/dark.
- Existing responsive coverage passes for all tabs at 320, 390, 768, 1280 and landscape 844, at text scales 1 and 2 in both themes. Navigation handles safe areas/keyboard and preserves search on returning from detail.
- Discover golden comparisons pass in both themes with actual Inter, Material and Cupertino font loading. Both images were visually inspected.
- Web release build succeeds, including the Wasm dry run. Browser check: Discover tab opens; scored card opens sample Results; Docker opens the suggestion sheet; Copy changes to Copied; sheet closes; score/skills/ATS render. Browser screenshot: `artifacts/ui-results-browser.jpg`.
- Native icon and splash generators both completed successfully.
- Android emulator boots (`Pixel_10_Pro`, emulator-5554), but installing/running the app was blocked: the Flutter x86_64 debug engine JAR download from storage.googleapis.com timed out. Offline Gradle also confirms missing engine cache. Native build failure is dependency resolution, not a verified app runtime result.
- iOS simulator is unavailable on this Windows host. Native frame timing, dropped-frame claims and physical low-end testing are unverified. No performance PASS is claimed.

## Remaining work and boundaries

1. Resume rename requires a controller/repository operation that does not exist. This was not added under the UI-only rule.
2. There is no share-intent integration or source-app metadata to display. No fabricated Shared from chip was added.
3. Discover uses local fixtures; there is no remote refresh to represent. Search, filters and scenario loading/empty/error remain available.
4. Interview has synchronous local coaching and no scoring/typing service. No invented AI score, fabricated strengths, or simulated typing delay was added. Existing coaching remains visible.
5. Dashboard has no prior-period aggregate for honest trend arrows; the chart uses actual stored dates. The reward card retains the existing demo countdown, without invented ad-provider progress.
6. Sync is not connected, so there is no fake spinning sync-success state. OS reduce-transparency and automatic low-end detection are not exposed by the current architecture; the existing manual preference and high-contrast fallback are wired across glass surfaces.
7. Native verification and scroll profiling remain required before a release. After engine downloads work, run `flutter run -d emulator-5554 --profile` and inspect frame timings; use solid surfaces if blur is expensive. Run the iOS light/dark/text-scale matrix on a macOS host.

## Design review evidence

This is a scoped review of the implemented UI; it does not certify native performance or claim every existing prototype control received a browser click-through.

- R-03/R-34 PASS in the tested matrix: tab and pushed-route layout tests produce no overflow exceptions in both themes.
- R-17/R-18/R-36/R-38 PASS for added content: local counts/dates drive the chart; examples retain visible demo/sample labeling; no testimonials or performance/security claims were introduced.
- R-23/R-24 PASS: the user expressly requested original assets and the five-tab structure; nav switching tests exercise real branches.
- R-25 PASS for tested tokens: normal/high-contrast surface text, action text and white-on-primary fill meet 4.5:1 through luminance assertions. Full pixel-by-pixel contrast certification is outside this check.
- R-26/R-27 PASS for added controls/states: copy test confirms platform clipboard data, empty action test invokes its callback, new resume/stage controls call existing supported operations; scenario states remain implemented.
- R-32 PASS for shared pressables: keyboard activation/disabled-state test, visible focus outline and 44-pixel minimum bounds.
- R-33 PASS: source widgets/assets are authored in the repository; generator scripts only render original branding and native resources.
- R-35 coverage: build and critical browser interactions recorded above; exhaustive manual click-through and native run remain pending, so the full gate is not declared complete.
- Purpose review: glass separates navigation from solid content; semantic badges explain ATS/score/quota; illustrations teach the resume/job/tracker loop; entrance and copy motion indicate changes. No stock decoration, glow or monospace hero was added.
- Liveliness review: declared 2/2/2 dials, document/check motif, input/results focal points, structural spacing and restrained amber follow the supplied direction.

## Commit organization

Audit, theme foundation and shared score/surface commits precede screen integration. Screen integration also registers the asset/font dependencies it needs. A separate branding commit contains generated native/web resources; final polish/validation documents the contrast, tests and platform limits. This keeps the original user tooling changes outside the redesign commits.
