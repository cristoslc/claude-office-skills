---
name: office-install
description: "Environment setup for office-skills. When Claude needs to verify or install prerequisites before running any office skill workflow — detects platform, checks what's present, acquires what's missing to a local tools/ directory and writes a paths.json that other skills read."
---

# Office Skills — Environment Setup

This skill installs the tools required by the office-skills repository into a single local directory and writes a `paths.json` that other skills use to locate them. Follow it sequentially — each phase gates the next. Skip phases where all checks already pass.

**Do not run this proactively.** Only follow this workflow when:
- A script fails because a tool is missing
- The user explicitly asks to set up the environment
- You're operating in a new environment for the first time

## Tool home

All tools are installed under:

```
.agents/skills/office-install/tools/
```

If this repo is used globally (e.g. from `~/.agents/skills/`), that path is `~/.agents/skills/office-install/tools/`. The install script resolves the correct root automatically.

After installation, a `paths.json` is written to the same `tools/` directory. Other skills read this file to locate `uv`, `deno`, and `soffice` without assuming they are on PATH.

## Phase 0: Detect environment

Run these checks and record the results. Every later decision branches on them.

```bash
uname -s 2>/dev/null || echo WINDOWS
uname -m 2>/dev/null
echo "$SHELL"
```

Record:
- **Platform**: macOS / Linux / Windows
- **Architecture**: arm64 / x86_64
- **Has admin/elevation**: yes / no / unknown

If on Windows and the user hasn't stated whether elevation is available, **ask before proceeding**. Do not assume.

## Phase 1: Python runtime — `uv`

`uv` is the single prerequisite for all Python-based skills. It bundles its own Python — no system Python needed.

### Check

```bash
# Check if already installed in tools/
TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)/.agents/skills/office-install/tools"
if [ -f "$TOOLS_DIR/uv" ] || [ -f "$TOOLS_DIR/uv.exe" ]; then
  echo "uv found in tools/"
elif command -v uv &>/dev/null; then
  echo "uv on PATH"
fi
```

If uv is already in `tools/` or on PATH (version 0.4+), skip to Phase 2.

### Install to `tools/`

**macOS / Linux:**

```bash
TOOLS_DIR=".agents/skills/office-install/tools"
mkdir -p "$TOOLS_DIR"
curl -LsSf https://astral.sh/uv/install.sh | DENO_INSTALL=no UV_INSTALL_DIR="$TOOLS_DIR" sh -s -- --no-modify-path
```

The install script for uv respects `UV_INSTALL_DIR` and `--no-modify-path` to avoid touching shell profiles.

**Windows — elevation available:**

```powershell
$toolsDir = Join-Path $PWD ".agents\skills\office-install\tools"
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
winget install astral-sh.uv --location $toolsDir
```

**Windows — no elevation:**

Download the standalone binary:

```powershell
$toolsDir = Join-Path $PWD ".agents\skills\office-install\tools"
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
$arch = if ([Environment]::Is64BitOperatingSystem) { "x86_64" } else { "i686" }
$uvVersion = "0.7.12"
$url = "https://github.com/astral-sh/uv/releases/download/$uvVersion/uv-$arch-pc-windows-msvc.zip"
$zip = Join-Path $toolsDir "uv.zip"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest $url -OutFile $zip
Expand-Archive $zip $toolsDir -Force
Remove-Item $zip
```

### Verify

```bash
.agents/skills/office-install/tools/uv --version
```

Or on Windows: `& "$toolsDir\uv.exe" --version`

If uv was already on PATH and not in tools/, symlink or copy it:

```bash
TOOLS_DIR=".agents/skills/office-install/tools"
mkdir -p "$TOOLS_DIR"
cp "$(command -v uv)" "$TOOLS_DIR/"
```

## Phase 2: JavaScript runtime — `deno`

Required only for the `pptx` html2pptx workflow. If the user is only working with DOCX, PDF, or XLSX, skip this phase entirely.

### Check

```bash
deno --version
```

If this succeeds (any version 2.0+), copy it to tools/ and skip:

```bash
TOOLS_DIR=".agents/skills/office-install/tools"
mkdir -p "$TOOLS_DIR"
cp "$(command -v deno)" "$TOOLS_DIR/"
```

### Install to `tools/`

**macOS / Linux:**

