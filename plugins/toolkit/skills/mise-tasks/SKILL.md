---
name: mise-tasks
description: How to write and organize mise tasks — file format, naming conventions, shared helper libraries, and how to drive them from Claude.
---

# Mise Tasks

All scripts — run by humans or by Claude — are mise file tasks written in zsh. Never use Python scripts for tasks; never embed script logic in a skill or in `mise.toml`. A skill that needs a task describes *how to call it*; this skill is about *how to write* tasks.

## File task format

```zsh
#!/usr/bin/env zsh
#MISE description="What this task does"

# task logic here
```

Required: `#!/usr/bin/env zsh` shebang on line 1, `#MISE description="..."` on line 2. The file must be executable (`chmod +x <file>`).

**Warning:** Some formatters add a space after `#`, turning `#MISE` into `# MISE`, which breaks parsing. If that happens, use the `# [MISE]` form instead.

## Naming and namespacing

A task's name is its path under the tasks directory. Subdirectories create `:`-namespaced names; a file named `_default` in a subdirectory makes that namespace runnable on its own — no `mise.toml` entry needed:

```
foo                 # task name: foo
group/bar           # task name: group:bar
group/_default      # task name: group        (run `mise run group`)
```

## Running tasks

```bash
mise run <name>        # run a task
mise run group:bar     # run a namespaced task
mise tasks             # list available tasks
```

## Shared helper library

Tasks should source a shared helper library at the top rather than duplicating output logic. Resolve it from the script's own path so it works regardless of where `mise run` is invoked:

```zsh
source "${0:A:h}/_lib.sh"   # ${0:A} is the symlink-resolved absolute path; :h is dirname
```

A helper library should provide at minimum:

```zsh
header "..."             # bold heading
info "..."               # informational line
success "..."            # ✓ line
warn "..."               # ⚠ to stderr
error "..."              # ✗ to stderr
dim "..."                # dimmed text (e.g. echoing a command before running it)
ask "prompt" "default"   # interactive text input → result in $REPLY
confirm "prompt"         # yes/no prompt → returns 0 for yes, 1 for no
```

It should also restore the working directory on source, so tasks act on the directory where `mise run` was invoked rather than the project root mise cds to:

```zsh
[[ -n "${MISE_ORIGINAL_CWD}" ]] && cd "$MISE_ORIGINAL_CWD"
```

## Driving tasks from Claude

When a skill drives a mise task that would normally trigger a Bash permission prompt, collapse the two prompts into one by adding `allowed-tools` to the skill's frontmatter:

```yaml
allowed-tools: Bash(mise run my:task:*)
```

The grant is active only while that skill runs and lapses when it finishes — the task auto-runs inside the skill's flow but still prompts everywhere else. The `AskUserQuestion` in the skill becomes the single decision point. Never blanket-allow mise in `settings.json` (`Bash(mise run:*)`) — that silences prompts for tasks that have no approval gate of their own.
