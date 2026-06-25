---
name: 1password
description: How to set up the 1Password CLI (op) — installation, connecting to the 1Password 8 desktop app, and verifying the connection.
---

# 1Password CLI Setup (op)

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

`op` authenticates through the **1Password 8** desktop app's CLI integration. It requires 1Password 8 — version 7 cannot integrate with the CLI.

1. Open 1Password 8
2. Go to **Settings → Developer**
3. Enable **"Integrate with 1Password CLI"**
4. Sign into your account in the app if you haven't already

Verify the connection:

```bash
op account list
```

This should list your account. If it returns nothing, the integration isn't active yet.

> `op whoami` is not a reliable signal — it reports "not signed in" until a session is unlocked even when `op` works fine. Always use `op account list` to check.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `op account list` returns nothing | Enable CLI integration in 1Password 8 → Settings → Developer |
| `op` not found | Run `mise install` (if declared in `mise.toml`) or `brew install 1password-cli` |
| `[ERROR] 401` on read | Lock and unlock 1Password in the desktop app to refresh the session |
| Wrong account | Check `op account list`; switch with `op signin --account <shorthand>` |
