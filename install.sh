#!/bin/bash

set -e


echo "🏝️  Islands Dark Theme Installer for Positron (macOS/Linux)"
echo "============================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect target: positron or vscode
TARGET=""
if [ "$1" = "--vscode" ]; then
    TARGET="vscode"
elif [ "$1" = "--positron" ]; then
    TARGET="positron"
fi

# Auto-detect if not specified
if [ -z "$TARGET" ]; then
    if command -v positron &> /dev/null; then
        TARGET="positron"
    elif command -v code &> /dev/null; then
        TARGET="vscode"
    else
        echo -e "${RED}Neither positron nor code CLI found!${NC}"
        echo "Usage: $0 [--positron|--vscode]"
        exit 1
    fi
fi

if [ "$TARGET" = "positron" ]; then
    CLI_CMD="positron"
    echo -e "${GREEN}Target: Positron${NC}"
else
    CLI_CMD="code"
    echo -e "${GREEN}Target: VS Code${NC}"
fi

# Check if CLI is available
if ! command -v "$CLI_CMD" &> /dev/null; then
    echo -e "${RED}Error: $CLI_CMD CLI not found!${NC}"
    if [ "$TARGET" = "positron" ]; then
        echo "Please install Positron and make sure 'positron' command is in your PATH."
    else
        echo "Please install VS Code and make sure 'code' command is in your PATH."
    fi
    exit 1
fi

echo -e "${GREEN}✓ $CLI_CMD CLI found${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set paths based on target
if [ "$TARGET" = "positron" ]; then
    EXT_DIR="$HOME/.positron/extensions/bwya77.islands-dark-1.0.0"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        SETTINGS_DIR="$HOME/Library/Application Support/Positron/User"
    else
        SETTINGS_DIR="$HOME/.config/Positron/User"
    fi
else
    EXT_DIR="$HOME/.vscode/extensions/bwya77.islands-dark-1.0.0"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
    else
        SETTINGS_DIR="$HOME/.config/Code/User"
    fi
fi

echo ""
echo "📦 Step 1: Installing Islands Dark theme extension..."

rm -rf "$EXT_DIR"
mkdir -p "$EXT_DIR"
cp "$SCRIPT_DIR/package.json" "$EXT_DIR/"
cp -r "$SCRIPT_DIR/themes" "$EXT_DIR/"

if [ -d "$EXT_DIR/themes" ]; then
    echo -e "${GREEN}✓ Theme extension installed to $EXT_DIR${NC}"
else
    echo -e "${RED}❌ Failed to install theme extension${NC}"
    exit 1
fi

# Remove extensions.json so it rebuilds cleanly
if [ "$TARGET" = "positron" ]; then
    EXT_JSON="$HOME/.positron/extensions/extensions.json"
else
    EXT_JSON="$HOME/.vscode/extensions/extensions.json"
fi
if [ -f "$EXT_JSON" ]; then
    rm -f "$EXT_JSON"
    echo -e "${GREEN}✓ Cleared extensions.json (will rebuild on next launch)${NC}"
fi

echo ""
echo "🔧 Step 2: Installing Custom UI Style extension..."
if $CLI_CMD --install-extension subframe7536.custom-ui-style --force; then
    echo -e "${GREEN}✓ Custom UI Style extension installed${NC}"
else
    echo -e "${YELLOW}⚠️  Could not install Custom UI Style extension automatically${NC}"
    echo "   Please install it manually from the Extensions marketplace"
fi

echo ""
echo "🔤 Step 3: Installing Bear Sans UI fonts..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_DIR="$HOME/Library/Fonts"
    echo "   Installing fonts to: $FONT_DIR"
    cp "$SCRIPT_DIR/fonts/"*.otf "$FONT_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✓ Fonts installed to Font Book${NC}"
    echo "   Note: You may need to restart applications to use the new fonts"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    echo "   Installing fonts to: $FONT_DIR"
    cp "$SCRIPT_DIR/fonts/"*.otf "$FONT_DIR/" 2>/dev/null || true
    fc-cache -f 2>/dev/null || true
    echo -e "${GREEN}✓ Fonts installed${NC}"
else
    echo -e "${YELLOW}⚠️  Could not detect OS type for automatic font installation${NC}"
    echo "   Please manually install the fonts from the 'fonts/' folder"
fi

echo ""
echo "⚙️  Step 4: Applying settings..."
mkdir -p "$SETTINGS_DIR"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

# Backup existing settings if they exist
if [ -f "$SETTINGS_FILE" ]; then
    BACKUP_FILE="$SETTINGS_FILE.pre-islands-dark"
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo -e "${YELLOW}⚠️  Existing settings.json backed up to:${NC}"
    echo "   $BACKUP_FILE"
    echo "   You can restore your old settings from this file if needed."
fi

# Copy Islands Dark settings
cp "$SCRIPT_DIR/settings.json" "$SETTINGS_FILE"
echo -e "${GREEN}✓ Islands Dark settings applied${NC}"

echo ""
echo "🚀 Step 5: Enabling Custom UI Style..."
echo "   $TARGET will reload after applying changes..."

# Create a flag file to indicate first run
FIRST_RUN_FILE="$SCRIPT_DIR/.islands_dark_first_run_${TARGET}"
if [ ! -f "$FIRST_RUN_FILE" ]; then
    touch "$FIRST_RUN_FILE"
    echo ""
    echo -e "${YELLOW}📝 Important Notes:${NC}"
    echo "   • IBM Plex Mono and FiraCode Nerd Font Mono need to be installed separately"
    echo "   • After reload, you may see a 'corrupt installation' warning"
    echo "   • This is expected - click the gear icon and select 'Don't Show Again'"
    echo ""
    if [ -t 0 ]; then
        read -p "Press Enter to continue and reload..."
    fi
fi

# Apply custom UI style
echo "   Applying CSS customizations..."

echo -e "${GREEN}✓ Setup complete!${NC}"
echo ""
echo "🎉 Islands Dark theme has been installed for $TARGET!"
echo ""

# Use AppleScript on macOS to show a notification
if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e 'display notification "Islands Dark theme installed successfully!" with title "🏝️ Islands Dark"' 2>/dev/null || true
fi

echo "   Reloading $TARGET..."
$CLI_CMD --reload-window 2>/dev/null || $CLI_CMD . 2>/dev/null || true

echo ""
echo -e "${GREEN}Done! 🏝️${NC}"
