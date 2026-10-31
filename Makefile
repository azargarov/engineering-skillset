.DEFAULT_GOAL := build

include presets/personal.mk

DIST_DIR := dist/personal
SKILLS_DIR := .agents/skills

.PHONY: build check clean

build:
	rm -rf $(DIST_DIR)
	mkdir -p $(DIST_DIR)
	./scripts/compose-policy.sh --level $(PRESET_LEVEL) $(foreach priority,$(PRESET_PRIORITIES),--priority $(priority)) > $(DIST_DIR)/AGENTS.md
	set -eu; \
	for skill in $(PRESET_SKILLS); do \
	  mkdir -p $(DIST_DIR)/skills/$$skill; \
	  cp $(SKILLS_DIR)/$$skill/SKILL.md $(DIST_DIR)/skills/$$skill/SKILL.md; \
	done

check: build
	bash tests/compose-policy.sh
	bash tests/build-personal.sh

clean:
	rm -rf dist
