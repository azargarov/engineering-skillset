#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/install-user.XXXXXX")
trap 'chmod -R u+w -- "$test_dir" 2>/dev/null || true; rm -rf -- "$test_dir"' EXIT
fail() { printf 'install-user: %s\n' "$*" >&2; exit 1; }
state_name=.engineering-skillset-state
home=$test_dir/home
data=$test_dir/custom-data
bin=$home/.local/bin
config_home=$test_dir/xdg-config-home
mkdir -p -- "$home" "$data" "$config_home"

fresh_checkout=$test_dir/fresh-checkout
mkdir -p -- "$fresh_checkout"
cp -a -- "$repo_root/Makefile" "$repo_root/AGENTS.md" "$repo_root/modules" \
  "$repo_root/presets" "$repo_root/scripts" "$repo_root/.agents" "$repo_root/config" "$fresh_checkout/"
fresh_output=$(HOME=$home XDG_CONFIG_HOME=$config_home XDG_DATA_HOME=$data ESS_BIN_DIR=$bin make -C "$fresh_checkout" install-user)
[[ -x $bin/ess && -L $data/engineering-skillset/current ]] || fail 'clean install did not publish CLI and current'
data_root=$data/engineering-skillset
preferences=$config_home/engineering-skillset/model-preferences.md
[[ -f $preferences && ! -L $preferences ]] || fail 'fresh install did not create a regular model preferences file'
cmp -s "$repo_root/config/model-preferences.md.example" "$preferences" || fail 'fresh preferences differ from published template'
grep -Fq "Model preferences: initialized at $preferences" <<< "$fresh_output" || fail 'fresh install status was incorrect'
active=$(readlink -- "$data_root/current")
cmp -s "$repo_root/config/model-preferences.md.example" \
  "$data_root/current/config/model-preferences.md.example" || \
  fail 'installed release omitted the model preferences template'
PATH=$bin:$PATH HOME=$home XDG_DATA_HOME=$data ess list > "$test_dir/list"
cmp -s "$test_dir/list" <(printf 'fast-development\nperformance\nprototype\nreliable\n') || fail 'global list failed'

# Reinstallation preserves edits, and release updates do not change the private copy.
printf '\nUser customization.\n' >> "$preferences"
install_output=$(HOME=$home XDG_CONFIG_HOME=$config_home XDG_DATA_HOME=$data ESS_BIN_DIR=$bin bash "$repo_root/scripts/install-user.sh")
grep -Fq "Model preferences: existing configuration preserved at $preferences" <<< "$install_output" || fail 'reinstall did not report preserved preferences'
grep -Fq 'User customization.' "$preferences" || fail 'reinstall replaced user preferences'

project=$test_dir/project
mkdir -p "$project/.agents/skills/user-skill"
printf 'user skill\n' > "$project/.agents/skills/user-skill/SKILL.md"
PATH=$bin:$PATH HOME=$home XDG_DATA_HOME=$data ess install prototype "$project" >/dev/null
link=$project/.agents/skills/software-design
expected=$data_root/current/prototype/skills/software-design
[[ $(readlink -- "$link") == "$expected" && -r $link/SKILL.md ]] || fail 'project link did not use stable installed path'
printf 'unrelated\n' > "$project/user-file"
PATH=$bin:$PATH HOME=$home XDG_DATA_HOME=$data ess install reliable "$project" >/dev/null
[[ $(readlink -- "$link") == "$data_root/current/reliable/skills/software-design" ]] || fail 'preset switch failed'

# Relocate the fresh checkout after installation; installed use stays healthy.
mv -- "$fresh_checkout" "$test_dir/fresh-checkout-moved"
PATH=$bin:$PATH HOME=$home XDG_DATA_HOME=$data ess status "$project" >/dev/null || fail 'installed CLI depended on the checkout'

