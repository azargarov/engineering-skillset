#!/usr/bin/env bash

program=${0##*/}

usage() {
  cat <<'USAGE'
Usage:
  scripts/install-policy.sh --target DIR --level ID [--priority ID ...] [--optional ID ...] [--reconfigure] [--dry-run]

Install a composed policy as DIR/AGENTS.md and the four bundled Skills under
DIR/.agents/skills using the local Engineering Skillset composer. The target
directory must already exist. A first install creates those managed files and
.engineering-skillset-manifest. Repeating the same configuration leaves them
unchanged. Changes require --reconfigure; modified managed files or an
inconsistent manifest are refused.

Add --reconfigure to explicitly replace a verified managed configuration. Use
--dry-run to validate the selection and display the plan without changing
the target directory. Existing user files and symbolic links are never replaced.
Skills are made available for explicit or context-appropriate invocation; they
are not mandatory for every task. See
docs/development/installation-metadata.md for the manifest format. Use --help
by itself to show this text.
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
agents_dir=$target_dir/.agents
skills_dir=$agents_dir/skills
skill_ids=(software-design implementation-review verification-qa project-handover)
skill_source_paths=()
skill_dest_paths=()
skill_stage_paths=()
stored_skill_hashes=()
skill_hashes=()
[[ ! -L $output_path ]] || fail "AGENTS.md must not be a symbolic link"
[[ ! -L $manifest_path ]] || fail "installation manifest must not be a symbolic link"
for directory in "$agents_dir" "$skills_dir"; do
  [[ ! -L $directory ]] || fail "Skill installation path must not be a symbolic link: '$directory'"
  [[ ! -e $directory || -d $directory ]] || fail "Skill installation path is not a directory: '$directory'"
done
for skill_id in "${skill_ids[@]}"; do
  skill_directory=$skills_dir/$skill_id
  skill_file=$skill_directory/SKILL.md
  [[ ! -L $skill_directory && (! -e $skill_directory || -d $skill_directory) ]] || \
    fail "Skill directory is not a safe directory: '$skill_directory'"
  [[ ! -L $skill_file ]] || fail "managed Skill file must not be a symbolic link: '$skill_file'"
  [[ ! -e $skill_file || -f $skill_file ]] || fail "Skill path is not a regular file: '$skill_file'"
  skill_dest_paths+=("$skill_file")
done

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
manifest_version=''
if ((agents_exists)); then
  [[ -f $output_path && -r $output_path ]] || \
    fail "managed AGENTS.md is not a readable regular file"
  [[ -f $manifest_path && -r $manifest_path ]] || \
    fail "installation manifest is not a readable regular file"
  manifest_lines=()
  mapfile -t manifest_lines < "$manifest_path"
  manifest_version=${manifest_lines[0]:-}
  case $manifest_version in
    engineering-skillset-manifest-v1)
      ((${#manifest_lines[@]} == 3)) || fail "installation manifest is malformed"
      stored_skill_hashes=( '' '' '' '' )
      ;;
    engineering-skillset-manifest-v2)
      ((${#manifest_lines[@]} == 7)) || fail "installation manifest is malformed"
      ;;
    *) fail "installation manifest has an unsupported format" ;;
  esac
  [[ ${manifest_lines[1]} =~ ^policy_sha256=([0-9a-f]{64})$ ]] || \
    fail "installation manifest has an invalid policy digest"
  stored_policy_sha=${BASH_REMATCH[1]}
  if [[ $manifest_version == engineering-skillset-manifest-v2 ]]; then
    for ((skill_index=0; skill_index<${#skill_ids[@]}; skill_index++)); do
      expected_prefix="skill_${skill_ids[skill_index]}_sha256="
      [[ ${manifest_lines[skill_index+2]} == "$expected_prefix"* ]] || \
        fail "installation manifest is missing a Skill digest for '${skill_ids[skill_index]}'"
      skill_digest=${manifest_lines[skill_index+2]#"$expected_prefix"}
      [[ $skill_digest =~ ^[0-9a-f]{64}$ ]] || \
        fail "installation manifest has an invalid Skill digest for '${skill_ids[skill_index]}'"
      stored_skill_hashes+=("$skill_digest")
      [[ -f ${skill_dest_paths[skill_index]} && -r ${skill_dest_paths[skill_index]} ]] || \
        fail "managed Skill file is missing or unreadable: '${skill_dest_paths[skill_index]}'"
      current_skill_sha=$(sha256sum -- "${skill_dest_paths[skill_index]}") || \
        fail "cannot verify managed Skill '${skill_ids[skill_index]}'"
      current_skill_sha=${current_skill_sha%% *}
      [[ $current_skill_sha == "$skill_digest" ]] || \
        fail "managed Skill '${skill_ids[skill_index]}' was modified; refusing to replace it"
    done
  else
    for skill_file in "${skill_dest_paths[@]}"; do
      [[ ! -e $skill_file ]] || \
        fail "unmanaged Skill file already exists; refusing to overwrite: '$skill_file'"
    done
  fi
  configuration_line_index=$((${#manifest_lines[@]} - 1))
  [[ ${manifest_lines[configuration_line_index]} == configuration=* ]] || \
    fail "installation manifest has no configuration"
  stored_configuration=${manifest_lines[configuration_line_index]#configuration=}
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
  stored_skill_inodes=()
  for skill_index in "${!skill_dest_paths[@]}"; do
    if [[ -n ${stored_skill_hashes[skill_index]:-} ]]; then
      stored_skill_inode=$(stat -c '%d:%i' -- "${skill_dest_paths[skill_index]}") || \
        fail "cannot inspect managed Skill '${skill_ids[skill_index]}'"
      stored_skill_inodes+=("$stored_skill_inode")
    else
      stored_skill_inodes+=('')
    fi
  done
fi
for skill_index in "${!skill_dest_paths[@]}"; do
  if [[ -z ${stored_skill_hashes[skill_index]:-} && -e ${skill_dest_paths[skill_index]} ]]; then
    fail "unmanaged Skill file already exists; refusing to overwrite: '${skill_dest_paths[skill_index]}'"
  fi
  if [[ -z ${stored_skill_hashes[skill_index]:-} && \
    -d $skills_dir/${skill_ids[skill_index]} ]]; then
    fail "unmanaged Skill directory already exists; refusing to use it: '$skills_dir/${skill_ids[skill_index]}'"
  fi
done
((!reconfigure || agents_exists)) || \
  fail "there is no managed installation to reconfigure"

script_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) || \
  fail "cannot locate the script directory"
composer=$script_dir/compose-policy.sh
[[ -x $composer ]] || fail "local composer is missing or not executable"
skill_source_root=$script_dir/../.agents/skills
for skill_id in "${skill_ids[@]}"; do
  skill_source=$skill_source_root/$skill_id/SKILL.md
  [[ -f $skill_source && ! -L $skill_source && -r $skill_source ]] || \
    fail "bundled Skill is missing or unreadable: '$skill_id'"
  skill_source_paths+=("$skill_source")
done
for utility in cmp cp ln mkdir mktemp mv rm rmdir sha256sum sort stat; do
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
for skill_index in "${!skill_ids[@]}"; do
  skill_stage_paths+=("$stage_dir/skill-${skill_ids[skill_index]}/SKILL.md")
done
publication_destinations=("$output_path" "${skill_dest_paths[@]}" "$manifest_path")
publication_stages=("$policy_stage" "${skill_stage_paths[@]}" "$manifest_stage")
replacement_paths=()
replacement_guard_paths=()
backup_paths=()
publication_hashes=()
publication_modes=()
prior_exists=()
publication_changes=()
created_dirs=()
manifest_publication_index=$((${#skill_ids[@]} + 1))
for publication_index in "${!publication_destinations[@]}"; do
  if ((publication_index == 0)); then
    publication_name=AGENTS.md
  elif ((publication_index == manifest_publication_index)); then
    publication_name=manifest
  else
    publication_name="skill-${skill_ids[publication_index-1]}"
  fi
  replacement_paths+=("$stage_dir/replacement-$publication_name")
  replacement_guard_paths+=("$stage_dir/replacement-guard-$publication_name")
  backup_paths+=("$stage_dir/previous-$publication_name")
  if [[ -e ${publication_destinations[publication_index]} ]]; then
    prior_exists+=(1)
  else
    prior_exists+=(0)
  fi
done
install_complete=0
published=()
reconfiguration_started=0
replaced=()

cleanup() {
  local status=$?
  local rollback_failed=0
  trap - EXIT
  if ((!install_complete && reconfiguration_started)); then
    for ((index=${#publication_destinations[@]}-1; index>=0; index--)); do
      ((replaced[index])) || continue
      destination=${publication_destinations[index]}
      if [[ -e $destination && ! -L $destination && \
        $destination -ef ${replacement_guard_paths[index]} ]]; then
        current_sha=$(sha256sum -- "$destination") || current_sha=''
        current_sha=${current_sha%% *}
        current_mode=$(stat -c '%a' -- "$destination") || current_mode=''
        if [[ $current_sha == "${publication_hashes[index]}" && \
          $current_mode == "${publication_modes[index]}" ]]; then
          if ((prior_exists[index])); then
            if ! mv -T -- "${backup_paths[index]}" "$destination"; then
              error "failed to restore '$destination'; recovery file remains in '$stage_dir'"
              ((status != 0)) || status=1
              rollback_failed=1
            fi
          elif ! rm -f -- "$destination"; then
            error "failed to remove newly published '$destination'"
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
    for ((index=${#publication_destinations[@]}-1; index>=0; index--)); do
      ((published[index])) || continue
      destination=${publication_destinations[index]}
      staged=${publication_stages[index]}
      if [[ -e $destination && ! -L $destination && $destination -ef $staged ]]; then
        current_sha=$(sha256sum -- "$destination") || current_sha=''
        current_sha=${current_sha%% *}
        current_mode=$(stat -c '%a' -- "$destination") || current_mode=''
        if [[ $current_sha == "${publication_hashes[index]:-}" && \
          $current_mode == "${publication_modes[index]:-}" ]]; then
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
  if ((!install_complete)); then
    for ((index=${#created_dirs[@]}-1; index>=0; index--)); do
      if ! rmdir -- "${created_dirs[index]}" 2>/dev/null; then
        error "failed to remove created directory '${created_dirs[index]}'"
        ((status != 0)) || status=1
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

ensure_directory() {
  local directory=$1
  if [[ -e $directory ]]; then
    [[ -d $directory && ! -L $directory ]] || \
      fail "Skill installation path is not a safe directory: '$directory'"
  else
    mkdir -- "$directory" || fail "cannot create Skill installation directory: '$directory'"
    created_dirs+=("$directory")
  fi
}

if ! "$composer" "${selection_args[@]}" --output "$policy_stage"; then
  fail "policy composition failed"
fi
policy_sha=$(sha256sum -- "$policy_stage") || fail "cannot hash composed policy"
policy_sha=${policy_sha%% *}
policy_stage_mode=$(stat -c '%a' -- "$policy_stage") || fail "cannot read composed policy permissions"
for skill_index in "${!skill_ids[@]}"; do
  mkdir -- "$(dirname -- "${skill_stage_paths[skill_index]}")" || \
    fail "cannot create Skill staging directory"
  cp -- "${skill_source_paths[skill_index]}" "${skill_stage_paths[skill_index]}" || \
    fail "cannot stage Skill '${skill_ids[skill_index]}'"
  skill_sha=$(sha256sum -- "${skill_stage_paths[skill_index]}") || \
    fail "cannot hash staged Skill '${skill_ids[skill_index]}'"
  skill_hashes+=("${skill_sha%% *}")
done
printf 'engineering-skillset-manifest-v2\npolicy_sha256=%s\n' \
  "$policy_sha" > "$manifest_stage" || fail "cannot write installation manifest"
for skill_index in "${!skill_ids[@]}"; do
  printf 'skill_%s_sha256=%s\n' "${skill_ids[skill_index]}" \
    "${skill_hashes[skill_index]}" >> "$manifest_stage" || \
    fail "cannot write Skill ownership metadata"
done
printf 'configuration=%s\n' "$selection_config" >> "$manifest_stage" || \
  fail "cannot write installation manifest"
manifest_mode=$(stat -c '%a' -- "$manifest_stage") || \
  fail "cannot read installation manifest permissions"
manifest_sha=$(sha256sum -- "$manifest_stage") || fail "cannot hash installation manifest"
manifest_sha=${manifest_sha%% *}
publication_hashes=("$policy_sha" "${skill_hashes[@]}" "$manifest_sha")
publication_modes=("$policy_stage_mode")
for skill_stage in "${skill_stage_paths[@]}"; do
  publication_modes+=("$(stat -c '%a' -- "$skill_stage")") || \
    fail "cannot read staged Skill permissions"
done
publication_modes+=("$manifest_mode")
published=()
replaced=()
for publication_index in "${!publication_destinations[@]}"; do
  published+=(0)
  replaced+=(0)
  if ((prior_exists[publication_index])) && \
    cmp -s -- "${publication_destinations[publication_index]}" \
      "${publication_stages[publication_index]}"; then
    publication_changes+=(0)
  else
    publication_changes+=(1)
  fi
done

if ((agents_exists)); then
  if [[ $stored_configuration == "$selection_config" && \
    $stored_policy_sha == "$policy_sha" ]] && \
    cmp -s -- "$output_path" "$policy_stage" && \
    cmp -s -- "$manifest_path" "$manifest_stage"; then
    skills_current=1
    for skill_index in "${!skill_dest_paths[@]}"; do
      [[ -n ${stored_skill_hashes[skill_index]:-} && \
        ${stored_skill_hashes[skill_index]} == "${skill_hashes[skill_index]}" ]] || {
        skills_current=0
        break
      }
      cmp -s -- "${skill_dest_paths[skill_index]}" "${skill_stage_paths[skill_index]}" || {
        skills_current=0
        break
      }
    done
    if ((skills_current)); then
      install_complete=1
      if ((dry_run)); then
        printf 'Dry run: installation is already current.\nTarget: %s\nSkills: %s\n' \
          "$output_path" "$skills_dir"
      else
        printf 'Installation is already current: %s\nSkills: %s\n' \
          "$output_path" "$skills_dir"
      fi
      exit 0
    fi
  fi

  if ((!reconfigure)); then
    fail "requested installation differs; use --reconfigure to authorize changes"
  fi
  if ((dry_run)); then
    install_complete=1
    printf 'Dry run: would reconfigure managed installation.\nTarget: %s\nSkills: %s\nCurrent configuration: %s\nRequested configuration: %s\n' \
      "$output_path" "$skills_dir" "$stored_configuration" "$selection_config"
    exit 0
  fi

  ensure_directory "$agents_dir"
  ensure_directory "$skills_dir"
  for skill_id in "${skill_ids[@]}"; do
    ensure_directory "$skills_dir/$skill_id"
  done
  for publication_index in "${!publication_destinations[@]}"; do
    ((publication_changes[publication_index])) || continue
    destination=${publication_destinations[publication_index]}
    if ((prior_exists[publication_index])); then
      ln -T -- "$destination" "${backup_paths[publication_index]}" || \
        fail "cannot create recovery copy of managed file '$destination'"
    fi
    ln -T -- "${publication_stages[publication_index]}" \
      "${replacement_paths[publication_index]}" || \
      fail "cannot stage replacement file '$destination'"
    ln -T -- "${replacement_paths[publication_index]}" \
      "${replacement_guard_paths[publication_index]}" || \
      fail "cannot verify staged replacement '$destination'"
  done
  current_policy_sha=$(sha256sum -- "$output_path") || current_policy_sha=''
  current_policy_sha=${current_policy_sha%% *}
  current_manifest_sha=$(sha256sum -- "$manifest_path") || current_manifest_sha=''
  current_manifest_sha=${current_manifest_sha%% *}
  [[ $current_policy_sha == "$stored_policy_sha" && \
    $current_manifest_sha == "$stored_manifest_sha" && \
    $(stat -c '%d:%i' -- "$output_path") == "$stored_policy_inode" && \
    $(stat -c '%d:%i' -- "$manifest_path") == "$stored_manifest_inode" ]] || \
    fail "managed files changed during reconfiguration; refusing update"
  for publication_index in 0 "$manifest_publication_index"; do
    if ((publication_changes[publication_index])); then
      [[ ${publication_destinations[publication_index]} -ef \
        ${backup_paths[publication_index]} ]] || \
        fail "managed file changed during reconfiguration: '${publication_destinations[publication_index]}'"
    fi
  done
  for skill_index in "${!skill_dest_paths[@]}"; do
    if ((!publication_changes[skill_index+1])); then
      continue
    elif [[ -n ${stored_skill_hashes[skill_index]:-} ]]; then
      current_skill_sha=$(sha256sum -- "${skill_dest_paths[skill_index]}") || current_skill_sha=''
      current_skill_sha=${current_skill_sha%% *}
      [[ ${skill_dest_paths[skill_index]} -ef ${backup_paths[skill_index+1]} && \
        $current_skill_sha == "${stored_skill_hashes[skill_index]}" && \
        $(stat -c '%d:%i' -- "${skill_dest_paths[skill_index]}") == \
          "${stored_skill_inodes[skill_index]}" ]] || \
        fail "managed Skill changed during reconfiguration; refusing update"
    else
      [[ ! -e ${skill_dest_paths[skill_index]} && ! -L ${skill_dest_paths[skill_index]} ]] || \
        fail "Skill destination appeared during reconfiguration; refusing update"
    fi
  done

  reconfiguration_started=1
  for publication_index in "${!publication_destinations[@]}"; do
    ((publication_changes[publication_index])) || continue
    destination=${publication_destinations[publication_index]}
    if ((prior_exists[publication_index])); then
      [[ ! -L $destination && $destination -ef ${backup_paths[publication_index]} ]] || \
        fail "managed file changed before publication: '$destination'"
      mv -T -- "${replacement_paths[publication_index]}" "$destination" || \
        fail "could not publish replacement '$destination'"
      replaced[publication_index]=1
    else
      ln -T -- "${publication_stages[publication_index]}" "$destination" || \
        fail "could not publish Skill without overwriting: '$destination'"
      published[publication_index]=1
    fi
  done
  for publication_index in "${!publication_destinations[@]}"; do
    cmp -s -- "${publication_destinations[publication_index]}" \
      "${publication_stages[publication_index]}" || \
      fail "reconfigured file changed during publication: '${publication_destinations[publication_index]}'"
  done
  install_complete=1
  printf 'Reconfigured installation: %s\nSkills: %s\n' "$output_path" "$skills_dir"
  exit 0
fi

if ((dry_run)); then
  install_complete=1
  printf 'Dry run: would install policy, Skills, and manifest.\nTarget: %s\nSkills: %s\nConfiguration: %s\n' \
    "$output_path" "$skills_dir" "$selection_config"
  exit 0
fi

ensure_directory "$agents_dir"
ensure_directory "$skills_dir"
for skill_id in "${skill_ids[@]}"; do
  ensure_directory "$skills_dir/$skill_id"
done
for publication_index in "${!publication_destinations[@]}"; do
  ln -T -- "${publication_stages[publication_index]}" \
    "${publication_destinations[publication_index]}" || \
    fail "could not publish managed file without overwriting: '${publication_destinations[publication_index]}'"
  published[publication_index]=1
done
for publication_index in "${!publication_destinations[@]}"; do
  if [[ ! ${publication_destinations[publication_index]} -ef ${publication_stages[publication_index]} ]] || \
    ! cmp -s -- "${publication_destinations[publication_index]}" \
      "${publication_stages[publication_index]}"; then
    fail "installed file changed during publication: '${publication_destinations[publication_index]}'"
  fi
done
install_complete=1
printf 'Installed policy: %s\nSkills: %s\n' "$output_path" "$skills_dir"
