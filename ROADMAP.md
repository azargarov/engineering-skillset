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
`ess delegation on|off` with `ess status` as the diagnostic command, reuse
preset composition and the existing installer ownership checks, and add one
OpenCode Skill. Ordinary preset
installations omit delegation. Preserve v0.2.1/v0.3 state compatibility and
keep OpenCode optional. Do not add routing, adapters, or orchestration.

Status: implemented, verified, and owner-accepted for v0.3.0. The latest HTTP
API delegation experiment is accepted as functional evidence: `deepseek/deepseek-flash`
completed the store component and tests, `openai/gpt-6-luna` completed the HTTP
handler component and tests, and Codex reviewed and integrated the results.
Both delegations completed successfully; final tests, race detector, vet,
build, and HTTP smoke checks passed. This does not establish comparative
effectiveness versus Codex working alone. Evidence and compatibility
limitations are recorded in
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
agent judgment and is not an automated runtime selector. Local model context
windows remain an investigation backlog item; see the evaluation plan. See
[`docs/development/model-preferences.md`](docs/development/model-preferences.md).

## v0.3.0 release closeout

Current stable release: **v0.3.0**.

Owner acceptance: the current ESS v0.3 implementation and release scope are
accepted. The closeout commit and `v0.3.0` tag record this acceptance. The
release includes four presets, published distribution and user installation,
optional OpenCode delegation, and advisory model-preferences configuration.
Acceptance does not claim delegation is faster, cheaper, or more reliable than
Codex working alone. Comparative effectiveness and other evaluation questions
remain open in [`docs/development/evaluation-plan.md`](docs/development/evaluation-plan.md).

## Planned v0.4 — Skill hardening and evaluation

The v0.3.0 release remains the immutable comparison baseline. Its completed
milestones and acceptance records above are unchanged. The v0.4 work below is
planned, not implemented or behaviorally validated. This roadmap update
records the approved direction; implementation remains subject to operator
review after this planning stage.

The sequence separates deterministic contract and repository checks from
behavioral evaluation. Complete the bounded hardening work first, freeze its
artifacts, then run the controlled evaluation and interpret results without
converting structural compliance into an effectiveness claim.

### M0.6 — Skill hardening

**Status:** Implemented, deterministically verified, and owner-accepted. No
behavioral effectiveness claim is made. Evidence is recorded in
[`docs/development/m06-skill-hardening.md`](docs/development/m06-skill-hardening.md).

**Objective:** Make existing workflow requirements more enforceable, observable,
and auditable while preserving the modular Skill architecture, presets, and
proportional QA.

**Deliverables:**

- Strengthen `verification-qa` with a traceable evidence record for every
  claimed verified property: property/requirement, method, result, and evidence
  reference. For executed checks, retain the exact command, exit code, and
  relevant inspected output or artifact references. Require the method to fit
  the property, inspected results, and evidence that supports the claim;
  otherwise report `partially verified` or `unverified`. Match verification
  level to the property and risk, including integration-level evidence for
  integration properties. Include a concise table of common invalid
  conclusions. Avoid duplicating `implementation-review` responsibilities.
- Add a bounded red–green workflow for reproducible defects: establish and
  record the failing condition, apply the fix, rerun relevant verification,
  and record resolution evidence. Permit equivalent reproduction methods when
  automated tests are unsuitable. Do not require test-first development for
  every change; retain existing presets and proportional QA without weakening
  correctness requirements.
- Review `project-handover` metadata for provider-neutral wording (for example,
  “between agent sessions”) while retaining intentional Codex integration
  details.
- Strengthen optional `opencode-delegation` result reporting with a minimal
  structured return contract: completion status, changed files, commands,
  exit codes/outcomes, and blockers or unresolved issues. Support no-change,
  failed, and blocked results. Treat delegate self-reports as untrusted until
  the coordinator checks relevant results and independently verifies
  integration. Do not add a delegation framework.
- Consider moving lengthy examples or optional procedures to `references/`
  only where this measurably reduces instruction overhead; keep mandatory
  behavioral gates in the main Skill or Core Policy. Do not restructure the
  repository broadly.
- Run a small Skill observability experiment distinguishing selection,
  evidence of instruction loading, and compliance. A declaration or request
  alone proves neither loading nor compliance. Measure added instruction and
  token overhead; do not make activation announcements mandatory across Skills
  before evidence supports that choice.
