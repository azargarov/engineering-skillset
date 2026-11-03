---
name: opencode-delegation
description: Delegate bounded engineering tasks to configured OpenCode models and integrate their results safely.
---

# OpenCode Delegation

Use this Skill only when delegation is enabled by the project's Engineering
Skillset policy and delegation is useful for the current task. The lead agent
retains responsibility for scope, architecture, integration, verification,
and the final result.

## Check availability and models

1. Check that OpenCode is installed with `command -v opencode`. If it is
   unavailable, continue directly or provide a precise handoff if the user
   authorized another executor.
2. Run `opencode models` and choose from the configured models. Do not assume
   a model, provider, endpoint, or credential that is not shown by the local
   configuration.
3. If present, consult the user's private preferences at
   `${XDG_CONFIG_HOME:-$HOME/.config}/engineering-skillset/model-delegation.md`.
   Treat this as advice only and do not expose private connection details in
   task context.
4. Select a model using demonstrated capability, context needs, tool support,
   expected cost, completion time, and the effort needed to verify and
   integrate the result. Local models often suit focused functions, isolated
   tests, documentation, simple fixes, and refactoring. Cloud models often
   suit larger or multi-file implementation, complex debugging, and work that
   needs substantial context or reasoning. These are preferences, not rules.

## Run a bounded task

Use `opencode run --model <configured-model> --dir <project-path> "<task>"`
for a noninteractive task. Confirm available flags with `opencode run --help`
when the installed version differs. Do not use `--auto` unless the user
explicitly authorized automatic permission approval. Keep delegated work
within the user's scope and give it only the necessary files and context.

Before starting, provide the task boundary, relevant interfaces and
constraints, expected result, required checks, and how to return the result.
Prefer a small, independently verifiable task with clear ownership. Do not
assume separate OpenCode sessions can communicate with each other.

## Integrate and verify

Collect the complete result and the commands run, their outcomes, and any
remaining limitations. Review every change in the project context. Resolve
integration issues, run the lead's established verification strategy, and
compare the result with the authorized requirements. Delegated checks can
provide evidence, but do not replace the lead's integration and final QA.
Return incomplete or out-of-scope work to the lead without applying it.
