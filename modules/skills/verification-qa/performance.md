## Performance verification

1. For executable changes, run the primary scenario and inspect its actual
   result; a manual or automated smoke check is acceptable.
2. For optimization work, state the relevant performance requirement and
   measurement conditions, measure a baseline, and compare the changed version
   under equivalent conditions. Use profiling to explain observed changes.
3. Check memory and other resource use when they are part of the requirement
   or relevant to the workload or suspected bottleneck.
4. Verify relevant concurrency, race, resource-limit, and regression behavior
   when the implementation uses those mechanisms or requirements depend on
   them.
5. Recheck functional correctness while optimizing, and report measurement
   conditions and unverified claims.
