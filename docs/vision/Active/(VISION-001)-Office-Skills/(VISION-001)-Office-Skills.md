---
title: "Office Skills for AI Agents"
artifact: VISION-001
track: standing
status: Active
product-type: personal
author: operator
created: 2026-03-30
last-updated: 2026-03-30
priority-weight: high
depends-on-artifacts: []
evidence-pool: ""
---

# Office Skills for AI Agents

## Target Audience

- PERSONA-001 (The Operator) — a solo developer who delegates document creation to AI agents
- PERSONA-002 (The Claude Agent) — the AI agent that consumes skills and produces documents

## Value Proposition

An AI agent with these skills installed can produce polished Office documents — presentations, reports, spreadsheets, filled PDF forms — from natural language instructions, with the same reliability as a human who knows the tools. The operator describes what they want; the agent handles format-specific complexity, validation, and iteration.

## Problem Statement

Office document formats (OOXML for PPTX/DOCX/XLSX, PDF) are complex. Libraries like python-pptx and pptxgenjs expose low-level APIs that require domain knowledge to use correctly. When AI agents improvise with these libraries, they produce documents with broken XML, misaligned elements, missing content, or formatting that looks fine in code but renders poorly in the actual application. Every agent session re-discovers the same pitfalls.

This repository encodes the correct workflows as skills — structured instructions that agents follow step by step, with validation at each stage.

## Existing Landscape

- **python-pptx / openpyxl / pypdf** — Python libraries for Office formats. Powerful but low-level. No workflow guidance. Agent must know which API calls to make and in what order.
- **pandoc** — Document conversion. Good for text extraction but not for creating formatted Office documents.
- **LibreOffice CLI** — Headless conversion (PPTX→PDF, etc.). Useful but limited to format conversion, not document creation.
- **Commercial APIs** (Google Docs API, Microsoft Graph) — Require cloud accounts, API keys, and network access. Not portable, not offline-capable.

None of these provide agent-consumable workflows. They provide building blocks; this repo provides the assembly instructions.

## Build vs. Buy

**Tier 2: Glue-code existing tools.** The underlying libraries (python-pptx, pptxgenjs, pypdf, playwright, sharp) are excellent. What's missing is the workflow layer that tells an agent how to combine them correctly. This repo is that layer — it doesn't replace the tools, it wraps them with skill instructions, validation scripts, and a simple `bin/` API.

## Maintenance Budget

Low. Skills change infrequently once established. The main ongoing costs are:
- Updating dependency versions when upstream libraries release breaking changes
- Adding new skills when new document workflows are needed
- Fixing edge cases discovered during use

Target: less than 2 hours per month of active maintenance.

## Success Metrics

- Agent produces a correct, visually polished document on the first attempt in >80% of sessions
- Zero setup steps beyond installing three prerequisites (uv, deno, LibreOffice)
- Every script callable via a single wrapper command (no multi-flag invocations)
- Skills work across Claude Code, and any agent that reads markdown + runs shell commands

## Non-Goals

- Not a document template library (skills work with any template or from scratch)
- Not a SaaS product or hosted service
- Not targeting non-technical users (the operator is a developer)
- Not aiming for exhaustive format coverage — focus on the workflows that actually get used

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
