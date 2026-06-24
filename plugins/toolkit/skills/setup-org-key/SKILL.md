---
name: setup-org-key
description: Generate a per-org GitHub SSH key, upload it to the user's GitHub account, add an SSH host alias, and add a git URL rewrite so pushes/clones to that org automatically use the right key. Supports multiple orgs — each gets its own key, alias, and rewrite. Use when the user wants to set up SSH access for a GitHub org, rotate an org key, or add another org key alongside existing ones.
---

# GitHub Per-Org SSH Key Setup

Generate an ed25519 SSH key scoped to a GitHub org, upload it to the user's account,
configure an SSH host alias, and add a git URL rewrite rule. Every step is idempotent —
re-running for the same org is safe.

## Prerequisites check

Before doing anything else, verify:

1. `gh` is installed: `command -v gh`
2. `gh` is authenticated: `gh auth status` — if not, tell the user to run `gh auth login` and stop.
3. `ssh-keygen` is available: `command -v ssh-keygen`

## Gather the org name

If the user provided the org name as an argument (e.g. `/setup-org-key westpair`), use it.
Otherwise ask: "Which GitHub org should this key be scoped to?"

Call the org `<org>` for the rest of these steps. All naming (key file, SSH alias, URL
rewrites) is derived from `<org>`. The key is uploaded to the GitHub user account that has
access to the org — that account's username may or may not match `<org>` (e.g. for a
personal repo they're the same; for a company org they differ).

## Derive names

```
KEY_FILE=~/.ssh/id_ed25519_github_<org>
KEY_COMMENT=github-<org>
SSH_HOST=github.com-<org>
```

## Step 1 — Generate the SSH key

Check if `~/.ssh/id_ed25519_github_<org>` already exists.

- If it exists: tell the user the key already exists and ask whether to continue with the
  existing key or generate a fresh one. If generating fresh, remove the old pair first.
- If it does not exist: generate it silently.

```
ssh-keygen -t ed25519 -C "github-<org>" -f ~/.ssh/id_ed25519_github_<org> -N ""
```

Set permissions: `chmod 600 ~/.ssh/id_ed25519_github_<org>`

## Step 2 — Upload the public key to GitHub

Read the public key: `cat ~/.ssh/id_ed25519_github_<org>.pub`

The key is uploaded to the GitHub user account that has access to `<org>`. Check
`gh auth status` to see which accounts are logged in and which is active.

If the correct account is not active, switch to it first — neither `gh auth switch` nor
`gh auth refresh` accept a `--user` flag, so always switch first, then run:

```
gh auth switch --user <username>
```

If that account lacks the `admin:public_key` scope (upload returns HTTP 404 with a message
about missing scopes), refresh its scopes after switching:

```
gh auth refresh --hostname github.com --scopes admin:public_key
# complete the browser flow, then re-run the upload
```

Upload the key:

```
gh ssh-key add ~/.ssh/id_ed25519_github_<org>.pub \
  --title "github-<org>@$(hostname -s)" \
  --type authentication
```

After uploading, switch back to the original active account if you switched away:

```
gh auth switch --user <original-username>
```

If the upload fails because a key with identical content already exists on the account,
note that and continue — the key is already registered.

## Step 3 — Add the SSH host alias

Target file: `~/.ssh/config`  
Create the file if it does not exist; ensure `~/.ssh` is `700` and `config` is `600`.

Check whether a `Host github.com-<org>` block already exists in the file:
```
grep -q "^Host github.com-<org>$" ~/.ssh/config
```

If the block is absent, append it:

```
# BEGIN github-<org>
Host github.com-<org>
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github_<org>
  IdentitiesOnly yes
# END github-<org>
```

If the block already exists, skip this step and note it.

## Step 4 — Add the git URL rewrite rules

These rewrites make `git clone git@github.com:<org>/repo` and
`git clone https://github.com/<org>/repo` automatically use the SSH host alias —
and therefore the right key — without any per-repo configuration.

Use `git config --global` to add both `insteadOf` variants.  
`--add` means the rules accumulate safely alongside rewrites for other orgs.

Check before adding to stay idempotent:

```
# SSH rewrite
if ! git config --global --get-all "url.git@github.com-<org>:<org>/.insteadOf" \
     | grep -qF "git@github.com:<org>/"; then
  git config --global --add \
    "url.git@github.com-<org>:<org>/.insteadOf" \
    "git@github.com:<org>/"
fi

# HTTPS rewrite
if ! git config --global --get-all "url.git@github.com-<org>:<org>/.insteadOf" \
     | grep -qF "https://github.com/<org>/"; then
  git config --global --add \
    "url.git@github.com-<org>:<org>/.insteadOf" \
    "https://github.com/<org>/"
fi
```

## Step 5 — Verify

Test that the SSH alias resolves to GitHub correctly:

```
ssh -T git@github.com-<org> 2>&1
```

A response like `Hi <user>! You've successfully authenticated...` means it worked.
A `Permission denied` means the key upload may be pending or the key was already on the
account under a different name — tell the user and suggest `gh ssh-key list` to check.

## Report to the user

Summarise what was done, one bullet per step, indicating whether each step was newly
applied or already in place. End with the complete SSH config block and git rewrite that
are now active for this org, so the user can verify at a glance.

If the user has multiple orgs set up, note that each org's key, SSH alias, and rewrite
are independent — adding another org is safe and won't affect the existing ones.
