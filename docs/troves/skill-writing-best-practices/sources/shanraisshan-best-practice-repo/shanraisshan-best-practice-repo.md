---
source_id: shanraisshan-best-practice-repo
title: "Claude Code Best Practice — Community Best Practices Repository"
url: https://github.com/shanraisshan/claude-code-best-practice
type: web
fetched: 2026-04-10
---

# Claude Code Best Practice

Source: Community-maintained best practices repository (35k stars) by shanraisshan.

## Skill-Specific Best Practices

### Description Writing

- The skill description field is a **trigger, not a summary** — write it for the model ("when should I fire?")
- Front-load the key use case — each description entry is capped at 250 characters
- Make descriptions "pushy" to combat Claude's tendency to undertrigger skills (from Anthropic's skill-creator)

### What to Put in Skills

- **Don't state the obvious** — focus on what pushes Claude out of its default behavior
- **Don't railroad Claude** — give goals and constraints, not prescriptive step-by-step instructions
- **Include scripts and libraries** so Claude composes rather than reconstructs boilerplate
- **Embed !`command`** in SKILL.md to inject dynamic shell output into the prompt — Claude runs it on invocation and the model only sees the result

### Orchestration Pattern

The community has converged on the **Command → Agent → Skill** pattern:

- **Commands** (`.claude/commands/`): Knowledge injected into existing context — simple user-invoked prompt templates for workflow orchestration
- **Agents** (`.claude/agents/`): Autonomous actor in fresh isolated context — custom tools, permissions, model, memory, and persistent identity
- **Skills** (`.claude/skills/`): Knowledge injected into existing context — configurable, preloadable, auto-discoverable, with context forking and progressive disclosure

### Development Workflows

All major workflows converge on the same architectural pattern: **Research → Plan → Execute → Review → Ship**

### Settings vs CLAUDE.md

- Use `settings.json` for harness-enforced behavior (attribution, permissions, model) — don't put "NEVER add Co-Authored-By" in CLAUDE.md when `attribution.commit: ""` is deterministic
- Have feature-specific sub-agents (extra context) with skills (progressive disclosure) instead of general QA or backend engineer roles

## Key Community Projects and Patterns

### Superpowers (obra/superpowers)
- TDD-first approach
- Iron Laws (invariants)
- Whole-plan review
- 14 skills including writing-plans, test-driven-development, verification-before-completion

### Spec Kit (github/spec-kit)
- Spec-driven development
- Constitution (governance rules)
- 22+ tools

### Everything Claude Code (affaan-m)
- Instinct scoring
- AgentShield
- Multi-lang rules
- 182 skills

## Tips and Tricks

- Use CLAUDE.md for facts and conventions, Skills for procedures and workflows
- Skills are the consumer API — they should be self-contained
- Test Skills end-to-end before committing changes
- The `/` menu helps users discover skills — use descriptive names