## Reliable verification

1. Identify relevant contracts, invariants, boundaries, integrations,
   regressions, and failure behavior for the change.
2. For changes affecting observable software behavior, require automated
   tests covering applicable behavioral risks. Add or update tests as needed,
   execute them, and inspect their results. Select tests by the guarantees
   being verified; do not impose arbitrary test counts or duplicate coverage.
   Compilation, static analysis, and diff checks do not satisfy this
   behavioral-test requirement.
3. Test concurrency, races, resource limits, recovery, or load when the
   implementation and its requirements make those risks relevant.
4. Cover applicable concerns such as concurrency, idempotency, persistence,
   boundary conditions, failure handling, recovery, and regression at the
   level needed to establish each guarantee. Check that errors and partial
   failures follow the required behavior and that important invariants remain
   true.
5. Inspect results and report which requirements were verified, which checks
   ran, and what remains untested. If required tests cannot be implemented or
   executed, record the reason, unverified guarantees, and residual risks, and
   mark QA **INCOMPLETE**. Do not claim successful verification without
   execution evidence or full verification when a critical check is missing.

Do not require 100% coverage or exhaustive input testing; verify meaningful
requirements thoroughly without duplicating coverage across levels without
reason.
