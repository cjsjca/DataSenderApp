#!/usr/bin/env python3
"""
Chat bridge server - Connects web browser to Claude CLI
Handles real-time bidirectional communication
"""

from flask import Flask, request, jsonify, Response
from flask_cors import CORS
import subprocess
import threading
import queue
import json
import time
import os

app = Flask(__name__)
CORS(app)

# Message queues
to_claude = queue.Queue()
from_claude = queue.Queue()

# Claude process management
claude_process = None
claude_thread = None

def run_claude():
    """Run Claude CLI and handle I/O"""
    global claude_process
    
    # Start Claude CLI
    claude_process = subprocess.Popen(
        ['claude', '--no-version-check'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1
    )
    
    # Monitor output
    while claude_process.poll() is None:
        # Check for input from web
        try:
            message = to_claude.get(timeout=0.1)
            claude_process.stdin.write(message + '\n')
            claude_process.stdin.flush()
            from_claude.put({'type': 'thinking', 'message': 'Processing...'})
        except queue.Empty:
            pass
        
        # Read output from Claude
        line = claude_process.stdout.readline()
        if line:
            from_claude.put({'type': 'response', 'message': line.strip()})

@app.route('/send', methods=['POST'])
def send_to_claude():
    """Receive message from browser"""
    data = request.json
    message = data.get('message', '')
    
    # Add to queue for Claude
    to_claude.put(message)
    
    # Also save to Supabase for persistence
    save_to_supabase(message, source='browser')
    
    return jsonify({'status': 'queued'})

@app.route('/stream')
def stream_from_claude():
    """SSE endpoint for real-time updates"""
    def generate():
        while True:
            try:
                data = from_claude.get(timeout=1)
                yield f"data: {json.dumps(data)}\n\n"
            except queue.Empty:
                # Send heartbeat
                yield f"data: {json.dumps({'type': 'heartbeat'})}\n\n"
    
    return Response(generate(), mimetype="text/event-stream")

@app.route('/terminal')
def terminal_view():
    """Get current terminal output"""
    # Return last N lines of terminal output
    return jsonify({'terminal': get_terminal_buffer()})

def save_to_supabase(content, source='browser'):
    """Save messages to Supabase for persistence"""
    # Your existing Supabase saving logic
    pass

def get_terminal_buffer():
    """Get recent terminal output"""
    # Implementation to capture terminal state
    return "Terminal output here..."

if __name__ == '__main__':
    # Start Claude in background thread
    claude_thread = threading.Thread(target=run_claude)
    claude_thread.daemon = True
    claude_thread.start()
    
    print("🚀 Chat bridge server starting...")
    print("📱 Browser interface: http://localhost:8080")
    print("🖥️  Claude CLI running in background")
    
    app.run(host='0.0.0.0', port=8080)