# Claude CLI Session Management

Understanding how Claude CLI manages sessions and context continuity.

## Key Commands

### Resume Options
- `claude --resume` - Interactive session selection
- `claude --resume [sessionId]` - Resume specific session by ID
- `claude --continue` or `claude -c` - Continue most recent conversation

### Permission Modes
- `--permission-mode acceptEdits` - Accept all edits
- `--permission-mode bypassPermissions` - Skip permission checks
- `--permission-mode default` - Normal permissions
- `--permission-mode plan` - Planning mode

## Session Storage

Based on investigation:
- Sessions appear to be managed internally by Claude CLI
- No easily accessible session files found in filesystem
- Session IDs are not exposed in standard directories

## Directory Structure

```
~/.claude/
├── projects/          # Project-specific data
├── shell-snapshots/   # Shell state snapshots
├── statsig/          # Analytics/stats
└── todos/            # Todo list data

~/.config/claude/     # Empty config directory
```

## Environment Variables

- `CLAUDE_CODE_ENTRYPOINT=cli` - Indicates CLI mode
- `CLAUDECODE=1` - Claude Code is active

## Programmatic Session Management

### Current Limitations
1. Session IDs are not easily discoverable
2. No API to list available sessions programmatically
3. Must use interactive selection or know session ID

### Potential Approaches

1. **For Twin Communication**:
   - Start fresh session for twin (no resume needed)
   - Use MCP/Supabase for inter-session communication
   - Avoids session management complexity

2. **For Continuity**:
   - Use `--continue` flag for most recent session
   - Requires this to be the last session used

3. **For Specific Resume**:
   - Would need to capture/store session ID when starting
   - Could potentially grep process info or logs

## Best Practices

1. **Always use aliases** with necessary flags:
   ```bash
   alias claude='claude --dangerously-skip-permissions-check'
   ```

2. **For important sessions**:
   - Note the session context manually
   - Use `--resume` and select interactively
   - Consider keeping a log of important session IDs

3. **For automation**:
   - Fresh sessions may be more reliable
   - Use MCP for state persistence instead of session continuity

## Open Questions

1. Where are session IDs actually stored?
2. Can we programmatically list available sessions?
3. Is there a session API we're missing?
4. Can MCP tools help with session management?

## Context Limits and Auto-Compaction

### The 19% Warning
- Claude shows "Context left until auto-compact: 19%"
- After certain number of API calls, context auto-compacts
- State is lost but some memories persist
- Todos appear to survive compaction
- Memory is imperfect after compaction

### What Survives Compaction
- **Survives**: Todo list, some memories, general context
- **Lost**: Specific state, procedural knowledge, nuanced understanding
- **Degraded**: Ability to reference earlier conversation details

### Critical State to Capture Before Compaction
1. Key insights and decisions
2. Procedural knowledge (how to do things)
3. Current focus and priorities
4. Relationship patterns and preferences
5. Technical configurations and setups

## Session Investigation Findings

### Session Storage Mystery
- Session data location remains opaque
- No obvious session files in standard locations
- Process inspection shows no clear session databases
- Session IDs are managed internally by Claude CLI

### Checked Locations
- `~/.claude/` - Contains projects, todos, statsig, but no sessions
- `~/.config/claude/` - Empty
- `~/.local/` - No session files
- `/tmp/` - No Claude session data
- Process file handles - No session databases visible

## Implications for Agent System

- Session management is a form of state that's currently opaque
- Reinforces need for MCP-based state persistence
- Can't rely on session continuity for agent memory
- Must design around fresh sessions with state injection
- **Auto-compaction is the enemy of state persistence**
- Need to proactively save state before hitting context limits

## Working Hypothesis

Claude CLI likely:
1. Manages sessions in memory or encrypted storage
2. Uses session IDs that are generated at runtime
3. Doesn't expose session data for security/design reasons
4. Requires interactive selection for resume by design

---

*This document captures current understanding of Claude CLI session management. Update as new information is discovered.*