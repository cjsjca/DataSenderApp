#!/usr/bin/env python3
"""Test Supabase connection"""

import requests
from datetime import datetime

SUPABASE_URL = "https://xvxyzmldrqewigrrccea.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE"

print("Testing Supabase connection...")

# Test message
data = {
    'content': f"[TEST] Connection test at {datetime.now().strftime('%H:%M:%S')}"
}

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json',
    'Prefer': 'return=minimal'
}

try:
    response = requests.post(
        f"{SUPABASE_URL}/rest/v1/texts",
        headers=headers,
        json=data
    )
    
    print(f"Status: {response.status_code}")
    print(f"Response: {response.text}")
    
    if response.status_code == 201:
        print("✅ Success! Message sent to Supabase")
    else:
        print("❌ Failed to send message")
        
except Exception as e:
    print(f"❌ Error: {e}")