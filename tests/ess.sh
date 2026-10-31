#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/ess-test.XXXXXX")
test_bin=$test_dir/bin
ess_script=$repo_root/scripts/ess
state_name=.engineering-skillset-state
trap 'rm -rf -- "$test_dir"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

invoke() {
  PATH="$test_bin:$PATH" ess "$@"
}

expect_failure() {
  local expected=$1
  shift
  if invoke "$@" > "$test_dir/stdout" 2> "$test_dir/stderr"; then
    fail "command unexpectedly succeeded: $*"
  fi
  if [[ -n $expected ]]; then
    grep -Fq -- "$expected" "$test_dir/stderr" || {
      cat "$test_dir/stderr" >&2
      fail "expected error '$expected' for: $*"
    }
  fi
}

assert_policy_matches() {
  local preset=$1 target=$2
  cmp -s "$repo_root/dist/$preset/AGENTS.md" "$target/AGENTS.md" || \
    fail "installed policy differs from $preset"
}

assert_skill_links() {
  local preset=$1 target=$2 skill expected
  for skill in software-design implementation-review verification-qa project-handover; do
    expected=$repo_root/dist/$preset/skills/$skill
    [[ -L $target/.agents/skills/$skill ]] || fail "Skill link is missing: $skill"
    [[ $(readlink -- "$target/.agents/skills/$skill") == "$expected" ]] || \
      fail "Skill link has the wrong target: $skill"
  done
}

snapshot_tree() {
  find "$1" -mindepth 1 -printf '%P %y %m %l\n' | sort
}

mkdir -p "$test_bin"
ln -s -- "$ess_script" "$test_bin/ess"

printf 'fast-development\nperformance\npersonal\nproduction\nprototype\nreliable\n' > "$test_dir/expected-presets"
invoke list > "$test_dir/list"
cmp -s "$test_dir/expected-presets" "$test_dir/list" || fail 'list output is incorrect'

# Install from the current directory through a PATH symlink to the real script.
current_target=$test_dir/current-directory-project
mkdir "$current_target"
(
  cd "$current_target"
  invoke install personal
)
assert_policy_matches personal "$current_target"
assert_skill_links personal "$current_target"
[[ $(sed -n '1p' "$current_target/$state_name") == engineering-skillset-state-v1 ]] || \
  fail 'state schema version is incorrect'
grep -Fxq 'preset=personal' "$current_target/$state_name" || fail 'state preset is incorrect'
installed_sha=$(sha256sum "$current_target/AGENTS.md" | cut -c1-64)
grep -Fxq "policy_sha256=$installed_sha" "$current_target/$state_name" || \
  fail 'state policy digest is incorrect'
grep -Fxq 'skills=implementation-review,project-handover,software-design,verification-qa' \
  "$current_target/$state_name" || fail 'state Skill list is incorrect'
invoke status "$current_target" > "$test_dir/healthy-status" || fail 'healthy status failed'
grep -Fq 'Source checkout revision (HEAD):' "$test_dir/healthy-status" || \
  fail 'source revision missing from status'
grep -Fq 'Status: healthy' "$test_dir/healthy-status" || fail 'healthy status was not reported'

# Explicit paths with spaces and the other built presets.
spaced_target="$test_dir/project with spaces"
mkdir "$spaced_target"
invoke install production "$spaced_target" > "$test_dir/production-install"
assert_policy_matches production "$spaced_target"
assert_skill_links production "$spaced_target"

prototype_target=$test_dir/prototype-project
mkdir "$prototype_target"
invoke install prototype "$prototype_target" >/dev/null
assert_policy_matches prototype "$prototype_target"
assert_skill_links prototype "$prototype_target"

for preset in fast-development performance reliable; do
  target=$test_dir/$preset-project
  mkdir "$target"
  invoke install "$preset" "$target" >/dev/null
  assert_policy_matches "$preset" "$target"
  assert_skill_links "$preset" "$target"
  grep -Fxq "preset=$preset" "$target/$state_name" || fail "$preset state was not recorded"
done

printf 'keep\n' > "$current_target/user-file.txt"
make -C "$repo_root" build >/dev/null
installed_presets=(personal production prototype fast-development performance reliable)
installed_targets=(
  "$current_target"
  "$spaced_target"
  "$prototype_target"
  "$test_dir/fast-development-project"
  "$test_dir/performance-project"
  "$test_dir/reliable-project"
)
for index in "${!installed_presets[@]}"; do
  assert_policy_matches "${installed_presets[$index]}" "${installed_targets[$index]}"
  assert_skill_links "${installed_presets[$index]}" "${installed_targets[$index]}"
done
[[ $(cat "$current_target/user-file.txt") == keep ]] || fail 'build changed unrelated project content'

