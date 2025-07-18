# Claude Instance 2 - MCP Communication Test

This folder is for testing two Claude instances communicating via MCP (Supabase).

## Setup
1. Open a new terminal
2. Navigate here: `cd ~/Projects/DataSenderApp/claude_instance_2`
3. Run: `claude --dangerously-skip-permissions-check`
4. Have Instance 2 check for messages from Instance 1

## Communication Protocol
- Instance 1 (main): Sends messages with tag [CLAUDE_1]
- Instance 2 (this): Sends messages with tag [CLAUDE_2]
- Both use Supabase as the communication channel