---
name: office-install
description: "Environment setup for office-skills. When Claude needs to verify or install prerequisites before running any office skill workflow — detects platform, checks what's present, acquires what's missing to a local tools/ directory, resolves npm dependencies, and writes a paths.json that other skills read."
---

# Office Skills — Environment Setup

This skill installs the tools required by the office-skills repository into a single local directory, resolves npm dependencies, and writes a `paths.json` that other skills use to locate them. Follow it sequentially — each phase gates the next. Skip phases where all checks already pass.

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

After installation, a `paths.json` is written to the same `tools/` directory. Other skills read this file to locate `uv`, `deno`, `soffice`, and the `node_modules` directory without assuming they are on PATH.

## Two install scenarios

This skill works identically in two layouts:

| | Project | Global |
|---|---------|--------|
| Skill root | `{project}/.agents/skills/office-install/` | `~/.agents/skills/office-install/` |
| `deno.json` / `deno.lock` | Copied from `resources/` to project root | Adapted version from `resources/` in skill root |
| `node_modules/` | `{project_root}/node_modules/` | `{skill_root}/node_modules/` |
| Deno invocation | Bare `deno` from project root | `officedeno` wrapper script |

Phase 0 determines which scenario applies. All later phases branch on it.

## Phase 0: Detect environment

Run these checks and record the results. Every later decision branches on them.

### Platform detection

**macOS / Linux:**

```bash
uname -s 2>/dev/null || echo WINDOWS
uname -m 2>/dev/null
echo "$SHELL"
```

**Windows (PowerShell):**

```powershell
[System.Runtime.InteropServices.RuntimeInformation]::OSDescription
[Environment]::Is64BitOperatingSystem
```

Record:
- **Platform**: macOS / Linux / Windows
- **Architecture**: arm64 / x86_64
- **Has admin/elevation**: yes / no / unknown

If on Windows and the user hasn't stated whether elevation is available, **ask before proceeding**. Do not assume.

### Skill-root resolution

Determine whether the skill is installed project-local or globally:

```bash
SKILL_ROOT=""
for candidate in \
  ".agents/skills/office-install" \
  "$HOME/.agents/skills/office-install"; do
  if [ -f "$candidate/SKILL.md" ]; then
    SKILL_ROOT="$(cd "$candidate" && pwd)"
    break
  fi
done

IS_GLOBAL=false
if [[ "$SKILL_ROOT" == "$HOME/"* ]]; then
  IS_GLOBAL=true
fi
```

**Windows (PowerShell):**

```powershell
$skillRoot = ""
$isGlobal = $false

$projectPath = Join-Path $PWD ".agents\skills\office-install\SKILL.md"
$globalPath = Join-Path $env:USERPROFILE ".agents\skills\office-install\SKILL.md"

if (Test-Path $projectPath) {
    $skillRoot = Join-Path $PWD ".agents\skills\office-install"
} elseif (Test-Path $globalPath) {
    $skillRoot = Join-Path $env:USERPROFILE ".agents\skills\office-install"
    $isGlobal = $true
}
```

Record:
- **SKILL_ROOT**: absolute path to `office-install/` directory
- **IS_GLOBAL**: `true` or `false`

## Phase 1: Python runtime — `uv`

`uv` is the single prerequisite for all Python-based skills. It bundles its own Python — no system Python needed.

### Check

```bash
if [ -f "$SKILL_ROOT/tools/uv" ] || [ -f "$SKILL_ROOT/tools/uv.exe" ]; then
  echo "uv found in tools/"
elif command -v uv &>/dev/null; then
  echo "uv on PATH"
fi
```

If uv is already in `tools/` or on PATH (version 0.4+), skip to Phase 2.

### Install to `tools/`

**macOS / Linux:**

```bash
TOOLS_DIR="$SKILL_ROOT/tools"
mkdir -p "$TOOLS_DIR"
curl -LsSf https://astral.sh/uv/install.sh | DENO_INSTALL=no UV_INSTALL_DIR="$TOOLS_DIR" sh -s -- --no-modify-path
```

**Windows — elevation available:**

```powershell
$toolsDir = Join-Path $skillRoot "tools"
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
winget install astral-sh.uv --location $toolsDir
```

**Windows — no elevation:**

