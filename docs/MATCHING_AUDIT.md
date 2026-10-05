# Matching and job text audit

Date: 2026-10-04

## Executive summary

Rolevia's current Match screen is not using the LLM Edge Function. It runs a local, deterministic comparison through `AppController.analyze`, which calls `MatchAnalyzer.analyze` directly. The local score is mostly literal keyword coverage and does not understand demonstrated experience, dates, duration, recency, synonyms, negation, or requirement priority.

An `analyze-job` Edge Function exists, but the active Match screen does not call it. Its LLM prompt asks the model to invent the overall score, trims both the resume and job description to the first 4,000 characters, does not validate the returned JSON, and has a keyword-only fallback that inserts fabricated matches, gaps, and rewrite metrics.

The dotted, fragmentary job descriptions originate primarily from the job source path. `search-jobs` takes Jooble's `snippet`, not a full description, stores that snippet in `overview`, and collapses every whitespace run to one space. If Jooble supplied ellipses or a teaser, Rolevia preserved them and lost the paragraph and bullet structure. The app then adds generic responsibilities and qualifications that did not come from the listing. The Job Detail screen renders the stored `overview` in full, so its text widget is not the source of the dots.

## 1. How the match score is computed today

### Active on-device flow

The Match screen's `_analyze` method calls `AppController.analyze` at `lib/features/match_screen.dart:155-175`. `AppController.analyze` calls `MatchAnalyzer.analyze` synchronously at `lib/state/app_state.dart:771-801`. There is no network or Edge Function call in this path.

`MatchAnalyzer.analyze` is in `lib/core/services/match_analyzer.dart:55-164`.

The formula is at `lib/core/services/match_analyzer.dart:116-122`:

```text
overall =
  keyword score * 0.70
  + ATS formatting score * 0.20
  + action-verb density * 0.05
  + quantified-action-line density * 0.05
```

The four inputs are:

1. Keyword score: `matched keyword count / job keyword count`, rounded to 0 through 100. See `lib/core/services/match_analyzer.dart:72-84`.
2. ATS formatting score: percentage of boolean PDF checks that passed. See `lib/core/services/match_analyzer.dart:112-115`.
3. Action-verb density: lines containing one of a fixed list of action verbs divided by all non-empty resume lines. See `lib/core/services/match_analyzer.dart:85-107`.
4. Quantified-line density: action lines containing a number plus one of a short list of units, divided by the number of action lines. See `lib/core/services/match_analyzer.dart:97-111`.

For a catalog job with a non-empty `job.skills`, only that skills array is compared. For pasted text, almost every token of at least three characters becomes a keyword after a small stop-word list is removed. See `lib/core/services/match_analyzer.dart:72-79`.

Matching uses a literal, case-insensitive token-boundary regular expression in `_contains` at `lib/core/services/match_analyzer.dart:51-53`. Frequency and context do not matter. One appearance anywhere in the resume counts as a full match.

### Edge Function flow

The separate Edge Function is `supabase/functions/analyze-job/index.ts`.

- `generateMatchAnalysis` tries Gemini, then OpenAI, then `generateDeterministicAnalysis`. See lines 147-242.
- `buildPrompt` asks the model to return its own `overall`, component scores, matched words, missing words, strengths, gaps, and rewrites. See lines 245-280.
- No deterministic formula checks or recalculates the model's score.
- The JSON is parsed directly with `JSON.parse` at lines 189-194 and 229-234. There is no schema validation and no repair retry.
- The fallback at lines 282-352 uses `String.includes` over a fixed keyword list.
- The fallback forces a score into the 55 to 95 range at line 318.
- If it finds no matches, it fabricates `Communication`, `Git`, and `Problem Solving` at lines 311-313.
- If it finds no missing skills, it fabricates `CI/CD` and `Docker` at lines 314-316.
- It also fabricates strengths and quantified rewrites at lines 335-349.

`SyncManager` can send an outbox item whose entity is `analysis` to this function at `lib/data/sync/sync_manager.dart:57-61`, but no current app code enqueues an `analysis` item. The visible Match flow is therefore local keyword scoring only. The Edge Function is present but disconnected from that flow.

### Classification

