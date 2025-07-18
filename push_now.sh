#!/bin/bash
# Manual push to GitHub

cd /Users/loaner/Projects/DataSenderApp

# Commit any pending changes first
if [[ $(git status --porcelain) ]]; then
    git add .
    git commit -m "Manual save before push $(date +"%Y-%m-%d %H:%M:%S")"
    echo "Committed pending changes"
fi

# Push to GitHub
echo "Pushing to GitHub..."
git push origin main && echo "✓ Successfully pushed to GitHub" || echo "✗ Push failed"

# Show status
echo ""
git log --oneline -3