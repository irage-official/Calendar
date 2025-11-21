#!/bin/bash
# Sync events.json from data/ to assets/data/ and update metadata

echo "🔄 Syncing events.json..."

# Copy from data/ to assets/data/
cp data/events.json assets/data/events.json

# Count events
TOTAL_EVENTS=$(grep -c '"id":' data/events.json)

# Get current version and increment
CURRENT_VERSION=$(grep -o '"version": "[^"]*"' data/events-metadata.json | cut -d'"' -f4)
MAJOR=$(echo $CURRENT_VERSION | cut -d'.' -f1)
MINOR=$(echo $CURRENT_VERSION | cut -d'.' -f2)
PATCH=$(echo $CURRENT_VERSION | cut -d'.' -f3)
NEW_PATCH=$((PATCH + 1))
NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH"

# Update metadata
cat > data/events-metadata.json << EOF
{
  "version": "$NEW_VERSION",
  "updated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_events": $TOTAL_EVENTS
}
EOF

echo "✅ Synced successfully!"
echo "   📁 data/events.json → assets/data/events.json"
echo "   📊 Version: $NEW_VERSION"
echo "   📈 Total events: $TOTAL_EVENTS"

