#!/usr/bin/env python3
"""Simple test to see if we can connect browser to Claude"""

import subprocess
import http.server
import socketserver
import json

PORT = 8080

class TestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.path = '/realtime_chat.html'
        return super().do_GET()
    
    def do_POST(self):
        if self.path == '/chat':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data)
            
            print(f"Received: {data.get('message', '')}")
            
            # For now, just echo back
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = {'status': 'received', 'message': data.get('message', '')}
            self.wfile.write(json.dumps(response).encode())

print(f"Starting test server on http://localhost:{PORT}")
print("Open http://localhost:8080/realtime_chat.html in your browser")

with socketserver.TCPServer(("", PORT), TestHandler) as httpd:
    httpd.serve_forever()