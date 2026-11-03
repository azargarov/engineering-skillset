.DEFAULT_GOAL := build
SHELL := /bin/bash

PRESETS := prototype fast-development performance reliable
PRESET ?= prototype
DIST_ROOT ?= dist
BUILD_ROOT ?= $(DIST_ROOT)

ifeq ($(PRESET),prototype)
PRESET_FILE := presets/prototype.mk
else ifeq ($(PRESET),fast-development)
PRESET_FILE := presets/fast-development.mk
else ifeq ($(PRESET),performance)
PRESET_FILE := presets/performance.mk
else ifeq ($(PRESET),reliable)
PRESET_FILE := presets/reliable.mk
else
$(error unknown preset '$(PRESET)'; choose one of: $(PRESETS))
endif

include $(PRESET_FILE)
include presets/skill-modules.mk

ifneq ($(filter build-modular-skill,$(MAKECMDGOALS)),)
ifeq ($(filter $(SKILL_PRESET),$(MODULAR_PRESETS)),)
$(error unknown modular Skill preset '$(SKILL_PRESET)'; choose one of: $(MODULAR_PRESETS))
endif
ifeq ($(filter $(SKILL_NAME),$(MODULAR_SKILLS)),)
$(error unknown modular Skill '$(SKILL_NAME)'; choose one of: $(MODULAR_SKILLS))
endif
MODULAR_MODULES_SELECTED := $(MODULES_$(SKILL_NAME)_$(SKILL_PRESET))
MODULAR_SOURCE_SELECTED := $(SKILL_SOURCE_$(SKILL_NAME))
MODULAR_DESCRIPTION_SELECTED := $(SKILL_DESCRIPTION_$(SKILL_NAME))
MODULAR_TITLE_SELECTED := $(SKILL_TITLE_$(SKILL_NAME))
ifeq ($(strip $(MODULAR_MODULES_SELECTED)$(MODULAR_SOURCE_SELECTED)),)
$(error no module files configured for $(SKILL_NAME) / $(SKILL_PRESET))
endif
ifneq ($(strip $(MODULAR_MODULES_SELECTED)),)
ifneq ($(strip $(MODULAR_SOURCE_SELECTED)),)
$(error configure either source modules or an unchanged Skill source for $(SKILL_NAME), not both)
endif
ifeq ($(strip $(MODULAR_DESCRIPTION_SELECTED)),)
$(error no description configured for modular Skill '$(SKILL_NAME)')
endif
ifeq ($(strip $(MODULAR_TITLE_SELECTED)),)
$(error no title configured for modular Skill '$(SKILL_NAME)')
endif
endif
endif

DIST_DIR := $(BUILD_ROOT)/$(PRESET)
SKILLS_DIR := .agents/skills

.PHONY: build install-user build-staged build-one build-modular-skill check clean

build:
	@set -eu; \
	publish_root='$(DIST_ROOT)'; \
	case "$$publish_root" in \
	  */*) stage_parent=$${publish_root%/*}; stage_name=$${publish_root##*/}; [[ -n $$stage_parent ]] || stage_parent=/ ;; \
	  *) stage_parent=.; stage_name=$$publish_root ;; \
	esac; \
	[[ -n $$stage_name && $$stage_name != . && $$stage_name != .. ]] || { printf 'invalid DIST_ROOT: %s\n' "$$publish_root" >&2; exit 2; }; \
	mkdir -p "$$stage_parent"; \
	stage_root=$$(mktemp -d "$$stage_parent/.$$stage_name.stage.XXXXXX"); \
	trap 'rm -rf -- "$$stage_root"' EXIT; \
	$(MAKE) --no-print-directory build-staged BUILD_ROOT="$$stage_root"; \
	bash scripts/publish-build.sh "$$stage_root" "$$publish_root" $(PRESETS); \
	rm -rf -- "$$stage_root"; \
	trap - EXIT

install-user: build
	bash scripts/install-user.sh

