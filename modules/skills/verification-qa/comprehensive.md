## Reliable verification

1. Identify relevant contracts, invariants, boundaries, integrations,
   regressions, and failure behavior for the change.
2. Implement and execute all necessary risk-based checks for significant
   requirements, including applicable unit, integration, system, regression,
   boundary, failure, and recovery behavior. Use the lowest level that
   establishes each property and cover emergent interactions at higher levels
   without unnecessary repetition.
3. Test concurrency, races, resource limits, recovery, or load when the
   implementation and its requirements make those risks relevant.
4. Check that errors and partial failures follow the required behavior and
   that important invariants remain true.
5. Inspect results and report which requirements were verified, which checks
   ran, and what remains untested. If a necessary check cannot run, report the
   blocker and leave the relevant guarantee unverified. Do not claim full
   verification when a critical check is missing or present assumptions as
   results.

Do not require 100% coverage or exhaustive input testing; verify meaningful
requirements thoroughly without duplicating coverage across levels without
reason.
