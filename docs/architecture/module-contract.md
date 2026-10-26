# Minimal Policy Module Contract

**Status:** M01.1 deliverable; source-file convention for composition work

## Purpose and boundary

This contract defines the smallest readable source representation for reusable
policy modules. It supports the approved composition:

`Core Policy + exactly one project level + zero or more priorities + zero or more optional modules`

Policy modules are not workflow Skills. A module changes standing policy
emphasis or depth; a Skill describes a reusable task procedure. This contract
does not define a composer, installer, general configuration schema, template
engine, dependency resolver, or Skill layout.

## Identity and category

Use one Markdown file per module at:

```text
modules/<category>/<id>.md
```

The category directory is one of `levels`, `priorities`, or `optional`. The
file basename without `.md` is the module ID. Together, the category and ID
form its identity, for example `priorities/readability`. Use lowercase ASCII
letters, digits, and hyphens in IDs so lexical ordering is locale-independent.

Identity and category come from the path; do not repeat them in frontmatter or
a manifest. The visible Markdown heading is for readers and does not determine
identity. Paths are one level below the category directory; there are no
nested modules, aliases, or duplicate registrations.

Core Policy is deliberately not a selectable module. Its canonical source is
the root `AGENTS.md`; it is always included exactly once before modules. There
is no `modules/core` category, and a selected module cannot occupy or replace
the Core position.

## Module content

Keep module content as ordinary, directly readable Markdown:

- Begin with one descriptive level-one heading, followed by concise policy
  instructions.
- State guidance that belongs to the module's category and applies within its
  scope. Do not restate Core Policy as a substitute for module-specific value.
- Preserve Core guarantees, authorized scope, and truthful evidence reporting.
  A module adds emphasis or constraints; it cannot weaken those guarantees.
- Avoid frontmatter, embedded configuration, template markers, generated
  syntax, and metadata not needed to select, order, or understand the module.

Every engineering priority must guide identifiable engineering decisions.
Reject or consolidate a module that only repeats Core principles or offers
generic aspirations without changing a decision. For example, a readability
priority should say how to choose between concrete implementation options,
not merely instruct the agent to write readable code.

## Selection and reproducible order

A selection identifies modules by category and ID. The eventual configuration
syntax remains open; these identity rules do not prescribe one.

Compose in this order:

1. Root `AGENTS.md` as the immutable Core Policy source.
2. Exactly one selected file from `modules/levels/`.
3. Selected files from `modules/priorities/`, sorted by ID in bytewise
   ascending order.
4. Selected files from `modules/optional/`, sorted by ID in bytewise ascending
   order.

The order is for reproducible presentation, not authority. Module order does
not resolve conflicts. Selection input order has no effect. Include each
selected file's Markdown content once; unselected files contribute nothing.

## Minimum selection and compatibility checks

For this contract, the necessary checks are:

- Require exactly one project-level ID and confirm its file exists in
  `modules/levels/`.
- Confirm each priority and optional ID exists in its matching category
  directory; reject duplicate selections and category-mismatched references.
- Reject IDs that do not follow the filename convention, missing files, and
  unknown categories. Never accept a module reference as the Core Policy.
- Include Core from root `AGENTS.md` once and first, regardless of module
  selection; module files cannot replace that source structurally.

No pair-specific incompatibilities are known for the current source set, which
contains only the `priorities/readability` example and no project-level or
optional modules. Do not add a compatibility table or dependency mechanism
until a real supported combination requires one. Natural-language conflicts
still need review; path validation cannot prove semantic compatibility.

## Example and current limits

[`modules/priorities/readability.md`](../../modules/priorities/readability.md)
is the single example module. The contract describes all three selectable
categories, but this example alone does not form a complete composition:
there is not yet a project-level module. Creating representative level and
optional modules belongs to later approved M01 work.

This contract establishes identity, category, content, order, and basic
selection checks only. It does not establish that any module improves Codex
behavior, nor does it settle the final category taxonomy or installed output
layout.
