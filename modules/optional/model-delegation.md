# Model Delegation

## Assisted model delegation

Delegation is optional. The assigned agent remains the primary implementer and
task owner; senior agents retain responsibility for architecture-relevant
implementation, integration choices, and their own coding work. Implementation
owners assemble delegated results, integrate, build, test, debug, and report.

When considering delegation, read the user's configuration at
`${XDG_CONFIG_HOME:-$HOME/.config}/engineering-skillset/model-delegation.md`.
If it is absent, continue directly unless another delegation mechanism is
explicitly authorized and available.

Delegate only bounded, independently verifiable tasks when expected savings in
time, API cost, or resource use outweigh preparation, context transfer,
integration, verification, and likely rework. Give each executor only the
context needed to state scope, interfaces, constraints, expected results, and
verification. Delegation does not transfer accountability or expand authorized
scope. Sub-delegation is allowed only within the assigned scope and the
operator's authorization; avoid unnecessary depth.

Before distributing implementation work, the lead establishes a proportional
test strategy from the project preset, requirements, architecture, risks,
component and integration boundaries, and acceptance criteria. Assign each
task its owned guarantees and required checks. Component checks establish local
behavior; integration checks cover interactions; system checks cover relevant
end-to-end outcomes. Avoid redundant coverage. Executors may add justified
local checks but must not weaken the agreed strategy; material changes return
to the lead. The implementation owner performs integration and final
verification. Final QA checks the complete result against requirements,
strategy, and evidence. Scale checks strictly and proportionally to the preset:
prototypes need essential correctness checks without excess test
infrastructure; reliable work needs stronger evidence where risk warrants it,
not more agents by default.

Use existing agent and OpenCode session capabilities. The initial workflow is
assisted, using separate sessions. Do not assume an invocation or communication
capability that is unavailable; prepare a precise operator handoff instead.
Limited hierarchical delegation is permitted when the existing executors
support it, with the delegating agent accountable for subordinate results.
Keep the workflow modular and provider-independent. Local model and executor
preferences belong in private user configuration, not this compiled policy.

Respect the selected preset: `prototype`, `fast-development`, `performance`,
and `reliable` keep their existing engineering and QA priorities. Delegation
is never mandatory for a preset.
