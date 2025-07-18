#!/usr/bin/env python3
"""
Monitors Supabase for new messages and alerts you in terminal
Run this alongside Claude CLI
"""

import requests
import json
import time
from datetime import datetime, timezone
import subprocess
import os

SUPABASE_URL = 'https://xvxyzmldrqewigrrccea.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE'

# Track last check time
last_check = datetime.now(timezone.utc)

def check_messages():
    """Check for new messages since last check"""
    global last_check
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}'
    }
    
    # Get messages after last check
    timestamp = last_check.isoformat()
    query = f"created_at.gt.{timestamp}&order=created_at.asc"
    
    try:
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/texts?{query}",
            headers=headers
        )
        
        if response.status_code == 200:
            messages = response.json()
            
            for msg in messages:
                content = msg.get('content', '')
                created = msg.get('created_at', '')
                
                # Skip if it's from Claude
                if '[CLAUDE]' in content:
                    continue
                
                # Alert with sound and display
                print(f"\n🔔 NEW MESSAGE ({created}):")
                print(f"   {content}\n")
                
                # Mac notification sound
                os.system('afplay /System/Library/Sounds/Glass.aiff')
                
                # Optional: Mac notification
                subprocess.run([
                    'osascript', '-e',
                    f'display notification "{content[:100]}" with title "New Supabase Message"'
                ])
            
            # Update last check time
            if messages:
                last_check = datetime.now(timezone.utc)
                
    except Exception as e:
        print(f"Error checking messages: {e}")

def main():
    print("🎧 Listening to Supabase for new messages...")
    print("   Messages will appear here with notification sound")
    print("   Press Ctrl+C to stop\n")
    
    try:
        while True:
            check_messages()
            time.sleep(5)  # Check every 5 seconds
            
    except KeyboardInterrupt:
        print("\n\n👋 Stopped listening to Supabase")

if __name__ == "__main__":
    main()