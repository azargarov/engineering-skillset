# Behavioral Evaluation Protocol

**Status:** M04.1 experimental design; no evaluation runs performed

## Purpose and limits

Compare ordinary Codex work with Core Policy and with a selected full
Engineering Skillset composition. The protocol is a small manual experiment,
not an evaluation framework or release policy. It tests outcomes on selected
tasks; it cannot establish general improvement from a small number of runs.

This design follows the [evaluation plan](evaluation-plan.md), Core Policy,
and Engineering Principles. Structural checks establish that the tested
instructions are present and the runs are comparable; only observed agent
work and independent assessment can support behavioral conclusions.

## Configurations

Use the same original project instructions in every condition. Add only the
specified Engineering Skillset material:

| Condition | Instructions available |
|---|---|
| **A — Baseline** | Original project instructions. No Engineering Skillset policy modules or Skills. |
| **B — Core-only** | The same original instructions plus `AGENTS.md` Core Policy. No additional modules or Skills. |
| **C — Full** | The same original instructions and Core Policy, the `personal` level, `readability` and `development-speed` priorities, and the three implemented Workflow Skills. No optional modules are currently available. |

Freeze the C composition and its file revisions before running tasks. Make
the three Skills available in C for every task; predeclare which Skills should
apply to each task so that both useful activation and unnecessary activation
can be assessed. Record whether each Skill was discovered, loaded, and used
when those events are observable. Do not add an invocation hint to only one
configuration or change selection after seeing a result.

The baseline must contain the target project's original guidance, without
Engineering Skillset Core or overlapping managed instructions. Preserve that
guidance byte-for-byte in B and C. If a snapshot already contains Core or
overlapping Skillset content, select another snapshot or mark the comparison
confounded; do not silently remove instructions to manufacture a baseline.

## Candidate task set

Start with three independent tasks, one small task per configuration per
scenario (nine runs for the initial pilot):

| Scenario | Task shape and evidence | Expected Skill use in C |
|---|---|---|
| **Routine, low-risk change** | A small documentation or similarly bounded change with clear acceptance and an existing focused check. Tests whether the full instructions add avoidable planning, tools, files, or review work. It should not require a workflow Skill. | None expected; record any activation or added process. |
| **Cross-component behavior** | A bounded behavior change with component-level checks and an integration contract or failure mode. Ask for implementation and review of the resulting change; define acceptance tests independently before runs. | Implementation Review and Verification & QA expected. Project Handover only if continuity is part of the task. |
| **Partial-work handover** | A realistic state containing confirmed progress, a failed or unrun check, an unresolved question, a deferred item, and a next authorized action. Assess whether another fresh session can resume accurately. | Project Handover expected; Verification & QA when assessing check evidence. |

These are candidate shapes, not claims about historical failures. The current
evaluation plan records no substantiated SpeechPlatform or Infera Codex
incident. Before using a real project as evidence-based, verify and cite its
issue, commit, review, test, or milestone record. Otherwise label the task as
hypothetical or use a controlled regression fixture. Do not reuse the same
fixture as both training context and a claimed hold-out case.

Before any run, write the task's authorized scope, visible acceptance
conditions, independently run checks, and evaluator-only assertions. Keep
hidden assertions and reviewer notes out of the agent's context. Use exactly
the same task text in A, B, and C.

## Controls and run procedure

1. Select a repository snapshot and task. Record its revision and initial
   tracked and untracked changes. Prepare separate clean copies for A, B, and
   C; no run may see another run's conversation, patch, or result.
2. Freeze task text, acceptance checks, original project instructions, and
   Skillset files. Record revisions or hashes where practical. Confirm that
   only the assigned Engineering Skillset material differs between
   conditions.
3. Keep model/runtime version, reasoning effort, tool versions and access,
   network and permissions, dependencies, starting context/history, and time
   or context limits the same. Record unavailable settings, including random
   seed when not exposed. Rotate run order where practical.
4. Run each condition in a fresh, isolated Codex session. Do not carry context
   or changes between sessions. Do not expose hidden evaluator checks.
5. Apply the same deterministic acceptance checks to each resulting patch
   and capture commands, complete results, changed paths, and final claims.
   Record failed setup or environmental deviations; retain unfavorable runs
   and explain any result excluded from direct comparison.

If an instruction, tool, runtime, repository state, or task differs materially,
mark the comparison confounded. Repair setup and rerun where practical, or
report the limitation; do not treat unlike runs as a controlled comparison.

## Assessment criteria and evidence

Keep findings separate by criterion. Do not use one aggregate score that lets
style or speed offset correctness, scope, or false-evidence failures.

