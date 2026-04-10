# Skill Writing Best Practices — Synthesis

## Key Findings

### 1. Progressive Disclosure Is the Core Architecture

All sources converge on a single architectural principle: **skills use progressive disclosure** — metadata → instructions → resources — to minimize context window consumption.

- At startup, only `name` and `description` (L1) are loaded into context across all skills (anthropic-best-practices, anthropic-engineering-blog, google-adk-skills-progressive-disclosure).
- SKILL.md body (L2) loads only when the skill is triggered.
- Additional reference files (L3) load only when referenced from SKILL.md instructions.
- Google's ADK documentation quantifies this: "an agent with 10 skills starts each call with roughly 1,000 tokens of L1 metadata instead of 10,000 tokens in a monolithic prompt — roughly a 90% reduction in baseline context usage."
- **Implication:** Keep SKILL.md under 500 lines. Split detailed content into separate files and link from SKILL.md. Avoid nesting references deeper than one level (anthropic-best-practices).

### 2. Description Is the Trigger — Write It for the Model, Not Humans

The `description` field is the single most important piece of metadata. It determines whether Claude loads the skill at all.

- Claude reads every skill's description and matches against the user's request (analytics-vidhya-skills-explained, claude-help-center-skills).
- Vague descriptions ("helps with documents") cause missed triggers; overly broad ones cause false positives (anthropic-code-skills-docs).
- Write in third person, not first person ("Processes PDF files" not "I can help you process PDFs") — Anthropic explicitly warns that inconsistent POV causes discovery problems (anthropic-best-practices).
- Front-load the key use case — descriptions >250 characters are truncated in the skill listing (anthropic-code-skills-docs).
- Anthropic's own skill-creator tool recommends making descriptions "a little pushy" to combat Claude's tendency to undertrigger skills (shanraisshan-best-practice-repo).
- Include both **what** the skill does and **when** to use it: "Extract text and tables from PDF files. Use when working with PDF files, forms, or document extraction." (anthropic-best-practices).

### 3. One Skill, One Job

Every source agrees: focused skills compose better than monolithic ones.

- "If you find yourself writing 'and also' more than once in your SKILL.md, split it into two Skills" (analytics-vidhya-skills-explained).
- "A Skill that does too many things becomes hard to trigger accurately and harder to debug when something goes wrong" (analytics-vidhya-skills-explained).
- "Create separate Skills for different workflows. Multiple focused Skills compose better than one large Skill" (claude-help-center-skills).
- Skills can't explicitly reference other skills, but Claude can use multiple skills together automatically — composability through independent, focused units (claude-help-center-skills).

### 4. Don't State the Obvious — Focus on What Pushes Claude Out of Default

The strongest signal across Anthropic's official docs is that Claude is already very smart. Only add context it wouldn't know on its own.

- "Default assumption: Claude is already very smart. Challenge each piece of information: 'Does Claude really need this explanation?'" (anthropic-best-practices).
- A concise 50-token example (showing code) is preferred over a 150-token verbose explanation (anthropic-best-practices).
- Don't railroad Claude with prescriptive step-by-step instructions — give goals and constraints instead (shanraisshan-best-practice-repo).
- Match specificity to fragility: high freedom for flexible tasks, low freedom (exact scripts) for fragile operations like database migrations (anthropic-best-practices).

### 5. Degrees of Freedom: Match Specificity to Task Fragility

Anthropic's best practices establish a clear framework:

| Freedom Level | When to Use | Example |
|---|---|---|
| High (text instructions) | Multiple approaches valid, decisions depend on context | Code review guidelines |
| Medium (pseudocode/scripts with params) | Preferred pattern exists, some variation OK | Report generation template |
| Low (exact scripts, no params) | Operations are fragile, consistency is critical | Database migration with exact flags |

The analogy: "Think of Claude as a robot exploring a path. Narrow bridge with cliffs = low freedom. Open field with no hazards = high freedom." (anthropic-best-practices)

### 6. Scripts Solve Problems; Don't Punt to Claude

When a skill includes code, the code should handle error conditions rather than failing and letting Claude figure it out.

