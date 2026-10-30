# Engineering Skillset — Development Roadmap

**Version:** 0.1\
**Date:** 2026-10-26\
**Status:** Proposed roadmap; milestone details are refined progressively\
**Project:** Engineering Skillset (initial target: OpenAI Codex)

## 1. Product goal

Create a portable, modular, configurable engineering methodology for AI-assisted software development. Its purpose is to improve correctness, scope discipline, readability, maintainability, verification honesty, and development continuity at proportionate cost.

The end user selects a project level, engineering priorities, and optional capabilities. A lightweight **Bash installer** obtains a specified version of the module sources into a temporary directory, composes the selected instructions and Skills, installs only required artifacts into a new or existing project, and cleans up temporary data safely.

**Composition model (agreed product requirement):**

`Core Policy + exactly one project-level module + zero or more priority modules + zero or more optional modules + selected reusable workflow Skills`

Policy modules affect standards, priorities, and depth of engineering work. Skills provide reusable task procedures. A module does not have to correspond to one Skill. The exact number and boundaries of Skills, composition format (fixed sections vs. slots), and repository layout remain open pending experiment.

The always-applicable Core Policy preserves scope, correctness, proportionate QA, compositional testing, truthful evidence, and continuity. No selected module may silently weaken those guarantees. Educational behavior is independent of project maturity; exact profile labels and their configuration semantics require validation.

## 2. Project rules

1. **Minimal useful increment:** Build only what is needed to test the current hypothesis. Do not implement all possible modules in advance.
2. **QA at meaningful transitions:** Review requirements/design when relevant; review implementation and scope before final verification; verify actual results; evaluate acceptance and record state. Small changes may combine stages.
3. **Evidence over claims:** Distinguish observed results, interpretation, and what is not established. Self-review is not independent assurance.
4. **Compositional testing:** Verify local component guarantees at component level and emergent interactions at higher levels; repeat critical guarantees only when the repeated check provides distinct evidence.
5. **Controlled scope:** Deferred improvements go to the backlog and do not become approved work automatically.
6. **Proportionate records:** Preserve meaningful decisions, stages, and verification evidence while keeping active context small. Git alone is not the complete rationale record.
7. **Measure value:** Compare behavior and outcomes against Codex baselines. Extra steps, interruptions, files, and tokens are costs to measure.
8. **Progressive planning:** Elaborate the current milestone; keep future milestones high-level until relevant evidence is available.

## 3. Milestone overview

| Milestone | Objective | Current status |
|---|---|---|
| **M00 — Engineering Foundation** | Principles, Core Policy, modular composition requirements, and evaluation plan | **Completed** |
| **M01 — Module Composition** | Validate a minimal composable set of policy modules | **Completed (verified supported scope)** |
| **M02 — Bash Installer** | Safe, repeatable local and remote installation and reconfiguration | **Completed (verified supported scope)** |
| **M03 — Workflow Skills** | Implement and verify the selected task workflows | **Completed (verified supported scope)** |
| **M04 — Evaluation & Qualification** | Evaluate modules and Skills against actual Codex behavior | **Completed for evaluation scope; behavioral effectiveness inconclusive** |
| **M05 — Experimental v1 Release** | Package, document, verify, and publish the experimental system | **Completed** |

**Status convention:** Planned / Next active / In progress / Blocked / Completed / Accepted. Completion requires evidence against milestone acceptance conditions; documentation deliverables alone do not establish behavioral effectiveness.

## 4. M00 — Engineering Foundation

**Goal:** Establish universal guarantees and a minimal, testable basis for module composition.

### M00.1 — Engineering Principles v1

**Status:** Completed.\
**Artifact:** `docs/requirements/engineering-principles-v1.md`\
**Reported commit:** `52cc28576acaf648eef3518729eea1bc7b9d27b5`

Seven principles were documented. Subsequent review clarified QA independence, final-verification ordering, and distinct higher-level testing evidence. Formal evaluation of the rules' practical effectiveness remains open.

### M00.2 — Core Policy

**Status:** Completed.\
**Artifact:** `AGENTS.md`\
**Commit:** `8655abdb0b3ba017bf662e9bced88a7ed0e7d8cf`

Core Policy expresses durable, actionable instructions without binding the project to an installer or fixed Skill count. Final wording clarifies that final review precedes reporting an authorized task complete, and that acceptance assessment is not user approval. Behavioral effectiveness remains untested.

**Exit:** Minimal diff reviewed, formatting checked, principle coverage confirmed, and committed. Behavioral effectiveness is not claimed.

