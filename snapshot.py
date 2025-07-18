#!/usr/bin/env python3
"""
Fast snapshot system - sends project state to Supabase
No git interruptions, pure text versioning
"""

import os
import json
import requests
from datetime import datetime
from pathlib import Path

SUPABASE_URL = "https://xvxyzmldrqewigrrccea.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE"

def snapshot_file(filepath):
    """Snapshot a single file to Supabase"""
    try:
        with open(filepath, 'r') as f:
            content = f.read()
        
        data = {
            'content': f"[SNAPSHOT] {filepath}\n\n{content}",
            'metadata': {
                'type': 'snapshot',
                'file': str(filepath),
                'timestamp': datetime.now().isoformat()
            }
        }
        
        response = requests.post(
            f"{SUPABASE_URL}/rest/v1/texts",
            headers={
                'apikey': SUPABASE_KEY,
                'Authorization': f'Bearer {SUPABASE_KEY}',
                'Content-Type': 'application/json'
            },
            json=data
        )
        return response.status_code == 201
    except:
        return False

def quick_snapshot(files=None):
    """Snapshot specific files or all important ones"""
    if not files:
        # Default important files
        files = [
            'CLAUDE.md',
            'README.md', 
            'terminal_chat.py',
            'mcp_config.json'
        ]
    
    for f in files:
        if os.path.exists(f):
            snapshot_file(f)
            print(f"✓ {f}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        quick_snapshot(sys.argv[1:])
    else:
        quick_snapshot()