```powershell
$toolsDir = Join-Path $skillRoot "tools"
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
"$SKILL_ROOT/tools/uv" --version
```

If uv was already on PATH and not in tools/, copy it:

```bash
TOOLS_DIR="$SKILL_ROOT/tools"
mkdir -p "$TOOLS_DIR"
cp "$(command -v uv)" "$TOOLS_DIR/"
```

## Phase 2: JavaScript runtime — `deno`

Required only for the `pptx` html2pptx workflow. If the user is only working with DOCX, PDF, or XLSX, skip this phase entirely.

### Check

```bash
deno --version
```

If this succeeds (any version 2.0+), copy it to tools/ and skip the download:

```bash
TOOLS_DIR="$SKILL_ROOT/tools"
mkdir -p "$TOOLS_DIR"
cp "$(command -v deno)" "$TOOLS_DIR/"
```

### Install to `tools/`

**macOS / Linux:**

```bash
TOOLS_DIR="$SKILL_ROOT/tools"
mkdir -p "$TOOLS_DIR"
curl -fsSL https://deno.land/install.sh | DENO_INSTALL="$TOOLS_DIR" sh
```

**Windows — elevation available:**

```powershell
$toolsDir = Join-Path $skillRoot "tools"
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
winget install DenoLand.Deno --location $toolsDir
```

**Windows — no elevation:**

```powershell
$toolsDir = Join-Path $skillRoot "tools"
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

**Deno does not use the system certificate store by default.** On corporate networks that proxy TLS with a self-signed certificate, Deno will fail with certificate errors.

Set this environment variable to tell Deno to read the system CA store:

```bash
export DENO_TLS_CA_STORE=system
```

On Windows (PowerShell profile):

```powershell
[System.Environment]::SetEnvironmentVariable('DENO_TLS_CA_STORE', 'system', 'User')
```

If that doesn't resolve it, use:

```bash
export DENO_CERT=/path/to/corporate-ca.pem
# or per-invocation:
deno --cert /path/to/corporate-ca.pem ...
```

**Always set `DENO_TLS_CA_STORE=system` before running `deno` in this skill.**

### Verify

**macOS / Linux:**

```bash
DENO_TLS_CA_STORE=system "$SKILL_ROOT/tools/deno" eval "console.log('deno works')"
```

**Windows (PowerShell):**

```powershell
$env:DENO_TLS_CA_STORE = "system"
& "$skillRoot\tools\deno.exe" eval "console.log('deno works')"
```

## Phase 3: Deno npm dependencies + Playwright browser

Required only for the `pptx` html2pptx workflow and `pdf` JavaScript libraries (same gate as Phase 2). If the user is only working with DOCX or XLSX text operations, skip this phase entirely.

### What this installs

The following npm packages are declared in `deno.json` (shipped at `$SKILL_ROOT/resources/deno.json`) and required by office skill scripts:

| Package | Purpose |
|---------|---------|
| playwright | Headless browser for HTML rendering |
| sharp | Image processing (SVG→PNG rasterization, has platform-specific native binaries) |
| pptxgenjs | PowerPoint file generation |
| react | React runtime for icon rendering |
| react-dom | Server-side React rendering |
| react-icons | Icon component library |
| pdf-lib | PDF creation and modification |
| pdfjs-dist | PDF text extraction |

Plus the Playwright Chromium browser binary (~150MB).

### Check

Verify that `node_modules/` exists with the key packages installed, including a platform-matching `@img/sharp-*` native binary:

**macOS / Linux:**

```bash
if [ -d "node_modules" ] && [ -d "node_modules/sharp" ] && [ -d "node_modules/playwright" ]; then
  echo "Deno npm dependencies appear installed"
else
  echo "Deno npm dependencies need installation"
