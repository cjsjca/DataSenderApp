#!/usr/bin/env python3
"""Test Claude CLI interaction"""

import subprocess
import time
import sys

# Start Claude
proc = subprocess.Popen(
    ['claude'],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
    text=True,
    bufsize=0
)

print("Claude started, reading initial output...")

# Read initial output with timeout
start = time.time()
initial = ""
while time.time() - start < 3:
    try:
        # Read one character at a time
        char = proc.stdout.read(1)
        if char:
            initial += char
            sys.stdout.write(char)
            sys.stdout.flush()
    except:
        break

print("\n\nInitial output complete. Sending test message...")

# Send a test message
test_message = "Hello Claude, please respond with just 'Hello!'"
proc.stdin.write(test_message + '\n')
proc.stdin.flush()

print(f"Sent: {test_message}")
print("Waiting for response...")

# Read response
response = ""
start = time.time()
while time.time() - start < 10:
    try:
        char = proc.stdout.read(1)
        if char:
            response += char
            sys.stdout.write(char)
            sys.stdout.flush()
    except:
        break

print("\n\nTest complete.")
proc.terminate()