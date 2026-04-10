---
source_id: claude-help-center-skills
title: "How to Create Custom Skills — Claude Help Center"
url: https://support.claude.com/en/articles/12512198-how-to-create-custom-skills
type: web
fetched: 2026-04-10
---

# How to Create Custom Skills

Source: Claude Help Center guide for creating custom skills.

## What Makes a Good Skill

The best Skills:

- Solve a specific, repeatable task
- Have clear instructions that Claude can follow
- Include examples when helpful
- Define when they should be used
- Are focused on one workflow rather than trying to do everything

## Required Metadata Fields

**name:** A human-friendly name for your Skill (64 characters maximum). Example: Brand Guidelines

**description:** A clear description of what the Skill does and when to use it. This is critical — Claude uses this to determine when to invoke your Skill (200 characters maximum). Example: "Apply Acme Corp brand guidelines to presentations and documents, including official colors, fonts, and logo usage."

## Adding Resources

If you have too much information for a single SKILL.md file (e.g., sections that only apply to specific scenarios), add files within your Skill directory. For example, add a REFERENCE.md file. Referencing it in SKILL.md will help Claude decide if it needs to access that resource.

## Adding Scripts

For more advanced Skills, attach executable code files to SKILL.md, allowing Claude to run code. Claude and Claude Code can install packages from standard repositories (Python PyPI, JavaScript npm) when loading Skills. API Skills require pre-installed dependencies.

## Testing Your Skill

### Before uploading:
1. Review your SKILL.md for clarity
2. Check that the description accurately reflects when Claude should use the Skill
3. Verify all referenced files exist in the correct locations
4. Test with example prompts to ensure Claude invokes it appropriately

### After uploading:
1. Enable the Skill in Customize > Skills
2. Try several different prompts that should trigger it
3. Review Claude's thinking to confirm it's loading the Skill
4. Iterate on the description if Claude isn't using it when expected

## Best Practices

- **Keep it focused:** Create separate Skills for different workflows. Multiple focused Skills compose better than one large Skill.
- **Write clear descriptions:** Claude uses descriptions to decide when to invoke your Skill. Be specific about when it applies.
- **Start simple:** Begin with basic instructions in Markdown before adding complex scripts. You can always expand on the Skill later.
- **Use examples:** Include example inputs and outputs in your Skill.md to help Claude understand what success looks like.
- **Test incrementally:** Test after each significant change rather than building a complex Skill all at once.
- **Skills can build on each other:** While Skills can't explicitly reference other Skills, Claude can use multiple Skills together automatically. This composability is one of the most powerful parts of the Skills feature.
- **Review the open Agent Skills specification:** Follow the guidelines at agentskills.io, so skills you create can work across platforms.

## Security Considerations

- Exercise caution when adding scripts to your Skill.md file
- Don't hardcode sensitive information (API keys, passwords)
- Review any Skills you download before enabling them
- Use appropriate MCP connections for external service access