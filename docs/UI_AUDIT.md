# UI audit before redesign

Baseline: 2 October 2026. `flutter analyze`: no issues. `flutter test`: 34 tests passed.

## Architecture and boundaries

Riverpod Notifier holds app state; GoRouter uses an indexed shell that preserves tab state. SharedPreferences backs a local demo repository. There is no Supabase client or real AI/ad service. Models, fixtures, repository and controller must remain unchanged. Existing uncommitted UI, Android tooling and layout-test changes belong to the user and must be preserved.

## Findings

- ThemeExtension colors and semantic typography exist under `core/design`; palette slightly differs from the supplied brief. Fonts use native fallback. Spacing/radii are centralized but screens still repeat literals.
- Adaptive cards/buttons, glass navigation, collapsing headers, keyboard focus, scenario skeleton/error/empty states and a transparency preference already exist. Reuse these rather than replacing the architecture.
- Shared and results score rings duplicate styling, use indigo for every score and lack a consolidated score semantics label. Band badges and deterministic company avatars should be shared.
- Empty states and onboarding use generic single icons instead of product-specific original illustrations. No asset or native branding setup exists.
- Loading skeletons pulse indefinitely even with reduced motion. Glass includes a sheen gradient beyond the requested single hero wash. Transparency preference is passed inconsistently.
- Results keywords and matched skills have working controls, but expansion is abrupt. Copy feedback exists as toasts without an in-place confirmation. Rewrites remain explicit prototype examples.
- Discover uses fixture jobs, so pull-to-refresh must not imply a remote fetch. Tracker updates are already supported, but drag/swipe interactions need UI-only wiring to existing controller actions.
- Dashboard counts are real local state; a weekly chart must derive dates from local records rather than invent trends. Interview responses are a local demo and must stay labeled accordingly.
- Existing tests cover tabs at widths 320, 390, 768, 1280 and landscape 844, with light/dark and text scales 1 and 2. Additional score/badge/empty/navigation tests are needed.

## Phased plan

1. Align tokens and theme entry points; retain native font fallback until a licensed Inter dependency is available.
2. Consolidate score/badge/avatar and glass behavior, preserving navigation and focus.
3. Refine Match, Results, Rewrites, Discover, Vault, Tracker, Dashboard and onboarding through existing UI callbacks.
4. Create original document/kanban SVG illustrations and branding; register assets and generate native resources.
5. Test bands, semantics, reduced motion, dark/light and responsive layouts; build and document platform verification limits.

Design read: career utility for Philippine fresh graduates; ENERGY 2 / RHYTHM 2 / MOTION 2. Indigo identifies primary actions, amber highlights scarce scans, semantic colors explain match bands. Solid cards keep content legible; glass marks navigation elevation. Document and kanban artwork teaches the actual workflow. Spacing separates job input, resume choice and the analysis action. Motion communicates progress, selection and successful copying.

## Device baseline

Available targets: Windows, Chrome and Edge. No connected Android emulator or iOS simulator. Native mobile and frame profiling are pending, not verified.