```bash
TOOLS_DIR=".agents/skills/office-install/tools"
mkdir -p "$TOOLS_DIR"
curl -fsSL https://deno.land/install.sh | DENO_INSTALL="$TOOLS_DIR" sh
```

The deno install script reads `DENO_INSTALL` to set the target directory. Do NOT pass `-y` — the script is non-interactive when `DENO_INSTALL` is set and stdout is not a TTY (piped from curl).

**Windows — elevation available:**

```powershell
$toolsDir = Join-Path $PWD ".agents\skills\office-install\tools"
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
winget install DenoLand.Deno --location $toolsDir
```

**Windows — no elevation:**

```powershell
$toolsDir = Join-Path $PWD ".agents\skills\office-install\tools"
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
$denoVersion = "2.3.2"
$url = "https://github.com/denoland/deno/releases/download/v$denoVersion/deno-x86_64-pc-windows-msvc.zip"
$zip = Join-Path $toolsDir "deno.zip"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest $url -OutFile $zip
Expand-Archive $zip $toolsDir -Force
Remove-Item $zip
```

### Corporate network / TLS certificate support

**Deno does not use the system certificate store by default.** On corporate networks that proxy TLS with a self-signed certificate (installed in the OS trust store), Deno will fail with certificate errors.

Set this environment variable to tell Deno to read the system CA store:

```bash
export DENO_TLS_CA_STORE=system
```

Add it to the user's shell profile (`~/.zshrc`, `~/.bashrc`, etc.) so it persists.

On Windows (PowerShell profile):

```powershell
[System.Environment]::SetEnvironmentVariable('DENO_TLS_CA_STORE', 'system', 'User')
```

If that doesn't resolve it (some corporate setups use a separate PEM file), use:

```bash
export DENO_CERT=/path/to/corporate-ca.pem
# or per-invocation:
deno --cert /path/to/corporate-ca.pem ...
```

**Always set `DENO_TLS_CA_STORE=system` before running `deno` in this skill.** This ensures the install and verification steps work on corporate networks.

### Verify

```bash
DENO_TLS_CA_STORE=system .agents/skills/office-install/tools/deno eval "console.log('deno works')"
```

## Phase 3: Playwright browser

Required only for the `pptx` html2pptx workflow (same gate as Phase 2).

### Check

```bash
DENO_TLS_CA_STORE=system .agents/skills/office-install/tools/deno run npm:playwright --version
```

### Install

```bash
DENO_TLS_CA_STORE=system .agents/skills/office-install/tools/deno run npm:playwright install chromium
```

This downloads Chromium to a userspace cache (~150MB). No elevation needed.

### If blocked

If the download fails due to network policy:
- Set `HTTPS_PROXY` / `HTTP_PROXY` environment variables
- Or download the Chromium archive manually and set `PLAYWRIGHT_BROWSERS_PATH`

## Phase 4: LibreOffice

Required for: PPTX-to-PDF conversion, XLSX formula recalculation, and document validation rendering. If the user only needs text extraction, XML editing, or PDF form filling, skip this phase.

### Check

```bash
soffice --version 2>/dev/null || echo "not found"
```

If `soffice` is on PATH, symlink it into tools/ and skip the download:

```bash
TOOLS_DIR=".agents/skills/office-install/tools"
mkdir -p "$TOOLS_DIR"
ln -sf "$(command -v soffice)" "$TOOLS_DIR/soffice"
```

### Install to `tools/`

The goal is to extract a portable `soffice` binary into `tools/` without requiring admin rights or system-wide installation.

**macOS — download DMG, extract app:**

```bash
TOOLS_DIR=".agents/skills/office-install/tools"
mkdir -p "$TOOLS_DIR"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  LO_ARCH="aarch64"
else
  LO_ARCH="x86_64"
fi

# Download latest LibreOffice DMG
LO_VERSION="26.2.2"
DMG_URL="https://download.documentfoundation.org/libreoffice/stable/${LO_VERSION}/mac/${LO_ARCH}/LibreOffice_${LO_VERSION}_MacOS_${LO_ARCH}.dmg"
DMG_PATH="$TOOLS_DIR/LibreOffice.dmg"

echo "Downloading LibreOffice ${LO_VERSION} for macOS ${LO_ARCH}..."
curl -fSL -o "$DMG_PATH" "$DMG_URL"

# Mount DMG, copy app, unmount
hdiutil attach "$DMG_PATH" -quiet -mountpoint "$TOOLS_DIR/dmg_mount"
cp -R "$TOOLS_DIR/dmg_mount/LibreOffice.app" "$TOOLS_DIR/"
hdiutil detach "$TOOLS_DIR/dmg_mount" -quiet
rm "$DMG_PATH"

# Create soffice symlink
ln -sf "$TOOLS_DIR/LibreOffice.app/Contents/MacOS/soffice" "$TOOLS_DIR/soffice"
```

