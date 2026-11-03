# Local Model Delegation Configuration Example

The compiled policy is provider-independent. Machine-specific executor
preferences may be kept in the user's private
`${XDG_CONFIG_HOME:-$HOME/.config}/engineering-skillset/model-delegation.md`.
When considering delegation, an agent using the OpenCode Delegation Skill may
consult this file for preferences. Its absence does not prevent direct work or
normal ESS use. Keep endpoint URLs, credentials, and private connection
details in local configuration or a credential store; never copy credentials
into project files or compiled artifacts. This is plain Markdown, not a parsed
ESS schema.

The repository-root `model-delegation.md` is a user-maintained local example
and is not included in builds or installed projects. Its executor names and
model preferences are illustrative and must be checked against the current
OpenCode configuration. ESS does not import or overwrite it.

An example local file:

```markdown
# My model delegation setup

## Executors

- Codex session: use the current Codex agent for architecture, integration,
  and final verification.
- OpenCode session `local-review`: invoke through my existing OpenCode
  terminal session; model `my-local-coder`; local endpoint details are stored
  in my private OpenCode configuration.
- OpenCode session `cloud-implementation`: invoke through my existing
  OpenCode terminal session; model `my-cloud-coder`; credentials are stored
  in my credential manager.

## Responsibilities and preferences

- Prefer the local model for bounded reviews and isolated implementation
  tasks that do not need unavailable tools.
- Prefer the Codex session for integration, architecture decisions, builds,
  tests, debugging, and final reporting.
- Use cloud execution only when its expected quality or completion-time
  benefit justifies sending the task context to that service.

## Limitations and budgets

- The local model cannot access the network and may have a smaller context
  window; provide only the relevant files and interfaces.
- Use a short task-specific timeout and context budget; stop and return to the
  owner if the bounded task cannot be completed within them.
```

Adapt executor names, invocation steps, capabilities, responsibilities,
limitations, local/cloud preferences, and optional timeout/context guidance to
the tools actually available. Do not assume that another agent or session can
be invoked from the current one. This file is user-managed and is not included
in builds.