- Current user-facing Match screen: local, keyword-dominant deterministic scoring.
- Edge Function when called separately: LLM-invented score, with keyword-only deterministic fallback.
- Current architecture as a whole: both implementations exist, but only the local one is wired into the primary UI.

## 2. What resume content is and is not read

The local analyzer reads only `ResumeVersion.extractedText` as one plain string. It also reads the boolean `atsChecks` map. See `lib/core/services/match_analyzer.dart:60-65` and `112-115`.

It does not parse or reason about:

- Resume sections such as Experience, Projects, Education, Certifications, Languages, or Skills.
- Which role, employer, or project supports a skill.
- Start dates, end dates, employment duration, overlapping jobs, gaps, or recency.
- Seniority or scope of responsibility.
- Must-have versus nice-to-have requirements.
- Evidence strength. A skills-list mention and a detailed achievement bullet count the same.
- Negation or weak wording such as `no experience`, `familiar with`, `exposure to`, or `learning`.
- Equivalent and transferable skills.
- Abbreviations, plurals, stemming, or Taglish and Filipino terminology.
- Technology relationships such as SQL versus PostgreSQL, React versus React Native, or AWS versus individual AWS services.
- Keyword stuffing or repeated blocks.
- Source spans or evidence quotes.
- Sensitive attributes. The analyzer does not explicitly score age, sex, civil status, photo, religion, or address, but there is also no structured exclusion layer beyond the existing PII sanitizer.

The `ResumeVersion` model has loose `summary`, `experience`, `skills`, and `education` fields at `lib/models/models.dart:217-242`, but the analyzer ignores those fields and uses only `extractedText` and `atsChecks`.

The Edge Function receives the resume as plain text and asks the LLM to analyze it. Its prompt does not request a structured resume profile, dates, durations, evidence spans, or per-requirement verdicts. It also does not explicitly prohibit decisions based on protected traits.

## 3. PDF text extraction quality

PDF extraction is implemented by `PdfExtractorService` in `lib/core/services/pdf_extractor_service.dart:12-34` using Syncfusion's `syncfusion_flutter_pdf` package.

The current process is:

1. Reject files larger than 10 MB and files without a `%PDF-` signature.
2. Open the PDF with `PdfDocument`.
3. Call `PdfTextExtractor.extractText()` once for the whole document.
4. Reject the PDF if the result is empty.
5. Call `extractTextLines()` only to derive three ATS checks: small fonts, a crude multi-column pattern, and top-margin text.
6. Pass the extracted text through `PiiSanitizer.sanitize`.

Weaknesses and break points:

- Multi-column reading order is whatever `extractText()` returns. The extracted line bounds are not used to reorder columns.
- Bullets are not normalized.
- Hyphenated line breaks are not repaired.
- Repeated headers and footers are not removed. The `marginText` check only reports top-margin text.
- Tables are not reconstructed or flattened deliberately.
- Scanned or image-only PDFs have no OCR fallback. They fail with `This PDF has no text layer. Export a searchable PDF.` at line 25.
- Garbled but non-empty extraction is accepted because there is no parse-quality or character-quality check.
- The UI explicitly advises users to provide a simple one-column, selectable-text PDF at `lib/features/auth_screens.dart:1075` and `1108`, which confirms that complex layouts and scans are not handled.

These gaps can scramble dates, roles, bullets, and skills before matching begins.

## 4. Source of dots and fragments in job descriptions

### Primary root cause: a source snippet is treated as the full description

`JoobleJob` exposes a `snippet` field at `supabase/functions/search-jobs/index.ts:9-20`. The search function transforms that field with:

```ts
const overview = cleanHtml(r.snippet);
```

at `supabase/functions/search-jobs/index.ts:227-234`, then stores it as the job's `overview` at lines 240-269.

A snippet is a teaser, not a guaranteed full description. If the provider sends `...`, `....`, or a cut-off `See more` teaser, Rolevia stores those artifacts unchanged. No later code fetches the full listing from `r.link`.

### Structure loss: whitespace normalization flattens the snippet

`cleanHtml` removes all tags and then runs `.replace(/\s+/g, " ")` at `supabase/functions/search-jobs/index.ts:51-63`. That converts line breaks, paragraphs, and list spacing into a single run-on line. It also removes HTML tags without inserting a line break, so adjacent blocks can merge.

