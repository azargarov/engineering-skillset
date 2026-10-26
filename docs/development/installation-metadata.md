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
malformed metadata, changed policy contents, or a different configuration.
Repeated identical selections leave the managed files unchanged. A different
configuration requires explicit `--reconfigure`; before replacing either file,
the installer verifies the existing manifest and policy digest. Reconfiguration
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
