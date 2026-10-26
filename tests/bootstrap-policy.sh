#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

test_dir=$(mktemp -d "${TMPDIR:-/tmp}/bootstrap-policy-test.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT

repo_root=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
bootstrap=$repo_root/scripts/bootstrap-policy.sh
revision=0123456789abcdef0123456789abcdef01234567
source_repo=https://github.com/example/engineering-skillset
mock_bin=$test_dir/mock-bin
temp_parent=$test_dir/bootstrap-tmp
download_log=$test_dir/download-urls
mock_archive=''
archive_sha=''
curl_fail=0

mkdir "$mock_bin" "$temp_parent" "$test_dir/source"
cat > "$mock_bin/curl" <<'MOCK_CURL'
#!/usr/bin/env bash
set -euo pipefail
output=''
url=''
while (($#)); do
  case $1 in
    --output)
      output=$2
      shift 2
      ;;
    --proto|--proto-redir)
      shift 2
      ;;
    --fail|--location|--silent|--show-error)
      shift
      ;;
    *)
      url=$1
      shift
      ;;
  esac
done
printf '%s\n' "$url" >> "$BOOTSTRAP_DOWNLOAD_LOG"
if [[ ${BOOTSTRAP_CURL_FAIL:-0} == 1 ]]; then
  exit 22
fi
cp -- "$BOOTSTRAP_ARCHIVE" "$output"
MOCK_CURL
chmod +x "$mock_bin/curl"

source_root=$test_dir/source/engineering-skillset-$revision
mkdir -p "$source_root/scripts" "$source_root/modules"
cp AGENTS.md "$source_root/AGENTS.md"
cp scripts/compose-policy.sh scripts/install-policy.sh "$source_root/scripts/"
cp -a modules/levels modules/priorities "$source_root/modules/"
valid_archive=$test_dir/valid.tar.gz
tar -czf "$valid_archive" -C "$test_dir/source" "${source_root##*/}"
mock_archive=$valid_archive
archive_sha=$(sha256sum "$valid_archive" | cut -d' ' -f1)

invoke_bootstrap() {
  PATH="$mock_bin:$PATH" \
    BOOTSTRAP_ARCHIVE="$mock_archive" \
    BOOTSTRAP_DOWNLOAD_LOG="$download_log" \
    BOOTSTRAP_CURL_FAIL="$curl_fail" \
    TMPDIR="$temp_parent" \
    "$bootstrap" --source "$source_repo" --revision "$revision" \
      --sha256 "$archive_sha" --target "$1" "${@:2}"
}

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

expect_failure() {
  local expected=$1
  local target=$2
  shift 2
  if invoke_bootstrap "$target" "$@" > "$test_dir/stdout" 2> "$test_dir/stderr"; then
    fail "bootstrap unexpectedly succeeded: $*"
  fi
  grep -Fq -- "$expected" "$test_dir/stderr" || {
    cat "$test_dir/stderr" >&2
    fail "expected error '$expected' for: $*"
  }
  if [[ -d $target ]]; then
    [[ -z $(find "$target" -mindepth 1 -print -quit) ]] || \
      fail "failed bootstrap changed target '$target'"
  else
    [[ ! -e $target ]] || fail "failed bootstrap created target '$target'"
  fi
  [[ -z $(find "$temp_parent" -mindepth 1 -print -quit) ]] || \
    fail "failed bootstrap left temporary files"
}

"$bootstrap" --help > "$test_dir/help"
grep -Fq -- '--sha256 ARCHIVE_SHA256' "$test_dir/help" || \
  fail "help omits archive integrity requirement"

mkdir "$test_dir/install-target"
printf 'user-owned project file\n' > "$test_dir/install-target/README.local"
user_file_sha=$(sha256sum "$test_dir/install-target/README.local")
"$repo_root/scripts/compose-policy.sh" --level personal --priority readability \
  > "$test_dir/expected.md"
invoke_bootstrap "$test_dir/install-target" --level personal \
  --priority readability > "$test_dir/install.log"
cmp -s "$test_dir/expected.md" "$test_dir/install-target/AGENTS.md" || \
  fail "bootstrapped policy differs from composer output"
[[ -f $test_dir/install-target/.engineering-skillset-manifest ]] || \
  fail "bootstrapped installation omitted its manifest"
[[ $(find "$test_dir/install-target" -mindepth 1 -maxdepth 1 -type f | wc -l) == 3 ]] || \
  fail "bootstrap created unexpected target files"
[[ $(sha256sum "$test_dir/install-target/README.local") == "$user_file_sha" ]] || \
  fail "bootstrap modified a user-owned project file"
[[ -z $(find "$temp_parent" -mindepth 1 -print -quit) ]] || \
  fail "successful bootstrap left temporary files"
