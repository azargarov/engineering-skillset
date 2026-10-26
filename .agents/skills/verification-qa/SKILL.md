---
name: verification-qa
description: Plan and assess proportionate tests and other checks for an engineering change when deciding what verification to run or what results establish.
---

Assess verification evidence for the authorized scope. Focus on properties,
test levels, and what results establish; Implementation Review focuses on
implementation defects and design quality. Do not repeat a code review just
because verification was requested.

Checks may run iteratively during implementation. For formal completion,
follow the active Core Policy's implementation-review → final-verification →
acceptance order.

1. Identify the authorized scope, acceptance criteria, and relevant guarantees
   from the active instructions. Use the selected project level and priorities
   where they change verification decisions; do not invent configuration.
2. Map each important property to the lowest architectural level that can
   establish it: component behavior and boundaries, integration between
   components, or system behavior and user outcomes.
3. Inspect existing tests, checks, and applicable fresh evidence before
   proposing more. Note which properties each check covers and where coverage
   is weak, missing, stale, or at the wrong level. Passing component tests do
   not establish integrated or system behavior.
4. Select the smallest sufficient additional checks for the gaps. At higher
   levels, target interactions and emergent behavior instead of repeating
   component coverage. Repeat a critical guarantee only when the higher-level
   check gives distinct evidence against another failure mode.
5. Run relevant checks when authorized and feasible. Preserve each actual
   result, including failures. Do not silently recast a failing check as a
   warning, and do not expand implementation scope to fix a discovered issue
   unless that work is authorized.
6. Identify the assurance that actually occurred: implementation self-check
   (the author's direct checks while working), deterministic automated
   verification (repeatable commands against defined expectations), same-agent
   review (the author reviews their own work), or independent review (a
   separate reviewer). Self-checks and same-agent review are not independent
   assurance.
7. Report the requested scope as **verified**, **partially verified**, or **not
   established**, limiting the claim to properties supported by evidence.
   Distinguish:
   - **OBSERVED** — checks actually executed and artifacts directly inspected.
   - **INTERPRETED** — conclusions drawn from those observations.
   - **NOT ESTABLISHED** — relevant properties without sufficient evidence.

Use these labels as concise signposts, not as a fixed report form. Keep small
changes lightweight, avoid repeating checks without a distinct reason, and
state focused follow-up checks for important gaps. When a test reveals a
concrete defect, report the observed failure and the narrow verification gap;
leave implementation review and correction to the authorized workflow.
