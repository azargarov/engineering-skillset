# Engineering Principles v1

**Version:** 1.0, M00.1 deliverable; grounded in Architecture and Requirements Brief v0.1

**Purpose:** State the small set of engineering guarantees that the methodology must preserve. These principles do not prescribe Skills, tools, repository layout, configuration, or installer design.

## 1. Non-negotiable guarantees

1. **Meet the authorized need.** Work from explicit user needs, constraints, and acceptance conditions. Keep changes within authorized scope. Surface material ambiguity, risk, contract changes, or scope growth at a meaningful decision point.
2. **Choose the simplest adequate solution.** Prefer clear, idiomatic, maintainable code and the smallest suitable design. Apply KISS and YAGNI; use DRY and SOLID as judgment aids, not mechanical rules. Add abstractions, dependencies, configuration, or structure only when justified by a present need. Respect existing conventions and contracts unless an approved change is needed.
3. **Design and test from broad to narrow.** Relate user outcomes to system responsibilities, component contracts, and implementation steps at a depth proportionate to the change. Design tests with requirements and interfaces. Component tests establish local guarantees; higher-level tests focus on emergent interaction and system properties, relying on valid lower-level evidence instead of repeating its full coverage. Critical guarantees may be repeated at higher levels when doing so provides independent evidence against distinct failure modes.
4. **Apply QA at every meaningful stage.** Check requirements and scope, design and plan, implementation, verification, and acceptance/handover. Iterative tests during implementation are encouraged. The mandatory formal-completion sequence is: implementation → implementation and scope review → final relevant verification → acceptance against user outcomes → record and handover. Failed checks require correction and rechecking of affected work. Small changes may combine stages; meaningful checks remain.
5. **Report evidence honestly.** Distinguish observed results, interpretation and its basis, and what remains unestablished. Report commands and checks actually run, failures, limitations, and relevant gaps. Never imply tests, approvals, user validation, measurements, or readiness that did not occur.
6. **Preserve development continuity.** Retain the decisions, stage outcomes, deviations, and verification evidence needed to understand meaningful work. Keep the active state concise, with confirmed status, blockers, next action, and links to durable records. Record-keeping is proportional; deferred ideas do not become authorized work merely by being recorded.
7. **Adapt rigor, not the guarantees.** Scale analysis, documentation, review depth, and verification to project intent, change impact, and risk. A prototype can use a narrow plan and focused checks; production work may need deeper security, reliability, compatibility, operational, and change-control evidence as applicable. A profile or maturity change prompts a relevant gap assessment and bounded changes, not an automatic rewrite. Correctness and authorized requirements are not traded away for speed or another priority.

## 2. Optional workflows and techniques

These are choices to apply when useful, not universal requirements in every task:

- Detailed architecture diagrams, formal ADRs, milestone plans, and separate stage records.
- Test-first or other prescribed implementation sequences; independent review; multiple reviewers.
- CI orchestration, prerequisite-suite execution, or reliance on fresh verification evidence tied to a revision.
- Expanded traceability matrices, performance measurement, security analysis, deployment checks, and observability review.
- A separate backlog, additional approval gates, or specialized review checklists.

Use a technique when its expected value for clarity, risk reduction, or verification justifies its cost. The required QA outcomes remain; the ceremony and mechanism are not fixed here.

## 3. Proportionate QA

At each applicable stage, ask the smallest set of questions that can establish the needed confidence:

| Stage | Review questions |
|---|---|
| Requirements and scope | Is the intended outcome clear enough to act on? Are constraints, acceptance, and boundaries understood? |
| Design and plan | Are responsibilities, contracts, dependencies, risks, and test levels appropriate? Is the proposed work sized to the need? |
| Implementation | Does the change meet the requirements and agreed design? Is it readable, idiomatic, appropriately simple, and within scope? Are relevant error paths and resource lifecycles handled? |
| Verification | Which relevant checks actually ran, against what change where material? What failed, was skipped, is stale, or remains uncovered? Do tests establish the intended behavior at the correct level? |
| Acceptance and handover | Do results meet the acceptance conditions? Are deviations, limitations, unverified claims, current state, and next action clear? |

Review depth follows risk and impact: consider changed contracts and consumers, security or data exposure, failure cost, irreversibility, deployment reach, and uncertainty. Agent self-review is the agent's own inspection of its work; deterministic verification is repeatable checking against defined expectations; independent review is scrutiny by a reviewer separate from the authoring agent. Self-review and deterministic verification provide useful evidence, but self-review is not independent assurance. For a low-risk local change, a focused self-review and relevant checks may be enough. Higher-impact work warrants broader design scrutiny, independent review where useful, and deeper verification. Independent review's activation policy remains undecided.

Tests are layered and compositional. Thoroughly establish each component's own behavior and boundaries at its level. At integration and system levels, focus on properties introduced by composition, including interactions, cross-component failures, and user outcomes. Critical guarantees may also be repeated when higher-level verification provides independent evidence against distinct failure modes. Higher-level suites may orchestrate lower-level suites or rely on fresh, applicable evidence; test functions should not call other test functions. A pass at one level is not evidence of guarantees belonging to another.

## 4. Mapping to the approved brief

| Brief requirement | Principle(s) |
|---|---|
| Desired outcomes 1–2; coding standards (3.3) | 1–2 |
| Desired outcomes 3–5; layered design and planning (3.4) | 1, 3–4 |
| Compositional tests and preliminary test design (3.5) | 3; QA table and test guidance |
| Central QA and truthful evidence (3.6) | 4–5; proportionate QA |
| Authorized scope and execution control (3.7) | 1–2, 4 |
| Development history and session continuity (desired outcome 7; 3.8) | 6 |
| Project maturity and priorities (desired outcome 8; 3.1–3.2, 5) | 2, 7 |
| Install/update safety and minimal target footprint (desired outcome 9; 3.9) | Retained as product requirements; not converted into coding principles |
| Lifecycle evolution and profile change (5) | 7 |
| Methodology quality and anti-overengineering constraints (desired outcome 10; 11) | 2, 7; optional-workflow rule |
| QA across requirements, architecture, planning, implementation, verification, acceptance (3.6) | 4; proportionate QA table |

Portability, installation, configuration, Skills packaging, and Skill evaluation are product or methodology design topics, not additional universal coding principles; their requirements remain in the brief.

## 5. Open questions to carry into M00.2

The brief leaves the following decisions open; this document does not resolve them:

- How will universal guarantees, optional workflows, project profiles, and task-specific guidance be expressed and kept from contradicting one another?
- What is the lightest practical mechanism for central QA across the lifecycle, and how will it preserve the implementation-review → final-verification → acceptance ordering?
- What criteria trigger explicit design/plan approval, independent review, or escalation, and how do these vary by profile and change risk?
- What is the smallest useful record model that preserves meaningful stage history and fresh-session continuity without duplicate sources of truth? Is a separate backlog worth maintaining?
- How should test evidence freshness and applicability be determined when higher-level verification relies on lower-level results?
- How will profile and priority changes prompt a relevant gap assessment without triggering an unnecessary rewrite?
- How will the Skills themselves be evaluated? This is an explicit priority open issue in the brief; the minimum credible structural, activation, behavioral, composition, and outcome evaluation remains undecided.
- What evidence is sufficient for acceptance in educational and prototype work while still making limitations explicit?

The exact Skill boundaries, configuration model, repository and installed-file layout, QA implementation (conventions, Skills, tools, or a combination), approval policy, and evaluation/release criteria remain open as stated in the brief.
