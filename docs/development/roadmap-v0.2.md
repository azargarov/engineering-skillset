# Engineering Skillset v0.2 — Modular Source, Built Presets, `ess`

**Status:** Proposed v0.2 plan for owner review; stages authorized individually
**Baseline:** Preserve `v0.1.0-experimental` tag, evidence, and history
**Architecture decision:** Modules are editable sources; presets are built distributions; `ess` installs them.

## 1. Product goal

Keep the engineering methodology portable, modular, and practical, with minimal custom tooling. Use native Git, Make, Bash, filesystem operations, and symlinks. Do not add a package manager or runtime dependency resolver.

- **Module:** source Markdown defining Core, one maturity level, an independent engineering priority, or a reusable Skill component.
- **Preset:** named, built set of a self-contained `AGENTS.md` and selected standalone Skills.
- **Build:** `make build` produces deterministic, flat artifacts. Agents need not resolve source-module links when using a preset.
- **Install:** `ess` selects a built preset for the current directory by default, or an explicit target. It copies project `AGENTS.md` and symlinks selected Skill directories to a central checkout.
- **Source of updates:** one local Git checkout; `ess check` inspects the remote, `ess update` updates only on request and rebuilds presets.

The project `AGENTS.md` includes Core exactly once plus selected level and priorities. `~/.codex/AGENTS.md` is optional personal guidance, never required for the project's engineering guarantees. A selected Skill must be usable as a standalone `SKILL.md`, without runtime references to the source module structure. Don't copy all Core rules into every Skill.

**Important constraint:** Project-local links select which Skills a project exposes. Avoid simultaneously installing the same names globally, since Codex can discover both global and local copies. Symlinks pointing outside the project are local development artifacts and should generally be excluded from its Git commits. Built source and installer behavior must be documented for portable/collaborative projects.

## 2. Minimal interface

Proposed commands (not yet implemented):

```sh
make build                   # generate all declared presets
make check                   # validate build and links/structure
make clean                   # delete only build output

ess list                     # available presets and their composition
ess install personal         # default target: current working directory
ess install prototype /path/to/project
ess status                   # current directory by default
ess check                    # fetch remote metadata without modifying checkout
ess update                  # explicit fast-forward source update, then rebuild
```

Optional `--dry-run` on install; no interactive prompts in the initial version. `ess install` may replace only files/symlinks demonstrably managed by `ess`. Refuse an unmanaged existing `AGENTS.md`, real Skill directories, unexpected symlinks, or partially conflicting target. Report what is present before changes. Do not `rm -rf` arbitrary project files. Keep update and installation distinct; no implicit online access during install.

## 3. Source and output layout (proposed)

```text
engineering-skillset/
  Makefile
  README.md
  LICENSE
  src/
    core.md
    levels/{prototype,personal,production}.md
    priorities/{readability,development-speed}.md
    skills/{software-design,implementation-review,verification-qa,project-handover}/
  presets/{prototype,personal,production}.conf
  dist/                            # generated; never edit directly
    prototype/AGENTS.md
    prototype/skills/*/SKILL.md
    personal/AGENTS.md
    personal/skills/*/SKILL.md
    production/AGENTS.md
    production/skills/*/SKILL.md
  scripts/ess
  scripts/compose-policy.sh        # reuse existing composer where possible
  tests/
  ROADMAP.md
  docs/development/...
```

The paths are illustrative pending the first stage's design review. Avoid adding a separate Skill template engine unless existing independent Skills cannot be copied unchanged into `dist/`. Keep presets few; do not enumerate every combination of priorities. Existing `roadmap-optimization` stays experimental until its separate M09.2 qualification.

## 4. Invariants

1. Mandatory Core guarantees: correctness, authorized scope, proportional QA, compositional testing, truthful evidence, and development continuity.
2. Prototype/Personal/Production vary in engineering rigor, not truthfulness or basic correctness. Priorities remain independent source modules, even if the initial CLI exposes only three named presets.
3. Same inputs produce identical built files. No timestamps, runtime LLM calls, implicit downloads, or untracked templates during build.
4. Generated Skills are individually usable and retain valid Skill frontmatter. Build-time composition must not duplicate generic Core policy in each Skill.
5. Project policy is a regular portable file; selected Skills are links to central built artifacts. Document that broken links occur when the central checkout moves or is unavailable.
6. Before replacing existing managed installation, detect and report any local user changes; avoid silent data loss. Prefer a minimal explicit ownership convention over an elaborate manifest or hash-driven lifecycle system.
7. `ess` resolves its source checkout reliably when invoked via `~/.local/bin/ess` symlink. Respect `umask` and paths with spaces; report errors, avoid claiming atomic multi-file replacement.
8. `ess check` and `ess update` are explicit network operations, with update restricted to safe fast-forward behavior and refusal on dirty checkouts. No unattended updates.
9. Preserve the v0.1 public tag/history and experimental findings. Use a v0.2 branch; migrate existing v0.1 projects only after review, never automatically.
10. Keep `ess` thin; Git handles versions, Make handles builds, Markdown holds methodology.

