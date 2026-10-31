#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/build-personal-test.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

dist_dir=$repo_root/dist/personal
expected_skills=(software-design implementation-review verification-qa project-handover)

[[ -s $dist_dir/AGENTS.md ]] || fail 'Personal AGENTS.md is missing or empty'
"$repo_root/scripts/compose-policy.sh" --level personal \
  --priority development-speed --priority readability > "$test_dir/expected-AGENTS.md"
cmp -s "$test_dir/expected-AGENTS.md" "$dist_dir/AGENTS.md" || \
  fail 'Personal policy differs from the supported composer output'
[[ $(grep -Fxc '# Engineering Skillset Core Policy' "$dist_dir/AGENTS.md") == 1 ]] || \
  fail 'Core Policy must appear exactly once in the preset policy'

for skill in "${expected_skills[@]}"; do
  source_file=$repo_root/.agents/skills/$skill/SKILL.md
  built_file=$dist_dir/skills/$skill/SKILL.md
  [[ -s $built_file ]] || fail "built Skill is missing or empty: $skill"
  cmp -s "$source_file" "$built_file" || fail "built Skill changed from source: $skill"
  awk -v expected_name="$skill" '
    NR == 1 && $0 != "---" { exit 1 }
    NR == 2 && $0 != "name: " expected_name { exit 1 }
    NR == 3 && $0 !~ /^description: .+/ { exit 1 }
    NR > 1 && $0 == "---" { closed = 1; exit }
    END { if (!closed) exit 1 }
  ' "$built_file" || fail "invalid standalone Skill frontmatter: $skill"
done

actual_count=$(find "$dist_dir/skills" -mindepth 2 -maxdepth 2 -type f -name SKILL.md | wc -l)
[[ $actual_count -eq ${#expected_skills[@]} ]] || \
  fail "expected ${#expected_skills[@]} built Skills, found $actual_count"

cp -a "$repo_root/dist" "$test_dir/dist-before"
make -C "$repo_root" build >/dev/null
diff -r "$test_dir/dist-before" "$repo_root/dist" >/dev/null || \
  fail 'repeated build changed generated artifact bytes or structure'

printf 'build-personal: all checks passed\n'
