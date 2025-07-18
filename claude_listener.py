#!/usr/bin/env python3
"""
Claude's listener - monitors Supabase for terminal messages
"""

import time
import requests
from datetime import datetime

SUPABASE_URL = "https://xvxyzmldrqewigrrccea.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE"

def get_latest_message():
    """Get the most recent terminal message"""
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}'
    }
    
    query = "content.like.[TERMINAL]%&order=created_at.desc&limit=1"
    
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/texts?{query}",
            headers=headers
        )
        
        if response.status_code == 200:
            messages = response.json()
            if messages:
                return messages[0]
    except:
        pass
    
    return None

def send_response(content):
    """Send Claude's response"""
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    data = {
        'content': f"[CLAUDE] {content}",
        'created_at': datetime.now().isoformat()
    }
    
    try:
        requests.post(
            f"{SUPABASE_URL}/rest/v1/texts",
            headers=headers,
            json=data
        )
    except:
        pass

# Quick test
if __name__ == "__main__":
    print("Checking for latest message...")
    msg = get_latest_message()
    if msg:
        print(f"Latest: {msg['content']}")
        print(f"Time: {msg['created_at']}")