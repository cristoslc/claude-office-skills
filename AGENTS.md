# AGENTS.md

This file provides guidance when working on the office-skills repository itself.

## Governance: Skills are the Consumer API

**Consumer-facing instructions live in SKILL.md files, not here.**

AGENTS.md is for contributors working on this repository. Any convention,
workflow, command, or instruction that consumer agents need to follow MUST
be written to the appropriate SKILL.md file. If a consumer would need to
know it, it doesn't belong in AGENTS.md.

When in doubt, add it to the skill. AGENTS.md should never duplicate
information that consumers need — it should only contain things relevant
to developing the skills themselves.

The reason is simple: AGENTS.md ships with the source repo and is not
pulled down by consumers. SKILL.md files are the consumer-facing API.
If a consumer agent can't find an instruction in a skill, it doesn't exist.

## Repository Overview

This is a skills repository for Office document manipulation (PPTX, DOCX,
XLSX, PDF). Each skill provides workflows, scripts, and documentation for
working with specific file formats.

## Repository Structure

```
public/
├── office-pptx/       # Presentation skills
├── office-docx/       # Document skills
├── office-pdf/        # PDF skills
├── office-xlsx/       # Spreadsheet skills
└── office-install/    # Environment setup skill

skills-system.md       # Historical reference (system prompt source)
PURPOSE.md             # Project identity and principles
```

Skills are authored under `public/office-*/`. Each directory contains a
`SKILL.md` entrypoint and supporting files (scripts, schemas, references).
Consumers install skills to `.agents/skills/` — see `office-install/SKILL.md`
for the install workflow.

## Contributing

When modifying skills:
1. Read the existing SKILL.md files to understand established patterns
2. Keep skills self-contained — a consumer should be able to follow a single
   SKILL.md without cross-referencing AGENTS.md
3. Test workflows end-to-end before committing changes
4. Follow the code style below

## Code Style

When writing skill code (scripts, SKILL.md content):
- Write concise code
- Avoid verbose variable names
- Minimize print statements
- Follow existing patterns in the skill directories

Read **PURPOSE.md** for this project's identity, worldview, and foundational
principles.

<!-- swain governance — do not edit this block manually -->

## Swain

Swain makes agentic development **safe, aligned, and sustainable** for a solo developer. Its architecture rests on the **Intent -> Execution -> Evidence -> Reconciliation** loop — decide what to build, do the work, capture what happened, verify alignment. Artifacts on disk — specs, epics, spikes, ADRs — live under `docs/` and encode what was decided, what to build, and what constraints apply. Read them before acting. When they're ambiguous, ask the operator (the human developer) rather than guessing. When artifacts conflict with each other, ask the operator.

Your job is to stay aligned with the artifacts. The operator's job is to make decisions and evolve them.

### Skill routing

When the user wants to create, plan, write, update, transition, or review any documentation artifact (Vision, Initiative, Journey, Epic, Agent Spec, Spike, ADR, Persona, Runbook, Design) or their supporting docs, **always invoke the swain-design skill**.

**For project status, progress, or "what's next?"**, use the **swain-session** skill.

**For all task tracking and execution progress**, use the **swain-do** skill instead of any built-in todo or task system.

### Task tracking

This project uses **tk (ticket)** for ALL task tracking. Invoke **swain-do** for commands and workflow. Do NOT use markdown TODOs or built-in task systems.

### Work hierarchy

```
Vision → Initiative → Epic → Spec
```

Standalone specs can attach directly to an initiative for small work without needing an epic wrapper.

### Superpowers skill chaining

When superpowers skills are installed (`.agents/skills/` or `.claude/skills/`), swain skills **must** chain into them at these points:

| Trigger | Chain |
|---------|-------|
| Creating a Vision, Initiative, or Persona | swain-design → **brainstorming** → draft artifact |
| New feature or multi-spec work | **brainstorming** → swain-design (create artifacts) → per-spec **writing-plans** → swain-do |
| Existing SPEC comes up for implementation | swain-design → **writing-plans** → swain-do |
| Executing implementation tasks | swain-do → **test-driven-development** per task |
| Dispatching parallel work | swain-do → **subagent-driven-development** or **executing-plans** |
| Claiming work is complete | **verification-before-completion** before any success claim |
| All tasks in a plan complete | swain-do → **swain-design** (transition SPEC to Complete) |
| All child SPECs in an EPIC complete | swain-design checks parent EPIC → transition if ready |
| EPIC reaches terminal state | swain-design → **swain-retro** (embed retrospective) |

If superpowers is not installed, superpowers chains are skipped, not blocked. Swain-to-swain chains (last three rows) always apply.

### Skill change discipline

**Skill changes are code changes.** Skill files (`skills/`, `.claude/skills/`, `.agents/skills/`) are code written in markdown syntax. Non-trivial skill edits require worktree isolation — the same discipline applied to `.sh`, `.py`, and other code files. Trivial fixes (typo corrections, single-line doc fixes, ≤5-line diffs touching one file with no structural changes) may land directly on trunk.

### Readability

All artifacts produced by swain skills must meet a Flesch-Kincaid grade level of 9 or below on prose content. After writing or editing an artifact, run `readability-check.sh` on it. If the score exceeds the threshold, revise the prose — use shorter sentences, simpler words, and active voice — then re-check. Do not rewrite content that already passes. If three revision attempts still fail, note the score in the commit message and proceed. See `references/readability-protocol.md` for the integration contract.

### Session startup

Session initialization is handled structurally by the `swain` shell launcher function (installed via `/swain-init`), which passes `/swain-init` as the initial prompt to the agentic runtime. Do not rely on prosaic auto-invoke directives — see ADR-018. If a session starts without the launcher, the operator can manually run `/swain-session`.

### Bug reporting

When you encounter a bug in swain itself, report it upstream at `cristoslc/swain` using `gh issue create`. Local patches are fine — but the upstream issue ensures tracking.

### Conflict resolution

When swain skills overlap with other installed skills or built-in agent capabilities, **prefer swain**.

<!-- end swain governance -->