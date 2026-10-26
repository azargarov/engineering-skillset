#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

test_dir=$(mktemp -d "${TMPDIR:-/tmp}/install-policy-test.XXXXXX")
repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
installer=$repo_root/scripts/install-policy.sh
composer=$repo_root/scripts/compose-policy.sh
test_level=$repo_root/modules/levels/m02-4-test.md
created_test_level=0
if [[ -e $test_level || -L $test_level ]]; then
  printf 'FAIL: temporary test level already exists: %s\n' "$test_level" >&2
  exit 1
fi

cleanup_test() {
  if ((created_test_level)); then
    rm -f -- "$test_level"
  fi
  rm -rf -- "$test_dir"
}
trap cleanup_test EXIT

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

expect_failure "use --reconfigure" --target "$test_dir/empty-target" \
  --level personal --priority readability
[[ $(stat -c '%i:%Y:%a' "$test_dir/empty-target/AGENTS.md") == "$installed_stat" ]] || \
  fail "configuration mismatch modified AGENTS.md"

before_policy=$(sha256sum "$test_dir/empty-target/AGENTS.md")
before_manifest=$(sha256sum "$test_dir/empty-target/.engineering-skillset-manifest")
"$installer" --target "$test_dir/empty-target" --level personal \
  --priority readability --reconfigure --dry-run > "$test_dir/reconfigure-dry-run.log"
grep -Fq -- 'Current configuration: level=personal;priority=development-speed;priority=readability' \
  "$test_dir/reconfigure-dry-run.log" || fail "reconfiguration dry-run omitted current selections"
grep -Fq -- 'Requested configuration: level=personal;priority=readability' \
  "$test_dir/reconfigure-dry-run.log" || fail "reconfiguration dry-run omitted requested selections"
[[ $(sha256sum "$test_dir/empty-target/AGENTS.md") == "$before_policy" && \
  $(sha256sum "$test_dir/empty-target/.engineering-skillset-manifest") == "$before_manifest" ]] || \
  fail "reconfiguration dry-run modified managed files"

"$composer" --level personal --priority readability > "$test_dir/reconfigured-expected.md"
"$installer" --target "$test_dir/empty-target" --level personal \
  --priority readability --reconfigure > "$test_dir/reconfigure.log"
cmp -s "$test_dir/reconfigured-expected.md" "$test_dir/empty-target/AGENTS.md" || \
  fail "reconfigured policy differs from composer output"
grep -Fq -- 'configuration=level=personal;priority=readability' \
  "$test_dir/empty-target/.engineering-skillset-manifest" || \
  fail "reconfiguration did not update manifest selections"
if compgen -G "$test_dir/empty-target/.engineering-skillset-stage.*" > /dev/null; then
  fail "successful reconfiguration left a staging directory"
fi
reconfigured_stat=$(stat -c '%i:%Y:%a' "$test_dir/empty-target/AGENTS.md")
"$installer" --target "$test_dir/empty-target" --level personal \
  --priority readability > "$test_dir/repeat-changed-config.log"
"$installer" --target "$test_dir/empty-target" --level personal \
  --priority readability --reconfigure > "$test_dir/repeat-authorized.log"
[[ $(stat -c '%i:%Y:%a' "$test_dir/empty-target/AGENTS.md") == "$reconfigured_stat" ]] || \
  fail "identical reconfiguration rewrote AGENTS.md"
grep -Fq -- 'already current' "$test_dir/repeat-changed-config.log" || \
  fail "identical config without --reconfigure was not a no-op"
grep -Fq -- 'already current' "$test_dir/repeat-authorized.log" || \
  fail "identical config with --reconfigure was not a no-op"

printf '# M02.4 test level\n\nTemporary project-level fixture.\n' > "$test_level"
created_test_level=1
"$composer" --level m02-4-test --priority readability > "$test_dir/level-expected.md"
"$installer" --target "$test_dir/empty-target" --level m02-4-test \
  --priority readability --reconfigure > "$test_dir/level-reconfigure.log"
cmp -s "$test_dir/level-expected.md" "$test_dir/empty-target/AGENTS.md" || \
  fail "project-level reconfiguration differs from composer output"
grep -Fq -- 'configuration=level=m02-4-test;priority=readability' \
  "$test_dir/empty-target/.engineering-skillset-manifest" || \
  fail "project-level reconfiguration did not update manifest"

before_dry_run=$(stat -c '%i:%Y:%a' "$test_dir/empty-target/AGENTS.md")
"$installer" --target "$test_dir/empty-target" --level m02-4-test --dry-run \
  --priority readability > "$test_dir/repeat-dry-run.log"
