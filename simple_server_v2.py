#!/usr/bin/env python3
"""
Simple backend server for DataSenderApp - Version 2
Improved Claude CLI integration with better I/O handling
"""

import http.server
import socketserver
import subprocess
import json
import threading
import queue
import time
import sys
import select
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
            stderr=subprocess.STDOUT,  # Combine stderr with stdout
            text=True,
            bufsize=0  # Unbuffered
        )
        
        print("Claude CLI started successfully", flush=True)
        from_claude.put({'type': 'status', 'message': 'connected'})
        
        # Read initial output
        initial_output = ""
        while True:
            # Use select to check if data is available
            ready, _, _ = select.select([claude_process.stdout], [], [], 0.1)
            if ready:
                char = claude_process.stdout.read(1)
                if char:
                    initial_output += char
                    if char == '\n' or len(initial_output) > 1000:
                        break
            else:
                break
        
        if initial_output:
            print(f"Claude initial output: {initial_output.strip()}", flush=True)
            from_claude.put({'type': 'response', 'message': initial_output.strip()})
        
        # Monitor output in separate thread
        def read_output():
            buffer = ""
            while claude_process and claude_process.poll() is None:
                try:
                    # Read character by character for better responsiveness
                    ready, _, _ = select.select([claude_process.stdout], [], [], 0.1)
                    if ready:
                        char = claude_process.stdout.read(1)
                        if char:
                            buffer += char
                            # Send on newline or when buffer gets large
                            if char == '\n' or len(buffer) > 100:
                                if buffer.strip():
                                    print(f"Claude output: {buffer.strip()}", flush=True)
                                    from_claude.put({'type': 'response', 'message': buffer.strip()})
                                buffer = ""
                except Exception as e:
                    print(f"Error reading output: {e}", flush=True)
        
        output_thread = threading.Thread(target=read_output)
        output_thread.daemon = True
        output_thread.start()
        
        # Process input
        while claude_process and claude_process.poll() is None:
            try:
                message = to_claude.get(timeout=0.1)
                print(f"Sending to Claude: {message}", flush=True)
                claude_process.stdin.write(message + '\n')
                claude_process.stdin.flush()
                from_claude.put({'type': 'status', 'message': 'thinking'})
            except queue.Empty:
                pass
                
    except Exception as e:
        print(f"Error running Claude: {e}", flush=True)
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
            
            print("Client connected to /events", flush=True)
            
            # Send updates
            while True:
                try:
                    data = from_claude.get(timeout=30)  # 30 second timeout
                    event = f"data: {json.dumps(data)}\n\n"
                    self.wfile.write(event.encode())
                    self.wfile.flush()
                except queue.Empty:
                    # Send heartbeat
                    self.wfile.write(b"data: {\"type\": \"heartbeat\"}\n\n")
                    self.wfile.flush()
                except Exception as e:
                    print(f"SSE error: {e}", flush=True)
                    break
            return
        
        return super().do_GET()
    
    def do_POST(self):
        if self.path == '/chat':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data)
            
            message = data.get('message', '')
            print(f"Received from client: {message}", flush=True)
            
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
    
    def log_message(self, format, *args):
        # Override to add flush
        sys.stderr.write("%s - - [%s] %s\n" %
                         (self.address_string(),
                          self.log_date_time_string(),
                          format%args))
        sys.stderr.flush()

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
        print(f"\n🚀 DataSenderApp Backend Server v2")
        print(f"📍 Local: http://localhost:{PORT}")
        print(f"📱 Network: http://YOUR_IP:{PORT}")
        print(f"\n✨ Claude CLI integration active")
        print(f"🌐 Open http://localhost:{PORT} in your browser\n")
        sys.stdout.flush()
        
        httpd.serve_forever()