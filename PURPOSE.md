# PURPOSE

**office-skills** is a skills library that gives AI coding agents the ability to create and manipulate Office documents — PowerPoint, Word, Excel, and PDF — through structured, repeatable workflows.

## Why this exists

Coding agents are powerful at generating code but have no native understanding of Office document formats. OOXML is complex, libraries have sharp edges, and the workflows for creating a polished presentation or filling a PDF form involve multi-step processes that agents get wrong when improvising. This repository encodes those workflows as skills: read-this-then-do-that instructions that turn document manipulation from a guess-and-check exercise into a reliable operation.

## What it values

- **Zero ceremony.** Clone the repo, have the prerequisites, and everything works. No virtual environments, no package installation, no build steps.
- **Agent-first ergonomics.** Skills are designed to be consumed by AI agents, not read by humans in a browser. Wrapper scripts provide a simple API; SKILL.md files provide the decision logic.
- **Fidelity over speed.** A document that looks wrong is worse than no document. Workflows include validation steps, thumbnail grids for visual checking, and explicit error handling for common OOXML pitfalls.
- **Portability.** Skills work with any agent that can read markdown and run shell commands. No proprietary runtime, no cloud service, no API keys.

## What it is not

- Not a document conversion service
- Not a template library (though it works with templates)
- Not a GUI application
- Not tied to any specific AI provider
