---
name: secrets
description: MUST READ before touching any secret, credential, .env file, or API key — rules for safe handling, how to write scripts that source secrets without exposing them, and what to do when a secret is exposed.
---

# Secrets Handling

## Hard rules

1. **Never read `.env*` files.** Not with `cat`, `Read`, `Bash`, or any tool. A `.env` file may contain live credentials — reading it pulls secrets into context where they can be logged, cached, or leaked. This rule applies even if the file only contains `op://` references or placeholder-looking values.

2. **Never commit `.env*` files.** They belong in `.gitignore`. Commit `.env.example` with placeholder values instead so the shape of the config is documented without the secrets.

3. **Never pass secrets as command-line arguments.** They appear in shell history and process lists. Read from environment variables inside scripts, never inline them.

4. **Never print or log secret values.** Don't `echo $API_KEY`, don't include them in error messages, don't write them to log files.

## Accessing secrets in scripts

When a task or script needs secrets, write the script to a file and let it read from the environment — never construct commands with secret values embedded.

**With mise** (preferred): if `_.file = ".env"` is declared in `mise.toml`, mise loads `.env` automatically for every `mise run` and `mise exec` invocation. No explicit sourcing needed — just use the env vars inside the task.

**Without mise**: write the script to a file that sources `.env` itself, then run it:

```bash
#!/usr/bin/env zsh
source .env
# use $MY_SECRET, $API_KEY, etc. — never echoed, never passed as args
```

Never construct a one-liner like `API_KEY=$(grep API_KEY .env | cut -d= -f2) some-command` — that both reads the file and risks the value appearing in process state.

## .env file conventions

- `.env` — gitignored, filled in locally with real values
- `.env.example` — committed, placeholder values only, documents every required variable
- `.env.test` / `.env.local` — also gitignored if they exist

When creating a new project, set up `.gitignore` and `.env.example` before writing any code that uses secrets.

## If a secret is exposed

A secret committed to git, printed in logs, or passed as an argument must be treated as compromised:

1. **Rotate it at the source immediately** — revoke and regenerate the token, key, or password at the service that issued it. Deleting the commit is not enough; the secret is in git history and may already be cached by GitHub, CI, or mirrors.
2. **Audit access logs** if the service provides them.
3. **Update the local `.env`** with the new value.

Never just remove the exposed value and move on without rotating.
