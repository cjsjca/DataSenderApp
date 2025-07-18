#!/bin/bash
# Setup script for testing two Claude instances communicating via MCP

echo "🚀 Setting up MCP Communication Test"
echo ""
echo "This will demonstrate two Claude instances communicating through Supabase MCP"
echo ""
echo "Steps:"
echo "1. Terminal 1 (this window): Claude Instance 1"
echo "2. Terminal 2: cd ~/Projects/DataSenderApp/claude_instance_2"
echo "3. Terminal 2: claude --dangerously-skip-permissions-check"
echo ""
echo "In Terminal 2, when Claude starts, say:"
echo "  'Please check Supabase for messages tagged [CLAUDE_1] using MCP tools'"
echo ""
echo "Then Instance 1 and 2 can communicate through Supabase!"
echo ""
echo "Starting Instance 1 with MCP awareness..."
echo ""

# Ensure MCP config is in place
if [ ! -f ".mcp.json" ]; then
    echo "⚠️  No .mcp.json found. Creating from template..."
    cp Backend/MCP/.mcp.json .mcp.json
fi

# Start Claude with MCP-first reminder
claude --dangerously-skip-permissions-check -m "Remember: Use MCP tools first! They give exponential power. To communicate with another Claude instance, use Supabase MCP to insert messages with [CLAUDE_1] tag."