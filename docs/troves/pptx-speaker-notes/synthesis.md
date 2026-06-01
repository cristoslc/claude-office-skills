# Trove Synthesis: PPTX Speaker Notes Extension

## Key Findings

### 1. PptxGenJS Already Has an `addNotes()` API

`slide.addNotes('TEXT')` is a first-class feature of PptxGenJS. It accepts a plain string and creates the OOXML notes slide + master + relationships internally. **This means extending the html2pptx workflow to support speaker notes requires minimal effort** — just an additional call after `html2pptx()` returns the slide object.

### 2. The html2pptx Workflow Returns the Slide Object

The `html2pptx()` function returns `{ slide, placeholders }`. The `slide` object is the PptxGenJS slide instance, which has `addNotes()` available on it. Users can call `slide.addNotes('...')` after the HTML-to-slide conversion without any changes to the html2pptx library itself.

### 3. Two Patterns for Adding Notes

| Pattern | How it works | When to use |
|---------|-------------|-------------|
| **Per-slide inline** | Call `slide.addNotes()` after each `html2pptx()` call | Notes are determined at slide-creation time |
| **Batch post-process** | Pass notes data as part of the slide script, iteratively call `addNotes` on created slides | Notes come from a separate data source (e.g., a markdown file) |

### 4. OOXML Notes Slide Structure (for the edit/repack workflow)

When editing existing presentations via OOXML unpack/repack, speaker notes live at `ppt/notesSlides/notesSlide{N}.xml` and are referenced from `ppt/slides/_rels/slideN.xml.rels`. This is already documented in the SKILL.md at lines 49 and 369.

### 5. NotesMaster Dependency

A `notesMaster1.xml` file, `notesSz` in `presentation.xml`, and Content_Types overrides are all needed. PptxGenJS handles this automatically when `addNotes()` is called.

## Points of Agreement

Both the PptxGenJS API and the OOXML schema approach agree:
- Speaker notes are per-slide (each slide has its own notes)
- Notes content is plain text (no rich formatting in the standard case)
- The notes are stored independently from slide content XML

## Gaps in Current SKILL.md

### Gap 1: html2pptx workflow doesn't mention `addNotes`

The SKILL.md describes the html2pptx workflow in detail (lines 166-198) but never mentions that `slide.addNotes()` can be called after conversion. Users following the workflow won't know they can add speaker notes.

### Gap 2: SKILL.md description claims speaker notes support but workflow doesn't deliver

Line 3 of SKILL.md says the skill handles "(4) Adding comments or speaker notes" but the actual workflows only cover reading speaker notes (via raw XML at line 39) — not writing them.

### Gap 3: No example of the notes + slide pattern

The html2pptx.md guide has complete examples showing charts, tables, images — but no example combining slide creation with `addNotes()`.

## What to Change

### In SKILL.md
- No structural changes needed (the OOXML edit workflow already lists `ppt/notesSlides/` and covers duplication constraints)
- The html2pptx creation workflow should mention `slide.addNotes()` as an optional post-step

### In html2pptx.md
- Add a "Speaker Notes" section showing how to call `slide.addNotes()` after `html2pptx()`
- Add notes to the complete example at the end

### In html2pptx.cjs (optional enhancement)
- Could accept an optional `notes` property in the `options` parameter and auto-call `addNotes()` — but this would couple HTML semantics to a PowerPoint-only feature. The post-call pattern is cleaner.

## Effort Estimate

| Change | Lines changed | Complexity |
|--------|-------------|------------|
| Add notes section to html2pptx.md | ~15-20 lines | Trivial (documentation only) |
| Add notes to complete example | ~3-5 lines | Trivial |
| Mention notes in SKILL.md creation workflow | ~3-5 lines | Trivial |
| **Total** | **~25 lines** | **Documentation only — pure addition** |

No code changes to html2pptx.cjs are needed — the PptxGenJS `addNotes()` API is already available on the returned slide object. The hard work (OOXML notes slide generation, notes master, Content_Types, relationships) is handled by PptxGenJS internally.