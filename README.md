# Engineering Skillset (ESS)

**Engineering Skillset (ESS) is a lightweight tool for configuring, installing,
and switching between sets of engineering Skills and policies for AI coding
agents.** It is currently Codex-first, with optional OpenCode delegation.

Different projects need different engineering practices. A quick prototype
and a reliability-focused project should not necessarily use identical
workflows. Maintaining agent instructions and Skills by hand across projects
is inconvenient. ESS provides reusable configurations that you can install
and switch as project requirements evolve.

## Quick start

ESS currently supports GNU/Linux and requires Bash, GNU Make, and Git, along
with common GNU command-line tools.

From a checkout of this repository:

```bash
make install-user
export PATH="$HOME/.local/bin:$PATH"
ess list
ess install prototype /path/to/your/project
ess status /path/to/your/project
```

The target project directory must already exist. Omit the path to install in
the current directory. To switch later, install another preset:

```bash
ess install reliable /path/to/your/project
```

ESS installs the project's `AGENTS.md` policy and links its Skills. The policy
is a copy; Skills link to the active user installation. See [installation
details](#installation-and-updates) for updates and uninstall behavior.

## Presets

Choose the engineering approach that fits the project or current work:

| Preset | Focus |
|---|---|
| `prototype` | Test a key assumption with the smallest adequate implementation and focused checks. |
| `fast-development` | Build useful, maintainable software quickly with simple design and checks for important behavior. |
| `performance` | Meet measurable performance goals through profiling, workload-based benchmarks, and resource checks. |
| `reliable` | Make correctness and failure behavior predictable with risk-based verification. |

Preset definitions are maintained in [`modules/levels/`](modules/levels/).
Switching presets guides subsequent agent work; it does not authorize
retroactive changes or weaken existing project requirements.

## How ESS works

1. Choose a preset for the project.
2. ESS composes its policy from the shared Core Policy, the selected preset,
   and configured shared or optional policy modules.
3. ESS installs the generated policy and links the preset's workflow Skills
   into the project.
4. The coding agent follows the installed instructions and can use relevant
   Skills during its work.
5. Install another preset when the project's needs change.

ESS keeps policies and Skills modular so shared guidance can be maintained
once, preset-specific guidance can vary, and optional behavior can stay out of
projects that do not need it. A deterministic build generates the distribution
from Markdown sources and preset definitions. The `ess` CLI installs built
artifacts; it does not compile source modules or run an agent.

Each preset includes the `software-design`, `implementation-review`,
`verification-qa`, and `project-handover` Skills. Skill names stay the same
across presets while relevant guidance varies. The generated project
`AGENTS.md` is self-contained; linked Skills come from the active ESS user
installation.

## CLI commands

Run `ess --help` for usage. The supported commands are:

```bash
ess list
ess install prototype
ess install reliable /path/to/your/project
ess status
ess delegation on
ess delegation off
ess uninstall
```

Project paths are optional for `install`, `status`, and `uninstall`; they
default to the current directory. `install` also accepts `--dry-run`.
`status` is the single diagnostic command and reports managed policy and Skill
state, delegation state, and OpenCode availability.

## Optional OpenCode delegation

Delegation is opt-in per project. Enable it with `ess delegation on` and turn
it off with `ess delegation off`. When enabled, ESS installs an additional
delegation policy and the `opencode-delegation` Skill. OpenCode is optional;
normal preset installations work without it.

The Skill describes bounded delegation to an OpenCode session using providers
and models already configured there. A private model-preferences file can list
advisory models by provider. Preferences are not an automated selector: the
agent checks availability and suitability, may choose another model, and
reports its choice. See the [model preferences guide](docs/development/model-preferences.md)
and [delegation implementation and evidence](docs/development/m04-optional-opencode-delegation.md).

## Architecture and documentation

ESS has a small set of Markdown policy modules, four declarative presets,
reusable workflow Skill sources, a deterministic Make-based distribution
build, and a CLI that installs generated files into user projects. The shared
Core Policy applies to every preset; optional modules, such as delegation, are
included only when enabled. This keeps common guarantees consistent while
letting projects select only the guidance they need.

For detailed design and behavior, see:

- [Project vision and boundaries](VISION.md)
- [Implemented architecture](docs/architecture/v0.2-architecture.md)
- [Module composition design proposal](docs/architecture/module-composition.md)
- [Module and Skill contracts](docs/architecture/module-contract.md) and [Skill contract](docs/architecture/skill-contract.md)
- [Roadmap and release status](ROADMAP.md)
- [Installation ownership and recovery](docs/development/installation-metadata.md)

## Project status

**Current stable release: v0.3.0.** Its verified capabilities include four
preset builds, published distribution and per-user installation, project
installation and switching, managed policy and Skill ownership checks,
optional per-project OpenCode delegation, and advisory model-preferences
configuration. The v0.3.0 release is implemented, verified, and accepted.

## Installation and updates

`make install-user` builds and installs an immutable release under
`${XDG_DATA_HOME:-$HOME/.local/share}/engineering-skillset/` and installs
`ess` at `~/.local/bin/ess`. Add that directory to `PATH` yourself; the
installer does not edit shell startup files. An unrelated existing `ess` file
is preserved and causes installation to stop.

Update the central checkout and install its newly built distribution:

```bash
git -C /path/to/engineering-skillset pull
make -C /path/to/engineering-skillset install-user
```

Linked Skills follow the active release. Since project `AGENTS.md` is copied,
reinstall the selected preset to refresh it. ESS does not fetch Git updates or
automatically clean up prior releases.

Remove ESS-managed project files with:

```bash
ess uninstall
```

Uninstall preserves unrelated project content and checks the recorded
ownership state before removing managed files. For interrupted installs and
other limitations, see [installation metadata and recovery](docs/development/installation-metadata.md).

## License

Apache License 2.0. See [`LICENSE`](LICENSE).
