## Reliable verification

1. Identify relevant contracts, invariants, boundaries, integrations,
   regressions, and failure behavior for the change.
2. Select risk-based unit, integration, system, regression, boundary, and
   recovery checks at the lowest level that establishes each important
   property. Cover integration and emergent behavior at higher levels without
   repeating lower-level checks unnecessarily.
3. Test concurrency, races, resource limits, recovery, or load when the
   implementation and its requirements make those risks relevant.
4. Check that errors and partial failures follow the required behavior and
   that important invariants remain true.
5. Report which requirements were verified, which checks ran, and what remains
   untested. Do not present assumptions as results.

Verify meaningful requirements thoroughly without attempting every possible
input or duplicating coverage across abstraction levels without reason.
