---
name: office-install
description: "Environment setup for office-skills. When Claude needs to verify or install prerequisites before running any office skill workflow — detects platform, checks what's present, acquires what's missing using the least-privileged method available."
---

# Office Skills — Environment Setup

This skill walks you through verifying and installing the tools required by the office-skills repository. Follow it sequentially — each phase gates the next. Skip phases where all checks already pass.

**Do not run this proactively.** Only follow this workflow when:
- A script fails because a tool is missing
- The user explicitly asks to set up the environment
- You're operating in a new environment for the first time

## Phase 0: Detect environment

Run these checks and record the results. Every later decision branches on them.

```bash
# Platform
uname -s 2>/dev/null || echo WINDOWS

# Shell
echo "$SHELL" 2>/dev/null; if defined COMSPEC (echo %COMSPEC%)

# Package managers available (don't install anything yet)
which brew 2>/dev/null      # macOS
which apt-get 2>/dev/null   # Debian/Ubuntu
which scoop 2>/dev/null     # Windows userspace
which choco 2>/dev/null     # Windows admin (may need elevation)
which winget 2>/dev/null    # Windows 10+ built-in
```

Record what you find:
- **Platform**: macOS / Linux / Windows
- **Has admin/elevation**: yes / no / unknown
- **Userspace package manager**: brew / scoop / none
- **System package manager**: apt / dnf / pacman / choco / winget / none

If on Windows and the user hasn't stated whether elevation is available, **ask before proceeding**. Do not assume.

## Phase 1: Python runtime — `uv`

`uv` is the single prerequisite for all Python-based skills. It bundles its own Python — no system Python needed.

### Check

```bash
uv --version
```

If this succeeds (any version 0.4+), skip to Phase 2.

### Install — by platform

**macOS (Homebrew):**
```bash
brew install uv
```

**Linux (curl):**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Windows — elevation available:**
```powershell
winget install astral-sh.uv
```

**Windows — no elevation (corporate/locked-down):**

The default install script (`irm https://astral.sh/uv/install.ps1 | iex`) may trigger security warnings. Instead, download the standalone binary:

1. Determine architecture:
   ```powershell
   $arch = if ([Environment]::Is64BitOperatingSystem) { "x86_64" } else { "i686" }
   ```

2. Download and extract:
   ```powershell
   $uvVersion = "0.7.12"  # pin to known-good version
   $url = "https://github.com/astral-sh/uv/releases/download/$uvVersion/uv-$arch-pc-windows-msvc.zip"
   $toolsDir = Join-Path $PWD "tools"
   New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
   $zip = Join-Path $toolsDir "uv.zip"
   Invoke-WebRequest $url -OutFile $zip
   Expand-Archive $zip $toolsDir -Force
   Remove-Item $zip
   ```

3. Verify it runs from the extracted location:
   ```powershell
   & "$toolsDir\uv.exe" --version
   ```

4. If the organization's endpoint protection blocks execution of the downloaded binary, **stop and tell the user** — this environment may require IT to allowlist `uv.exe`, or the user may need to use a pre-approved Python installation instead.

### Verify

```bash
uv run --with rich python -c "import rich; print('uv works')"
```

This confirms uv can download Python, resolve a package, and execute. If it fails, diagnose before continuing.

## Phase 2: JavaScript runtime — `deno`

Required only for the `pptx` html2pptx workflow. If the user is only working with DOCX, PDF, or XLSX, skip this phase entirely.

### Check

```bash
deno --version
```

If this succeeds (any version 2.0+), skip to Phase 3.

### Install — by platform

**macOS (Homebrew):**
```bash
brew install deno
```

**Linux (curl):**
```bash
curl -fsSL https://deno.land/install.sh | sh
```

**Windows — elevation available:**
```powershell
winget install DenoLand.Deno
```

**Windows — no elevation:**

Same pattern as uv — download the zip and extract:

1. Download and extract:
   ```powershell
   $denoVersion = "2.3.2"  # pin to known-good version
   $url = "https://github.com/denoland/deno/releases/download/v$denoVersion/deno-x86_64-pc-windows-msvc.zip"
   $toolsDir = Join-Path $PWD "tools"
   New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
   $zip = Join-Path $toolsDir "deno.zip"
   Invoke-WebRequest $url -OutFile $zip
   Expand-Archive $zip $toolsDir -Force
   Remove-Item $zip
   ```

2. Verify:
   ```powershell
   & "$toolsDir\deno.exe" --version
   ```