build-staged:
	@set -e; \
	for preset in $(PRESETS); do \
	  $(MAKE) --no-print-directory build-one PRESET=$$preset BUILD_ROOT="$(BUILD_ROOT)"; \
	done; \
	mkdir -p "$(BUILD_ROOT)/config"; \
	cp config/model-preferences.md.example "$(BUILD_ROOT)/config/model-preferences.md.example"; \
	for preset in $(MODULAR_PRESETS); do \
	  for skill in $(MODULAR_SKILLS); do \
	    $(MAKE) --no-print-directory build-modular-skill SKILL_PRESET=$$preset SKILL_NAME=$$skill BUILD_ROOT="$(BUILD_ROOT)"; \
	  done; \
	done

build-one:
	@if [ "$(abspath $(BUILD_ROOT))" = "$(abspath $(DIST_ROOT))" ]; then printf 'build-one is an internal staging target; use make build\n' >&2; exit 2; fi
	rm -rf "$(DIST_DIR)"
	mkdir -p "$(DIST_DIR)"
	./scripts/compose-policy.sh --level $(PRESET_LEVEL) $(foreach priority,$(PRESET_PRIORITIES),--priority $(priority)) > "$(DIST_DIR)/AGENTS.md"
	mkdir -p "$(DIST_DIR)/delegation/skills/opencode-delegation"
	./scripts/compose-policy.sh --level $(PRESET_LEVEL) $(foreach priority,$(PRESET_PRIORITIES),--priority $(priority)) --optional delegation-policy > "$(DIST_DIR)/delegation/AGENTS.md"
	cp .agents/skills/opencode-delegation/SKILL.md "$(DIST_DIR)/delegation/skills/opencode-delegation/SKILL.md"
	set -eu; \
	for skill in $(PRESET_SKILLS); do \
	  mkdir -p "$(DIST_DIR)/skills/$$skill"; \
	  cp "$(SKILLS_DIR)/$$skill/SKILL.md" "$(DIST_DIR)/skills/$$skill/SKILL.md"; \
	done

build-modular-skill:
	@set -eu; \
	output_dir=$(BUILD_ROOT)/$(SKILL_PRESET)/skills/$(SKILL_NAME); \
	output_file=$$output_dir/SKILL.md; \
	modules='$(MODULAR_MODULES_SELECTED)'; \
	source='$(MODULAR_SOURCE_SELECTED)'; \
	for module in $$modules; do \
	  if [ ! -f "$$module" ] || [ ! -r "$$module" ]; then \
	    printf 'missing or unreadable %s module: %s\n' '$(SKILL_NAME)' "$$module" >&2; \
	    exit 2; \
	  fi; \
	done; \
	mkdir -p "$$output_dir"; \
	temp_file=$$(mktemp "$$output_file.tmp.XXXXXX"); \
	trap 'rm -f "$$temp_file"' EXIT; \
	if [ -n "$$source" ]; then \
	  if [ ! -f "$$source" ] || [ ! -r "$$source" ]; then \
	    printf 'missing or unreadable %s Skill source: %s\n' '$(SKILL_NAME)' "$$source" >&2; \
	    exit 2; \
	  fi; \
	  cat "$$source" > "$$temp_file"; \
	else \
	  { \
	    printf '%s\n' '---' 'name: $(SKILL_NAME)' 'description: $(MODULAR_DESCRIPTION_SELECTED)' '---' '' '# $(MODULAR_TITLE_SELECTED)'; \
	    for module in $$modules; do \
	      printf '\n'; \
	      cat "$$module"; \
	    done; \
	  } > "$$temp_file"; \
	fi; \
	file_umask=$$(umask); \
	output_mode=$$(printf '%04o' "$$((0666 & ~8#$$file_umask))"); \
	chmod "$$output_mode" "$$temp_file"; \
	mv "$$temp_file" "$$output_file"; \
	trap - EXIT

check: build
	bash tests/compose-policy.sh
	bash tests/build-modular-presets.sh
	bash tests/build-modular-skills.sh
	bash tests/ess.sh
	bash tests/install-user.sh
	bash tests/build-publication.sh

clean:
	rm -rf "$(DIST_ROOT)"
