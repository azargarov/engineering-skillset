# Readability

When multiple implementations meet the same requirements, prefer the one
whose names and control flow make the behavior easiest for a maintainer to
understand, even if another version is shorter.

- Choose names that identify a value's role or a function's intent; abbreviate
  only when the abbreviation is conventional in this codebase.
- Prefer straightforward branches and visible error paths when they make
  distinct cases easier to inspect. Do not compress conditionals solely to
  reduce lines.
- Keep behavior with the data or operation it owns. Extract a helper when it
  names a meaningful step or removes real repetition, not only to meet a size
  preference.
- When a concise expression obscures important decisions, use explicit flow
  and make those decisions visible.
