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
Repeated identical selections leave the managed files unchanged. Configuration
changes and policy updates are deferred to M02.4.

Initial publication uses same-directory staging and no-overwrite links. If a
publication step fails, the installer removes files it can verify it just
published. A process termination or filesystem failure during rollback can
still require manual inspection; the next run refuses inconsistent state.
