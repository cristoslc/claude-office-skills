# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.4] - 2026-06-01

### Added

- `office-pptx`: Document `slide.addNotes()` API in html2pptx.md and SKILL.md
  so agents can add speaker notes to any slide after HTML conversion
- `docs/`: Trove `pptx-speaker-notes` — PptxGenJS speaker notes API and
  OOXML notes slide structure reference
- `CHANGELOG.md`: Project changelog

## [1.2.3] - 2026-05-XX

### Fixed

- Prism review findings: exception handling, input validation, and security
  hardening

## [1.2.2] - 2026-05-XX

### Fixed

- Deno 2 compatibility, BOM issues, and Playwright path resolution
- `office-install`: Add non-interactive execution requirement

## [1.2.1] - 2026-05-XX

### Fixed

- Bump Pillow minimum to 10.2.0 (CVE-2023-50447)
- `html2pptx`: Windows compatibility — CDP launch and CJS conversion

## [1.2.0] - 2026-05-XX

### Added

- Legacy skill detection in `office-install`
- `office-install`: Ship `deno.json`/`deno.lock` in `resources/` for npm
  dependency resolution
- Trove: `skill-writing-best-practices` (7 sources)

### Changed

- `AGENTS.md` refactored to be contributor-only; consumer instructions
  migrated to SKILL.md files
- `office-install` rewritten for standalone tool installs and proper
  skill distribution
- Toolchain migrated from `venv`/`npm` to `uv`/`deno`

## [1.1.0] - 2026-05-XX

### Added

- Swain skills installation
- Mandatory visual verification (two-pass) to all skill docs

### Changed

- Repository renamed to `office-skills`; all skills prefixed with `office-`

## [1.0.0] - 2026-05-XX

### Added

- Initial release: Office document manipulation skills (PPTX, DOCX, XLSX,
  PDF, Install)
- Skills for creating, editing, and analyzing Office documents
- Environment setup via `office-install` skill

[Unreleased]: https://github.com/cristoslc/office-skills/compare/v1.2.4...HEAD
[1.2.4]: https://github.com/cristoslc/office-skills/releases/tag/v1.2.4
[1.2.3]: https://github.com/cristoslc/office-skills/releases/tag/v1.2.3
[1.2.2]: https://github.com/cristoslc/office-skills/releases/tag/v1.2.2
[1.2.1]: https://github.com/cristoslc/office-skills/releases/tag/v1.2.1
[1.2.0]: https://github.com/cristoslc/office-skills/releases/tag/v1.2.0
[1.1.0]: https://github.com/cristoslc/office-skills/releases/tag/v1.1.0
[1.0.0]: https://github.com/cristoslc/office-skills/releases/tag/v1.0.0