---
name: atlassian-mcp
description: Atlassian (Jira + Confluence) MCP connector — the claude.ai connector, how it's enabled, authenticated, and verified.
---

# Atlassian MCP Connector (Jira + Confluence)

Claude reaches Jira and Confluence through the official **claude.ai Atlassian connector** (`https://mcp.atlassian.com/v1/mcp`), authenticated by account-level OAuth. Because it lives in your claude.ai account, it loads in **every project** automatically and needs no credentials in `.env`.

Tool prefix: `mcp__claude_ai_Atlassian__`

Key tools:
- `searchJiraIssuesUsingJql(jql, ...)` — search issues using JQL
- `createJiraIssue(projectKey, summary, description, issueType, ...)` — create an issue
- `editJiraIssue(issueIdOrKey, ...)` — update an issue
- `getJiraIssue(issueIdOrKey)` — fetch a single issue
- `transitionJiraIssue(issueIdOrKey, transitionId)` — move an issue to a new status
- `addCommentToJiraIssue(issueIdOrKey, body)` — add a comment
- `getConfluencePage(pageId)` — fetch a Confluence page
- `searchConfluenceUsingCql(cql, ...)` — search Confluence using CQL
- `createConfluencePage(spaceKey, title, body, ...)` — create a page
- `updateConfluencePage(pageId, title, body, ...)` — update a page

## Setup (one-time)

The connector is tied to your claude.ai account — there is nothing to install locally.

1. Open [claude.ai → Settings → Connectors](https://claude.ai/settings/connectors)
2. Find **Atlassian**, click **Connect**, and authorize access.

To verify it worked:

```
claude mcp list
```

A connected Atlassian line ends in `Connected`. If it shows `Needs authentication`, reconnect the same way.

## Re-authenticating

If Jira or Confluence tools stop working, return to [claude.ai → Settings → Connectors](https://claude.ai/settings/connectors) and reconnect Atlassian.

> Note: claude.ai connectors load only when your active auth method is your claude.ai subscription. Under `ANTHROPIC_API_KEY`, Bedrock, or Vertex they are not loaded.
