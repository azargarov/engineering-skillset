#!/usr/bin/env bash

program=${0##*/}

usage() {
  cat <<'USAGE'
Usage:
  scripts/compose-policy.sh --level ID [--priority ID ...] [--optional ID ...] [--output PATH]

Compose the root AGENTS.md Core Policy, exactly one project level, selected
priorities, and selected optional modules into one standalone Markdown policy.
With no --output, write the completed policy to stdout. --output requires a new
path; existing files are never overwritten. Module IDs are filenames without
the .md suffix. Priorities and optional modules are emitted in ID order.

Examples:
  scripts/compose-policy.sh --level personal
  scripts/compose-policy.sh --level personal --priority readability
  scripts/compose-policy.sh --level personal \
    --priority readability --priority development-speed --output /tmp/policy.md

Use --help by itself to show this text. This local prototype does not install
the policy or select workflow Skills.
USAGE
}

error() {
  printf '%s: %s\n' "$program" "$*" >&2
}

fail() {
  error "$*"
  exit 2
}

valid_id() {
  local id=$1
  [[ $id =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

already_selected() {
  local wanted=$1
  shift
  local selected
  for selected in "$@"; do
    [[ $selected == "$wanted" ]] && return 0
  done
  return 1
}

sort_ids() {
  if (($#)); then
    printf '%s\n' "$@" | LC_ALL=C sort
  fi
}

if (($# == 1)) && [[ $1 == --help ]]; then
  usage
  exit 0
fi

level_id=''
level_seen=0
priority_ids=()
optional_ids=()
output_path=''
output_seen=0

while (($#)); do
  case $1 in
    --level)
      (($# >= 2)) || fail "--level requires an ID"
      ((level_seen == 0)) || fail "select exactly one project level; --level was repeated"
      level_id=$2
      valid_id "$level_id" || fail "invalid project-level ID '$level_id'"
      level_seen=1
      shift 2
      ;;
    --priority)
      (($# >= 2)) || fail "--priority requires an ID"
      valid_id "$2" || fail "invalid priority ID '$2'"
      already_selected "$2" "${priority_ids[@]}" && fail "duplicate priority '$2'"
      priority_ids+=("$2")
      shift 2
      ;;
    --optional)
      (($# >= 2)) || fail "--optional requires an ID"
      valid_id "$2" || fail "invalid optional-module ID '$2'"
      already_selected "$2" "${optional_ids[@]}" && fail "duplicate optional module '$2'"
      optional_ids+=("$2")
      shift 2
      ;;
    --output)
      (($# >= 2)) || fail "--output requires a path"
      ((output_seen == 0)) || fail "--output may be supplied only once"
      output_path=$2
      [[ -n $output_path ]] || fail "--output requires a non-empty path"
      output_seen=1
      shift 2
      ;;
    --help)
      fail "--help must be used by itself"
      ;;
    *)
      fail "unknown argument '$1'"
      ;;
  esac
done

((level_seen == 1)) || fail "missing required --level ID"

script_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) || \
  fail "cannot locate the script directory"
root_dir=$(CDPATH='' cd -- "$script_dir/.." && pwd -P) || \
  fail "cannot locate the repository root"

core_file=$root_dir/AGENTS.md
[[ -f $core_file && -r $core_file ]] || fail "Core Policy file is missing or unreadable: AGENTS.md"

level_file=$root_dir/modules/levels/$level_id.md
[[ ! -L $level_file ]] || fail "symlinked project level '$level_id' is not supported"
[[ -f $level_file && -r $level_file ]] || fail "unknown or unreadable project level '$level_id'"

for id in "${priority_ids[@]}"; do
  file=$root_dir/modules/priorities/$id.md
  [[ ! -L $file ]] || fail "symlinked priority module '$id' is not supported"
  [[ -f $file && -r $file ]] || fail "unknown or unreadable priority '$id'"
done

for id in "${optional_ids[@]}"; do
  file=$root_dir/modules/optional/$id.md
  [[ ! -L $file ]] || fail "symlinked optional module '$id' is not supported"
  [[ -f $file && -r $file ]] || fail "unknown or unreadable optional module '$id'"
done

if ((output_seen)); then
  if [[ $output_path == */* ]]; then
    output_dir=${output_path%/*}
    output_name=${output_path##*/}
    [[ -n $output_dir ]] || output_dir=/
  else
    output_dir=.
    output_name=$output_path
  fi
  [[ -n $output_name && $output_name != . && $output_name != .. ]] || \
    fail "--output must name a file"
  [[ -d $output_dir ]] || fail "output directory does not exist: '$output_dir'"
  [[ -w $output_dir ]] || fail "output directory is not writable: '$output_dir'"
  [[ ! -e $output_path && ! -L $output_path ]] || \
    fail "refusing to overwrite existing path '$output_path'"
  temp_template=$output_dir/.engineering-policy.XXXXXX
else
  temp_dir=${TMPDIR:-/tmp}
  [[ -d $temp_dir && -w $temp_dir ]] || fail "temporary directory is not writable: '$temp_dir'"
  temp_template=$temp_dir/engineering-policy.XXXXXX
fi

tmp_file=$(mktemp "$temp_template" 2>/dev/null) || \
  fail "cannot create a temporary output file"

cleanup() {
  if [[ -n ${tmp_file:-} ]]; then
    rm -f -- "$tmp_file" 2>/dev/null || true
  fi
}
trap cleanup EXIT

if ! cat "$core_file" > "$tmp_file"; then
  fail "failed while reading Core Policy"
fi

module_files=("$level_file")

sorted_ids=$(sort_ids "${priority_ids[@]}") || fail "could not sort priority IDs"
sorted_priority_ids=()
if [[ -n $sorted_ids ]]; then
  mapfile -t sorted_priority_ids <<< "$sorted_ids"
fi
for id in "${sorted_priority_ids[@]}"; do
  module_files+=("$root_dir/modules/priorities/$id.md")
done

sorted_ids=$(sort_ids "${optional_ids[@]}") || fail "could not sort optional-module IDs"
sorted_optional_ids=()
if [[ -n $sorted_ids ]]; then
  mapfile -t sorted_optional_ids <<< "$sorted_ids"
fi
for id in "${sorted_optional_ids[@]}"; do
  file=$root_dir/modules/optional/$id.md
  if grep -q '[^[:space:]]' "$file"; then
    module_files+=("$file")
  else
    grep_status=$?
    ((grep_status == 1)) || fail "failed while reading optional module '$id'"
  fi
done

section_headings=()
section_files=()
for file in "$core_file" "${module_files[@]}"; do
  heading=''
  IFS= read -r heading < "$file" || [[ -n $heading ]] || \
    fail "section is empty: '$file'"
  [[ $heading == '# '* ]] || fail "section must begin with an H1 heading: '$file'"
  for selected_file in "${section_files[@]}"; do
    cmp -s -- "$file" "$selected_file" && \
      fail "duplicate section content in '$file' and '$selected_file'"
  done
  already_selected "$heading" "${section_headings[@]}" && \
    fail "duplicate section heading '$heading'"
  section_headings+=("$heading")
  section_files+=("$file")
done

for file in "${module_files[@]}"; do
  if ! printf '\n' >> "$tmp_file" || ! cat "$file" >> "$tmp_file"; then
    fail "failed while reading selected module '$(basename -- "$file" .md)'"
  fi
done

if ((output_seen)); then
  file_umask=$(umask) || fail "cannot read file creation mask"
  output_mode=$(printf '%04o' "$((0666 & ~8#$file_umask))") || \
    fail "cannot calculate output permissions"
  chmod "$output_mode" -- "$tmp_file" || \
    fail "cannot set output permissions"
  if ! ln -T -- "$tmp_file" "$output_path" 2>/dev/null; then
    fail "could not create output at '$output_path' without overwriting"
  fi
  if ! rm -f -- "$tmp_file"; then
    fail "output was created but temporary-file cleanup failed"
  fi
  tmp_file=''
else
  if ! cat "$tmp_file"; then
    fail "failed while writing policy to stdout"
  fi
fi