**Linux — download AppImage:**

```bash
TOOLS_DIR=".agents/skills/office-install/tools"
mkdir -p "$TOOLS_DIR"

ARCH=$(uname -m)
LO_VERSION="26.2.2"
APPIMAGE_URL="https://libreoffice.soluzioniopen.com/download/LibreOffice-${LO_VERSION}-standard-${ARCH}.AppImage"

echo "Downloading LibreOffice ${LO_VERSION} AppImage for ${ARCH}..."
curl -fSL -o "$TOOLS_DIR/LibreOffice.AppImage" "$APPIMAGE_URL"
chmod +x "$TOOLS_DIR/LibreOffice.AppImage"

# Create soffice symlink
ln -sf "$TOOLS_DIR/LibreOffice.AppImage" "$TOOLS_DIR/soffice"
```

**Linux — alternative: download .tar.gz from official site:**

```bash
TOOLS_DIR=".agents/skills/office-install/tools"
mkdir -p "$TOOLS_DIR"

ARCH=$(uname -m)
LO_VERSION="26.2.2"

# Determine package format
if command -v dpkg &>/dev/null; then
  PKG_TYPE="deb"
elif command -v rpm &>/dev/null; then
  PKG_TYPE="rpm"
fi

TAR_URL="https://download.documentfoundation.org/libreoffice/stable/${LO_VERSION}/linux/${ARCH}/${PKG_TYPE}/LibreOffice_${LO_VERSION}_Linux_${ARCH}_${PKG_TYPE}.tar.gz"
echo "Downloading LibreOffice ${LO_VERSION} for Linux ${ARCH} (${PKG_TYPE})..."
curl -fSL -o "$TOOLS_DIR/libreoffice.tar.gz" "$TAR_URL"

# Extract — the tar contains DEBS/ or RPMS/ folder with the packages
cd "$TOOLS_DIR"
tar xzf libreoffice.tar.gz
cd LibreOffice_*/  # enters the extracted directory

# For .deb: extract the core package directly without installing
if [ "$PKG_TYPE" = "deb" ]; then
  dpkg-deb -x DEBS/libreoffice*-core_*.deb "$TOOLS_DIR/libreoffice-opt/"
  dpkg-deb -x DEBS/libreoffice*-core-*.deb "$TOOLS_DIR/libreoffice-opt/" 2>/dev/null || true
  for deb in DEBS/libreoffice*.deb; do dpkg-deb -x "$deb" "$TOOLS_DIR/libreoffice-opt/"; done
else
  for rpm in RPMS/*.rpm; do rpm2cpio "$rpm" | cpio -id -D "$TOOLS_DIR/libreoffice-opt/"; done 2>/dev/null || true
fi

rm libreoffice.tar.gz
ln -sf "$TOOLS_DIR/libreoffice-opt/opt/libreoffice*/program/soffice" "$TOOLS_DIR/soffice"
```

**Windows — download LibreOffice Portable:**

```powershell
$toolsDir = Join-Path $PWD ".agents\skills\office-install\tools"
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

$loVersion = "26.2.2"
$url = "https://download.documentfoundation.org/libreoffice/portable/$loVersion/LibreOfficePortable_${lo_version}_MultilingualStandard.paf.exe"
$installer = Join-Path $toolsDir "LibreOfficePortable.paf.exe"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest $url -OutFile $installer

# PortableApps installer can be extracted with 7-Zip without running it
# The soffice binary will be at: tools\LibreOfficePortable\App\libreoffice\program\soffice.exe
Write-Host "Run the LibreOffice Portable installer and point it to: $toolsDir"
Write-Host "Or extract with 7-Zip: 7z x $installer -o$toolsDir\LibreOfficePortable"
```

### Verify

```bash
.agents/skills/office-install/tools/soffice --version
```

## Phase 5: Write `tools/paths.json`

After all required tools are installed, write a `paths.json` to the `tools/` directory. This is the single file that other skills read to locate tools — they check it before falling back to PATH.

