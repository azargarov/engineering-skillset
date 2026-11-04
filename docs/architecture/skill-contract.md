# Workflow Skill Contract

## Purpose and boundary

A workflow Skill provides a reusable, actionable procedure for a recognizable
task. It is separate from standing engineering policy and from policy modules:
Core Policy and the selected effective policy remain authoritative, while a
Skill guides how to carry out one workflow. A Skill does not change project
level, priorities, module selection, or authorization.

Skills may be reused with different policy-module configurations. They should
apply the active project instructions and priorities without copying or
weakening Core guarantees.

## Minimal structure

Store a repository Skill in Codex's repository-local discovery directory:

```text
.agents/skills/<skill-name>/SKILL.md
```

The `SKILL.md` begins with YAML front matter containing:

```yaml
---
name: example-skill
description: Explain the task this Skill handles and when Codex should use it.
---
```

The `name` is a concise, stable Skill identifier. The `description` states
both the task and its activation context so Codex can select it appropriately.
The Markdown body contains the workflow's actionable instructions.

Add scripts, references, or assets only when they materially support the
procedure. An instruction-only Skill is the default. Skills are discovered
separately from policy composition and installation; this contract does not
define distribution, installation, configuration, or evaluation machinery.

## Discovery and invocation

Codex scans repository-local `.agents/skills` directories from the current
working directory through the repository root. It uses Skill metadata to
consider matching Skills, and users can request one explicitly with
`$<skill-name>`, for example `$implementation-review`. Codex may need a
restart if a local Skill change is not picked up.

These conventions follow the current
[Codex Skill documentation](https://learn.chatgpt.com/docs/build-skills).

For software development, all four workflow Skills (`software-design`,
`implementation-review`, `verification-qa`, and `project-handover`) are
mandatory. Core Policy controls their staged, progressive loading; load each
at its corresponding stage rather than loading every Skill body at startup.
The active preset determines each Skill's depth and verification
requirements. If a required Skill is unavailable, report that and do not
claim execution.

## Instruction quality

- Keep a Skill focused on one workflow and concise enough to follow during
  routine work.
- Give operational steps and useful outputs rather than restating general
  engineering principles.
- Apply scope, project-level rigor, priorities, and existing conventions from
  the active instructions; do not invent configuration or approval steps.
- Distinguish required findings from optional improvements and unsupported
  speculation.
- Do not claim independent assurance when the authoring agent reviews its own
  work.

## Initial Skill

The first implementation of this contract is
[`implementation-review`](../../.agents/skills/implementation-review/SKILL.md).
It supplies a bounded review procedure without adding scripts, references, or
changes to the composer or installer.
