#!/bin/bash
# Lightweight auto-commit system using fswatch
# Captures all changes instantly without slowing down work

# Prevent multiple instances
LOCKFILE="/tmp/datasenderapp-autocommit.lock"
if [ -f "$LOCKFILE" ]; then
    PID=$(cat "$LOCKFILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "Auto-commit already running (PID: $PID)"
        exit 0
    else
        echo "Removing stale lock file"
        rm "$LOCKFILE"
    fi
fi
echo $$ > "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo "fswatch not found. Install with: brew install fswatch"
    exit 1
fi

# Configuration
PROJECT_DIR="/Users/loaner/Projects/DataSenderApp"
COMMIT_DELAY=5  # Wait 5 seconds after last change before committing

cd "$PROJECT_DIR"

echo "Starting auto-commit watcher..."
echo "- Commits after ${COMMIT_DELAY}s of inactivity"
echo "- Push to GitHub every 30 minutes"
echo "- Press Ctrl+C to stop"

# Function to commit changes
commit_changes() {
    if [[ $(git status --porcelain) ]]; then
        git add .
        git commit -m "Auto-save $(date +"%Y-%m-%d %H:%M:%S")" > /dev/null 2>&1
        echo "[$(date +"%H:%M:%S")] Changes committed"
    fi
}

# Background push every 30 minutes
(
    while true; do
        sleep 1800  # 30 minutes
        git push origin main > /dev/null 2>&1 && echo "[$(date +"%H:%M:%S")] Pushed to GitHub"
    done
) &
PUSH_PID=$!

# Watch for changes with debouncing
TIMER_PID=""
fswatch -o . --exclude .git | while read; do
    # Cancel previous timer
    [[ -n $TIMER_PID ]] && kill $TIMER_PID 2>/dev/null
    
    # Start new timer
    (
        sleep $COMMIT_DELAY
        commit_changes
    ) &
    TIMER_PID=$!
done

# Cleanup on exit
trap "kill $PUSH_PID 2>/dev/null" EXIT