---
title: "The Claude Agent"
artifact: PERSONA-002
track: standing
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
linked-artifacts:
  - VISION-001
depends-on-artifacts: []
---

# The Claude Agent

## Archetype Label

AI coding agent that consumes skills to produce Office documents.

## Demographic Summary

An LLM-based agent (Claude Code, or any agent that reads markdown and executes shell commands) operating in a terminal session. Has access to the filesystem, can run bash commands, read files, and write files. Does not have a GUI, cannot open Office applications, and cannot visually inspect output. Relies entirely on skill instructions and script output to judge correctness.

## Goals and Motivations

- Follow SKILL.md instructions precisely to produce correct Office documents
- Minimize trial-and-error: get the right output on the first or second attempt
- Understand which tool to use for each task without searching the codebase
- Run scripts with simple, predictable commands (not long chains of flags)
- Validate output programmatically since visual inspection is impossible

## Frustrations and Pain Points

- Long, complex invocation commands with many flags are easy to get wrong (`uv run --with pkg1 --with pkg2 ...`)
- Ambiguous instructions ("use the appropriate tool") lead to wrong choices
- Scripts that fail silently or produce broken output without error messages
- Having to construct multi-step workflows from scratch when a skill already encodes them
- Dependency errors at runtime because packages weren't installed

## Behavioral Patterns

- Reads SKILL.md files completely before starting work (as instructed)
- Executes scripts via wrapper commands in `bin/` directories
- Validates output after each step (runs validate.py, creates thumbnail grids)
- Iterates based on operator feedback ("fix slide 3" triggers re-read of inventory, targeted replacement)
- Cannot visually inspect — relies on programmatic checks and thumbnail grids read as images

## Context of Use

- Runs in a sandboxed terminal session with filesystem access
- Has `uv`, `deno`, and `soffice` available on PATH
- Reads skill files at the start of each document task
- Produces output to `outputs/<document-name>/` directories
- May be running in a worktree (isolated git branch) for parallel work
- Session may be short-lived — skills must be self-contained per invocation

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
