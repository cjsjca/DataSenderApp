#!/bin/bash
# Run two Claude instances that communicate via MCP

echo "🧠🧠 Claude Twins - MCP Communication Demo"
echo ""
echo "This demonstrates two Claude instances communicating through Supabase MCP"
echo ""
echo "Setup:"
echo "1. Terminal 1: cd claude_twins/instance_1 && claude"
echo "2. Terminal 2: cd claude_twins/instance_2 && claude"
echo ""
echo "Protocol:"
echo "- Instance 1: Use tag [CLAUDE_1] in messages"
echo "- Instance 2: Use tag [CLAUDE_2] in messages"
echo "- Both: Use Supabase MCP to send/receive"
echo ""
echo "Opening Terminal 1 for Instance 1..."

cd instance_1
claude --dangerously-skip-permissions-check