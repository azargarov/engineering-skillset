#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
data_home=${XDG_DATA_HOME:-${HOME:?HOME is not set}/.local/share}
data_root=$data_home/engineering-skillset
config_root=${XDG_CONFIG_HOME:-$HOME/.config}/engineering-skillset
bin_dir=${ESS_BIN_DIR:-$HOME/.local/bin}
dist_root=${DIST_ROOT:-$repo_root/dist}
presets=(prototype fast-development performance reliable)
skills=(software-design implementation-review verification-qa project-handover)

fail() { printf 'install-user: %s\n' "$*" >&2; exit 2; }
[[ -d $dist_root && ! -L $dist_root ]] || fail "built distribution is missing: '$dist_root' (run make build)"
[[ -d $dist_root/config && ! -L $dist_root/config && \
  -f $dist_root/config/model-preferences.md.example && ! -L $dist_root/config/model-preferences.md.example && \
  -r $dist_root/config/model-preferences.md.example ]] || fail 'model preferences template is missing or invalid'
for preset in "${presets[@]}"; do
  dir=$dist_root/$preset
  [[ -d $dir && ! -L $dir && -f $dir/AGENTS.md && ! -L $dir/AGENTS.md && -r $dir/AGENTS.md && -d $dir/skills && ! -L $dir/skills ]] || fail "invalid preset distribution: '$preset'"
  for skill in "${skills[@]}"; do
    [[ -d $dir/skills/$skill && ! -L $dir/skills/$skill && -f $dir/skills/$skill/SKILL.md && ! -L $dir/skills/$skill/SKILL.md && -r $dir/skills/$skill/SKILL.md ]] || fail "invalid Skill distribution: '$preset/$skill'"
  done
  [[ -f $dir/delegation/AGENTS.md && ! -L $dir/delegation/AGENTS.md && -r $dir/delegation/AGENTS.md && -f $dir/delegation/skills/opencode-delegation/SKILL.md && ! -L $dir/delegation/skills/opencode-delegation/SKILL.md && -r $dir/delegation/skills/opencode-delegation/SKILL.md ]] || fail "invalid delegation distribution: '$preset'"
done

mkdir -p -- "$data_root/releases" "$bin_dir" || fail 'cannot create user installation directories'
if [[ -e $data_root/current || -L $data_root/current ]]; then
  [[ -L $data_root/current ]] || fail "refusing to replace non-symlink active path: '$data_root/current'"
  active_target=$(readlink -- "$data_root/current") || fail 'cannot read active release link'
  [[ $active_target =~ ^releases/[A-Za-z0-9][A-Za-z0-9._-]*$ && -d $data_root/$active_target && ! -L $data_root/$active_target ]] || fail 'active release link is invalid; refusing update'
fi
wrapper=$bin_dir/ess
runtime=$data_root/ess-runtime
expected_wrapper=$(printf '#!/usr/bin/env bash\nset -euo pipefail\nexport ESS_DATA_HOME=%q\nexec %q/ess-runtime "$@"\n' "$data_home" "$data_root")
if [[ -e $wrapper || -L $wrapper ]]; then
  [[ -f $wrapper && ! -L $wrapper ]] || fail "refusing to replace existing CLI path: '$wrapper'"
  [[ $(cat -- "$wrapper") == "$expected_wrapper" ]] || fail "refusing to replace unrelated CLI file: '$wrapper'"
fi
if [[ -e $runtime || -L $runtime ]]; then
  [[ -f $runtime && ! -L $runtime && -x $runtime && -f $wrapper ]] || fail "refusing to replace unrelated runtime path: '$runtime'"
fi

