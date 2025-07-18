#!/bin/bash
# Start the Claude chat server

echo "Starting Claude Realtime Chat Server..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is required but not installed."
    exit 1
fi

# Install required packages if needed
pip3 install flask flask-cors > /dev/null 2>&1

# Get local IP address
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

echo ""
echo "Server starting on:"
echo "  Local: http://localhost:8080/realtime_chat.html"
echo "  Network: http://$LOCAL_IP:8080/realtime_chat.html"
echo ""
echo "Access from iPhone using the Network URL when on same WiFi"
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server
python3 chat_server.py