## 5. Milestones

### V2-00 — Architecture reconciliation and plan approval

**Status:** Reconciled for V2-01; later stages remain subject to separate authorization.

- Confirm source/built distinction, preset naming, policy portability, symlink behavior, collision policy and central checkout path resolution.
- Inventory v0.1 components and decide retain/archive/remove after qualification.
- Agree on minimal command semantics and the managed-file replacement rule.
- Make this document the v0.2 detailed plan; link to it from root `ROADMAP.md` without duplicating full milestones.

**Exit:** The architecture decision is recorded in `docs/architecture/v0.2-architecture.md`; existing sources, Skills, composer, installer, and bootstrap are retained. No installer runtime changes are included in V2-01.

### V2-01 — Build one Personal preset

- Build from existing Core, Personal, Readability, Development Speed, and four current Skills.
- Use existing composer for policy; introduce Makefile and minimal preset definition as necessary.
- Prefer copying existing standalone Skills unchanged over inventing an include language.
- Verify deterministic output, self-contained `AGENTS.md`, valid Skill frontmatter and parity with current Personal composition.
- No installer changes yet.

**Exit:** `make build`/`make check` work for Personal; reproducible artifact comparison passes; review before proceeding.

### V2-02 — Prototype and Production presets

- Add minimal `prototype` and `production` level modules.
- Define three presets and explicitly select priorities and Skills for each.
- Build and review all three configurations; keep QA guarantees across levels.
- Test that preset artifacts do not depend on source Markdown at agent runtime.

**Exit:** Three verified, distinct, flat presets; no need to create every possible module combination.

### V2-03 — Implement minimal `ess`

- One Bash CLI in `scripts/ess`, made available with a symlink under `~/.local/bin/ess`.
- Support `list`, `install PRESET [PATH]`, `status [PATH]`, and `install --dry-run`.
- Current working directory is the default installation target; a specified path wins.
- Write `AGENTS.md` as a normal file, link only selected Skill directories to the central built preset.
- On preset switch, replace only known managed artifacts; preserve/refuse conflicts with user-owned files. Record enough to show active preset and avoid destructive guessing, without importing v0.1 ownership-manifest complexity.
- Test new installation, repeat, switch, target with spaces, invalid arguments, symlink resolution, collisions, permissions, and safe failure.

**Exit:** Minimal command supports a complete safe install and switch in disposable projects.

### V2-04 — Git updates, integration, and migration documentation

- Implement `ess check` using Git remote information, reporting available updates without changing the checkout or project.
- Implement `ess update` as an explicitly requested fast-forward checkout update followed by a validated rebuild; refuse dirty/conflicting states.
- Verify that symlinked built Skills update in two disposable projects. Confirm a project `AGENTS.md` stays unchanged until explicit reinstall, and document the resulting version difference.
- Reconcile v0.1-managed installations carefully; document non-destructive manual migration, no automatic cleanup.
- Qualify `ess` when run via `~/.local/bin/ess`; update README, supported environments, and test documentation.

**Exit:** Installed state and update status are truthful; integration and failure tests pass; migration behavior is documented.

### V2-05 — Simplify release surface and publish v0.2

- Retire obsolete per-project installer/bootstrap and associated current docs only after the new path passes; retain old behavior in v0.1 tag/history.
- Review scope, release diff, testing, published artifacts, and limitations.
- Publish a distinct experimental v0.2 tag and GitHub release; do not rewrite v0.1 tags.
- Update `ROADMAP.md` milestone status on verified release.

**Exit:** Reproducible v0.2 build and installation, independently verified release, honest evidence.

## 6. Deferred

- Generating every possible combination of levels and priorities.
- Automatic modification of user-authored `AGENTS.md` or user-owned Skills.
- Background auto-updates, GUI, own package registry, declarative dependency solver, multi-machine sync.
- Runtime effectiveness claims beyond recorded experiments.
- M09.2 roadmap Skill graduation and general automatic Skill activation research.

## 7. First Codex implementation assignment

V2-01 is authorized on the `v0.2-development` branch. Build and check the Personal preset, then stop for owner review. Do not implement `ess`, alter global user directories, remove v0.1 tooling, migrate projects, or change release tags in this stage.
