---
name: github-mcp
description: GitHub MCP connector — the remote MCP server, how it's authenticated and registered at user scope so it loads in every project.
---

# GitHub MCP Connector

Claude reaches GitHub through the official remote MCP server (`https://api.githubcopilot.com/mcp/`). GitHub has **no claude.ai connector** and its remote server won't complete OAuth from Claude, so it's authenticated with a token from `gh`. It's registered at **user scope** so it loads in **every project**.

Tool prefix: `mcp__github__`

Key tools:
- `get_me()` — get the authenticated user
- `search_repositories(query, ...)` — search repos
- `list_pull_requests(owner, repo, ...)` — list PRs
- `create_pull_request(owner, repo, title, body, head, base, ...)` — create a PR
- `pull_request_read(owner, repo, pullNumber)` — get PR details
- `list_issues(owner, repo, ...)` — list issues
- `search_issues(query, ...)` — search issues
- `add_issue_comment(owner, repo, issueNumber, body)` — comment on an issue
- `search_code(query, ...)` — search code across repos

## Setup (one-time)

Requires `gh` to be installed and authenticated (`gh auth status`). The token is stored only in `~/.claude.json` — never in the repo.

```bash
token=$(gh auth token)
claude mcp remove github --scope local 2>/dev/null || true
claude mcp remove github --scope user 2>/dev/null || true
claude mcp add --scope user --transport http github \
  https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer $token"
```

The remove steps are idempotent and ensure a stale token from a prior registration doesn't shadow the new one.

Verify with:

```bash
claude mcp list
```

The `github` line should end in `Connected`.

## Recovery

If GitHub tools stop working, the token has likely rotated. Re-run the setup commands above to refresh it. If `gh auth token` fails first, run `gh auth login` to re-authenticate.