# Install from a disposable source checkout, then relocate it.
fixture=$test_dir/source-checkout
mkdir -p "$fixture/scripts" "$fixture/dist"
cp -- "$repo_root/scripts/ess" "$fixture/scripts/ess"
cp -a -- "$repo_root/dist/." "$fixture/dist/"
chmod +x "$fixture/scripts/ess"
cp -- "$repo_root/scripts/install-user.sh" "$fixture/scripts/install-user.sh"
home2=$test_dir/home-relocated
data2=$test_dir/data-relocated
bin2=$home2/.local/bin
mkdir -p "$home2" "$data2"
HOME=$home2 XDG_CONFIG_HOME="$test_dir/relocated-xdg" XDG_DATA_HOME=$data2 ESS_BIN_DIR=$bin2 bash "$fixture/scripts/install-user.sh" >/dev/null
project2=$test_dir/project-relocated
mkdir "$project2"
PATH=$bin2:$PATH HOME=$home2 XDG_DATA_HOME=$data2 ess install prototype "$project2" >/dev/null
fixture_moved=$test_dir/source-checkout-moved
mv -- "$fixture" "$fixture_moved"
PATH=$bin2:$PATH HOME=$home2 XDG_DATA_HOME=$data2 ess status "$project2" >/dev/null || fail 'CLI depended on source checkout'
[[ -r $project2/.agents/skills/software-design/SKILL.md ]] || fail 'project Skill depended on source checkout'

# Updating activates new immutable content while preserving the project link.
update_dist=$test_dir/update-dist
cp -a -- "$repo_root/dist" "$update_dist"
printf '\nUser installation update fixture.\n' >> "$update_dist/reliable/skills/software-design/SKILL.md"
printf '\nUpdated published template fixture.\n' >> "$update_dist/config/model-preferences.md.example"
link_before=$(readlink -- "$project/.agents/skills/software-design")
update_output=$(HOME=$home XDG_CONFIG_HOME=$config_home XDG_DATA_HOME=$data ESS_BIN_DIR=$bin DIST_ROOT=$update_dist bash "$repo_root/scripts/install-user.sh")
grep -Fq "Model preferences: existing configuration preserved at $preferences" <<< "$update_output" || fail 'update did not report preserved preferences'
! grep -Fq 'Updated published template fixture.' "$preferences" || fail 'distribution update changed private preferences'
[[ $(readlink -- "$project/.agents/skills/software-design") == "$link_before" ]] || fail 'update rewrote project Skill link'
grep -Fq 'User installation update fixture.' "$project/.agents/skills/software-design/SKILL.md" || fail 'project link did not see updated release'
active=$(readlink -- "$data_root/current")

# XDG_CONFIG_HOME and the deprecated filename are respected.
legacy_home=$test_dir/legacy-home
legacy_config=$test_dir/xdg-config
legacy_path=$legacy_config/engineering-skillset/model-delegation.md
mkdir -p "$legacy_home" "$(dirname "$legacy_path")"
printf 'legacy preferences\n' > "$legacy_path"
legacy_output=$(HOME=$legacy_home XDG_CONFIG_HOME=$legacy_config XDG_DATA_HOME="$test_dir/legacy-data" ESS_BIN_DIR="$test_dir/legacy-bin" \
  bash "$repo_root/scripts/install-user.sh")
grep -Fq "Model preferences: legacy configuration preserved at $legacy_path" <<< "$legacy_output" || fail 'legacy fallback status was incorrect'
[[ ! -e $legacy_config/engineering-skillset/model-preferences.md && $(cat "$legacy_path") == 'legacy preferences' ]] || fail 'legacy configuration was changed or shadowed'

# The new filename wins when both are present.
both_home=$test_dir/both-home
both_config=$test_dir/both-xdg
both_dir=$both_config/engineering-skillset
mkdir -p "$both_home" "$both_dir"
printf 'new preferences\n' > "$both_dir/model-preferences.md"
printf 'legacy preferences\n' > "$both_dir/model-delegation.md"
both_output=$(HOME=$both_home XDG_CONFIG_HOME=$both_config XDG_DATA_HOME="$test_dir/both-data" ESS_BIN_DIR="$test_dir/both-bin" \
  bash "$repo_root/scripts/install-user.sh")
grep -Fq "Model preferences: existing configuration preserved at $both_dir/model-preferences.md" <<< "$both_output" || fail 'new preferences did not take precedence'
[[ $(cat "$both_dir/model-preferences.md") == 'new preferences' && $(cat "$both_dir/model-delegation.md") == 'legacy preferences' ]] || fail 'existing preferences were modified'

# A configuration initialization failure must not print installation success.
bad_config_home=$test_dir/not-a-directory
printf 'file blocks config directory\n' > "$bad_config_home"
if HOME=$home XDG_CONFIG_HOME=$bad_config_home XDG_DATA_HOME="$test_dir/failure-data" ESS_BIN_DIR="$test_dir/failure-bin" \
  bash "$repo_root/scripts/install-user.sh" > "$test_dir/config-failure.out" 2>&1; then
  fail 'configuration initialization failure succeeded'
