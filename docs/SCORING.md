# Evidence scoring

Rolevia calculates the match score in code. The language model can extract requirements and evidence, but it cannot choose the final number.

## Requirement verdict values

| Verdict | Multiplier | Meaning |
| --- | ---: | --- |
| Strong | 1.00 | The resume shows the requirement in an experience or project bullet with context. |
| Partial | 0.60 | The evidence is weaker, older, below the required duration, or uses cautious language. |
| Transferable | 0.50 | The resume shows a related skill or responsibility that can transfer to the requirement. |
| Mention only | 0.30 | The term appears only in a skills list without demonstrated use. |
| Missing | 0.00 | The resume provides no usable evidence. |

The constants live in `lib/core/matching/matching_config.dart`.

## Priority weighting

Must-have requirements contribute 70 percent of the score. Nice-to-have requirements contribute 30 percent. If a job has only one priority group, that group receives the full available weight so the score does not drop merely because the posting omitted a preferred section.

Each group score is the average verdict multiplier for requirements in that group. Repeated words do not add weight because each extracted requirement is scored once.

## Years and recency

- Evidence below an explicit minimum-years requirement cannot receive Strong.
- Skills last used more than five years ago are reduced to Partial unless the resume shows newer evidence elsewhere.
- Very old evidence lowers confidence.
- Overlapping employment ranges are merged before total duration is calculated, so concurrent jobs do not double-count time.

## Seniority

If the job asks for a senior or lead level and the resume only shows junior or entry-level roles, Rolevia flags a seniority mismatch and multiplies the result by 0.85. The mismatch is shown to the user.

## Missing must-have caps

The final score is capped when must-have requirements are missing:

- One missing must-have: maximum 75.
- Two missing must-haves: maximum 60.
- Three or more missing must-haves: maximum 50.

This prevents optional strengths from hiding a critical gap.

## Confidence

Confidence is separate from score.

- High: the job text appears complete and the resume has recognizable sections and dated experience.
- Medium: one input has limited structure or some evidence is ambiguous.
- Low: the job looks truncated, the resume parse is weak, or most verdicts rely on low-confidence matching.

## Keyword stuffing

Repeated phrases and oversized skills sections are flagged. They never increase a requirement's multiplier. A contextual experience or project bullet always outranks repeated mentions.
