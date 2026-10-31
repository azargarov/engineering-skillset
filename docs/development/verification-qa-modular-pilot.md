# Verification QA Modular Composition Pilot

**Review verdict:** PASS. The independent pilot verdict is preserved. The
owner accepted the composition pattern; this closeout stage corrected output
permissions to honor the active umask.

## Configuration and composition

[`../../presets/skill-modules.mk`](../../presets/skill-modules.mk) is a plain
GNU Make include containing explicit ordered lists of Markdown files for
each pilot variant. `Makefile` concatenates selected files below fixed Skill
frontmatter and a configured heading. The source modules are included
verbatim, in the order declared. Generated file permissions follow the
invoking process's umask.

The shared `common.md` module holds verification principles. `smoke.md` adds
the prototype strategy; `comprehensive.md` adds the reliable strategy. This
keeps workflow names stable while allowing the compiled `verification-qa`
content to differ by preset.

## Limitations

- This is a focused pilot, not a general configuration format. Only the
  explicitly configured workflows and `prototype`/`reliable` variants can be
  compiled.
- The compiler provides a fixed frontmatter wrapper and concatenates Markdown;
  it does not support templates, conditional sections, dependency resolution,
  or module-level metadata.
- Module paths are whitespace-separated Make values, so paths containing
  spaces are unsupported. Missing or unreadable files fail before the target
  artifact is replaced.
- During the initial pilot, `dist/reliable` contained only this Skill and had
  no generated `AGENTS.md`. The complete preset composition stage now
  generates the policy and full Skill set. `ess` remains unchanged; its
  existing discovery and install assumptions are exercised by disposable
  project checks for the complete presets.
- The complete build now stages and validates all presets before publishing
  files individually by atomic rename. Existing directory Skill links remain
  stable across successful rebuilds. An interruption during the sequence of
  file replacements can still leave mixed generations; `make clean` still
  removes published outputs and breaks those links until the next build.

The focused tests verify the generated variants, selected content and order,
frontmatter, differences, deterministic output, umask behavior for `022` and
`077`, and clear failures for invalid selections and missing modules. They do
not establish behavioral effectiveness in agent tasks.

## Comparison and extension recommendation

The prototype variant prioritizes startup and the primary scenario, normally
uses a manual smoke check, and records limitations and unverified assumptions.
The reliable variant covers relevant contracts, invariants, boundaries,
integrations, regressions, and failures, with concurrency, recovery, resource,
or load checks when justified. Both share the same principles for risk-based
checks, correctness, and truthful evidence.

Extend this pattern to another workflow after owner review confirms that these
variants are clear, useful, and maintainable. Keep explicit file lists and
verbatim composition while they remain sufficient; add broader configuration
machinery only if a concrete workflow requires it.
