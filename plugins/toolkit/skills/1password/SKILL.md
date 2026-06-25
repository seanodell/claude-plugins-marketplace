---
name: 1password
description: How to set up and use the 1Password CLI (op) — installation, connecting to the desktop app, reading secrets, and injecting secrets into commands without exposing them.
---

# 1Password CLI (op)

`op` is the 1Password CLI. It lets scripts and tasks read secrets from 1Password at runtime without committing them or putting them in plain-text `.env` files.

## Installation

**Via mise** (preferred — keeps `op` project-scoped and version-pinned):

```toml
# mise.toml
[tools]
op = "latest"
```

Then `mise install`.

**Via Homebrew** (machine-wide fallback):

```bash
brew install 1password-cli
```

Verify: `op --version`

## Connecting to the desktop app

`op` authenticates through the **1Password 8** desktop app's CLI integration — not a separate login. It requires 1Password 8 (not 7).

1. Open 1Password 8
2. Go to **Settings → Developer**
3. Enable **"Integrate with 1Password CLI"**
4. Sign into your account in the app if you haven't already

Verify the connection:

```bash
op account list   # should list your account(s)
```

If `op account list` returns nothing, the desktop app integration isn't active. Re-check Settings → Developer, or try locking and unlocking 1Password.

> Note: `op whoami` is not a reliable signal — it reports "not signed in" until a session is unlocked, even when `op` can read fine. Use `op account list` instead.

## Vaults and addressing

Secrets are addressed as `op://<vault>/<item>/<field>`:

```bash
op read "op://Employee/GitHub/token"        # read one field
op item get "GitHub" --vault Employee       # inspect a whole item
op vault list                               # list available vaults
op item list --vault Employee               # list items in a vault
```

Use vault and item **IDs** (not names) in anything committed or automated — names can change, IDs are stable.

## Reading secrets in scripts and tasks

Read a secret into a variable:

```bash
token=$(op read "op://Employee/GitHub/token")
```

Never pass the result as a command-line argument — assign to a variable and use it from there. Never print or log it.

## What Claude should never do

- Never run `op item create` or `op item edit` without explicit user instruction — these modify the vault
- Never print or log a value returned by `op read`
- Never read `.env` files directly, even if they contain only `op://` references — see the `secrets` skill

## Troubleshooting

| Symptom | Fix |
|---|---|
| `op account list` returns nothing | Enable CLI integration in 1Password 8 → Settings → Developer |
| `op` not found | Run `mise install` (if declared in `mise.toml`) or `brew install 1password-cli` |
| `[ERROR] 401` on read | Lock and unlock 1Password in the desktop app to refresh the session |
| Wrong account reading the secret | Check `op account list`; switch with `op signin --account <shorthand>` |
