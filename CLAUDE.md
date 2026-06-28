# CLAUDE.md

Working guidance for Claude and contributors in this repo. Public-facing info lives in [README.md](README.md).

## What this repo is

A Claude Code plugin marketplace monorepo: the marketplace catalog and every plugin it serves are bundled together here. The repo is `seanodell/claude-plugins-marketplace`; the marketplace it defines is named **`seanodell`** (the `claude-*plugins*` family is reserved by Claude Code, so the marketplace name can't match the repo name). Build everything **as if it were a real, published marketplace** — the structure must stay valid so the published flow (`/plugin marketplace add seanodell/claude-plugins-marketplace`) works with zero restructuring. Marketplace-specific concerns (publishing, discovery, versioning policy, hosted distribution) are **deferred** — don't build them yet, but never lay things out in a way that would have to be undone later.

## Structure conventions

1. **Marketplace catalog** — `.claude-plugin/marketplace.json` at the repo root names the marketplace and lists each plugin with a **repo-relative** `source` path (e.g. `./plugins/toolkit`). Relative sources are what let the same manifest serve both local-path installs and the future GitHub install.
2. **Plugins** — each plugin is a self-contained directory under `plugins/<name>/` with its own `.claude-plugin/plugin.json` manifest.
3. **Manifests only in `.claude-plugin/`** — *only* `marketplace.json` / `plugin.json` go inside a `.claude-plugin/` dir. Everything else (`skills/`, `commands/`, `agents/`, `hooks/`, `.mcp.json`) sits at the plugin root and is auto-discovered.
4. **Skills** — a skill is `plugins/<plugin>/skills/<skill>/SKILL.md`: markdown with `name` + `description` frontmatter. The `description` must say *what it does and when to use it* — that's what makes it discoverable/invocable.

## mise task conventions

See the `toolkit:mise-tasks` skill for full conventions on file format, naming, helper libraries, and driving tasks from Claude. Repo-specific rules:

1. **Namespaced under `plugins:`** — all mise tasks live under `mise-tasks/plugins/`, so they're invoked as `mise run plugins:<task>`. This is the standing convention for the repo.
2. **zsh file tasks** — tasks are zsh file tasks (`#!/usr/bin/env zsh` line 1, `#MISE description="..."` line 2, executable). No Python, no logic in `mise.toml`.
3. **Shared helpers** — `mise-tasks/plugins/_lib.sh` (leading underscore = not a task) holds output helpers and `need_claude`; source it via `source "${0:A:h}/_lib.sh"` so cwd doesn't matter.
4. **Idempotent** — tasks must be safe to re-run.

## Local install (developer convenience)

`mise run plugins:install` registers this working copy as a local marketplace and installs the bundled plugins, bypassing publishing. Key facts:

1. **Local source** — the marketplace is added by filesystem path (`$REPO_ROOT`, from `mise.toml`), never via GitHub.
2. **User scope** — plugins install at `--scope user` so their skills reach **every** project on the machine, not just this repo.
3. **Live re-sync** — a path-based marketplace refreshes from the working copy via `claude plugin marketplace update` (run on re-install). Do **not** use `claude plugin update` here — that's for remote plugins only.
4. **Restart to load** — newly installed skills load on the next Claude Code start.

## Committing changes

Before every commit in this repo, bump the patch version in `plugins/toolkit/.claude-plugin/plugin.json` (e.g. `0.1.1` → `0.1.2`) and include it in the same commit. This is required so `claude plugin update toolkit@seanodell` detects and fetches the new content — the plugin cache is version-keyed and a no-op if the version doesn't change.

## Contracts (keep these in sync)

1. **Marketplace name** — `seanodell` is shared across `marketplace.json`, the `plugins:*` tasks, and every `<plugin>@seanodell` reference. All must agree.
2. **Plugin name** — a plugin's `name` is shared across its `plugin.json`, its `marketplace.json` entry, and the install/uninstall commands.
3. **Relative source** — a plugin's `source` in `marketplace.json` must resolve from the marketplace root.

When adding a plugin, add it to `marketplace.json`'s `plugins` array **and** to the `PLUGINS=(...)` list in `mise-tasks/plugins/install` and `uninstall`.
