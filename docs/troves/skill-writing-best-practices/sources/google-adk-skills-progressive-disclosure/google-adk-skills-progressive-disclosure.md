---
source_id: google-adk-skills-progressive-disclosure
title: "Developer's Guide to Building ADK Agents with Skills"
url: https://developers.googleblog.com/developers-guide-to-building-adk-agents-with-skills/
type: web
fetched: 2026-04-10
---

# Developer's Guide to Building ADK Agents with Skills

Source: Google Developers Blog on building AI agent skills with progressive disclosure.

## Progressive Disclosure in Agent Skills

The SkillToolset achieves context efficiency through **progressive disclosure**. This architectural pattern allows agents to load context precisely when it is needed, rather than cramming thousands of tokens into a monolithic system prompt.

### Three Levels of Detail

1. **L1 — Skill metadata** (name, description): Auto-loaded at startup. Minimal token cost.
2. **L2 — Skill instructions** (SKILL.md body): Loaded when the skill is triggered by user request.
3. **L3 — Skill resources** (reference files): Loaded only when the agent's instructions dictate it via the load_skill_resource tool.

By using this architecture, an agent with 10 skills starts each call with roughly 1,000 tokens of L1 metadata instead of 10,000 tokens in a monolithic prompt. This translates to roughly a **90% reduction** in baseline context usage.

### The Simplest Pattern

A Python object with name, description, and instructions, defined directly in your agent code.

### File-Based Skill Pattern

This design splits knowledge across two layers:
- The SKILL.md instructions (L2) tell the agent what steps to follow
- The references/style-guide.md file (L3) provides the detailed domain knowledge for each step
- The agent loads the reference only when its instructions dictate it

## Four Practical Skill Patterns

1. **Inline skill definition** — Simplest: a Python object with name, description, and instructions
2. **File-based skill** — SKILL.md with separate reference files for progressive disclosure
3. **Skill with tools** — Skills that define tools the agent can call
4. **SkillToolset** — Auto-generated tools (list_skills, load_skill, load_skill_resource) for dynamic skill management

## Key Takeaway

The progressive disclosure pattern — metadata → instructions → resources — is both an Anthropic and Google convention for agent skills. The principle is universal across agent platforms: don't dump everything into the system prompt; instead, let the agent discover and load what it needs on demand.