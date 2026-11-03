# Current State

- **Release:** v0.3.0 remains immutable at `7ea3d58c1c075663afd97f7bb3215339d8a050d3`.
- **M0.6:** Completed and owner-accepted. Hardened comparison source is frozen at `677bbeb7ee71e6089e9798e864c979bd253f4b78`.
- **M0.7:** Owner-accepted for one initial controlled pilot with procedural filesystem separation; enforced filesystem isolation is optional for this pilot. The accepted protocol requires a fresh snapshot-only candidate workspace, evaluator separation, pre/post integrity checks, contamination reporting, and runtime preflight. M0.7 closeout verification and push are in progress; no candidate run has started.
- **Authorized M0.8 scope:** One case-04 baseline run, Codex without ESS, frozen public snapshot and task, existing independent 11-requirement evaluator. No comparisons, additional cases, or repetitions.
- **Evidence:** [M0.7 record](docs/development/evaluation-runs/m07-pilot/implementation-plan.md), [protocol](docs/development/evaluation-runs/m07-pilot/protocol.md). Frozen input hashes are in the case's `INPUTS.sha256` manifests.
- **Next action:** Finish M0.7 checksums/repository checks, commit and push, confirm GitHub Actions, then perform runtime preflight. If preflight passes, execute and report the single authorized run; otherwise stop with the blocker.