fi
```

**Windows (PowerShell):**

```powershell
$nmDir = if ($isGlobal) { Join-Path $skillRoot "node_modules" } else { Join-Path $PWD "node_modules" }
if ((Test-Path $nmDir) -and (Test-Path (Join-Path $nmDir "sharp")) -and (Test-Path (Join-Path $nmDir "playwright"))) {
    Write-Host "Deno npm dependencies appear installed"
} else {
    Write-Host "Deno npm dependencies need installation"
}
```

If the check passes, skip to the Playwright browser step below.

### Step 1: Place `deno.json` and `deno.lock`

The shipped `deno.json` and `deno.lock` are at `$SKILL_ROOT/resources/deno.json` and `$SKILL_ROOT/resources/deno.lock`. They define the import map and integrity-pin all packages.

**Project case** — copy to the project root:

```bash
cp "$SKILL_ROOT/resources/deno.json" "./deno.json"
cp "$SKILL_ROOT/resources/deno.lock" "./deno.lock"
```

**Windows (PowerShell):**

```powershell
Copy-Item (Join-Path $skillRoot "resources\deno.json") (Join-Path $PWD "deno.json") -Force
Copy-Item (Join-Path $skillRoot "resources\deno.lock") (Join-Path $PWD "deno.lock") -Force
```

**Global case** — the shipped `deno.json` has `"html2pptx": "./public/office-pptx/scripts/html2pptx.js"` which is wrong for the global layout (where `public/` doesn't exist — the directory is `office-pptx/scripts/html2pptx.js` directly). Copy to skill root and rewrite the import path:

**macOS / Linux:**

```bash
cp "$SKILL_ROOT/resources/deno.json" "$SKILL_ROOT/deno.json"
cp "$SKILL_ROOT/resources/deno.lock" "$SKILL_ROOT/deno.lock"
python3 -c "
import json
d = json.load(open('$SKILL_ROOT/deno.json'))
d['imports']['html2pptx'] = './office-pptx/scripts/html2pptx.js'
json.dump(d, open('$SKILL_ROOT/deno.json', 'w'), indent=2)
print(json.dumps(d, indent=2))
"
```

**Windows (PowerShell):**

```powershell
Copy-Item (Join-Path $skillRoot "resources\deno.json") (Join-Path $skillRoot "deno.json") -Force
Copy-Item (Join-Path $skillRoot "resources\deno.lock") (Join-Path $skillRoot "deno.lock") -Force
$denoJsonPath = Join-Path $skillRoot "deno.json"
$denoJson = Get-Content $denoJsonPath -Raw | ConvertFrom-Json
$denoJson.imports.html2pptx = "./office-pptx/scripts/html2pptx.js"
$denoJson | ConvertTo-Json -Depth 10 | Set-Content $denoJsonPath
```

The `deno.lock` file does NOT need modification — it pins package integrity hashes, not import paths.

### Step 2: Run `deno install`

This downloads all npm packages declared in `deno.json` into a local `node_modules/` directory, enforced by the integrity hashes in `deno.lock`. No system Node.js or npm is required.

**Project case** — run from project root (where `deno.json` was just copied):

**macOS / Linux:**

```bash
DENO_TLS_CA_STORE=system "$SKILL_ROOT/tools/deno" install
```

**Windows (PowerShell):**

```powershell
$env:DENO_TLS_CA_STORE = "system"
& "$skillRoot\tools\deno.exe" install
```

**Global case** — run from the skill root with explicit config/lock paths:

**macOS / Linux:**

```bash
DENO_TLS_CA_STORE=system "$SKILL_ROOT/tools/deno" install --config "$SKILL_ROOT/deno.json" --lock "$SKILL_ROOT/deno.lock"
```

**Windows (PowerShell):**

```powershell
$env:DENO_TLS_CA_STORE = "system"
& "$skillRoot\tools\deno.exe" install --config "$skillRoot\deno.json" --lock "$skillRoot\deno.lock"
```

This creates `node_modules/` in the same directory as `deno.json`. For the project case, that's the project root. For the global case, that's the skill root.

### Step 3: Install Playwright Chromium browser

**Project case:**

```bash
DENO_TLS_CA_STORE=system "$SKILL_ROOT/tools/deno" run --node-modules-dir=auto npm:playwright install chromium
```

**Global case:**

```bash
DENO_TLS_CA_STORE=system "$SKILL_ROOT/tools/deno" run --config "$SKILL_ROOT/deno.json" --node-modules-dir="$SKILL_ROOT" npm:playwright install chromium
```

**Windows (PowerShell) — global case:**

```powershell
$env:DENO_TLS_CA_STORE = "system"
& "$skillRoot\tools\deno.exe" run --config "$skillRoot\deno.json" --node-modules-dir="$skillRoot" npm:playwright install chromium
```

This downloads Chromium to a userspace cache (~150MB). No elevation needed.

If the download fails due to network policy:
- Set `HTTPS_PROXY` / `HTTP_PROXY` environment variables
- Or download the Chromium archive manually and set `PLAYWRIGHT_BROWSERS_PATH`

### Step 4: (Global only) Write `officedeno` wrapper to working directory

In a global install, the user runs `deno` from their project directory — which has no `deno.json`. The `officedeno` wrapper script points deno at the global `deno.json`, import map, and `node_modules/`.

**macOS / Linux:**

```bash
if [ "$IS_GLOBAL" = true ]; then
  sed "s|__SKILL_ROOT_PLACEHOLDER__|$SKILL_ROOT|g" \
    "$SKILL_ROOT/scripts/officedeno" > ./officedeno
  chmod +x ./officedeno