[[ $(stat -c '%i:%Y:%a' "$test_dir/empty-target/AGENTS.md") == "$before_dry_run" ]] || \
  fail "repeated dry-run modified AGENTS.md"
grep -Fq -- 'already current' "$test_dir/repeat-dry-run.log" || \
  fail "repeated dry-run did not report current installation"

mkdir "$test_dir/existing-target"
printf 'existing policy\n' > "$test_dir/existing-target/AGENTS.md"
expect_failure "AGENTS.md is unmanaged" \
  --target "$test_dir/existing-target" --level personal --reconfigure
[[ $(cat "$test_dir/existing-target/AGENTS.md") == 'existing policy' ]] || \
  fail "existing policy was modified"

mkdir "$test_dir/manifest-only-target"
printf 'engineering-skillset-manifest-v1\n' > \
  "$test_dir/manifest-only-target/.engineering-skillset-manifest"
expect_failure "manifest exists without AGENTS.md" \
  --target "$test_dir/manifest-only-target" --level personal --reconfigure

mkdir "$test_dir/symlink-manifest-target"
ln -s "$test_dir/symlink-destination" \
  "$test_dir/symlink-manifest-target/.engineering-skillset-manifest"
expect_failure "manifest must not be a symbolic link" \
  --target "$test_dir/symlink-manifest-target" --level personal --reconfigure

mkdir "$test_dir/symlink-target"
printf 'symlink target\n' > "$test_dir/symlink-destination"
ln -s "$test_dir/symlink-destination" "$test_dir/symlink-target/AGENTS.md"
expect_failure "AGENTS.md must not be a symbolic link" \
  --target "$test_dir/symlink-target" --level personal --reconfigure
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
  --target "$test_dir/modified-target" --level personal --reconfigure
grep -Fq -- 'User edit.' "$test_dir/modified-target/AGENTS.md" || \
  fail "user-modified policy was not preserved"

mkdir "$test_dir/manifest-tamper-target"
"$installer" --target "$test_dir/manifest-tamper-target" --level personal > /dev/null
sed -i 's/^policy_sha256=.*/policy_sha256=bad/' \
  "$test_dir/manifest-tamper-target/.engineering-skillset-manifest"
expect_failure "invalid policy digest" \
  --target "$test_dir/manifest-tamper-target" --level personal --reconfigure

mkdir "$test_dir/malformed-config-target"
"$installer" --target "$test_dir/malformed-config-target" --level personal > /dev/null
sed -i 's/^configuration=.*/configuration=not-a-valid-config/' \
  "$test_dir/malformed-config-target/.engineering-skillset-manifest"
expect_failure "invalid configuration" \
  --target "$test_dir/malformed-config-target" --level personal --reconfigure

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

for failed_destination in AGENTS.md .engineering-skillset-manifest; do
  rollback_target=$test_dir/rollback-${failed_destination//[^A-Za-z]/}
  mkdir "$rollback_target"
  "$installer" --target "$rollback_target" --level personal \
    --priority development-speed > /dev/null
  old_policy=$(sha256sum "$rollback_target/AGENTS.md")
  old_manifest=$(sha256sum "$rollback_target/.engineering-skillset-manifest")
  real_mv=$(command -v mv)
  mkdir -p "$test_dir/mv-bin"
  cat > "$test_dir/mv-bin/mv" <<'FAIL_MV'
#!/usr/bin/env bash
destination=${!#}
if [[ $destination == */$FAIL_MV_DESTINATION ]]; then
  exit 1
fi
exec "$REAL_MV" "$@"
FAIL_MV
  chmod +x "$test_dir/mv-bin/mv"
  if PATH="$test_dir/mv-bin:$PATH" REAL_MV="$real_mv" \
    FAIL_MV_DESTINATION="$failed_destination" "$installer" \
    --target "$rollback_target" --level personal --priority readability \
    --reconfigure > "$test_dir/stdout" 2> "$test_dir/stderr"; then
    fail "simulated reconfiguration publication failure unexpectedly succeeded for $failed_destination"
  fi
  grep -Fq -- 'could not publish replacement' "$test_dir/stderr" || \
    { cat "$test_dir/stderr" >&2; fail "reconfiguration publication failure was not reported for $failed_destination"; }
  [[ $(sha256sum "$rollback_target/AGENTS.md") == "$old_policy" && \
    $(sha256sum "$rollback_target/.engineering-skillset-manifest") == "$old_manifest" ]] || \
    fail "failed reconfiguration did not restore managed files for $failed_destination"
  [[ -z $(find "$rollback_target" -mindepth 1 -name '.engineering-skillset-stage.*' -print -quit) ]] || \
    fail "failed reconfiguration left staging artifacts for $failed_destination"
done

printf 'install-policy: all checks passed\n'
