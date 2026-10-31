# Performance

For performance work, start from measurable requirements and preserve
functional correctness while improving efficiency.

- Select algorithms and data structures suited to the workload and resource
  constraints.
- Profile representative behavior before optimizing; benchmark changes and
  examine memory use where it matters.
- Add concurrency or asynchronous execution only when requirements and
  measurements justify the extra complexity.
- Verify relevant resource limits, race or concurrency behavior, and
  performance regressions without assuming every change needs all such checks.
