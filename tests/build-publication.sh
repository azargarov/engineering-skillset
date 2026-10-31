#!/usr/bin/env bash

set -euo pipefail

repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/build-publication.XXXXXX")
published_root=$test_dir/published
project_dir=$test_dir/project
trap 'rm -rf -- "$test_dir"' EXIT

fail() {
  printf 'build-publication: %s\n' "$*" >&2
  exit 1
}

snapshot_published() {
  (cd "$published_root" && find . -type f -print0 | LC_ALL=C sort -z | xargs -0 sha256sum && find . -type f -printf '%m %p\n' | LC_ALL=C sort)
}

assert_no_stage_leftovers() {
  shopt -s nullglob
  local leftovers=("$test_dir"/.published.stage.*)
  [[ ${#leftovers[@]} == 0 ]] || fail 'staging directory was left behind'
}

assert_preset_trees_match() {
  local preset
  for preset in prototype personal production fast-development performance reliable; do
    diff -r -- "$repo_root/dist/$preset" "$published_root/$preset" >/dev/null || \
      fail "published output for '$preset' does not match the complete intended build"
  done
}

make -C "$repo_root" "DIST_ROOT=$published_root" build >/dev/null
file_umask=$(umask)
expected_mode=$(printf '%o' "$((0666 & ~8#$file_umask))")
published_mode=$(stat -c '%a' "$published_root/prototype/skills/verification-qa/SKILL.md")
[[ $published_mode == "$expected_mode" ]] || fail "published Skill mode $published_mode does not respect umask $file_umask"

mkdir -p "$project_dir/.agents/skills"
printf 'user-owned project note\n' > "$project_dir/notes.txt"
printf 'unrelated published-root file\n' > "$published_root/user-note.txt"
link_path=$project_dir/.agents/skills/verification-qa
link_target=$published_root/prototype/skills/verification-qa
ln -s "$link_target" "$link_path"
[[ -r $link_path/SKILL.md ]] || fail 'initial Skill link is not readable'
link_before=$(readlink -- "$link_path")

# Publish changed Skill content while keeping the existing project link target.
make -C "$repo_root" "DIST_ROOT=$published_root" \
  'SKILL_DESCRIPTION_verification-qa=Publication rebuild test description.' build >/dev/null
[[ -L $link_path && $(readlink -- "$link_path") == "$link_before" ]] || \
  fail 'successful rebuild replaced the project Skill link'
grep -Fq 'Publication rebuild test description.' "$link_path/SKILL.md" || \
  fail 'existing project link did not observe the newly published Skill'
[[ $(cat "$project_dir/notes.txt") == 'user-owned project note' ]] || fail 'unrelated project file changed'
[[ $(cat "$published_root/user-note.txt") == 'unrelated published-root file' ]] || fail 'unrelated published-root file changed'
assert_no_stage_leftovers

# Fail a publisher rename after multiple files, then rebuild and confirm recovery.
bin_dir=$test_dir/bin
mkdir -p "$bin_dir"
real_mv=$(command -v mv)
cat > "$bin_dir/mv" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ " $* " == *'/.publish.'* ]]; then
  count_file=$MV_COUNT_FILE
  count=0
  [[ ! -f $count_file ]] || read -r count < "$count_file"
  count=$((count + 1))
  printf '%s\n' "$count" > "$count_file"
  if [[ $count == "$MV_FAIL_AT" ]]; then
    printf 'injected publication rename failure at file %s\n' "$count" >&2
    exit 1
  fi
fi
exec "$REAL_MV" "$@"
EOF
chmod +x "$bin_dir/mv"
if output=$(PATH="$bin_dir:$PATH" REAL_MV="$real_mv" MV_COUNT_FILE="$test_dir/mv-count" MV_FAIL_AT=26 \
  make -C "$repo_root" "DIST_ROOT=$published_root" \
    'SKILL_DESCRIPTION_verification-qa=Interrupted publication test description.' build 2>&1); then
  fail 'injected partial publication unexpectedly succeeded'
fi
[[ $output == *'injected publication rename failure at file 26'* ]] || \
  fail "injected publication failure did not occur: $output"
[[ $output == *'publication stopped after 25 files; outputs may contain mixed generations'* ]] || \
  fail "partial publication was not reported clearly: $output"
[[ $output != *'Build complete'* ]] || fail 'failed publication claimed success'
[[ -r $link_path/SKILL.md ]] || fail 'partial publication broke an existing Skill link'
grep -Fq 'Interrupted publication test description.' "$link_path/SKILL.md" || \
  fail 'injected failure did not occur after a published file changed'

make -C "$repo_root" "DIST_ROOT=$published_root" build >/dev/null
assert_preset_trees_match
[[ -r $link_path/SKILL.md ]] || fail 'recovery build broke an existing Skill link'
if grep -Fq 'Interrupted publication test description.' "$link_path/SKILL.md"; then
  fail 'recovery build retained content from the interrupted generation'
fi
[[ $(cat "$published_root/user-note.txt") == 'unrelated published-root file' ]] || \
  fail 'recovery build changed unrelated published-root data'
assert_no_stage_leftovers

before=$(snapshot_published)
if output=$(make -C "$repo_root" "DIST_ROOT=$published_root" \
  MODULES_verification-qa_prototype=modules/skills/verification-qa/missing.md build 2>&1); then
  fail 'build with a missing module unexpectedly succeeded'
fi
[[ $output == *'missing or unreadable verification-qa module: modules/skills/verification-qa/missing.md'* ]] || \
  fail "missing-module error was unclear: $output"
[[ $(snapshot_published) == "$before" ]] || fail 'compile failure changed published outputs'
[[ -r $link_path/SKILL.md ]] || fail 'compile failure broke an existing Skill link'
assert_no_stage_leftovers

if output=$(make -C "$repo_root" "DIST_ROOT=$published_root" MODULAR_PRESETS=unknown build 2>&1); then
  fail 'build with an invalid preset selection unexpectedly succeeded'
fi
[[ $output == *'no module files configured for software-design / unknown'* ]] || \
  fail "invalid-configuration error was unclear: $output"
[[ $(snapshot_published) == "$before" ]] || fail 'invalid configuration changed published outputs'
assert_no_stage_leftovers

invalid_source=$test_dir/invalid-skill.md
printf '# Missing frontmatter\n\nInvalid fixture.\n' > "$invalid_source"
if output=$(make -C "$repo_root" "DIST_ROOT=$published_root" \
  "SKILL_SOURCE_project-handover=$invalid_source" build 2>&1); then
  fail 'build with invalid Skill frontmatter unexpectedly succeeded'
fi
[[ $output == *"invalid Skill frontmatter in 'prototype/project-handover'"* ]] || \
  fail "validation error was unclear: $output"
[[ $(snapshot_published) == "$before" ]] || fail 'validation failure changed published outputs'
[[ -r $link_path/SKILL.md ]] || fail 'validation failure broke an existing Skill link'
[[ $(cat "$project_dir/notes.txt") == 'user-owned project note' ]] || fail 'validation failure changed unrelated project data'
assert_no_stage_leftovers

printf 'Build publication checks passed.\n'
