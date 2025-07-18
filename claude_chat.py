#!/usr/bin/env python3
"""
Claude chat wrapper for SSH access
Uses Anthropic API directly to bypass OAuth issues
"""

import os
import sys
from anthropic import Anthropic
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def chat_with_claude():
    # Get API key from environment
    api_key = os.getenv('ANTHROPIC_API_KEY')
    if not api_key:
        print("Error: ANTHROPIC_API_KEY not found in .env file")
        print("Please add your API key to .env file")
        return
    
    client = Anthropic(api_key=api_key)
    
    print("Claude Chat (type 'exit' to quit)")
    print("-" * 40)
    
    messages = []
    
    while True:
        # Get user input
        user_input = input("\nYou: ").strip()
        
        if user_input.lower() in ['exit', 'quit', 'q']:
            break
            
        if not user_input:
            continue
            
        # Add user message
        messages.append({"role": "user", "content": user_input})
        
        try:
            # Get Claude's response
            response = client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=1024,
                messages=messages
            )
            
            # Print response
            assistant_message = response.content[0].text
            print(f"\nClaude: {assistant_message}")
            
            # Add to history
            messages.append({"role": "assistant", "content": assistant_message})
            
        except Exception as e:
            print(f"\nError: {e}")

if __name__ == "__main__":
    chat_with_claude()