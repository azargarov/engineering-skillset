#!/usr/bin/env bash

program=${0##*/}

usage() {
  cat <<'USAGE'
Usage:
  scripts/install-policy.sh --target DIR --level ID [--priority ID ...] [--optional ID ...] [--dry-run]

Install a composed policy as DIR/AGENTS.md using the local Engineering
Skillset composer. The target directory must already exist. Existing AGENTS.md
files and symbolic links are never overwritten.

Use --dry-run to validate the selection and display the planned target without
changing the target directory. Use --help by itself to show this text.
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
      selection_args+=("$1")
      shift
      if (($#)) && [[ $1 != --* ]]; then
        selection_args+=("$1")
        shift
      fi
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
[[ -d $target_dir ]] || fail "target directory does not exist: '$target_dir'"
target_dir=$(CDPATH='' cd -- "$target_dir" && pwd -P) || \
  fail "cannot resolve target directory"
output_path=$target_dir/AGENTS.md
[[ ! -e $output_path && ! -L $output_path ]] || \
  fail "refusing to overwrite existing path '$output_path'"

script_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) || \
  fail "cannot locate the script directory"
composer=$script_dir/compose-policy.sh
[[ -x $composer ]] || fail "local composer is missing or not executable"

if ((dry_run)); then
  if "$composer" "${selection_args[@]}" > /dev/null; then
    :
  else
    exit "$?"
  fi
  printf 'Dry run: no target files changed.\nTarget: %s\nConfiguration:' "$output_path"
  printf ' %q' "${selection_args[@]}"
  printf '\n'
else
  if "$composer" "${selection_args[@]}" --output "$output_path"; then
    printf 'Installed policy: %s\n' "$output_path"
  else
    exit "$?"
  fi
fi