- Add a minimal GitHub Actions workflow running `make check` on pushes and pull
  requests, limited to existing deterministic checks.

**Dependencies:** Existing v0.3.0 Skills, composition rules, and deterministic
`make check`; the evaluation plan's distinction between structural validity
and behavioral effectiveness.

**Deterministic acceptance criteria:** Relevant Skills and metadata express
these contracts without conflict or unnecessary duplication; references, if
introduced, preserve access to mandatory gates; the workflow runs only
`make check` for push and pull-request events; applicable repository checks
pass. Record exact checks and outcomes.

**Behavioral criteria:** Not a claim of effectiveness or a release gate for
Skill utility. Observability and overhead are experimental findings to be
assessed in M0.8.

**Exclusions:** New default Skills, presets, adapters, routing, universal
activation announcements, mandatory TDD, and generic frameworks. A dedicated
defect-diagnosis Skill remains a possible future experiment only if evidence
shows incremental benefit.

### M0.7 — v0.4 evaluation preparation

**Status:** Owner-accepted for one initial controlled pilot using procedural
filesystem separation; enforced filesystem isolation is optional for this
pilot. Preparation remains deterministically verified: reference passed all 11
requirement IDs; starting snapshot passed health and failed the 10
new-behavior IDs as expected. The accepted protocol requires a fresh
snapshot-only candidate workspace, evaluator separation, integrity checks,
contamination reporting, and runtime preflight. Authorization is limited to
one case-04 Codex-without-ESS baseline run. See the [M0.7 evidence
record](docs/development/evaluation-runs/m07-pilot/implementation-plan.md) and
[accepted protocol](docs/development/evaluation-runs/m07-pilot/protocol.md).
No candidate run or effectiveness finding is claimed by M0.7 closeout.

**Objective:** Extend the existing [evaluation plan](docs/development/evaluation-plan.md)
into a reproducible, bounded protocol before effectiveness runs begin.

**Deliverables:**

- Define matched conditions for Codex without ESS, Codex with ESS v0.3.0, and
  Codex with hardened ESS. Selected external Skills, especially relevant
  Superpowers workflows, may be optional comparison conditions; treat
  Superpowers and similar projects as sources of candidate mechanisms and
  experiments, not wholesale collections to import.
- Preselect identical task snapshots, task text, and independent acceptance
  checks; hold model/tool settings and other conditions constant where
  practicable. Record unavoidable differences and confounders.
- Specify traceable run evidence, controlled environment setup/teardown,
  failure cleanup, and recording of deviations and inconclusive results.
  Capture runtime, token usage, retries, and integration overhead where
  measurable.
- Assess whether repeated setup/teardown code across selected cases justifies
  a small reusable fixture lifecycle wrapper. Introduce one only if that
  repetition is demonstrated; do not build a generic evaluation framework.
- Separate findings for (1) functional correctness and defect resolution,
  (2) engineering quality and scope compliance, (3) verification quality,
  (4) accuracy of verification claims, (5) Skill selection, activation, and
  behavioral compliance, and (6) runtime and operational overhead. Preserve
  observed evidence, interpretation, and unverified claims as distinct.
  Critical failures remain visible and are never averaged away.
- Predefine selected external mechanisms to investigate: systematic
  debugging, verification-before-completion, focused red–green defect
  workflows, behavioral counterexamples, progressive disclosure through
  `references/`, and activation observability. Do not treat stars,
  testimonials, or undocumented benchmark claims as effectiveness evidence.

**Dependencies:** M0.6 artifacts frozen for comparison; existing evaluation
cases, acceptance documents, and evaluation plan.

**Acceptance criteria:** The protocol identifies frozen inputs, conditions,
acceptance checks, evidence capture, environment lifecycle, analysis categories,
and deviation handling before runs. It makes clear that increased activation
announcements or documentation volume alone are not engineering outcomes.
The initial run set and any external comparison Skills are selected before
observing results.

**Exclusions:** Generic benchmarking platform, broad model comparisons,
weighted aggregate effectiveness scores, automated context-window management,
and importing `brainstorming`, `writing-plans`, or general-purpose TDD Skills
into default ESS composition.

### M0.8 — Controlled v0.4 evaluation and decision

