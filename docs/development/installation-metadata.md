# Installation Metadata

The local installer manages the composed policy, the four bundled Workflow
Skills, and one ownership manifest:

- `AGENTS.md` contains the composed policy.
- `.agents/skills/<skill-id>/SKILL.md` contains each bundled Skill:
  `software-design`, `implementation-review`, `verification-qa`, and
  `project-handover`.
- `.engineering-skillset-manifest` records managed-file digests and the policy
  configuration.

The current manifest is plain text:

```text
engineering-skillset-manifest-v2
policy_sha256=<SHA-256 of AGENTS.md>
skill_software-design_sha256=<SHA-256 of that Skill's SKILL.md>
skill_implementation-review_sha256=<SHA-256 of that Skill's SKILL.md>
skill_verification-qa_sha256=<SHA-256 of that Skill's SKILL.md>
skill_project-handover_sha256=<SHA-256 of that Skill's SKILL.md>
configuration=level=personal;priority=development-speed;priority=readability
```

Priority and optional selections are listed in stable identifier order. The
manifest is a local consistency and ownership record, not a signature or proof
of authorship. The installer verifies all recorded digests before replacing
managed files. Repeating the same policy and bundled Skill contents leaves the
managed files unchanged. A changed policy or bundled Skill requires explicit
`--reconfigure`; modified managed files, unmanaged collisions at a bundled
Skill path, malformed metadata, or inconsistent state are refused.

Existing v1 policy-only manifests remain readable. They do not claim ownership
of any Skill file. The same policy/configuration can be upgraded to v2 with
`--reconfigure`, which installs the four Skills and records their digests. If
a target Skill path already contains an unmanaged file, the upgrade refuses
to overwrite it. An existing `.agents/skills` directory and unrelated Skills
are preserved. An existing directory at one of the four bundled Skill IDs is
also refused unless the manifest establishes ownership of its `SKILL.md`.
Only missing parent directories and the four exact bundled Skill files are
created.

Skills are installed as available workflows; installation does not mean they
must be invoked for every task. Codex can discover them from the project
`.agents/skills` directory, and they may be invoked explicitly or when
contextually relevant.

Initial publication stages all files before creating target paths and uses
no-overwrite links. Detectable publication failures roll back files published
by the installer when their identity and digest still match. Reconfiguration
uses recovery copies in the target-local `.engineering-skillset-stage.*`
directory and rolls back detectable failures when the destinations still
match the staged replacements. Policy, four Skills, and manifest are published
through separate filesystem operations, not atomically as a set. Process
termination or a filesystem failure between operations can leave an
inconsistent installation. The next run refuses inconsistent or modified
state; concurrent filesystem modifications are not qualified.

If reconfiguration is interrupted, do not rerun installation or delete the
staging directory. Back up current target files and inspect the reported
recovery directory (or remaining `.engineering-skillset-stage.*` directory).
The recovery copies are named `previous-AGENTS.md`, `previous-manifest`, and
`previous-skill-<skill-id>`. Compare the policy and Skill copies with the
digests in `previous-manifest` before restoring, and confirm the manifest's
format and configuration. Preserve the files and resolve the state manually
if copies do not match or newer user edits may exist; the installer does not
choose which copy to keep.

The ownership record does not create a separate removal interface. The four
bundled Skills are always installed together; uninstall and selective Skill
removal are not supported by this installer.
