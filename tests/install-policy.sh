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
"$composer" --level personal --priority development-speed \
  --priority readability > "$test_dir/expected.md"
"$installer" --target "$test_dir/empty-target" --level personal \
  --priority readability --priority development-speed > "$test_dir/install.log"
cmp -s "$test_dir/expected.md" "$test_dir/empty-target/AGENTS.md" || \
  fail "installed policy differs from composer output"
[[ -f $test_dir/empty-target/.engineering-skillset-manifest ]] || \
  fail "installation manifest is missing"
[[ $(cat "$test_dir/empty-target/.engineering-skillset-manifest") == \
  $'engineering-skillset-manifest-v1\npolicy_sha256='* ]] || \
  fail "installation manifest is not human-readable"
[[ $(find "$test_dir/empty-target" -mindepth 1 -maxdepth 1 -type f | wc -l) == 2 ]] || \
  fail "installation created unexpected target files"
if compgen -G "$test_dir/empty-target/.engineering-skillset-stage.*" > /dev/null; then
  fail "successful installation left a staging directory"
fi

installed_stat=$(stat -c '%i:%Y:%a' "$test_dir/empty-target/AGENTS.md")
"$installer" --target "$test_dir/empty-target" --level personal \
  --priority development-speed --priority readability > "$test_dir/repeat.log"
[[ $(stat -c '%i:%Y:%a' "$test_dir/empty-target/AGENTS.md") == "$installed_stat" ]] || \
  fail "identical installation rewrote AGENTS.md"
grep -Fq -- 'already current' "$test_dir/repeat.log" || \
  fail "identical installation was not reported as a no-op"

expect_failure "configuration differs" --target "$test_dir/empty-target" \
  --level personal --priority readability
[[ $(stat -c '%i:%Y:%a' "$test_dir/empty-target/AGENTS.md") == "$installed_stat" ]] || \
  fail "configuration mismatch modified AGENTS.md"

before_dry_run=$(stat -c '%i:%Y:%a' "$test_dir/empty-target/AGENTS.md")
"$installer" --target "$test_dir/empty-target" --level personal --dry-run \
  --priority readability --priority development-speed > "$test_dir/repeat-dry-run.log"
[[ $(stat -c '%i:%Y:%a' "$test_dir/empty-target/AGENTS.md") == "$before_dry_run" ]] || \
  fail "repeated dry-run modified AGENTS.md"
grep -Fq -- 'already current' "$test_dir/repeat-dry-run.log" || \
  fail "repeated dry-run did not report current installation"

mkdir "$test_dir/existing-target"
printf 'existing policy\n' > "$test_dir/existing-target/AGENTS.md"
expect_failure "AGENTS.md is unmanaged" \
  --target "$test_dir/existing-target" --level personal
[[ $(cat "$test_dir/existing-target/AGENTS.md") == 'existing policy' ]] || \
  fail "existing policy was modified"

mkdir "$test_dir/manifest-only-target"
printf 'engineering-skillset-manifest-v1\n' > \
  "$test_dir/manifest-only-target/.engineering-skillset-manifest"
expect_failure "manifest exists without AGENTS.md" \
  --target "$test_dir/manifest-only-target" --level personal

mkdir "$test_dir/symlink-manifest-target"
ln -s "$test_dir/symlink-destination" \
  "$test_dir/symlink-manifest-target/.engineering-skillset-manifest"
expect_failure "manifest must not be a symbolic link" \
  --target "$test_dir/symlink-manifest-target" --level personal

mkdir "$test_dir/symlink-target"
printf 'symlink target\n' > "$test_dir/symlink-destination"
ln -s "$test_dir/symlink-destination" "$test_dir/symlink-target/AGENTS.md"
expect_failure "AGENTS.md must not be a symbolic link" \
  --target "$test_dir/symlink-target" --level personal
