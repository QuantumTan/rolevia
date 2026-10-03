# Job Matcher

A local-first Flutter frontend for discovering jobs, managing resume metadata, running deterministic demo comparisons, and tracking applications. The temporary display name is centralized in `lib/core/brand.dart`.

## Run on Windows

1. Install the stable Flutter SDK and Android Studio with an Android SDK.
2. From PowerShell in this folder, run `flutter doctor`.
3. Run `flutter pub get`.
4. Start an emulator or connect an Android device, then run `flutter run`.
5. Choose **Continue on this device**, then add a resume or choose **Skip for now**.

Use `flutter test`, `flutter analyze`, and `flutter build apk --debug` for verification. iOS source is included, but an iOS build requires macOS with Xcode and cannot be produced on Windows.

## Backend foundation

The Supabase database foundation lives in `supabase/`, with migrations, owner
access policies, and database tests. Run `npm ci` and `npm run test:backend` for
the embedded PostgreSQL checks. See [backend architecture and setup](docs/BACKEND_ARCHITECTURE.md)
for local Supabase startup, the API contract, and the remaining integration work.
The Flutter app still uses demo persistence; real authentication, sync, and AI
are not connected yet.

## Flutter structure

- `lib/models`: typed domain models.
- `lib/data`: fixtures plus the replaceable `DemoRepository` persistence boundary.
- `lib/state`: Riverpod state and domain operations.
- `lib/features`: onboarding, authentication, five tabs, and detail flows.
- `lib/shared` and `lib/core`: reusable surfaces, feedback, theme, and branding.

## Implemented flows

The app includes onboarding and local workspace access, local job search and filters, saved jobs, resume metadata selection and example previews, deterministic match progress and results, board/list application tracking, derived dashboard figures, profile editing, theme selection, reduced transparency, reset, and sign-out. Account sign-in and rewarded ads show unavailable states until their services are connected.

## Demo boundaries

No credentials are sent or stored. Selected resume files are not copied, parsed, or uploaded. Match results are deterministic fixtures, not AI, ATS measurements, or hiring probabilities. External applications and notifications are not connected. `shared_preferences` stores only demo settings, IDs, resume metadata, application records, and match history.

Live backend integration will use feature-specific repositories instead of uploading
the `DemoRepository` snapshot, which contains simulated authentication and quota.
A future AI service should replace the deterministic match operation behind a
repository interface and map validated responses into the `MatchResult` contract.