grep -Fq -- "$source_repo/archive/$revision.tar.gz" "$download_log" || \
  fail "bootstrap used an unexpected source endpoint"

initial_policy_stat=$(stat -c '%d:%i:%Y' "$test_dir/install-target/AGENTS.md")
initial_manifest_stat=$(stat -c '%d:%i:%Y' \
  "$test_dir/install-target/.engineering-skillset-manifest")
invoke_bootstrap "$test_dir/install-target" --level personal \
  --priority readability > "$test_dir/repeat.log"
[[ $(stat -c '%d:%i:%Y' "$test_dir/install-target/AGENTS.md") == "$initial_policy_stat" && \
  $(stat -c '%d:%i:%Y' "$test_dir/install-target/.engineering-skillset-manifest") == "$initial_manifest_stat" ]] || \
  fail "identical bootstrap installation rewrote managed files"

old_bootstrap_policy=$(sha256sum "$test_dir/install-target/AGENTS.md")
old_bootstrap_manifest=$(sha256sum "$test_dir/install-target/.engineering-skillset-manifest")
if invoke_bootstrap "$test_dir/install-target" --level personal \
  --priority development-speed > "$test_dir/stdout" 2> "$test_dir/stderr"; then
  fail "bootstrap changed configuration without explicit reconfiguration"
fi
grep -Fq -- 'use --reconfigure' "$test_dir/stderr" || \
  fail "bootstrap did not preserve installer reconfiguration error"
[[ $(sha256sum "$test_dir/install-target/AGENTS.md") == "$old_bootstrap_policy" && \
  $(sha256sum "$test_dir/install-target/.engineering-skillset-manifest") == "$old_bootstrap_manifest" ]] || \
  fail "unauthorized bootstrap reconfiguration changed managed files"
invoke_bootstrap "$test_dir/install-target" --level personal \
  --priority development-speed --reconfigure --dry-run > "$test_dir/reconfigure-dry-run.log"
grep -Fq -- 'Current configuration: level=personal;priority=readability' \
  "$test_dir/reconfigure-dry-run.log" || \
  fail "bootstrap reconfiguration dry-run omitted current selections"
grep -Fq -- 'Requested configuration: level=personal;priority=development-speed' \
  "$test_dir/reconfigure-dry-run.log" || \
  fail "bootstrap reconfiguration dry-run omitted requested selections"
[[ $(sha256sum "$test_dir/install-target/AGENTS.md") == "$old_bootstrap_policy" && \
  $(sha256sum "$test_dir/install-target/.engineering-skillset-manifest") == "$old_bootstrap_manifest" ]] || \
  fail "bootstrap reconfiguration dry-run modified managed files"
invoke_bootstrap "$test_dir/install-target" --level personal \
  --priority development-speed --reconfigure > "$test_dir/reconfigure.log"
"$repo_root/scripts/compose-policy.sh" --level personal \
  --priority development-speed > "$test_dir/reconfigure-expected.md"
cmp -s "$test_dir/reconfigure-expected.md" "$test_dir/install-target/AGENTS.md" || \
  fail "bootstrap did not forward --reconfigure to installer"
grep -Fq -- 'configuration=level=personal;priority=development-speed' \
  "$test_dir/install-target/.engineering-skillset-manifest" || \
  fail "bootstrap reconfiguration did not update manifest"
[[ $(sha256sum "$test_dir/install-target/README.local") == "$user_file_sha" ]] || \
  fail "reconfiguration modified a user-owned project file"
printf '\nlocal policy edit\n' >> "$test_dir/install-target/AGENTS.md"
modified_policy=$(sha256sum "$test_dir/install-target/AGENTS.md")
current_manifest=$(sha256sum "$test_dir/install-target/.engineering-skillset-manifest")
if invoke_bootstrap "$test_dir/install-target" --level personal \
  --priority readability --reconfigure > "$test_dir/stdout" 2> "$test_dir/stderr"; then
  fail "bootstrap replaced a user-modified managed policy"
fi
grep -Fq -- 'managed AGENTS.md was modified' "$test_dir/stderr" || \
  fail "bootstrap did not preserve modified-policy refusal"
[[ $(sha256sum "$test_dir/install-target/AGENTS.md") == "$modified_policy" && \
  $(sha256sum "$test_dir/install-target/.engineering-skillset-manifest") == "$current_manifest" ]] || \
  fail "bootstrap modified files after refusing a user edit"
[[ -z $(find "$temp_parent" -mindepth 1 -print -quit) ]] || \
  fail "bootstrap reconfiguration left temporary files"

