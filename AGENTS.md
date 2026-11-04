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

For software development tasks, execute all four workflow Skills; do not skip
one because the task appears simple. Load each Skill progressively at its
stage, using the installed paths under `.agents/skills/`, and apply the active
preset's requirements:

1. Read `.agents/skills/software-design/SKILL.md` before planning, designing,
   or implementing.
2. Read `.agents/skills/implementation-review/SKILL.md` after implementation
   and before final verification.
3. Read `.agents/skills/verification-qa/SKILL.md` before selecting or
   executing final verification checks. Load it earlier if verification work
   is required during implementation.
4. Read `.agents/skills/project-handover/SKILL.md` before completing the task
   and reporting the result.

If a required Skill file is missing or unreadable, report that explicitly and
do not claim to have executed that Skill.

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

## Project memory

For meaningful development and when resuming project work, use the project's
memory records to preserve intent, scope, decisions, progress, and evidence
across sessions:

- `VISION.md` is the authoritative project intent, requirements, and
  boundaries. Treat it as immutable during ordinary development. A proposed
  change requires explicit owner approval; never modify it silently. Consult
  it before substantial design changes.
- `ROADMAP.md` records the authorized milestone sequence, scope, and status.
  Keep it consistent with `VISION.md` and actual progress.
- `current.md` is a concise fresh-session summary of the active milestone,
  progress, blockers, and next action. Read it when present and update it when
  meaningful progress or blockers change. When establishing a new project,
  create a concise `current.md` from the authorized requirements and plan.
- `milestones/` preserves durable milestone results and verification evidence.
  Distinguish planned, implemented, verified, and owner-accepted status; never
  imply verification or owner acceptance that did not occur.
- `decisions/` records significant architectural or engineering decisions,
  rationale, and material trade-offs. Follow existing ADR conventions where
  appropriate; do not record trivial implementation details or create empty
  records.
- `errors/` records significant failures when investigation, resolution, or
  an unresolved issue will help future work. Avoid routine test output,
  temporary debugging logs, and empty records.

At session start or resumption, read `VISION.md`, `ROADMAP.md`, and
`current.md` when present. Identify the next authorized incomplete milestone
from the roadmap or the user's explicit task. Work only within that approved
scope, preserve accepted decisions and project boundaries, and report missing
essential requirements rather than inventing them. If a required record is
absent, use established project conventions; do not silently replace or
restructure existing records.

During implementation, record significant decisions and substantial failures
when their rationale or findings will help future work. At the end of
meaningful milestone work, update the milestone record and roadmap with actual
status and evidence, preserve unresolved issues, and update `current.md` with
progress, blockers, and the next authorized action. Keep the records concise
and scale detail to the task and active project level. These updates are part
of normal development and do not depend on a handover request. Mark work
owner-accepted only after explicit owner acceptance.