### M00.3 — Module Composition Requirements

**Status:** Completed.\
**Artifact:** `docs/architecture/module-composition.md`\
**Commit:** `c758698730464c11ede20776ac807cd0f4f8b1dc`

The design defines Core / one level / zero or more priorities / zero or more optional modules, keeps Skills separate, specifies conflict handling and module-quality requirements, and includes three example compositions. It recommends fixed-order named sections while retaining named slots as an evaluated alternative. Composition produces a standalone effective policy; integrating with existing repository instructions belongs to the installer, whose reconciliation behavior remains open.

**Exit:** Examples, module responsibilities, conflict behavior, and structural acceptance criteria are documented without an implementation framework. The recommendation remains subject to M01 validation; behavioral effectiveness is not claimed.

### M00.4 — Minimal Evaluation Plan

**Status:** Completed.\
**Artifact:** `docs/development/evaluation-plan.md`\
**Commit:** `dce458a88122fe7d225fc573b9422c23a2ac70eb`

The plan defines baseline, Core-only, and composed comparisons; controlled conditions; independent criteria; hypothetical initial scenarios pending evidence of specific real-project incidents; and marginal-benefit review. Behavioral effectiveness has not been tested, and the final release policy remains open.

**Exit:** A lightweight evaluation methodology is committed. It does not predetermine results, pass thresholds, or the final release policy.

**M00 exit:** M00.1–M00.4 deliverables are committed and verified. The final release policy and other identified decisions remain open.

## 5. M01 — Module Composition

**Goal:** Validate predictable, comprehensible composition before building a full installer.

- **M01.1 — Minimal module contract:** Completed in commit `eefdab4`. Established readable Markdown modules, path-based identity, categories, fixed ordering, and minimal selection checks.
- **M01.2 — First policy modules:** Completed in commit `f297d32`. Added the `personal` level and `development-speed` priority alongside the existing `readability` priority.
- **M01.3 — Minimal policy composer:** Completed in commit `ef70236`. Added the local Bash composer, CLI, deterministic composition, and focused tests.
- **M01.4 — Sorting and structural verification:** Completed in commit `0cb548e`. Simplified stable C-locale sorting and verified Core preservation, ordering, duplicate sections, output publication, and cleanup.
- **M01.5 — Final integration review:** Completed in commit `5b4677d`. Fixed hidden sorter failures and added regression coverage proving failure is reported without publishing partial output.

**Acceptance:** Accepted for the verified supported scope: standalone compositions using the Core Policy, the `personal` level, and zero or more of the `readability` and `development-speed` priorities. Representative outputs were rendered and reviewed; automated checks cover deterministic ordering, Core preservation, invalid selections, duplicate sections, and output failure handling. This structural verification does not establish behavioral effectiveness.

**Limitations:** No optional modules are currently supplied, so successful optional-module composition is not demonstrated. No explicitly incompatible module pairs are defined; the composer does not implement pairwise incompatibility rules or semantic conflict detection. Only currently supported modules and selections were reviewed. Behavioral effectiveness remains untested and belongs to the evaluation milestone.

**M01 exit:** M01.1–M01.5 are committed and verified for the scope above. Installer behavior, remote downloads, Skills, optional-module examples, and behavioral qualification are not part of this acceptance.

## 6. M02 — Bash Installer

**Goal:** Implement safe delivery of tested configurations with no permanent setup clutter in target repositories.

**Status:** Completed for the verified supported scope.

- **M02.1 — Minimal local installer:** Completed in commit `dfe813a0cf5759e6a462e994c3e1e7a648eca177`. Added explicit selections, dry-run, composer reuse, and no-overwrite first installation.
- **M02.2 — Remote bootstrap:** Completed in commit `b93b640ca987bbc968d584e5e45fd91dd9b286fa`. Added pinned-revision archive download, caller-provided SHA-256 checking, archive path/type validation, extraction in temporary storage, and installer delegation.
- **M02.3 — Installation safety and idempotency:** Completed in commit `99292301baae323c8ac0d9f2a43a328493ab9f82`. Added ownership metadata, integrity checks, safe repeated installation, dry-run, and refusal of unmanaged or modified files.
- **M02.4 — Safe reconfiguration:** Completed in commit `5919d5ddef8603d3e5a2ddef467be7383057d357`. Added explicit `--reconfigure`, validated replacement staging and rollback, bootstrap forwarding, and reconfiguration tests.
- **M02.5 — Final integration review:** Completed in commit `a46ba85517e178c349827a0291a4b51ccd7bd5bd`. Rejected unsafe target paths in bootstrap, made cleanup failures return nonzero without masking an earlier status, expanded controlled archive integration coverage, and documented recovery steps.

