---
source_id: anthropic-engineering-blog
title: "Equipping Agents for the Real World with Agent Skills"
url: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
type: web
fetched: 2026-04-10
---

# Equipping Agents for the Real World with Agent Skills

Source: Anthropic engineering blog by Barry Zhang, Keith Lazuka, and Mahesh Murag.

## Core Insight

Building a skill for an agent is like putting together an onboarding guide for a new hire. Instead of building fragmented, custom-designed agents for each use case, anyone can now specialize their agents with composable capabilities by capturing and sharing their procedural knowledge.

## The Anatomy of a Skill

A skill is a directory that contains a `SKILL.md` file. This file must start with YAML frontmatter that contains some required metadata: `name` and `description`. At startup, the agent pre-loads the `name` and `description` of every installed skill into its system prompt.

This metadata is the **first level** of progressive disclosure: it provides just enough information for Claude to know when each skill should be used without loading all of it into context. The actual body of this file is the **second level** of detail. If Claude thinks the skill is relevant to the current task, it will load the skill by reading its full `SKILL.md` into context.

Additional linked files are the **third level** (and beyond) of detail, which Claude can choose to navigate and discover only as needed.

In the PDF skill example, `SKILL.md` refers to two additional files (`reference.md` and `forms.md`). By moving the form-filling instructions to a separate file (`forms.md`), the skill author is able to keep the core of the skill lean, trusting that Claude will read `forms.md` only when filling out a form.

Progressive disclosure is the core design principle that makes Agent Skills flexible and scalable. Like a well-organized manual that starts with a table of contents, then specific chapters, and finally a detailed appendix, skills let Claude load information only as needed.

## Skills and the Context Window

The context window flow:

1. The context window has the core system prompt and the metadata for each installed skill, along with the user's initial message
2. Claude triggers a skill by invoking a Bash tool to read the contents of SKILL.md
3. Claude may choose to read additional bundled files
4. Claude proceeds with the user's task now that it has loaded relevant instructions

## Skills and Code Execution

Skills can include code for Claude to execute as tools at its discretion. Large language models excel at many tasks, but certain operations are better suited for traditional code execution. For example, sorting a list via token generation is far more expensive than simply running a sorting algorithm. Beyond efficiency concerns, many applications require the deterministic reliability that only code can provide.

The PDF skill includes a pre-written Python script that reads a PDF and extracts all form fields. Claude can run this script without loading either the script or the PDF into context. And because code is deterministic, this workflow is consistent and repeatable.

## Developing and Evaluating Skills

- **Start with evaluation:** Identify specific gaps in your agents' capabilities by running them on representative tasks and observing where they struggle or require additional context. Then build skills incrementally to address these shortcomings.
- **Structure for scale:** When the SKILL.md file becomes unwieldy, split its content into separate files and reference them. If certain contexts are mutually exclusive or rarely used together, keeping the paths separate will reduce the token usage.
- **Think from Claude's perspective:** Monitor how Claude uses your skill in real scenarios and iterate based on observations. Pay special attention to the `name` and `description` — Claude will use these when deciding whether to trigger the skill.
- **Iterate with Claude:** As you work on a task with Claude, ask Claude to capture its successful approaches and common mistakes into reusable context and code within a skill. If it goes off track when using a skill to complete a task, ask it to self-reflect on what went wrong.

## Security Considerations

Skills provide Claude with new capabilities through instructions and code. While this makes them powerful, it also means that malicious skills may introduce vulnerabilities. We recommend installing skills only from trusted sources. When installing from less-trusted sources, thoroughly audit before use — paying particular attention to code dependencies, bundled resources, and instructions that connect to external network sources.

## Future Vision

The Skills format is intentionally simple. This simplicity makes it easier for organizations, developers, and end users to build customized agents and give them new capabilities. Looking further ahead, the hope is to enable agents to create, edit, and evaluate Skills on their own, letting them codify their own patterns of behavior into reusable capabilities.