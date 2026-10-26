#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

test_dir=$(mktemp -d "${TMPDIR:-/tmp}/install-policy-test.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT

repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
installer=$repo_root/scripts/install-policy.sh
composer=$repo_root/scripts/compose-policy.sh

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

expect_failure() {
  local expected=$1
  shift
  if "$installer" "$@" > "$test_dir/stdout" 2> "$test_dir/stderr"; then
    fail "command unexpectedly succeeded: $*"
  fi
  [[ ! -s $test_dir/stdout ]] || fail "failed command wrote partial stdout: $*"
  grep -Fq -- "$expected" "$test_dir/stderr" || {
    cat "$test_dir/stderr" >&2
    fail "expected error '$expected' for: $*"
  }
}

"$installer" --help > "$test_dir/help"
grep -Fq -- '--target DIR' "$test_dir/help" || fail "help omits target usage"

mkdir "$test_dir/empty-target"
"$composer" --level personal --priority readability > "$test_dir/expected.md"
"$installer" --target "$test_dir/empty-target" --level personal \
  --priority readability > "$test_dir/install.log"
cmp -s "$test_dir/expected.md" "$test_dir/empty-target/AGENTS.md" || \
  fail "installed policy differs from composer output"
[[ $(find "$test_dir/empty-target" -mindepth 1 -maxdepth 1 -printf '%f\n') == AGENTS.md ]] || \
  fail "installation created unexpected target files"
if compgen -G "$test_dir/empty-target/.engineering-policy.*" > /dev/null; then
  fail "successful installation left a temporary file"
fi

mkdir "$test_dir/existing-target"
printf 'existing policy\n' > "$test_dir/existing-target/AGENTS.md"
expect_failure "refusing to overwrite existing path" \
  --target "$test_dir/existing-target" --level personal
[[ $(cat "$test_dir/existing-target/AGENTS.md") == 'existing policy' ]] || \
  fail "existing policy was modified"

mkdir "$test_dir/symlink-target"
printf 'symlink target\n' > "$test_dir/symlink-destination"
ln -s "$test_dir/symlink-destination" "$test_dir/symlink-target/AGENTS.md"
expect_failure "refusing to overwrite existing path" \
  --target "$test_dir/symlink-target" --level personal
[[ $(cat "$test_dir/symlink-destination") == 'symlink target' ]] || \
  fail "symlink destination was modified"

mkdir "$test_dir/dry-target" "$test_dir/dry-tmp"
TMPDIR="$test_dir/dry-tmp" "$installer" --target "$test_dir/dry-target" \
  --level personal --priority development-speed --dry-run > "$test_dir/dry-run.log"
grep -Fq -- "$test_dir/dry-target/AGENTS.md" "$test_dir/dry-run.log" || \
  fail "dry-run omitted planned target"
grep -Fq -- '--priority development-speed' "$test_dir/dry-run.log" || \
  fail "dry-run omitted configuration"
[[ ! -e $test_dir/dry-target/AGENTS.md ]] || fail "dry-run modified target"
[[ -z $(find "$test_dir/dry-tmp" -mindepth 1 -print -quit) ]] || \
  fail "dry-run left a composer temporary file"

mkdir "$test_dir/invalid-target" "$test_dir/failure-target"
expect_failure "unknown or unreadable priority" \
  --target "$test_dir/invalid-target" --level personal --priority unknown
[[ ! -e $test_dir/invalid-target/AGENTS.md ]] || \
  fail "invalid selection created a policy"
expect_failure "target directory does not exist" \
  --target "$test_dir/missing-target" --level personal

mkdir "$test_dir/fail-bin"
cat > "$test_dir/fail-bin/ln" <<'FAIL_LN'
#!/usr/bin/env bash
exit 1
FAIL_LN
chmod +x "$test_dir/fail-bin/ln"
if PATH="$test_dir/fail-bin:$PATH" "$installer" \
  --target "$test_dir/failure-target" --level personal \
  > "$test_dir/stdout" 2> "$test_dir/stderr"; then
  fail "simulated installation failure unexpectedly succeeded"
fi
grep -Fq -- "could not create output" "$test_dir/stderr" || \
  fail "installation failure was not reported"
[[ ! -e $test_dir/failure-target/AGENTS.md ]] || \
  fail "failed installation published a policy"
if compgen -G "$test_dir/failure-target/.engineering-policy.*" > /dev/null; then
  fail "failed installation left a temporary file"
fi

printf 'install-policy: all checks passed\n'
