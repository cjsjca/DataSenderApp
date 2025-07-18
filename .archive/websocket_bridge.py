#!/usr/bin/env python3
"""
WebSocket bridge - Real-time bidirectional communication
Browser <-> Claude CLI
"""

import asyncio
import websockets
import subprocess
import json
import threading
import queue

# Global queues
to_claude = queue.Queue()
from_claude = queue.Queue()

class ClaudeBridge:
    def __init__(self):
        self.claude_process = None
        self.clients = set()
        
    async def handle_client(self, websocket, path):
        """Handle WebSocket connection from browser"""
        self.clients.add(websocket)
        try:
            async for message in websocket:
                data = json.loads(message)
                
                if data['type'] == 'message':
                    # Send to Claude
                    to_claude.put(data['content'])
                    
                    # Notify all clients
                    await self.broadcast({
                        'type': 'user_message',
                        'content': data['content']
                    })
                    
        finally:
            self.clients.remove(websocket)
    
    async def broadcast(self, data):
        """Send to all connected clients"""
        if self.clients:
            await asyncio.gather(
                *[client.send(json.dumps(data)) for client in self.clients]
            )
    
    def run_claude(self):
        """Run Claude CLI in subprocess"""
        self.claude_process = subprocess.Popen(
            ['claude'],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1
        )
        
        # Read thread
        def read_output():
            for line in iter(self.claude_process.stdout.readline, ''):
                if line:
                    from_claude.put({
                        'type': 'claude_response',
                        'content': line.strip()
                    })
        
        threading.Thread(target=read_output, daemon=True).start()
        
        # Write thread
        def write_input():
            while True:
                message = to_claude.get()
                self.claude_process.stdin.write(message + '\n')
                self.claude_process.stdin.flush()
        
        threading.Thread(target=write_input, daemon=True).start()
    
    async def claude_output_handler(self):
        """Send Claude output to browsers"""
        while True:
            try:
                # Check for Claude output
                data = from_claude.get_nowait()
                await self.broadcast(data)
            except queue.Empty:
                await asyncio.sleep(0.1)

async def main():
    bridge = ClaudeBridge()
    
    # Start Claude
    bridge.run_claude()
    
    # Start WebSocket server
    async with websockets.serve(bridge.handle_client, "localhost", 8765):
        print("🚀 WebSocket bridge running on ws://localhost:8765")
        print("🌐 Connect from browser to communicate with Claude CLI")
        
        # Handle Claude output
        await bridge.claude_output_handler()

if __name__ == "__main__":
    asyncio.run(main())