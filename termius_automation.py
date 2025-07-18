#!/usr/bin/env python3
"""
Termius Automation Layer
Programmatic control without UI interaction
"""

import subprocess
import json
import os
from pathlib import Path

class TermiusAutomation:
    """Control Termius programmatically"""
    
    def __init__(self):
        self.home = Path.home()
        self.project = self.home / "Projects" / "DataSenderApp"
        
    def create_snippet(self, name, command):
        """Create a snippet programmatically (via termius-cli)"""
        # Note: Full snippet API requires Team plan
        # For now, we'll document what would be possible
        snippet = {
            "name": name,
            "script": command,
            "run_on_connect": False,
            "logout_after": False
        }
        return snippet
    
    def quick_send(self, message):
        """Send message without opening Termius UI"""
        cmd = [
            'ssh',
            '-o', 'StrictHostKeyChecking=no',
            '-o', 'UserKnownHostsFile=/dev/null',
            'localhost',  # Replace with your Mac's address
            f'cd {self.project} && echo "{message}" | python3 quick_send.py'
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            return result.stdout
        except Exception as e:
            return f"Error: {e}"
    
    def launch_chat(self):
        """Launch terminal chat session"""
        cmd = [
            'termius',
            'connect',
            'DataSenderMac',
            '--command',
            f'cd {self.project} && python3 terminal_chat.py'
        ]
        
        try:
            subprocess.run(cmd)
        except Exception as e:
            print(f"Error: {e}")
    
    def check_status(self):
        """Check if Claude is running"""
        cmd = [
            'ssh',
            'localhost',
            'ps aux | grep claude | grep -v grep'
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            return "Claude running" if result.stdout else "Claude not running"
        except:
            return "Cannot connect"

# Snippet definitions for Termius
SNIPPETS = {
    "chat": {
        "name": "Launch Chat",
        "script": "cd ~/Projects/DataSenderApp && python3 terminal_chat.py"
    },
    "quick": {
        "name": "Quick Send",
        "script": """read -p "Message: " msg
cd ~/Projects/DataSenderApp
echo "$msg" | python3 quick_send.py"""
    },
    "status": {
        "name": "Check Claude",
        "script": "ps aux | grep claude | grep -v grep || echo 'Claude not running'"
    },
    "snapshot": {
        "name": "Snapshot Files",
        "script": "cd ~/Projects/DataSenderApp && python3 snapshot.py"
    },
    "recent": {
        "name": "Recent Messages",
        "script": """cd ~/Projects/DataSenderApp
python3 -c "
import requests
import json
from datetime import datetime

url = 'https://xvxyzmldrqewigrrccea.supabase.co/rest/v1/texts'
params = '?order=created_at.desc&limit=5'
headers = {
    'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE'
}

response = requests.get(url + params, headers=headers)
if response.status_code == 200:
    messages = response.json()
    for msg in messages:
        time = datetime.fromisoformat(msg['created_at'].replace('+00:00', ''))
        print(f'[{time.strftime('%H:%M')}] {msg['content'][:100]}...')
"
"""
    }
}

if __name__ == "__main__":
    # Print snippet definitions for manual setup
    print("=== Termius Snippets for Manual Setup ===\n")
    
    for key, snippet in SNIPPETS.items():
        print(f"Name: {snippet['name']}")
        print(f"Script:\n{snippet['script']}")
        print("-" * 40)
    
    # Test automation
    print("\n=== Testing Automation ===")
    auto = TermiusAutomation()
    print(auto.check_status())