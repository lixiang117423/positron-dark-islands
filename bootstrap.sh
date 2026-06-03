#!/bin/bash

set -e

# Islands Dark Theme Bootstrap Installer (Positron / VS Code)
# One-liner: curl -fsSL <repo-url>/bootstrap.sh | bash
# Use: bash bootstrap.sh --positron  or  bash bootstrap.sh --vscode

echo "🏝️  Islands Dark Theme Bootstrap Installer"
echo "=========================================="
echo ""

REPO_URL="https://github.com/lixiang117423/positron-dark-islands.git"
INSTALL_DIR="$HOME/.islands-dark-temp"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
else
    OS="Linux"
fi

echo "📥 Step 1: Downloading Islands Dark..."
echo "   Repository: $REPO_URL"

# Remove old temp directory if exists
rm -rf "$INSTALL_DIR"

# Clone repository
BRANCH="main"
if ! git clone "$REPO_URL" "$INSTALL_DIR" --quiet --branch "$BRANCH"; then
    echo "❌ Failed to download Islands Dark"
    exit 1
fi

echo "✓ Downloaded successfully!"
echo ""

echo "🚀 Step 2: Running installer..."
echo ""

# Pass target flag to installer
INSTALL_FLAGS=""
if [ "$1" = "--positron" ]; then
    INSTALL_FLAGS="--positron"
elif [ "$1" = "--vscode" ]; then
    INSTALL_FLAGS="--vscode"
fi

# Run appropriate installer
if [[ "$OS" == "macOS" ]] || [[ "$OS" == "Linux" ]]; then
    cd "$INSTALL_DIR"
    bash install.sh $INSTALL_FLAGS
else
    echo "⚠️  Automatic installation not supported for this OS"
    echo "   Please manually run: cd $INSTALL_DIR && ./install.sh $INSTALL_FLAGS"
    exit 1
fi

# Cleanup (optional - keeps the temp directory)
echo ""
echo "🧹 Step 3: Cleaning up..."
read -p "   Remove temporary files? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$INSTALL_DIR"
    echo "✓ Temporary files removed"
else
    echo "   Files kept at: $INSTALL_DIR"
fi

echo ""
echo -e "🎉 Done! Enjoy your Islands Dark theme!"
