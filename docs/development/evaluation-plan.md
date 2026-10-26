# Engineering Skillset Evaluation Plan

**Status:** M00.4 design proposal; evaluation and final release policy remain open

## Purpose and boundary

Evaluate whether Engineering Skillset improves Codex engineering outcomes
enough to justify its added instructions, decisions, and operational cost. The
initial method is a small, controlled comparison using real repository
snapshots and independently assessable tasks. It is not an evaluation
framework, fixture suite, or release gate implementation.

Structural validity and behavioral effectiveness are separate claims:

- **Structural validation** checks that policy and Skill artifacts are
  complete, selected correctly, composed reproducibly, and consistent with
  Core Policy. These checks can often be deterministic.
- **Behavioral evaluation** checks what Codex does with those instructions and
  whether resulting work is better, unchanged, or worse. Valid documents and
  successful composition do not establish behavioral effectiveness.

Do not treat this plan, a few successful runs, or any one score as proof that
the Skillset works generally. The release policy and required evidence remain
for project-owner decision.

## Comparison configurations

Use the same target repository's ordinary instructions as the shared base in
all conditions. Change only the Engineering Skillset material being evaluated.

| Configuration | Instructions available |
|---|---|
| **Baseline** | Existing project instructions at the frozen repository snapshot; no added Engineering Skillset Core, policy modules, or workflow Skills. |
| **Core-only** | The same existing project instructions plus the Engineering Skillset Core Policy. No policy modules or workflow Skills. |
| **Composed** | The same existing project instructions plus Core Policy, the preselected project level, selected priorities and optional modules, and relevant workflow Skills. |

Record the exact material available and, for Skills, whether the agent selected
or read them. Choose Skills relevant to a scenario before runs begin. Do not
change that choice after seeing a result. If evaluating activation, include
both a task expected to activate the Skill and a plausible negative task where
it should not activate.

Do not remove or rewrite native project instructions to make conditions look
consistent. If the target already contains Engineering Skillset Core or
overlapping managed guidance, choose a different snapshot/repository or
document that the baseline is confounded. Existing instructions and their
conflicts are part of the observed context.

## Controlled comparison procedure

For each task, prepare independent working copies from the same frozen
repository revision and reset all copies to that state. Run each configuration
with the same task text, acceptance criteria, repository guidance, starting
history, environment, and available context, except for the assigned
Engineering Skillset material. Isolate runs so one agent's changes or
conversation cannot affect another.

Before running:

1. Select a task and state its authorized scope and acceptance criteria.
2. Write or identify deterministic checks and any subjective review questions.
   Keep hidden evaluator assertions and reviewer notes out of the agent's
   available context.
3. Record the three instruction configurations and selected modules/Skills.
4. Freeze the source revision, task prompt, tools, permissions, and runtime
   conditions described below.
5. Randomize or rotate condition order where practical to reduce order and
   operator effects.

For each run, record:

- repository revision and any initial local changes;
- exact user task and acceptance criteria;
- model identifier/version, agent/runtime version, reasoning effort, and
  sampling settings or seed when exposed;
- tool versions, environment, network availability, and permissions/approval
  behavior;
- project instructions and Skill/module content made available, with their
  revisions or hashes where practical;
- final patch, commands and results actually observed, relevant interaction
  events, and the evaluation findings.

Use identical model and runtime versions, tool access, permission settings,
network policy, dependencies, and time/context limits across matched
conditions. If a setting such as a random seed is unavailable, record that
fact; do not imply it was controlled. Keep the same non-Skillset context and
initial conversation. The intended treatment difference is the additional
policy or Skills, not a more detailed prompt or extra evaluator hints.

The project's existing test suite and acceptance checks may be run in every
condition. Use the same commands and environment. Do not expose evaluator-only
checks to the agent unless they would normally be available in the project.
Record deviations, unavailable tools, and failed setup; exclude no unfavorable
result without a documented reason.

## Initial scenario set

The requirements brief describes general risks such as scope expansion,
unnecessary abstractions, weak test design, inaccurate verification claims,
and lost session state. It names SpeechPlatform and its M06 records as
candidate source material, but the documents available here do not establish a
specific Codex failure, issue, or regression from that project. No Infera
evidence or project checkout is present. Therefore the scenarios below are
hypothetical evaluation candidates, not historical incidents.

