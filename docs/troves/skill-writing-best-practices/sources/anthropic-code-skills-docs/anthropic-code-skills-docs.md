---
source_id: anthropic-code-skills-docs
title: "Extend Claude with Skills — Claude Code Docs"
url: https://code.claude.com/docs/en/skills
type: web
fetched: 2026-04-10
---

# Extend Claude with Skills

Source: Official Claude Code documentation on skills.

## Key Concepts

Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit. Claude uses skills when relevant, or you can invoke one directly with `/skill-name`.

**When to create a skill:** When you keep pasting the same playbook, checklist, or multi-step procedure into chat, or when a section of CLAUDE.md has grown into a procedure rather than a fact.

Unlike CLAUDE.md content, a skill's body loads only when it's used, so long reference material costs almost nothing until you need it.

Claude Code skills follow the [Agent Skills](https://agentskills.io) open standard, which works across multiple AI tools.

## Where Skills Live

| Location | Path | Applies to |
|:---|:---|:---|
| Enterprise | See managed settings | All users in your organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

When skills share the same name across levels, higher-priority locations win: enterprise > personal > project.

## Types of Skill Content

**Reference content:** Adds knowledge Claude applies to your current work — conventions, patterns, style guides, domain knowledge. Runs inline so Claude can use it alongside conversation context.

**Task content:** Gives Claude step-by-step instructions for a specific action, like deployments, commits, or code generation. Often actions you want to invoke directly with `/skill-name`. Add `disable-model-invocation: true` to prevent Claude from triggering it automatically.

## Frontmatter Reference

| Field | Required | Description |
|:---|:---|:---|
| `name` | No | Display name. Lowercase, numbers, hyphens only (max 64 chars). If omitted, uses directory name. |
| `description` | Recommended | What the skill does and when to use it. Front-load key use case. Descriptions >250 chars truncated in listing. |
| `argument-hint` | No | Hint for autocomplete, e.g., `[issue-number]` |
| `disable-model-invocation` | No | `true` to prevent auto-loading. Default: `false`. |
| `user-invocable` | No | `false` to hide from `/` menu. Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without asking permission when skill is active. |
| `model` | No | Model to use when skill is active. |
| `effort` | No | Effort level when skill is active. Overrides session. Options: `low`, `medium`, `high`, `max`. |
| `context` | No | Set to `fork` to run in forked subagent context. |
| `agent` | No | Which subagent type to use when `context: fork` is set. |
| `hooks` | No | Hooks scoped to this skill's lifecycle. |
| `paths` | No | Glob patterns that limit when this skill is activated. |
| `shell` | No | Shell for `` !`command` `` blocks. `bash` (default) or `powershell`. |

## String Substitutions

| Variable | Description |
|:---|:---|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` / `$N` | Access a specific argument by 0-based index |
| `${CLAUDE_SESSION_ID}` | The current session ID |
| `${CLAUDE_SKILL_DIR}` | The directory containing the skill's SKILL.md |

## Dynamic Context Injection

The `` !`<command>` `` syntax runs shell commands before the skill content is sent to Claude. The command output replaces the placeholder, so Claude receives actual data, not the command itself.

For multi-line commands, use a fenced code block opened with ` ```! `.

## Supporting Files

Skills can include multiple files in their directory. This keeps SKILL.md focused on the essentials while letting Claude access detailed reference material only when needed.

```
my-skill/
├── SKILL.md (required)
├── template.md (template for Claude to fill in)
├── examples/
│   └── sample.md (example output)
└── scripts/
    └── validate.sh (script Claude can execute)
```

**Keep SKILL.md under 500 lines.** Move detailed reference material to separate files.

## Invocation Control

| Frontmatter | You can invoke | Claude can invoke | When loaded |
|:---|:---|:---|:---|
| (default) | Yes | Yes | Description always in context, full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description not in context, full skill loads when you invoke |
| `user-invocable: false` | No | Yes | Description always in context, full skill loads when invoked |

## Skill Content Lifecycle

When you or Claude invoke a skill, the rendered SKILL.md content enters the conversation as a single message and stays there for the rest of the session. Claude Code does not re-read the skill file on later turns, so write guidance that should apply throughout a task as standing instructions rather than one-time steps.

Auto-compaction carries invoked skills forward within a token budget (5,000 tokens per skill, 25,000 combined). Older skills can be dropped entirely after compaction.

## Troubleshooting

- **Skill not triggering:** Check the description includes keywords users would naturally say; verify skill appears in listing; try rephrasing request.
- **Skill triggers too often:** Make description more specific; add `disable-model-invocation: true` for manual-only control.
- **Skill descriptions cut short:** Each entry is capped at 250 characters. Front-load the key use case. Budget scales at 1% of context window, fallback 8,000 characters.