fi
```

**Windows (PowerShell):**

```powershell
if ($isGlobal) {
    $template = Get-Content (Join-Path $skillRoot "scripts\officedeno.ps1") -Raw
    $script = $template -replace '__SKILL_ROOT_PLACEHOLDER__', $skillRoot
    $script | Set-Content (Join-Path $PWD "officedeno.ps1")
}
```

How other skills use the wrapper: instead of `DENO_TLS_CA_STORE=system deno run --allow-all script.js`, they use `./officedeno run --allow-all script.js` (or `.\officedeno.ps1` on Windows). This resolves the import map and node_modules from the global skill root automatically.

### Step 5: Cross-platform targeting (optional)

If you need native binaries for a platform other than the current one (e.g., preparing a project on macOS to run on Windows), set environment variables before installing:

**macOS / Linux:**

```bash
npm_config_platform=win32 npm_config_arch=x64 DENO_TLS_CA_STORE=system "$SKILL_ROOT/tools/deno" install
```

**Windows (PowerShell):**

```powershell
$env:npm_config_platform = "win32"
$env:npm_config_arch = "x64"
$env:DENO_TLS_CA_STORE = "system"
& "$skillRoot\tools\deno.exe" install
```

Supported platform/arch combinations:
- `linux` + `x64` | `arm64`
- `darwin` + `x64` | `arm64`
- `win32` + `x64`

### Step 6: Verify

Verify all 8 npm packages resolve and sharp's native binary loads:

**macOS / Linux:**

```bash
DENO_TLS_CA_STORE=system "$SKILL_ROOT/tools/deno" eval '
  await import("npm:pptxgenjs");
  await import("npm:sharp");
  await import("npm:playwright");
  await import("npm:pdf-lib");
  console.log("All Deno npm dependencies OK");
'

DENO_TLS_CA_STORE=system "$SKILL_ROOT/tools/deno" eval '
  const sharp = (await import("npm:sharp")).default;
  await sharp(Buffer.from("<svg></svg>")).png().toBuffer();
  console.log("sharp native binary OK");
'
```

**Windows (PowerShell):**

```powershell
$env:DENO_TLS_CA_STORE = "system"
& "$skillRoot\tools\deno.exe" eval @"
  await import("npm:pptxgenjs");
  await import("npm:sharp");
  await import("npm:playwright");
  await import("npm:pdf-lib");
  console.log("All Deno npm dependencies OK");
"@

& "$skillRoot\tools\deno.exe" eval @"
  const sharp = (await import("npm:sharp")).default;
  await sharp(Buffer.from("<svg></svg>")).png().toBuffer();
  console.log("sharp native binary OK");
"@
```

For the global case, append `--config "$SKILL_ROOT/deno.json" --node-modules-dir="$SKILL_ROOT"` to each `deno` invocation.

## Phase 4: LibreOffice

Required for: PPTX-to-PDF conversion, XLSX formula recalculation, and document validation rendering. If the user only needs text extraction, XML editing, or PDF form filling, skip this phase.

### Check

```bash
soffice --version 2>/dev/null || echo "not found"
```

If `soffice` is on PATH, symlink it into tools/ and skip the download:

**macOS / Linux:**

```bash
TOOLS_DIR="$SKILL_ROOT/tools"
mkdir -p "$TOOLS_DIR"
ln -sf "$(command -v soffice)" "$TOOLS_DIR/soffice"
```

### Install to `tools/`

The goal is to extract a portable `soffice` binary into `tools/` without requiring admin rights or system-wide installation.

**macOS — download DMG, extract app:**

```bash
TOOLS_DIR="$SKILL_ROOT/tools"
mkdir -p "$TOOLS_DIR"

ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  LO_ARCH="aarch64"
else
  LO_ARCH="x86_64"