Before calling a scenario evidence-based, inspect the cited project's issue,
commit, review, test, or milestone record and record the exact reference and
observed failure. Do not infer an incident from a general risk statement or
from the existence of a Skill or process document.

| Candidate | Scenario and evidence status | Main questions |
|---|---|---|
| **Bounded maintenance change** | Hypothetical, based on the brief's general scope and complexity risks. Choose a real, small bug or behavior change only after acceptance can be stated independently. | Does the result meet requirements? Does it stay within scope? Are abstractions, dependencies, and unrelated edits justified? Does the agent request approval only when needed? |
| **Cross-component behavior** | Hypothetical, based on the brief's stated risk that lower-level passes do not establish integration behavior. Select an existing flow with identifiable component contracts and one emergent outcome. | Are local guarantees checked at the right level? Does integration verification target the new interaction or failure mode without duplicating whole lower-level suites? Is behavior correct? |
| **Verification and handover** | Hypothetical, based on the brief's general risks of unsupported verification claims and lost session state. Use a task with relevant checks and a meaningful next step or handoff. | Do reported commands/results match observed logs? Are unrun checks and limitations explicit? When continuity is relevant, can a fresh session resume from the recorded decisions, status, blockers, and next action? |

These scenarios cover several criteria without requiring a large task library.
Prefer a small number of real tasks with clear, independent acceptance over
many synthetic prompts. Avoid adversarial wording that tests policy traps
rather than representative engineering work. A documented SpeechPlatform or
Infera incident may replace or ground a candidate after its evidence is
verified.

## Assessment criteria and evidence

Assess each run against the same task-specific rubric. Record evidence and
findings by criterion; do not combine critical failures with subjective
qualities in a single average score.

| Criterion | Deterministic evidence first | Selective independent review |
|---|---|---|
| Requirements satisfaction and correctness | Prewritten acceptance checks, relevant existing tests, reproducible commands, and inspection of changed behavior. | Review requirements that cannot be fully asserted, edge cases, and whether test results support the claimed outcome. |
| Scope compliance | Compare the patch with the authorized files/contracts and task boundaries; identify changed paths and unrelated diffs. | Decide whether a change is materially outside scope or justified by the task. |
| Unnecessary complexity | Note added dependencies, abstractions, files, and code paths; compare with the starting snapshot. | Judge whether each material addition is needed and whether a simpler adequate implementation exists. Cite examples. |
| Honest verification and evidence | Compare reported commands, results, and claims with captured command output and run logs. | Assess whether interpretations and limitations are represented accurately and clearly. |
| Appropriate QA and test design | Run the same relevant checks; inspect which behaviors and test levels are covered. | Assess whether tests target requirements, component guarantees, and emergent properties at suitable levels without needless duplication. |
| Escalation and process overhead | Count approval requests, pauses, tool calls, elapsed time, tokens when available, and added files/artifacts. | Judge whether an escalation was warranted by actual ambiguity, risk, scope, or required authorization; overhead is a cost, not automatically a failure. |
| Development continuity, when relevant | Start a fresh session with only the normal handoff/current state and check whether required records and links resolve. | Assess whether a new agent can identify confirmed status, decisions, blockers, limitations, and next action without loading irrelevant history. |

Tests and command logs establish only what they actually cover. A passing
lower-level suite does not establish integration correctness; self-review does
not count as independent assurance. Mark a criterion **not assessable** when
the task or available evidence cannot establish it.

### Independent assessment

Run deterministic checks before subjective review. Have a reviewer who did not
author the tested module or the candidate implementation assess code quality,
scope judgments, QA fit, and reporting clarity where those qualities are not
mechanically decidable. Where practical, hide the configuration label and
randomize patch order; reviewers may infer the condition, so record whether
blinding was maintained. Use a short shared rubric and require concrete
examples for subjective findings.

If no separate reviewer is available, label the assessment as self-review or
owner review, not independent assurance. Keep reviewer disagreement and
uncertainty visible; resolve factual disputes with deterministic evidence and
do not turn judgment into fabricated certainty.

