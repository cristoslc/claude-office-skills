# Changelog

## [1.2.1] - 2026-04-10

### Features

#### Windows-compatible browser launch for html2pptx

Deno on Windows does not support the extra stdio pipes that Playwright's default browser launch requires, causing a `TypeError: Cannot read properties of undefined` crash. The new `launchBrowserWindows()` function bypasses this by spawning Chrome directly and connecting via the Chrome DevTools Protocol (CDP), scanning stderr for the WebSocket URL. This path is gated on `process.platform === 'win32'` — macOS and Linux continue using Playwright's standard launcher.

- Converted `html2pptx.js` from ESM imports to CJS (`require`/`module.exports`) so Deno's CJS interop resolves bare module specifiers like `playwright` and `sharp` correctly. The skill is consumed via `require()` per the documented pattern; ESM added no value and broke that interop.
- Added `process.env.TEMP` and `process.env.TMP` fallbacks to the `tmpDir` default, since Windows doesn't set `TMPDIR`.

### Supporting Changes

- Bumped minimum Pillow version from `>=10.0.0` to `>=10.2.0` to address CVE-2023-50447 (arbitrary code execution via `PIL.ImageMath.eval`).

## [1.2.0] - 2026-04-10

### Features

#### Standalone Tool Distribution
Rewrote the office-install skill to support standalone tool installs and proper skill distribution, enabling agentic setup without global system pollution.

- Added legacy skill detection to office-install for smoother migrations.
- Shipped deno.json and deno.lock within the office-install resources for reliable npm dependency resolution via Deno.
- Migrated the project toolchain from venv/npm to uv/deno for faster, portable execution.

### Supporting Changes

- Migrated AGENTS.md to be contributor-only, moving all consumer-facing instructions into individual SKILL.md files.
- Updated README.md to reflect the new portable toolchain and setup guidance.

### Features

#### Consistent office-* namespace

All skill directories now follow the `office-*` naming convention (`office-pptx/`, `office-docx/`, `office-pdf/`, `office-xlsx/`, `office-install/`). Path references updated across AGENTS.md, README, skills-system.md, and all planning artifacts.

#### Agent-facing install skill

New `office-install` skill provides progressive, environment-adaptive setup guidance. The agent detects the platform, checks what's present, and acquires missing tools using the least-privileged method available — including portable zip-extracted binaries for corporate Windows where elevation is unavailable.

- Visual verification is now mandatory in all PPTX and DOCX skill workflows (two-pass: thumbnail grid + per-slide detail check)

### Planned

#### Zero-install portable toolchain

Six specs designed under EPIC-001 to eliminate all installation steps. PEP 723 inline metadata for Python scripts (SPEC-001), system tool replacement with bundled Python packages (SPEC-002), Deno migration for html2pptx (SPEC-003), cross-platform wrapper scripts with tool discovery (SPEC-004), documentation updates (SPEC-005), and the install skill (SPEC-006). Target: clone the repo and run with only uv, deno, and LibreOffice — all installable without elevation.

### Supporting Changes

- Removed swain governance skills and runtime artifacts (.agents/, skills-lock.json, deno.lock, ROADMAP.md) from git tracking — these are runtime-only and now gitignored
- Gitignore consolidated: .agents/, .claude/, tools/, deno.lock, skills-lock.json, ROADMAP.md
