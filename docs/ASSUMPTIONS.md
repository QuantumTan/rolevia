# Rolevia: Baseline Assumptions & Codebase Audit

## 1. Operating Environment & Hardware Targets
- **Primary Audience:** Job seekers, career shifters, and BPO/IT professionals in the Philippines using mid-range Android devices (e.g. MediaTek Helio G99 / Snapdragon 680 class, 4GB-6GB RAM).
- **Display Adaptability:** Fluid refresh rate adaptation for 60 Hz, 90 Hz, and 120 Hz displays without promising locked hardware rates, with a p95 frame budget of under 16.6 ms (and under 8.33 ms where hardware allows) for build and raster in `--profile` mode.
- **Connectivity:** Unstable mobile data (3G/4G/intermittent LTE). Full offline-first capability powered by local Drift SQLite and an outbox queue that synchronizes with Supabase when online.

## 2. Visual Identity & Design System
- **Philosophy:** "Engineered Editorial Utility" inspired by Linear, Things 3, and Flighty.
- **Surfaces:** True Obsidian dark canvas (`#08090C`), Graphite elevated surface (`#111318`), pure white light surface (`#FFFFFF`) with slate canvas (`#F8FAFC`).
- **Borders:** Hairline 0.5pt borders across cards and segmented controls, featuring a subtle specular top edge highlight on dark elevated surfaces (`rgba(255, 255, 255, 0.14)`).
- **Typography:** Inter and native system fonts for primary text; tabular numerals (`FontFeature.tabularFigures()`) across all counts, scores, diffs, dates, and PHP currency amounts.
- **Tactile Feedback:** Spring scale curve feedback on all pressable cards and buttons with haptic micro-clicks honoring the user's haptic toggle.
- **Iconography:** Strict zero-emoji policy across UI strings, assets, logs, comments, and documentation. Vector line icons only (Material Icons/Symbols on Android, Cupertino on iOS).
- **Motion & Data-Viz:** Every screen features purposeful motion explaining state changes and at least one distinctive graphic or data-visualization element.

## 3. Privacy, Security & AI Honesty
- **Philippine Data Privacy Act (RA 10173):** Explicit user consent, strict local retention, zero unauthorized logging of resume text, and full user-directed data deletion ("Reset workspace").
- **Serverless AI Boundary:** No client-side API keys. All external inference calls route through authenticated serverless functions.
- **Prompt Injection Defense:** Job descriptions and resume text are treated strictly as untrusted data strings, never executable instructions.
- **No Hallucinated Experience:** Match scoring strictly measures evidenced qualifications in resume text. Results provide guidance and gap analysis, not hiring predictions.

## 4. State Management & Architecture
- **Framework:** Flutter with Riverpod for application state and selectors.
- **Navigation:** GoRouter stateful shell routing with deep linking support.
- **Persistence:** Drift SQLite local database with sync engine.