### Format

```json
{
  "tools_dir": "<absolute path to .agents/skills/office-install/tools/>",
  "uv": "<absolute path to uv binary>",
  "deno": "<absolute path to deno binary>",
  "soffice": "<absolute path to soffice binary>",
  "env": {
    "DENO_TLS_CA_STORE": "system"
  }
}
```

Every path must be **absolute**. Use the resolved path — no `~`, no relative paths.

### Writing the file

After completing all relevant phases, resolve absolute paths and write:

```bash
TOOLS_DIR="$(cd '.agents/skills/office-install/tools' && pwd)"

cat > "$TOOLS_DIR/paths.json" << EOF
{
  "tools_dir": "$TOOLS_DIR",
  "uv": "$TOOLS_DIR/uv",
  "deno": "$TOOLS_DIR/deno",
  "soffice": "$TOOLS_DIR/soffice",
  "env": {
    "DENO_TLS_CA_STORE": "system"
  }
}
EOF
```

If a tool was not installed (e.g. deno skipped because user only needs DOCX), set its value to `null`:

```json
{
  "tools_dir": "/abs/path/to/tools",
  "uv": "/abs/path/to/tools/uv",
  "deno": null,
  "soffice": "/abs/path/to/tools/soffice",
  "env": {
    "DENO_TLS_CA_STORE": "system"
  }
}
```

**Always rewrite `paths.json` at the end of every run of this skill**, even if some tools were already present. This ensures the file stays in sync with what's actually installed.

## Phase 6: Verify full stack

Run the checks below for the skills the user needs. Only test what's relevant. Use the paths from `paths.json`.

### Read paths.json

```bash
TOOLS_DIR="$(cd '.agents/skills/office-install/tools' && pwd)"
UV=$(python3 -c "import json; d=json.load(open('$TOOLS_DIR/paths.json')); print(d['uv'] or 'uv')")
DENO=$(python3 -c "import json; d=json.load(open('$TOOLS_DIR/paths.json')); print(d['deno'] or 'deno')")
SOFFICE=$(python3 -c "import json; d=json.load(open('$TOOLS_DIR/paths.json')); print(d['soffice'] or 'soffice')")
```

### Python skills (PPTX/DOCX/PDF/XLSX editing)

```bash
"$UV" run public/office-pptx/scripts/inventory.py --help
```

### html2pptx (PPTX creation from scratch)

```bash
DENO_TLS_CA_STORE=system "$DENO" eval "import('npm:pptxgenjs').then(m => console.log('pptxgenjs', m.default ? 'ok' : 'fail'))"
```

### Visual verification (PPTX/DOCX rendering)

```bash
"$SOFFICE" --headless --version
```

### PDF to images

```bash
"$UV" run public/office-pdf/scripts/convert_pdf_to_images.py --help
```

Report which capabilities are available and which are not. Frame missing capabilities as "these specific workflows won't work" rather than "setup failed."

---

## Skills update — download or refresh from GitHub

The office-skills project lives at `https://github.com/cristoslc/office-skills`. This section handles getting the skills files (SKILL.md, scripts, schemas) onto disk when git is not available, and checking for updates.

### Where skills live on disk

There are two install locations:

| Location | When to use | Path |
|----------|-------------|------|
| **Local (in-repo)** | Running from a git clone of office-skills | `./public/office-install/` (and other `public/office-*`) |
| **Global (standalone)** | Running office-skills as a standalone tool, no clone | `~/.agents/skills/office-install/` (and other `~/.agents/skills/office-*`) |

In global mode, the entire `public/` directory tree from the repo is placed under `~/.agents/skills/`. The `tools/` directory and `paths.json` go inside `~/.agents/skills/office-install/tools/`.

### Check if git is available

```bash
command -v git &>/dev/null && echo "git available" || echo "no git"
```

If git is available, prefer `git clone` or `git pull` — it handles incremental updates, diffs, and rollbacks.

### Fresh download without git

Use the GitHub archive API to download a tarball of the repo and extract the `public/` directory:

**macOS / Linux:**

