# DataSenderApp

A web application for real-time text streaming to Claude CLI.

## What This Is

- Frontend web interface for text input (realtime_chat.html)
- Backend server that connects web app to Claude CLI (chat_server.py)
- Auto-commit system for versioning (auto_commit.sh)

## Auto-Commit System

Currently running! Commits after 5 seconds of inactivity, pushes every 30 minutes.

Check status:
```bash
ps aux | grep fswatch | grep -v grep
tail -f /tmp/datasenderapp-autocommit.log
```

## Quick Start

1. Make sure auto-commit is running (see above)
2. Run `./start_server.sh`
3. Open browser to http://localhost:8080/realtime_chat.html
4. Start typing

## Technical Notes

- Uses WebSocket/SSE for real-time communication
- Claude CLI runs as subprocess
- All text saved to Supabase for persistence
- Works on iPhone via local network