fi
! grep -Fq 'Installed Engineering Skillset' "$test_dir/config-failure.out" || fail 'failed configuration initialization claimed installation success'

# A staging failure leaves the previous active release untouched.
real_cp=$(command -v cp)
mkdir -p "$test_dir/fail-cp"
cat > "$test_dir/fail-cp/cp" <<'EOF'
#!/usr/bin/env bash
if [[ $1 == -a ]]; then exit 1; fi
exec "$REAL_CP" "$@"
EOF
chmod +x "$test_dir/fail-cp/cp"
if PATH="$test_dir/fail-cp:$PATH" REAL_CP="$real_cp" HOME=$home XDG_CONFIG_HOME=$config_home XDG_DATA_HOME=$data ESS_BIN_DIR=$bin \
  bash "$repo_root/scripts/install-user.sh" > /dev/null 2>&1; then
  fail 'injected staging failure succeeded'
fi
[[ $(readlink -- "$data_root/current") == "$active" ]] || fail 'staging failure replaced active release'

# A failed pointer publication leaves the previous active release selected.
real_mv=$(command -v mv)
mkdir -p "$test_dir/failbin"
cat > "$test_dir/failbin/mv" <<'EOF'
#!/usr/bin/env bash
if [[ $1 == -Tf ]]; then exit 1; fi
exec "$REAL_MV" "$@"
EOF
chmod +x "$test_dir/failbin/mv"
if PATH="$test_dir/failbin:$PATH" REAL_MV="$real_mv" MV_LOG="$test_dir/mv.log" HOME=$home XDG_CONFIG_HOME=$config_home XDG_DATA_HOME=$data ESS_BIN_DIR=$bin \
  bash "$repo_root/scripts/install-user.sh" > /dev/null 2>&1; then fail 'injected activation failure succeeded'; fi
[[ $(readlink -- "$data_root/current") == "$active" ]] || fail 'failed publication replaced active release'

# Invalid distributions and unrelated global CLI paths are refused.
invalid=$test_dir/invalid
cp -a -- "$repo_root/dist" "$invalid"
rm -- "$invalid/reliable/skills/project-handover/SKILL.md"
if HOME=$home XDG_CONFIG_HOME=$config_home XDG_DATA_HOME=$data ESS_BIN_DIR=$bin DIST_ROOT=$invalid bash "$repo_root/scripts/install-user.sh" >/dev/null 2>&1; then
  fail 'invalid release was accepted'
fi
unrelated=$test_dir/unrelated
mkdir -p "$unrelated/.local/bin" "$unrelated/.local/share"
printf 'owner command\n' > "$unrelated/.local/bin/ess"
if HOME=$unrelated XDG_CONFIG_HOME="$test_dir/unrelated-xdg" XDG_DATA_HOME=$unrelated/.local/share bash "$repo_root/scripts/install-user.sh" >/dev/null 2>&1; then
  fail 'unrelated global CLI was overwritten'
fi
[[ $(cat "$unrelated/.local/bin/ess") == 'owner command' ]] || fail 'unrelated CLI changed'

# An active link through a symlinked release directory is treated as corrupt.
symlink_data=$test_dir/symlink-data
mkdir -p "$symlink_data/engineering-skillset/releases"
ln -s "$repo_root/dist" "$symlink_data/engineering-skillset/releases/release-external"
ln -s releases/release-external "$symlink_data/engineering-skillset/current"
if HOME=$home XDG_CONFIG_HOME=$config_home XDG_DATA_HOME=$symlink_data ESS_BIN_DIR="$test_dir/symlink-bin" \
  bash "$repo_root/scripts/install-user.sh" > /dev/null 2>&1; then
  fail 'symlinked active release was accepted'
fi
[[ $(readlink "$symlink_data/engineering-skillset/current") == releases/release-external ]] || \
  fail 'invalid active release link was modified'

PATH=$bin:$PATH HOME=$home XDG_DATA_HOME=$data ess uninstall "$project" >/dev/null
[[ ! -e $project/AGENTS.md && ! -e $project/$state_name && $(cat "$project/user-file") == unrelated && \
  $(cat "$project/.agents/skills/user-skill/SKILL.md") == 'user skill' ]] || \
  fail 'guarded uninstall failed or removed user data'
printf 'install-user: all checks passed\n'
