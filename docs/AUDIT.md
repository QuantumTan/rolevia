# Rolevia Codebase Audit (Phase 0)

Date: 2026-10-05
Scope: Comprehensive review of all screen features, navigation shells, shared widgets, and state interactions.
Standard: 12 Non-Negotiable Rules (Engineered Editorial Utility, Zero Emojis, Zero AI-Slop, Accessibility, Performance Budget).

---

## 1. Executive Summary & Defect Categorization

This audit documents confirmed defects and architectural gaps across 9 core screen surfaces:
- Discover (`lib/features/discover_screen.dart`)
- Pipeline / Tracker (`lib/features/tracker_screen.dart`)
- Vault (`lib/features/vault_screen.dart`)
- Dashboard (`lib/features/dashboard_screen.dart`)
- Match Studio (`lib/features/match_screen.dart`)
- Arena Screen (`lib/features/arena_screen.dart`)
- Profile & Settings (`lib/features/detail_screens.dart`)
- Details & Sheets (`lib/features/application_details_sheet.dart`, `lib/features/detail_screens.dart`)
- App Shell & Navigation Bar (`lib/features/shell.dart`, `lib/core/widgets/adaptive_navigation_bar.dart`)

---

## 2. Screen-by-Screen Audit Findings

### 2.1 Discover Screen (`lib/features/discover_screen.dart`)
- **Layout & Filter Bloat (L546-583, L730-817):**
  - Location is presented as a plain unstyled text row without structured chip framing or clear tactile boundary.
  - Filter pills lack explicit categoric grouping into a single horizontal row of outlined chips with chevrons (`Role type`, `Work arrangement`, `Salary range`, `Radius`).
  - Active filter counts are not badged on individual chips.
- **Sponsor / Ad Banner Slop (L957):**
  - `AdBannerWidget` remains in the footer column, violating the rule against intrusive sponsor banners and ad slop.
- **Widgets Forcing Extra Rebuilds (L640-660):**
  - `_searchController.onChanged` calls unbatched `setState()` on every keystroke in addition to debounced queries, causing full-viewport sliver tree rebuilds during user typing.
- **Accessibility Gaps:**
  - Filter tap targets under 44x44 minimum touch target without `MaterialTapTargetSize.padded`.
  - Location picker lacks an explicit `Semantics` label explaining its modal action.

### 2.2 Pipeline / Tracker Screen (`lib/features/tracker_screen.dart` & `lib/features/shell.dart`)
- **Layout Collision & Redundant Add Actions (shell.dart: L154-169, tracker_screen.dart: L129, L156-164):**
  - `FloatingActionButton` on index 1 floats 72pt above the bottom edge, directly colliding with card content and competing with an inline "Add application" button in `EmptyState` and an `IconButton` in `SliverAppTopBar`.
  - Fix: One single add action belongs in the navigation bar; remove the floating button and inline add button.
- **Duplicate Actions on Cards (tracker_screen.dart: L737-770, L772-803):**
  - On `_ApplicationCard`, both the `record.matchBadge` pressable container (L740) and the primary `Analyze` button (L773) trigger `_analyzeRecord(context, ref)`.
  - Fix: Exactly one contextual action per card.
- **Missing States:**
  - Offline sync status indicator relies solely on textual banner without offline queue count badge.

### 2.3 Vault Screen (`lib/features/vault_screen.dart`)
- **Button Text & Redundancy (L937-952, L982-1040):**
  - Historical button strings included redundant plus symbols (`+ + Upload PDF`).
  - Active resume view duplicates upload/paste split actions between the empty header and the main scroll view.
  - Fix: Standardize to "Upload PDF" with "Paste text" as a secondary action in a bottom-anchored split control.
- **Diagnostics Vertical Bloat (L217-307):**
  - `_buildAtsHealthCard` consumes excessive vertical height due to multiline explanatory prose and stacked full-width rows for column layout, density, and limits.
  - Fix: Show ATS checks as a compact two-column tabular card (check name, status line icon, value) with monospace figures.
- **Missing States:**
  - When analyzing large PDF payloads, error fallback does not suggest copy-paste as a direct actionable fallback button.

### 2.4 Dashboard Screen (`lib/features/dashboard_screen.dart`)
- **Duplicate Quota Cards, Watch-Ad Triggers & Sponsor Banners (L91, L314, app_top_bar.dart: L600-645):**
  - Quota is shown as an arbitrary stat box ('Scans available') among metrics, and repeated inside settings sheets.
  - Ad triggers are scattered across multiple surfaces.
  - Fix: Exactly one quota pill in the top bar; zero sponsor banners; rewarded ad trigger exists only in an on-demand sheet when tapping the quota pill or when scans are exhausted.
- **Recursive Navigation (L314-321):**
  - `EmptyState` includes an action button navigating to `/match` via `context.go('/match')` while Match is already accessible via the primary studio action.

### 2.5 Match Studio (`lib/features/match_screen.dart`)
- **Duplicated Entry Points Across Tabs:**
  - Match is entered through ad-hoc cross-links in `DashboardScreen`, `JobDetailScreen`, `VaultScreen`, and `ResumeViewerSheet`.
  - Fix: Centralize into one Match Studio opened from the center Analyze action in the navigation shell and from contextual "Analyze" buttons on a job or resume card.
- **Filler Copy (L256-261):**
  - Subtitle text ("Quick estimates work offline. When connected...") acts as cognitive filler under the title.
- **Keyboard Handling & Ingestion State:**
  - Text input area lacks auto-clearing upon successful match generation, preserving stale job text on return.