The cleaner does not create ellipses, but it preserves source ellipses while destroying the structure around them. That combination explains fragmentary strings separated by dots.

### Fabricated text is appended to the source snippet

Every imported job gets three generic responsibilities and three generic qualifications at `supabase/functions/search-jobs/index.ts:250-259`. These are not provided by Jooble. `jobText` later concatenates the role, company, snippet, fabricated responsibilities, fabricated qualifications, and skills at `lib/state/app_state.dart:831-838`.

This means the displayed overview and the analyzed text do not represent the same faithful job description.

### UI truncation checks

- Match input: `TextField` uses `minLines: 6` and `maxLines: 12` at `lib/features/match_screen.dart:327-340`. In Flutter, this makes the field internally scrollable; it does not replace content with dots.
- Match input hard cap: the same field has `maxLength: 30000` at line 331. Text beyond the limit cannot be entered through the field. There is no chunking or explicit shortening explanation.
- Job Detail: the description `Text` at `lib/features/detail_screens.dart:233-241` has no `maxLines` and no `TextOverflow.ellipsis`. It displays the stored `overview` in full.
- Results header: `MatchResultScreen` shows the role, company, location, resume, and score, but no job description. See `lib/features/detail_screens.dart:487-545`.
- Job cards use ellipsis for one-line metadata such as location and badges, not for the full description. See `lib/features/discover_screen.dart:883-914` and `948-959`.

### Other candidates checked

- Substring and truncate calls: no Dart truncation is applied to the stored or locally analyzed job text. The Edge prompt does slice it, covered in section 5.
- Share intent: there is no receiver for external shared text. The `/share` route is a hard-coded mock screen at `lib/features/detail_screens.dart:2772-2951`, so external social text is not currently ingested.
- Regex replacing characters with dots: none found.
- Local storage: Drift stores job `overview` and the full domain JSON in SQLite `TEXT` columns at `lib/data/local/app_database.dart:56-74`; no length constraint is defined.
- Server storage: PostgreSQL stores `overview` as unconstrained `text` at `supabase/migrations/20261003000100_foundation.sql:13-39`.
- Sync: `LocalRepository.put` copies `overview` directly at `lib/data/repositories/local_repository.dart:151-171`; it does not truncate it.

## 5. Behavior above current token or character limits

### Match input

The UI has a 30,000-character field limit at `lib/features/match_screen.dart:331`. It does not split, summarize, or clearly report that the model will receive less. The local analyzer sees whatever remains in the controller.

### Local analyzer

The local analyzer has no explicit text cap. It processes the full text that reaches it.

### Edge Function

`buildPrompt` silently slices the resume and job text to 4,000 JavaScript characters each:

- Resume: `params.resumeText.slice(0, 4000)` at `supabase/functions/analyze-job/index.ts:274`.
- Job: `params.jobText.slice(0, 4000)` at `supabase/functions/analyze-job/index.ts:278`.

There is no warning, chunking, map-reduce pass, or audit metadata. Text after the first 4,000 characters is silently ignored by the LLM.

The cache hash is computed from the full inputs at `supabase/functions/analyze-job/index.ts:74-78`, so two inputs that differ only after character 4,000 produce separate cache keys even though the model sees identical prompt text.

## 6. Weaknesses ranked by impact