3. Same caveat as uv — if the binary is blocked by endpoint protection, inform the user.

### Verify

```bash
deno eval "console.log('deno works')"
```

## Phase 3: Playwright browser

Required only for the `pptx` html2pptx workflow (same gate as Phase 2).

### Check

```bash
deno run npm:playwright --version
```

If Chromium is already installed, this outputs a version. If not, it will print a message about missing browsers.

### Install

```bash
deno run npm:playwright install chromium
```

This downloads Chromium to a userspace cache (~150MB). No elevation needed on any platform.

### If blocked

If the download fails due to network policy (proxy, firewall), the user may need to:
- Set `HTTPS_PROXY` / `HTTP_PROXY` environment variables
- Or download the Chromium archive manually and set `PLAYWRIGHT_BROWSERS_PATH`

Tell the user what failed and ask how their network is configured.

## Phase 4: LibreOffice

Required for: PPTX-to-PDF conversion, XLSX formula recalculation, and document validation rendering. If the user only needs text extraction, XML editing, or PDF form filling, skip this phase.

### Check

```bash
soffice --version
```

### Install — by platform

**macOS:**
```bash
brew install --cask libreoffice
```

**Linux:**
```bash
sudo apt-get install -y libreoffice    # Debian/Ubuntu
sudo dnf install -y libreoffice        # Fedora
```

**Windows — elevation available:**
```powershell
winget install TheDocumentFoundation.LibreOffice
```

**Windows — no elevation:**

LibreOffice Portable runs entirely from a folder with no installation, no registry writes, and no elevation:

1. Direct the user to download LibreOffice Portable from https://www.libreoffice.org/download/portable-versions/
2. They should extract it to a local directory (e.g., `tools\LibreOfficePortable\`)
3. The `soffice.exe` path will be inside `App\libreoffice\program\soffice.exe`
4. Verify:
   ```powershell
   & "tools\LibreOfficePortable\App\libreoffice\program\soffice.exe" --version
   ```

**Note**: LibreOffice Portable is ~350MB. This is a manual download — do not attempt to automate it without asking the user first.

## Phase 5: Verify full stack

Run the checks below for the skills the user needs. Only test what's relevant.

### Python skills (PPTX/DOCX/PDF/XLSX editing)

```bash
uv run public/office-pptx/scripts/inventory.py --help
```

### html2pptx (PPTX creation from scratch)

```bash
deno eval "import('npm:pptxgenjs').then(m => console.log('pptxgenjs', m.default ? 'ok' : 'fail'))"
```

### Visual verification (PPTX/DOCX rendering)

```bash
soffice --headless --version
```

### PDF to images

```bash
uv run public/office-pdf/scripts/convert_pdf_to_images.py --help
```

Report which capabilities are available and which are not. Frame missing capabilities as "these specific workflows won't work" rather than "setup failed."

## Tool discovery for wrapper scripts

When tools are installed to `tools/` rather than on PATH, wrapper scripts need to find them. The convention is:

1. Check `OFFICE_SKILLS_UV` / `OFFICE_SKILLS_DENO` / `OFFICE_SKILLS_SOFFICE` env vars (explicit override)
2. Check `<repo-root>/tools/` for portable binaries
3. Fall back to PATH

When generating or running wrapper scripts, use this search order. If a tool is in `tools/`, construct the full path rather than assuming it's on PATH.

## Troubleshooting

### "Execution of scripts is disabled on this system" (Windows PowerShell)

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

This is a per-user setting and does not require elevation.

### Downloaded binary blocked by SmartScreen / endpoint protection

The executable was flagged by the organization's security policy. Options:
- Right-click the .exe → Properties → check "Unblock" (if available)
- Ask IT to allowlist the specific binary hash
- Use a pre-approved Python/Node installation if one exists on the system

Do not try to bypass security controls. Inform the user and ask how to proceed.

### Proxy / firewall blocks downloads

If `Invoke-WebRequest` or `curl` fails:
- Check if `HTTPS_PROXY` is set: `echo $env:HTTPS_PROXY`
- Ask the user for their proxy URL and set it before retrying
- Some corporate environments require a PAC file — the user will know

### `uv run` fails to download Python

uv downloads Python from GitHub releases. If this is blocked:
- The user can pre-install Python via their IT-approved method
- Then set `UV_PYTHON` to point to it: `$env:UV_PYTHON = "C:\Python312\python.exe"`
- uv will use that Python instead of downloading its own