```bash
SKILLS_DIR="$HOME/.agents/skills"
mkdir -p "$SKILLS_DIR"

# Download the archive (trunk branch)
echo "Downloading office-skills from GitHub..."
curl -fSL "https://github.com/cristoslc/office-skills/archive/refs/heads/trunk.tar.gz" -o /tmp/office-skills.tar.gz

# Extract only the public/ directory to the skills dir
tar xzf /tmp/office-skills.tar.gz -C /tmp/ "office-skills-trunk/public"

# Move public/ contents to the skills root
# Each office-* directory becomes a top-level skill directory
cp -R /tmp/office-skills-trunk/public/ "$SKILLS_DIR/"

# Also copy AGENTS.md and supporting files
cp /tmp/office-skills-trunk/AGENTS.md "$SKILLS_DIR/" 2>/dev/null || true
cp /tmp/office-skills-trunk/requirements.txt "$SKILLS_DIR/" 2>/dev/null || true

# Clean up
rm -rf /tmp/office-skills.tar.gz /tmp/office-skills-trunk

# Record the installed version
REMOTE_SHA=$(curl -fsSL "https://api.github.com/repos/cristoslc/office-skills/commits/trunk" | python3 -c "import json,sys; print(json.load(sys.stdin)['sha'])" 2>/dev/null || echo "unknown")
echo "$REMOTE_SHA" > "$SKILLS_DIR/office-install/.installed-sha"

echo "Skills installed to $SKILLS_DIR/ (SHA: $REMOTE_SHA)"
```

**Windows (PowerShell):**

```powershell
$skillsDir = Join-Path $env:USERPROFILE ".agents\skills"
New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null

$url = "https://github.com/cristoslc/office-skills/archive/refs/heads/trunk.zip"
$zip = Join-Path $env:TEMP "office-skills.zip"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest $url -OutFile $zip

Expand-Archive $zip $env:TEMP -Force
$extracted = Join-Path $env:TEMP "office-skills-trunk\public"

# Copy each skill directory
Copy-Item -Path "$extracted\office-*" -Destination $skillsDir -Recurse -Force

# Record the installed version
$sha = (Invoke-RestMethod -Uri "https://api.github.com/repos/cristoslc/office-skills/commits/trunk" -ErrorAction SilentlyContinue).sha
if ($sha) { $sha | Out-File (Join-Path $skillsDir "office-install\.installed-sha") -Encoding utf8 }

# Clean up
Remove-Item $zip -Force
Remove-Item (Join-Path $env:TEMP "office-skills-trunk") -Recurse -Force

Write-Host "Skills installed to $skillsDir"
```

### Check for updates

Compare the local version against the latest on GitHub. The simplest check is the commit SHA of the `trunk` branch:

```bash
REMOTE_SHA=$(curl -fsSL "https://api.github.com/repos/cristoslc/office-skills/commits/trunk" | python3 -c "import json,sys; print(json.load(sys.stdin)['sha'])" 2>/dev/null)
LOCAL_SHA_FILE="$HOME/.agents/skills/office-install/.installed-sha"

if [ -f "$LOCAL_SHA_FILE" ]; then
  LOCAL_SHA=$(cat "$LOCAL_SHA_FILE")
  if [ "$REMOTE_SHA" = "$LOCAL_SHA" ]; then
    echo "Skills are up to date ($REMOTE_SHA)"
  else
    echo "Update available: local=$LOCAL_SHA remote=$REMOTE_SHA"
  fi
else
  echo "No local version recorded. Run the fresh download to install."
fi
```

### Apply updates

Updates use the same download-and-extract approach as a fresh install. The `public/` directories are overwritten in place. Tools and `paths.json` are preserved because they live inside `tools/` (which is not overwritten by the skill download).

**macOS / Linux:**

```bash
SKILLS_DIR="$HOME/.agents/skills"

# Get the latest commit SHA
REMOTE_SHA=$(curl -fsSL "https://api.github.com/repos/cristoslc/office-skills/commits/trunk" | python3 -c "import json,sys; print(json.load(sys.stdin)['sha'])")

# Download and extract (same as fresh download)
curl -fSL "https://github.com/cristoslc/office-skills/archive/refs/heads/trunk.tar.gz" -o /tmp/office-skills.tar.gz
tar xzf /tmp/office-skills.tar.gz -C /tmp/ "office-skills-trunk/public"
cp -R /tmp/office-skills-trunk/public/ "$SKILLS_DIR/"
cp /tmp/office-skills-trunk/AGENTS.md "$SKILLS_DIR/" 2>/dev/null || true
cp /tmp/office-skills-trunk/requirements.txt "$SKILLS_DIR/" 2>/dev/null || true
rm -rf /tmp/office-skills.tar.gz /tmp/office-skills-trunk

# Record the installed version
echo "$REMOTE_SHA" > "$SKILLS_DIR/office-install/.installed-sha"
echo "Updated skills to $REMOTE_SHA"
```

