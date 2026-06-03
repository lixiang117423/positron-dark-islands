# Islands Dark Theme Installer for Windows (Positron / VS Code)

param(
    [string]$Target = ""
)

$ErrorActionPreference = "Stop"

Write-Host "Islands Dark Theme Installer for Windows" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Detect target
if ($Target -eq "vscode") {
    $targetName = "VS Code"
} elseif ($Target -eq "positron") {
    $targetName = "Positron"
} else
{
    # Auto-detect
    $positronPath = Get-Command "positron" -ErrorAction SilentlyContinue
    $codePath = Get-Command "code" -ErrorAction SilentlyContinue
    if ($positronPath) {
        $Target = "positron"
        $targetName = "Positron"
    } elseif ($codePath) {
        $Target = "vscode"
        $targetName = "VS Code"
    } else
    {
        # Try to find in common locations
        $possiblePositronPaths = @(
            "$env:LOCALAPPDATA\Programs\Positron\Positron.exe",
            "$env:ProgramFiles\Positron\Positron.exe"
        )
        $possibleCodePaths = @(
            "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
            "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd",
            "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.cmd"
        )

        foreach ($path in $possiblePositronPaths) {
            if (Test-Path $path) {
                $Target = "positron"
                $targetName = "Positron"
                break
            }
        }
        if (-not $Target) {
            foreach ($path in $possibleCodePaths) {
                if (Test-Path $path) {
                    $env:Path += ";$(Split-Path $path)"
                    $Target = "vscode"
                    $targetName = "VS Code"
                    break
                }
            }
        }

        if (-not $Target) {
            Write-Host "Error: Neither Positron nor VS Code found!" -ForegroundColor Red
            Write-Host "Usage: .\install.ps1 -Target positron|vscode"
            exit 1
        }
    }
}

Write-Host "Target: $targetName" -ForegroundColor Green

# Set CLI command
if ($Target -eq "positron") {
    $cliCmd = "positron"
    $extDir = "$env:USERPROFILE\.positron\extensions\bwya77.islands-dark-1.0.0"
    $extJsonPath = "$env:USERPROFILE\.positron\extensions\extensions.json"
    $settingsDir = "$env:APPDATA\Positron\User"
    $processName = "Positron"
} else {
    $cliCmd = "code"
    $extDir = "$env:USERPROFILE\.vscode\extensions\bwya77.islands-dark-1.0.0"
    $extJsonPath = "$env:USERPROFILE\.vscode\extensions\extensions.json"
    $settingsDir = "$env:APPDATA\Code\User"
    $processName = "Code"
}

# Check CLI
$cliResolved = Get-Command $cliCmd -ErrorAction SilentlyContinue
if (-not $cliResolved) {
    Write-Host "Warning: $cliCmd CLI not found in PATH, continuing anyway..." -ForegroundColor Yellow
}

# Get the directory where this script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "Step 1: Installing Islands Dark theme extension..."

if (Test-Path $extDir) {
    Remove-Item -Recurse -Force $extDir
}
New-Item -ItemType Directory -Path $extDir -Force | Out-Null
Copy-Item "$scriptDir\package.json" "$extDir\" -Force
Copy-Item "$scriptDir\themes" "$extDir\themes" -Recurse -Force

if (Test-Path "$extDir\themes") {
    Write-Host "Theme extension installed to $extDir" -ForegroundColor Green
} else {
    Write-Host "Failed to install theme extension" -ForegroundColor Red
    exit 1
}

# Remove extensions.json so it rebuilds cleanly on next launch
if (Test-Path $extJsonPath) {
    Remove-Item $extJsonPath -Force
    Write-Host "Cleared extensions.json (will rebuild on next launch)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 2: Installing Custom UI Style extension..."
try {
    $output = & $cliCmd --install-extension subframe7536.custom-ui-style --force 2>&1
    Write-Host "Custom UI Style extension installed" -ForegroundColor Green
} catch {
    Write-Host "Could not install Custom UI Style extension automatically" -ForegroundColor Yellow
    Write-Host "   Please install it manually from the Extensions marketplace"
}

Write-Host ""
Write-Host "Step 3: Installing Bear Sans UI fonts..."
$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

if (-not (Test-Path $fontDir)) {
    New-Item -ItemType Directory -Path $fontDir -Force | Out-Null
}

try {
    $fonts = Get-ChildItem "$scriptDir\fonts\*.otf"
    foreach ($font in $fonts) {
        try {
            Copy-Item $font.FullName $fontDir -Force -ErrorAction SilentlyContinue
        } catch {
            # Silently continue if copy fails
        }
    }

    Write-Host "Fonts installed" -ForegroundColor Green
    Write-Host "   Note: You may need to restart applications to use the new fonts" -ForegroundColor DarkGray
} catch {
    Write-Host "Could not install fonts automatically" -ForegroundColor Yellow
    Write-Host "   Please manually install the fonts from the 'fonts/' folder"
    Write-Host "   Select all .otf files and right-click > Install"
}

Write-Host ""
Write-Host "Step 4: Applying $targetName settings..."
if (-not (Test-Path $settingsDir)) {
    New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
}

$settingsFile = Join-Path $settingsDir "settings.json"

# Backup existing settings if they exist
if (Test-Path $settingsFile) {
    $backupFile = "$settingsFile.pre-islands-dark"
    Copy-Item $settingsFile $backupFile -Force
    Write-Host "Existing settings.json backed up to:" -ForegroundColor Yellow
    Write-Host "   $backupFile"
    Write-Host "   You can restore your old settings from this file if needed."
}

# Copy Islands Dark settings
Copy-Item "$scriptDir\settings.json" $settingsFile -Force
Write-Host "Islands Dark settings applied" -ForegroundColor Green

Write-Host ""
Write-Host "Step 5: Enabling Custom UI Style..."

# Check if this is the first run
$firstRunFile = Join-Path $scriptDir ".islands_dark_first_run_$Target"
if (-not (Test-Path $firstRunFile)) {
    New-Item -ItemType File -Path $firstRunFile | Out-Null
    Write-Host ""
    Write-Host "Important Notes:" -ForegroundColor Yellow
    Write-Host "   - IBM Plex Mono and FiraCode Nerd Font Mono need to be installed separately"
    Write-Host "   - After $targetName reloads, you may see a 'corrupt installation' warning"
    Write-Host "   - This is expected - click the gear icon and select 'Don't Show Again'"
    Write-Host ""
    Read-Host "Press Enter to continue and reload $targetName"
}

Write-Host "   Applying CSS customizations..."

Write-Host ""
Write-Host "Islands Dark theme has been installed!" -ForegroundColor Green
Write-Host ""

# Quit and relaunch so Custom UI Style fully initializes and patches CSS
Write-Host "   Closing $targetName..." -ForegroundColor Cyan
Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

Write-Host "   Relaunching $targetName..." -ForegroundColor Cyan
Start-Process $cliCmd -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
Write-Host ""
Write-Host "If the CSS customizations are not applied, open the Command Palette" -ForegroundColor Yellow
Write-Host "(Ctrl+Shift+P) and run: Custom UI Style: Reload" -ForegroundColor Yellow

Start-Sleep -Seconds 3
