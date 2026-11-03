# Current State

- **Project:** Engineering Skillset. Published v0.2.1 remains the compatibility
  baseline; accepted v0.3 delegation policy sources remain historical context.
- **Active milestone:** M0.5, provider-based model preferences. Implemented
  and verified in the worktree; owner acceptance is pending.
- **Behavior:** Four normal preset builds omit delegation. `ess delegation
  on|off` controls the setting through existing installer ownership and digest
  checks; `ess status` is the single diagnostic command. Delegation policy is
  `modules/optional/delegation-policy.md`; provider preferences use
  `model-preferences.md` with deprecated `model-delegation.md` fallback. State
  v2 remains compatible with v0.2.1/v0.3 inference.
- **Evidence:** `make build`, `make check`, Bash syntax validation,
  `git diff --check`, and a bounded local OpenCode run passed. The redundant
  `delegation status` command was removed after practical testing; follow-up
  `make check`, syntax, diff, CLI help, and direct command checks passed.
  M0.5 `make check` passed with preference-guidance assertions for all four
  presets. The template is published and installed with the user release; no
  runtime selector or config parser was added. See
  [`docs/development/model-preferences.md`](docs/development/model-preferences.md).

## Next action

Review the M0.5 worktree and evidence for owner acceptance. Model selection is
agent judgment; checks verify guidance, compatibility paths, and packaging,
not model quality or an automated selector.
