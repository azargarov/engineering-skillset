## Performance design

1. Translate performance goals into measurable workload, latency, throughput,
   memory, or resource requirements.
2. Inspect the relevant algorithm and data flow. Use profiling or benchmarks
   to identify costly work before adding optimization structure.
3. Keep efficiency improvements localized where practical, and preserve the
   functional contracts and behavior of the system.
4. Add concurrency or asynchronous boundaries only when measurements and
   requirements justify them; account for their resource and correctness
   costs.
5. State the expected measurement that will show whether the design meets its
   performance goal.
