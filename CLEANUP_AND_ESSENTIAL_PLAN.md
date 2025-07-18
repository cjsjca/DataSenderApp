# Project Cleanup and Essential MVP Plan

## Files to DELETE (Half-attempts and Experiments)

### Failed Bridge Attempts
- brain_chat.html - File-based polling approach (didn't work)
- brain_input.html - Another half-attempt
- pipe_to_claude.py - File-based bridge (incomplete)
- simple_bridge.py - Incomplete server
- direct_chat.html - Just sends to Supabase, no real bridge
- simple_chat.html - Basic UI, no real functionality
- web_to_mcp.html - MCP bridge that doesn't work
- mcp_chat_server.js - MCP server (MCP doesn't work as expected)
- claude_chat.html - Another incomplete attempt
- listen_and_respond.sh - Manual polling approach

### MCP Mythology Files
- MCP_FIRST.md - Based on false assumptions
- mcp_proxy.py - Workaround for non-existent MCP tools
- mcp_config.json - Duplicate config
- mcp_first_config.json - Another duplicate

### Confusion-Adding Docs
- INTERPRETER_GUIDE.md - Not needed
- CODE_OF_CONDUCT.md - Generic
- CONTRIBUTING.md - Generic
- LICENSE - Generic
- POST_COMPACT_TEST_QUESTIONS.md - One-time use
- REHYDRATION_STRATEGY.md - Overthinking it
- CONTEXT_PRESERVATION.md - Redundant

## Files to KEEP (Essential for MVP)

### Core Working Code
- realtime_chat.html - PERFECT UI with all feedback elements
- auto_commit.sh - Works flawlessly
- quick_send.py - Useful for testing
- start_server.sh - Needed for server

### Essential Docs (Need Updating)
- README.md - Update to reflect reality
- CLAUDE.md - Core memory/instructions
- COMPLETE_PROJECT_UNDERSTANDING.md - Current reality

### New Files to Create
- chat_bridge.py - The ACTUAL working bridge
- QUICK_START.md - "Run these 3 commands"

## The Essential MVP Plan

### What We're Building
A simple bridge that connects your perfect `realtime_chat.html` to Claude CLI:

```
Browser (realtime_chat.html)
    ↓ (WebSocket)
Bridge Server (chat_bridge.py)
    ↓ (subprocess)
Claude CLI Session
```

### Core Features Needed
1. Start Claude CLI subprocess
2. WebSocket connection to browser
3. Pipe messages both ways
4. Handle status updates (thinking/ready/error)
5. Allow interruption

### Implementation Steps
1. Create `chat_bridge.py` with minimal working code
2. Test with existing `realtime_chat.html`
3. Update `start_server.sh` to use new bridge
4. Test from iPhone
5. Document in clean README

## New Directory Structure

```
DataSenderApp/
├── README.md                    # Clear explanation
├── QUICK_START.md              # 3 commands to run
├── CLAUDE.md                   # Persistent instructions
├── core/
│   ├── chat_bridge.py          # The working bridge
│   ├── realtime_chat.html      # The perfect UI
│   ├── auto_commit.sh          # Git automation
│   └── start_server.sh         # One-command start
├── utils/
│   └── quick_send.py           # Testing tool
└── docs/
    └── UNDERSTANDING.md        # Project reality
```

## Critical Understanding to Preserve

1. **This is a cognitive prosthetic** - Not a coding tool
2. **Browser-to-CLI bridge** - Simple subprocess piping
3. **MCP doesn't work as documented** - Use direct APIs
4. **The UI is already perfect** - Just needs backend
5. **Voice-first via browser** - Not complex agents

## Next Claude Instance Instructions

"Read QUICK_START.md first. This project is a simple browser-to-CLI bridge for Claude. The UI is done (realtime_chat.html), you just need to connect it to Claude CLI via WebSocket. Don't overthink it."