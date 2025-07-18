#!/usr/bin/env python3
"""Simple bridge between web interface and Claude CLI"""

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import subprocess
import json

app = Flask(__name__)
CORS(app)

@app.route('/')
def index():
    return send_from_directory('.', 'realtime_chat.html')

@app.route('/<path:path>')
def serve_static(path):
    return send_from_directory('.', path)

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    message = data.get('message', '')
    
    # For now, just echo back
    # In real version, would pipe to Claude CLI
    return jsonify({'status': 'received', 'message': message})

@app.route('/events')
def events():
    def generate():
        yield f"data: {json.dumps({'type': 'connected'})}\n\n"
    
    from flask import Response
    return Response(generate(), mimetype='text/event-stream')

if __name__ == '__main__':
    print("\n🚀 Server running at:")
    print(f"   Local: http://localhost:8080/realtime_chat.html")
    print(f"   Network: http://192.168.0.116:8080/realtime_chat.html")
    print("\nAccess from iPhone using the Network URL")
    
    app.run(host='0.0.0.0', port=8080)