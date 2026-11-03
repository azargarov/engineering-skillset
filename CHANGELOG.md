# Changelog

## v0.3.0 — Accepted release

- Added optional, skill-based OpenCode delegation with per-project opt-in.
- Added advisory provider/model preferences and initialized the private
  preferences file from the published template during user installation.
- Verified the four presets, published distribution, installation workflow,
  optional delegation, and model-preferences configuration behavior.
- Accepted the HTTP API delegation experiment as functional evidence: separate
  delegated models completed store and HTTP handler components and their tests;
  Codex reviewed and integrated the results. Both delegations and final tests,
  race detector, vet, build, and HTTP smoke checks passed.

No claim is made that delegation is faster, cheaper, or more reliable than
Codex working alone. Comparative effectiveness remains unverified. See the
evaluation plan for deferred questions and known limitations.

## v0.2.1 — Release candidate, unpublished

- Added per-user installation with `make install-user`, using
  `~/.local/bin/ess` and `${XDG_DATA_HOME:-$HOME/.local/share}`.
- Published complete read-only releases and switched the stable `current`
  symlink atomically. Existing project Skill links continue to resolve after
  updates and source-checkout relocation.
- Rejects a corrupted active-release path that points through a symlinked
  release directory.
- Kept the installed and checkout CLI on the same `scripts/ess`
  implementation.
- Documented manual uninstall/reinstall for v0.2.0 project installations.
- Added automated and disposable end-to-end installation verification.

No automatic Git updates, release cleanup, or v0.2.0 migration command is
included. See [release qualification](docs/development/release-v0.2.1.md) for
verification evidence and remaining limitations.