mkdir "$test_dir/dry-target"
invoke_bootstrap "$test_dir/dry-target" --level personal \
  --priority development-speed --dry-run > "$test_dir/dry-run.log"
grep -Fq -- 'Configuration: level=personal;priority=development-speed' \
  "$test_dir/dry-run.log" || \
  fail "bootstrap did not forward installer selections"
[[ -z $(find "$test_dir/dry-target" -mindepth 1 -print -quit) ]] || \
  fail "dry-run modified target"
[[ -z $(find "$temp_parent" -mindepth 1 -print -quit) ]] || \
  fail "dry-run left temporary files"

mkdir "$test_dir/invalid-revision-target"
log_lines=$(wc -l < "$download_log")
revision=not-a-commit
expect_failure "full 40-character hexadecimal commit SHA" \
  "$test_dir/invalid-revision-target" --level personal
revision=0123456789abcdef0123456789abcdef01234567
[[ $(wc -l < "$download_log") == "$log_lines" ]] || \
  fail "invalid revision initiated a download"
expect_failure "unknown argument" "$test_dir/invalid-revision-target" \
  --level personal --unexpected
[[ $(wc -l < "$download_log") == "$log_lines" ]] || \
  fail "unsupported argument initiated a download"
expect_failure "target directory does not exist" "$test_dir/missing-target" \
  --level personal
[[ $(wc -l < "$download_log") == "$log_lines" ]] || \
  fail "missing target initiated a download"

mkdir "$test_dir/linked-target" "$test_dir/real-parent"
ln -s "$test_dir/linked-target" "$test_dir/target-link"
expect_failure "target directory must not be a symbolic link" \
  "$test_dir/target-link" --level personal
mkdir "$test_dir/real-parent/child"
ln -s "$test_dir/real-parent" "$test_dir/parent-link"
expect_failure "target path must not traverse a symbolic link" \
  "$test_dir/parent-link/child" --level personal
expect_failure "target path must not contain a '..' component" \
  "$test_dir/linked-target/../linked-target" --level personal
[[ $(wc -l < "$download_log") == "$log_lines" ]] || \
  fail "unsafe target path initiated a download"
[[ -z $(find "$test_dir/linked-target" -mindepth 1 -print -quit) ]] || \
  fail "unsafe target path modified the resolved directory"

mkdir "$test_dir/target with spaces"
invoke_bootstrap "$test_dir/target with spaces/" --level personal --dry-run \
  > "$test_dir/spaced-target-dry-run.log"
grep -Fq -- "$test_dir/target with spaces/AGENTS.md" \
  "$test_dir/spaced-target-dry-run.log" || \
  fail "valid target path containing spaces was rejected or misreported"
[[ -z $(find "$test_dir/target with spaces" -mindepth 1 -print -quit) ]] || \
  fail "valid spaced target dry-run modified the target"

mkdir "$test_dir/download-failure-target"
curl_fail=1
expect_failure "download failed" "$test_dir/download-failure-target" --level personal
curl_fail=0

mkdir "$test_dir/checksum-target"
valid_sha=$archive_sha
archive_sha=0000000000000000000000000000000000000000000000000000000000000000
expect_failure "SHA-256 does not match" "$test_dir/checksum-target" --level personal
archive_sha=$valid_sha

mkdir "$test_dir/unsafe-target"
printf 'outside archive member\n' > "$test_dir/outside-member"
unsafe_archive=$test_dir/unsafe.tar.gz
tar --absolute-names -czf "$unsafe_archive" "$test_dir/outside-member"
mock_archive=$unsafe_archive
archive_sha=$(sha256sum "$unsafe_archive" | cut -d' ' -f1)
expect_failure "unsafe absolute" "$test_dir/unsafe-target" --level personal
[[ $(cat "$test_dir/outside-member") == 'outside archive member' ]] || \
  fail "unsafe archive path modified a file outside the temporary directory"

mkdir "$test_dir/link-source" "$test_dir/link-target"
ln -s "$test_dir/outside-member" "$test_dir/link-source/outside-link"
link_archive=$test_dir/link.tar.gz
tar -czf "$link_archive" -C "$test_dir" link-source
mock_archive=$link_archive
archive_sha=$(sha256sum "$link_archive" | cut -d' ' -f1)
expect_failure "archive contains a link or unsupported file type" \
  "$test_dir/link-target" --level personal

mkdir "$test_dir/malformed-target"
malformed_archive=$test_dir/malformed.tar.gz
printf 'not a tar archive\n' > "$malformed_archive"
mock_archive=$malformed_archive
archive_sha=$(sha256sum "$malformed_archive" | cut -d' ' -f1)
expect_failure "not a readable tar.gz archive" "$test_dir/malformed-target" \
  --level personal

