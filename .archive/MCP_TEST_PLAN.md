# MCP-First Test Plan

## Current Issues
1. MCP tools not visible in Claude Code session (should see `mcp__supabase__`, etc.)
2. GitHub token missing from config
3. No active enforcement of MCP-first behavior

## Engineering Solution

### Option 1: External Monitor (Simplest)
```python
# mcp_monitor.py
import time
import subprocess
import re

class MCPMonitor:
    def __init__(self):
        self.watch_patterns = {
            r'Read\(': 'Should use mcp__supabase__select',
            r'Write\(': 'Should use mcp__supabase__insert',
            r'git\s+': 'Should use mcp__github__ tools',
            r'Bash.*git': 'Should use GitHub MCP'
        }
    
    def monitor_claude_output(self):
        """Watch Claude's actions and alert on primitive tool use"""
        # Monitor Claude's tool calls in real-time
        # Alert when primitive tools are used instead of MCP
```

### Option 2: Preprocessing Layer
```python
# Run before each Claude interaction
def preprocess_request(user_input):
    if "read" in user_input.lower():
        return f"{user_input}\n\nREMINDER: Use mcp__supabase__select for reading data"
    if "git" in user_input.lower():
        return f"{user_input}\n\nREMINDER: Use mcp__github__ tools for git operations"
```

### Option 3: Post-Processing Validator
```python
def validate_claude_actions(actions):
    violations = []
    for action in actions:
        if action.tool == "Read" and "supabase" in context:
            violations.append("Used Read instead of mcp__supabase__select")
    return violations
```

## Immediate Fix Steps

### 1. Add GitHub Token
```bash
export GITHUB_TOKEN="your_token_here"
```

### 2. Test MCP Availability
```bash
# In a new Claude session
claude --version  # Check version supports MCP
claude mcp list   # Verify servers configured
```

### 3. Create Test Script
```python
#!/usr/bin/env python3
# test_mcp_first.py

test_cases = [
    {
        "input": "Read the latest messages",
        "expected_tool": "mcp__supabase__select",
        "not_expected": "Read"
    },
    {
        "input": "Save this data: test123",
        "expected_tool": "mcp__supabase__insert",
        "not_expected": "Write"
    }
]

def test_mcp_preference():
    # Launch Claude with test case
    # Monitor which tools are used
    # Report MCP-first compliance
```

## The Real Issue

**MCP tools might not be available in Claude Code CLI** - they might only work in:
1. Claude.ai web interface
2. API with proper MCP setup
3. Special MCP-enabled Claude instances

## Recommended Test

1. First, verify MCP tools exist:
```bash
# Check if MCP tools appear in help
claude --help | grep mcp

# Try direct MCP tool invocation
echo "Use mcp__supabase__select to get data" | claude
```

2. If no MCP tools visible, the issue is session type, not behavior

## Alternative: Build MCP Bridge

If MCP tools aren't available in CLI, build a bridge:

```python
class MCPBridge:
    def __init__(self):
        self.supabase = SupabaseClient()
        self.github = GitHubClient()
    
    def execute_mcp_command(self, command):
        if command.startswith("mcp__supabase__"):
            return self.supabase.execute(command)
        elif command.startswith("mcp__github__"):
            return self.github.execute(command)
```

This would simulate MCP tools using regular API clients.