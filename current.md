# Current State

- **Project:** Engineering Skillset. Published v0.2.1 remains the compatibility
  baseline; accepted v0.3 delegation policy sources remain historical context.
- **Active milestone:** M0.4, optional OpenCode delegation. Implemented and
  verified in the worktree; owner acceptance is pending.
- **Behavior:** Four normal preset builds omit delegation. `ess delegation
  on|off|status` changes the project through existing installer ownership and
  digest checks. State v2 records the setting, and v1 installations upgrade
  safely with v0.2.1/v0.3 inference.
- **Evidence:** `make build`, `make check`, Bash syntax validation,
  `git diff --check`, and a bounded local OpenCode run passed. See
  [`docs/development/m04-optional-opencode-delegation.md`](docs/development/m04-optional-opencode-delegation.md).

## Next action

Review the M0.4 worktree and evidence for owner acceptance. The smoke task
establishes that the documented noninteractive OpenCode command works with
one configured local model; it does not evaluate broader delegation quality
or productivity.
