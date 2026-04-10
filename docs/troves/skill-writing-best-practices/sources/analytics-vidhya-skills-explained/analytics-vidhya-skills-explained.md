---
source_id: analytics-vidhya-skills-explained
title: "Claude Skills Explained: Build, Configure, and Use Custom Skills on Claude Code"
url: https://www.analyticsvidhya.com/blog/2026/03/claude-skills-custom-skills-on-claude-code/
type: web
fetched: 2026-04-10
---

# Claude Skills Explained

Source: Analytics Vidhya comprehensive guide on building and configuring Claude Skills.

## Key Insight: Skills vs Saved Prompts

A saved prompt must be called every session. A Skill gets saved once and loaded automatically when relevant. Claude reads it on demand, rather than storing it in memory permanently. It doesn't eat into your conversation context unless it's actually needed. A skill doesn't just contain instructions but also structure — it can define the approach, context, and how that task should be executed.

Think of it like a cookbook sitting on the shelf. You don't memorise every recipe. You pull it out when needed, follow it, and put it back. Claude Skills work the same way.

## Discovery Rules: How Claude Picks the Right Skill

Claude reads the description field of every available SKILL.md and matches it against your request. If your message contains keywords or intent that align with a Skill's description, that Skill gets loaded.

Two implications:
1. Vague descriptions lead to missed triggers. If your description says "helps with documents," Claude might not load it when you ask to "write a quarterly report."
2. Overly broad descriptions can cause the wrong Skill to fire.

A good rule of thumb: write your description as if you're telling Claude exactly when to use it. "Use when the user asks to generate a performance summary or weekly report" will always outperform "for reports."

## Build-Test-Refine Loop

The core loop of building good Skills: **write, test, observe, refine**. Most people get to a solid Skill within two or three iterations.

Keep your instructions specific but not bloated. If your SKILL.md runs into several pages, Claude is spending a lot of context loading it. Aim to include only what Claude wouldn't do correctly on its own. That is the real value of a Skill.

## One Skill Per Task

Use one Skill per task. Don't try to bundle your code review, your report writing, and your email drafting into one SKILL.md. Build separate Skills and let Claude's discovery rules handle the routing.

## Best Practices Summarized

1. **Keep one Skill focused on one job:** If you find yourself writing "and also" more than once, split it into two Skills.
2. **Write a clear, trigger-focused description:** Vague descriptions will either miss triggers or fire at the wrong time. Write it as an instruction: "Use when the user asks to draft, edit, or review a blog post."
3. **Use supporting files instead of stuffing everything into SKILL.md:** Move detailed references, templates, or style guides into separate files. Claude only loads what it needs.
4. **Keep risky actions manual-only:** Anything that writes files, calls external services, or makes irreversible changes should have `disable-model-invocation: true`.
5. **Test with realistic prompts before relying on it:** Type the kind of thing you'd actually say in a real session and see if Claude picks it up correctly.
6. **A Skill is a tool, not an operating system:** A focused Skill that does one thing reliably is worth ten bloated ones that sort of do everything.

## Common Pitfalls

- **Skill not triggering:** Description doesn't match natural language users would say.
- **Wrong Skill triggering:** Overlapping descriptions between Skills.
- **Skill fires but ignores instructions:** SKILL.md tries to do too much; move extra material into supporting files.
- **Changes not showing up:** Skills can exist at multiple locations; Claude may be loading a different copy.
- **Supporting file not being read:** You must reference files from SKILL.md — Claude doesn't automatically inspect every file.
- **Claude doesn't see all Skills:** Too many skills can exceed the character budget for descriptions.

## Three-Level Progressive Loading

1. The YAML metadata at startup
2. The SKILL.md instructions when the Skill is triggered
3. Any extra files, resources, or scripts, only when they are referenced

This staged model keeps context usage efficient and is one of the biggest reasons Skills are more scalable than giant prompts.