---
name: git-workflow
description: Git workflow conventions — cloning repos, how Claude stages, authors, and proposes commits with user approval, conventional commit format, and push handling.
---

# Git Workflow

## How Claude commits

Claude never runs `git commit` without explicit user approval. The flow every time:

1. **Stage** specific files with `git add <files>`. Never `git add .` or `git add -A` — stage only the files relevant to the current change.

2. **Author the message.** Write a conventional-commit message (format below) using the Write tool to `/tmp/commit-msg-<branch>`, where `<branch>` is the current branch name. The message must never be passed as a command-line argument — always use `-F`.

3. **Validate** (warn, don't block):
   - Subject must match `type(scope): description` — e.g. `feat(auth): add OAuth flow`
   - Subject line is 72 characters or fewer
   - A blank line must separate subject from body

4. **Show the staged summary.** Run `git diff --cached --stat` to get the file list.

5. **Relay.** In the same reply as the approval prompt, show the proposed commit message as a markdown blockquote, followed by the staged files as plain text. Use `> &nbsp;` for the blank line between subject and body so it renders visibly:

   ```
   > feat(auth): add OAuth flow
   >
   > &nbsp;
   >
   > - add Google OAuth provider
   > - wire callback route
   ```

   Staged files:
   - `src/auth.ts` (+42 -3)
   - `src/routes/callback.ts` (+18)

6. **Get commit approval.** Ask with `AskUserQuestion` — "Commit these changes?" Never proceed on a free-text guess.

7. **Commit.** On approval: `git commit -F /tmp/commit-msg-<branch>`

8. **Get push approval.** Ask separately with `AskUserQuestion` after the commit succeeds:
   - Header: "Push"
   - Question: "Push to origin?"
   - Options: "Yes, push now (Recommended)", "No, skip"

9. **Push.** On approval: `git push -u origin HEAD`

10. **Stop on no.** If the user declines at any step, stop — nothing further changes.

## Conventional commit format

```
type(scope): short description

- succinct bullet describing one change
- another bullet, one point per line
```

Rules:
1. Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `perf`, `build`, `ci`. Scope is optional — omit the parentheses if unused.
2. Subject line is 72 characters or fewer, no trailing period.
3. Exactly one blank line between subject and body.
4. Body is required, written as bullet points (`- item`) — one point per line. No prose paragraphs.
5. No co-author or attribution lines.

## Cloning a repository

1. **Parse the URL.** Accept any GitHub URL form:
   - HTTPS: `https://github.com/<org>/<repo>` or `https://github.com/<org>/<repo>.git`
   - SSH: `git@github.com:<org>/<repo>.git`

2. **Protocol.** If the URL is HTTPS, ask with `AskUserQuestion` before proceeding:
   - Header: "Protocol"
   - Question: "Clone via SSH or HTTPS?"
   - Options: "SSH" (recommended — works with org keys from `setup-org-key`), "HTTPS"
   - Convert to SSH form if chosen: `git@github.com:<org>/<repo>.git`

3. **Confirm the clone path.** Ask with `AskUserQuestion`:
   - Header: "Clone path"
   - Question: "Where should `<repo>` be cloned?"
   - Default option: `~/Development/<org>/<repo>` — derive `<org>` and `<repo>` from the URL
   - "Other" lets the user type a custom path

4. **Clone.** Create the parent directory and clone:
   ```bash
   mkdir -p ~/Development/<org>
   git clone <url> ~/Development/<org>/<repo>
   ```

5. **Credential failure.** If the clone fails with an authentication or permission error, suggest running the `setup-org-key` skill to generate and register an SSH key for the org, then retry with SSH.

6. **Stop on no.** If the user declines or provides no path, stop.

## Credential errors on push or clone

Any time `git push` or `git clone` fails with an authentication or permission error, suggest running the `setup-org-key` skill. It generates an ed25519 key scoped to the org, uploads it to GitHub, and configures an SSH host alias and URL rewrite so future operations use the right key automatically.