[[ $(cat "$test_dir/symlink-destination") == 'symlink target' ]] || \
  fail "symlink destination was modified"

mkdir "$test_dir/dry-target" "$test_dir/dry-tmp"
TMPDIR="$test_dir/dry-tmp" "$installer" --target "$test_dir/dry-target" \
  --level personal --priority development-speed --dry-run > "$test_dir/dry-run.log"
grep -Fq -- "$test_dir/dry-target/AGENTS.md" "$test_dir/dry-run.log" || \
  fail "dry-run omitted planned target"
grep -Fq -- 'Configuration: level=personal;priority=development-speed' \
  "$test_dir/dry-run.log" || \
  fail "dry-run omitted configuration"
[[ -z $(find "$test_dir/dry-target" -mindepth 1 -print -quit) ]] || \
  fail "dry-run modified target"
[[ -z $(find "$test_dir/dry-tmp" -mindepth 1 -print -quit) ]] || \
  fail "dry-run left a composer temporary file"

mkdir "$test_dir/invalid-target" "$test_dir/failure-target"
expect_failure "unknown or unreadable priority" \
  --target "$test_dir/invalid-target" --level personal --priority unknown
[[ ! -e $test_dir/invalid-target/AGENTS.md ]] || \
  fail "invalid selection created a policy"
expect_failure "target directory does not exist" \
  --target "$test_dir/missing-target" --level personal

mkdir "$test_dir/real-target"
ln -s "$test_dir/real-target" "$test_dir/target-link"
expect_failure "target directory must not be a symbolic link" \
  --target "$test_dir/target-link" --level personal
expect_failure "target path must not contain a '..' component" \
  --target "$test_dir/real-target/../real-target" --level personal
mkdir -p "$test_dir/real-parent/child"
ln -s "$test_dir/real-parent" "$test_dir/parent-link"
expect_failure "target path must not traverse a symbolic link" \
  --target "$test_dir/parent-link/child" --level personal

mkdir "$test_dir/modified-target"
"$installer" --target "$test_dir/modified-target" --level personal > /dev/null
printf '\nUser edit.\n' >> "$test_dir/modified-target/AGENTS.md"
expect_failure "managed AGENTS.md was modified" \
  --target "$test_dir/modified-target" --level personal
grep -Fq -- 'User edit.' "$test_dir/modified-target/AGENTS.md" || \
  fail "user-modified policy was not preserved"

mkdir "$test_dir/manifest-tamper-target"
"$installer" --target "$test_dir/manifest-tamper-target" --level personal > /dev/null
sed -i 's/^policy_sha256=.*/policy_sha256=bad/' \
  "$test_dir/manifest-tamper-target/.engineering-skillset-manifest"
expect_failure "invalid policy digest" \
  --target "$test_dir/manifest-tamper-target" --level personal

mkdir "$test_dir/fail-bin"
real_ln=$(command -v ln)
cat > "$test_dir/fail-bin/ln" <<'FAIL_LN'
#!/usr/bin/env bash
destination=${!#}
if [[ $destination == */.engineering-skillset-manifest ]]; then
  exit 1
fi
exec "$REAL_LN" "$@"
FAIL_LN
chmod +x "$test_dir/fail-bin/ln"
if PATH="$test_dir/fail-bin:$PATH" REAL_LN="$real_ln" "$installer" \
  --target "$test_dir/failure-target" --level personal \
  > "$test_dir/stdout" 2> "$test_dir/stderr"; then
  fail "simulated installation failure unexpectedly succeeded"
fi
grep -Fq -- "could not publish installation manifest" "$test_dir/stderr" || \
  fail "installation failure was not reported"
[[ ! -e $test_dir/failure-target/AGENTS.md ]] || \
  fail "failed installation published a policy"
[[ -z $(find "$test_dir/failure-target" -mindepth 1 -print -quit) ]] || \
  fail "failed installation did not roll back the policy"

printf 'install-policy: all checks passed\n'