**Acceptance:** Accepted for the verified supported scope. Controlled archive integration exercised bootstrap → installer → composer for initial installation, exact repeat, dry-run, authorized reconfiguration, policy equality, manifest updates, and preservation of user-owned files. Component and integration tests cover failure handling, malformed or modified managed state, target/archive path validation, and temporary cleanup. Shell syntax, ShellCheck, and whitespace checks passed. This evidence establishes tested structural and filesystem behavior for current supported selections; it does not establish behavioral effectiveness.

**Limitations:** Live GitHub download is **NOT ESTABLISHED**. Trusted SHA-256 digest provenance is **NOT ESTABLISHED**; the bootstrap checks a caller-provided digest but does not authenticate its provenance. Policy and manifest publication are separate filesystem operations and are not atomic as a pair. Successful optional-module paths remain untested because no optional modules are currently supported. Concurrent filesystem modifications were not qualified. Behavioral effectiveness remains unverified and belongs to M04. M02.5 received agent self-review and deterministic verification, not independent assurance.

**M02 exit:** M02.1–M02.5 are committed and verified for the supported scope above. M02 is complete; the listed limitations remain open.

## 7. M03 — Workflow Skills

**Goal:** Provide practical, reusable workflows for implementation review, verification, and project handover.

- **M03.1 — Skill contract and Implementation Review:** Completed in commit `46df7bb`. Added the minimal Skill contract and the first review workflow.
- **M03.2 — Implementation Review runtime verification:** Completed; a fresh Codex session discovered and invoked the Skill, and task trace showed the Skill instructions being read. No correction was needed, so no commit was necessary.
- **M03.3 — Verification & QA Skill:** Completed in commit `171caed`. Added hierarchical verification reasoning, assurance distinctions, and evidence reporting.
- **M03.4 — Verification & QA runtime verification:** Completed for the observed smoke-test scope. A fresh session invoked the Skill and produced correctly scoped findings and evidence categories. The trace did not expose Skill file-read events; no correction or commit was necessary.
- **M03.5 — Project Handover Skill:** Completed in commit `9b0a530`. Added the concise history, current-state, and backlog workflow.
- **M03.6 — Project Handover runtime verification:** Completed for the observed fixture scope. A fresh session invoked the Skill and preserved history, verified state, unresolved questions, deferred work, and authorization boundaries. Instruction loading was not observable in the task trace; no correction or commit was necessary.
- **M03.7 — Final Skills integration review:** Accepted for its verified supported scope. One controlled scenario exercised all three workflows in sequence; the review, failing integration check, and handover records were consistent. No correction was justified, so no commit was necessary.
- **M03.8 — Software Design Skill:** Completed in commit `db5c9d8`. Added a concise design workflow for new systems and changes to existing architectures, with proportionate design and implementation planning. The Skill was structurally validated, discovered natively, and explicitly invoked in two controlled read-only design scenarios; traces showed its instructions being read.

**Acceptance:** M03 is complete for the verified supported scope: the three Skills have valid structure, distinct responsibilities, and were exercised individually and together on controlled scenarios. The integration scenario preserved the concrete defect, the passing component check, the failing integration check, an unresolved design question, a deferred improvement, and the authorized next action. The proposed correction was not applied or claimed as verified.

**Limitations:** Only controlled scenarios were exercised. Skill instruction loading was not observable in every runtime test. No independent assurance was performed. Behavioral effectiveness relative to baseline Codex remains unverified and belongs to M04. These smoke tests do not establish general effectiveness or superiority.

**M03 exit:** M03.1–M03.7 are complete for the verified supported scope. Continue to preserve the distinction between policy modules and reusable workflow Skills.

**M03.8 extension:** The two controlled scenarios exercised a small CLI change and a larger webhook integration design. They support that the Skill can produce actionable, proportionate designs in those examples; they do not establish general behavioral effectiveness or superiority over baseline Codex. No independent assurance was performed.

## 8. M04 — Evaluation & Qualification

**Goal:** Establish whether Core, module composition, and Skills improve real engineering outcomes enough to justify their overhead.

Evaluate at least:

1. **Baseline:** Codex with ordinary existing project guidance.
2. **Core-only:** Codex with the common Core Policy, without added workflow Skills.
3. **Composed:** Codex with Core plus selected policy modules and candidate Skills.

