#!/usr/bin/env bash

set -euo pipefail

fail() {
  printf 'build-modular-skills: %s\n' "$*" >&2
  exit 1
}

python3 - <<'PY'
from pathlib import Path

presets = ("prototype", "fast-development", "performance", "reliable")
descriptions = {
    "software-design": "Use when the user requests software design or implementation needs nontrivial architecture or interface decisions; define responsibilities, boundaries, trade-offs, and implementation steps. Keep routine localized changes lightweight.",
    "verification-qa": "Use when planning substantial verification or assessing whether checks establish required behavior; select and assess checks appropriate to the active preset and task risks. Routine checks can follow project instructions without this workflow.",
}
titles = {"software-design": "Software Design", "verification-qa": "Verification QA"}
module_lists = {
    ("software-design", "prototype"): ("common.md", "prototype.md"),
    ("software-design", "fast-development"): ("common.md", "fast-development.md"),
    ("software-design", "performance"): ("common.md", "performance.md"),
    ("software-design", "reliable"): ("common.md", "reliable.md"),
    ("verification-qa", "prototype"): ("common.md", "smoke.md"),
    ("verification-qa", "fast-development"): ("common.md", "essential.md"),
    ("verification-qa", "performance"): ("common.md", "performance.md"),
    ("verification-qa", "reliable"): ("common.md", "comprehensive.md"),
}
copied_skills = ("implementation-review", "project-handover")
compiled = {}
for preset in presets:
    for skill in (*descriptions, *copied_skills):
        artifact_path = Path(f"dist/{preset}/skills/{skill}/SKILL.md")
        if not artifact_path.is_file():
            raise SystemExit(f"{preset}/{skill}: generated Skill is missing")
        artifact = artifact_path.read_text()
        if skill in copied_skills:
            expected = Path(f".agents/skills/{skill}/SKILL.md").read_text()
        else:
            lines = artifact.splitlines()
            if lines[:4] != [
                "---",
                f"name: {skill}",
                f"description: {descriptions[skill]}",
                "---",
            ]:
                raise SystemExit(f"{preset}/{skill}: invalid or missing Skill frontmatter")
            expected = (
                "---\n"
                f"name: {skill}\n"
                f"description: {descriptions[skill]}\n"
                "---\n\n"
                f"# {titles[skill]}\n"
            )
            expected += "".join(
                "\n" + Path("modules/skills", skill, module).read_text()
                for module in module_lists[(skill, preset)]
            )
        if artifact != expected:
            raise SystemExit(f"{preset}/{skill}: generated content differs from its configured source")
        if "modules/skills/" in artifact:
            raise SystemExit(f"{preset}/{skill}: unresolved module path in compiled Skill")
        compiled[(skill, preset)] = artifact

for skill in descriptions:
    if len({compiled[(skill, preset)] for preset in presets}) != len(presets):
        raise SystemExit(f"{skill}: preset variants do not differ as configured")
for skill in copied_skills:
    if len({compiled[(skill, preset)] for preset in presets}) != 1:
        raise SystemExit(f"{skill}: identical shared guidance was copied inconsistently")

checks = {
    ("verification-qa", "prototype"): ("scenario", "Inspect the actual result", "automated smoke check"),
    ("verification-qa", "fast-development"): ("edge", "focused automated tests"),
    ("verification-qa", "performance"): ("scenario", "equivalent conditions", "profiling", "race"),
    ("verification-qa", "reliable"): ("invariants", "recovery", "critical check is missing", "100% coverage"),
    ("software-design", "prototype"): ("hypothesis", "minimal structure", "temporary limitations"),
    ("software-design", "fast-development"): ("readable", "maintainable", "Avoid concurrency"),
    ("software-design", "performance"): ("measurable workload", "profiling", "functional contracts"),
    ("software-design", "reliable"): ("contracts", "invariants", "module responsibilities", "failure behavior"),
}
for key, phrases in checks.items():
    normalized = " ".join(compiled[key].split()).lower()
    for phrase in phrases:
        if phrase.lower() not in normalized:
            raise SystemExit(f"{key[1]}/{key[0]}: expected strategy guidance is missing: {phrase}")
for artifact in compiled.values():
    if "Engineering Skillset Core Policy" in artifact:
        raise SystemExit("a compiled Skill duplicates the complete Core Policy")
PY

artifacts=()
for preset in prototype fast-development performance reliable; do
  for skill in software-design implementation-review verification-qa project-handover; do
    artifacts+=("dist/$preset/skills/$skill/SKILL.md")
  done
done
hashes_before=$(sha256sum "${artifacts[@]}")
make --no-print-directory build >/dev/null
[[ $(sha256sum "${artifacts[@]}") == "$hashes_before" ]] || \
  fail 'repeated full build changed modular Skill bytes'

for mode_case in '022 644' '077 600'; do
  read -r requested_umask expected_mode <<< "$mode_case"
  for preset in prototype fast-development performance reliable; do
    for skill in software-design implementation-review verification-qa project-handover; do
      (
        umask "$requested_umask"
        make --no-print-directory build-modular-skill \
          SKILL_PRESET="$preset" SKILL_NAME="$skill"
      )
      actual_mode=$(stat -c '%a' "dist/$preset/skills/$skill/SKILL.md")
      [[ $actual_mode == "$expected_mode" ]] || \
        fail "$preset/$skill mode $actual_mode does not respect umask $requested_umask (expected $expected_mode)"
    done
  done
done

if output=$(make --no-print-directory build-modular-skill SKILL_PRESET=unknown SKILL_NAME=verification-qa 2>&1); then
  fail 'invalid preset selection unexpectedly succeeded'
fi
[[ $output == *"unknown modular Skill preset 'unknown'"* ]] || fail "invalid preset error was unclear: $output"

if output=$(make --no-print-directory build-modular-skill SKILL_PRESET=prototype SKILL_NAME=unknown 2>&1); then
  fail 'invalid Skill selection unexpectedly succeeded'
fi
[[ $output == *"unknown modular Skill 'unknown'"* ]] || fail "invalid Skill error was unclear: $output"

prototype_before=$(sha256sum dist/prototype/skills/verification-qa/SKILL.md)
if output=$(make --no-print-directory build-modular-skill \
  SKILL_PRESET=prototype SKILL_NAME=verification-qa \
  MODULES_verification-qa_prototype=modules/skills/verification-qa/missing.md 2>&1); then
  fail 'missing module unexpectedly succeeded'
fi
[[ $output == *'missing or unreadable verification-qa module: modules/skills/verification-qa/missing.md'* ]] || \
  fail "missing module error was unclear: $output"
[[ $(sha256sum dist/prototype/skills/verification-qa/SKILL.md) == "$prototype_before" ]] || \
  fail 'missing module failure changed the existing artifact'

printf 'Complete modular Skill checks passed.\n'