**Status:** Complete and owner-accepted. Original A1 and the first replacement launch remain preserved as
historical stopped attempts. Following owner authorization for a local-only
initial Git commit, the fresh A1 replacement completed and the owner accepts it
as a pilot observation: Condition A used the four catalog-visible bundled
Codex Skills baseline, and all 11 final functional acceptance requirements
passed. The first A1 evaluator invocation exposed global-hook interference
with three candidate-authored parallel tests; the per-service adapter passed
all requirements and candidate tests without changing candidate code or frozen
assertions. Both invocations and the deviation remain preserved in the
[A1 report](docs/development/evaluation-runs/m08-pilot/A1-candidate-20261103/report.md).

The corrected `case04-corrected-evaluator-v1` is frozen with evaluator
manifest SHA-256
`627ff3b67ca78351086dda3eaae1e703706c2296eed847d02f39cfe616d99a7f`.
Calibration passed: reference 11/11; the original snapshot had its 10 expected
functional failures while `REG-01` passed; A1 compatibility passed 11/11 and
the candidate-authored parallel tests passed. See the [evaluator validation
record](docs/development/evaluation-runs/m08-pilot/evaluator-validation-20261103/report.md)
and [frozen artifacts](docs/development/evaluation-runs/m08-pilot/evaluator-v1/README.md).
At the owner's direction, evaluator v2 now evaluates implementations as
ordinary HTTP services without candidate-specific source adapters. The
finalized v2.1 uses a versioned task contract and deterministic fixture
observations. Two repeated calibration blocks passed all 11 checks on the
reference and sealed A1; the original snapshot had its ten expected behavior
failures and REG-01 passed. RETRY-01 exhaustion and RETRY-02 numeric/date
Retry-After caps, fallbacks, and sequences are observed at the provider
boundary. See the [v2.1 validation record](docs/development/evaluation-runs/m08-pilot/evaluator-validation-v2-final-20261103/report.md).
Evaluator v1 and its A1 result remain historical. The A1 candidate manifest
now excludes mutable `.git` bookkeeping while retaining the root commit ID,
source hashes, and patch hash. Following the operator's explicit authorization, A2 and A3 completed sequentially under the same
versioned v2 task and v2.1 evaluator; both passed all 11 checks with full
coverage. Resource use, interventions, implementation outcomes, cleanup, hashes,
and A1 task-clarification comparability are recorded in the
[matched pilot report](docs/development/evaluation-runs/m08-pilot/comparative-pilot-A2-A3-20261104.md)
and individual run artifacts. The owner accepts A2/A3 as successful Condition
A baseline observations; this does not accept M0.8 as a whole. The evaluator
and candidates remain frozen. M0.8
Condition B then completed three fresh original-v0.3.0 `reliable` runs under
the frozen v2 task and v2.1 evaluator; B1–B3 each passed all 11 requirements
with full coverage. B3 enumerated paths outside its workspace and is marked
protocol-contaminated, so B1/B2 are the only clean B comparison observations.
Candidate traces, Skills observations, resources, patches, integrity, and
cleanup are recorded in the
[Condition B report](docs/development/evaluation-runs/m08-pilot/condition-B-reliable-20261104.md)
and per-run artifacts. B preflight reported inconsistent plugin Skill catalog
visibility, which limits strict comparison with A2/A3 and is documented in the
report. The owner then approved a catalog-variability amendment for the
exploratory hardened ESS condition. C1–C3 completed from fresh snapshot-only
workspaces using the frozen M0.6 hardened reliable policy, four ESS Skills,
and unchanged v2 task/evaluator/runtime configuration. All three passed 11/11
with full coverage. C1's trace records a candidate-created smoke script under
`/tmp`; no disqualifying material access was evidenced. Catalog variability
remains a comparison limitation and no causal effect is claimed. The six-
dimension A/B/C analysis and per-run evidence are in the
[Condition C report](docs/development/evaluation-runs/m08-pilot/condition-C-hardened-reliable-20261104.md).
The owner accepts the completed Sol evaluation phase and Condition C. The
final six-dimension synthesis, acceptance record, and retained limitations are
in the [Sol closeout](docs/development/evaluation-runs/m08-pilot/sol-evaluation-closeout-20261104.md).
The historical run records and frozen artifacts remain unchanged. No
Condition D, delegation, external-Skill, or Luna comparison was started.

**Objective:** Execute the prepared comparisons and make evidence-bounded
recommendations about the hardened Skills and evaluation scope.

