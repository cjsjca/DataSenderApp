#!/usr/bin/env python3
"""
Simple file-based bridge between web interface and Claude CLI
Web writes to input file → This script pipes to Claude → Claude responds
"""

import os
import sys
import time
import subprocess
from datetime import datetime

INPUT_FILE = "/tmp/claude_input.txt"
OUTPUT_FILE = "/tmp/claude_output.txt"
LOG_FILE = "/tmp/claude_bridge.log"

def log(message):
    """Log with timestamp"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, 'a') as f:
        f.write(f"[{timestamp}] {message}\n")
    print(f"[{timestamp}] {message}")

def main():
    log("Starting Claude bridge...")
    
    # Create files if they don't exist
    for file in [INPUT_FILE, OUTPUT_FILE]:
        if not os.path.exists(file):
            open(file, 'w').close()
            os.chmod(file, 0o666)  # Make accessible to web server
    
    # Start Claude CLI
    log("Starting Claude CLI...")
    claude_process = subprocess.Popen(
        ["claude", "--dangerously-skip-permissions-check"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1
    )
    
    log(f"Claude started with PID: {claude_process.pid}")
    log(f"Watching for input at: {INPUT_FILE}")
    
    last_message = ""
    
    try:
        while True:
            # Check for new input
            try:
                with open(INPUT_FILE, 'r') as f:
                    message = f.read().strip()
                
                if message and message != last_message:
                    log(f"New message: {message}")
                    last_message = message
                    
                    # Send to Claude
                    claude_process.stdin.write(message + '\n')
                    claude_process.stdin.flush()
                    
                    # Collect response (with timeout)
                    response_lines = []
                    start_time = time.time()
                    
                    while time.time() - start_time < 30:  # 30 second timeout
                        line = claude_process.stdout.readline()
                        if line:
                            response_lines.append(line.strip())
                            # Check if response seems complete
                            if line.strip() == "" and len(response_lines) > 2:
                                break
                    
                    # Write response
                    response = '\n'.join(response_lines)
                    with open(OUTPUT_FILE, 'w') as f:
                        f.write(response)
                    
                    log(f"Response written ({len(response)} chars)")
                    
                    # Clear input to prevent re-processing
                    with open(INPUT_FILE, 'w') as f:
                        f.write("")
                    
            except Exception as e:
                log(f"Error processing: {e}")
            
            time.sleep(1)  # Check every second
            
    except KeyboardInterrupt:
        log("Stopping bridge...")
        claude_process.terminate()
    except Exception as e:
        log(f"Fatal error: {e}")
        claude_process.terminate()

if __name__ == "__main__":
    main()