#!/usr/bin/env bash

program=${0##*/}

usage() {
  cat <<'USAGE'
Usage:
  scripts/bootstrap-policy.sh --source https://github.com/OWNER/REPO \
    --revision COMMIT_SHA --sha256 ARCHIVE_SHA256 --target DIR \
    --level ID [--priority ID ...] [--optional ID ...] [--reconfigure] [--dry-run]

Download the GitHub source archive for one full commit SHA, verify its SHA-256,
validate and extract it in a temporary directory outside DIR, then run its
local installer to install the composed policy and four bundled Skills. The
target directory must already exist.

Use a trusted repository and obtain ARCHIVE_SHA256 through a trusted channel.
The commit URL identifies a revision but does not itself verify archive bytes.
The bootstrap does not fall back to another source. Use --help by itself to
show this text.
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

source_repo=''
source_seen=0
revision=''
revision_seen=0
expected_sha256=''
sha256_seen=0
target_dir=''
target_seen=0
installer_args=()

while (($#)); do
  case $1 in
    --source)
      (($# >= 2)) || fail "--source requires a GitHub repository URL"
      ((source_seen == 0)) || fail "--source may be supplied only once"
      source_repo=$2
      source_seen=1
      shift 2
      ;;
    --revision)
      (($# >= 2)) || fail "--revision requires a full commit SHA"
      ((revision_seen == 0)) || fail "--revision may be supplied only once"
      revision=$2
      revision_seen=1
      shift 2
      ;;
    --sha256)
      (($# >= 2)) || fail "--sha256 requires an archive digest"
      ((sha256_seen == 0)) || fail "--sha256 may be supplied only once"
      expected_sha256=$2
      sha256_seen=1
      shift 2
      ;;
    --target)
      (($# >= 2)) || fail "--target requires a directory"
      ((target_seen == 0)) || fail "--target may be supplied only once"
      target_dir=$2
      target_seen=1
      shift 2
      ;;
    --level|--priority|--optional)
      installer_args+=("$1")
      shift
      if (($#)) && [[ $1 != --* ]]; then
        installer_args+=("$1")
        shift
      fi
      ;;
    --dry-run)
      installer_args+=(--dry-run)
      shift
      ;;
    --reconfigure)
      installer_args+=(--reconfigure)
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

((source_seen)) || fail "missing required --source URL"
((revision_seen)) || fail "missing required --revision COMMIT_SHA"
((sha256_seen)) || fail "missing required --sha256 ARCHIVE_SHA256"
((target_seen)) || fail "missing required --target DIR"
[[ $source_repo =~ ^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/?$ ]] || \
  fail "--source must be an HTTPS GitHub repository URL without a .git suffix"
[[ $revision =~ ^[[:xdigit:]]{40}$ ]] || \
  fail "--revision must be a full 40-character hexadecimal commit SHA"
[[ $expected_sha256 =~ ^[[:xdigit:]]{64}$ ]] || \
  fail "--sha256 must be a 64-character hexadecimal digest"
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
target_dir=$(CDPATH='' cd -- "$target_dir" && pwd -P) || \
  fail "cannot resolve target directory"
[[ $target_logical == "$target_dir" ]] || \
  fail "target path must not traverse a symbolic link"
[[ $target_dir != / ]] || fail "target directory must not be the filesystem root"
source_repo=${source_repo%/}
revision=${revision,,}
expected_sha256=${expected_sha256,,}
archive_url=$source_repo/archive/$revision.tar.gz

for utility in curl sha256sum tar mktemp; do
  command -v "$utility" > /dev/null 2>&1 || fail "required utility is unavailable: $utility"
done

temp_parent=${TMPDIR:-/tmp}
[[ -d $temp_parent && -w $temp_parent ]] || \
  fail "temporary directory is missing or not writable: '$temp_parent'"
temp_parent=$(CDPATH='' cd -- "$temp_parent" && pwd -P) || \
  fail "cannot resolve temporary directory"
case "$temp_parent/" in
  "$target_dir/"*) fail "temporary directory must be outside the target directory" ;;
esac

temp_dir=$(mktemp -d "$temp_parent/engineering-skillset-bootstrap.XXXXXX") || \
  fail "cannot create temporary bootstrap directory"

# shellcheck disable=SC2329 # Invoked by the EXIT trap below.
cleanup() {
  local status=$?
  trap - EXIT
  if ! rm -rf -- "$temp_dir"; then
    error "failed to remove temporary bootstrap directory: $temp_dir"
    ((status != 0)) || status=1
  fi
  exit "$status"
}
trap 'cleanup' EXIT

archive_file=$temp_dir/source.tar.gz
member_list=$temp_dir/archive-members
verbose_list=$temp_dir/archive-details
extract_dir=$temp_dir/extracted

if ! curl --fail --location --silent --show-error \
  --proto '=https' --proto-redir '=https' \
  --output "$archive_file" "$archive_url"; then
  fail "download failed from '$archive_url'"
fi

if ! printf '%s  %s\n' "$expected_sha256" "$archive_file" | \
  sha256sum --check --status; then
  fail "downloaded archive SHA-256 does not match --sha256"
fi

if ! tar --quoting-style=escape -tzf "$archive_file" > "$member_list" || \
  ! tar --quoting-style=escape -tvzf "$archive_file" > "$verbose_list"; then
  fail "downloaded file is not a readable tar.gz archive"
fi
[[ -s $member_list ]] || fail "archive is empty"

archive_root=''
while IFS= read -r member; do
  [[ -n $member && $member != /* ]] || fail "archive contains an unsafe absolute or empty path"
  case "/$member/" in
    */../*) fail "archive contains an unsafe parent-directory path" ;;
  esac
  member=${member%/}
  [[ -n $member ]] || fail "archive contains an empty path"
  root=${member%%/*}
  [[ $root =~ ^[A-Za-z0-9_.-]+$ && $root != . && $root != .. ]] || \
    fail "archive has an invalid top-level directory"
  if [[ -z $archive_root ]]; then
    archive_root=$root
  elif [[ $root != "$archive_root" ]]; then
    fail "archive must contain exactly one top-level directory"
  fi
done < "$member_list"

while IFS= read -r details; do
  case ${details:0:1} in
    -|d) ;;
    *) fail "archive contains a link or unsupported file type" ;;
  esac
done < "$verbose_list"

mkdir "$extract_dir" || fail "cannot create extraction directory"
if ! tar -xzf "$archive_file" -C "$extract_dir" \
  --no-same-owner --no-same-permissions --no-overwrite-dir; then
  fail "archive extraction failed"
fi

source_root=$extract_dir/$archive_root
[[ -d $source_root && ! -L $source_root ]] || \
  fail "extracted source root is missing or invalid"
for source_file in AGENTS.md scripts/compose-policy.sh scripts/install-policy.sh; do
  [[ -f $source_root/$source_file && ! -L $source_root/$source_file && -r $source_root/$source_file ]] || \
    fail "source is missing a required file: '$source_file'"
done
for skill_id in software-design implementation-review verification-qa project-handover; do
  source_file=.agents/skills/$skill_id/SKILL.md
  [[ -f $source_root/$source_file && ! -L $source_root/$source_file && -r $source_root/$source_file ]] || \
    fail "source is missing a required Skill: '$skill_id'"
done
[[ -x $source_root/scripts/compose-policy.sh && -x $source_root/scripts/install-policy.sh ]] || \
  fail "source installer or composer is not executable"
[[ -d $source_root/modules/levels && -d $source_root/modules/priorities ]] || \
  fail "source module directories are missing"

installer_args=(--target "$target_dir" "${installer_args[@]}")
"$source_root/scripts/install-policy.sh" "${installer_args[@]}"
exit "$?"
