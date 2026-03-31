---
title: "Node.js Zero-Install Strategy for html2pptx"
artifact: SPIKE-001
track: container
status: Complete
author: operator
created: 2026-03-30
last-updated: 2026-03-30
question: "What is the best approach to eliminate `npm install` for Node.js dependencies in this repo, given that html2pptx.js is a library (not a CLI) importing pptxgenjs, playwright, sharp, react, and react-icons?"
gate: Pre-implementation
risks-addressed:
  - "npm install step blocks zero-setup goal"
  - "playwright requires chromium browser binary — heavier than pure-JS deps"
  - "sharp has native bindings — may complicate portable execution"
evidence-pool: ""
---

# Node.js Zero-Install Strategy for html2pptx

## Summary

**Verdict: Go — Deno.** Deno 2.7+ runs the existing html2pptx CJS script with zero modifications via `deno run --allow-all --node-modules-dir=auto`. Sharp native bindings and Playwright both work. `deno.json` replaces package.json for dependency pinning. A local `node_modules/` is auto-created on first run (no manual `npm install`). Chromium binary remains a one-time setup (`npx playwright install chromium`), same as system tools like soffice. npx --package is too fragile (undocumented NODE_PATH hack). Bun has incomplete Playwright support. Deno is already installed on this machine.

## Question

What is the best approach to eliminate `npm install` for Node.js dependencies in this repo, given that `html2pptx.js` is a library (not a CLI tool) that imports `playwright`, `sharp`, `pptxgenjs`, `react`, `react-dom`, and `react-icons`?

## Dependency Clarification

Before evaluating candidates, the actual dependency graph is narrower than package.json suggests:

**html2pptx.js imports directly:** `playwright`, `sharp`, `path` (stdlib)
**pptxgenjs** — not imported by html2pptx.js, but used in the caller scripts that Claude generates per the SKILL.md workflow
**react / react-dom / react-icons** — not imported by html2pptx.js. Used in ad-hoc icon rasterization scripts (see `html2pptx.md` § Icons & Gradients). These render React icon components to SVG strings, then Sharp converts SVG→PNG. They're workflow dependencies, not html2pptx.js dependencies.

This means the problem splits into two dependency sets:
1. **html2pptx.js core:** `playwright`, `sharp` (native modules)
2. **Workflow scripts (generated per-presentation):** `pptxgenjs`, `react`, `react-dom`, `react-icons`, `sharp` (pure-JS except sharp)

## Candidates Investigated

### 1. `npx --package` flag

**Verdict: Not practical.**

- `npx --package=pkg node script.js` does NOT make packages importable by default. npx only adds `.bin` to PATH; it doesn't set `NODE_PATH`.
- **Workaround exists** but is fragile: `npx --package=sharp -c 'export NODE_PATH="${PATH%%/node_modules/.bin*}/node_modules"; node script.js'` — undocumented hack that extracts the npx cache path from PATH.
- Version pinning works: `npx --package=sharp@0.33.5`
- Sharp's native bindings install correctly via npx
- Playwright library loads, but **browser binaries are not auto-installed** — still need `npx playwright install chromium` as a one-time step
- Cold start ~0.9s, warm cache ~0.5s
- With 6+ packages, the command line becomes unwieldy

**Bottom line:** The NODE_PATH hack is too fragile for a skill that Claude agents execute. One npm version change breaks it.

### 2. Deno

**Verdict: Strong candidate.**

- **npm: specifiers work.** `import sharp from "npm:sharp@0.33.5"` resolves and executes, including native libvips bindings. Verified on this machine (Deno 2.7.1).
- **Playwright works** with `--node-modules-dir=auto` (needed for postinstall browser download). Browser binaries still need a one-time `npx playwright install chromium`.
- **Existing CJS script runs with zero modifications:** `deno run --allow-all --node-modules-dir=auto html2pptx-local.cjs` — tested, clean exit.
- **ESM scripts need minor adjustment** — the repo's `package.json` has `"type": "module"` but html2pptx.js uses `require()`. Options: rename to `.cjs`, remove `"type": "module"`, or pass `--unstable-detect-cjs`.
- **deno.json** replaces package.json for dependency pinning:
  ```json
  {
    "nodeModulesDir": "auto",
    "imports": {
      "playwright": "npm:playwright@1.49.0",
      "sharp": "npm:sharp@0.33.5",
      "pptxgenjs": "npm:pptxgenjs@4.0.1"
    }
  }
  ```
