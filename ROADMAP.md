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
| **M01 — Module Composition** | Validate a minimal composable set of policy modules | **Next active (implementation not started)** |
| **M02 — Bash Installer** | Safe, repeatable local and remote installation and reconfiguration | Planned |
| **M03 — Engineering Skills** | Implement selected task workflows with QA integrated throughout | Planned |
| **M04 — Evaluation & Qualification** | Evaluate modules and Skills against actual Codex behavior | Planned |
| **M05 — Release v1.0** | Package, document, verify, and publish the usable system | Planned |

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

- **M01.1 — Module contract:** Define the simplest source format for policy modules; identify any metadata truly needed for selection and compatibility.
- **M01.2 — Composition prototype:** Exercise Core with representative level, priority, and optional modules. Suggested initial candidates: levels `personal` and `production`; priorities `readability` and `development-speed`; option `educational`. These are experimental candidates, not a locked product taxonomy.
- **M01.3 — Structural checks:** Check deterministic output for identical inputs, supported combinations, missing references, rendering defects, duplicate universal rules, and obvious policy conflicts.
- **M01.4 — Review:** Assess whether the selected priorities meaningfully influence the effective guidance without weakening Core. Compare fixed sections and slots only if both solve an observed need.

**Acceptance:** At least three distinct example configurations can be rendered and reviewed. The chosen format is minimal, auditable, and suitable for Codex. This milestone does not prove behavior improvement.

## 6. M02 — Bash Installer

**Goal:** Implement safe delivery of tested configurations with no permanent setup clutter in target repositories.

- **M02.1 — Local install:** Support a local source checkout, target directory, explicit arguments or interactive defaults, and a readable proposed-output preview.
- **M02.2 — Remote acquisition:** Retrieve a specified trusted release/revision into `mktemp` storage, validate the download as appropriate, and clean temporary data via controlled cleanup/traps. Do not make unreviewed `curl | bash` the recommended installation path.
- **M02.3 — Safe writes:** Provide `--dry-run`, identify existing files and ownership, avoid silent overwrites/deletes, use safe temporary writes, and report incomplete operations. Do not claim that individual atomic renames make a multi-file installation transactional.
- **M02.4 — Reconfiguration:** Recompose on repeated runs; preserve version/selection/managed-file hash metadata as needed; show diffs and stop on locally modified managed files rather than attempting a complex automatic merge.

**Acceptance:** Installation works in empty and existing repositories; repeated identical installs are safe; failure does not silently damage existing files; changing configuration is reviewable; only selected effective artifacts and minimal required metadata remain in the target. Bash is the chosen initial delivery mechanism; another runtime is not required unless a proven constraint demands it.

## 7. M03 — Engineering Skills

**Goal:** Add workflows when evaluations or concrete needs show they provide value beyond Core Policy.

Candidate workflows, subject to validation:

- **M03.1 — Plan:** Requirements, architecture, contracts, bounded planning, preliminary compositional test design, and proportionate pre-implementation QA.
- **M03.2 — Implement:** Authorized scope, idiomatic code, justified abstractions, error handling, and implementation/scope review.
- **M03.3 — Verify:** Relevant tests and evidence, test levels, truthful observed/interpreted/not-established reporting, and acceptance assessment.
- **M03.4 — Continuity assessment:** Test whether compact current state, stage history, and backlog work reliably through these instructions. Introduce a dedicated handover Skill only if useful evidence supports it.

**Acceptance:** Candidate workflows have distinct responsibilities, do not conflict with Core, do not impose undue ceremony on trivial changes, and can operate under more than one module configuration. Their behavioral quality is subsequently qualified in M04.

## 8. M04 — Evaluation & Qualification

**Goal:** Establish whether Core, module composition, and Skills improve real engineering outcomes enough to justify their overhead.

Evaluate at least:

1. **Baseline:** Codex with ordinary existing project guidance.
2. **Core-only:** Codex with the common Core Policy, without added workflow Skills.
3. **Composed:** Codex with Core plus selected policy modules and candidate Skills.

For isolating Skill effects, keep underlying policy and authorization comparable between paired runs. Fix model/effort, repository snapshot, tools, permissions, and task acceptance criteria as closely as practical. Use independent, preferably deterministic outcome checks; use human review for subjective judgments. A small number of repeated runs is a smoke signal, not statistical proof.

- **M04.1 — Cases:** Real observed failures where available; independent bug-fix, API/architecture, and cross-component scenarios; some hold-out cases.
- **M04.2 — Comparison:** Correctness, regressions, scope violations, unnecessary abstractions, truthful reporting, needless escalation, time/tokens, and artifact overhead.
- **M04.3 — Regression/composition:** Positive and negative Skill activation, combinations of policies, changed instructions, unexpected extra work, and instruction conflicts.
- **M04.4 — Acceptance:** Retain, simplify, combine, or remove each module/Skill based on results; report uncertainty and untested cases clearly.

**Acceptance:** Reproducible evaluation notes, no concealed critical failures, a justified release set, and an explicit account of limitations and overhead.

## 9. M05 — Release v1.0

**Goal:** Ship the smallest reliable usable system.

- Document purpose, supported platforms/agents, installation, profiles, priorities, options, reconfiguration, review of diffs, and uninstall limitations.
- Test installation and updates in clean and existing Git repositories, including collision and interrupted-operation scenarios.
- Verify packaging excludes development fixtures, unrelated modules, temporary downloads, and other nonessential files from target projects.
- Tag a release with its verified revision, known limitations, and reproducible checks.

**Acceptance:** A user can install an appropriate configuration, inspect and safely change it later, and understand what the methodology does and what has actually been tested.

## 10. Cross-milestone checkpoints

At every meaningful milestone transition:

1. Review scope, design fit, maintainability, and unnecessary complexity.
2. Run the relevant available checks and record exact observed results; identify checks not run.
3. Compare results with acceptance criteria without inventing user approval.
4. Preserve meaningful decisions and stage outcomes, with commit/test references rather than copied logs.
5. Update concise active state and deferred backlog as appropriate.

The underlying record layout is still an open implementation decision. Avoid mandatory separate files per stage for small work.

## 11. Decisions retained and questions left open

**Retained:** central proportionate QA; compositional testing; honest evidence; authoritative scope; readable code and KISS/YAGNI; meaningful stage history and compact current context; configurable level/priorities/options; modular assembly; Bash installer; safe updates; evaluation against baseline.

**Open:** exact project-level taxonomy; profile and priority semantics; module section/slot format; conflicts beyond enforceable static rules; number of Skills; activation and independent-review thresholds; record formats; installer flags and metadata details; statistically meaningful Skill acceptance policy. These must be resolved through bounded design and tests rather than speculative framework-building.

## 12. Immediate next actions

1. **M01 — Module Composition** is the next active milestone; implementation has not started.
2. Validate the fixed-section recommendation against representative configurations and named slots after M01 implementation is approved.
3. Keep the actual installer until composition proves useful and tractable.

**Roadmap change rule:** This document may be updated as evidence arrives. Preserve important decisions and explicitly revise future milestones when learning warrants it; do not expand approved scope silently.
