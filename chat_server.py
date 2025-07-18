#!/usr/bin/env python3
"""
Lightweight server to bridge between web interface and Claude CLI
Provides real-time feedback and interrupt capabilities
"""

import asyncio
import json
import subprocess
import threading
import time
from datetime import datetime
from flask import Flask, request, jsonify, Response
from flask_cors import CORS
import queue
import os
import signal

app = Flask(__name__)
CORS(app)

# Global state
active_processes = {}
message_queue = queue.Queue()
clients = []

# Claude CLI command
CLAUDE_CMD = ["claude", "--dangerously-skip-permissions-check"]

@app.route('/chat', methods=['POST'])
def chat():
    """Handle chat messages"""
    data = request.json
    message = data.get('message', '')
    process_id = data.get('processId', str(time.time()))
    
    # Start processing in background
    thread = threading.Thread(
        target=process_message,
        args=(message, process_id)
    )
    thread.start()
    
    return jsonify({'status': 'processing', 'processId': process_id})

@app.route('/interrupt', methods=['POST'])
def interrupt():
    """Interrupt active process"""
    data = request.json
    process_id = data.get('processId')
    
    if process_id in active_processes:
        proc = active_processes[process_id]
        try:
            # Send interrupt signal
            os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
            active_processes.pop(process_id, None)
            broadcast_message({
                'type': 'error',
                'message': 'Process interrupted by user'
            })
            return jsonify({'status': 'interrupted'})
        except:
            pass
    
    return jsonify({'status': 'not_found'})

@app.route('/events')
def events():
    """Server-sent events endpoint"""
    def generate():
        # Send initial connection
        yield f"data: {json.dumps({'type': 'connected'})}\n\n"
        
        # Keep connection alive
        while True:
            try:
                # Check for messages
                message = message_queue.get(timeout=30)
                yield f"data: {json.dumps(message)}\n\n"
            except queue.Empty:
                # Send heartbeat
                yield f"data: {json.dumps({'type': 'heartbeat'})}\n\n"
    
    return Response(
        generate(),
        mimetype='text/event-stream',
        headers={
            'Cache-Control': 'no-cache',
            'X-Accel-Buffering': 'no'
        }
    )

def process_message(message, process_id):
    """Process message through Claude CLI"""
    try:
        # Notify thinking
        broadcast_message({'type': 'thinking'})
        
        # Create process with new process group
        proc = subprocess.Popen(
            CLAUDE_CMD,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1,
            preexec_fn=os.setsid  # Create new process group
        )
        
        active_processes[process_id] = proc
        
        # Send message to Claude
        proc.stdin.write(message + '\n')
        proc.stdin.flush()
        
        # Read response
        response_lines = []
        start_time = time.time()
        
        while True:
            # Check if process was interrupted
            if process_id not in active_processes:
                break
                
            # Read output line by line
            line = proc.stdout.readline()
            if not line:
                break
                
            response_lines.append(line.strip())
            
            # Send progress updates
            elapsed = time.time() - start_time
            if elapsed > 2:  # After 2 seconds, show progress
                broadcast_message({
                    'type': 'progress',
                    'message': f'Processing... ({int(elapsed)}s)'
                })
        
        # Clean up
        active_processes.pop(process_id, None)
        
        # Send response
        response = '\n'.join(response_lines)
        if response:
            broadcast_message({
                'type': 'response',
                'message': response
            })
        else:
            broadcast_message({
                'type': 'error',
                'message': 'No response from Claude'
            })
            
    except Exception as e:
        active_processes.pop(process_id, None)
        broadcast_message({
            'type': 'error',
            'message': f'Error: {str(e)}'
        })

def broadcast_message(message):
    """Send message to all connected clients"""
    message_queue.put(message)

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'active_processes': len(active_processes)
    })

if __name__ == '__main__':
    print("Starting Claude Chat Server on http://localhost:8080")
    print("Access the chat interface at: http://localhost:8080/realtime_chat.html")
    print("\nFor iPhone access:")
    print("1. Make sure your iPhone is on the same network")
    print("2. Find your Mac's IP: ifconfig | grep 'inet ' | grep -v 127.0.0.1")
    print("3. Access: http://YOUR_MAC_IP:8080/realtime_chat.html")
    
    # Serve static files too
    import os
    from flask import send_from_directory
    
    @app.route('/<path:path>')
    def serve_static(path):
        if os.path.exists(path):
            return send_from_directory('.', path)
        return "Not found", 404
    
    app.run(host='0.0.0.0', port=8080, threaded=True)