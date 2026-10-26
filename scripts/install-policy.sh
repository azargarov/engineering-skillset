#!/usr/bin/env bash

program=${0##*/}

usage() {
  cat <<'USAGE'
Usage:
  scripts/install-policy.sh --target DIR --level ID [--priority ID ...] [--optional ID ...] [--reconfigure] [--dry-run]

Install a composed policy as DIR/AGENTS.md using the local Engineering
Skillset composer. The target directory must already exist. A first install
creates AGENTS.md and .engineering-skillset-manifest. Repeating the same
configuration leaves managed files unchanged; changed or locally modified
installations are refused.

Add --reconfigure to explicitly replace a verified managed configuration. Use
--dry-run to validate the selection and display the plan without changing
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
reconfigure=0
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
    --reconfigure)
      ((reconfigure == 0)) || fail "--reconfigure may be supplied only once"
      reconfigure=1
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
  [[ $stored_configuration =~ ^level=[a-z0-9]+(-[a-z0-9]+)*(\;(priority|optional)=[a-z0-9]+(-[a-z0-9]+)*)*$ ]] || \
    fail "installation manifest has an invalid configuration"
  stored_records=()
  stored_suffix=${stored_configuration#level=*}
  if [[ $stored_suffix == ';'* ]]; then
    IFS=';' read -r -a stored_records <<< "${stored_suffix#;}"
  fi
  if ((${#stored_records[@]})); then
    sorted_stored_records=$(printf '%s\n' "${stored_records[@]}" | LC_ALL=C sort) || \
      fail "cannot validate manifest configuration ordering"
    canonical_configuration="level=${stored_configuration#level=}"
    canonical_configuration=${canonical_configuration%%;*}
    while IFS= read -r stored_record; do
      canonical_configuration+=";$stored_record"
    done <<< "$sorted_stored_records"
    [[ $canonical_configuration == "$stored_configuration" ]] || \
      fail "installation manifest configuration is not in canonical order"
    for ((record_index=1; record_index<${#stored_records[@]}; record_index++)); do
      [[ ${stored_records[record_index]} != "${stored_records[record_index-1]}" ]] || \
        fail "installation manifest contains a duplicate selection"
    done
  fi
  current_policy_sha=$(sha256sum -- "$output_path") || \
    fail "cannot verify managed AGENTS.md"
  current_policy_sha=${current_policy_sha%% *}
  [[ $current_policy_sha == "$stored_policy_sha" ]] || \
    fail "managed AGENTS.md was modified; refusing to replace it"
  current_manifest_sha=$(sha256sum -- "$manifest_path") || \
    fail "cannot verify installation manifest"
  stored_manifest_sha=${current_manifest_sha%% *}
  stored_policy_inode=$(stat -c '%d:%i' -- "$output_path") || \
    fail "cannot inspect managed AGENTS.md"
  stored_manifest_inode=$(stat -c '%d:%i' -- "$manifest_path") || \
    fail "cannot inspect installation manifest"
fi
((!reconfigure || agents_exists)) || \
  fail "there is no managed installation to reconfigure"

script_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) || \
  fail "cannot locate the script directory"
composer=$script_dir/compose-policy.sh
[[ -x $composer ]] || fail "local composer is missing or not executable"
for utility in cmp ln mktemp mv rm sha256sum sort stat; do
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
reconfiguration_started=0
replaced=(0 0)
replacement_policy=$stage_dir/replacement-AGENTS.md
replacement_manifest=$stage_dir/replacement-manifest
replacement_policy_guard=$stage_dir/replacement-policy-guard
replacement_manifest_guard=$stage_dir/replacement-manifest-guard
previous_policy=$stage_dir/previous-AGENTS.md
previous_manifest=$stage_dir/previous-manifest

cleanup() {
  local status=$?
  local rollback_failed=0
  trap - EXIT
  if ((!install_complete && reconfiguration_started)); then
    destinations=("$manifest_path" "$output_path")
    replacements=("$replacement_manifest_guard" "$replacement_policy_guard")
    backups=("$previous_manifest" "$previous_policy")
    replacement_hashes=("$manifest_sha" "$policy_sha")
    replacement_modes=("$manifest_mode" "$policy_stage_mode")
    for index in 0 1; do
      ((replaced[index])) || continue
      destination=${destinations[index]}
      replacement=${replacements[index]}
      backup=${backups[index]}
      if [[ -e $destination && $destination -ef $replacement ]]; then
        current_sha=$(sha256sum -- "$destination") || current_sha=''
        current_sha=${current_sha%% *}
        current_mode=$(stat -c '%a' -- "$destination") || current_mode=''
        if [[ $current_sha == "${replacement_hashes[index]}" && \
          $current_mode == "${replacement_modes[index]}" ]]; then
          if ! mv -T -- "$backup" "$destination"; then
            error "failed to restore '$destination'; recovery file remains in '$stage_dir'"
            ((status != 0)) || status=1
            rollback_failed=1
          fi
        else
          error "preserving changed file during rollback: '$destination'"
          ((status != 0)) || status=1
          rollback_failed=1
        fi
      else
        error "preserving unexpected file during rollback: '$destination'"
        ((status != 0)) || status=1
        rollback_failed=1
      fi
    done
  fi
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
  if ((!reconfiguration_started || install_complete || !rollback_failed)); then
    if ! rm -rf -- "$stage_dir"; then
      error "failed to remove staging directory '$stage_dir'"
      ((status != 0)) || status=1
    fi
  else
    error "preserving reconfiguration recovery files in '$stage_dir'"
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
  if [[ $stored_configuration == "$selection_config" && \
    $stored_policy_sha == "$policy_sha" ]] && \
    cmp -s -- "$output_path" "$policy_stage" && \
    cmp -s -- "$manifest_path" "$manifest_stage"; then
    install_complete=1
    if ((dry_run)); then
      printf 'Dry run: installation is already current.\nTarget: %s\n' "$output_path"
    else
      printf 'Installation is already current: %s\n' "$output_path"
    fi
    exit 0
  fi

  if ((!reconfigure)); then
    fail "requested managed policy differs; use --reconfigure to authorize changes"
  fi
  if ((dry_run)); then
    install_complete=1
    printf 'Dry run: would reconfigure managed policy.\nTarget: %s\nCurrent configuration: %s\nRequested configuration: %s\n' \
      "$output_path" "$stored_configuration" "$selection_config"
    exit 0
  fi

  ln -T -- "$output_path" "$previous_policy" || \
    fail "cannot create recovery copy of managed AGENTS.md"
  ln -T -- "$manifest_path" "$previous_manifest" || \
    fail "cannot create recovery copy of installation manifest"
  ln -T -- "$policy_stage" "$replacement_policy" || \
    fail "cannot stage replacement policy"
  ln -T -- "$manifest_stage" "$replacement_manifest" || \
    fail "cannot stage replacement manifest"
  ln -T -- "$replacement_policy" "$replacement_policy_guard" || \
    fail "cannot verify staged replacement policy"
  ln -T -- "$replacement_manifest" "$replacement_manifest_guard" || \
    fail "cannot verify staged replacement manifest"
  current_policy_sha=$(sha256sum -- "$output_path") || current_policy_sha=''
  current_policy_sha=${current_policy_sha%% *}
  current_manifest_sha=$(sha256sum -- "$manifest_path") || current_manifest_sha=''
  current_manifest_sha=${current_manifest_sha%% *}
  [[ $output_path -ef $previous_policy && $manifest_path -ef $previous_manifest && \
    $current_policy_sha == "$stored_policy_sha" && \
    $current_manifest_sha == "$stored_manifest_sha" && \
    $(stat -c '%d:%i' -- "$output_path") == "$stored_policy_inode" && \
    $(stat -c '%d:%i' -- "$manifest_path") == "$stored_manifest_inode" ]] || \
    fail "managed files changed during reconfiguration; refusing update"

  reconfiguration_started=1
  [[ ! -L $output_path && $output_path -ef $previous_policy ]] || \
    fail "managed AGENTS.md changed before publication; refusing update"
  if ! mv -T -- "$replacement_policy" "$output_path"; then
    fail "could not publish replacement AGENTS.md"
  fi
  replaced[1]=1
  [[ ! -L $manifest_path && $manifest_path -ef $previous_manifest ]] || \
    fail "installation manifest changed before publication; refusing update"
  if ! mv -T -- "$replacement_manifest" "$manifest_path"; then
    fail "could not publish replacement installation manifest"
  fi
  replaced[0]=1
  if ! cmp -s -- "$output_path" "$policy_stage" || \
    ! cmp -s -- "$manifest_path" "$manifest_stage"; then
    fail "reconfigured files changed during publication"
  fi
  install_complete=1
  printf 'Reconfigured policy: %s\n' "$output_path"
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
