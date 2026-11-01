# Installation Metadata

`scripts/ess` manages a copied project policy, centrally linked Workflow
Skills, and one plain-text ownership state file:

- `AGENTS.md` is copied from the selected built preset.
- `.agents/skills/<skill-id>` links through
  `${XDG_DATA_HOME:-$HOME/.local/share}/engineering-skillset/current/<preset>/skills/<skill-id>`.
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
Unlinking a Skill removes the link itself and never follows it; installed
release targets are not changed.

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

## Recovering an interrupted first install

This procedure applies only to a first install with no previous valid
ownership state. Installation stages temporary policy and state files, then
publishes Skill links, publishes `AGENTS.md`, and writes the ownership state
last. If the command stops after publishing target paths but before the state
write, those paths remain without ownership metadata. The `EXIT` trap cleans
temporary files when it runs, but does not roll back paths already published.
With some Skill links present and no policy, install treats the links as
unmanaged collisions and refuses; uninstall leaves them because state is
absent. If `AGENTS.md` is present without state, both commands refuse to guess
ownership.

If no target path was published, rerun `ess install` normally. Otherwise,
first stop other writers and check that the ownership state is absent. The
current files alone cannot prove they came from `ess`: proceed only if you
know `AGENTS.md` and the relevant `.agents/skills/<skill>` paths were absent
before this first install. A matching policy or link target is supporting
evidence, not proof of ownership. If the prior contents are uncertain, leave
all paths untouched and request review.

For a confirmed empty starting project, identify the intended preset with
`ess list`. Compare any present `AGENTS.md` byte-for-byte with
`${XDG_DATA_HOME:-$HOME/.local/share}/engineering-skillset/current/<preset>/AGENTS.md`. For each
present Skill path, verify it is a symlink whose literal target is exactly
`${XDG_DATA_HOME:-$HOME/.local/share}/engineering-skillset/current/<preset>/skills/<skill>`, and verify
that target contains a readable `SKILL.md`. The policy and links must agree
on one preset. If any path differs, stop without changing it.

Move only the paths you positively verified into a new, private backup
directory outside the project. For example, after creating a destination that
does not already exist (and making sure `$HOME` is outside the project):

```bash
set -eu
project=/path/to/project
state="$project/.engineering-skillset-state"
if [[ -e $state || -L $state ]]; then
  printf '%s\n' 'ownership state exists; this procedure does not apply' >&2
  exit 1
fi
backup=$(mktemp -d "$HOME/ess-interrupted-install.XXXXXX") || exit 1
mkdir -- "$backup/skills"
# Run these only for paths that exist and passed the checks above.
mv -- "$project/AGENTS.md" "$backup/AGENTS.md"
mv -- "$project/.agents/skills/software-design" "$backup/skills/software-design"
```

Repeat the Skill-link move only for each confirmed link left by the interrupted
install. `mv` moves the link itself; it does not follow the Skill target. Do not
move or remove the `.agents` directories or unrelated Skills. Keep the backup,
then rerun `ess install <preset> <project>` and check `ess status <project>`.
Staging files named `.ess-policy.*`, `.ess-state.*`, or `.ess-link.*` are not
proof of ownership; do not remove them by name alone. They do not establish
ownership or prevent a new install.

Installation and uninstall use multiple filesystem operations and are not
atomic as a set. State-last uninstall can resume after an interruption as long
as the state file remains valid. Concurrent modifications during either
operation are not qualified; do not edit managed paths while the command is
running. The state file is not cryptographically protected from deliberate
forgery by a user with write access to the project.

The installed distribution under `${XDG_DATA_HOME:-$HOME/.local/share}/engineering-skillset/`
contains immutable releases and a stable `current` symlink. Updating publishes
a complete release and atomically changes `current`; project Skill links do not
need rewriting. Previous releases are retained. The checkout can be moved or
removed after installation. A new update requires a source checkout and build.

## v0.2.0 manual transition

There is no automatic migration command. Verify the old project installation
is healthy with the original checkout's `ess status`, then run its
`ess uninstall`. Install the selected preset with the globally installed CLI.
The uninstall removes the managed policy and Skill links while preserving
unrelated project files and Skills. If the old installation is damaged or a
managed file was modified, stop for manual review; do not bypass ownership
validation.
