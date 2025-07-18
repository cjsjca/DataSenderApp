#!/usr/bin/env python3
"""
Ultra-fast message sender for Termius snippets
Usage: echo "your message" | python3 quick_send.py
"""

import sys
import requests

# Read from stdin
message = sys.stdin.read().strip()

if message:
    try:
        response = requests.post(
            'https://xvxyzmldrqewigrrccea.supabase.co/rest/v1/texts',
            headers={
                'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE',
                'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE',
                'Content-Type': 'application/json'
            },
            json={'content': f'[QUICK] {message}'},
            timeout=2
        )
        
        if response.status_code == 201:
            print(f"✓ Sent: {message}")
        else:
            print("✗ Failed")
    except Exception as e:
        print(f"✗ Error: {e}")
else:
    print("Usage: echo 'your message' | python3 quick_send.py")