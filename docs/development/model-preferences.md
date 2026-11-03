# Delegation Model Preferences

Implemented and verified for v0.3.0; owner-accepted as part of the release.
Preferences remain advisory, and model selection is agent judgment rather
than an automated selector.

The checked-in template is [`config/model-preferences.md.example`](../../config/model-preferences.md.example).
`make install-user` copies it to the private user configuration path on first
installation:

```bash
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/engineering-skillset"
mkdir -p "$config_dir"
${EDITOR:-vi} "$config_dir/model-preferences.md"
```

The path is `${XDG_CONFIG_HOME:-$HOME/.config}/engineering-skillset/model-preferences.md`.
Subsequent installations preserve your file unchanged. Review `opencode models`
and edit the provider lists to match model names available in the current
OpenCode configuration. The template's sample names are examples, not
restrictions. The installed file is a regular copy and remains independent of
ESS release updates.

The new `model-preferences.md` file takes precedence. If it is absent, the
OpenCode Delegation Skill reads the legacy
`${XDG_CONFIG_HOME:-$HOME/.config}/engineering-skillset/model-delegation.md`
file for compatibility. That legacy filename is deprecated. During
installation, if the new file is absent but the legacy file exists, ESS
preserves the legacy file and does not create the new file. When both exist,
only the new file is used; ESS does not merge or overwrite either file. If
neither exists, installation initializes the new file from the published
template.

Preferences are advisory. The agent checks candidates against the output of
`opencode models`, uses list order only within each provider, and weighs task
suitability, capability, complexity, availability, cost, and verification
effort. It may
choose another available model when justified and reports the selected model
and reason. This guidance does not change project reliability requirements or
engineering priorities. ESS does not parse the Markdown or impose model
restrictions.
