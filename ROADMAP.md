# Engineering Skillset Roadmap

The product vision and initial preset model are described in
[`VISION.md`](VISION.md). The revised v0.2 plan and current implementation
evidence are in [`docs/development/roadmap-v0.2.md`](docs/development/roadmap-v0.2.md).

V2-01 and V2-02 implementation evidence is preserved in Git history. V2-03
(`ess`) is implemented and committed, with owner acceptance still pending.
The v0.2.1 M02 local user installation is operator-accepted. M03 verification
and release preparation are complete in the worktree and await operator
review. See [`docs/development/release-v0.2.1.md`](docs/development/release-v0.2.1.md)
and the detailed roadmap.

The v0.1 roadmap is preserved at
[`docs/development/roadmap-v0.1.md`](docs/development/roadmap-v0.1.md). The
`v0.1.0-experimental` tag and its evaluation records remain historical evidence.

## v0.3 — Skill-Based Model Delegation

Published v0.2.1 remains the compatibility baseline. The previously approved
M00/M01 declarative routing and orchestration design is superseded by this
instruction-based design; the original proposals remain in
[`docs/development/m00-v0.3-requirements.md`](docs/development/m00-v0.3-requirements.md)
and [`docs/development/m01-v0.3-architecture.md`](docs/development/m01-v0.3-architecture.md)
as historical records. v0.3 uses a concise optional source module compiled
into Core Policy/`AGENTS.md`, plus private, user-maintained Markdown model
configuration. Existing agents and OpenCode sessions provide execution
capabilities; the project adds no routing engine, runtime, or communication
infrastructure. The design remains modular, portable, minimally complex, and
preserves v0.2.1 behavior when delegation guidance is unused.

Implementation and verification sequence:

1. Record this architectural change and the verification strategy before
   implementation. Preserve the historical M00/M01 text and mark it
   superseded.
2. Add concise delegation principles as an optional policy source module and
   include it in compiled Core Policy outputs using the existing composer.
3. Document a private local Markdown configuration location and an example;
   keep endpoints, credentials, and private settings outside version control.
4. Verify module inclusion and omission/empty behavior at the composer
   boundary; build all four presets and confirm their Skills and QA policy
   remain intact.
5. Run the existing regression suite, inspect generated outputs and Git
   status, then update `current.md` with evidence and operator-review status.

Testing strategy: component checks cover composition and empty/omitted module
behavior; preset-build checks cover the generated integration and preservation
of existing QA/Skills; the existing `make check` suite provides system-level
regression evidence for CLI, install, and publication behavior. Checks remain
proportional to this documentation-and-composition change and add no test
framework or automation layer.

## M0.4 — Optional OpenCode delegation

Authorized scope: make delegation explicitly opt-in per project through
`ess delegation on|off|status`, reuse preset composition and the existing
installer ownership checks, and add one OpenCode Skill. Ordinary preset
installations omit delegation. Preserve v0.2.1/v0.3 state compatibility and
keep OpenCode optional. Do not add routing, adapters, or orchestration.

Status: implemented and verified in the current worktree; owner acceptance is
pending. Evidence and compatibility limitations are recorded in
[`docs/development/m04-optional-opencode-delegation.md`](docs/development/m04-optional-opencode-delegation.md).
Practical delegation evaluation beyond the bounded command smoke test is
separate from M0.4 and is not a claimed outcome.
