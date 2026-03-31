---
title: "Run-First, No-Install Dependency Strategy"
artifact: ADR-001
track: standing
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
linked-artifacts:
  - VISION-001
  - EPIC-001
  - SPEC-001
  - SPEC-002
  - SPEC-003
  - SPIKE-001
depends-on-artifacts: []
evidence-pool: ""
---

# Run-First, No-Install Dependency Strategy

## Context

This repository provides skills that AI agents consume to create Office documents. The previous dependency model required setup steps before any script could run: create a Python venv, `pip install -r requirements.txt`, `npm install`, and install system tools (pandoc, poppler). This setup friction is particularly harmful for agents — they encounter dependency errors at runtime, waste tokens diagnosing missing packages, and the operator must intervene to fix the environment.

The project values zero ceremony (PURPOSE.md). Every install step is a barrier between "I want a presentation" and getting one.

## Decision

**All scripts must be runnable with no prior installation step.** Dependencies are resolved at invocation time by the runtime, not by a pre-configured environment.

The three-tier strategy:

1. **Python scripts** use PEP 723 inline script metadata (`# /// script` blocks) and run via `uv run`. Each script declares its own dependencies; `uv` resolves and caches them on first run. No venv, no requirements.txt, no pip.

2. **Node.js scripts** run via `deno run --allow-all` with dependencies pinned in `deno.json`. Deno resolves npm packages from its global cache and auto-creates a local `node_modules/` when native modules (sharp, playwright) require it. No npm install, no package.json.

3. **System tools that have Python-bundled alternatives** are replaced: `pdftoppm` (poppler) becomes `pymupdf` (bundled in wheel), `pandoc` becomes `pypandoc-binary` (bundled in wheel). Both resolve via the same `uv run` pattern.

The only remaining system prerequisites are: `uv`, `deno`, and `LibreOffice` (no Python alternative exists for Office-to-PDF conversion). Playwright's Chromium browser is a one-time setup (`deno run npm:playwright install chromium`), treated like LibreOffice.

## Alternatives Considered

**Keep venv + requirements.txt + npm install.** Status quo. Works but creates setup friction and fails silently when the environment isn't configured. Rejected because it contradicts the zero-ceremony principle.

**Docker container with everything pre-installed.** Eliminates setup entirely but adds Docker as a prerequisite, breaks filesystem access patterns, and makes iteration slow. Overkill for a skills library.

**Publish scripts as pip/npm packages.** Each script becomes installable via `pip install` or `npx`. Adds packaging overhead (setup.py, versioning, publishing) for tools that change frequently and are consumed locally. Rejected as over-engineered.

**npx --package for Node.js.** Investigated in SPIKE-001. Does not work for library imports without an undocumented NODE_PATH hack. Rejected as fragile.

**Bun for Node.js.** Investigated in SPIKE-001. Incomplete Playwright support, sharp compatibility issues. Rejected as too risky.

## Consequences

**Positive:**
- Clone-and-run experience: three prerequisites, then everything works
- Each script is self-contained — can be copied to another repo and still runs
- Dependency versions are pinned per-script (Python) or per-project (Deno), not in a shared requirements file
- Agents never encounter "module not found" errors from missing installs

**Accepted downsides:**
- First invocation of each script is slower (uv/deno download and cache dependencies)
- `uv` and `deno` are relatively new tools — less ubiquitous than pip/npm
- pymupdf is AGPL-licensed (acceptable for internal tooling, would matter for SaaS distribution)
- Deno creates a `node_modules/` directory on first run when `nodeModulesDir: "auto"` is set — not truly "no files", just "no manual install"

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