**Deliverables:**

- Run the preselected cases under the frozen conditions, preserving per-run
  patches, commands/results, logs or artifacts needed to substantiate claims,
  and measured operational overhead where available.
- Evaluate all six M0.7 dimensions separately. Use independent acceptance
  checks; conduct independent review where practical and identify self-review
  accurately where it is not.
- Record failures, setup problems, cleanup outcomes, deviations, mixed or
  inconclusive results, and limitations. Do not exclude unfavorable runs
  without a documented reason or infer broad effectiveness from a small sample.
- Make explicit recommendations to retain, simplify, revise, defer, or
  investigate further. Any dedicated defect-diagnosis Skill remains a future
  experiment contingent on evidence of incremental benefit.

**Dependencies:** M0.7 protocol accepted and M0.6 artifacts frozen.

**Deterministic completion checks:** Each planned run has traceable inputs,
conditions, acceptance results, command outcomes, and deviation/cleanup
records; deterministic checks are run and reported; analysis distinguishes
observations from interpretation and unverified claims. These checks establish
that the evaluation was conducted and recorded, not that ESS is effective.

**Behavioral effectiveness criteria:** Report outcome-by-outcome evidence and
critical failures without an aggregate score. Any claim is bounded to the
observed tasks, configurations, environment, and repeat count. No positive
threshold or release conclusion is predeclared by this roadmap; unresolved or
inconclusive evidence remains visible for operator decision.

**Exclusions:** Implementation changes beyond approved hardening, broad claims
of superiority, weighted aggregate scoring, and a generic benchmark suite.

### M0.9 — GPT-6 Luna comparison

**Status:** Planned; owner-approved to plan only. No Luna coding runs are
authorized yet. The [experimental plan](docs/development/evaluation-runs/m09-luna/plan.md)
freezes the comparison conditions, procedure, evidence, limits, and
interpretation criteria before any run. Its model identifier was checked
against the installed Codex CLI catalog on 2026-11-04: `gpt-6-luna`, with
`high` reasoning supported.

**Research question:** Does hardened ESS improve GPT-6 Luna's correctness,
engineering quality, verification behavior, claim accuracy, reliability, or
operational efficiency?

**Conditions:** L-A is GPT-6 Luna without ESS (3 runs); L-C is GPT-6 Luna with
the frozen M0.6 hardened reliable policy (3 runs). Both use the same model,
high reasoning effort, runtime permissions, task, evaluator, and tool settings.
Original ESS v0.3.0, delegation, and additional cases are excluded.

**Controls and acceptance:** Reuse case-04 task v2, evaluator
`case04-http-evaluator-v2.1`, deterministic provider fixture, fresh candidate
workspace procedure, existing acceptance requirements, and six-dimensional
methodology. Verify frozen input hashes and record each run's effective Skill
catalog; use the same bundled-Skill baseline where practicable. Preserve all
runs and deviations, make no post-evaluation repairs or assertion changes, and
do not interpret this six-run pilot as statistically conclusive. Recheck model
availability and exact identifier before launch. No ESS Skill/preset,
baseline, task, evaluator, infrastructure, or case changes are in scope.

**Resource requirement:** Six independent Luna coding sessions, each with a
fresh workspace and full per-run evidence capture; separate Skill-catalog
diagnostics as needed. Token quota and monetary cost are not guaranteed by this
plan and must be recorded as available or unavailable during execution.

### External Skills and deferred questions

Superpowers (`obra/superpowers`) and similar agent-skill projects are candidate
sources for selective mechanisms and optional experimental comparison. Do not
adopt whole Skill collections or add default `brainstorming`,
`writing-plans`, or general-purpose TDD Skills. Keep a dedicated
defect-diagnosis Skill as a possible later experiment, not current scope.
External popularity or testimonials do not establish effectiveness.

The evaluation plan remains authoritative for detailed methods and unresolved
decisions. Still open before execution: exact task snapshots and first case
set; practical availability of independent reviewers; which external Skills
are relevant and comparable under controlled settings; which runtime exposes
sufficient Skill-load evidence; whether setup repetition warrants the fixture
wrapper; and what evidence the owner will require for any release or
composition decision. The previously listed local LLM context-window
investigation is deferred and remains separate from this bounded v0.4 scope.
These questions do not block this roadmap update and must not be filled with
invented outcomes.
