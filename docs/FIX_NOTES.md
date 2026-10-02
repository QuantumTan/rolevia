# Fix notes

## Task 6: Application details

### Before: root causes

1. Shared sheet chrome exposed Med/Large buttons and a fixed-height AnimatedContainer instead of draggable detents.
2. The body owned a separate SingleChildScrollView, so resize and scroll gestures could not hand off.
3. The modal also retained its outer drag recognizer; a single coordinated sheet is needed.
4. Notes resources lived in a function/StatefulBuilder and were disposed in the route future's whenComplete, before the exit animation necessarily unmounted the field.
5. Autosave coexisted with Save changes; stage selection depended on that extra save action.
6. A stale captured record could overwrite changes when a later notes save ran.
7. The body repeated the header summary and lacked date/link/resume details and delete confirmation.

The reported `_dependents.isEmpty` assertion is an inherited-element teardown assertion. The old early-disposal path was unsafe; it has been removed. The original full stack trace was not supplied, so no claim is made that the assertion itself was reproduced before the fix. Dirty-note swipe/scrim dismissal and repeated reopening now pass without framework exceptions.

### After

- One `showModalBottomSheet` route with `isScrollControlled: true`, scrim dismissal and outer dragging disabled; one DraggableScrollableSheet handles resizing.
- `minChildSize: 0`, expanded detent 0.95, `snap: true`. Collapsed is 0.55 on ordinary viewports. At 360 x 640 it becomes 0.5625 to keep 360 pixels; rotation updates the resting detent without resetting content. A viewport shorter than 379 pixels cannot fit a 360-pixel sheet under a 95% maximum, so it uses the physical 95% limit rather than overflowing the display.
- Header and body share the sheet-provided controller via one CustomScrollView. Header stays pinned. Content expands before scrolling and downward drags at scroll offset zero resize the sheet.
- Velocity selects the next detent for fast flicks; gentle releases choose the nearest. Settle uses a 300 ms easing curve. Reduced motion uses direct jumps for programmatic/custom settles and a one-millisecond native snap fallback.
- Light haptic on arrival at a detent. The 36 x 5 grabber, 8 pixels from the top, has a 44-pixel drag area and nudges up once per sheet type after the entry animation. Reduced motion suppresses that hint.
- Grabber Semantics exposes Expand and Collapse custom actions, without visible resize buttons.
- Notes focus expands to 95%. Keyboard-inset changes queue a second visibility update if an earlier reveal is still running, preventing the keyboard from covering the field. Closing the keyboard leaves the sheet expanded.
- Solid body, glass header only, 28-pixel top corners and light/dark styles. Header contains a 48-pixel company avatar, two-line 22-point semibold role, one-line metadata and a 44-pixel close action.
- One row contains the existing score badge and View analysis. Analysis navigation uses the latest stored analysis for the application job ID. Unlinked applications have a disabled analysis action rather than a made-up result.
- One horizontal group of five capsule status chips saves through the existing update operation immediately. No status dropdown.
- Details show a tappable applied date, resume title, domain-only job link and location. Date picker updates the existing appliedAt field. HTTP(S) links open with the platform browser and have failure feedback.
- ApplicationRecord has no analysis/resume ID. Resume is taken from the latest stored analysis for the linked job, with an explicit source note; absent data says Not recorded. No model or repository field was added.
- Notes have four minimum lines, a 350 ms debounce, and inline Saved/check feedback that fades in and remains for two seconds. Saved indicates handoff to the existing controller; the existing fire-and-forget persistence contract was not altered.
- PopScope flushes pending notes on close, scrim and swipe dismissal. A ConsumerStatefulWidget owns/disposes the text controller, focus node and timers when the subtree unmounts. No provider writes or ancestor lookups occur in dispose. Saves read the current record, preserving stage/date edits.
- Delete application confirms with “Delete this application?” / “This can't be undone.” and Cancel/Delete. Deleted records are not restored by a pending notes save.

### Redundant controls removed

- Med/Medium and Large detent buttons and their showDetents/openLarge size-control API, globally in the shared helper.
- Application Save changes button, since notes autosave and stage/date changes commit through existing UI callbacks.
- Repeated body role/company summary and separate notes-status footer; these are now one header and one inline Saved indicator.
- Duplicate resize handling from the outer modal drag recognizer and independent body scroller.

### Verification

- Baseline: 46 tests passed.
- After: 60 tests passed, including 14 new sheet tests. No new analyzer issues. Web release build and Wasm dry run succeed.
- Tests cover absent size/Save buttons; exactly one status control; actual drag to 55%/95% and dismissal; scroll handoff; haptics; domain-only link and platform launch payload; autosave/Saved expiry; immediate stage updates; pending notes on scrim dismissal; three repeated dirty swipe dismissals; accessible resize actions; reduced motion; rotation; both themes at 360 x 640 and text scale 1.3; keyboard visibility; date picker and delete confirmation/cancellation.
- Existing theme, golden and responsive tests still pass. Source search finds no Med/Medium/Large size buttons or detent-toggle APIs.
- Browser: Tracker card opens details without size controls; grabber drags to expanded and back to collapsed; details and notes are visible when expanded. Screenshots are in `artifacts/task6-sheet-collapsed.jpg` and `artifacts/task6-sheet-expanded.jpg`.
- No device performance/FPS claim is made. Android native verification remains blocked by the previously timed-out Flutter engine download; iOS simulator is unavailable on this Windows host. Keyboard/rotation checks are automated widget checks, not physical-device claims.

### Dependencies and scope

Added pinned `url_launcher 6.3.2` for the requested job-link browser action and its generated desktop plugin registrations. Official package: https://pub.dev/packages/url_launcher. No animation package was added. Models, repository, controller, fixtures, API/sync logic and existing unrelated tooling edits were left unchanged. This commit handles Task 6; the other tasks in the attached broader brief are outside this change.

### Scoped design review

- Layout/theme PASS: small-screen keyboard/rotation tests and existing responsive/golden matrix pass; header/body remain separate navigation/content layers.
- Controls/states PASS: resize, status, date, delete and notes tests invoke real supported actions; unavailable analysis/resume/link data is shown honestly. The copied domain launch payload is tested without opening a real external site.
- Accessibility PASS for the changed controls: minimum 44-pixel header/grabber actions, custom resize semantics, text 1.3 reflow and reduced-motion checks. Existing contrast-token tests remain passing.
- Purpose/liveliness PASS: the existing indigo career-utility direction is retained; glass marks the sheet header, the grabber explains dragging, and Saved feedback reports a concrete edit.
- Native runtime/performance review remains unverified; this scoped review does not replace device testing.
