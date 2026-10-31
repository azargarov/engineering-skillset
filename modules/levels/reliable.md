# Reliable

For reliable systems, make important correctness guarantees predictable and
maintainable while scaling effort to the task's risks.

- State relevant contracts, invariants, boundary behavior, error handling,
  and failure behavior explicitly.
- Keep module responsibilities and interfaces clear enough to preserve those
  guarantees across components.
- Verify meaningful behavior with risk-based unit, integration, regression,
  boundary, and recovery checks; do not exhaustively test every possible input.
- Address observability and operational recovery where they matter to the
  system's requirements.
- Use concurrency only when the task requires it and the design justifies it.