# Repeated installs are idempotent and preserve unrelated project content.
mkdir -p "$current_target/.agents/skills/user-skill"
printf 'user skill\n' > "$current_target/.agents/skills/user-skill/SKILL.md"
policy_stat=$(stat -c '%i:%Y:%a' "$current_target/AGENTS.md")
state_stat=$(stat -c '%i:%Y:%a' "$current_target/$state_name")
invoke install personal "$current_target" > "$test_dir/repeat"
[[ $(stat -c '%i:%Y:%a' "$current_target/AGENTS.md") == "$policy_stat" ]] || fail 'repeat rewrote policy'
[[ $(stat -c '%i:%Y:%a' "$current_target/$state_name") == "$state_stat" ]] || fail 'repeat rewrote state'
[[ $(cat "$current_target/user-file.txt") == keep ]] || fail 'unrelated file changed'
[[ $(cat "$current_target/.agents/skills/user-skill/SKILL.md") == 'user skill' ]] || \
  fail 'unrelated Skill changed'

invoke install production "$current_target" >/dev/null
assert_policy_matches production "$current_target"
assert_skill_links production "$current_target"
[[ -f $current_target/user-file.txt && -d $current_target/.agents/skills/user-skill ]] || \
  fail 'preset switch removed unrelated files'

# Dry-run must leave the target byte-for-byte structurally unchanged.
dry_target=$test_dir/dry-run-project
mkdir "$dry_target"
snapshot_tree "$dry_target" > "$test_dir/dry-before"
invoke install personal "$dry_target" --dry-run > "$test_dir/dry-output"
grep -Fq 'Dry run: no files changed.' "$test_dir/dry-output" || fail 'dry-run message missing'
snapshot_tree "$dry_target" > "$test_dir/dry-after"
cmp -s "$test_dir/dry-before" "$test_dir/dry-after" || fail 'dry-run changed target files'

# New policy and state files honor restrictive umask values.
private_target=$test_dir/private-project
mkdir "$private_target"
(
  umask 0077
  invoke install prototype "$private_target" >/dev/null
)
[[ $(stat -c '%a' "$private_target/AGENTS.md") == 600 ]] || fail 'policy mode ignored umask'
[[ $(stat -c '%a' "$private_target/$state_name") == 600 ]] || fail 'state mode ignored umask'

# Unmanaged policies, files, directories, and broken links are preserved.
unmanaged_policy=$test_dir/unmanaged-policy
mkdir "$unmanaged_policy"
printf 'user policy\n' > "$unmanaged_policy/AGENTS.md"
expect_failure 'without a valid' install personal "$unmanaged_policy"
[[ $(cat "$unmanaged_policy/AGENTS.md") == 'user policy' ]] || fail 'unmanaged policy changed'

unmanaged_skill=$test_dir/unmanaged-skill
mkdir -p "$unmanaged_skill/.agents/skills/software-design"
printf 'user skill\n' > "$unmanaged_skill/.agents/skills/software-design/SKILL.md"
expect_failure 'unmanaged Skill path' install personal "$unmanaged_skill"
[[ -f $unmanaged_skill/.agents/skills/software-design/SKILL.md ]] || fail 'unmanaged Skill changed'

broken_skill=$test_dir/broken-skill-link
mkdir -p "$broken_skill/.agents/skills"
ln -s "$test_dir/does-not-exist" "$broken_skill/.agents/skills/software-design"
expect_failure 'unmanaged Skill path' install personal "$broken_skill"
[[ -L $broken_skill/.agents/skills/software-design ]] || fail 'broken user Skill link was removed'

broken_policy=$test_dir/broken-policy-link
mkdir "$broken_policy"
ln -s "$test_dir/does-not-exist" "$broken_policy/AGENTS.md"
expect_failure 'without a valid' install personal "$broken_policy"
[[ -L $broken_policy/AGENTS.md ]] || fail 'broken user policy link was removed'

# Modified managed policy or links refuse a switch without changing state.
modified_policy=$test_dir/modified-policy
mkdir "$modified_policy"
invoke install personal "$modified_policy" >/dev/null
printf '\nuser edit\n' >> "$modified_policy/AGENTS.md"
cp "$modified_policy/$state_name" "$test_dir/state-before-policy-conflict"
expect_failure 'was modified' install production "$modified_policy"
cmp -s "$test_dir/state-before-policy-conflict" "$modified_policy/$state_name" || \
  fail 'state changed after modified-policy refusal'

modified_link=$test_dir/modified-link
mkdir "$modified_link"
invoke install personal "$modified_link" >/dev/null
rm "$modified_link/.agents/skills/software-design"
ln -s "$test_dir/incorrect-target" "$modified_link/.agents/skills/software-design"
cp "$modified_link/$state_name" "$test_dir/state-before-link-conflict"
expect_failure 'unexpected or broken target' install production "$modified_link"
cmp -s "$test_dir/state-before-link-conflict" "$modified_link/$state_name" || \
  fail 'state changed after modified-link refusal'

# Missing or malformed state cannot grant overwrite authority or execute data.
missing_state=$test_dir/missing-state
mkdir "$missing_state"
cp "$repo_root/dist/personal/AGENTS.md" "$missing_state/AGENTS.md"
expect_failure 'without a valid' install production "$missing_state"

