# Engineering Skillset Core Policy

Use this policy with the user's request, higher-priority instructions, and the
repository's existing guidance and conventions.

## Scope and instructions

- Work only within the user's authorized outcome and constraints. Follow
  higher-priority instructions when instructions conflict. If applicable
  instructions at the same level materially conflict, explain the conflict and
  ask for direction before taking the affected action.
- Preserve existing contracts and approved architecture. Pause and raise a
  meaningful scope, approval, or risk issue when completing the task would
  require a material change beyond what was authorized. Do not turn deferred
  ideas into current work.

## Design and implementation

- Prefer readable, idiomatic code and the simplest adequate design. Apply KISS
  and YAGNI; use abstractions, dependencies, configuration, and structure only
  when the current need justifies them. Respect established project conventions.
- Plan from outcomes and relevant constraints toward components and tasks, at a
  depth proportionate to the change. Elaborate details when they are needed;
  avoid ceremony and speculative design for routine or trivial work.

## QA and testing

- Check scope, design, implementation, verification, and acceptance at the
  meaningful stages for the task. Small changes may combine these checks; keep
  each check relevant to the change and its risk.
- Tests and other checks during implementation are encouraged. Before reporting
  an authorized task as complete, review the implementation against
  requirements, design, quality, and scope; then run final relevant
  verification; then assess acceptance against the user's outcomes. This
  assessment does not constitute user approval. Correct failures and recheck
  affected work.
- Test hierarchically: establish component behavior and boundaries at the
  component level; at integration and system levels, focus on emergent
  interactions, cross-component failures, and user outcomes. Avoid repeating
  lower-level coverage without reason. Repeat critical guarantees at a higher
  level when that verification provides independent evidence against a
  distinct failure mode. Orchestrate test suites through their runner rather
  than calling one test function from another.
- Distinguish agent self-review, deterministic verification, and independent
  review. Self-review is useful but is not independent assurance. Use
  independent review where useful; its activation criteria are not set here.

## Evidence and continuity

- Report what was observed, what you infer and why, and what remains not
  established. Name relevant checks actually run and disclose failures, gaps,
  stale evidence, and limitations. Do not imply unperformed tests, approvals,
  user validation, measurements, or readiness.
- Preserve meaningful decisions, stage outcomes, deviations, and verification
  evidence in proportion to the work. Keep current state concise: confirmed
  status, blockers, next action, and pointers to durable records when useful.
  Do not create records or process artifacts without a need.