release_id="release-$(date -u +%Y%m%dT%H%M%SZ)-$$"
release=$data_root/releases/$release_id
stage=$(mktemp -d "$data_root/releases/.stage.XXXXXX") || fail 'cannot stage release'
wrapper_tmp=$(mktemp "$bin_dir/.ess.XXXXXX") || { rm -rf -- "$stage"; fail 'cannot stage CLI'; }
runtime_tmp=$(mktemp "$data_root/.ess-runtime.XXXXXX") || { rm -rf -- "$stage"; rm -f -- "$wrapper_tmp"; fail 'cannot stage CLI runtime'; }
link_tmp=''
cleanup() { [[ -z $stage ]] || rm -rf -- "$stage"; rm -f -- "$wrapper_tmp" "$runtime_tmp"; [[ -z $link_tmp ]] || rm -f -- "$link_tmp"; }
trap cleanup EXIT
for preset in "${presets[@]}"; do
  cp -a -- "$dist_root/$preset" "$stage/$preset" || fail "cannot stage preset '$preset'"
  [[ -f $stage/$preset/AGENTS.md && -r $stage/$preset/AGENTS.md ]] || fail "staged preset is incomplete: '$preset'"
done
mkdir -p -- "$stage/config" || fail 'cannot create staged config directory'
cp -- "$dist_root/config/model-preferences.md.example" "$stage/config/model-preferences.md.example" || fail 'cannot stage model preferences template'
chmod -R a-w -- "$stage" || fail 'cannot make staged release read-only'
mv -T -- "$stage" "$release" || fail 'cannot publish release directory'
stage=''
cp -- "$repo_root/scripts/ess" "$runtime_tmp" || fail 'cannot stage CLI runtime'
chmod 755 -- "$runtime_tmp" || fail 'cannot set CLI permissions'
mv -fT -- "$runtime_tmp" "$data_root/ess-runtime" || fail 'cannot publish CLI runtime'
printf '%s\n' "$expected_wrapper" > "$wrapper_tmp" || fail 'cannot write CLI wrapper'
chmod 755 -- "$wrapper_tmp" || fail 'cannot set CLI wrapper permissions'

link_tmp=$data_root/.current.$$
ln -s -- "releases/$release_id" "$link_tmp" || fail 'cannot stage active release link'
if [[ -e $wrapper || -L $wrapper ]]; then
  mv -fT -- "$wrapper_tmp" "$wrapper" || fail 'cannot publish CLI wrapper'
else
  mv -T -- "$wrapper_tmp" "$wrapper" || fail 'cannot publish CLI wrapper'
fi
mv -Tf -- "$link_tmp" "$data_root/current" || fail 'cannot activate release'
trap - EXIT
rm -f -- "$link_tmp"
mkdir -p -- "$config_root" || fail "cannot create model preferences directory: '$config_root'"
preferences=$config_root/model-preferences.md
legacy_preferences=$config_root/model-delegation.md
if [[ -e $preferences || -L $preferences ]]; then
  preferences_status="Model preferences: existing configuration preserved at $preferences"
elif [[ -e $legacy_preferences || -L $legacy_preferences ]]; then
  preferences_status="Model preferences: legacy configuration preserved at $legacy_preferences"
else
  preferences_tmp=$(mktemp "$config_root/.model-preferences.XXXXXX") || fail "cannot stage model preferences in '$config_root'"
  if ! cp -- "$data_root/current/config/model-preferences.md.example" "$preferences_tmp"; then
    rm -f -- "$preferences_tmp"
    fail "cannot initialize model preferences at '$preferences'"
  fi
  if ln -- "$preferences_tmp" "$preferences" 2>/dev/null; then
    rm -f -- "$preferences_tmp"
    preferences_status="Model preferences: initialized at $preferences"
  else
    rm -f -- "$preferences_tmp"
    if [[ -e $preferences || -L $preferences ]]; then
      preferences_status="Model preferences: existing configuration preserved at $preferences"
    elif [[ -e $legacy_preferences || -L $legacy_preferences ]]; then
      preferences_status="Model preferences: legacy configuration preserved at $legacy_preferences"
    else
      fail "cannot initialize model preferences at '$preferences'"
    fi
  fi
fi
printf 'Installed Engineering Skillset %s\nCLI: %s\nData: %s\n' "$release_id" "$wrapper" "$data_root"
printf '%s\n' "$preferences_status"