mkdir "$test_dir/missing-installer-source" \
  "$test_dir/missing-installer-target"
missing_root=$test_dir/missing-installer-source/engineering-skillset-$revision
mkdir -p "$missing_root/scripts" "$missing_root/modules/levels" \
  "$missing_root/modules/priorities"
cp AGENTS.md "$missing_root/AGENTS.md"
cp scripts/compose-policy.sh "$missing_root/scripts/compose-policy.sh"
touch "$missing_root/modules/levels/personal.md" \
  "$missing_root/modules/priorities/readability.md"
chmod +x "$missing_root/scripts/compose-policy.sh"
missing_archive=$test_dir/missing-installer.tar.gz
tar -czf "$missing_archive" -C "$test_dir/missing-installer-source" \
  "${missing_root##*/}"
mock_archive=$missing_archive
archive_sha=$(sha256sum "$missing_archive" | cut -d' ' -f1)
expect_failure "source is missing a required file: 'scripts/install-policy.sh'" \
  "$test_dir/missing-installer-target" --level personal

mkdir "$test_dir/installer-error-target"
mock_archive=$valid_archive
archive_sha=$valid_sha
set +e
invoke_bootstrap "$test_dir/installer-error-target" --level personal \
  --priority unknown > "$test_dir/stdout" 2> "$test_dir/stderr"
status=$?
set -e
[[ $status == 2 ]] || fail "installer exit status was not preserved (got $status)"
grep -Fq -- "unknown or unreadable priority" "$test_dir/stderr" || \
  fail "installer error was not preserved"
[[ ! -e $test_dir/installer-error-target/AGENTS.md ]] || \
  fail "installer validation failure changed target"
[[ -z $(find "$temp_parent" -mindepth 1 -print -quit) ]] || \
  fail "installer failure left temporary files"

mkdir "$test_dir/cleanup-bin" "$test_dir/cleanup-target"
real_rm=$(command -v rm)
cat > "$test_dir/cleanup-bin/rm" <<'FAIL_BOOTSTRAP_CLEANUP'
#!/usr/bin/env bash
for path in "$@"; do
  if [[ $path == */engineering-skillset-bootstrap.* ]]; then
    exit 1
  fi
done
exec "$REAL_RM" "$@"
FAIL_BOOTSTRAP_CLEANUP
chmod +x "$test_dir/cleanup-bin/rm"
set +e
PATH="$test_dir/cleanup-bin:$PATH" REAL_RM="$real_rm" \
  invoke_bootstrap "$test_dir/cleanup-target" --level personal \
  > "$test_dir/stdout" 2> "$test_dir/stderr"
status=$?
set -e
[[ $status != 0 ]] || fail "bootstrap cleanup failure returned success"
grep -Fq -- 'failed to remove temporary bootstrap directory' "$test_dir/stderr" || \
  fail "bootstrap cleanup failure was not reported"
[[ -f $test_dir/cleanup-target/AGENTS.md ]] || \
  fail "cleanup failure unexpectedly lost the completed installation"
cleanup_residue=$(find "$temp_parent" -mindepth 1 -maxdepth 1 -type d \
  -name 'engineering-skillset-bootstrap.*' -print -quit)
[[ -n $cleanup_residue ]] || fail "simulated cleanup failure left no observable recovery path"
"$real_rm" -rf -- "$cleanup_residue"
[[ -z $(find "$temp_parent" -mindepth 1 -print -quit) ]] || \
  fail "bootstrap cleanup fixture left temporary files"

set +e
PATH="$test_dir/cleanup-bin:$PATH" REAL_RM="$real_rm" \
  invoke_bootstrap "$test_dir/cleanup-target" --level personal \
  --priority unknown > "$test_dir/stdout" 2> "$test_dir/stderr"
status=$?
set -e
[[ $status == 2 ]] || \
  fail "bootstrap cleanup failure masked primary installer status (got $status)"
grep -Fq -- 'unknown or unreadable priority' "$test_dir/stderr" || \
  fail "primary installer error was lost after cleanup failure"
grep -Fq -- 'failed to remove temporary bootstrap directory' "$test_dir/stderr" || \
  fail "secondary cleanup failure was not reported"
cleanup_residue=$(find "$temp_parent" -mindepth 1 -maxdepth 1 -type d \
  -name 'engineering-skillset-bootstrap.*' -print -quit)
[[ -n $cleanup_residue ]] || fail "primary failure cleanup fixture left no residue to remove"
"$real_rm" -rf -- "$cleanup_residue"
[[ -z $(find "$temp_parent" -mindepth 1 -print -quit) ]] || \
  fail "primary failure cleanup fixture left temporary files"

printf 'bootstrap-policy: all checks passed\n'
