---
name: skill-maintenance
description: How to create and maintain project-local Claude skills — invoke when a workflow changes, a skill is missing or outdated, or something documented in a skill is found to be wrong.
---

# Skill Maintenance

Skills are the authoritative documentation for how Claude does work in a repo. Keep them current.

## When to act

- A workflow, command, or process changed → update the relevant skill
- A skill is wrong or misleading → fix it immediately, then continue
- No skill covers something Claude just did or learned → create one
- A tool, dependency, or task was added or removed → update the relevant skill

Never leave a known-wrong skill in place. Fix it in the same session it's discovered.

## Skill file format

Each skill is a **directory** containing a `SKILL.md`:

```
.claude/skills/<name>/SKILL.md
```

The directory name is the skill name. A flat `<name>.md` is not picked up — it must be `<name>/SKILL.md`.

```markdown
---
name: kebab-case-name
description: One-line summary — what it does and when to use it
verified: YYYY-MM-DD
---

# Skill Title

...content...
```

Set `verified:` to today's date whenever you create or update a skill.

### Optional frontmatter

- `disable-model-invocation: true` — keep the skill invocable via `/<name>` but prevent Claude from auto-loading it. Use for manual-only skills.
- `allowed-tools: Bash(...)` — grant specific tool permissions while this skill is active, scoped to the skill's lifetime only.

## Writing good skills

- Write direct instructions, not background or commentary
- Document the *why* only when it's non-obvious
- Cover edge cases and failure modes, not just the happy path
- A skill that needs a task describes *how to call it* — the task itself is the implementation

## Reloading

Project-local skills in `.claude/skills/` load automatically at session start. After creating or editing a skill, restart Claude Code for the change to take effect.
