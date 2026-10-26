# Module Composition Model

**Status:** M00.3 design draft; proposed requirements, not an implementation

## Purpose and boundary

Define a small model for assembling project-specific policy from reusable
modules. The proposal preserves the existing Core Policy and Engineering
Principles. It does not define an installer, CLI, configuration schema, module
catalogue, or workflow Skills.

The composition categories follow the project roadmap:

`Core Policy + one project level + zero or more priorities + zero or more optional modules`

Selected workflow Skills are a separate concept. A Skill describes a reusable
task procedure; a policy module sets standing expectations or adjusts the
emphasis and rigor of work. The same Skills may be used with different policy
compositions. A module need not correspond to one Skill.

## Module responsibilities

| Category | Selection | May contribute or adjust | Must preserve |
|---|---|---|---|
| Core Policy | Always included, exactly once | Universal engineering guarantees and common task guidance | Authorized scope, correctness, truthful evidence, proportionate QA, and the other approved Core requirements. It cannot be weakened by selected modules. |
| Project level | Exactly one | Typical rigor, breadth of checks, planning depth, and operational emphasis for the project's intent | Core guarantees. A level does not select priorities or authorize work outside the user's request. |
| Engineering priorities | Zero or more | Emphasis and relevant trade-off guidance, such as readability, development speed, runtime performance, reliability, or resource efficiency | Core guarantees and the selected project level. A priority is not permission to trade correctness or authorized requirements away. |
| Optional modules | Zero or more | Specialized, bounded guidance such as educational behavior, security, API contracts, or deployment practices | Core guarantees, the selected level, and the user's authorized scope. A module applies only within its stated subject and conditions. |

These categories are conceptually distinct. For example, educational behavior
is an optional concern that can apply at more than one project level; it is not
a project level. Security may be represented as an optional specialized module
when its guidance adds specialized practices; a topic's label alone does not
determine its category.

## Proposed composition approach

### Fixed-order named sections

Assemble one readable policy document from named sections in a fixed category
order:

1. Core Policy, retained verbatim and first.
2. The single selected project-level section.
3. Selected priority sections in stable identifier order.
4. Selected optional-module sections in stable identifier order.

Within-category ordering is for reproducible presentation only; it does not
give one priority or optional module authority over another. Unselected modules
contribute no instructions. Workflow Skills remain separate artifacts and are
not folded into these policy sections.

The exact output filename and installation location remain open. This proposal
describes the effective content and order, not an installed repository layout.

Composition produces a standalone effective policy from Core Policy and the
selected modules; it does not merge repository instructions. Integrating that
policy with pre-existing repository guidance belongs to the installer. The
installer must not silently overwrite, duplicate, or weaken existing
instructions; exact reconciliation behavior remains open.

### Comparison with named slots

| Concern | Fixed-order named sections | Named slots filled by modules |
|---|---|---|
| Simplicity | Direct concatenation in a short, explicit order; little indirection. | Requires a template, slot definitions, and rules for filling them. |
| Predictability | Category order and stable within-category ordering are easy to inspect. | Predictable when slot order and fill rules are explicit, but behavior is less visible from the selected modules alone. |
| Maintainability | Easy to edit and review as a single composed document; sections can be added when a real category needs them. | Can keep insertion locations consistent as templates grow, but adds another structure to maintain. |
| Conflict handling | Makes all selected guidance visible together; order must not be treated as override precedence. | Slots can separate concerns, but do not resolve contradictory instructions and may imply precedence if insertion points differ. |
| Extensibility | Adequate for the current four categories; new sections can be added deliberately. | More flexible for many insertion points or repeated variants, at added complexity. |
| Testability | Check required section presence, content, order, omissions, and reproducibility. | Also check valid slot names, required fills, cardinality, and slot ordering. |

**Recommendation:** Use fixed-order named sections as the initial composition
model. It fits the small, known category set and is easier to audit. Keep this a
proposal for M01 to validate with representative compositions; do not build a
general template or slot engine. Neither approach detects arbitrary semantic
conflicts by itself.

Every engineering priority must influence identifiable engineering decisions,
such as design choices, verification depth, or trade-offs. Reject or
consolidate any module that merely repeats Core Policy or offers generic
aspirations without changing a decision.

## Conflict handling

- Core Policy and the user's authorized scope are not overrideable by a level,
  priority, or optional module. Section order is not a precedence rule.
- Project level, priorities, and optional modules describe different axes.
  Multiple priorities may coexist; do not silently rank one above another.
- When priorities pull in different directions, preserve correctness and
  acceptance requirements. Use explicit targets and observed evidence where
  available (for example, measured performance goals); explain material
  trade-offs and seek direction when the authorized requirements genuinely
  conflict.
- Reject an unsupported selection or a combination explicitly declared
  incompatible, with a clear explanation before producing the final output.
  Keep such compatibility declarations direct and small; do not introduce
  transitive dependency resolution or a general plugin system.
- Natural-language contradictions cannot be assumed detectable by a
  deterministic composer. Review module guidance for conflicts. If a material
  conflict is discovered and cannot be resolved from existing authority,
  constraints, or an explicit user decision, surface it and do not present the
  composition as unambiguous. At task time, follow instruction authority and
  raise same-level material conflicts for direction.

## Illustrative compositions

