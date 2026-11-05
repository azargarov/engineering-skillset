## Verification principles

- Identify the task's important expected behavior and concrete risks before
  choosing checks.
- For changes to observable software behavior, name the behavioral guarantees
  being changed or preserved and the risks relevant to those guarantees.
- Prefer checks that establish the required behavior directly. Report what
  each check establishes and identify important gaps.
- Preserve functional correctness and existing project contracts while
  changing code.
- Distinguish observed verification results from assumptions and untested
  claims.
- For every property reported as verified, retain a traceable evidence row
  with the property or requirement, method, result, and evidence reference.
  For each executable check, record the exact command and exit code plus the
  relevant inspected output or artifact reference. Group properties only when
  the same check directly supports each one. Inspect results; an uninspected
  log or a delegate's report alone is not evidence. If the method, result, or
  supporting evidence is insufficient, report the property as partially
  verified or unverified.
- Match verification level to the property. A property about component
  interaction needs integration-level evidence; component checks alone cannot
  establish it. Select additional higher-level checks to cover interactions
  and emergent behavior without duplicating lower-level coverage needlessly.
- Do not infer a property beyond what the check demonstrates:

  | Invalid conclusion | What the result actually establishes |
  | --- | --- |
  | Compilation succeeded, therefore behavior is correct | The code compiled under the recorded conditions. |
  | Component tests passed, therefore integration works | The tested components passed; their interaction remains unestablished. |
  | A command exited zero, therefore every requirement passed | That command completed successfully; inspect what it checks and its output. |
  | A change was reviewed, therefore it was independently verified | Review is assurance only to the extent and independence actually performed. |

- For a reproducible defect, capture the failing condition before correction,
  then repeat the relevant reproduction after the fix and record the resolution
  evidence. Use an automated regression test when suitable; otherwise use an
  equivalent reproducible manual check or other direct evidence. This bounded
  red–green check applies to reproducible defects and does not require
  test-first development for every change.

Compilation, static analysis, and diff checks establish useful properties but
cannot substitute for behavioral verification when behavior changes.
