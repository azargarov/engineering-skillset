# Engineering Skillset v0.2 — Modular Presets Roadmap

**Status:** Revised plan for owner review; no future implementation authorized
**Product intent:** [`../../VISION.md`](../../VISION.md)
**Baseline:** Preserve the released `v0.1.0-experimental` history and evaluation
evidence.

This roadmap aligns the v0.2 work with task strategies assembled from explicit
source modules. It records earlier implementation evidence separately from
owner acceptance. Later work proceeds only after owner review and authorization.

## Product and architecture direction

The initial presets are `prototype`, `fast-development`, `performance`, and
`reliable`.
Each preset is a small declarative selection of Markdown modules. Modules may
represent shared rules or a workflow variant. The initial modular workflow
experiment is `verification-qa`, with selections for `prototype` and
`reliable`; the other two presets can initially reuse existing guidance until
evidence justifies additional variants.

Make orchestrates deterministic compilation into stable per-preset
directories. A compiled Skill is a standalone `SKILL.md`; shared Core Policy
is supplied once as portable project `AGENTS.md`, not copied wholesale into
every Skill. Workflow Skill names stay stable across presets while their
content may differ. `ess` installs or switches built presets and links compiled
Skills from a central Git checkout; it does not compile source modules. Preset
switches govern subsequent work while preserving existing project contracts
and operational requirements. Git manages source versions and updates. Keep
configuration and lifecycle behavior simple, and retain existing components
where they fit the clarified product.

## Recorded work

### V2-01 — Build Personal preset

**Implementation evidence:** committed as `3d46bed`; Personal build and
structural checks were added. The original stage scope and evidence are
preserved in Git history. This work is a foundation and may be adapted as the
modular configuration evolves.

### V2-02 — Add Prototype and Production presets

**Implementation evidence:** committed as `cea6aaa`; prototype, personal, and
production preset definitions and build outputs were added. Existing evidence
and the historical `personal` and `production` configurations are retained;
they are not aliases for the four initial product presets.

### V2-03 — Implement minimal `ess`

**Implementation evidence:** committed as `9f3fcd0`; the CLI implements
`list`, `install`, `status`, and dry-run installation behavior against the
current `dist/` structure, with focused tests in `tests/ess.sh`.
**Acceptance:** owner review remains pending. The implementation is not marked
accepted or complete for release; review whether its contracts fit the revised
output structure before extending it.

## Proposed remaining work

### V2-04 — Define declarative modular presets and first workflow experiment

- Define the minimal configuration format and explicit module file selections
  for the four initial presets.
- Establish how shared Core Policy is emitted once in portable project policy
  while compiled Skills remain independently usable.
- Implement modular `verification-qa` variants initially for `prototype` and
  `reliable`; preserve the stated strategy differences and shared guarantees.
- Define explicit selections for the new presets while preserving the
  historical `personal` and `production` configurations and their evidence.

**Exit evidence:** configuration is understandable and explicit; the first
two QA variants compose deterministically; review before broadening the
compiler.

### V2-05 — Validate and extend modular compilation

- Validate generated Skills for standalone use and valid Skill structure.
- Verify shared Core Policy guarantees remain available to all presets.
- Review substantive differences between prototype and reliable QA guidance.
- Extend modular compilation to other workflows only where a demonstrated
  strategy difference warrants a variant.

**Exit evidence:** structural checks and focused comparisons support the
intended distinctions; no claim of behavioral effectiveness without suitable
evaluation.

### V2-06 — Align build, `ess`, and publication behavior

- Adapt Make targets and stable output directories to the final configuration
  and generated layout.
- Adapt `ess` to install and switch the four presets, linking centrally
  maintained compiled Skills while writing portable, self-contained project
  `AGENTS.md`.
- Qualify preset switching and the behavior of linked Skills after a central
  rebuild or update, including build publication and failure behavior.
- Keep update actions explicit and preserve safe handling of user-owned files.

**Exit evidence:** builds and switching work against the agreed layout;
publication behavior and limitations are documented and checked in disposable
projects.

### V2-07 — Simplify, document, and prepare experimental release

- Identify obsolete installation machinery after the new route is qualified;
  simplify only the agreed current surface while preserving v0.1 history.
- Update user and development documentation to describe the supported
  workflow and limitations.
- Review the release diff and evidence, then prepare an experimental v0.2
  release for owner review.
- Do not alter the v0.1 release tag or historical evaluation records.

**Exit evidence:** release contents, build, installation route, and known
limitations are reviewable. Publishing and tag creation require separate
authorization.

## Scope boundaries

No stage calls for a general package manager, custom templating language,
dependency resolver, automatic code refactoring, whole-project level
migration, or exhaustive tests unrelated to actual risks. Do not work in the
M09.2 experimental archive as part of this roadmap. Avoid adding lifecycle
machinery without demonstrated value.

## Open owner decisions before implementation

1. What final stable output directory convention should `ess` link into, and
   what publication guarantee is required during rebuilds?
2. After V2-03 review, which managed installation and collision contracts
   remain acceptable for the new output structure?
3. Which obsolete installation machinery should be simplified after the new
   route is qualified, while retaining its historical record?
