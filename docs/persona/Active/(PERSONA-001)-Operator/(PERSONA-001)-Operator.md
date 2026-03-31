---
title: "The Operator"
artifact: PERSONA-001
track: standing
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
linked-artifacts:
  - VISION-001
depends-on-artifacts: []
---

# The Operator

## Archetype Label

Solo developer who delegates document creation to AI agents.

## Demographic Summary

Technical professional (engineer, consultant, founder) who regularly needs to produce Office documents — presentations for stakeholders, reports as Word docs, spreadsheets for analysis, filled PDF forms — but doesn't want to spend time in PowerPoint or Word. Comfortable with the command line, uses Claude Code or similar agentic tools daily. Manages one or more repos where these skills are installed.

## Goals and Motivations

- Produce polished Office documents by describing what they want in natural language
- Spend zero time on formatting, layout, and Office-specific quirks
- Trust that the output is correct — no broken XML, no missing fonts, no truncated text
- Maintain a library of reusable workflows that improve over time
- Keep the toolchain simple: few prerequisites, no fragile build chains

## Frustrations and Pain Points

- Office formats are opaque — OOXML is a maze of XML files with undocumented interdependencies
- Agents improvise badly when given raw access to python-pptx or docx libraries
- Setup friction: virtual environments, npm install, system tool dependencies that vary by OS
- Presentations that look fine in the XML but render poorly in PowerPoint
- Having to manually fix agent output because the workflow missed a validation step

## Behavioral Patterns

- Gives high-level instructions ("make a deck about Q3 results with these numbers") and expects the agent to handle the rest
- Reviews output visually (opens the file in the Office app) rather than inspecting code
- Iterates quickly: "fix slide 3", "make the header bigger", "add a chart here"
- Installs skills once and expects them to keep working across sessions

## Context of Use

- Works in a terminal (Claude Code, VS Code terminal, or standalone CLI)
- Has `uv`, `deno`, and LibreOffice installed
- May be on macOS or Linux
- Documents are produced on-demand, not in batch — typically 1-5 documents per session
- Output files go to a local directory, then get shared via email, Slack, or Google Drive

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
