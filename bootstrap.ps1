# Islands Dark Theme Bootstrap Installer for Windows (Positron / VS Code)
# One-liner: irm <repo-url>/bootstrap.ps1 | iex
# Use: .\bootstrap.ps1 -Target positron  or  .\bootstrap.ps1 -Target vscode

param(
    [string]$Target = ""
)

$ErrorActionPreference = "Stop"

echo "🏝️  Islands Dark Theme Bootstrap Installer"
echo "=========================================="
echo ""

$RepoUrl = "https://github.com/lixiang117423/positron-dark-islands.git"
$Branch = "main"
$InstallDir = "$env:TEMP\islands-dark-temp"

echo "📥 Step 1: Downloading Islands Dark..."
echo "   Repository: $RepoUrl"

# Remove old temp directory if exists
if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir
}

# Clone repository
try {
    git clone $RepoUrl $InstallDir --quiet --branch $Branch
} catch {
    echo "❌ Failed to download Islands Dark"
    echo "   Make sure Git is installed: https://git-scm.com/download/win"
    exit 1
}

echo "✓ Downloaded successfully"
echo ""

echo "🚀 Step 2: Running installer..."
echo ""

# Run installer with target flag
$installArgs = @{}
if ($Target -eq "positron" -or $Target -eq "vscode") {
    $installArgs["Target"] = $Target
}

# Run installer
cd $InstallDir
try {
    .\install.ps1 @installArgs
} catch {
    echo "❌ Installation failed"
    echo $_.Exception.Message
    exit 1
}

# Cleanup
echo ""
echo "🧹 Step 3: Cleaning up..."
$remove = Read-Host "   Remove temporary files? (y/n)"
if ($remove -eq 'y' -or $remove -eq 'Y') {
    Remove-Item -Recurse -Force $InstallDir
    echo "✓ Temporary files removed"
} else {
    echo "   Files kept at: $InstallDir"
}

echo ""
echo "🎉 Done! Enjoy your Islands Dark theme!"
