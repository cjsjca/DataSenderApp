#!/usr/bin/env python3
"""
Claude MCP Wrapper - Forces MCP-first operations
This wrapper intercepts commands and redirects to MCP servers when possible
"""

import sys
import os
import subprocess
import json
import re
from datetime import datetime

# MCP server mappings - expand this based on your servers
MCP_MAPPINGS = {
    # File operations → Supabase
    'read': 'mcp__supabase__select',
    'write': 'mcp__supabase__insert', 
    'list': 'mcp__supabase__select',
    
    # Git operations → GitHub MCP
    'git': 'mcp__github__',
    
    # Data operations → Supabase
    'save': 'mcp__supabase__insert',
    'load': 'mcp__supabase__select',
    'query': 'mcp__supabase__select',
}

class MCPWrapper:
    def __init__(self):
        self.log_file = "/tmp/claude_mcp_wrapper.log"
        self.state_file = "/tmp/claude_mcp_state.json"
        self.load_state()
    
    def log(self, message):
        """Log operations for debugging"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(self.log_file, 'a') as f:
            f.write(f"[{timestamp}] {message}\n")
    
    def load_state(self):
        """Load persistent state"""
        try:
            with open(self.state_file, 'r') as f:
                self.state = json.load(f)
        except:
            self.state = {
                'mcp_first': True,
                'intercept_commands': True,
                'last_session': None,
                'usage_stats': {}
            }
    
    def save_state(self):
        """Save persistent state"""
        with open(self.state_file, 'w') as f:
            json.dump(self.state, f, indent=2)
    
    def intercept_command(self, command):
        """Check if command should be redirected to MCP"""
        self.log(f"Intercepting: {command}")
        
        # Check for common operations that could use MCP
        for pattern, mcp_tool in MCP_MAPPINGS.items():
            if pattern in command.lower():
                self.log(f"Redirecting to MCP: {mcp_tool}")
                return self.suggest_mcp_alternative(command, mcp_tool)
        
        return None
    
    def suggest_mcp_alternative(self, original_command, mcp_tool):
        """Suggest MCP alternative for command"""
        suggestion = f"""
🚀 MCP-FIRST SUGGESTION:
Instead of: {original_command}
Consider using MCP: {mcp_tool}

This gives you:
- Database persistence
- Remote access capability  
- Autonomous agent potential
- Exponential power through server integration

Type 'mcp' to see available MCP tools, or 'continue' to use original command.
"""
        return suggestion
    
    def wrap_claude_session(self):
        """Wrap Claude CLI session with MCP awareness"""
        print("🧠 Claude MCP Wrapper Active")
        print("📡 MCP servers give exponential power - autonomous agents, databases, external systems")
        print("💡 I'll suggest MCP alternatives for common operations\n")
        
        # Set environment to remind Claude about MCP
        os.environ['CLAUDE_MCP_FIRST'] = '1'
        os.environ['CLAUDE_WRAPPER_ACTIVE'] = '1'
        
        # Start Claude with custom prompt
        initial_prompt = """Remember: MCP tools are my superpowers! They give me:
- Autonomous agent capabilities
- Database persistence
- External system integration
- Exponential power beyond built-in tools

I should always consider MCP tools first before using primitive built-in tools.
Available MCP servers: supabase, github"""
        
        # Launch Claude CLI
        subprocess.run([
            'claude',
            '--dangerously-skip-permissions-check',
            '-m', initial_prompt
        ])

def main():
    wrapper = MCPWrapper()
    
    if len(sys.argv) > 1:
        # Command mode - check for MCP alternatives
        command = ' '.join(sys.argv[1:])
        suggestion = wrapper.intercept_command(command)
        if suggestion:
            print(suggestion)
    else:
        # Interactive mode - wrap Claude session
        wrapper.wrap_claude_session()

if __name__ == "__main__":
    main()