For isolating Skill effects, keep underlying policy and authorization comparable between paired runs. Fix model/effort, repository snapshot, tools, permissions, and task acceptance criteria as closely as practical. Use independent, preferably deterministic outcome checks; use human review for subjective judgments. A small number of repeated runs is a smoke signal, not statistical proof.

- **M04.1 — Behavioral Evaluation Design:** Completed in commit `5f09a38`. Defined the three comparison configurations, controls, assessment criteria, validity limits, and a proposed manual pilot.
- **M04.2 — Evaluation Case Preparation:** Completed in commit `ea65489`. Prepared three frozen cases with agent-facing tasks, separate evaluator criteria, deterministic checks where practical, and recorded provenance.
- **M04.3 — Matched Pilot Comparison and Analysis:** Completed for the nine-run pilot and its provisional analysis. Evidence is recorded in `docs/development/evaluation-runs/m04.3/README.md` and `docs/development/evaluation-runs/m04.3-analysis.md` (pilot commit `8488a4f`; analysis commit `f83ef37`). One run per condition and case is not statistical evidence.
- **M04.4 — Targeted Repeats and Ablation:** Completed as an evaluation activity for its bounded scope. The four planned follow-up runs are recorded in `docs/development/evaluation-runs/m04.4-follow-up/README.md`; the Case 2 Core-only/Baseline pair produced identical accepted patches, while the Case 3 pair preserved the expected integration failure and handover boundary. An additional explicit Project Handover activation check is recorded in `docs/development/evaluation-runs/m04.5-skill-activation/README.md` (evidence commit `fe3cd06`). Metadata discovery was observed, but the Skill body read and invocation were not established; this is an unresolved result, not proof of value or experimental failure. The follow-up evidence, analysis, and closeout are in commits `fe83bf3`, `7737040`, and `7ff432c`. Component effectiveness remains inconclusive.
- **M04.5 — Final Evaluation Decisions:** Completed for the recorded evidence and evaluation scope. The prior self-reviewed assessment is preserved in `docs/development/evaluation-runs/m04.5-decision-review.md` (commit `7c141f8`); final provisional experimental-v1 decisions and release distinctions are in `docs/development/evaluation-runs/m04.5-final-decisions.md` (commit `6cb6b12`). The pilot, targeted follow-up, explicit Skill activation check, and one matched end-to-end comparison establish no general behavioral advantage over Baseline. Components are provisionally included for experimental inspection and trial; effectiveness remains inconclusive. No independent assurance was performed, and no further evaluation runs are planned for M04.

**Acceptance:** The planned pilot, bounded follow-up, activation check, and focused end-to-end comparison are recorded; no known critical acceptance failures were concealed; provisional experimental inclusion decisions and observed costs are documented without claiming efficacy or statistical significance. M04 is closed as an evaluation activity, not as proof of behavioral effectiveness.

## 9. M05 — Experimental v1 Release

**Goal:** Prepare a clearly labeled experimental distribution whose supported scope and limitations are explicit. Do not present it as a proven productivity improvement.

### M05.1 — Skills Packaging and Installation

**Status:** Accepted for the verified supported scope. **Commit:** `43f72a9c902f6ab4d3a5594d5c6490901afb2e97`.

The local installer now installs the composed policy and all four bundled Workflow Skills. Manifest v2 records policy and Skill digests; existing v1 policy-only manifests require explicit `--reconfigure` to add the Skills. Unmanaged collisions and modified managed Skills are refused, unrelated Skills are preserved, and repeated installs leave managed files unchanged. Bootstrap validates the four required Skill files before invoking the installer.

Composer, installer, and bootstrap tests, Bash syntax checks, ShellCheck, and `git diff --check` passed. A fresh-target `codex debug prompt-input` check listed all four installed Skill names, establishing discovery metadata in that runtime; Skill body loading and invocation were not established.

**Limitations:** Policy, Skills, and manifest publication is not atomic as a set; process interruption may leave inconsistent state. Concurrent filesystem modifications remain unqualified. Live GitHub download and trusted digest provenance remain **NOT ESTABLISHED**. Selective Skill removal and uninstall are unsupported; only the current `SKILL.md` files are managed. M05.1 does not establish behavioral effectiveness or independent assurance.

- Document purpose, supported platforms/agents, installation, profiles, priorities, options, reconfiguration, review of diffs, and uninstall limitations.
- Test installation and updates in clean and existing Git repositories, including collision and interrupted-operation scenarios.
- Verify packaging excludes development fixtures, unrelated modules, temporary downloads, and other nonessential files from target projects.
- Tag a release with its verified revision, known limitations, and reproducible checks.

