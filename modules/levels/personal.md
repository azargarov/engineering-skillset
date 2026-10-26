# Personal

For a personal project intended to remain useful and maintainable, apply
professional engineering judgment at a depth suited to the task and its risk.

- Keep planning concise for bounded changes. Examine contracts, dependencies,
  and broader design when the change could affect them; do not create formal
  plans or records for routine work without a reason.
- Prefer readable, dependable implementations that fit the project's existing
  conventions and responsibility boundaries.
- Verify changed behavior with focused tests and checks. Add boundary,
  regression, or integration coverage when the affected behavior calls for it;
  avoid duplicating unrelated coverage.
- Preserve maintainability through appropriate error handling, resource
  cleanup, and compatibility with existing consumers where relevant.
- Apply production-specific operational reviews or release controls when user
  requirements or concrete risk warrant them, not by default.