fi

LO_VERSION="26.2.2"
DMG_URL="https://download.documentfoundation.org/libreoffice/stable/${LO_VERSION}/mac/${LO_ARCH}/LibreOffice_${LO_VERSION}_MacOS_${LO_ARCH}.dmg"
DMG_PATH="$TOOLS_DIR/LibreOffice.dmg"

echo "Downloading LibreOffice ${LO_VERSION} for macOS ${LO_ARCH}..."
curl -fSL -o "$DMG_PATH" "$DMG_URL"

hdiutil attach "$DMG_PATH" -quiet -mountpoint "$TOOLS_DIR/dmg_mount"
cp -R "$TOOLS_DIR/dmg_mount/LibreOffice.app" "$TOOLS_DIR/"
hdiutil detach "$TOOLS_DIR/dmg_mount" -quiet
rm "$DMG_PATH"

ln -sf "$TOOLS_DIR/LibreOffice.app/Contents/MacOS/soffice" "$TOOLS_DIR/soffice"
```

**Linux — download AppImage:**

```bash
TOOLS_DIR="$SKILL_ROOT/tools"
mkdir -p "$TOOLS_DIR"

ARCH=$(uname -m)
LO_VERSION="26.2.2"
APPIMAGE_URL="https://libreoffice.soluzioniopen.com/download/LibreOffice-${LO_VERSION}-standard-${ARCH}.AppImage"

echo "Downloading LibreOffice ${LO_VERSION} AppImage for ${ARCH}..."
curl -fSL -o "$TOOLS_DIR/LibreOffice.AppImage" "$APPIMAGE_URL"
chmod +x "$TOOLS_DIR/LibreOffice.AppImage"

ln -sf "$TOOLS_DIR/LibreOffice.AppImage" "$TOOLS_DIR/soffice"
```

**Linux — alternative: download .tar.gz from official site:**

```bash
TOOLS_DIR="$SKILL_ROOT/tools"
mkdir -p "$TOOLS_DIR"

ARCH=$(uname -m)
LO_VERSION="26.2.2"

if command -v dpkg &>/dev/null; then
  PKG_TYPE="deb"
elif command -v rpm &>/dev/null; then
  PKG_TYPE="rpm"
fi

TAR_URL="https://download.documentfoundation.org/libreoffice/stable/${LO_VERSION}/linux/${ARCH}/${PKG_TYPE}/LibreOffice_${LO_VERSION}_Linux_${ARCH}_${PKG_TYPE}.tar.gz"
echo "Downloading LibreOffice ${LO_VERSION} for Linux ${ARCH} (${PKG_TYPE})..."
curl -fSL -o "$TOOLS_DIR/libreoffice.tar.gz" "$TAR_URL"

cd "$TOOLS_DIR"
tar xzf libreoffice.tar.gz
cd LibreOffice_*/

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
$toolsDir = Join-Path $skillRoot "tools"
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

$loVersion = "26.2.2"
$url = "https://download.documentfoundation.org/libreoffice/portable/$loVersion/LibreOfficePortable_${loVersion}_MultilingualStandard.paf.exe"
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
"$SKILL_ROOT/tools/soffice" --version
```

## Phase 5: Write `tools/paths.json`

After all required tools are installed, write a `paths.json` to the `tools/` directory. This is the single file that other skills read to locate tools — they check it before falling back to PATH.

### Format

```json
{
  "tools_dir": "<absolute path to office-install/tools/>",
  "skill_root": "<absolute path to office-install/>",
  "uv": "<absolute path to uv binary>",
  "deno": "<absolute path to deno binary>",
  "soffice": "<absolute path to soffice binary>",
  "node_modules_dir": "<absolute path to node_modules/>",
  "global_install": false,
  "env": {
    "DENO_TLS_CA_STORE": "system"
  }
}
```

Every path must be **absolute**. Use the resolved path — no `~`, no relative paths.

If a tool was not installed (e.g. deno skipped because user only needs DOCX), set its value to `null`:

```json
{
  "tools_dir": "/abs/path/to/tools",
  "skill_root": "/abs/path/to/office-install",
  "uv": "/abs/path/to/tools/uv",
  "deno": null,
  "soffice": "/abs/path/to/tools/soffice",
  "node_modules_dir": null,
  "global_install": false,
  "env": {
    "DENO_TLS_CA_STORE": "system"
  }
}
```

### Writing the file

**macOS / Linux:**

```bash
TOOLS_DIR="$SKILL_ROOT/tools"

