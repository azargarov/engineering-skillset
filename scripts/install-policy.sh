#!/usr/bin/env bash

program=${0##*/}

usage() {
  cat <<'USAGE'
Usage:
  scripts/install-policy.sh --target DIR --level ID [--priority ID ...] [--optional ID ...] [--dry-run]

Install a composed policy as DIR/AGENTS.md using the local Engineering
Skillset composer. The target directory must already exist. A first install
creates AGENTS.md and .engineering-skillset-manifest. Repeating the same
configuration leaves managed files unchanged; changed or locally modified
installations are refused.

Use --dry-run to validate the selection and display the plan without changing
the target directory. Existing user files and symbolic links are never replaced.
See docs/development/installation-metadata.md for the manifest format. Use
--help by itself to show this text.
USAGE
}

error() {
  printf '%s: %s\n' "$program" "$*" >&2
}

fail() {
  error "$*"
  exit 2
}

if (($# == 1)) && [[ $1 == --help ]]; then
  usage
  exit 0
fi

target_dir=''
target_seen=0
dry_run=0
selection_args=()
level_id=''
selection_records=()

while (($#)); do
  case $1 in
    --target)
      (($# >= 2)) || fail "--target requires a directory"
      ((target_seen == 0)) || fail "--target may be supplied only once"
      target_dir=$2
      [[ -n $target_dir ]] || fail "--target requires a non-empty directory"
      target_seen=1
      shift 2
      ;;
    --level|--priority|--optional)
      (($# >= 2)) || fail "$1 requires an ID"
      [[ $2 != --* ]] || fail "$1 requires an ID"
      selection_args+=("$1" "$2")
      case $1 in
        --level) level_id=$2 ;;
        --priority) selection_records+=("priority=$2") ;;
        --optional) selection_records+=("optional=$2") ;;
      esac
      shift 2
      ;;
    --dry-run)
      ((dry_run == 0)) || fail "--dry-run may be supplied only once"
      dry_run=1
      shift
      ;;
    --help)
      fail "--help must be used by itself"
      ;;
    *)
      fail "unknown argument '$1'"
      ;;
  esac
done

((target_seen)) || fail "missing required --target DIR"
case "/$target_dir/" in
  */../*) fail "target path must not contain a '..' component" ;;
esac
target_path=$target_dir
while [[ $target_path == */ && $target_path != / ]]; do
  target_path=${target_path%/}
done
[[ ! -L $target_path ]] || fail "target directory must not be a symbolic link"
[[ -d $target_dir ]] || fail "target directory does not exist: '$target_dir'"
target_logical=$(CDPATH='' cd -L -- "$target_dir" && pwd -L) || \
  fail "cannot resolve target directory"
target_dir=$(CDPATH='' cd -P -- "$target_dir" && pwd -P) || \
  fail "cannot resolve target directory"
[[ $target_logical == "$target_dir" ]] || \
  fail "target path must not traverse a symbolic link"
[[ $target_dir != / ]] || fail "target directory must not be the filesystem root"
output_path=$target_dir/AGENTS.md
manifest_path=$target_dir/.engineering-skillset-manifest
[[ ! -L $output_path ]] || fail "AGENTS.md must not be a symbolic link"
[[ ! -L $manifest_path ]] || fail "installation manifest must not be a symbolic link"

agents_exists=0
manifest_exists=0
[[ -e $output_path ]] && agents_exists=1
[[ -e $manifest_path ]] && manifest_exists=1
if ((agents_exists != manifest_exists)); then
  if ((agents_exists)); then
    fail "AGENTS.md is unmanaged or its manifest is missing; refusing to overwrite"
  fi
  fail "installation manifest exists without AGENTS.md; refusing inconsistent state"
fi