### 2.6 Arena Screen (`lib/features/arena_screen.dart`)
- **Recursive Navigation (L258):**
  - Resume selection fallback button calls `context.go('/vault')`, duplicating the bottom navigation bar.
- **Typography & Consistency:**
  - Score radar labels lack tabular figure formatting on dynamic metrics.

### 2.7 Profile & Settings Screen (`lib/features/detail_screens.dart`)
- **Clutter & Loose Pill Clusters (L2716-2857):**
  - Seniority levels, themes, default tabs, and skills are rendered as loose wraps of blue chips with arbitrary wrapping points.
  - Fix: Platform-native grouped lists (inset grouped on iOS, Material 3 grouped cards on Android); convert pill clusters into segmented controls.
- **Accent Color Picker (L2716-2775):**
  - Color choices are laid out as loose checkmark chips rather than an engineered row of 5 circular swatches.
- **Cluttered Toggles (L3350-3550):**
  - Switches for Reduce Motion, Reduce Transparency, and Haptics are rendered without clear section framing or dividers.

### 2.8 App Shell & Navigation Bar (`lib/features/shell.dart`, `lib/core/widgets/adaptive_navigation_bar.dart`)
- **FAB Collision on Index 1 (shell.dart: L154-169):**
  - Floating action button overlays `LiquidGlass` bar on mobile viewports.
- **Unified Center Analyze & Add Integration:**
  - Navigation bar currently holds 4 flat tabs without a dedicated center Analyze action for Match Studio.

---

## 3. Phase 1 Purge Verification & Resolution

The following confirmed defects were resolved in Phase 1:
1. **Discover Screen:**
   - Replaced 3 stacked rows of blue filter pills with a single horizontal scroll row of 4 outlined chips with chevrons: `Role type`, `Work arrangement`, `Salary range`, `Radius`.
   - Each chip opens an adaptive multi-select bottom sheet with persistent `Reset` and `Apply` action rows. Active filter counts display dynamically on each chip badge (e.g. `Role type (2)`).
   - Location transformed from plain unstyled text to an outlined top chip with pin icon, chevron, and `Semantics` action.
   - Removed `AdBannerWidget` sponsor banner from the footer sliver.
2. **Pipeline / Tracker:**
   - Removed the floating add button and inline `EmptyState` add button.
   - Docked a single, accessible add application action (`_NavAddButton` with 44x44 minimum touch target) into the adaptive navigation bar for the Tracker tab.
   - Unified duplicate actions on `_ApplicationCard`: Wishlist cards now have exactly one contextual action (`Analyze`), and other stages display informative status tags without redundant press handlers.
3. **Recursive Navigation:**
   - Removed cross-links duplicating tab destinations (`/match`, `/vault`, `/discover`) in Dashboard `EmptyState`, Arena screen resume fallback button, and Match screen header.
4. **Vault:**
   - Standardized button text to "Upload PDF" and secondary action to "Paste text".
   - Added a bottom-anchored split control (`Upload PDF` flex: 3, `Paste text` flex: 2) floating neatly above the navigation bar, and removed duplicate split buttons from the scroll body.
   - Compacted ATS structural health diagnostics from stacked cards into an engineered two-column tabular card (check name | status icon, monospace value) with full overflow protection at 1.3x and 2.0x text scaling.
5. **Match Studio:**
   - Standardized screen title to "Match Studio" in `SliverAppTopBar`.
   - Purged redundant "Job match" header and filler subtitle ("Quick estimates work offline...").
   - Removed redundant Vault cross-link button in favor of a clean, full-width resume switcher pill.
6. **Dashboard:**
   - Cleaned the metric stats grid to 3 core metrics (Applied, Interviews, Tracked roles), removing quota from the grid.
   - Verified quota pill lives in the top bar with on-demand rewarded scan sheet.
   - Purged all sponsor banners and filler marketing subtitles.
7. **Profile & Settings:**
   - Converted loose blue pill clusters for Seniority (`ExperienceLevel`), Theme Mode (`AppTheme`), Default Start Screen, and Interview Language into native `SegmentedButton` controls.
   - Refactored accent color picker into a horizontal row of 5 circular swatches with minimum 44x44 touch targets and selection indicators.
   - Removed marketing filler taglines under section headings.
8. **Filler Copy:**
   - Purged taglines and filler descriptions across Dashboard, Match, Vault, and Profile screens.
9. **Zero Emojis:**
   - Confirmed 0 emojis across all code, strings, assets, comments, and logs.

---

## 4. Remaining Defects for Subsequent Phases (Phases 2-6)

The following architectural and polish items remain to be addressed in subsequent phases:
1. **Dedicated Center Analyze Navigation Item:**
   - Integrating the permanent center Analyze button into the navigation bar shell for instant one-tap Match Studio access (to be completed in Prompt 5).
2. **Offline Outbox & Sync Resilience:**
   - Adding exponential backoff with randomized jitter to `RemoteSyncService` batch outbox retries.
   - SQLite cold-start pre-seeding for first-launch performance on mid-range Android devices.
3. **Voice & Arena Audio Pipeline:**
   - Handling audio permission states and offline speech-to-text fallback in `ArenaScreen`.
4. **Custom Data Visualizations & Geometric Monoline Assets:**
   - Replacing generic placeholder icons with custom monoline geometric vector illustrations in empty and error states.
   - Adding custom `Semantics` accessibility nodes for multi-stage radar charts and evidence breakdown bars.
5. **Sheet Dismiss Gesture & Keyboard Inset Polish:**
   - Fine-tuning keyboard dismiss interactions on high-scale text settings (textScaleFactor >= 1.3) in application details modal.
