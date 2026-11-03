# M0.4 — Optional OpenCode Delegation

## Outcome

Implemented in the worktree; deterministic verification and one practical
local OpenCode smoke task passed. Owner acceptance is pending. This extends the
accepted v0.3 policy module with explicit per-project opt-in and one reusable
executor Skill; it adds no router, model adapter, or orchestration service.

## Architecture and local configuration decision

The Make build composes ordinary preset policies without delegation and also
packages a delegated policy plus the OpenCode Skill for each preset. `ess`
selects the requested artifacts through its existing install transaction,
policy digest, Skill symlink ownership, and state file. State v2 records the
delegation setting; v1 state remains readable. The CLI infers an old v0.3
installation as enabled from its verified policy content, and treats a
v0.2.1 policy without that section as disabled.

User model preferences remain private and are not included in policy builds.
Portable rules live in `modules/optional/delegation-policy.md`; invocation and
model selection belong to `.agents/skills/opencode-delegation/SKILL.md`. The
configuration template and compatibility paths are documented in
[`model-preferences.md`](model-preferences.md).

### Status command follow-up

Practical installation evaluation found that `ess delegation status` duplicated
`ess status`. The CLI now uses `ess status` as the single diagnostic command;
`ess delegation on|off` remains the opt-in control. This changes no installed
project files or state format, so existing installations remain compatible.

The follow-up passed `make check`, Bash syntax validation
(`bash -n scripts/ess scripts/*.sh tests/*.sh`), and `git diff --check`. A
temporary project accepted delegation on/off, and `ess status` reported the
delegation state, OpenCode availability, and managed delegation Skill state.
The removed `ess delegation status` action failed as expected. The CLI help
lists only `ess delegation on|off`.

## Verification evidence

- `make build` passed for all four presets. Default policies omit the optional
  module; delegated variants include it and package the reusable Skill.
- `make check` passed: composer, all preset/Skill builds, CLI installation and
  lifecycle tests, isolated user installation, and guarded publication tests.
- CLI coverage includes four presets, on/off/idempotence, preset preservation,
  standard and unrelated Skill preservation, delegated uninstall, modified
  policy refusal, v0.2.1 and v0.3 state upgrades, and status without OpenCode.
- `bash -n scripts/ess scripts/*.sh tests/*.sh` and `git diff --check` passed.
- Installed OpenCode and inspected `opencode models` and `opencode run --help`.
  A bounded task using a configured local model created only the requested
  file in a temporary directory; its content was checked. The command used
  `opencode run --model ... --dir ... --format json` without `--auto`.
- Implementation review was self-review, not independent review. No claims
  about general delegation quality or productivity were evaluated.

## Limitations

v1 has no explicit delegation field; v0.3 inference depends on the verified
policy containing the module's `# Model Delegation` heading. Existing modified
policy or managed Skill paths still stop upgrade rather than being overwritten.
The root local example is not read automatically by ESS; the Skill may consult
the documented private Markdown preferences file when it exists.
