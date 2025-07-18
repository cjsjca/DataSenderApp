#!/bin/bash
# Run this to have Claude actively monitor Supabase

echo "🤖 Starting Supabase listener for Claude..."
echo ""
echo "Setup:"
echo "1. This window: Will show incoming messages"
echo "2. Other window: Run 'claude' to respond"
echo ""
echo "Workflow:"
echo "- Send message from iPhone to Supabase"
echo "- See/hear notification here"
echo "- Switch to Claude window to respond"
echo ""

python3 supabase_listener.py