**Using git (if available):**

```bash
SKILLS_DIR="$HOME/.agents/skills/office-skills"

if [ -d "$SKILLS_DIR/.git" ]; then
  # Existing clone — pull latest
  git -C "$SKILLS_DIR" pull --ff-only
else
  # Fresh clone
  git clone https://github.com/cristoslc/office-skills.git "$SKILLS_DIR"
  # Then symlink or copy public/office-* to ~/.agents/skills/
fi
```

### GitHub API rate limits

Unauthenticated GitHub API requests are rate-limited to 60/hour. The commit-SHA check above uses one request. If you hit the limit:

- Use the archive URL directly (no API call needed): `https://github.com/cristoslc/office-skills/archive/refs/heads/trunk.tar.gz`
- For update checks without the API, compare the `last-modified` header of the archive URL against a stored timestamp
- Or set `GITHUB_TOKEN` in the environment for 5000/hour rate limit

### Offline / air-gapped environments

If the machine has no internet access:
1. Download the tarball on another machine: `curl -fSL -o office-skills.tar.gz https://github.com/cristoslc/office-skills/archive/refs/heads/trunk.tar.gz`
2. Transfer it via USB, shared drive, etc.
3. Extract manually: `tar xzf office-skills.tar.gz && cp -R office-skills-trunk/public/ ~/.agents/skills/`

## Tool discovery — how other skills find tools

Other skills (pptx, docx, pdf, xlsx) locate tools using this search order:

1. **Read `paths.json`** from `.agents/skills/office-install/tools/paths.json` (or `~/.agents/skills/office-install/tools/paths.json` for global installs)
2. If a tool's value is a non-null string, use that path
3. If a tool's value is `null` or the key is missing, fall back to PATH (`command -v <tool>`)
4. Set environment variables from the `env` object (e.g. `DENO_TLS_CA_STORE=system`)

When generating or running wrapper scripts, use this search order. If a tool is in `tools/`, construct the full path rather than assuming it's on PATH.

### Shell helper — resolve a tool path

```bash
office_tool() {
  local tool="$1"
  local paths_file
  for dir in ".agents/skills/office-install/tools" "$HOME/.agents/skills/office-install/tools"; do
    if [ -f "$dir/paths.json" ]; then
      paths_file="$dir/paths.json"
      break
    fi
  done
  if [ -n "$paths_file" ]; then
    local resolved
    resolved=$(python3 -c "import json,sys; d=json.load(open('$paths_file')); v=d.get('$tool'); print(v if v else '')" 2>/dev/null)
    if [ -n "$resolved" ]; then
      echo "$resolved"
      return
    fi
  fi
  command -v "$tool"
}
```

Usage: `UV="$(office_tool uv)"`, `DENO="$(office_tool deno)"`, `SOFFICE="$(office_tool soffice)"`

## Troubleshooting

### Deno certificate errors on corporate networks

Set `DENO_TLS_CA_STORE=system` before all deno invocations:

```bash
export DENO_TLS_CA_STORE=system
```

If this doesn't work, your corporate cert may not be in the system store. Export it as PEM and use:

```bash
export DENO_CERT=/path/to/corporate-ca.pem
```

Or per-invocation: `deno --cert /path/to/corporate-ca.pem ...`

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
- Check if `HTTPS_PROXY` is set: `echo $HTTPS_PROXY`
- Ask the user for their proxy URL and set it before retrying
- Some corporate environments require a PAC file — the user will know

### `uv run` fails to download Python

uv downloads Python from GitHub releases. If this is blocked:
- The user can pre-install Python via their IT-approved method
- Then set `UV_PYTHON` to point to it: `export UV_PYTHON="/path/to/python3"`
- uv will use that Python instead of downloading its own

### LibreOffice download is too large

The `soffice` binary alone is ~350MB+. If the download is impractical:
- On macOS: `brew install --cask libreoffice` (if Homebrew is available)
- On Linux: `sudo apt-get install -y libreoffice-core --no-install-recommends` (Debian/Ubuntu, smaller footprint)
- Then symlink the system `soffice` into `tools/`