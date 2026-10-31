#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/build-presets-test.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

presets=(prototype personal production)
skills=(software-design implementation-review verification-qa project-handover)
core_file=$repo_root/AGENTS.md
core_bytes=$(wc -c < "$core_file")
personal_v2_01_sha256=b1ea85616e9dd9931467187192f58df1e8b23dcf77c7a83b05cf373aeefee6f5

for preset in "${presets[@]}"; do
  case $preset in
    prototype) level=Prototype ;;
    personal) level=Personal ;;
    production) level=Production ;;
  esac

  preset_dir=$repo_root/dist/$preset
  policy_file=$preset_dir/AGENTS.md
  [[ -s $policy_file ]] || fail "built policy is missing or empty: $preset"

  "$repo_root/scripts/compose-policy.sh" --level "${level,,}" \
    --priority development-speed --priority readability > "$test_dir/expected-$preset.md"
  cmp -s "$test_dir/expected-$preset.md" "$policy_file" || \
    fail "policy composition differs from composer output: $preset"
  head -c "$core_bytes" "$policy_file" | cmp -s "$core_file" - || \
    fail "Core Policy is not unchanged and first: $preset"
  [[ $(grep -Fxc '# Engineering Skillset Core Policy' "$policy_file") == 1 ]] || \
    fail "Core Policy must appear exactly once: $preset"
  [[ $(grep -Ec '^# (Prototype|Personal|Production)$' "$policy_file") == 1 ]] || \
    fail "policy must contain exactly one project level: $preset"
  grep -Fqx "# $level" "$policy_file" || fail "selected level is missing: $preset"
  case $preset in
    prototype) ! grep -Eq '^# (Personal|Production)$' "$policy_file" || fail 'unselected level included in Prototype' ;;
    personal) ! grep -Eq '^# (Prototype|Production)$' "$policy_file" || fail 'unselected level included in Personal' ;;
    production) ! grep -Eq '^# (Prototype|Personal)$' "$policy_file" || fail 'unselected level included in Production' ;;
  esac

  printf '%s\n' \
    '# Engineering Skillset Core Policy' \
    "# $level" \
    '# Development Speed' \
    '# Readability' > "$test_dir/expected-headings"
  grep -E '^# ' "$policy_file" > "$test_dir/actual-headings"
  cmp -s "$test_dir/expected-headings" "$test_dir/actual-headings" || \
    fail "policy Markdown section structure or priority order is wrong: $preset"

  actual_skill_count=$(find "$preset_dir/skills" -mindepth 2 -maxdepth 2 -type f -name SKILL.md | wc -l)
  [[ $actual_skill_count -eq ${#skills[@]} ]] || \
    fail "wrong number of Skills in preset: $preset"
  for skill in "${skills[@]}"; do
    printf '%s\n' "$skill/SKILL.md"
  done | sort > "$test_dir/expected-skill-paths"
  find "$preset_dir/skills" -type f -printf '%P\n' | sort > "$test_dir/actual-skill-paths"
  cmp -s "$test_dir/expected-skill-paths" "$test_dir/actual-skill-paths" || \
    fail "preset contains missing or unexpected Skill files: $preset"

  for skill in "${skills[@]}"; do
    source_file=$repo_root/.agents/skills/$skill/SKILL.md
    built_file=$preset_dir/skills/$skill/SKILL.md
    [[ -s $built_file ]] || fail "built Skill is missing or empty: $preset/$skill"
    if [[ $preset == prototype && $skill == verification-qa ]]; then
      grep -Fq '## Prototype verification' "$built_file" || \
        fail 'Prototype verification-qa variant was not compiled'
    elif [[ $preset == prototype && $skill == software-design ]]; then
      grep -Fq '## Prototype design' "$built_file" || \
        fail 'Prototype software-design variant was not compiled'
    else
      cmp -s "$source_file" "$built_file" || \
        fail "built Skill differs from unchanged source: $preset/$skill"
    fi
    awk -v expected_name="$skill" '
      NR == 1 && $0 != "---" { exit 1 }
      NR == 2 && $0 != "name: " expected_name { exit 1 }
      NR == 3 && $0 !~ /^description: .+/ { exit 1 }
      NR > 1 && $0 == "---" { closed = 1; exit }
      END { if (!closed) exit 1 }
    ' "$built_file" || fail "invalid Skill frontmatter: $preset/$skill"
  done
done

personal_sha256=$(sha256sum "$repo_root/dist/personal/AGENTS.md" | cut -d' ' -f1)
[[ $personal_sha256 == "$personal_v2_01_sha256" ]] || \
  fail 'Personal policy changed from the V2-01 build output'

for skill in "${skills[@]}"; do
  [[ $skill == verification-qa || $skill == software-design ]] && continue
  for preset in personal production; do
    cmp -s "$repo_root/dist/$preset/skills/$skill/SKILL.md" \
      "$repo_root/dist/prototype/skills/$skill/SKILL.md" || \
      fail "Skill differs across presets: $skill"
  done
done

if make -C "$repo_root" PRESET=invalid build-one > "$test_dir/invalid-out" 2> "$test_dir/invalid-err"; then
  fail 'Make unexpectedly accepted an invalid preset selection'
fi
grep -Fq "unknown preset 'invalid'" "$test_dir/invalid-err" || \
  fail 'Make did not clearly reject an invalid preset selection'

cp -a "$repo_root/dist" "$test_dir/dist-before"
make -C "$repo_root" build >/dev/null
diff -r "$test_dir/dist-before" "$repo_root/dist" >/dev/null || \
  fail 'repeated build changed generated artifact bytes or structure'

printf 'build-presets: all checks passed\n'
