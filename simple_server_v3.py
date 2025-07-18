#!/usr/bin/env python3
"""
Simple backend server for DataSenderApp - Version 3
Uses Claude CLI in print mode for each message
"""

import http.server
import socketserver
import subprocess
import json
import threading
import queue
import time
import sys
from urllib.parse import parse_qs

# Message queues
from_claude = queue.Queue()

# Active processes
active_processes = {}

def process_message(message, process_id):
    """Process a single message with Claude CLI"""
    try:
        # Update status
        from_claude.put({'type': 'status', 'message': 'thinking'})
        
        # Run Claude with --print flag for single response
        proc = subprocess.Popen(
            ['claude', '--print', message],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True
        )
        
        # Store process for potential interruption
        active_processes[process_id] = proc
        
        # Read output
        output = ""
        while True:
            line = proc.stdout.readline()
            if not line:
                break
            output += line
            # Send incremental updates
            if len(output) > 50:  # Send chunks
                from_claude.put({'type': 'response', 'message': output.strip()})
                output = ""
        
        # Send final output
        if output:
            from_claude.put({'type': 'response', 'message': output.strip()})
        
        # Wait for process to complete
        proc.wait()
        
        # Clean up
        if process_id in active_processes:
            del active_processes[process_id]
            
    except Exception as e:
        print(f"Error processing message: {e}", flush=True)
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
            
            # Send initial connection status
            event = f"data: {json.dumps({'type': 'status', 'message': 'connected'})}\n\n"
            self.wfile.write(event.encode())
            self.wfile.flush()
            
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
            process_id = data.get('processId', str(time.time()))
            
            print(f"Received from client: {message}", flush=True)
            
            # Process message in background thread
            thread = threading.Thread(
                target=process_message, 
                args=(message, process_id)
            )
            thread.daemon = True
            thread.start()
            
            # Send response
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {'status': 'processing', 'processId': process_id}
            self.wfile.write(json.dumps(response).encode())
            
        elif self.path == '/interrupt':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data)
            
            process_id = data.get('processId')
            if process_id in active_processes:
                active_processes[process_id].terminate()
                del active_processes[process_id]
                print(f"Interrupted process: {process_id}", flush=True)
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {'status': 'interrupted'}
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
    PORT = 8082  # New port to avoid conflicts
    
    # Start web server
    with socketserver.TCPServer(("", PORT), ChatHandler) as httpd:
        print(f"\n🚀 DataSenderApp Backend Server v3")
        print(f"📍 Local: http://localhost:{PORT}")
        print(f"📱 Network: http://YOUR_IP:{PORT}")
        print(f"\n✨ Claude CLI in print mode (one response per message)")
        print(f"🌐 Open http://localhost:{PORT} in your browser\n")
        sys.stdout.flush()
        
        httpd.serve_forever()