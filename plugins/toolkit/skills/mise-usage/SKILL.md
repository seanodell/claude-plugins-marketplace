---
name: mise-usage
description: How to use mise in a project — running commands, managing tools, .env and .venv, Python/uv setup, writing tasks, and driving tasks from Claude.
---

# Mise Usage

## Claude has no mise environment

When Claude runs a Bash command, it is **not** in an activated mise shell. Tools declared in `mise.toml` (`python`, `uv`, `node`, etc.) are not on PATH, `.venv` is not activated, and `.env` is not loaded.

**Never run raw tool commands** — not `python`, `uv`, `pip`, `node`, or anything else managed by mise. Every command must go through mise:

```bash
mise run <task>          # run a mise task (preferred — tasks have the full env)
mise exec -- <command>   # run a one-off command with the mise environment
```

Examples:
```bash
mise exec -- python script.py
mise exec -- uv add requests
mise exec -- node index.js
```

## mise.toml structure

`mise.toml` at the repo root declares tools and environment:

```toml
[tools]
python = "3.13"
uv = "latest"
node = "22"

[env]
_.file = ".env"                                              # autoload .env
_.python.venv = { path = ".venv", create = true }           # manage .venv
UV_PYTHON = { value = "{{ tools.python.path }}", tools = true }
```

`mise install` installs all declared tools. After that, `mise run` and `mise exec` have the full environment.

## .env autoloading

Declare `_.file = ".env"` in the `[env]` block and mise loads it automatically for every `mise run` and `mise exec` invocation. Never manually source `.env` before running commands. Gitignore `.env`; commit `.env.example` with placeholder values.

## .venv management

Declare `_.python.venv = { path = ".venv", create = true }` in the `[env]` block and mise creates and activates the `.venv` automatically. Never run `python -m venv`, `uv venv`, or any manual venv command — mise owns this.

## Python and uv conventions

- Declare `python` and `uv` in `[tools]`; set `UV_PYTHON` so uv uses mise's Python, not system Python
- Declare dependencies in `pyproject.toml` — never `requirements.txt`
- Install/sync deps with `mise exec -- uv sync` or inside a mise task
- Commit `uv.lock` for reproducible installs

## Writing tasks

All scripts run by humans or Claude are mise file tasks written in zsh. Never embed script logic in `mise.toml` or skills.

```zsh
#!/usr/bin/env zsh
#MISE description="What this task does"

# task logic here
```

Requirements: `#!/usr/bin/env zsh` on line 1, `#MISE description="..."` on line 2, file executable (`chmod +x`).

**Warning:** Some formatters add a space after `#`, turning `#MISE` into `# MISE`, which breaks parsing. Use `# [MISE]` if that happens.

### Naming

A task's name is its path under the tasks directory. Subdirectories create `:`-namespaced names; `_default` makes a namespace directly runnable:

```
foo              # mise run foo
group/bar        # mise run group:bar
group/_default   # mise run group
```

### Shared helper library

Source a shared helper at the top of every task — resolve it from the script's own path so it works regardless of where `mise run` is invoked:

```zsh
source "${0:A:h}/_lib.sh"   # ${0:A} = symlink-resolved absolute path; :h = dirname
```

A helper library should provide:

```zsh
header "..."             # bold heading
info "..."               # informational line
success "..."            # ✓ line
warn "..."               # ⚠ warning line
error "..."              # ✗ to stderr
dim "..."                # dimmed text (e.g. echoing a command before running it)
ask "prompt" "default"   # interactive text input → result in $REPLY
confirm "prompt"         # yes/no prompt → returns 0 for yes, 1 for no
```

It should also restore the working directory on source, so tasks act on the directory where `mise run` was invoked:

```zsh
[[ -n "${MISE_ORIGINAL_CWD}" ]] && cd "$MISE_ORIGINAL_CWD"
```

### Idempotency

Tasks must be safe to re-run. Check before mutating — don't assume state is clean.

## Troubleshooting mise activation

If `mise run` or `mise exec` fails because `mise` is not found, the shell is not activated. Check:

```bash
command -v mise          # should print a path
echo $MISE_SHELL         # should print "zsh", "bash", etc. — empty means not activated
```

To activate mise in the current shell profile:

```bash
# Check if activation is already present
grep -q "mise activate" ~/.zshrc && echo "already present" || echo "missing"

# If missing, add it
echo '\neval "$(mise activate zsh)"' >> ~/.zshrc
```

After adding, open a new terminal — the current session will not pick it up. Once activated, `mise install` installs the tools declared in `mise.toml` for the current project.

## Driving tasks from Claude

When a skill drives a mise task that would otherwise trigger a Bash permission prompt, collapse the two prompts into one with `allowed-tools` in the skill's frontmatter:

```yaml
allowed-tools: Bash(mise run my:task:*)
```

The grant is active only while the skill runs and lapses when it finishes. The `AskUserQuestion` in the skill becomes the single decision point. Never blanket-allow mise in `settings.json` (`Bash(mise run:*)`) — that silences prompts for tasks that have no approval gate.