malformed_state=$test_dir/malformed-state
mkdir "$malformed_state"
cp "$repo_root/dist/personal/AGENTS.md" "$malformed_state/AGENTS.md"
# shellcheck disable=SC2016 # The literal command substitution proves state data is never executed.
printf 'engineering-skillset-state-v1\npreset=$(touch %s/executed)\npolicy_sha256=%s\nskills=\n' \
  "$test_dir" "$(sha256sum "$malformed_state/AGENTS.md" | cut -c1-64)" > "$malformed_state/$state_name"
expect_failure 'invalid preset name' install production "$malformed_state"
[[ ! -e $test_dir/executed ]] || fail 'state file content was executed'

nul_state=$test_dir/nul-state
mkdir "$nul_state"
invoke install personal "$nul_state" >/dev/null
cp "$nul_state/AGENTS.md" "$test_dir/nul-policy-before"
cp "$nul_state/$state_name" "$test_dir/valid-state-before-nul"
{
  printf 'engineering-skillset-state-v1\0\n'
  sed -n '2,4p' "$test_dir/valid-state-before-nul"
} > "$nul_state/$state_name"
cp "$nul_state/$state_name" "$test_dir/nul-state-before"
snapshot_tree "$nul_state" > "$test_dir/nul-tree-before"
expect_failure 'state file contains NUL bytes' install production "$nul_state"
cmp -s "$test_dir/nul-policy-before" "$nul_state/AGENTS.md" || \
  fail 'NUL-state refusal changed AGENTS.md'
cmp -s "$test_dir/nul-state-before" "$nul_state/$state_name" || \
  fail 'NUL-state refusal changed the state file'
snapshot_tree "$nul_state" > "$test_dir/nul-tree-after"
cmp -s "$test_dir/nul-tree-before" "$test_dir/nul-tree-after" || \
  fail 'NUL-state refusal changed the target structure'

# Invalid commands, missing builds, and absent targets fail cleanly.
expect_failure 'unknown command' nonsense
expect_failure 'list does not accept arguments' list extra
expect_failure 'install requires PRESET' install
expect_failure 'not built' install missing "$test_dir"
expect_failure 'status accepts at most one PATH' status one two
expect_failure 'target directory does not exist' install personal "$test_dir/no-target"

empty_checkout=$test_dir/empty-checkout
mkdir -p "$empty_checkout/scripts" "$empty_checkout/project"
cp "$ess_script" "$empty_checkout/scripts/ess"
chmod +x "$empty_checkout/scripts/ess"
if "$empty_checkout/scripts/ess" install personal "$empty_checkout/project" \
  > "$test_dir/unavailable-out" 2> "$test_dir/unavailable-err"; then
  fail 'installation succeeded without built artifacts'
fi
grep -Fq 'not built' "$test_dir/unavailable-err" || fail 'missing build was not reported'

# A subset fixture proves a switch removes only a verified managed Skill link.
fixture_checkout=$test_dir/fixture-checkout
mkdir -p "$fixture_checkout/scripts" "$fixture_checkout/dist" "$fixture_checkout/project"
cp "$ess_script" "$fixture_checkout/scripts/ess"
chmod +x "$fixture_checkout/scripts/ess"
cp -a "$repo_root/dist/personal" "$fixture_checkout/dist/"
cp -a "$repo_root/dist/prototype" "$fixture_checkout/dist/"
rm -rf "$fixture_checkout/dist/prototype/skills/project-handover"
"$fixture_checkout/scripts/ess" install personal "$fixture_checkout/project" >/dev/null
"$fixture_checkout/scripts/ess" install prototype "$fixture_checkout/project" > "$test_dir/subset-switch"
[[ ! -e $fixture_checkout/project/.agents/skills/project-handover && \
  ! -L $fixture_checkout/project/.agents/skills/project-handover ]] || \
  fail 'switch did not remove a verified managed Skill link'
grep -Fq 'skills=implementation-review,software-design,verification-qa' \
  "$fixture_checkout/project/$state_name" || fail 'state does not list selected Skills'

# Status reports policy tampering and broken managed links.
if invoke status "$modified_policy" > "$test_dir/inconsistent-policy-status"; then
  fail 'status accepted modified policy'
fi
grep -Fq 'Status: inconsistent' "$test_dir/inconsistent-policy-status" || \
  fail 'status did not report modified policy as inconsistent'

status_bad_link=$test_dir/status-broken-link
mkdir "$status_bad_link"
invoke install personal "$status_bad_link" >/dev/null
rm "$status_bad_link/.agents/skills/verification-qa"
ln -s "$test_dir/missing-skill-target" "$status_bad_link/.agents/skills/verification-qa"
if invoke status "$status_bad_link" > "$test_dir/inconsistent-link-status"; then
  fail 'status accepted broken managed Skill link'
fi
grep -Fq 'Status: inconsistent' "$test_dir/inconsistent-link-status" || \
  fail 'status did not report broken managed Skill link as inconsistent'

printf 'ess: all checks passed\n'