stored_policy_sha=''
stored_configuration=''
if ((agents_exists)); then
  [[ -f $output_path && -r $output_path ]] || \
    fail "managed AGENTS.md is not a readable regular file"
  [[ -f $manifest_path && -r $manifest_path ]] || \
    fail "installation manifest is not a readable regular file"
  manifest_lines=()
  mapfile -t manifest_lines < "$manifest_path"
  ((${#manifest_lines[@]} == 3)) || fail "installation manifest is malformed"
  [[ ${manifest_lines[0]} == 'engineering-skillset-manifest-v1' ]] || \
    fail "installation manifest has an unsupported format"
  [[ ${manifest_lines[1]} =~ ^policy_sha256=([0-9a-f]{64})$ ]] || \
    fail "installation manifest has an invalid policy digest"
  stored_policy_sha=${BASH_REMATCH[1]}
  [[ ${manifest_lines[2]} == configuration=* ]] || \
    fail "installation manifest has no configuration"
  stored_configuration=${manifest_lines[2]#configuration=}
  current_policy_sha=$(sha256sum -- "$output_path") || \
    fail "cannot verify managed AGENTS.md"
  current_policy_sha=${current_policy_sha%% *}
  [[ $current_policy_sha == "$stored_policy_sha" ]] || \
    fail "managed AGENTS.md was modified; refusing to replace it"
fi

script_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) || \
  fail "cannot locate the script directory"
composer=$script_dir/compose-policy.sh
[[ -x $composer ]] || fail "local composer is missing or not executable"
for utility in cmp ln mktemp rm sha256sum sort stat; do
  command -v "$utility" > /dev/null 2>&1 || fail "required utility is unavailable: $utility"
done

selection_config="level=$level_id"
if ((${#selection_records[@]})); then
  sorted_records=$(printf '%s\n' "${selection_records[@]}" | LC_ALL=C sort) || \
    fail "could not normalize the selected configuration"
  while IFS= read -r record; do
    selection_config+=";$record"
  done <<< "$sorted_records"
fi

staging_parent=$target_dir
if ((dry_run)); then
  staging_parent=${TMPDIR:-/tmp}
  [[ -d $staging_parent && -w $staging_parent ]] || \
    fail "temporary directory is missing or not writable: '$staging_parent'"
  staging_parent=$(CDPATH='' cd -- "$staging_parent" && pwd -P) || \
    fail "cannot resolve temporary directory"
  case "$staging_parent/" in
    "$target_dir/"*) fail "dry-run temporary directory must be outside the target" ;;
  esac
fi

stage_dir=$(mktemp -d "$staging_parent/.engineering-skillset-stage.XXXXXX") || \
  fail "cannot create installation staging directory"
policy_stage=$stage_dir/AGENTS.md
manifest_stage=$stage_dir/manifest
install_complete=0
published=(0 0)

cleanup() {
  local status=$?
  trap - EXIT
  if ((!install_complete)); then
    destinations=("$manifest_path" "$output_path")
    staged_files=("$manifest_stage" "$policy_stage")
    expected_hashes=("${manifest_sha:-}" "${policy_sha:-}")
    expected_modes=("${manifest_mode:-}" "${policy_stage_mode:-}")
    for index in 0 1; do
      ((published[index])) || continue
      destination=${destinations[index]}
      staged=${staged_files[index]}
      if [[ -e $destination && $destination -ef $staged ]]; then
        current_sha=$(sha256sum -- "$destination") || current_sha=''
        current_sha=${current_sha%% *}
        current_mode=$(stat -c '%a' -- "$destination") || current_mode=''
        if [[ $current_sha == "${expected_hashes[index]}" && \
          $current_mode == "${expected_modes[index]}" ]]; then
          rm -f -- "$destination" || {
            error "failed to roll back '$destination'"
            ((status != 0)) || status=1
          }
        else
          error "preserving changed file during rollback: '$destination'"
          ((status != 0)) || status=1
        fi
      fi
    done
  fi
  if ! rm -rf -- "$stage_dir"; then
    error "failed to remove staging directory '$stage_dir'"
    ((status != 0)) || status=1
  fi
  exit "$status"
}
trap cleanup EXIT

if ! "$composer" "${selection_args[@]}" --output "$policy_stage"; then
  fail "policy composition failed"
fi
policy_sha=$(sha256sum -- "$policy_stage") || fail "cannot hash composed policy"
policy_sha=${policy_sha%% *}
policy_stage_mode=$(stat -c '%a' -- "$policy_stage") || fail "cannot read composed policy permissions"
printf 'engineering-skillset-manifest-v1\npolicy_sha256=%s\nconfiguration=%s\n' \
  "$policy_sha" "$selection_config" > "$manifest_stage" || \
  fail "cannot write installation manifest"
manifest_mode=$(stat -c '%a' -- "$manifest_stage") || \
  fail "cannot read installation manifest permissions"
manifest_sha=$(sha256sum -- "$manifest_stage") || fail "cannot hash installation manifest"
manifest_sha=${manifest_sha%% *}

if ((agents_exists)); then
  [[ $stored_configuration == "$selection_config" ]] || \
    fail "installed configuration differs; configuration changes require M02.4"
  [[ $stored_policy_sha == "$policy_sha" ]] || \
    fail "composed policy differs from the managed installation; refusing update"
  cmp -s -- "$output_path" "$policy_stage" || \
    fail "managed AGENTS.md differs from the composed policy; refusing update"
  cmp -s -- "$manifest_path" "$manifest_stage" || \
    fail "installation manifest is inconsistent; refusing update"
  install_complete=1
  if ((dry_run)); then
    printf 'Dry run: installation is already current.\nTarget: %s\n' "$output_path"
  else
    printf 'Installation is already current: %s\n' "$output_path"
  fi
  exit 0
fi

if ((dry_run)); then
  install_complete=1
  printf 'Dry run: would install policy and manifest.\nTarget: %s\nConfiguration: %s\n' \
    "$output_path" "$selection_config"
  exit 0
fi

if ! ln -T -- "$policy_stage" "$output_path"; then
  fail "could not publish AGENTS.md without overwriting"
fi
published[1]=1
if ! ln -T -- "$manifest_stage" "$manifest_path"; then
  fail "could not publish installation manifest; attempting rollback"
fi
published[0]=1
if ! cmp -s -- "$output_path" "$policy_stage" || \
  ! cmp -s -- "$manifest_path" "$manifest_stage" || \
  [[ ! $output_path -ef $policy_stage || ! $manifest_path -ef $manifest_stage ]]; then
  fail "installed files changed during publication; attempting rollback"
fi
install_complete=1
printf 'Installed policy: %s\n' "$output_path"
