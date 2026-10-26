#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

test_dir=$(mktemp -d "${TMPDIR:-/tmp}/compose-policy-test.XXXXXX")
repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
composer=$repo_root/scripts/compose-policy.sh
core_file=$repo_root/AGENTS.md
duplicate_heading=$repo_root/modules/priorities/m01-4-duplicate-heading.md
duplicate_content=$repo_root/modules/priorities/m01-4-duplicate-content.md
symlink_module=$repo_root/modules/priorities/m01-4-symlink.md
duplicate_heading_created=0
duplicate_content_created=0
symlink_module_created=0

cleanup() {
  ((duplicate_heading_created)) && rm -f -- "$duplicate_heading"
  ((duplicate_content_created)) && rm -f -- "$duplicate_content"
  ((symlink_module_created)) && rm -f -- "$symlink_module"
  rm -rf -- "$test_dir"
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_core_prefix() {
  local output_file=$1
  local core_bytes
  core_bytes=$(wc -c < "$core_file")
  head -c "$core_bytes" "$output_file" | cmp -s "$core_file" - || \
    fail "Core Policy bytes changed in '$output_file'"
  [[ $(grep -Fxc '# Engineering Skillset Core Policy' "$output_file") == 1 ]] || \
    fail "Core Policy heading must occur exactly once"
}

expect_failure() {
  local expected=$1
  shift
  if "$composer" "$@" > "$test_dir/stdout" 2> "$test_dir/stderr"; then
    fail "command unexpectedly succeeded: $*"
  fi
  [[ ! -s $test_dir/stdout ]] || fail "failed command wrote partial stdout: $*"
  grep -Fq -- "$expected" "$test_dir/stderr" || {
    cat "$test_dir/stderr" >&2
    fail "expected error '$expected' for: $*"
  }
}

"$composer" --help > "$test_dir/help"
grep -Fq -- '--level ID' "$test_dir/help" || fail "help omits required level usage"

"$composer" --level personal > "$test_dir/zero-priorities.md"
assert_core_prefix "$test_dir/zero-priorities.md"
grep -Eq '^# Personal$' "$test_dir/zero-priorities.md" || fail "level section missing"
if grep -Eq '^# (Readability|Development Speed)$' "$test_dir/zero-priorities.md"; then
  fail "unselected priority appeared in output"
fi

"$composer" --level personal --priority readability > "$test_dir/one-priority.md"
assert_core_prefix "$test_dir/one-priority.md"
grep -Eq '^# Readability$' "$test_dir/one-priority.md" || fail "selected priority missing"

"$composer" --level personal \
  --priority readability --priority development-speed > "$test_dir/multiple-a.md"
"$composer" --level personal \
  --priority development-speed --priority readability > "$test_dir/multiple-b.md"
"$composer" --level personal \
  --priority development-speed --priority readability > "$test_dir/multiple-repeat.md"
cmp -s "$test_dir/multiple-a.md" "$test_dir/multiple-b.md" || \
  fail "priority selection order changed output"
cmp -s "$test_dir/multiple-a.md" "$test_dir/multiple-repeat.md" || \
  fail "repeated identical run changed output"
assert_core_prefix "$test_dir/multiple-a.md"

core_line=$(grep -n -F '# Engineering Skillset Core Policy' "$test_dir/multiple-a.md" | cut -d: -f1)
level_line=$(grep -n -F '# Personal' "$test_dir/multiple-a.md" | cut -d: -f1)
speed_line=$(grep -n -F '# Development Speed' "$test_dir/multiple-a.md" | cut -d: -f1)
readability_line=$(grep -n -F '# Readability' "$test_dir/multiple-a.md" | cut -d: -f1)
((core_line < level_line && level_line < speed_line && speed_line < readability_line)) || \
  fail "generated section order is incorrect"

"$composer" --level personal --priority readability \
  --output "$test_dir/output.md"
cmp -s "$test_dir/one-priority.md" "$test_dir/output.md" || \
  fail "file output differs from stdout output"
if compgen -G "$test_dir/.engineering-policy.*" > /dev/null; then
  fail "successful publication left a temporary output file"
fi

printf 'keep me\n' > "$test_dir/existing.md"
expect_failure "refusing to overwrite" --level personal --output "$test_dir/existing.md"
[[ $(cat "$test_dir/existing.md") == "keep me" ]] || fail "existing output was modified"

printf 'keep me\n' > "$test_dir/symlink-target.md"
ln -s -- "$test_dir/symlink-target.md" "$test_dir/symlink-output.md"
expect_failure "refusing to overwrite" --level personal --output "$test_dir/symlink-output.md"
[[ $(cat "$test_dir/symlink-target.md") == "keep me" ]] || fail "symlink output target was modified"

mkdir "$test_dir/fail-bin" "$test_dir/publish"
cat > "$test_dir/fail-bin/ln" <<'FAIL_LN'
#!/usr/bin/env bash
exit 1
FAIL_LN
chmod +x "$test_dir/fail-bin/ln"
if PATH="$test_dir/fail-bin:$PATH" "$composer" --level personal \
  --output "$test_dir/publish/policy.md" > "$test_dir/stdout" 2> "$test_dir/stderr"; then
  fail "publication failure unexpectedly succeeded"
fi
grep -Fq -- "could not create output" "$test_dir/stderr" || fail "publication failure was not reported"
[[ ! -s $test_dir/stdout ]] || fail "publication failure wrote partial stdout"
[[ ! -e $test_dir/publish/policy.md ]] || fail "publication failure left a partial output"
if compgen -G "$test_dir/publish/.engineering-policy.*" > /dev/null; then
  fail "publication failure left a temporary output file"
fi

mkdir "$test_dir/fail-sort-bin"
cat > "$test_dir/fail-sort-bin/sort" <<'FAIL_SORT'
#!/usr/bin/env bash
exit 1
FAIL_SORT
chmod +x "$test_dir/fail-sort-bin/sort"
if PATH="$test_dir/fail-sort-bin:$PATH" "$composer" --level personal \
  --priority readability --output "$test_dir/sort-failure.md" \
  > "$test_dir/stdout" 2> "$test_dir/stderr"; then
  fail "sort failure unexpectedly succeeded"
fi
grep -Fq -- "could not sort priority IDs" "$test_dir/stderr" || fail "sort failure was not reported"
[[ ! -s $test_dir/stdout ]] || fail "sort failure wrote partial stdout"
[[ ! -e $test_dir/sort-failure.md ]] || fail "sort failure published a partial policy"
if compgen -G "$test_dir/.engineering-policy.*" > /dev/null; then
  fail "sort failure left a temporary output file"
fi

[[ ! -e $duplicate_heading && ! -e $duplicate_content && ! -e $symlink_module ]] || \
  fail "temporary module fixture path already exists"
printf '# Readability\n\nDuplicate heading fixture.\n' > "$duplicate_heading"
duplicate_heading_created=1
expect_failure "duplicate section heading" --level personal \
  --priority readability --priority m01-4-duplicate-heading

cp "$repo_root/modules/priorities/readability.md" "$duplicate_content"
duplicate_content_created=1
expect_failure "duplicate section content" --level personal \
  --priority m01-4-duplicate-content --priority readability

ln -s readability.md "$symlink_module"
symlink_module_created=1
expect_failure "symlinked priority module" --level personal --priority m01-4-symlink

expect_failure "missing required --level" --priority readability
expect_failure "select exactly one project level" \
  --level personal --level personal
expect_failure "unknown or unreadable project level" --level unknown
expect_failure "invalid priority ID" --level personal --priority ../readability
expect_failure "unknown or unreadable priority" --level personal --priority unknown
expect_failure "duplicate priority" \
  --level personal --priority readability --priority readability
expect_failure "unknown or unreadable optional module" \
  --level personal --optional security
expect_failure "duplicate optional module" \
  --level personal --optional security --optional security
expect_failure "unknown argument" --level personal --unexpected
expect_failure "output directory does not exist" \
  --level personal --output "$test_dir/missing/output.md"

expect_failure "unknown or unreadable priority" \
  --level personal --priority unknown --output "$test_dir/partial.md"
[[ ! -e $test_dir/partial.md ]] || fail "failed composition left a partial output file"

printf 'compose-policy: all checks passed\n'
