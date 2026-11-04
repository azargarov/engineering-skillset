# Reliable

For reliable systems, make important correctness guarantees predictable and
maintainable while scaling effort to the task's risks.

- State relevant contracts, invariants, boundary behavior, error handling,
  and failure behavior explicitly.
- Keep module responsibilities and interfaces clear enough to preserve those
  guarantees across components.
- For significant requirements, implement and execute all necessary
  risk-based checks, including applicable unit, integration, boundary,
  regression, failure, and recovery behavior. Inspect results and report
  guarantees that remain unverified. If a necessary check cannot run, report
  the blocker and leave its guarantee unverified; do not claim full
  verification while a critical check is missing. Do not require 100% coverage
  or exhaustive input testing.
- Address observability and operational recovery where they matter to the
  system's requirements.
- Use concurrency only when the task requires it and the design justifies it.
