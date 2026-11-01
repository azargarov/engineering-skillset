# Installation Metadata

`scripts/ess` manages a copied project policy, centrally linked Workflow
Skills, and one plain-text ownership state file:

- `AGENTS.md` is copied from the selected built preset.
- `.agents/skills/<skill-id>` links to
  `<skillset-checkout>/dist/<preset>/skills/<skill-id>`.
- `.engineering-skillset-state` records the preset, the SHA-256 digest of
  `AGENTS.md`, and the sorted Skill IDs managed by `ess`.

The current state format is:

```text
engineering-skillset-state-v1
preset=<preset-id>
policy_sha256=<SHA-256 of AGENTS.md>
skills=<comma-separated sorted skill IDs>
```

This state is an ownership and consistency record, not a signature or proof of
authorship. Before switching or updating, `ess` checks that the existing policy
matches its recorded digest and that every managed Skill path is still the
expected symlink. Modified policy files, replaced links, malformed state, and
unmanaged collisions are refused. Unrelated project files and Skills are
preserved.

## Uninstall safeguards

`ess uninstall [PATH]` removes the recorded managed Skill symlinks, the
verified `AGENTS.md`, and finally the ownership state. It uses the state file
and the same policy digest and literal link-target checks as installation.
Unlinking a Skill removes the link itself and never follows it; the central
checkout and `dist/` targets are not changed.

Before removing anything, uninstall validates every managed file that is still
present. A changed policy, a non-symlink at a managed Skill path, or a symlink
with a different target stops the operation before cleanup begins. A missing
policy or Skill link is treated as already removed, allowing a retry after a
partial uninstall while valid state remains. The ownership state is removed
last for that reason.

When the state file is absent, `ess` cannot establish ownership. It refuses if
`AGENTS.md` remains and otherwise reports a no-op, leaving any Skill paths
untouched. Malformed or unreadable state is also refused. The `.agents` and
`.agents/skills` directories are left in place: the installer does not record
whether those directories existed before installation, and they may contain
user data.

Installation and uninstall use multiple filesystem operations and are not
atomic as a set. State-last uninstall can resume after an interruption as long
as the state file remains valid. Concurrent modifications during either
operation are not qualified; do not edit managed paths while the command is
running. The state file is not cryptographically protected from deliberate
forgery by a user with write access to the project.

The central `dist/` outputs must exist for installation and for linked Skills
to work. `make clean` removes those outputs and breaks existing Skill links
until the next successful build. Moving the central checkout changes the link
targets; uninstall must be run before moving or removing that checkout because
it validates links against the current checkout path.
