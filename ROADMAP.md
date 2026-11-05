# Engineering Skillset Roadmap

The product vision and initial preset model are described in
[`VISION.md`](VISION.md). The revised v0.2 plan and current implementation
evidence are in [`docs/development/roadmap-v0.2.md`](docs/development/roadmap-v0.2.md).

V2-01 and V2-02 implementation evidence is preserved in Git history. V2-03
(`ess`) is implemented and committed.
The v0.2.1 M02 local user installation is operator-accepted. M03 verification
and release preparation are complete in the worktree and await operator
review. See [`docs/development/release-v0.2.1.md`](docs/development/release-v0.2.1.md)
and the detailed roadmap.

The v0.1 roadmap is preserved at
[`docs/development/roadmap-v0.1.md`](docs/development/roadmap-v0.1.md). The
`v0.1.0-experimental` tag remains a historical release record.

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
`ess delegation on|off` with `ess status` as the diagnostic command, reuse
preset composition and the existing installer ownership checks, and add one
OpenCode Skill. Ordinary preset
installations omit delegation. Preserve v0.2.1/v0.3 state compatibility and
keep OpenCode optional. Do not add routing, adapters, or orchestration.

Status: implemented, verified, and owner-accepted for v0.3.0. The optional
delegation workflow and its compatibility limitations are documented in
[`docs/development/m04-optional-opencode-delegation.md`](docs/development/m04-optional-opencode-delegation.md).

Follow-up: the practical installation test found that `ess delegation status`
duplicated `ess status`. The redundant subcommand was removed; state format and
installed project files are unchanged. Regression verification is recorded in
[`docs/development/m04-optional-opencode-delegation.md`](docs/development/m04-optional-opencode-delegation.md).

## M0.5 — Provider-based model preferences

Authorized scope: extend the private Markdown preferences with advisory
provider/model lists; use responsibility-based filenames; publish a starter
template; preserve fallback from the deprecated user config name; have the
OpenCode Delegation Skill verify candidates against `opencode models`, choose
by task suitability without global provider ordering or allowlist behavior,
and report its selected model and reason. Preserve delegation toggles, preset
QA requirements, and existing installs.

Status: implemented, verified, and owner-accepted for v0.3.0.
`make check` passed, including all four delegated preset builds, preference
guidance, publication, user release installation, and CLI lifecycle checks.
The check validates instructions and packaging; actual model choice remains
agent judgment and is not an automated runtime selector. Model-selection
guidance is in
[`docs/development/model-preferences.md`](docs/development/model-preferences.md).

## v0.3.0 release closeout

Current stable release: **v0.3.0**.

Owner acceptance: the current ESS v0.3 implementation and release scope are
accepted. The closeout commit and `v0.3.0` tag record this acceptance. The
release includes four presets, published distribution and user installation,
optional OpenCode delegation, and advisory model-preferences configuration.
Acceptance covers the implemented release scope.

## v0.4 — Skill hardening

M0.6 strengthened verification evidence, defect reproduction, handover guidance,
and delegation result reporting while preserving the modular Skill architecture
and proportional QA. The accepted implementation and deterministic checks are
recorded in [`docs/development/m06-skill-hardening.md`](docs/development/m06-skill-hardening.md).

## M0.12 — Mandatory staged workflow Skill activation

Authorized scope: add a concise mandatory four-Skill execution contract to
Core Policy, preserve progressive stage loading and active-preset depth,
update generated artifacts and build checks for all presets, and document the
contract. This establishes instructions and structural packaging checks. Runtime Skill
file reads are not part of the product contract or automated checks.

Status: implemented and locally verified with `make build`, `make check`,
generated-artifact inspection, and `git diff --check`. The Core Policy also
requires verification, following `verification-qa` before planning or executing
verification, inspecting required check results, and reporting blocked
requirements as unverified unless a suitable alternative is completed. The
preset structural check asserts this contract while retaining staged Skill
activation. Owner acceptance is pending.

## M0.13 — Behavioral verification and QA handover contracts

**Status:** Implemented and deterministically verified. Owner review is
pending.

**Authorized scope:** Strengthen the existing `verification-qa` and
`project-handover` source Skills, update directly affected structural tests,
and preserve the four presets, staged activation, and current build/install
architecture.

**Acceptance:** Reliable requires executed automated tests for applicable
behavioral risks; other presets retain proportional verification. Handover
reports QA status, commands and results, verified guarantees, omitted or
failed checks, and remaining gaps. Generated Skills in all presets reflect
their sources and activation behavior remains unchanged.

**Verification:** `make build`, `make check`, and `git diff --check` passed.
Generated Skill content was checked against the source for every preset;
existing install and activation lifecycle checks passed. These checks
establish contract composition and packaging, not runtime compliance or
behavioral effectiveness of agents using the Skills.

**Reliable preset experiment — Inventory API (instruction adherence):** The
experiment account reports independent discovery of the four installed Skills.
It records an initial discovery failure followed by successful discovery via
symbolic links; the original cause is unknown. The account also reports that
`software-design` was read and a step-by-step implementation plan prepared,
then implementation proceeded after operator approval. Automated behavioral
tests were created for idempotency, concurrency, persistence, and HTTP
behavior. Go tests, the race detector, `vet`, build, and formatting checks were
reported successful, with final QA reported as **PASS**. These execution and QA
results are Codex-reported and were not independently reproduced for this
documentation update. The account identifies discovery of four Skills and
reading `software-design`; activation of the other three workflow Skills is
unverified. No cause for the initial discovery failure was established. This
records instruction adherence only and does not assess application code
quality.