These examples show policy composition only; they do not establish a final
module catalogue or configuration syntax.

### Prototype + development speed

| Layer | Contribution |
|---|---|
| Core Policy | Always applies: authorized scope, correctness, readable code, QA, compositional tests, truthful evidence, and proportionate continuity. |
| Prototype | Keep scope, planning, and verification narrow and suited to testing the current idea; use sufficient checks for the claims and risk. |
| Development speed | Favor small useful increments and low administrative overhead. It does not waive final relevant verification or truthful reporting. |
| Optional modules | None selected. |

The speed priority adjusts effort and emphasis; it cannot turn an unchecked
claim into a verified result or expand the authorized task.

### Personal + readability + runtime performance

| Layer | Contribution |
|---|---|
| Core Policy | Always applies, including KISS/YAGNI, correctness, scope, QA, and honest evidence. |
| Personal | Use maintainable, professional practices with pragmatic planning and coverage. |
| Readability | Prefer clear names, explicit flow, and natural responsibility boundaries. |
| Runtime performance | Address relevant performance targets with measurements or profiling where practical; avoid speculative optimization. |
| Optional modules | None selected. |

If an optimization materially harms readability, do not infer a winner from
section order. Compare the change to a relevant performance target, explain the
trade-off, and ask for direction if requirements cannot both be met.

### Production + reliability + security

| Layer | Contribution |
|---|---|
| Core Policy | Always applies; correctness, scope, QA, verification honesty, and continuity remain mandatory. |
| Production | Apply deeper operational, compatibility, reliability, and security scrutiny as relevant to the system and change risk. |
| Reliability | Emphasize dependable behavior, failure handling, and evidence appropriate to operational impact. |
| Optional security module | Add bounded security guidance for relevant data, access, threat, and failure concerns. |

If reliability and security guidance conflict for a concrete requirement, the
composition order does not decide the trade-off. Surface the specific risk and
resolve it against authorized requirements and explicit decisions.

## Composition acceptance criteria

### Deterministic structural validation

A composition is structurally acceptable when checks establish that:

- Core Policy is present exactly once, unchanged, and first; selected modules
  cannot remove or replace it.
- Exactly one supported project level is selected, and only selected priority
  and optional modules contribute instructions.
- Sections appear in the prescribed category order, with reproducible ordering
  within categories, regardless of selection input order.
- Module references resolve; no unresolved placeholders or missing references
  remain in the output.
- Identical source revisions and selections produce byte-identical output.
- Unsupported selections and explicitly incompatible combinations fail clearly
  rather than yielding partial or silently altered output.
- Duplicate section identifiers/headings or byte-identical section content
  are detected deterministically.
- The composed result is compact, readable Markdown with no duplicated Core
  section introduced by composition.

These checks establish composition structure and repeatability, not whether the
policy improves agent behavior.

Review semantic redundancy separately: equivalent natural-language guidance
may be phrased differently, so the composer is not required to detect it.
Reviewers should reject or consolidate modules whose guidance adds no
identifiable decision beyond Core or other selected modules.

### Behavioral effectiveness

Whether Core, modules, or Skills improve real Codex outcomes is a separate
Skillset evaluation question. Structural validity, clear examples, and a
successful composition do not establish behavioral effectiveness. Evaluation
methods, thresholds, and acceptance policy remain unresolved.

## Risks and remaining decisions

**Risks:** Fixed sections can still accumulate duplication; prose conflicts
may escape deterministic checks; a stable rendering order may be mistaken for
priority precedence; and a compact policy can still be too long or too vague
for routine use. Review actual composed examples before expanding the model.

**Open decisions:**

- Final labels, identifiers, boundaries, and contents for levels, priorities,
  and optional modules.
- Whether M01 confirms fixed sections or exposes a concrete need for named
  slots; this recommendation has not been behaviorally validated.
- The minimal representation for supported selections and explicitly
  incompatible pairs, if any, without creating a general schema or resolver.
- Exact output file/location, source versioning, and how composition is safely
  integrated with existing project instructions.
- How Skills are selected and distributed alongside policy modules while
  remaining reusable and conceptually separate.
- What evidence and independent review, if any, establish behavioral
  effectiveness; evaluation remains open.

## Alignment review

| Engineering Principle | How this proposal preserves it |
|---|---|
| 1. Meet the authorized need | Modules cannot expand scope or override user authorization. |
| 2. Choose the simplest adequate solution | Recommends fixed sections and rejects a general template/dependency framework. |
| 3. Design and test from broad to narrow | Separates universal, level, priority, optional, and workflow guidance; requires structural composition checks. |
| 4. Apply QA at every meaningful stage | Requires review of selected instructions and explicit conflict handling; does not prescribe task-time ceremony. |
| 5. Report evidence honestly | Separates structural validity from behavioral effectiveness and leaves effectiveness unclaimed. |
| 6. Preserve development continuity | Keeps the model auditable and calls for retaining relevant decisions without prescribing record files. |
| 7. Adapt rigor, not the guarantees | Levels and priorities adjust emphasis and depth while Core guarantees remain invariant. |

This proposal meets the M00.3 roadmap intent by defining category
responsibilities, a provisional composition order, conflict behavior, examples,
and structural acceptance criteria. It leaves module taxonomy and output layout
open for bounded validation in M01.
