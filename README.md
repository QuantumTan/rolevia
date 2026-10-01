# Job Matcher

A local-first Flutter frontend for discovering jobs, managing resume metadata, running deterministic demo comparisons, and tracking applications. The temporary display name is centralized in `lib/core/brand.dart`.

## Run on Windows

1. Install the stable Flutter SDK and Android Studio with an Android SDK.
2. From PowerShell in this folder, run `flutter doctor`.
3. Run `flutter pub get`.
4. Start an emulator or connect an Android device, then run `flutter run`.
5. Choose **Open demo workspace** to enter all five tabs immediately.

Use `flutter test`, `flutter analyze`, and `flutter build apk --debug` for verification. iOS source is included, but an iOS build requires macOS with Xcode and cannot be produced on Windows.

## Structure

- `lib/models`: typed domain models.
- `lib/data`: fixtures plus the replaceable `DemoRepository` persistence boundary.
- `lib/state`: Riverpod state and domain operations.
- `lib/features`: onboarding, authentication, five tabs, and detail flows.
- `lib/shared` and `lib/core`: reusable surfaces, feedback, theme, and branding.

## Implemented flows

The app includes onboarding and demo authentication, local job search and filters, saved jobs, resume metadata selection and sample previews, deterministic match progress and results, board/list application tracking, derived dashboard figures, profile editing, theme selection, reduced transparency, reset, and sign-out. Debug builds include a small state selector for loading, empty, and error views.

## Demo boundaries

No credentials are sent or stored. Selected resume files are not copied, parsed, or uploaded. Match results are deterministic fixtures, not AI, ATS measurements, or hiring probabilities. External applications and notifications are not connected. `shared_preferences` stores only demo settings, IDs, resume metadata, application records, and match history.

A future backend can implement `DemoRepository` or add feature-specific repository implementations without moving business logic into widgets. A future AI service should replace the deterministic match operation behind a repository interface and preserve the existing typed `MatchResult` contract.
