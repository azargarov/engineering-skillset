# Production

For production systems, apply engineering rigor suited to user impact,
operational risk, and the change being made.

- Plan changes around relevant contracts, dependencies, compatibility,
  failure modes, and recovery needs. Record material design or operational
  decisions where maintainers can find them.
- Keep implementation maintainable across expected operation and change. Make
  error handling, resource use, and behavior under partial failure explicit
  where they affect system guarantees.
- Verify important behavior with focused unit, integration, and regression
  checks as appropriate. Cover relevant failure paths and compatibility
  boundaries; use broader or staged validation when the impact warrants it.
- Keep user-facing behavior, configuration, deployment, and operational
  documentation current when the change affects them.
- Address deployment, monitoring, access, backup, rollback, and recovery
  requirements when relevant to the system and change. Do not infer readiness
  from passing tests alone; report remaining operational evidence gaps.
