.DEFAULT_GOAL := build

PRESETS := prototype personal production
PRESET ?= personal

ifeq ($(PRESET),prototype)
PRESET_FILE := presets/prototype.mk
else ifeq ($(PRESET),personal)
PRESET_FILE := presets/personal.mk
else ifeq ($(PRESET),production)
PRESET_FILE := presets/production.mk
else
$(error unknown preset '$(PRESET)'; choose one of: $(PRESETS))
endif

include $(PRESET_FILE)

DIST_DIR := dist/$(PRESET)
SKILLS_DIR := .agents/skills

.PHONY: build build-one check clean

build:
	@set -e; \
	for preset in $(PRESETS); do \
	  $(MAKE) --no-print-directory build-one PRESET=$$preset; \
	done

build-one:
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
	bash tests/ess.sh

clean:
	rm -rf dist
