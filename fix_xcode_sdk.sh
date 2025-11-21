#!/bin/bash

# Fix Xcode SDK path issue
# This script switches xcode-select to use the full Xcode installation

echo "Switching xcode-select to full Xcode installation..."
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

if [ $? -eq 0 ]; then
    echo "✓ Successfully switched to Xcode"
    
    echo "Verifying Xcode installation..."
    xcodebuild -version
    
    echo ""
    echo "Checking for iOS Simulator SDK..."
    xcrun --show-sdk-path --sdk iphonesimulator
    
    echo ""
    echo "Accepting Xcode license (if needed)..."
    sudo xcodebuild -license accept 2>/dev/null || echo "License already accepted or requires manual acceptance"
    
    echo ""
    echo "✓ Setup complete! You can now run Flutter commands."
else
    echo "✗ Failed to switch xcode-select. Please run manually:"
    echo "  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
fi

