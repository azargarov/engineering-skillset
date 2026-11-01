# Engineering Skillset v0.2.1 Release Candidate

**Status:** Prepared for operator review; not accepted, tagged, or published.
**Scope:** M02 local user installation, accepted by the operator, plus M03
verification and release preparation.

## Candidate contents

- Four supported presets and four existing Workflow Skills.
- `make install-user` installs the shared `ess` CLI and a complete validated
  release into the user data directory.
- Project Skills link through the stable `current` path. Releases are retained
  and their contents are made read-only at publication.
- v0.2.0 projects transition by checking health and uninstalling with the
  original checkout, then installing the preset with the new global CLI.

## Verification evidence

The full commands and outcomes are summarized in [`../../current.md`](../../current.md).
The required build, full test suite, Bash syntax check, and whitespace check
passed. A separate disposable
checkout exercise covered fresh install, unrelated-directory CLI use, source
relocation, a rebuilt update, stable project links, repeated install,
uninstall preservation, unrelated CLI refusal, and injected staging and
activation failures. Both injected failures preserved the prior `current`
link. Self-review found and fixed acceptance of an active link through a
symlinked release directory; the regression check confirms refusal without
changing `current`.

The exercised source tree is the release candidate worktree. No release
archive, tag, commit, push, or publication has been created.

## Known limitations

- Previous releases are not garbage-collected.
- An interrupted user installation can leave an inactive release directory;
  rerunning the installer is the recovery path.
- Project install, switch, and uninstall still consist of multiple filesystem
  operations and are not atomic as a whole.
- A v0.2.0 project with damaged or modified managed files requires manual
  review; ownership checks must not be bypassed.
- The candidate has not been published or validated on platforms beyond the
  documented GNU/Linux environment.

## Review gate

Operator review is required before M03 is accepted or any commit, tag, push,
or publication action is taken.
