# Performance

For performance work, start from measurable requirements and preserve
functional correctness while improving efficiency.

- Select algorithms and data structures suited to the workload and resource
  constraints.
- For executable changes, run the primary scenario and inspect its actual
  result; an automated smoke check is acceptable.
- For optimization work, state the relevant performance requirement and
  measurement conditions, measure a baseline, and compare the change under
  equivalent conditions. Profile and measure memory or other resources when
  relevant to the workload or suspected bottleneck.
- Add concurrency or asynchronous execution only when requirements and
  measurements justify the extra complexity.
- Verify relevant resource limits, race or concurrency behavior, and
  performance regressions without assuming every change needs all such checks.
