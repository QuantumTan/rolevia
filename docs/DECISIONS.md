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