NODE_MODULES_DIR=""
if [ -d "./node_modules" ] && [ "$IS_GLOBAL" = false ]; then
  NODE_MODULES_DIR="$(cd ./node_modules && pwd)"
elif [ -d "$SKILL_ROOT/node_modules" ] && [ "$IS_GLOBAL" = true ]; then
  NODE_MODULES_DIR="$SKILL_ROOT/node_modules"
fi

cat > "$TOOLS_DIR/paths.json" << EOF
{
  "tools_dir": "$TOOLS_DIR",
  "skill_root": "$SKILL_ROOT",
  "uv": "$TOOLS_DIR/uv",
  "deno": "$TOOLS_DIR/deno",
  "soffice": "$TOOLS_DIR/soffice",
  "node_modules_dir": "${NODE_MODULES_DIR:-null}",
  "global_install": $IS_GLOBAL,
  "env": {
    "DENO_TLS_CA_STORE": "system"
  }
}
EOF
```

**Windows (PowerShell):**

```powershell
$toolsDir = Join-Path $skillRoot "tools"

$nmDir = $null
if (-not $isGlobal -and (Test-Path (Join-Path $PWD "node_modules"))) {
    $nmDir = Join-Path $PWD "node_modules"
} elseif ($isGlobal -and (Test-Path (Join-Path $skillRoot "node_modules"))) {
    $nmDir = Join-Path $skillRoot "node_modules"
}

$paths = @{
    tools_dir = $toolsDir
    skill_root = $skillRoot
    uv = Join-Path $toolsDir "uv.exe"
    deno = Join-Path $toolsDir "deno.exe"
    soffice = Join-Path $toolsDir "soffice.exe"
    node_modules_dir = $nmDir
    global_install = $isGlobal
    env = @{
        DENO_TLS_CA_STORE = "system"
    }
}

$paths | ConvertTo-Json -Depth 3 | Set-Content (Join-Path $toolsDir "paths.json")
```

**Always rewrite `paths.json` at the end of every run of this skill**, even if some tools were already present. This ensures the file stays in sync with what's actually installed.

## Phase 6: Verify full stack

Run the checks below for the skills the user needs. Only test what's relevant. Use the paths from `paths.json`.

### Read paths.json

**macOS / Linux:**

```bash
TOOLS_DIR="$SKILL_ROOT/tools"
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

### sharp native binary

```bash
DENO_TLS_CA_STORE=system "$DENO" eval "
  const sharp = (await import('npm:sharp')).default;
  await sharp(Buffer.from('<svg></svg>')).png().toBuffer();
  console.log('sharp native binary OK');
"
```

### pdf-lib (PDF creation/modification)

```bash
DENO_TLS_CA_STORE=system "$DENO" eval "import('npm:pdf-lib').then(m => console.log('pdf-lib OK'))"
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

## Skills install and update — from GitHub

The office-skills project lives at `https://github.com/cristoslc/office-skills`. This section handles installing the skills (SKILL.md files, scripts, schemas) from the source repo and checking for updates.

### Source vs. install layout

This repository is the **source**. Skills are authored under `public/office-*/`. Each `public/office-*/` directory contains a `SKILL.md` entrypoint and supporting files (scripts, schemas, references).

**Consumers install skills into the standard agent skills path.** The canonical install location is `.agents/skills/` — either project-local or global:

| Scope | Path | Used by |
|-------|------|---------|
| **Project-local** | `<repo-root>/.agents/skills/office-*/` | When office-skills is a dependency of another project |
| **Global** | `~/.agents/skills/office-*/` | When office-skills is used standalone across projects |

The install process takes the `public/office-*/` directories from the source repo and places them at the standard `.agents/skills/` path. The `tools/` directory, `node_modules/`, and `paths.json` live inside `office-install/` — they are generated at install time, not shipped in the repo.

### Install methods (ordered by preference)

#### 1. `npx skills` (standard agent skills CLI)

