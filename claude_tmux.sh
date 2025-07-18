#!/bin/bash
# Claude CLI tmux session manager

SESSION_NAME="claude-cli"

# Function to start Claude CLI in tmux
start_claude_session() {
    # Check if session already exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "Claude CLI session already running!"
        echo "To attach: tmux attach -t $SESSION_NAME"
    else
        echo "Starting new Claude CLI session..."
        # Create new detached tmux session and run claude
        tmux new-session -d -s "$SESSION_NAME" -c "$PWD" "claude"
        echo "Claude CLI session started!"
        echo "To attach: tmux attach -t $SESSION_NAME"
    fi
}

# Function to attach to existing session
attach_claude_session() {
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux attach -t "$SESSION_NAME"
    else
        echo "No Claude CLI session found. Starting new one..."
        start_claude_session
        tmux attach -t "$SESSION_NAME"
    fi
}

# Main logic
case "${1:-attach}" in
    start)
        start_claude_session
        ;;
    attach|*)
        attach_claude_session
        ;;
esac