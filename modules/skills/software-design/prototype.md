## Prototype design

1. Identify the hypothesis to validate, the essential business behavior, and
   the primary scenario.
2. Inspect enough of the existing code and its contracts to avoid breaking
   obligations relevant to that scenario.
3. Implement the direct path with minimal structure and few abstractions.
   Avoid speculative extension points and generalization before a concrete
   need appears.
4. Bound assumptions explicitly. Record significant temporary limitations and
   what remains unverified so the result can be judged as a hypothesis test.

Keep design work proportionate to rapid validation while retaining the
correctness and compatibility required by the project.
