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
2. Look for the user's private preferences at
   `${XDG_CONFIG_HOME:-$HOME/.config}/engineering-skillset/model-preferences.md`.
   If absent, fall back to the deprecated
   `${XDG_CONFIG_HOME:-$HOME/.config}/engineering-skillset/model-delegation.md`.
   If both exist, use only the new file; do not merge them. If neither exists,
   use the existing selection behavior. Read any `preferred_models` provider
   lists as advice. The file is Markdown; interpret the simple section directly
   without requiring a parser. Do not expose private connection details in
   task context.
3. Run `opencode models` before invocation. Match the resolved preferences
   against the available provider/model identifiers exactly; never infer that
   an unavailable preferred model is available.
4. Prefer an available configured model when it is suitable for the task.
   List order expresses preference within that provider only; provider order
   does not set a global ranking. Consider task complexity, capability,
   context needs, tool support, availability, expected total cost, completion
   time, and verification/integration effort. Preferences are not an allowlist:
   choose another available model when it is a better fit and briefly explain
   why. If a preferred model is unavailable, skip it and consider other
   available candidates; do not silently substitute it as if it were
   available.
5. When reporting the handoff/result, name the selected provider/model exactly
   as listed by OpenCode and give a brief reason, including why it was outside
   preferences when applicable. Do not imply a preferred model was used if it
   was unavailable.

## Run a bounded task

Use `opencode run --model <provider/model> --dir <project-path> "<task>"`
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
