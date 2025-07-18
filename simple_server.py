#!/usr/bin/env python3
"""
Simple backend server for DataSenderApp
No external dependencies - uses only Python standard library
"""

import http.server
import socketserver
import subprocess
import json
import threading
import queue
import time
from urllib.parse import parse_qs

# Message queues
to_claude = queue.Queue()
from_claude = queue.Queue()

# Claude process
claude_process = None

def run_claude():
    """Run Claude CLI and handle I/O"""
    global claude_process
    
    try:
        # Start Claude CLI
        claude_process = subprocess.Popen(
            ['claude'],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1
        )
        
        print("Claude CLI started successfully")
        
        # Monitor output in separate thread
        def read_output():
            while claude_process and claude_process.poll() is None:
                line = claude_process.stdout.readline()
                if line:
                    from_claude.put({'type': 'response', 'message': line.strip()})
        
        output_thread = threading.Thread(target=read_output)
        output_thread.daemon = True
        output_thread.start()
        
        # Process input
        while claude_process and claude_process.poll() is None:
            try:
                message = to_claude.get(timeout=0.1)
                claude_process.stdin.write(message + '\n')
                claude_process.stdin.flush()
                from_claude.put({'type': 'status', 'message': 'thinking'})
            except queue.Empty:
                pass
                
    except Exception as e:
        print(f"Error running Claude: {e}")
        from_claude.put({'type': 'error', 'message': str(e)})

class ChatHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.path = '/realtime_chat.html'
        elif self.path == '/events':
            # Server-Sent Events for real-time updates
            self.send_response(200)
            self.send_header('Content-Type', 'text/event-stream')
            self.send_header('Cache-Control', 'no-cache')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            # Send updates
            while True:
                try:
                    data = from_claude.get(timeout=1)
                    event = f"data: {json.dumps(data)}\n\n"
                    self.wfile.write(event.encode())
                    self.wfile.flush()
                except queue.Empty:
                    # Send heartbeat
                    self.wfile.write(b"data: {\"type\": \"heartbeat\"}\n\n")
                    self.wfile.flush()
                except:
                    break
            return
        
        return super().do_GET()
    
    def do_POST(self):
        if self.path == '/chat':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data)
            
            message = data.get('message', '')
            print(f"Received: {message}")
            
            # Queue message for Claude
            to_claude.put(message)
            
            # Send response
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {'status': 'queued'}
            self.wfile.write(json.dumps(response).encode())
    
    def do_OPTIONS(self):
        # Handle CORS preflight
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

if __name__ == '__main__':
    PORT = 8080
    
    # Start Claude in background thread
    claude_thread = threading.Thread(target=run_claude)
    claude_thread.daemon = True
    claude_thread.start()
    
    # Give Claude a moment to start
    time.sleep(2)
    
    # Start web server
    with socketserver.TCPServer(("", PORT), ChatHandler) as httpd:
        print(f"\n🚀 DataSenderApp Backend Server")
        print(f"📍 Local: http://localhost:{PORT}")
        print(f"📱 Network: http://YOUR_IP:{PORT}")
        print(f"\n✨ Claude CLI integration active")
        print(f"🌐 Open http://localhost:{PORT} in your browser\n")
        
        httpd.serve_forever()