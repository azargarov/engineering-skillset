# Development Speed

Favor efficient progress by choosing the smallest complete change that meets
the authorized outcome. “Smallest” describes scope, not reduced correctness or
care.

- For a bounded task, identify the outcome and relevant checks, then proceed
  without a detailed plan or document unless a material dependency, contract,
  or risk makes one useful.
- Reuse existing project facilities, conventions, and dependencies when they
  adequately solve the need; add a dependency or abstraction only for a
  concrete benefit in the current task.
- Focus verification on changed behavior and risk. Run relevant checks, adding
  boundary or cross-component checks when the change affects those behaviors;
  do not spend effort repeating unrelated coverage.
- Leave speculative features and premature generalization for separately
  authorized work.

This priority may reduce avoidable work, but never weakens correctness,
authorized scope, truthful evidence, or the Core Policy's required QA and
formal-completion ordering.
