# Delegation Model Preferences

The checked-in template is [`config/model-preferences.md.example`](../../config/model-preferences.md.example).
Copy it from the ESS checkout to the private user configuration path, then
edit the preferences:

```bash
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/engineering-skillset"
mkdir -p "$config_dir"
cp -n config/model-preferences.md.example "$config_dir/model-preferences.md"
```

`cp -n` leaves an existing destination unchanged. Review `opencode models` and
edit the provider lists to match model names available in the current OpenCode
configuration. The template's sample names are examples, not restrictions.

The new `model-preferences.md` file takes precedence. If it is absent, the
OpenCode Delegation Skill reads the legacy
`${XDG_CONFIG_HOME:-$HOME/.config}/engineering-skillset/model-delegation.md`
file for compatibility. That legacy filename is deprecated. When both exist,
only the new file is used; ESS does not merge or overwrite either file. If
neither exists, delegation uses its existing default behavior.

Preferences are advisory. The agent checks candidates against the output of
`opencode models`, uses list order only within each provider, and weighs task
suitability, capability, complexity, availability, cost, and verification
effort. It may
choose another available model when justified and reports the selected model
and reason. This guidance does not change project reliability requirements or
engineering priorities. ESS does not parse the Markdown or impose model
restrictions.