- **Installation:** Already installed on this machine (`brew install deno`). Can also run via `npx deno` without global install.
- **Deno also understands existing package.json** — can be adopted incrementally.

**Caveats:**
- `nodeModulesDir: "auto"` is required for sharp and playwright (lifecycle scripts). This does create a `node_modules/` on first run — not truly "zero files", but it's automatic.
- Lifecycle scripts (postinstall) are skipped without `nodeModulesDir` — sharp works anyway (prebuilt binaries), but playwright doesn't.

### 3. Bun

**Verdict: Too risky for this use case.**

- Bun's auto-install feature downloads packages on the fly — no install step for pure-JS packages. Works for pptxgenjs, react, react-dom, react-icons.
- **Sharp:** Works in recent Bun versions but has a troubled history (segfaults, missing platform binaries). Requires `bun install` for native bindings (auto-install skips postinstall scripts).
- **Playwright:** Partial support. Playwright has an open PR for Bun compatibility but it's not officially supported. Browser control via child processes can fail. `bun install` + `bunx playwright install chromium` still needed.
- **No inline dependency declarations** (PEP 723 equivalent). Feature requested but not implemented (oven-sh/bun#26532).
- Not installed on this machine.

**Bottom line:** Adds a new runtime dependency with incomplete Playwright support. Risk outweighs the benefit over Deno or Node.

### 4. Keep package.json, lazy install

**Verdict: Pragmatic fallback.**

- Keep `package.json` but check for `node_modules/` and run `npm install` on first use.
- Skill instructions would say: "Run `npm install` in the repo root (one-time setup)" — similar to how system tools (soffice, pandoc) are documented.
- Advantage: zero rewrites, zero risk.
- Disadvantage: doesn't advance the zero-install goal.

### 5. Hybrid: npx-runnable package

**Verdict: Feasible but over-engineered for one library.**

- Restructure html2pptx.js as an npm package with `bin` entry. Publish to npm or use local path.
- Then `npx html2pptx slide.html output.pptx` handles dependencies via the package's own package.json.
- This would work but requires publishing and maintaining an npm package — heavy for one internal tool.

## Additional Findings

### Chromium binary (all candidates)

Every candidate requires a one-time `npx playwright install chromium` (~150MB). This is unavoidable — Playwright doesn't bundle browsers. This is comparable to the soffice/pandoc system tool requirement already documented.

**Lighter alternative:** puppeteer-core + system Chrome. But html2pptx.js uses Playwright's API extensively — rewriting to puppeteer is scope creep and loses Playwright's cross-browser support.

### react / react-dom / react-icons

These are **not html2pptx.js dependencies**. They're used in ad-hoc scripts Claude generates to rasterize icons (React component → SVG string → Sharp → PNG). These scripts are generated fresh per presentation. For the zero-install goal:
- With Deno: `import { FaHome } from "npm:react-icons/fa"` works inline.
- With npx: `npx --package=react --package=react-dom --package=react-icons -c 'node rasterize.js'` works (with the NODE_PATH hack).
- With current Node: they need `npm install` to be available.

The cleanest approach: these are workflow deps that belong in the generated script's inline metadata (like PEP 723 for Python), not in the repo's package.json.

### openpyxl (Python — bonus finding)

`openpyxl` is in requirements.txt but not imported by any script under `public/`. It's referenced in `xlsx/SKILL.md` as inline code that Claude generates. Under SPEC-001's uv approach, these become `uv run --with openpyxl` in generated scripts — no repo-level dependency needed.

## Go / No-Go Criteria

- **Go**: A candidate allows running `html2pptx.js` (or equivalent) with zero prior `npm install`, handles native modules, and doesn't require the user to install a new runtime beyond what `uv`/`npx` provides.
- **No-Go**: All candidates require a persistent `node_modules/` or a new runtime install with no clear advantage over the current `npm install` approach.

## Pivot Recommendation

If no zero-install approach works cleanly for the Node.js side, keep the current `package.json` + `npm install` but document it as a one-time setup step (parallel to how system tools like `soffice` are handled). Focus the zero-install win on the Python side (SPEC-001).

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
| Active | 2026-03-30 | — | Research complete, findings populated |
| Complete | 2026-03-30 | — | Verdict: Go — Deno for Node.js zero-install |