- "Prefer scripts for deterministic operations: Write `validate_form.py` rather than asking Claude to generate validation code" (anthropic-best-practices).
- Make configuration parameters self-documenting with justified values, not "voodoo constants" (anthropic-best-practices).
- Make it clear whether Claude should **execute** a script ("Run `analyze_form.py`") or **read** it as reference ("See `analyze_form.py` for the algorithm") — this distinction matters (anthropic-best-practices).

### 7. Build Evaluations First, Iterate With Claude

Anthropic recommends evaluation-driven development:

1. Identify gaps by running Claude on representative tasks without a skill
2. Create three evaluation scenarios that test these gaps
3. Establish baseline performance without the skill
4. Write minimal instructions to address the gaps
5. Iterate based on observed behavior

For iterative improvement, work with "Claude A" (the expert who helps refine the skill) and test with "Claude B" (a fresh instance using the skill). Observe where Claude B struggles, then bring insights back to Claude A (anthropic-best-practices, anthropic-engineering-blog).

### 8. Skill Lifecycle and Content Persistence

When a skill is invoked, its rendered content enters the conversation as a single message and stays for the rest of the session. Claude Code does not re-read the skill file on later turns (anthropic-code-skills-docs).

- Write **standing instructions** (rules that apply throughout a task), not one-time steps
- Auto-compaction carries invoked skills forward at 5,000 tokens per skill, 25,000 combined. Older skills can be dropped
- If a skill seems to stop influencing behavior, re-invoke it or strengthen the description

### 9. Invocation Control: Who Fires the Skill?

Three modes control skill activation (anthropic-code-skills-docs):

| Frontmatter | User invokes | Claude invokes | Notes |
|---|---|---|---|
| (default) | Yes | Yes | Description always in context |
| `disable-model-invocation: true` | Yes | No | Description not in context; skill only loads on manual `/skill-name` |
| `user-invocable: false` | No | Yes | Background knowledge; not an actionable command |

Use `disable-model-invocation: true` for risky actions (deploy, send message). Use `user-invocable: false` for contextual knowledge (legacy system context) that isn't a command.

### 10. Dynamic Context Injection

Claude Code supports `` !`command` `` syntax that runs shell commands before skill content is sent to Claude. The command output replaces the placeholder, so Claude receives the result, not the command itself.

- This is preprocessing, not something Claude executes
- Useful for injecting live data (git status, current branch, PR diffs) into skill instructions
- For multi-line commands, use fenced code blocks with ` ```! ` (anthropic-code-skills-docs)

## Points of Agreement

All sources agree on these principles:
1. **Progressive disclosure** — metadata → instructions → resources
2. **Concise.SKILL.md** — under 500 lines, split to files
3. **Description as trigger** — write for the model, include when + what
4. **One skill per task** — focused, composable
5. **Third-person descriptions** — no "I" or "you" in frontmatter
6. **Test iteratively** — write, test, observe, refine
7. **Start simple** — add complexity incrementally

## Points of Disagreement

Minor differences in emphasis:
- Analytics Vidhya and community sources emphasize "pushy descriptions" more than Anthropic's official docs, which recommend specificity without pushing
- Google ADK docs frame progressive disclosure as a tool-level API (list_skills, load_skill, load_skill_resource), while Anthropic's approach uses filesystem navigation — same principle, different implementation
- The community (shanraisshan) advocates a Command → Agent → Skill orchestration pattern that goes beyond what Anthropic's official skills documentation covers, but is consistent with it

## Gaps

These topics are not well-covered by any source:
- **Cross-platform skill portability:** agentskills.io is referenced but not detailed — how skills work across Claude.ai, Claude Code, and API
- **Skill versioning and lifecycle management:** How to update skills across a team without breaking existing workflows
- **Performance measurement:** Quantitative methods for measuring skill effectiveness beyond anecdotal observation
- **Skill composition patterns:** While the principle is stated (skills compose automatically), concrete patterns for multi-skill workflows are thin
- **Security hardening:** Beyond "don't hardcode secrets," there's little guidance on skill sandboxing, supply chain security, or runtime permission models
- **Claude Code vs Claude.ai vs API differences:** The sources cover these platforms in different sections but don't systematically compare skill behavior across surfaces