**Acceptance:** A user can obtain and use the documented experimental configuration, inspect and safely change it within the verified supported scope, and understand what has and has not been tested. Any claimed remote-bootstrap or Skill-distribution path must be verified before it is described as supported; otherwise omit or clearly mark it unsupported.

### M05.2 — End-to-End Qualification

**Status:** Completed for the verified qualification scope.

A fresh disposable-project installation produced a policy matching the selected composition, and all four Skills were installed, discovered, and explicitly invoked in fresh Codex sessions. Instruction-body loading was confirmed, including controlled comparisons using disposable copies for `software-design`, `verification-qa`, and `project-handover`. Relevant design, review, QA, and handover behavior was observed. Identical repeat installation and safe reconfiguration passed; representative user-owned files remained unchanged.

**Limitations:** These scenarios do not establish general improvement over Baseline. User-owned file preservation was checked for representative cases, not every possible layout. The focused instruction-loading experiments used disposable Skill copies and do not modify the shipped Skills. M05.2 does not qualify live GitHub download, trusted digest provenance, atomic policy/manifest publication, concurrent modifications, or behavioral effectiveness.

**Exit:** Installation, composition, Skill discovery/invocation/loading, repeat installation, and reconfiguration were verified for the tested scope. The experimental v1 release was published as GitHub Release/tag `v0.1.0-experimental`, pointing to verified commit `954bf56e1ce33cfeda65fedd6cf92d3c7dcb8311`. The release tag resolves to that commit. M05 is complete for its documented experimental scope.

**Release limitations retained:** Behavioral effectiveness and improvement over Baseline remain unproven; no statistical conclusions or independent assurance are established. Live GitHub download and trusted digest provenance remain **NOT ESTABLISHED**. Policy, Skills, and manifest publication is not atomic as a set; concurrent filesystem modifications remain unqualified; user-owned file preservation was checked for representative cases only. Selective Skill removal and uninstall are unsupported. Successful optional-module paths remain untested. These are recorded limitations, not claims established by publication.

## 10. Agreed future direction

- **M06 — Dropped:** No implementation is planned.
- **M07 — Postponed:** Retained as a future direction but not scheduled or active.
- **M08 — Composed-policy duplication and context efficiency:** Completed. The largest supported composition is 833 words; overlap primarily serves distinct policy responsibilities. Estimated wording savings of 20–50 words had no demonstrated behavioral benefit, so policy and Skill wording remain unchanged. Actual Skill-loading overhead remains a separate runtime-observation question. Findings: `docs/development/evaluation-runs/m08-context-efficiency.md`.
- **M09 — Roadmap Optimization Skill:** M09.1 (design and evaluation) is the next planned work. M09.2 (controlled migration) remains separate and may follow only after the Skill has been evaluated.

No prior M06–M09 milestone definitions were present in this roadmap when these directions were recorded.

## 11. Cross-milestone checkpoints

At every meaningful milestone transition:

1. Review scope, design fit, maintainability, and unnecessary complexity.
2. Run the relevant available checks and record exact observed results; identify checks not run.
3. Compare results with acceptance criteria without inventing user approval.
4. Preserve meaningful decisions and stage outcomes, with commit/test references rather than copied logs.
5. Update concise active state and deferred backlog as appropriate.

The underlying record layout is still an open implementation decision. Avoid mandatory separate files per stage for small work.

## 12. Decisions retained and questions left open

**Retained:** central proportionate QA; compositional testing; honest evidence; authoritative scope; readable code and KISS/YAGNI; meaningful stage history and compact current context; configurable level/priorities/options; modular assembly; Bash installer; safe updates; evaluation against baseline.

**Open:** exact project-level taxonomy; profile and priority semantics; module section/slot format; conflicts beyond enforceable static rules; number of Skills; activation and independent-review thresholds; record formats; installer flags and metadata details; statistically meaningful Skill acceptance policy. These must be resolved through bounded design and tests rather than speculative framework-building.

## 13. Immediate next actions

1. M08 is complete. Next planned work is M09.1: Roadmap Optimization Skill design and evaluation. M09.2 is a separate controlled migration, contingent on evaluation. M06 is dropped and M07 postponed.
2. Preserve the distinction between policy modules and reusable workflow Skills.
3. Do not treat M01 structural, M02 installation, M05 qualification, or release publication as evidence of behavioral effectiveness. M04 evaluation is complete, but effectiveness remains unproven.

**Roadmap change rule:** This document may be updated as evidence arrives. Preserve important decisions and explicitly revise future milestones when learning warrants it; do not expand approved scope silently.
