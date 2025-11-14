#!/bin/bash
# Script to remove adaptive icon after flutter_launcher_icons generation
# This ensures we use regular full-size icons instead of adaptive icons with safe zone

ADAPTIVE_ICON_PATH="android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml"

if [ -f "$ADAPTIVE_ICON_PATH" ]; then
    echo "Removing adaptive icon to use full-size regular icons..."
    rm -f "$ADAPTIVE_ICON_PATH"
    echo "✓ Adaptive icon removed. Regular icons will be used (logo fills entire icon space)."
else
    echo "Adaptive icon not found (already removed or not generated)."
fi

