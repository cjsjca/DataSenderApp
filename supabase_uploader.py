#!/usr/bin/env python3
"""
Simple Supabase Data Uploader
Upload text, files, and data to your Supabase instance
"""

import requests
import json
import os
import sys
from datetime import datetime

# Supabase configuration
SUPABASE_URL = "https://xvxyzmldrqewigrrccea.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE"

def upload_text(text):
    """Upload text to the texts table"""
    url = f"{SUPABASE_URL}/rest/v1/texts"
    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=representation"
    }
    data = {"content": text}
    
    response = requests.post(url, headers=headers, json=data)
    if response.status_code == 201:
        result = response.json()[0]
        print(f"✅ Text uploaded successfully!")
        print(f"   ID: {result['id']}")
        print(f"   Created: {result['created_at']}")
        return result
    else:
        print(f"❌ Failed to upload text: {response.status_code}")
        print(f"   Error: {response.text}")
        return None

def upload_file(file_path, bucket="uploads"):
    """Upload a file to Supabase storage"""
    file_name = os.path.basename(file_path)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    storage_path = f"{timestamp}_{file_name}"
    
    url = f"{SUPABASE_URL}/storage/v1/object/{bucket}/{storage_path}"
    
    # Determine content type
    content_type = "application/octet-stream"
    if file_path.lower().endswith(('.jpg', '.jpeg')):
        content_type = "image/jpeg"
    elif file_path.lower().endswith('.png'):
        content_type = "image/png"
    elif file_path.lower().endswith('.heic'):
        content_type = "image/heic"
    
    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": content_type
    }
    
    with open(file_path, 'rb') as f:
        data = f.read()
        response = requests.post(url, headers=headers, data=data)
    
    if response.status_code == 200:
        print(f"✅ File uploaded successfully!")
        print(f"   Path: {storage_path}")
        public_url = f"{SUPABASE_URL}/storage/v1/object/public/{bucket}/{storage_path}"
        print(f"   URL: {public_url}")
        return storage_path
    else:
        print(f"❌ Failed to upload file: {response.status_code}")
        print(f"   Error: {response.text}")
        return None

def interactive_mode():
    """Interactive command-line interface"""
    print("\n🚀 Supabase Data Uploader")
    print("=" * 40)
    
    while True:
        print("\nWhat would you like to upload?")
        print("1. Text")
        print("2. File")
        print("3. Quit")
        
        choice = input("\nEnter your choice (1-3): ").strip()
        
        if choice == "1":
            text = input("\nEnter text to upload: ")
            if text:
                upload_text(text)
            else:
                print("❌ No text entered")
                
        elif choice == "2":
            file_path = input("\nEnter file path: ").strip()
            if os.path.exists(file_path):
                upload_file(file_path)
            else:
                print(f"❌ File not found: {file_path}")
                
        elif choice == "3":
            print("\n👋 Goodbye!")
            break
            
        else:
            print("❌ Invalid choice. Please try again.")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Command line mode
        if sys.argv[1] == "text" and len(sys.argv) > 2:
            text = " ".join(sys.argv[2:])
            upload_text(text)
        elif sys.argv[1] == "file" and len(sys.argv) > 2:
            upload_file(sys.argv[2])
        else:
            print("Usage:")
            print("  python supabase_uploader.py                    # Interactive mode")
            print("  python supabase_uploader.py text 'Your text'  # Upload text")
            print("  python supabase_uploader.py file /path/to/file # Upload file")
    else:
        # Interactive mode
        interactive_mode()