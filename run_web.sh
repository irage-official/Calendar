#!/bin/bash

# Irage (Iranian Heritage) Calendar - Flutter Web Development Script
# This script ensures consistent port usage and hot reload functionality

echo "🚀 Starting Irage (Iranian Heritage) Calendar on Web..."
echo "📍 Port: 8080"
echo "🌐 URL: http://localhost:8080"
echo "🔄 Hot Reload: Enabled"
echo ""

# Kill any existing Flutter processes on port 8080
echo "🧹 Cleaning up existing processes..."
lsof -ti:8080 | xargs kill -9 2>/dev/null || true

# Start Flutter web with fixed port and hot reload
echo "🎯 Launching Flutter Web..."
flutter run -d chrome \
  --web-port=8080 \
  --web-hostname=localhost \
  --web-renderer=html \
  --hot \
  --verbose

echo ""
echo "✅ Development server started!"
echo "🔗 Open your browser to: http://localhost:8080"
echo "💡 Changes will automatically reload - no need to refresh manually!"
echo "🛑 Press Ctrl+C to stop the server"