1. **Critical: the score does not measure evidence.** A literal appearance anywhere in the resume counts as a full match, so a skills-list mention can equal years of demonstrated work.
2. **Critical: users are often analyzing a provider teaser, not the full job description.** Jooble `snippet` is stored as `overview`, with no full-description retrieval or truncation warning.
3. **Critical: the active UI bypasses the LLM Edge Function.** Users receive the local quick calculation as the only result, even though the architecture suggests a fuller analysis exists.
4. **Critical: the Edge Function silently discards all text after 4,000 characters.** Long jobs and resumes lose later requirements and experience.
5. **High: the Edge Function lets the LLM invent the score.** There is no deterministic scoring layer, schema validation, repair retry, or requirement-by-requirement evidence record.
6. **High: the deterministic Edge fallback fabricates data.** It inserts skills, gaps, strengths, and numerical outcomes that may not exist in either input.
7. **High: imported job content is altered with generic responsibilities and qualifications.** This can change both the keywords and the resulting score.
8. **High: PDF reading order is not corrected.** Multi-column resumes can scramble roles, dates, and bullets before analysis.
9. **High: there is no OCR fallback or editable parse preview.** Scanned PDFs fail, and garbled extraction cannot be corrected before matching.
10. **High: no disambiguation, synonyms, Taglish normalization, negation, duration, recency, or seniority logic exists.** Java and JavaScript are boundary-safe locally, but most other language and hierarchy cases are not modeled.
11. **Medium: keyword extraction from pasted jobs treats general prose as requirements.** Common words can become equal-weight keywords after a small stop-word filter.
12. **Medium: job structure is collapsed.** Headings, paragraphs, and bullets are lost in the import path, weakening readability and requirement extraction.
13. **Medium: the Match input enforces a 30,000-character cap with no chunking contract.** This contradicts the requirement to never silently truncate.
14. **Medium: analysis cache is user-scoped and combines both inputs.** It cannot reuse one parsed job across users or one parsed resume across multiple jobs.
15. **Medium: results expose flat matched and missing keyword lists.** Users cannot inspect the evidence, confidence, recency, or reason behind a verdict.

## Implementation plan

### Phase 1: preserve and present complete job text

- Replace `JobIngestion` with a pure, tested `JobTextCleaner` that retains the original text, produces cleaned text, identifies sections, normalizes bullets, removes filler ellipses and social artifacts, de-duplicates blocks, and flags likely truncation.
- Remove the 30,000-character field cap.
- Add a reusable long-text widget that collapses only when text exceeds roughly eight rendered lines and always offers working Show more and Show less controls.
- Use the cleaner and long-text widget in Match input support, Job Detail, and the Results header.
- Stop presenting provider snippets as full descriptions. Mark source snippets as truncated and do not append fabricated responsibilities or qualifications.
- Keep full text in SQLite and PostgreSQL `TEXT` fields and add original-versus-cleaned text fields where needed.
- Add visible character counts, `Full text used` status, and an amber likely-truncated warning.

### Phase 2: evidence-based matching

- Add structured models for job requirements, resume profiles, evidence verdicts, confidence, and score breakdowns.
- Centralize taxonomy, verdict multipliers, priority weights, years and recency modifiers, seniority rules, score caps, and confidence rules in one Dart configuration.
- Build a section-aware local quick estimate that uses the same taxonomy and labels itself `Quick estimate`.
- Rework the Edge Function into versioned job extraction, resume extraction, evidence comparison, schema validation, one repair retry, deterministic scoring, and content-hash caches.
- Delimit untrusted resume and job text as data and explicitly reject instructions contained inside them.
- Persist prompt version, model, token usage, and confidence metadata.

### Phase 3: resume reading quality

- Reconstruct PDF reading order from extracted text-line bounds, normalize bullets and hyphenation, and remove repeated headers and footers.
- Compute parse-quality signals and warnings.
- Add an OCR fallback for empty or severely garbled text, subject to a platform-compatible on-device OCR dependency.
- Add an editable `What we read from your resume` review screen before analysis.

### Phase 4: evidence-first results UX

- Preserve the existing Rolevia design tokens, navigation, tracker, rewrite, and interview flows.
- Show score, confidence, and one-line verdict together.
- Group requirements by must-have and nice-to-have.
- Replace matched and missing keyword chips with evidence verdict rows.
- Make each row open a bottom sheet with the resume quote, section, role, recency, reason, confidence, and a truthful suggestion.
- Rename missing keywords to `Gaps to close` and explicitly tell users not to add skills they do not have.

### Phase 5: tests and evaluation

- Add the requested 15 or more fixtures and expected verdicts.
- Add unit tests for cleaning, section detection, taxonomy, duration math, and deterministic scoring.
- Add widget tests for full-description expansion and the evidence sheet.
- Add a repeatable evaluation script that prints expected versus actual verdicts and score deltas.
- Run formatting, `flutter analyze`, the full test suite, and relevant Edge Function checks.

## Phase 0 conclusion

Problem 1 is confirmed: the active match result is mostly literal keyword coverage, not content understanding. Problem 2 is also confirmed: imported jobs use a flattened provider snippet as the full description, while long LLM inputs are separately cut to 4,000 characters without disclosure.
