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

## Implications for Agent System

- Session management is a form of state that's currently opaque
- Reinforces need for MCP-based state persistence
- Can't rely on session continuity for agent memory
- Must design around fresh sessions with state injection

---

*This document captures current understanding of Claude CLI session management. Update as new information is discovered.*