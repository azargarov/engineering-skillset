#!/usr/bin/env bash

set -euo pipefail

repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/build-modular-presets.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT

fail() {
  printf 'build-modular-presets: %s\n' "$*" >&2
  exit 1
}

presets=(prototype fast-development performance reliable)
skills=(software-design implementation-review verification-qa project-handover)
priorities=("readability development-speed" "readability development-speed" readability readability)

for index in "${!presets[@]}"; do
  preset=${presets[$index]}
  preset_dir=$repo_root/dist/$preset
  [[ -s $preset_dir/AGENTS.md ]] || fail "$preset AGENTS.md is missing or empty"
  read -r -a selected_priorities <<< "${priorities[$index]}"
  args=(--level "$preset" --optional model-delegation)
  for priority in "${selected_priorities[@]}"; do args+=(--priority "$priority"); done
  "$repo_root/scripts/compose-policy.sh" "${args[@]}" > "$test_dir/expected-$preset.md"
  cmp -s "$test_dir/expected-$preset.md" "$preset_dir/AGENTS.md" || \
    fail "$preset AGENTS.md does not match its configured Core, level, and priorities"
  [[ $(grep -Fxc '# Engineering Skillset Core Policy' "$preset_dir/AGENTS.md") == 1 ]] || \
    fail "$preset Core Policy is missing or duplicated"
  for requirement in \
    '## Project memory' \
    'VISION.md' 'ROADMAP.md' 'current.md' 'milestones/' 'decisions/' 'errors/' \
    'explicit owner approval' 'next authorized incomplete milestone' \
    'owner-accepted only after explicit owner acceptance'; do
    grep -Fq "$requirement" "$preset_dir/AGENTS.md" || \
      fail "$preset Core Policy is missing project-memory requirement: $requirement"
  done
  grep -Fq 'Before distributing implementation work, the lead establishes a proportional' "$preset_dir/AGENTS.md" || \
    fail "$preset delegation module is missing"
  grep -Fq 'Final QA checks the complete result against requirements' "$preset_dir/AGENTS.md" || \
    fail "$preset delegation QA requirements are missing"

  actual_skill_count=$(find "$preset_dir/skills" -mindepth 2 -maxdepth 2 -type f -name SKILL.md | wc -l)
  [[ $actual_skill_count -eq ${#skills[@]} ]] || fail "$preset has an incomplete workflow Skill set"
  for skill in "${skills[@]}"; do
    [[ -s $preset_dir/skills/$skill/SKILL.md ]] || fail "$preset/$skill is missing or empty"
    awk -v expected_name="$skill" '
      NR == 1 && $0 != "---" { exit 1 }
      NR == 2 && $0 != "name: " expected_name { exit 1 }
      NR == 3 && $0 !~ /^description: .+/ { exit 1 }
      NR > 1 && $0 == "---" { closed = 1; exit }
      END { if (!closed) exit 1 }
    ' "$preset_dir/skills/$skill/SKILL.md" || fail "$preset/$skill has invalid frontmatter"
  done
done

for preset in prototype fast-development performance reliable; do
  grep -Fq 'does not defer or replace required memory updates' \
    "$repo_root/dist/$preset/skills/project-handover/SKILL.md" || \
    fail "$preset/project-handover conflicts with Core Policy memory obligations"
  for skill in implementation-review project-handover; do
    cmp -s "$repo_root/.agents/skills/$skill/SKILL.md" \
      "$repo_root/dist/$preset/skills/$skill/SKILL.md" || \
      fail "$preset/$skill should reuse its unchanged source Skill"
  done
done

hashes_before=$(find "$repo_root/dist/prototype" "$repo_root/dist/fast-development" \
  "$repo_root/dist/performance" "$repo_root/dist/reliable" -type f -print0 |
  sort -z | xargs -0 sha256sum)
make -C "$repo_root" build >/dev/null
hashes_after=$(find "$repo_root/dist/prototype" "$repo_root/dist/fast-development" \
  "$repo_root/dist/performance" "$repo_root/dist/reliable" -type f -print0 |
  sort -z | xargs -0 sha256sum)
[[ $hashes_after == "$hashes_before" ]] || fail 'repeated build changed one or more new preset artifacts'

printf 'Complete modular preset checks passed.\n'
