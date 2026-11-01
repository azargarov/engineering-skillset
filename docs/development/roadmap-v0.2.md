# Engineering Skillset v0.2 — Modular Presets Roadmap

**Status:** Four-preset composition and V2-06 technical integration
qualification are complete. Stage 2A is operator-accepted. Stage 2B changes are
implemented and verified; operator acceptance and release preparation remain
pending. Behavioral effectiveness is not established.
**Product intent:** [`../../VISION.md`](../../VISION.md)
**Baseline:** Preserve the released `v0.1.0-experimental` history and evaluation
evidence.

This roadmap aligns the v0.2 work with task strategies assembled from explicit
source modules. It records implementation evidence separately from owner
acceptance. Further workflow extensions proceed only after owner review and
authorization.

## Product and architecture direction

The initial presets are `prototype`, `fast-development`, `performance`, and
`reliable`.
Each preset is a small declarative selection of Markdown modules. Modules may
represent shared rules or a workflow variant. The accepted first workflow
experiment is `verification-qa` for `prototype` and `reliable`. Complete
preset outputs now include all four strategies and the four existing workflow
Skill names. Historical `personal` and `production` implementations have been
removed from the active tree; their committed history and evaluation evidence
remain available through Git.

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
production preset definitions and build outputs were added. Their earlier
meaning and evidence are retained in Git history; these names are not aliases
for the four current product presets.

### V2-03 — Implement minimal `ess`

**Implementation evidence:** committed as `9f3fcd0`; the original CLI
implemented `list`, `install`, `status`, and dry-run installation behavior.
Stage 2B adds `uninstall` while reusing the existing state format and ownership
checks; focused lifecycle tests are in `tests/ess.sh`.
**Acceptance:** owner review remains pending. The implementation is not marked
accepted or complete for release; review whether its contracts fit the revised
output structure before extending it.

**Closeout recommendation (2026-10-31):** committed implementation and focused
tests cover the documented command surface, preset switching, dry-run,
ownership and SHA-256 refusal checks, idempotency, and managed-link status.
V2-06 disposable end-to-end qualification also exercised the revised preset
layout and central Skill links. This evidence supports technical closure of
V2-03 at its implemented scope, provided the owner accepts the documented
non-transactional multi-file installation limitation and central-checkout
dependency. Owner acceptance remains pending; this recommendation does not
mark the milestone accepted.

## Recorded implementation and release work

### V2-04 — Define declarative modular presets and validate workflow composition

**Implementation status:** `verification-qa` composition for all four presets
is implemented. The Prototype/Reliable pilot received an independent PASS
review and is accepted. Its review record, configuration limitations, and
remaining integration limits are documented in
[`verification-qa-modular-pilot.md`](verification-qa-modular-pilot.md).
The complete composition includes all four product presets and workflow
Skills. `implementation-review` and `project-handover` reuse their existing
standalone sources unchanged because their guidance does not need preset
variants. Generated Skill files respect the active umask. The complete
composition is implemented and covered by focused checks; its release review
remains subject to operator acceptance.

- Explicit ordered Markdown selections compose the four product presets.
- Shared Core Policy is emitted once in portable project policy; generated
  Skills remain standalone.
- Modular `verification-qa` and `software-design` content reflects the
  strategies; unchanged Skills are reused.
- Build outputs contain `AGENTS.md` and all four Workflow Skills for each
  supported preset. Historical `personal` and `production` implementations
  were retired from the active tree during Stage 2A.

**Exit evidence:** explicit selections build the four complete outputs
deterministically, retain shared Core Policy, and produce appropriate
strategy differences. Builds stage and validate outputs before publishing
files individually; successful rebuilds preserve directory Skill links.
Focused tests cover compile/validation failures and disposable linked projects.
Owner review is pending.

### V2-05 — Validate modular compilation

**Implementation status:** completed for the initial four-preset product.
Generated Skill structure and content distinctions are checked by
`tests/build-modular-skills.sh` and `tests/build-modular-presets.sh`.

No behavioral-effectiveness claim is made without suitable evaluation.

### V2-06 — Align build, `ess`, and publication behavior

**Current integration evidence:** `ess` installs only the four supported
preset names and expects a regular `AGENTS.md` plus
`skills/<name>/SKILL.md` directories. Stale output directories may remain in
`dist/` to avoid breaking existing links, but are not listed or installable.
Local build publication is validated through existing Skill links. Remote Git
updates remain unqualified; `make clean` intentionally removes published
outputs.

**End-to-end qualification (2026-10-31): PASS in a disposable checkout and
project.** Built all four product presets; installed Prototype; switched
through Fast Development, Performance, and Reliable; checked copied policy,
Skill links, managed state, status, and unrelated project data; and verified
repeat-install idempotency and refusal after local policy modification. A
source-module edit followed by rebuild appeared through the installed Skill
link while copied project policy remained unchanged. An invalid build
preserved published artifact hashes and left the installed project healthy.
The publication test also exercised partial per-file publication and
successful recovery. No integration defect was found.

This evidence qualifies integration behavior only. It does not show that an
agent discovers or invokes a Skill, follows a preset strategy, or produces
better outcomes. A separate design for controlled cross-model behavioral
evaluation is in
[`evaluation-plan.md`](evaluation-plan.md);
no OpenCode runs or model calls have been made.

**Known limits:** interruption during per-file publication can leave mixed
generations, and `make clean` removes targets of installed Skill links. Remote
Git update behavior is not implemented or qualified. Installation and
uninstall are multiple operations and not atomic as a set. This qualifies V2-06
integration behavior; it does not change pending owner acceptance recorded for
V2-03 or the complete four-preset composition.

**Owner decision:** automatic project-local `AGENTS.md` backups and archives
of compiled artifacts are excluded. Git remains the source history; Make
compiles artifacts; `ess` installs and switches presets using its existing
ownership state and policy digest checks.

Stage 2A limited listing and installation to the four supported names while
leaving stale output directories in place for existing Skill links. Stage 2B
adds guarded uninstall without changing the stable link layout. Automatic Git
updates remain outside the current scope. Existing policy ownership and digest
checks continue to protect user-modified project policy.

**Exit evidence:** builds and switching work against the agreed layout;
publication behavior and limitations are documented and checked in disposable
projects. The end-to-end qualification above provides integration evidence;
owner review remains necessary before treating the broader v0.2 plan as
accepted.

### V2-07 — Simplify, document, and prepare experimental release

**Stage 2A:** accepted by the operator. The active build and `ess` support only
the four product presets; superseded installer/bootstrap code and their
dedicated tests were removed. Project memory and historical evaluation
evidence were preserved.

**Stage 2B:** installer lifecycle, user documentation, architecture and
roadmap reconciliation, and root `current.md` are implemented and verified in
the current worktree. Operator acceptance remains pending.

- Review the proposed v0.2 cross-model behavioral evaluation plan; prepare
  task fixtures and run comparisons only after owner approval.
- Review the final release diff and evidence. Stage 2C release preparation,
  tagging, and publishing require separate authorization.
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

## Open release decisions

1. Accept the completed Stage 2B installer and documentation changes.
2. Decide separately whether to retain, archive, or remove untracked
   experimental evaluation material; it is not part of Stage 2A or Stage 2B.
3. Authorize Stage 2C release preparation only after reviewing the v0.2.0
   contents and remaining limitations.
