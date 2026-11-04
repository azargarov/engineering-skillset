# M0.9 closeout addendum — prompt framing limitation

**Owner acceptance:** The owner accepts the completed M0.9 GPT-6 Luna evaluation and its bounded findings, recorded in commit `3d33c251da93bedead9c5f2c8f2735b123907618`. GitHub Actions run [41847210179](https://github.com/azargarov/engineering-skillset/actions/runs/41847210179) passed. This addendum supplements the accepted report; it does not edit or replace M0.9 results or artifacts.

The owner reconfirms these accepted M0.9 findings:

- All six Luna runs passed the frozen evaluator's 11 requirements.
- No functional correctness improvement was observed with hardened ESS.
- Hardened ESS increased descriptive mean elapsed time by approximately 1.53× and input tokens by approximately 1.92×.
- Additional verification activity was observed but uncovered no frozen-requirement failures.
- Skill discovery, activation, and compliance were inconsistent.
- The small sample, catalog variability, and other documented limits prevent causal or statistically conclusive claims.

The owner identified a further limitation relevant to interpretation of ESS effectiveness: the L-A “without ESS” condition was not free of engineering-process guidance. Task v2 explicitly asked the candidate to add tests, run Go verification, report commands and results, and update project status. The candidate snapshot also contained an `AGENTS.md` instructing focused tests, `go test ./...`, status-document updates, and verification reporting, plus a project-status document with development history and a “next authorized action.” These directions overlap with hardened ESS guidance.

This framing does not change observed functional outcomes or resource measurements for the tested configurations. It weakens attribution of verification behavior and engineering outcomes to ESS, because the baseline already received process instructions. M0.9’s small sample and other documented limits continue to preclude causal or statistically conclusive claims.

The accepted [M0.9 report](evaluation-runs/m09-luna/final-report.md), all run evidence, task/evaluator inputs, frozen M0.6 baseline, candidate outputs, and hashes remain unchanged. The issue is being addressed prospectively in the M0.10 task-normalization proposal; no additional M0.9 run is authorized or planned.
