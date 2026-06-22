# claude-plugins-marketplace

A [Claude Code](https://code.claude.com/docs/en/claude-code) **plugin marketplace**, hosted on GitHub. The marketplace catalog and the plugins it offers all live together in this one repository.

- **Author / Owner:** Sean O'Dell
- **GitHub org:** [`seanodell`](https://github.com/seanodell)

## What this is

A self-contained Claude Code plugin marketplace:

- A marketplace manifest at [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json) catalogs every plugin offered.
- Each plugin lives under [plugins/](plugins/), self-contained with its own `.claude-plugin/plugin.json` manifest and its bundled components (skills, commands, agents, hooks, MCP servers).

## Install

Add the marketplace, then install any plugin from it:

```shell
/plugin marketplace add seanodell/claude-plugins-marketplace
/plugin install <plugin-name>@seanodell
```

For example:

```shell
/plugin install hello-world@seanodell
```

> The repo is `seanodell/claude-plugins-marketplace`; the marketplace it registers is named `seanodell`, so plugins install as `<plugin>@seanodell`.

## Plugins

| Plugin | Description |
| --- | --- |
| `hello-world` | Minimal plugin used to validate the install pipeline. |

## Repository layout

```
claude-plugins-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # marketplace catalog — lists all plugins
└── plugins/
    └── <plugin>/
        ├── .claude-plugin/
        │   └── plugin.json        # plugin manifest
        └── skills/
            └── <skill>/
                └── SKILL.md       # a bundled skill
```

## Developing locally

Contributors can install the bundled plugins straight from a working copy — no publishing required — with [mise](https://mise.jdx.dev/):

```shell
mise run plugins:install      # install from this working copy at user scope
mise run plugins:uninstall    # remove them again
```

See [CLAUDE.md](CLAUDE.md) for repository conventions and how local install works.

## License

[Apache License 2.0](LICENSE) © 2026 Sean O'Dell. See [NOTICE](NOTICE) for attribution.
