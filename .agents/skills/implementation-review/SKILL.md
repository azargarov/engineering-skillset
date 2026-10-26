---
name: implementation-review
description: Review an implementation for correctness, scope, design quality, complexity, and maintainability when a code review or implementation review is requested.
---

Review the implementation against the authorized outcome. Use the level of
detail appropriate to its size and risk; a small change may need only its diff
and directly related code.

1. Identify the requested outcome, constraints, acceptance criteria, and
   applicable project instructions. Inspect the relevant diff, implementation,
   contracts, and tests. Follow wider dependencies or architecture only when
   the change can affect them.
2. Look for concrete correctness defects, design or architectural weaknesses,
   broken contracts, security or reliability problems, unnecessary complexity,
   duplication, and maintainability problems. Check edge cases and failure
   paths when relevant.
3. Separate demonstrated defects from optional improvements and speculation.
   Support each finding with specific code or behavior and explain its effect.
   Do not report style preferences as defects.
4. Order findings by impact on the requested outcome and explain the basis.
   For each finding, identify its location, evidence, consequence, and smallest
   justified correction. Keep optional suggestions separate and include them
   only when they provide meaningful value.
5. Apply the active project level and engineering priorities where they affect
   concrete choices. Use only configuration already present in instructions or
   context; do not infer missing settings or add review ceremony.
6. Make corrections only when they are within the authorized task. After an
   authorized correction, check that it addresses the finding and run focused
   verification for the affected behavior and plausible regressions. Review
   the resulting diff. If a correction was not authorized, state what remains
   to be done rather than changing scope.
7. Report findings first. If none were found, say so and identify the reviewed
   scope. Distinguish observed evidence, interpretation, checks actually run,
   and anything not established.

When reviewing work you authored, describe this as self-review. Do not present
it as independent assurance.
