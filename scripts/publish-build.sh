#!/usr/bin/env bash

set -euo pipefail

program=${0##*/}
published_count=0

fail() {
  if ((published_count > 0)); then
    printf '%s: publication stopped after %d files; outputs may contain mixed generations: %s\n' \
      "$program" "$published_count" "$*" >&2
  else
    printf '%s: %s\n' "$program" "$*" >&2
  fi
  exit 2
}

(($# >= 3)) || fail 'usage: publish-build.sh STAGED_ROOT PUBLISHED_ROOT PRESET...'
staged_root=$1
published_root=$2
shift 2
presets=("$@")
skills=(software-design implementation-review verification-qa project-handover)

valid_id() {
  [[ $1 =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

[[ -d $staged_root && ! -L $staged_root ]] || fail "staged build is missing or invalid: '$staged_root'"
((${#presets[@]} > 0)) || fail 'no presets were supplied'

for preset in "${presets[@]}"; do
  valid_id "$preset" || fail "invalid preset name '$preset'"
done

mapfile -t staged_entries < <(find "$staged_root" -mindepth 1 -maxdepth 1 -printf '%f\n' | LC_ALL=C sort)
expected_entries=$(printf '%s\n' "${presets[@]}" config | LC_ALL=C sort)
actual_entries=$(printf '%s\n' "${staged_entries[@]}")
[[ $actual_entries == "$expected_entries" ]] || fail 'staged entries do not match the requested build and config template'
[[ -d $staged_root/config && ! -L $staged_root/config && \
  -f $staged_root/config/model-preferences.md.example && ! -L $staged_root/config/model-preferences.md.example && \
  -r $staged_root/config/model-preferences.md.example ]] || fail 'missing or invalid model preferences template'
mapfile -t config_entries < <(find "$staged_root/config" -mindepth 1 -maxdepth 1 -printf '%f\n')
[[ ${#config_entries[@]} == 1 && ${config_entries[0]} == model-preferences.md.example ]] || \
  fail 'staged config directory contains unexpected files'

for preset in "${presets[@]}"; do
  preset_dir=$staged_root/$preset
  agents_file=$preset_dir/AGENTS.md
  skills_dir=$preset_dir/skills
  delegation_dir=$preset_dir/delegation
  [[ -d $preset_dir && ! -L $preset_dir ]] || fail "invalid staged preset directory: '$preset_dir'"
  [[ -f $agents_file && ! -L $agents_file && -r $agents_file ]] || fail "missing or unreadable AGENTS.md for '$preset'"
  [[ $(grep -Fxc '# Engineering Skillset Core Policy' "$agents_file") == 1 ]] || \
    fail "Core Policy must appear exactly once in '$agents_file'"
  [[ -d $skills_dir && ! -L $skills_dir ]] || fail "missing or invalid Skills directory for '$preset'"
  [[ -d $delegation_dir && ! -L $delegation_dir && -f $delegation_dir/AGENTS.md && ! -L $delegation_dir/AGENTS.md && -r $delegation_dir/AGENTS.md ]] || fail "missing or invalid delegation policy for '$preset'"

  mapfile -t staged_skills < <(find "$skills_dir" -mindepth 1 -maxdepth 1 -printf '%f\n' | LC_ALL=C sort)
  expected_skills=$(printf '%s\n' "${skills[@]}" | LC_ALL=C sort)
  actual_skills=$(printf '%s\n' "${staged_skills[@]}")
  [[ $actual_skills == "$expected_skills" ]] || fail "staged Skill set is incomplete or unexpected for '$preset'"

  for skill in "${skills[@]}"; do
    skill_dir=$skills_dir/$skill
    skill_file=$skill_dir/SKILL.md
    [[ -d $skill_dir && ! -L $skill_dir ]] || fail "invalid staged Skill directory: '$skill_dir'"
    [[ -f $skill_file && ! -L $skill_file && -r $skill_file ]] || fail "missing or unreadable Skill '$preset/$skill'"
    mapfile -t skill_entries < <(find "$skill_dir" -mindepth 1 -maxdepth 1 -printf '%f\n')
    [[ ${#skill_entries[@]} == 1 && ${skill_entries[0]} == SKILL.md ]] || \
      fail "unexpected files in staged Skill '$preset/$skill'"
    awk -v expected_name="$skill" '
      NR == 1 && $0 != "---" { exit 1 }
      NR == 2 && $0 != "name: " expected_name { exit 1 }
      NR == 3 && $0 !~ /^description: .+/ { exit 1 }
      NR == 4 && $0 != "---" { exit 1 }
      NR == 4 { closed = 1; exit }
      END { if (!closed) exit 1 }
    ' "$skill_file" || fail "invalid Skill frontmatter in '$preset/$skill'"
    if grep -Fq 'modules/skills/' "$skill_file"; then
      fail "unresolved module reference in '$preset/$skill'"
    fi
  done

  mapfile -t preset_entries < <(find "$preset_dir" -mindepth 1 -maxdepth 1 -printf '%f\n' | LC_ALL=C sort)
  [[ ${preset_entries[*]} == 'AGENTS.md delegation skills' ]] || fail "unexpected staged files in preset '$preset'"
  [[ -d $delegation_dir/skills/opencode-delegation && ! -L $delegation_dir/skills/opencode-delegation && -f $delegation_dir/skills/opencode-delegation/SKILL.md && ! -L $delegation_dir/skills/opencode-delegation/SKILL.md && -r $delegation_dir/skills/opencode-delegation/SKILL.md ]] || fail "missing OpenCode delegation Skill for '$preset'"
  awk '
    NR == 1 && $0 != "---" { exit 1 }
    NR == 2 && $0 != "name: opencode-delegation" { exit 1 }
    NR == 3 && $0 !~ /^description: .+/ { exit 1 }
    NR == 4 && $0 != "---" { exit 1 }
    NR == 4 { closed = 1; exit }
    END { if (!closed) exit 1 }
  ' "$delegation_dir/skills/opencode-delegation/SKILL.md" || fail "invalid Skill frontmatter in '$preset/opencode-delegation'"
done

check_directory() {
  local path=$1
  if [[ -e $path || -L $path ]]; then
    [[ -d $path && ! -L $path ]] || fail "published path is not a regular directory: '$path'"
  fi
}

check_file() {
  local path=$1
  if [[ -e $path || -L $path ]]; then
    [[ -f $path && ! -L $path ]] || fail "published artifact is not a regular file: '$path'"
  fi
}

check_directory "$published_root"
check_directory "$published_root/config"
check_file "$published_root/config/model-preferences.md.example"
for preset in "${presets[@]}"; do
  check_directory "$published_root/$preset"
  check_directory "$published_root/$preset/skills"
  check_directory "$published_root/$preset/delegation"
  check_file "$published_root/$preset/delegation/AGENTS.md"
  check_directory "$published_root/$preset/delegation/skills"
  check_directory "$published_root/$preset/delegation/skills/opencode-delegation"
  check_file "$published_root/$preset/delegation/skills/opencode-delegation/SKILL.md"
  check_file "$published_root/$preset/AGENTS.md"
  for skill in "${skills[@]}"; do
    check_directory "$published_root/$preset/skills/$skill"
    check_file "$published_root/$preset/skills/$skill/SKILL.md"
  done
done

if [[ -e $published_root || -L $published_root ]]; then
  [[ -d $published_root && ! -L $published_root ]] || fail "published root is not a regular directory: '$published_root'"
else
  mkdir -p -- "$published_root" || fail "cannot create published root '$published_root'"
fi

publish_file() {
  local source=$1 relative=$2 target target_dir temp_file
  target=$published_root/$relative
  target_dir=${target%/*}
  mkdir -p -- "$target_dir" || fail "cannot create published directory '$target_dir'"
  temp_file=$(mktemp "$target_dir/.publish.XXXXXX") || fail "cannot create a temporary file in '$target_dir'"
  if ! cat -- "$source" > "$temp_file"; then
    rm -f -- "$temp_file"
    fail "cannot stage published artifact '$relative'"
  fi
  if ! chmod --reference="$source" -- "$temp_file"; then
    rm -f -- "$temp_file"
    fail "cannot preserve permissions for '$relative'"
  fi
  if ! mv -fT -- "$temp_file" "$target"; then
    rm -f -- "$temp_file"
    fail "cannot atomically publish '$relative'"
  fi
  published_count=$((published_count + 1))
}

while IFS= read -r -d '' source; do
  relative=${source#"$staged_root"/}
  publish_file "$source" "$relative"
done < <(find "$staged_root" -type f -print0 | LC_ALL=C sort -z)
