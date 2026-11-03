# M0.6 — Skill Hardening

**Status:** Implemented, deterministically verified, and owner-accepted.
Behavioral effectiveness is not assessed by this milestone.

## Implementation plan

| Area | Change | Verification |
| --- | --- | --- |
| Verification evidence | Add property-level traceability, command/exit evidence, suitable levels, invalid-conclusion examples, and bounded red–green defect checks in the shared QA module. | Inspect compiled Skills for all presets and run existing composition/regression checks. |
| Existing Skills | Make handover metadata provider-neutral; define a concise delegation result and coordinator-check contract. | Inspect source metadata and delegation inclusion/exclusion in generated presets. |
| Skill observability | Assess the bounded M04.5 explicit-activation experiment; separate selection, loading evidence, and compliance. | Inspect preserved prompt/context digests, traces, reports, and overhead measurements. |
| CI | Run existing `make check` on push and pull request. | Inspect workflow structure and run its command locally; remote Actions remains unverified. |
| Memory | Record evidence, limitations, and operator review state. | Cross-check roadmap and `current.md` against observed results. |

No references are added: the new mandatory gates are short and must remain
directly accessible. No preset, installation, composition, or v0.3.0 baseline
changes are planned.

## Acceptance

- Skill instructions express the requested evidence and result contracts
  without duplicating implementation review.
- All four preset outputs retain their expected skills and optional delegation
  behavior; applicable existing checks pass.
- CI handles only push and pull-request events and runs `make check`.
- Observability findings distinguish skill selection, evidence of loading, and
  behavioral compliance; no effectiveness claim is made.

## Evidence and outcome

- `make build` — exit 0. Built all four presets.
- `make check` — exit 0 (closeout rerun). Composition, modular preset and Skill, CLI, user
  installation, and publication checks passed.
- A direct generated-artifact inspection for `prototype`, `fast-development`,
  `performance`, and `reliable` confirmed QA and handover Skills are present,
  the new QA rule is compiled, and OpenCode delegation remains only under each
  preset's optional delegation output.
- `git diff --check` — exit 0 (closeout rerun).
- The local PyYAML parser loaded `.github/workflows/check.yml`; inspection
  confirmed push and pull-request triggers and a single `make check` run step.
  `actionlint` is unavailable, and no remote GitHub Actions run has occurred.
- Skill observability evidence reuses the bounded M04.5 activation experiment
  (`docs/development/evaluation-runs/m04.5-skill-activation/README.md`).
  **Selection:** the task explicitly requested `$project-handover`.
  **Loading:** metadata appeared in the effective context, but the preserved
  trace showed no Skill-body read or resolution event, so loading is not
  established. **Compliance:** the handover output exists, but cannot be
  attributed to the Skill because loading was not established. Single-run
  input/output tokens were B: 119,261/1,435 and C: 142,106/1,557; elapsed
  times were 18.45s and 21.72s. These are measured run totals, not isolated
  Skill overhead, and do not establish a causal cost or behavioral effect.

No references were added because the mandatory gates remained concise.
Installation logic, preset selection, and v0.3.0 release artifacts were not
changed. No M0.7 work was started.

## Owner acceptance and closeout

The owner accepted M0.6 based on the implementation report and reviewed diff.
The closeout verification commands were:

| Command | Exit code | Result / limitation |
| --- | ---: | --- |
| `make check` | 0 | Existing deterministic composition, preset, Skill, CLI, user-installation, and publication checks passed. |
| `git diff --check` | 0 | No whitespace errors reported. |

The workflow is configured for push and pull-request events and runs only
`make check`. Remote Actions status is checked after the closeout push; local
checks do not establish remote CI status. No behavioral effectiveness claim is
made. The existing `v0.3.0` tag is unchanged, and no M0.7 implementation was
started.
