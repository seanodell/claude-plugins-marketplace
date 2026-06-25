---
name: python-setup
description: How to set up and manage Python in a repo using mise + uv — toolchain declaration, venv provisioning, and dependency management.
---

# Python Setup

Not every repo needs Python, but those that do manage it through **mise + uv**. Never use pip, never create venvs by hand, and **never run raw `uv`/venv commands at a prompt** — environment provisioning belongs in a mise `setup` task (see the `mise-tasks` skill), so it's one reproducible command for humans and Claude alike.

## Declare the toolchain in mise.toml

```toml
[tools]
python = "3.13"
uv = "latest"

[env]
_.python.venv = { path = ".venv", create = true }
UV_PYTHON = { value = "{{ tools.python.path }}", tools = true }
```

- `mise install` installs the pinned Python and uv.
- On shell activation, mise creates and activates `.venv` automatically (the `[env]` block above).
- `UV_PYTHON` makes uv use mise's Python, not system Python.
- Gitignore `.venv/`; commit `pyproject.toml` and `uv.lock`.

## Provision via a setup task — never raw commands

Put venv creation and dependency install in a `setup` mise file task (create one, or add to the repo's existing `setup`), so the only thing anyone runs is `mise run setup`. The raw `uv` calls live **inside the task**, never typed at a prompt:

```zsh
#!/usr/bin/env zsh
#MISE description="Set up the dev environment"

# ... shared helpers, per the mise-tasks skill ...

if [[ ! -d .venv ]]; then
    uv venv .venv          # create the venv (works before shell activation)
fi
uv sync                    # install deps from pyproject.toml / uv.lock
```

First-time setup is then just:

```bash
mise install      # install Python + uv
mise run setup    # provision the venv and dependencies
```

## Dependencies

Declare dependencies in `pyproject.toml` (managed by uv; never `requirements.txt`). To change them, edit `pyproject.toml`, then run `mise run setup` to sync — the task runs `uv sync` for you. Commit `uv.lock` for reproducible installs.

## Running and upgrading

Within an activated shell, `python` resolves to `.venv/bin/python`, and mise tasks run in this environment too. To upgrade, bump the version in `mise.toml`, run `mise install`, then `mise run setup` to re-sync — again, no raw `uv` at the prompt.
