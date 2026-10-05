# Architecture & Design Decisions

## ADR-001: 0.5pt Hairline Surface Architecture with Specular Top Edge
- **Context:** Non-Negotiable Rule 3 requires "hairline 0.5pt borders with a faint specular top edge on dark surfaces" reflecting the "Engineered Editorial Utility" aesthetic.
- **Decision:** Updated `AdaptiveCard` to render custom asymmetric borders on dark surfaces: top edge highlighted with `glassHighlight` (`rgba(255, 255, 255, 0.14)`) at 0.5pt width, and side/bottom edges with `hairlineBorder` (`rgba(255, 255, 255, 0.08)`) at 0.5pt width. Light surfaces retain uniform hairline borders (`rgba(0, 0, 0, 0.08)`).
- **Consequences:** Provides crisp surface separation on OLED and LCD screens without adding heavy shadows or GPU overdraw.

## ADR-002: Elimination of AI-Slop Glyph Tropes (Sparkles & Brain Art)
- **Context:** Non-Negotiable Rule 4 explicitly forbids sparkle icons, glow halos, and stock "AI brain" art.
- **Decision:** Replaced all instances of `Icons.auto_awesome_rounded` and `Icons.psychology_outlined` across application sheets, preferences, dashboard, and tracker with semantic line glyphs (`Icons.analytics_outlined`, `Icons.tune_rounded`, `Icons.playlist_add_check_rounded`, `Icons.code_rounded`).
- **Consequences:** Prevents generic AI clichés while maintaining immediate affordance recognition.

## ADR-003: Strict Zero-Emoji Rule Across Docs and Code
- **Context:** Non-Negotiable Rule 2 strictly bans emojis in UI strings, assets, comments, logs, and documentation.
- **Decision:** Replaced emoji characters (e.g. pin, globe, checkmark glyphs) in `docs/BACKEND_PLAN.md` and test data with vector line icon references or standard alphanumeric text tokens.
- **Consequences:** Ensures clean, professional editorial typography throughout the entire repository.

## ADR-004: Terse Sentence-Case Copy & Removal of Subtitle Taglines
- **Context:** Non-Negotiable Rule 6 mandates terse, functional, sentence-case copy with no taglines under titles.
- **Decision:** Removed promotional taglines (such as the subtitle in ArenaScreen's app bar and marketing filler copy in DiscoverScreen's footer). Standardized CTA buttons and error messages to functional, direct descriptions of the actions.
- **Consequences:** Eliminates cognitive clutter and aligns with tools like Things 3 and Linear.

## ADR-005: AI Honesty & Hiring Prediction Disclaimer
- **Context:** Non-Negotiable Rule 11 requires that every score be explainable with evidence and accompanied by a short disclaimer that results are guidance, not a hiring prediction.
- **Decision:** Standardized the MatchResultScreen disclosure to explicitly state: "Results are guidance, not a hiring prediction. Scores reflect evidence found in your resume text and never invent experience."
- **Consequences:** Reinforces trust and complies with professional ethics and the Philippine Data Privacy Act.

## ADR-006: Design System, WCAG AA Contrast, and Cached ThemeData Architecture
- **Context:** Phase 2 requires strict color tokens, 5 user-selectable accents (default Ocean Blue), platform-aware typography with tabular numerals, strict spacing and radius tokens, cached static final ThemeData objects, motion tokens with spring physics, and WCAG AA >= 4.5:1 contrast compliance.
- **Decision:** Implemented cached static final `ThemeData` matrix (2 brightness x 5 accents = 10 configurations) loaded ahead of the first frame via `ThemePersistence` with zero rebuild overhead. Calibrated light and dark semantic tokens (such as dark error text `#FCA5A5` on `#7F1D1D` at 5.17:1 and light primary `#0369A1` on `#FFFFFF` at 5.9:1) to guarantee WCAG AA >= 4.5:1 contrast against their respective surfaces. Added responsive wrapping (`FittedBox` and `Flexible`) on `MatchBadge` and header rows to eliminate RenderFlex overflow on narrow 320-360dp devices under 1.3x text scale. Created golden tests for `ScoreRing`, `MatchBadge`, and `CompanyAvatar` across brightness modes.
- **Consequences:** Zero jank on theme switching, rock-solid accessibility under large text scaling, and clean design system consistency across the entire app.

