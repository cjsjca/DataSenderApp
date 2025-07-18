#!/usr/bin/env python3
"""
Fast terminal chat interface for Supabase
Optimized for speed and real-time conversation
"""

import os
import sys
import time
import json
import requests
import threading
from datetime import datetime
from queue import Queue

# Supabase config
SUPABASE_URL = "https://xvxyzmldrqewigrrccea.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE"

# Colors for terminal
CYAN = '\033[96m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
RESET = '\033[0m'
GRAY = '\033[90m'

class TerminalChat:
    def __init__(self):
        self.last_check = datetime.now()
        self.message_queue = Queue()
        self.running = True
        
    def send_message(self, content):
        """Send message to Supabase"""
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
        
        data = {
            'content': f"[TERMINAL] {content}",
            'created_at': datetime.now().isoformat()
        }
        
        try:
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/texts",
                headers=headers,
                json=data,
                timeout=2
            )
            return response.status_code == 201
        except:
            return False
    
    def check_messages(self):
        """Check for new messages from Claude"""
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}'
        }
        
        # Look for Claude's responses
        query = f"created_at.gt.{self.last_check.isoformat()}&content.like.[CLAUDE]%&order=created_at.asc"
        
        try:
            response = requests.get(
                f"{SUPABASE_URL}/rest/v1/texts?{query}",
                headers=headers,
                timeout=2
            )
            
            if response.status_code == 200:
                messages = response.json()
                for msg in messages:
                    self.message_queue.put(msg)
                    self.last_check = datetime.fromisoformat(msg['created_at'].replace('+00:00', ''))
        except:
            pass
    
    def monitor_loop(self):
        """Background thread to check for messages"""
        while self.running:
            self.check_messages()
            time.sleep(0.5)  # Check twice per second
    
    def display_message(self, msg):
        """Display a message from Claude"""
        content = msg['content'].replace('[CLAUDE] ', '')
        timestamp = datetime.fromisoformat(msg['created_at'].replace('+00:00', ''))
        time_str = timestamp.strftime('%H:%M:%S')
        
        print(f"\r{GRAY}{time_str}{RESET} {GREEN}Claude:{RESET} {content}")
        print(f"{CYAN}You:{RESET} ", end='', flush=True)
    
    def run(self):
        """Main chat loop"""
        print(f"{YELLOW}=== Terminal Chat (Supabase) ==={RESET}")
        print(f"{GRAY}Type messages and press Enter. Type /quit to exit.{RESET}\n")
        
        # Start monitor thread
        monitor = threading.Thread(target=self.monitor_loop, daemon=True)
        monitor.start()
        
        try:
            while True:
                # Check for incoming messages
                while not self.message_queue.empty():
                    msg = self.message_queue.get()
                    self.display_message(msg)
                
                # Get user input
                print(f"{CYAN}You:{RESET} ", end='', flush=True)
                user_input = input()
                
                if user_input.strip() == '/quit':
                    break
                
                if user_input.strip():
                    # Send message
                    if self.send_message(user_input):
                        print(f"{GRAY}[sent]{RESET}")
                    else:
                        print(f"{GRAY}[failed to send]{RESET}")
                
        except KeyboardInterrupt:
            pass
        finally:
            self.running = False
            print(f"\n{YELLOW}Chat ended.{RESET}")

if __name__ == "__main__":
    chat = TerminalChat()
    chat.run()