# Project Reorganization Plan

## Current Problems

1. **Unclear Project Purpose** - After compaction, I couldn't understand this was an MCP-first cognitive prosthetic
2. **MCP Confusion** - Documentation suggests programmatic MCP tools that don't match reality
3. **Scattered Files** - 50+ files at root level mixing different concerns
4. **No Clear Navigation** - Multiple "start here" type documents

## Proposed New Structure

```
DataSenderApp/
├── README.md                    # Clear project overview
├── QUICK_START.md              # How to get started immediately
├── docs/
│   ├── MCP_EXPLAINED.md        # What MCP is and how it ACTUALLY works
│   ├── PROJECT_VISION.md       # Cognitive prosthetic concept
│   ├── ARCHITECTURE.md         # System design
│   ├── insights/               # Chronological insights
│   └── bootstrap/              # Post-compaction recovery docs
├── mcp/
│   ├── README.md               # MCP configuration guide
│   ├── supabase/               # Supabase MCP setup
│   ├── github/                 # GitHub MCP setup
│   └── testing/                # Twin Claude demos
├── interfaces/
│   ├── web/                    # All HTML interfaces
│   ├── cli/                    # Command line tools
│   └── bridges/                # Server bridges
├── scripts/
│   ├── auto_commit.sh          # Versioning system
│   ├── quick_send.py           # Quick tools
│   └── setup/                  # Setup scripts
└── .archive/                   # Old/deprecated files
```

## Key Changes

### 1. Clear Entry Points
- **README.md** - "This is a cognitive prosthetic using MCP-first architecture"
- **QUICK_START.md** - "Run these 3 commands to see it work"
- **docs/MCP_EXPLAINED.md** - "Here's how MCP ACTUALLY works in Claude CLI"

### 2. Grouped by Purpose
- All MCP-related content in `mcp/`
- All interfaces in `interfaces/`
- All documentation in `docs/`

### 3. Archive Confusion
Move files that add confusion without adding clarity to `.archive/`

## Understanding MCP - What We Need to Document

### Current Understanding Gaps

1. **Slash Commands vs Tools**
   - Docs mention `/mcp__supabase__` commands
   - These don't appear in CLI
   - How do MCP tools ACTUALLY manifest?

2. **MCP Server Integration**
   - `claude mcp list` shows configured servers
   - But how do we USE them programmatically?
   - Natural language? Special syntax? Hidden tools?

3. **State Persistence via MCP**
   - Theory: MCP enables persistent state
   - Practice: How exactly?
   - Need concrete examples

### Research Needed

1. **Test Natural Language MCP**
   ```
   "Use Supabase MCP to insert a message"
   "Query Supabase via MCP for recent texts"
   ```

2. **Look for Hidden Tools**
   - Are MCP tools available but not listed?
   - Do they appear in certain contexts?

3. **Check Claude Code Source**
   - Is there documentation we're missing?
   - Are there example projects?

## Next Steps

1. **Create MCP_REALITY.md** - Document how MCP actually works based on testing
2. **Reorganize files** into new structure
3. **Write clear README** that explains the project in 3 sentences
4. **Test MCP thoroughly** and document findings

## Success Metrics

After reorganization:
- New Claude instance understands project purpose in < 1 minute
- MCP usage is clear and documented with examples
- File structure supports project goals, not hinders them