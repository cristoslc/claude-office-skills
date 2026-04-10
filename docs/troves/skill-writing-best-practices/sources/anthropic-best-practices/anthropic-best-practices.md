---
source_id: anthropic-best-practices
title: "Skill Authoring Best Practices"
url: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
type: web
fetched: 2026-04-10
---

# Skill Authoring Best Practices

Source: Anthropic official documentation on skill authoring best practices.

## Core Principles

### Concise is Key

The context window is a public good. Your Skill shares the context window with everything else Claude needs to know, including the system prompt, conversation history, other Skills' metadata, and your actual request.

Not every token in your Skill has an immediate cost. At startup, only the metadata (name and description) from all Skills is pre-loaded. Claude reads SKILL.md only when the Skill becomes relevant, and reads additional files only as needed. However, being concise in SKILL.md still matters: once Claude loads it, every token competes with conversation history and other context.

**Default assumption: Claude is already very smart.** Only add context Claude doesn't already have. Challenge each piece of information:

- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

### Set Appropriate Degrees of Freedom

Match the level of specificity to the task's fragility and variability.

**High freedom** (text-based instructions): Use when multiple approaches are valid, decisions depend on context, heuristics guide the approach.

**Medium freedom** (pseudocode or scripts with parameters): Use when a preferred pattern exists, some variation is acceptable, configuration affects behavior.

**Low freedom** (specific scripts, few or no parameters): Use when operations are fragile and error-prone, consistency is critical, a specific sequence must be followed.

**Analogy:** Think of Claude as a robot exploring a path:
- **Narrow bridge with cliffs on both sides:** There's only one safe way forward. Provide specific guardrails and exact instructions (low freedom).
- **Open field with no hazards:** Many paths lead to success. Give general direction and trust Claude to find the best route (high freedom).

### Test with All Models

Skills act as additions to models, so effectiveness depends on the underlying model. Test your Skill with all the models you plan to use it with. What works perfectly for Opus might need more detail for Haiku. If you plan to use your Skill across multiple models, aim for instructions that work well with all of them.

## Skill Structure

### Naming Conventions

Consider using **gerund form** (verb + -ing) for Skill names, as this clearly describes the activity or capability the Skill provides.

Good examples: `processing-pdfs`, `analyzing-spreadsheets`, `managing-databases`
Avoid: Vague names (`helper`, `utils`, `tools`), overly generic (`documents`, `data`, `files`)

### Writing Effective Descriptions

The `description` field enables Skill discovery and should include both what the Skill does and when to use it.

**Always write in third person.** The description is injected into the system prompt, and inconsistent point-of-view can cause discovery problems.

- Good: "Processes Excel files and generates reports"
- Avoid: "I can help you process Excel files"

**Be specific and include key terms.** Include both what the Skill does and specific triggers/contexts for when to use it.

Effective examples:

```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

Avoid vague descriptions like "Helps with documents" or "Processes data."

### Progressive Disclosure Patterns

SKILL.md serves as an overview that points Claude to detailed materials as needed, like a table of contents in an onboarding guide.

**Practical guidance:**
- Keep SKILL.md body under 500 lines for optimal performance
- Split content into separate files when approaching this limit
- All reference files should link directly from SKILL.md (one level deep, not nested)

Pattern 1: High-level guide with references — link to separate files for advanced features.
Pattern 2: Domain-specific organization — organize content by domain (finance, sales, product) to avoid loading irrelevant context.
Pattern 3: Conditional details — show basic content, link to advanced content.

**Avoid deeply nested references.** Keep references one level deep from SKILL.md. Claude may partially read files when they're referenced from other referenced files.

**Structure longer reference files** with a table of contents at the top for files longer than 100 lines.

## Workflows and Feedback Loops

### Use Workflows for Complex Tasks

Break complex operations into clear, sequential steps. For particularly complex workflows, provide a checklist that Claude can copy into its response and check off as it progresses.

### Implement Feedback Loops

Common pattern: Run validator → fix errors → repeat. This pattern greatly improves output quality.

## Content Guidelines

### Avoid Time-Sensitive Information

Don't include information that will become outdated. Use "old patterns" sections with `<details>` tags for historical context instead.

### Use Consistent Terminology

Choose one term and use it throughout the Skill. Avoid mixing "API endpoint", "URL", "API route", "path" when you mean the same thing.

## Common Patterns

### Template Pattern

Provide templates for output format. Match the level of strictness to your needs — strict for API responses, flexible for adaptive guidance.

### Examples Pattern

Provide input/output pairs for Skills where output quality depends on seeing examples.

### Conditional Workflow Pattern

Guide Claude through decision points (e.g., "Creating new content? → Follow creation workflow. Editing existing? → Follow editing workflow.")

## Evaluation and Iteration

### Build Evaluations First

Create evaluations BEFORE writing extensive documentation. This ensures your Skill solves real problems rather than documenting imagined ones.

**Evaluation-driven development:**
1. Identify gaps: Run Claude on representative tasks without a Skill. Document specific failures.
2. Create evaluations: Build three scenarios that test these gaps.
3. Establish baseline: Measure Claude's performance without the Skill.
4. Write minimal instructions: Create just enough content to address the gaps and pass evaluations.
5. Iterate: Execute evaluations, compare against baseline, and refine.

### Develop Skills Iteratively with Claude

The most effective process involves Claude itself: Work with one instance (Claude A) to create a Skill that is used by other instances (Claude B). Claude A helps you design and refine instructions, while Claude B tests them in real tasks.

### Observe How Claude Navigates Skills

Watch for:
- **Unexpected exploration paths:** Claude reads files in an order you didn't anticipate
- **Missed connections:** Claude fails to follow references to important files
- **Overreliance on certain sections:** Consider moving to main SKILL.md
- **Ignored content:** Might be unnecessary or poorly signaled

## Anti-patterns to Avoid

- Avoid Windows-style paths — always use forward slashes
- Avoid offering too many options — provide a default with an escape hatch
- Don't state the obvious — focus on what pushes Claude out of its default behavior
- Scripts should solve problems rather than punt to Claude
- No "voodoo constants" — all values justified and documented
- Avoid assuming tools are installed

## Checklist for Effective Skills

### Core Quality
- Description is specific and includes key terms
- Description includes both what the Skill does and when to use it
- SKILL.md body is under 500 lines
- Additional details are in separate files (if needed)
- No time-sensitive information (or in "old patterns" section)
- Consistent terminology throughout
- Examples are concrete, not abstract
- File references are one level deep
- Progressive disclosure used appropriately
- Workflows have clear steps

### Code and Scripts
- Scripts solve problems rather than punt to Claude
- Error handling is explicit and helpful
- No "voodoo constants" (all values justified)
- Required packages listed in instructions
- Scripts have clear documentation
- No Windows-style paths (all forward slashes)
- Validation/verification steps for critical operations
- Feedback loops included for quality-critical tasks

### Testing
- At least three evaluations created
- Tested with Haiku, Sonnet, and Opus
- Tested with real usage scenarios
- Team feedback incorporated (if applicable)