| Criterion | Evidence to collect |
|---|---|
| **Correctness** | Independently defined acceptance checks and observed behavior. Preserve each pass and failure; a component pass does not establish an integration guarantee. |
| **Authorized scope** | Changed paths and diff against task boundaries; record unrelated edits, unrequested actions, and justified scope changes separately. |
| **Simplicity and complexity** | Note added dependencies, abstractions, code paths, files, and process artifacts. An independent reviewer judges whether material additions were justified, citing examples. |
| **Readability and maintainability** | Independent review of changed code against local conventions, clarity, contracts, and likely maintenance needs. Do not treat personal style preferences as defects. |
| **Verification quality** | Compare checks run with relevant guarantees and architectural level. Component checks establish local behavior; integration checks target interactions and emergent properties. Repeat a critical check at a higher level only for distinct evidence against another failure mode. |
| **Evidence honesty** | Compare reported commands, results, approvals, and limitations with captured output and artifacts. Preserve failures and claims that remain unverified. |
| **Continuity and handover** | For the handover task, provide a fresh assessor only the records normally available. Check whether confirmed state, decisions, failed/unrun checks, deferred work, and next authorized action can be identified without treating backlog as approval. |
| **Execution cost** | Record elapsed time, token usage when exposed, tool/command calls, approval requests, changed files, and extra records. Mark unavailable metrics; do not estimate them as observations. |

Run deterministic checks before subjective assessment. Use at least one
reviewer who did not author the tested patch or Skillset instruction for the
subjective criteria. Hide condition labels and randomize patch order when
practical; report when blinding was not maintained or could be inferred.
Agent self-assessment and same-agent review are evidence of what the agent
reported or noticed, not independent assurance.

## Interpreting outcomes and decisions

The comparisons support distinct, limited interpretations:

- **B vs. A** estimates the effect of adding Core Policy to the same project
  guidance for the tested tasks.
- **C vs. B** estimates the effect of the selected level, priorities, and
  Skills as a bundle. It does not identify which component caused an outcome.
- **C vs. A** compares the tested full composition with baseline; it does not
  isolate Core or any one module or Skill.

Do not claim an improvement from the agent's own final assessment. Tie every
claim to checks, artifacts, or independent reviewer findings. Treat critical
correctness, scope, or false-evidence failures as such; do not offset them
with lower cost or better style.

A comparison is usable only when its inputs and observed outputs are recorded
well enough to assess the controls. Mark confounded or incomplete comparisons
explicitly. With one run per condition, describe results as a pilot signal,
not as a stable effect. Repeat matched runs when results vary, are surprising,
or a retention decision depends on a small apparent advantage. Small samples
do not justify significance, causal certainty, or broad transfer claims.

Treat a task comparison as incomplete if a condition lacks its patch, relevant
check results, or required independent assessment. A setup failure invalidates
the affected comparison; preserve its record and rerun where practical instead
of counting it as an outcome. A pilot supports only a task-specific
recommendation when the evidence shows an identifiable benefit or cost;
otherwise leave the finding inconclusive. It does not determine release.
Critical correctness, scope, or false-evidence failures cannot be offset by
other gains.

**Threats to validity:** The small task set may not represent ordinary
engineering work; controlled or hypothetical cases may behave differently
from real project tasks. Codex runs may vary even with matched settings, and a
random seed may be unavailable. Reviewers may infer the configuration despite
blinding. Skill discovery or loading may not be observable, and a bundled C
result cannot identify which module or Skill caused an effect. Record these
limits; do not generalize beyond the evidence.

For an individual module or Skill decision, first identify a concrete outcome
that the component is intended to affect. If the bundle comparison warrants
more investigation, compare the same configuration with and without that one
component on a relevant task; use a negative activation task for a Skill when
selectivity is in question. Change no other instruction or environmental
condition. Do not attribute bundled outcomes to an individual component.

For each policy or Skill, record one owner decision with evidence and cost:

- **Retain** when it has an identifiable useful effect and no material
  regression makes its cost unjustified.
- **Simplify** or **merge** when useful guidance is obscured by repetition,
  overlap, or overhead.
- **Remove** when it adds no identifiable value, causes material regressions,
  or adds unjustified cost.
- **Inconclusive** when evidence is sparse, mixed, or confounded. Leave the
  decision open or gather targeted evidence.

These are qualitative decision rules, not numeric thresholds. The project
owner decides whether demonstrated benefit justifies complexity. This
protocol does not define a final release policy.

## Minimal execution plan after M04.1

The canonical roadmap has been reconciled to these five M04 stages. M04.1 is
this design; the remaining operational stages are:

1. **M04.2 — Select and freeze cases:** choose the three task instances,
   verify any claimed historical source, define acceptance and evaluator
   checks, and record exact A/B/C material and environment.
2. **M04.3 — Run the pilot comparison:** execute the nine isolated runs once
   each, apply the same checks, and record criterion-level findings and cost.
3. **M04.4 — Target uncertainty:** repeat only variable or decision-sensitive
   comparisons; use one-at-a-time module or Skill ablations where bundle
   results justify attribution, and check unnecessary activation.
4. **M04.5 — Assess and decide:** have the independent reviewer complete the
   subjective assessment, summarize run-level evidence and limitations, and
   present retain/simplify/merge/remove/inconclusive recommendations to the
   project owner. Do not infer a release decision from this pilot.

No evaluation runs are part of M04.1. The exact task repositories and
revisions, verified historical incidents (if any), reviewer availability,
model/runtime and metric availability, repeat count, roadmap label alignment,
and evidence required for a final release decision remain unresolved.
