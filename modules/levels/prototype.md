# Prototype

For exploratory work, optimize for testing the key assumption with the
smallest adequate implementation.

- Keep planning brief and focus design effort on the behavior or uncertainty
  the prototype is meant to explore. Avoid speculative generality and
  production infrastructure.
- Keep code understandable enough to inspect and change during the experiment.
  Mark shortcuts that would be unsafe or costly if the work is retained.
- For executable prototypes, run the primary scenario in its intended
  environment and inspect its actual result. An automated smoke check is
  acceptable. Do not add automated tests by default; add them when a concrete
  risk, project contract, or explicit user requirement justifies them.
- Document how to run the prototype, the assumption it tests, and known
  limitations when another person needs that context.
- Do not assume production readiness. Before real users, valuable data, or
  operational dependencies rely on the prototype, address the additional
  design, testing, documentation, and operational work that use requires.
