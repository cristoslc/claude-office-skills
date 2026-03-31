---
title: "Migrate html2pptx to Deno"
artifact: SPEC-003
track: implementable
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
priority-weight: high
type: enhancement
parent-epic: EPIC-001
parent-initiative: ""
linked-artifacts:
  - SPIKE-001
depends-on-artifacts: []
addresses: []
evidence-pool: ""
source-issue: ""
swain-do: required
---

# Migrate html2pptx to Deno

## Problem Statement

The html2pptx workflow requires `npm install` to set up `playwright`, `sharp`, `pptxgenjs`, and React dependencies. SPIKE-001 established that Deno 2.7+ can run the existing CJS script with zero modifications using `deno run --allow-all --node-modules-dir=auto`, eliminating the manual install step.

## Desired Outcomes

Node.js scripts run via `deno run` with dependencies resolved from `deno.json`. No `npm install`, no `package.json`, no manual `node_modules/` management. Deno auto-creates `node_modules/` on first run for packages that need it (playwright, sharp).

## External Behavior

**Inputs:** HTML slide files + JavaScript generation scripts (unchanged).

**Outputs:** PPTX files (unchanged).

**Invocation change:**
- Before: `node script.js` (requires prior `npm install`)
- After: `deno run --allow-all script.js` (auto-resolves deps from `deno.json`)

**Preconditions:** `deno` installed. Chromium binary installed once via `deno run npm:playwright install chromium`.

## Acceptance Criteria

1. **Given** `html2pptx.js`, **when** run via `deno run --allow-all`, **then** it converts HTML slides to PPTX identically to the Node.js output.

2. **Given** a fresh clone with no `node_modules/`, **when** `deno run` is invoked, **then** dependencies are auto-resolved and the script executes (first run may be slower due to download).

3. **Given** `deno.json` in the repo root, **when** inspected, **then** it pins all npm dependencies to specific versions matching current package.json.

4. **Given** an icon rasterization script using `react-icons` + `sharp`, **when** run via `deno run`, **then** it produces identical PNG output.

5. **Given** the migration is complete, **when** `package.json` is reviewed, **then** it is removed (replaced by `deno.json`).

## Verification

| Criterion | Evidence | Result |
|-----------|----------|--------|

## Scope & Constraints

**In scope:**
- `public/pptx/scripts/html2pptx.js` — ensure it runs under Deno
- Create `deno.json` with pinned npm dependency versions
- Remove `package.json` and `package-lock.json`
- Add `node_modules/` and `deno.lock` to `.gitignore`
- Document one-time Chromium setup: `deno run npm:playwright install chromium`

**Out of scope:**
- Rewriting html2pptx.js to ESM — CJS works fine under Deno
- Changing any script behavior or output format
- Bundling Chromium (it's a one-time setup like LibreOffice)

## Implementation Approach

1. Create `deno.json` with `nodeModulesDir: "auto"` and `imports` map pinning current package.json versions.
2. Verify `deno run --allow-all public/pptx/scripts/html2pptx.js` works on a test HTML slide.
3. Test icon rasterization workflow (react-icons → sharp → PNG).
4. Update `.gitignore` for `node_modules/` and `deno.lock`.
5. Remove `package.json`, `package-lock.json`.
6. Verify Playwright chromium setup works via `deno run npm:playwright install chromium`.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
