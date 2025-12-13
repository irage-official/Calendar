#!/bin/bash

# Git Tag Sync Script
# این اسکریپت برای همگام‌سازی tag‌های local و remote استفاده می‌شود

echo "🔄 Syncing Git tags..."

# حذف tag‌های local که conflict دارند
echo "📋 Checking for conflicting tags..."
LOCAL_TAGS=$(git tag -l)
REMOTE_TAGS=$(git ls-remote --tags origin | sed 's/.*refs\/tags\///' | sed 's/\^{}//')

for tag in $LOCAL_TAGS; do
    if echo "$REMOTE_TAGS" | grep -q "^$tag$"; then
        LOCAL_COMMIT=$(git rev-parse $tag)
        REMOTE_COMMIT=$(git ls-remote --tags origin | grep "refs/tags/$tag$" | cut -f1)
        
        if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
            echo "⚠️  Conflict detected for tag: $tag"
            echo "   Local:  $LOCAL_COMMIT"
            echo "   Remote: $REMOTE_COMMIT"
            echo "🗑️  Deleting local tag: $tag"
            git tag -d $tag
        fi
    fi
done

# دریافت tag‌های remote
echo "⬇️  Fetching tags from remote..."
git fetch --tags --force

echo "✅ Tag sync completed!"
echo ""
echo "Current tags:"
git tag -l | tail -5

