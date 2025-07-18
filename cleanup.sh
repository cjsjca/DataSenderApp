#!/bin/bash

# cleanup.sh - Check for stray development processes on Mac
# Exit status: 0 if clean, 1 if processes found

echo "🔍 Checking for stray development processes..."
echo "=" | head -c 50 | tr '=' '='
echo

FOUND_PROCESSES=0

# Check for processes listening on port 3000
echo "📡 Checking port 3000..."
PORT_3000=$(lsof -i :3000 -t 2>/dev/null)
if [ -n "$PORT_3000" ]; then
    echo "⚠️  Found processes on port 3000:"
    lsof -i :3000 | grep -E "COMMAND|LISTEN"
    echo "   To terminate: kill $PORT_3000"
    echo
    FOUND_PROCESSES=1
else
    echo "✅ Port 3000 is free"
    echo
fi

# Check for processes listening on port 9090
echo "📡 Checking port 9090..."
PORT_9090=$(lsof -i :9090 -t 2>/dev/null)
if [ -n "$PORT_9090" ]; then
    echo "⚠️  Found processes on port 9090:"
    lsof -i :9090 | grep -E "COMMAND|LISTEN"
    echo "   To terminate: kill $PORT_9090"
    echo
    FOUND_PROCESSES=1
else
    echo "✅ Port 9090 is free"
    echo
fi

# Check for Node.js processes
echo "🟢 Checking for Node.js processes..."
NODE_PROCS=$(pgrep -fl node 2>/dev/null | grep -v grep)
if [ -n "$NODE_PROCS" ]; then
    echo "⚠️  Found Node.js processes:"
    echo "$NODE_PROCS" | while IFS= read -r line; do
        PID=$(echo "$line" | awk '{print $1}')
        CMD=$(echo "$line" | cut -d' ' -f2-)
        echo "   PID $PID: $CMD"
        echo "   To terminate: kill $PID"
    done
    echo
    FOUND_PROCESSES=1
else
    echo "✅ No Node.js processes running"
    echo
fi

# Check for Claude CLI processes
echo "🤖 Checking for Claude CLI processes..."
CLAUDE_PROCS=$(pgrep -fl claude 2>/dev/null | grep -v grep | grep -v "cleanup.sh")
if [ -n "$CLAUDE_PROCS" ]; then
    echo "⚠️  Found Claude CLI processes:"
    echo "$CLAUDE_PROCS" | while IFS= read -r line; do
        PID=$(echo "$line" | awk '{print $1}')
        CMD=$(echo "$line" | cut -d' ' -f2-)
        echo "   PID $PID: $CMD"
        echo "   To terminate: kill $PID"
    done
    echo
    FOUND_PROCESSES=1
else
    echo "✅ No Claude CLI processes running"
    echo
fi

# Check for Docker containers
echo "🐳 Checking for Docker containers..."
if command -v docker &> /dev/null; then
    DOCKER_CONTAINERS=$(docker ps -q 2>/dev/null)
    if [ -n "$DOCKER_CONTAINERS" ]; then
        echo "⚠️  Found running Docker containers:"
        docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}"
        echo
        echo "   To stop all containers: docker stop \$(docker ps -q)"
        echo "   To stop specific container: docker stop CONTAINER_ID"
        echo
        FOUND_PROCESSES=1
    else
        echo "✅ No Docker containers running"
        echo
    fi
else
    echo "ℹ️  Docker not installed or not in PATH"
    echo
fi

# Summary and exit
echo "=" | head -c 50 | tr '=' '='
echo
if [ $FOUND_PROCESSES -eq 0 ]; then
    echo "✨ All clean! No stray development processes found."
    exit 0
else
    echo "⚠️  Found stray processes. Use the commands above to terminate them."
    echo "💡 Tip: To kill all processes at once, you can use:"
    echo "   kill $(lsof -i :3000 -i :9090 -t 2>/dev/null) $(pgrep node) $(pgrep claude) 2>/dev/null"
    exit 1
fi