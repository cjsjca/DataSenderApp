# DataSenderApp

A web application for real-time text streaming to Claude CLI.

## Quick Start

```bash
# 1. Start the server
./start_server.sh

# 2. Open browser
http://localhost:8080/realtime_chat.html

# 3. Start typing
```

## What It Does

- Type text in browser
- Text streams to Claude CLI 
- Claude processes and responds
- See responses in browser with real-time status

## Files

- `realtime_chat.html` - Frontend web interface with real-time status indicators
- `simple_server.py` - Backend server (Python standard library) that bridges web app to Claude CLI  
- `auto_commit.sh` - Git auto-versioning (commits every 5s, pushes every 30min)
- `start_server.sh` - Server launcher script

## iPhone Access

```bash
# Find your Mac's IP
ifconfig | grep 'inet ' | grep -v 127.0.0.1

# Access from iPhone (same WiFi)
http://YOUR_MAC_IP:8080/realtime_chat.html
```

## Auto-Commit

Already running. Check status:
```bash
ps aux | grep fswatch | grep -v grep
tail -f /tmp/datasenderapp-autocommit.log
```

## Technical Details

- WebSocket/SSE for real-time communication
- Claude CLI runs as subprocess
- No authentication (bootstrap phase)

That's it. Simple text streaming.