## Repeated runs and interpretation

Codex behavior can vary between runs. Start with one matched run per
configuration for each selected scenario as a low-cost pilot. Repeat matched
runs when outcomes differ, a result is surprising, or a retention decision
depends on a small observed advantage. A few independent repetitions (for
example, two or three per condition when affordable) can reveal instability;
they are not a statistical pass threshold or proof of general superiority.

Keep run-level findings, not just a summary. Describe whether an outcome was
consistent, mixed, or isolated, and report failures as well as improvements.
Do not claim statistical significance, broad transferability, or causal
certainty from a small sample. Model/runtime changes, task differences, and
uncontrolled context are potential confounders. If practical, rerun all
conditions for a scenario after a material environment change rather than
comparing unlike runs.

Treat critical correctness, scope, and false-evidence findings separately;
they cannot be offset by lower overhead or better style. This plan defines no
numerical score, pass threshold, or final release rule.

## Measuring marginal benefit and module decisions

The three-way comparison estimates different effects:

- **Core-only vs. baseline:** evidence about adding Core Policy to the same
  project guidance.
- **Composed vs. Core-only:** evidence about the selected modules and Skills
  together, not about any one module in isolation.

To assess one module's marginal benefit, compare the current accepted base
configuration with the same configuration plus that module. Keep task,
snapshot, model, tools, and context fixed. For a Skill, include an appropriate
positive activation task and, when activation selectivity matters, a negative
task. Use leave-one-out comparisons for an established composition when
removing a module is easier to interpret than adding it. Do not attribute a
bundle's result to one component without a component-level comparison.

After reviewing outcomes and added cost, classify the module as:

- **Retain** when it provides identifiable, useful decisions or outcomes and
  no material regression makes its added cost unjustified.
- **Simplify** when a smaller part appears useful but other guidance adds
  repetition, confusion, or overhead.
- **Merge** when its useful guidance overlaps another module and a combined,
  clearer responsibility is easier to select and maintain.
- **Remove** when it adds no identifiable benefit, repeats existing guidance,
  causes material regression, or imposes cost without a defensible return.
- **Inconclusive** when evidence is too variable, confounded, or sparse to
  distinguish these choices. Gather targeted evidence or leave the decision
  open; do not label uncertainty as success.

These are review outcomes, not automatic thresholds. The project owner decides
whether demonstrated benefit justifies complexity and operational cost.

## Proportionate execution and record

For this personal open-source project, begin with the three scenario types
above, existing repository tests, compact run notes, and selective human
review. Do not build an evaluation platform, large benchmark corpus, scoring
dashboard, mandatory multi-reviewer process, or permanent test repository
before repeated use demonstrates a need.

Keep one concise record per evaluation batch with the task/source references,
configuration and environment details, actual checks/results, per-criterion
findings, overhead, limitations, and next decision. Store patches or logs only
when they are needed to reproduce or substantiate a finding; link to durable
revisions rather than copying them into reports. Evaluation artifacts should
not become installer payload by default.

## Alignment and unresolved decisions

This plan follows the seven Engineering Principles: it evaluates authorized
outcomes and scope; measures simplicity and justified complexity; tests
component and emergent behavior at appropriate levels; checks implementation
and verification evidence in order; distinguishes observations from
interpretation and unknowns; records decisions proportionately; and scales
evaluation effort to risk and project size.

It also follows the module-composition architecture: Core Policy is invariant;
level, priority, and optional-module roles remain distinct; workflow Skills
remain separate and reusable; composed instructions are treated as a standalone
effective policy; and structural validity is not confused with behavioral
effectiveness.

The following decisions remain open:

- Which exact SpeechPlatform or Infera cases have documented, reproducible
  Codex failures suitable for evaluation.
- Which tasks, repository revisions, and hidden acceptance checks form the
  first evaluation batch.
- What amount and type of independent human review is practical for routine
  updates.
- How priorities and project levels should affect task-specific evaluation
  expectations without weakening Core guarantees.
- How many repeated runs are worth their cost for a particular decision; the
  small-sample guidance above is not a release threshold.
- What evidence is sufficient for accepting, updating, or releasing the
  Skillset. The final release policy remains explicitly unresolved.
