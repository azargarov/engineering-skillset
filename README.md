# Engineering Skillset

Engineering Skillset provides a Core Policy and workflow Skills for AI coding
agents, with four presets for choosing the level of engineering process that
fits a task. The generated project `AGENTS.md` is self-contained. Workflow
Skills are linked to a central checkout so their content can be maintained in
one place.

The project is licensed under the Apache License, Version 2.0. See
[`LICENSE`](LICENSE).

## Requirements

The supported environment is GNU/Linux. Building and installing require Bash,
GNU Make, and common GNU/Linux command-line tools, including coreutils,
findutils, grep, awk, and diffutils (`cmp`). Keep these commands on `PATH`.
Use Git to update the central checkout. Other platforms have not been
qualified.

## Build and install

From a fresh checkout, build the presets first. The project directory must
already exist:

```bash
make build
./scripts/ess list
./scripts/ess install fast-development /path/to/your/project
./scripts/ess status /path/to/your/project
```

Omit the project path to install into the current directory. `ess` copies the
preset's `AGENTS.md` and creates links for its four Skills under
`.agents/skills/`.

## Choose a preset

| Preset | Intended use |
|---|---|
| `prototype` | Validate a hypothesis quickly; focus on essential logic and the happy path. |
| `fast-development` | Build maintainable software quickly with simple design and focused checks. |
| `performance` | Meet measurable performance goals using profiling and workload-based checks. |
| `reliable` | Prioritize clear contracts, failure behavior, and risk-driven verification. |

The older `personal` and `production` presets are retired. If an existing
installation uses either one, uninstall it from the same central checkout
before moving or removing that checkout.

Switch presets by installing another one into the same project:

```bash
./scripts/ess install reliable /path/to/your/project
```

The switch applies to subsequent work. It does not authorize retroactive
refactoring or weaken existing project requirements.

## Work with an AI coding agent

After installation, work in the project with your coding agent. The generated
`AGENTS.md` provides persistent project guidance. Invoke a workflow Skill by
name when useful, for example:

```text
$software-design

Review the architecture of this API and propose the smallest change needed to
support idempotent job submission. Do not edit files yet.
```

The four Skills are `software-design`, `implementation-review`,
`verification-qa`, and `project-handover`. Agents may use relevant Skills
contextually, but automatic activation is not guaranteed.

Check the installation at any time:

```bash
./scripts/ess status /path/to/your/project
```

`status` reports whether the policy digest and managed Skill links match the
installation state.

## Update an installation

Update the central checkout and rebuild its artifacts:

```bash
git -C /path/to/engineering-skillset pull
make -C /path/to/engineering-skillset build
```

Linked Skills use those central artifacts and reflect a successful rebuild.
The project `AGENTS.md` is a copy, so reinstall the selected preset to refresh
it:

```bash
/path/to/engineering-skillset/scripts/ess install fast-development /path/to/your/project
```

`ess` refuses to replace a project policy or Skill link that no longer matches
its recorded ownership state. Review and resolve such changes before
reinstalling. Git updates are performed explicitly by the user; `ess` does not
fetch or update the checkout.

## Uninstall

Remove the managed policy and Skill links while preserving unrelated project
content:

```bash
/path/to/engineering-skillset/scripts/ess uninstall /path/to/your/project
```

Uninstall requires a valid ownership state. It refuses if the managed policy or
a present managed Skill link has been modified or replaced. Missing managed
files are treated as already removed, so an interrupted uninstall can be
retried. If the ownership state is absent or malformed, `ess` will not guess
which files belong to it. Empty `.agents` directories are left in place because
their ownership is not recorded. Repeating uninstall after a successful
uninstall is safe.

## Project Memory Lifecycle

The Core Policy asks agents to preserve project intent, decisions, progress,
verification evidence, and unresolved work. For meaningful development, use
the project's `VISION.md`, `ROADMAP.md`, and `current.md` when present; record
milestone results, significant decisions, and important failures in the
project's established locations. Keep current state concise and truthful.
The `project-handover` Skill helps prepare that record when work is handed off.

## Symlinks and limitations

The generated `AGENTS.md` is portable, but Skill links point into this
checkout's `dist/<preset>/` directories. Keep the checkout and built artifacts
available while installed projects use those links. `make clean` removes the
artifacts and breaks the links until `make build` recreates them. Successful
builds publish files into stable directories; interruption during publication
can leave artifacts from mixed build generations.

Moving the central checkout also breaks existing links. Uninstall verifies
each link against the current checkout, so run it before moving or removing
that checkout.

Installation and uninstall perform several filesystem operations and are not
atomic as a set. Concurrent changes to project files during those operations
have not been qualified. Current evaluations do not establish a general
quality or productivity advantage over baseline coding agents.

## Development checks

Run the build and applicable release checks from the repository root:

```bash
make build
make check
bash -n scripts/ess scripts/*.sh tests/*.sh
```

The product sources and maintained verification scripts are in `modules/`,
`presets/`, `scripts/`, and `tests/`. See [`ROADMAP.md`](ROADMAP.md) for
project status and [`docs/architecture/`](docs/architecture/) for design
records.
