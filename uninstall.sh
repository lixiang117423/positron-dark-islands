#!/bin/bash

set -e

echo "🏝️  Islands Dark Theme Uninstaller for macOS/Linux"
echo "==================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect target
TARGET=""
if [ "$1" = "--vscode" ]; then
    TARGET="vscode"
elif [ "$1" = "--positron" ]; then
    TARGET="positron"
fi

if [ -z "$TARGET" ]; then
    if [ -d "$HOME/.positron/extensions/bwya77.islands-dark-1.0.0" ]; then
        TARGET="positron"
    elif [ -d "$HOME/.vscode/extensions/bwya77.islands-dark-1.0.0" ]; then
        TARGET="vscode"
    else
        TARGET="vscode"
    fi
fi

echo -e "${GREEN}Target: $TARGET${NC}"

# Set paths based on target
if [ "$TARGET" = "positron" ]; then
    EXT_BASE="$HOME/.positron/extensions"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        SETTINGS_DIR="$HOME/Library/Application Support/Positron/User"
    else
        SETTINGS_DIR="$HOME/.config/Positron/User"
    fi
else
    EXT_BASE="$HOME/.vscode/extensions"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
    else
        SETTINGS_DIR="$HOME/.config/Code/User"
    fi
fi

# Step 1: Restore old settings
echo ""
echo "⚙️  Step 1: Restoring $TARGET settings..."
SETTINGS_FILE="$SETTINGS_DIR/settings.json"
BACKUP_FILE="$SETTINGS_FILE.pre-islands-dark"

if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" "$SETTINGS_FILE"
    echo -e "${GREEN}✓ Settings restored from backup${NC}"
    echo "   Backup file: $BACKUP_FILE"
else
    echo -e "${YELLOW}⚠️  No backup found at $BACKUP_FILE${NC}"
    echo "   You may need to manually update your $TARGET settings."
fi

# Step 2: Disable Custom UI Style
echo ""
echo "🔧 Step 2: Disabling Custom UI Style..."
echo -e "${YELLOW}   Please disable Custom UI Style manually:${NC}"
echo "   1. Open Command Palette (Cmd+Shift+P / Ctrl+Shift+P)"
echo "   2. Run 'Custom UI Style: Disable'"
echo "   3. $TARGET will reload"

# Step 3: Remove theme extension
echo ""
echo "🗑️  Step 3: Removing Islands Dark theme extension..."
EXT_DIR="$EXT_BASE/bwya77.islands-dark-1.0.0"
if [ -d "$EXT_DIR" ] || [ -L "$EXT_DIR" ]; then
    rm -rf "$EXT_DIR"
    echo -e "${GREEN}✓ Theme extension removed${NC}"
else
    echo -e "${YELLOW}⚠️  Extension directory not found (may already be removed)${NC}"
fi

# Step 4: Remove extension from extensions.json
echo ""
echo "📋 Step 4: Unregistering extension..."
if command -v node &> /dev/null; then
    EXT_JSON_PATH="$EXT_BASE/extensions.json"
    node -e "
const fs = require('fs');
const extJsonPath = '$EXT_JSON_PATH';
if (fs.existsSync(extJsonPath)) {
    try {
        let extensions = JSON.parse(fs.readFileSync(extJsonPath, 'utf8'));
        const before = extensions.length;
        extensions = extensions.filter(e =>
            e.identifier?.id !== 'bwya77.islands-dark' &&
            e.identifier?.id !== 'your-publisher-name.islands-dark'
        );
        if (extensions.length < before) {
            fs.writeFileSync(extJsonPath, JSON.stringify(extensions));
            console.log('Extension unregistered');
        } else {
            console.log('Extension was not registered');
        }
    } catch (e) {
        console.log('Could not update extensions.json');
    }
}"
    echo -e "${GREEN}✓ Extension unregistered${NC}"
fi

# Step 5: Change theme
echo ""
echo "🎨 Step 5: Change your color theme..."
echo "   1. Open Command Palette (Cmd+Shift+P / Ctrl+Shift+P)"
echo "   2. Search for 'Preferences: Color Theme'"
echo "   3. Select your preferred theme"

echo ""
echo -e "${GREEN}✓ Islands Dark has been uninstalled from $TARGET!${NC}"
echo ""
echo "   Reload $TARGET to complete the process."
echo ""
