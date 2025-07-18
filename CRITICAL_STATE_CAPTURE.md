# Project Context - DataSenderApp

This document contains essential context for working on this project.

## Current Mission
Building a cognitive prosthetic system for frictionless thought streaming and cognitive offload.

## Immediate Next Steps (Priority Order)

1. **TEST MCP TOOLS** - Test Supabase MCP integration
   - Check if MCP servers are configured: `claude mcp list`
   - If not configured, see .mcp.json for setup
   - Test twin Claude instances communicating via MCP

2. **Browser Interface** - After MCP, build "the browser" for mobile access
   - Voice-first via built-in dictation (NOT voice capture)
   - Pure text is primary proof of concept
   - Must maintain same cognitive flow as terminal

## Key Technical Discoveries

### Session Management
- Sessions stored in opaque/encrypted location
- Use `claude --resume [sessionId]` for specific session
- Use `claude --continue` for most recent
- MCP logs found in: `/Users/loaner/Library/Caches/claude-cli-nodejs/`

### Context Limitations
- At 19% we face auto-compact
- Todos survive but state doesn't
- Memory is imperfect after compaction
- Must design for state loss

### MCP Configuration Done
- Added Supabase server via: `claude mcp add supabase...`
- Config confirmed with: `claude mcp list`
- Need restart to activate

## Critical Behavioral Patterns to Remember

1. **LISTEN FIRST** - Don't code until user asks
2. **MCP FIRST** - Use servers not built-in tools
3. **CAPTURE STATE** - Document before losing context
4. **VOICE TO TEXT** - Primary input method

## Project Structure Understanding

```
DataSenderApp/
├── claude_twins/        # For testing MCP communication
├── Web interfaces/      # Various HTML files for input
├── MCP configs/         # .mcp.json files
├── Documentation/       # INSIGHTS_LOG, AGENT_VISION, etc.
└── Scripts/            # auto_commit.sh, wrappers
```

## Relationship Context

- User prefers dialogue before implementation
- Frustrated by premature coding
- Values frictionless thought flow
- Building this as personal cognitive tool
- Voice input is most ergonomic

## What We're Building

**Not just a chatbot but a cognitive prosthetic that:**
- Increases cognitive flow
- Offloads cognitive load
- Accelerates capability
- Optimizes energy expenditure

## Remember After Compact

1. Check INSIGHTS_LOG.md for key realizations
2. Read CURRENT_FOCUS.md for priorities
3. MCP tools are the exponential unlock
4. Browser interface enables mobile access
5. Everything through text first

---

*This capture made at 19% context. Use this to restore working state after compaction.*

## Project Navigation

1. Start here for context
2. Read CURRENT_FOCUS.md for active priorities
3. Read CONSULTANT_ANALYSIS.md for architectural strategy
4. Check your todo list
5. Other docs provide deeper detail as needed