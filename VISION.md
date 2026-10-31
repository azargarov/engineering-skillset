# Engineering Skillset Vision

Engineering Skillset is a lightweight, modular engineering methodology for AI
coding agents. It lets an owner choose an engineering approach suited to the
current task while keeping the source rules small, reusable, and centrally
maintained.

## Problem and users

AI coding agents work on tasks with different risks, time constraints, and
performance needs. One fixed level of process either slows simple experiments
or provides too little guidance for work that needs stronger guarantees.
Engineering Skillset gives project owners and agent users a small set of
explicit strategies that can be selected for the work at hand.

Typical use is to install or switch a project's generated guidance from a
central Engineering Skillset checkout, then ask an agent to perform a task
under the chosen strategy. The strategy guides current work; it does not
automatically rewrite earlier code or waive project obligations.

## Desired experience

Users should be able to choose a preset, install or switch it with very few
commands, and get portable project instructions plus ready-to-use Skills.
Builds should be deterministic, generated Skills standalone, and updates
centrally maintained through Git. The system should be understandable from its
Markdown sources and a small declarative preset configuration.

The initial presets are:

- **prototype** — Validate a hypothesis quickly. Focus on essential business
  logic and the happy path, with minimal design and documentation. Manual
  smoke verification is normally enough; automated tests are optional unless
  a concrete risk calls for them. Acknowledge temporary limitations.
- **fast-development** — Build useful, maintainable software quickly with simple modular
  design and readable code. Test important behavior and common edge cases.
  Avoid unnecessary concurrency, abstractions, infrastructure, and premature
  optimization.
- **performance** — Meet measurable performance requirements using suitable
  algorithms, efficient resource use, profiling, benchmarking, and memory
  analysis. Add concurrency or asynchronous execution only when requirements
  and evidence justify it. Test relevant concurrency, race, resource, and
  regression risks while preserving functional correctness.
- **reliable** — Build predictable, maintainable software with strong
  correctness guarantees. State contracts, important invariants, error
  handling, and failure behavior. Use risk-driven unit, integration,
  regression, boundary, and recovery checks; address observability and
  recovery where relevant. Use concurrency only when the task justifies it,
  and verify meaningful requirements without exhaustively testing every
  possible input.

These strategies govern subsequent work after a preset switch. Switching does
not authorize retroactive refactoring or weaken existing project contracts,
operational requirements, or other obligations.

## Architecture and engineering principles

- **Module:** a small Markdown source component containing one engineering
  rule, behavior, or workflow variant.
- **Preset:** a named configuration that selects explicit module files to
  produce a ready-to-use engineering strategy.
- **Compiled Skill:** a complete, standalone `SKILL.md` generated from selected
  modules.
- **Core Policy:** universal engineering guarantees and instructions shared
  by all presets.

A simple declarative configuration maps each preset to its module files. A
Makefile deterministically composes those files into stable per-preset output
directories, producing standalone project `AGENTS.md` and `SKILL.md` artifacts.
Workflow Skill names remain stable across presets while their content may
differ. Workflow variants may be separate modules, such as
`verification-qa/smoke.md`, `verification-qa/essential.md`,
`verification-qa/performance.md`, and
`verification-qa/comprehensive.md`. Compiled Skills should be self-contained
with few internal cross-references. The Core Policy is shared and must not be
repeated in full in every Skill.

Core Policy remains common and self-contained in generated project
`AGENTS.md`. The `ess` CLI installs or switches built presets and links their
compiled Skills from a central Git checkout; it does not compile source
modules. Generated project `AGENTS.md` files remain portable and
self-contained. Git manages source versions and updates. Normal use should
require very few commands.

Keep the system understandable, minimal, and easy to maintain. Prefer simple
composition and established tools over custom frameworks. Preserve correctness
and truthful evidence across every strategy; scale design and verification to
the work's risks and stated requirements.

## Scope and non-goals

The product provides modular methodology sources, four initial presets,
deterministic compilation, centrally maintained Skills, and simple preset
installation and switching.

It is not a general-purpose package manager, a custom templating language, or
a dependency-resolution framework. It does not need complex runtime Skill
cross-references, automatic refactoring when presets change, or automatic
migration of an entire project to a new engineering level. Exhaustive testing
regardless of actual risk and complex configuration or lifecycle machinery
without demonstrated value are outside the scope.

## Expected outcomes and success criteria

Users can select a strategy appropriate to the current work, understand its
rules from concise source modules, and install or switch it with few commands.
Builds produce deterministic, standalone artifacts in stable locations;
shared guarantees remain present across presets; and the presets differ in
meaningful workflow guidance. Central updates can refresh linked Skills
without making project policy files dependent on the checkout. The result
remains small enough that maintainers can explain and change its behavior
without introducing a framework.
