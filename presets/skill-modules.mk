# Explicit, ordered Markdown selections for the four product presets.
MODULAR_PRESETS := prototype fast-development performance reliable
MODULAR_SKILLS := software-design implementation-review verification-qa project-handover

SKILL_DESCRIPTION_software-design := Use when the user requests software design or implementation needs nontrivial architecture or interface decisions; define responsibilities, boundaries, trade-offs, and implementation steps. Keep routine localized changes lightweight.
SKILL_TITLE_software-design := Software Design
MODULES_software-design_prototype := modules/skills/software-design/common.md modules/skills/software-design/prototype.md
MODULES_software-design_fast-development := modules/skills/software-design/common.md modules/skills/software-design/fast-development.md
MODULES_software-design_performance := modules/skills/software-design/common.md modules/skills/software-design/performance.md
MODULES_software-design_reliable := modules/skills/software-design/common.md modules/skills/software-design/reliable.md

SKILL_SOURCE_implementation-review := .agents/skills/implementation-review/SKILL.md
SKILL_SOURCE_project-handover := .agents/skills/project-handover/SKILL.md

SKILL_DESCRIPTION_verification-qa := Use when planning substantial verification or assessing whether checks establish required behavior; select and assess checks appropriate to the active preset and task risks. Routine checks can follow project instructions without this workflow.
SKILL_TITLE_verification-qa := Verification QA
MODULES_verification-qa_prototype := modules/skills/verification-qa/common.md modules/skills/verification-qa/smoke.md
MODULES_verification-qa_fast-development := modules/skills/verification-qa/common.md modules/skills/verification-qa/essential.md
MODULES_verification-qa_performance := modules/skills/verification-qa/common.md modules/skills/verification-qa/performance.md
MODULES_verification-qa_reliable := modules/skills/verification-qa/common.md modules/skills/verification-qa/comprehensive.md
