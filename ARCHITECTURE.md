# Architecture Overview

## What This Is

A web application that enables real-time text streaming between a browser-based frontend and Claude CLI running as a subprocess on your Mac.

## Technology Stack

### Frontend (realtime_chat.html)
- **Technology**: Vanilla HTML/CSS/JavaScript (no frameworks)
- **Communication**: WebSocket or Server-Sent Events (SSE) for real-time updates
- **Features**:
  - Real-time status indicators (connected/thinking/error)
  - Visual feedback during processing (animated dots, progress bars)
  - Interrupt capability for long-running processes
  - Mobile-responsive design

### Backend (simple_server.py)
- **Technology**: Python standard library only (no external dependencies)
- **Key Components**:
  - `subprocess.Popen()` - Spawns Claude CLI as a child process
  - Message queues - For bidirectional communication
  - Threading - Handles concurrent I/O operations
  - `http.server` - Built-in HTTP server
  - CORS enabled - Allows cross-origin requests

### Communication Flow

```
1. User Input (Browser)
      ↓
2. HTTP POST Request
      ↓
3. Python Server Receives Message
      ↓
4. Server writes to Claude CLI's stdin
      ↓
5. Claude CLI processes input
      ↓
6. Server reads from Claude CLI's stdout
      ↓
7. WebSocket/SSE pushes response to browser
      ↓
8. Browser displays response with status
```

## How It Works

### Starting the Application
1. `./start_server.sh` launches the Python backend server
2. Server starts on port 8080 (accessible on local network)
3. Server spawns Claude CLI subprocess
4. WebSocket/SSE connection established with browser

### Message Flow
1. User types in browser text area
2. JavaScript sends POST to `/chat` endpoint
3. Python server queues message
4. Message written to Claude CLI's stdin pipe
5. Server monitors Claude's stdout for responses
6. Responses streamed back to browser in real-time

### Key Design Decisions

**Why subprocess?**
- Direct access to Claude CLI's full capabilities
- No API keys or rate limits (using $250/month subscription)
- Can interrupt/kill process if needed

**Why WebSocket/SSE?**
- Real-time bidirectional communication
- Shows Claude's "thinking" process
- Enables interrupt functionality

**Why no external dependencies?**
- Zero installation friction
- Uses Python's built-in http.server
- Good subprocess handling
- SSE support with standard library

## File Structure

```
DataSenderApp/
├── realtime_chat.html    # Frontend web interface
├── simple_server.py      # Backend Python server (no dependencies)
├── start_server.sh       # Launch script
├── auto_commit.sh        # Git automation (separate concern)
├── ARCHITECTURE.md       # This file
├── README.md            # Quick start guide
└── CLAUDE.md            # Project notes
```

## Requirements

- Python 3 (standard library only - no pip install needed)
- Claude CLI installed and accessible
- Modern web browser
- Port 8080 available

## Security Notes

- No authentication (bootstrap phase)
- Server binds to 0.0.0.0 (network accessible)
- Subprocess has full system access
- Intended for local development only

## Standard Web Development Terminology

- **Web App/Web Application** - The entire system
- **Frontend** - Browser-based user interface (HTML/JS/CSS)
- **Backend** - Server-side application (Python/Flask)
- **API Endpoint** - URL paths like `/chat` that accept requests
- **WebSocket** - Protocol for real-time bidirectional communication
- **SSE (Server-Sent Events)** - One-way real-time updates from server
- **Subprocess** - Child process (Claude CLI) managed by parent (Python)
- **stdin/stdout** - Standard input/output streams for process communication

This architecture provides a clean separation between the user interface and the Claude CLI processing, with a Python server acting as the bridge between them.

## Future Enhancement: Multi-Agent Toggle

A natural evolution of this architecture is to support multiple agents with different specializations:

### Use Case
Currently, users often consult with one AI (like ChatGPT) for planning/architecture, then manually copy-paste to Claude CLI for implementation. This creates friction.

### Proposed Solution
Run two Claude CLI instances as separate subprocesses, each with a different role:

```
Frontend Web App
    ↓        ↓
Backend Server
    ↓        ↓
Claude 1   Claude 2
(Consultant) (Coder)
```

### Implementation Concept
```python
# Two separate Claude instances
claude_consultant = subprocess.Popen(['claude'], ...)
claude_coder = subprocess.Popen(['claude'], ...)

# Route based on mode
if mode == 'consultant':
    claude_consultant.stdin.write(message)
else:
    claude_coder.stdin.write(message)

# Transfer between agents
def send_to_coder():
    last_response = consultant_queue.get_last()
    claude_coder.stdin.write(f"Implement this: {last_response}")
```

### UI Changes Needed
- Mode toggle: [Consultant] [Coder]
- "Send to Coder →" button
- Different visual themes per mode
- Optional split-view for both conversations

### Benefits
- Eliminates copy-paste friction
- Each agent can be prompted for its specialty
- Same infrastructure, minimal new code
- Solves real workflow problem

This can be implemented with current architecture - no MCP or complex protocols needed.