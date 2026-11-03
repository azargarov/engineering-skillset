# Current State

- **Release:** v0.3.0 is the current stable release; its implementation and
  scope are owner-accepted. The v0.2.1 compatibility baseline is preserved.
- **Capabilities:** Four presets, published distribution and user
  installation, project install/switch/status/uninstall, optional per-project
  OpenCode delegation, and advisory provider/model preferences are verified.
- **Delegation evidence:** The accepted Codex/OpenCode experiment integrated
  OpenAI and DeepSeek models successfully and passed its recorded checks. It
  establishes functional integration, not comparative effectiveness.
- **M0.6:** Skill hardening is implemented, deterministically verified, and
  owner-accepted. Closeout `make check` and `git diff --check` passed (exit 0);
  earlier `make build`, generated-output
  inspection for all four presets, workflow inspection, and `git diff --check`
  passed. Activation evidence does not establish Skill loading or compliance.
  See [`docs/development/m06-skill-hardening.md`](docs/development/m06-skill-hardening.md).
- **Next action:** Stop for operator review after M0.6 closeout. Do not begin
  M0.7 until separately authorized. v0.3.0 remains the immutable comparison
  baseline. Local LLM context-window investigation is deferred. See
  [`ROADMAP.md`](ROADMAP.md) and
  [`docs/development/evaluation-plan.md`](docs/development/evaluation-plan.md).

No evidence establishes improvements in development speed, code quality,
cost, or reliability over baseline Codex. Do not begin v0.4 implementation
without a separately defined and authorized scope.
