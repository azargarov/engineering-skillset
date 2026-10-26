# Installation Metadata

The local installer creates one policy file and one hidden ownership manifest
in the target directory:

- `AGENTS.md` contains the composed policy.
- `.engineering-skillset-manifest` records its content digest and selected
  configuration.

The manifest is plain text:

```text
engineering-skillset-manifest-v1
policy_sha256=<SHA-256 of AGENTS.md>
configuration=level=personal;priority=development-speed;priority=readability
```

Priority and optional selections are listed in stable identifier order. The
manifest is a local consistency record, not a signature or proof of authorship.
The installer refuses a policy without a manifest, a manifest without a policy,
malformed metadata, changed policy contents, or a different configuration
unless the requested change is explicitly authorized with `--reconfigure`.
Repeated identical selections leave the managed files unchanged. Before
replacing either file, the installer verifies the existing manifest and policy
digest. Reconfiguration
uses same-directory staging and preserves recovery copies until both replacement
files are published. A failed publication is rolled back when the files still
match the staged replacements. If rollback cannot safely complete, recovery
files are retained for inspection and the installer reports their location.

Initial publication uses same-directory staging and no-overwrite links. If a
publication step fails, the installer removes files it can verify it just
published. Reconfiguration replaces the policy and manifest as two filesystem
operations; a process termination or filesystem failure between them can still
leave an inconsistent pair requiring manual inspection. The next run refuses
inconsistent state. Reconfiguration does not merge user-authored `AGENTS.md` or
provide configuration history.

If a reconfiguration is interrupted and the policy and manifest no longer
match, do not rerun installation or delete the staging directory. Back up the
target's current files, inspect the reported recovery directory (or a remaining
`.engineering-skillset-stage.*` directory), and verify that `previous-AGENTS.md`
matches the digest in `previous-manifest`. Restore that verified pair together,
then confirm the manifest digest against the restored `AGENTS.md` before
removing recovery files. If the backups do not match or the target may contain
newer user edits, preserve everything and resolve the pair manually; the
installer does not choose which copy to keep.
