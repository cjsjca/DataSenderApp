#!/usr/bin/env python3
"""
Local chat server that bridges between webpage and Claude via file watching
"""

import asyncio
import json
from datetime import datetime
from pathlib import Path
import time

# File paths for communication
INCOMING_FILE = Path("/tmp/brain_to_claude.txt")
OUTGOING_FILE = Path("/tmp/claude_to_brain.txt")
LOG_FILE = Path("/tmp/chat_log.json")

# Initialize files
INCOMING_FILE.touch()
OUTGOING_FILE.touch()
LOG_FILE.touch()

async def watch_for_messages():
    """Watch for new messages from the webpage"""
    last_content = ""
    
    print("🧠 Brain-Claude Bridge Started")
    print(f"📥 Watching: {INCOMING_FILE}")
    print(f"📤 Responses: {OUTGOING_FILE}")
    print("-" * 40)
    
    while True:
        try:
            # Check for new message from webpage
            current_content = INCOMING_FILE.read_text().strip()
            
            if current_content and current_content != last_content:
                print(f"\n[{datetime.now().strftime('%H:%M:%S')}] New message: {current_content}")
                
                # Log the message
                log_entry = {
                    "timestamp": datetime.now().isoformat(),
                    "from": "user",
                    "message": current_content
                }
                
                # Append to log
                try:
                    logs = json.loads(LOG_FILE.read_text() or "[]")
                except:
                    logs = []
                logs.append(log_entry)
                LOG_FILE.write_text(json.dumps(logs, indent=2))
                
                # Clear the outgoing file to signal "typing..."
                OUTGOING_FILE.write_text("...")
                
                # Write a marker for Claude to see
                marker_file = Path("/tmp/new_message_for_claude.txt")
                marker_file.write_text(f"User said: {current_content}")
                
                last_content = current_content
                
        except Exception as e:
            print(f"Error: {e}")
            
        await asyncio.sleep(0.5)  # Check twice per second

if __name__ == "__main__":
    try:
        asyncio.run(watch_for_messages())
    except KeyboardInterrupt:
        print("\n\n👋 Bridge stopped")