The [Vercel skills CLI](https://github.com/vercel-labs/skills) is the standard installer for the Agent Skills open format:

```bash
# Install all office-skills to .agents/skills/ (project-local)
npx skills add cristoslc/office-skills --all

# Install to global location
npx skills add cristoslc/office-skills --all -g

# Non-interactive (CI/CD)
npx skills add cristoslc/office-skills --all -g -y

# Install specific skills only
npx skills add cristoslc/office-skills --skill office-install --skill office-pptx -g
```

#### 2. Git clone (if git is available)

```bash
git clone https://github.com/cristoslc/office-skills.git /tmp/office-skills

SKILLS_DIR="$HOME/.agents/skills"
mkdir -p "$SKILLS_DIR"
for skill_dir in /tmp/office-skills/public/office-*/; do
  skill_name=$(basename "$skill_dir")
  ln -sf "$skill_dir" "$SKILLS_DIR/$skill_name"
done

echo "$(git -C /tmp/office-skills rev-parse HEAD)" > "$SKILLS_DIR/office-install/.installed-sha"
```

#### 3. Direct download (no git, no npm)

**macOS / Linux:**

```bash
SKILLS_DIR="$HOME/.agents/skills"
mkdir -p "$SKILLS_DIR"

echo "Downloading office-skills from GitHub..."
curl -fSL "https://github.com/cristoslc/office-skills/archive/refs/heads/trunk.tar.gz" -o /tmp/office-skills.tar.gz
tar xzf /tmp/office-skills.tar.gz -C /tmp/ "office-skills-trunk/public"
cp -R /tmp/office-skills-trunk/public/ "$SKILLS_DIR/"

rm -rf /tmp/office-skills.tar.gz /tmp/office-skills-trunk

REMOTE_SHA=$(curl -fsSL "https://api.github.com/repos/cristoslc/office-skills/commits/trunk" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['sha'])" 2>/dev/null || echo "unknown")
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

Copy-Item -Path "$extracted\office-*" -Destination $skillsDir -Recurse -Force

$sha = (Invoke-RestMethod -Uri "https://api.github.com/repos/cristoslc/office-skills/commits/trunk" -ErrorAction SilentlyContinue).sha
if ($sha) { $sha | Out-File (Join-Path $skillsDir "office-install\.installed-sha") -Encoding utf8 }

Remove-Item $zip -Force
Remove-Item (Join-Path $env:TEMP "office-skills-trunk") -Recurse -Force

Write-Host "Skills installed to $skillsDir"
```

### Check for updates

```bash
LOCAL_SHA_FILE="$HOME/.agents/skills/office-install/.installed-sha"

if [ -f "$LOCAL_SHA_FILE" ]; then
  LOCAL_SHA=$(cat "$LOCAL_SHA_FILE")
  REMOTE_SHA=$(curl -fsSL "https://api.github.com/repos/cristoslc/office-skills/commits/trunk" | python3 -c "import json,sys; print(json.load(sys.stdin)['sha'])" 2>/dev/null)
  if [ "$REMOTE_SHA" = "$LOCAL_SHA" ]; then
    echo "Skills are up to date ($REMOTE_SHA)"
  else
    echo "Update available: local=$LOCAL_SHA remote=$REMOTE_SHA"
  fi
else
  echo "No local version recorded. Run the install to get skills."
fi
```

### Apply updates

Re-run the same install method used originally. Tools, `node_modules/`, and `paths.json` are preserved — they live inside `office-install/` and are not overwritten by the skill download.

**Using `npx skills`:**

```bash
npx skills add cristoslc/office-skills --all -g -y
```

**Using git:**

```bash
git -C /tmp/office-skills pull --ff-only
# Re-symlink if needed
```

**Using direct download:** repeat the "Direct download" steps above.

After updating the skill files, re-run this skill (Phases 0–6) to regenerate `paths.json` and install any newly-added npm dependencies.

### GitHub API rate limits

Unauthenticated GitHub API requests are rate-limited to 60/hour. If you hit the limit:
- Use the archive URL directly (no API call): `https://github.com/cristoslc/office-skills/archive/refs/heads/trunk.tar.gz`
- Set `GITHUB_TOKEN` in the environment for 5000/hour rate limit

### Offline / air-gapped environments

If the machine has no internet access:
1. Download the tarball on another machine: `curl -fSL -o office-skills.tar.gz https://github.com/cristoslc/office-skills/archive/refs/heads/trunk.tar.gz`
2. Transfer it via USB, shared drive, etc.
3. Extract manually: `tar xzf office-skills.tar.gz && cp -R office-skills-trunk/public/ ~/.agents/skills/`

## Tool discovery — how other skills find tools

Other skills (pptx, docx, pdf, xlsx) locate tools using this search order:

1. **Read `paths.json`** from `{skill_root}/tools/paths.json`
2. If a tool's value is a non-null string, use that path
3. If a tool's value is `null` or the key is missing, fall back to PATH (`command -v <tool>`)
4. Set environment variables from the `env` object (e.g. `DENO_TLS_CA_STORE=system`)
5. If `global_install` is `true`, use the `officedeno` wrapper (in the working directory) instead of bare `deno`

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

### Resolving the deno command

For skills that need to run deno scripts, check `global_install` in `paths.json`:

```bash
TOOLS_DIR="$(office_tool tools_dir)"
GLOBAL=$(python3 -c "import json; d=json.load(open('$TOOLS_DIR/paths.json')); print(d.get('global_install', False))" 2>/dev/null)

if [ "$GLOBAL" = "True" ]; then
  DENO_CMD="./officedeno"
else
  DENO_CMD="$(office_tool deno) || deno"
fi

# Usage
DENO_TLS_CA_STORE=system $DENO_CMD run --allow-all script.js
```

### PowerShell helper — resolve a tool path

```powershell
function Get-OfficeTool {
    param([string]$ToolName)
    $pathsFile = $null
    foreach ($dir in @(
        (Join-Path $PWD ".agents\skills\office-install\tools"),
        (Join-Path $env:USERPROFILE ".agents\skills\office-install\tools")
    )) {
        $candidate = Join-Path $dir "paths.json"
        if (Test-Path $candidate) { $pathsFile = $candidate; break }
    }
    if ($pathsFile) {
        $paths = Get-Content $pathsFile -Raw | ConvertFrom-Json
        $result = $paths.PSObject.Properties | Where-Object { $_.Name -eq $ToolName } | Select-Object -ExpandProperty Value
        if ($result -and $result -ne "null") { return $result }
    }
    Get-Command $ToolName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}
```

## Troubleshooting

### Deno certificate errors on corporate networks

Set `DENO_TLS_CA_STORE=system` before all deno invocations:

```bash
export DENO_TLS_CA_STORE=system
```

If this doesn't work, your corporate cert may not be in the system store. Export it as PEM and use:

```bash
export DENO_CERT=/path/to/corporate-ca.pem
# or per-invocation:
deno --cert /path/to/corporate-ca.pem ...
```

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

### sharp native binary errors

If `sharp` fails at runtime with "Could not load the 'sharp' module" or a platform binary error:

1. Confirm the platform/arch matches:

```bash
DENO_TLS_CA_STORE=system "$DENO" eval "console.log(Deno.build.os, Deno.build.arch)"
```

2. Delete `node_modules/` and reinstall with explicit platform:

```bash
rm -rf node_modules/
npm_config_platform=win32 npm_config_arch=x64 DENO_TLS_CA_STORE=system "$DENO" install
```

3. For offline/airgapped systems, download the platform-specific sharp binary from [sharp releases](https://github.com/lovell/sharp/releases) and extract into `node_modules/@img/sharp-<platform>-<arch>/`

### `deno install` integrity check failure

If `deno install` fails with a hash/integrity error, the `deno.lock` may be stale (e.g., after a skill update added new packages). Re-run from the skill root:

```bash
DENO_TLS_CA_STORE=system "$DENO" install --config "$SKILL_ROOT/deno.json"
```

This regenerates `deno.lock` with updated hashes. The developer should then copy the updated lock to `resources/deno.lock` and commit both `resources/deno.json` and `resources/deno.lock` together.

### LibreOffice download is too large

The `soffice` binary alone is ~350MB+. If the download is impractical:
- On macOS: `brew install --cask libreoffice` (if Homebrew is available)
- On Linux: `sudo apt-get install -y libreoffice-core --no-install-recommends` (Debian/Ubuntu, smaller footprint)
- Then symlink the system `soffice` into `tools/`