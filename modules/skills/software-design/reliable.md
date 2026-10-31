## Reliable design

1. Identify relevant behavior, contracts, invariants, boundaries, and failure
   conditions before choosing component responsibilities.
2. Define cohesive module responsibilities and the smallest clear interfaces
   needed to preserve those contracts across boundaries.
3. Make important invariants, error handling, and failure behavior explicit.
   Consider partial failure and recovery where the task requires them.
4. Choose a maintainable design that controls coupling without adding layers
   or abstractions that do not protect a real responsibility or invariant.
5. Describe material trade-offs and assumptions, and keep unverified claims
   distinct from established requirements.

Address integration and operational constraints where they affect the design.
