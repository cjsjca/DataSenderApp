# DataSenderApp - AI Agent Bootstrap System

**🚨 FOR CLAUDE: If you're reading this after context loss/compaction, STOP and read CRITICAL_STATE_CAPTURE.md first! It contains your bootstrap instructions. 🚨**

A prototype system for building an autonomous AI agent with persistent memory and state, focused on frictionless text streaming and instantaneous feedback loops.

## Quick Start

```bash
# Start the real-time chat server
./start_server.sh

# Access from browser
http://localhost:8080/realtime_chat.html

# Access from iPhone (same network)
http://YOUR_MAC_IP:8080/realtime_chat.html
```

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed system design.

**Current Flow:**
```
Voice/Text → Web Interface → Local Server → Claude CLI → Supabase
                  ↓              ↓
            Real-time       Code Execution
            Feedback          via MCP
```

## Core Components

### 1. Real-time Chat Interface
- `realtime_chat.html` - Primary interface with instant feedback
- WebSocket/SSE for live status updates
- Visual thinking indicators and progress bars
- Process interruption capability
- Voice input via Mac accessibility settings

### 2. Local Bridge Server
- `chat_server.py` - Flask server bridging web to Claude CLI
- Real-time status streaming
- Process management and interrupts
- Direct MCP tool access

### 3. Auto-Commit System
- `auto_commit.sh` - Lightweight fswatch-based versioning
- Commits after 5s of inactivity
- Pushes every 30 minutes
- Zero workflow interruption

### 4. Web Interfaces
- `brain_chat.html` - Chat with file-based bridge
- `simple_send.html` - Quick text input
- `photo_upload.html` - Image uploads
- `workout_logger.html` - Specialized tracking

### 5. MCP Integration
- Supabase MCP for database operations
- GitHub MCP for version control
- Direct code execution capabilities
- Configuration in `Backend/MCP/.mcp.json`

### 6. Persistent Memory
- `CLAUDE.md` provides context persistence
- Auto-versioning captures all changes
- Building towards persistent AI state

### 7. Claude Twins (MCP Communication Demo)
- `claude_twins/` - Multiple Claude instances that communicate via MCP
- Demonstrates exponential power of MCP servers
- Shows distributed agent coordination
- Run: `cd claude_twins/instance_1` and `cd claude_twins/instance_2` in separate terminals

## Usage

### Primary Interface - Real-time Web Chat

1. **Start the server**:
   ```bash
   ./start_server.sh
   ```

2. **Access from Mac**:
   - Open: http://localhost:8080/realtime_chat.html
   - Use voice input via Accessibility settings
   - Watch real-time status indicators

3. **Access from iPhone**:
   - Connect to same WiFi network
   - Find Mac's IP: `ifconfig | grep 'inet ' | grep -v 127.0.0.1`
   - Open: http://YOUR_MAC_IP:8080/realtime_chat.html
   - Add to Home Screen for app-like experience

### Direct Claude CLI Access

For advanced users who need terminal access:
```bash
cd ~/Projects/DataSenderApp
claude --dangerously-skip-permissions-check
```

### Automatic Versioning System

**Lightweight fswatch + Git auto-commit** runs in the background to capture all changes:

```bash
# Start the auto-commit watcher
./auto_commit.sh

# What it does:
# - Watches all file changes using fswatch (near-zero CPU)
# - Commits after 5 seconds of inactivity
# - Pushes to GitHub every 30 minutes
# - Captures even rapid changes during fast coding
```

**Why this matters**: Claude works extremely fast - potentially 100+ file changes in 30 minutes. This system ensures nothing is lost between manual saves.

**Recovery commands**:
```bash
# See recent changes
git log --oneline -20

# Restore a file from 10 commits ago
git checkout HEAD~10 -- filename

# See what changed 5 commits ago
git show HEAD~5
```

### Voice Input Setup (Mac)

1. System Preferences → Accessibility → Voice Control
2. Enable Voice Control
3. Click in web chat input field
4. Speak naturally - text appears in real-time
5. Say "press enter" or click Send

## Database Schema

All data flows into the `texts` table:
- `id` - UUID
- `content` - Text content
- `created_at` - Timestamp
- `metadata` - JSON (optional)

## Data Flow

1. **Input** - Terminal, web browser, or SSH
2. **Capture** - Python scripts send to Supabase
3. **Storage** - PostgreSQL with timestamps
4. **Processing** - Background workers can:
   - Generate embeddings
   - Extract entities
   - Route to other services
   - Build knowledge graph

## Project Structure

```
DataSenderApp/
├── claude_twins/          # Twin Claude instances for MCP demos
│   ├── instance_1/        # First Claude with MCP config
│   ├── instance_2/        # Second Claude with MCP config
│   └── run_twins.sh       # Launch helper script
├── Backend/
│   └── MCP/
│       └── .mcp.json      # MCP configuration template
├── Web Interfaces/
│   ├── realtime_chat.html # Primary chat with status
│   ├── direct_chat.html   # Direct to Supabase
│   └── *.html             # Other input interfaces
├── MCP-First Docs/
│   ├── MCP_FIRST.md       # Paradigm shift documentation
│   ├── AGENT_VISION.md    # Autonomous agent vision
│   └── PERSISTENT_STATE.md # State persistence design
├── Core Scripts/
│   ├── auto_commit.sh     # Git auto-versioning
│   ├── quick_send.py      # Fast message sender
│   └── claude_mcp_wrapper.py # MCP-first wrapper
├── CLAUDE.md              # Persistent memory/context
└── README.md              # This file
```

## Key Features

1. **Instantaneous Feedback Loop**
   - Real-time status indicators (connected, thinking, error)
   - Visual progress for long operations
   - Animated thinking indicators
   - Interrupt capability for runaway processes

2. **Persistent Memory & State**
   - CLAUDE.md for project context
   - Auto-versioning for safety
   - Building towards AI with personality
   - Session continuity across reconnects

3. **Voice-First Design**
   - Mac Voice Control integration
   - Natural speech input
   - Frictionless thought capture
   - No typing required

## Philosophy

- **Everything is text** - Voice, images, code all normalized
- **Supabase first** - Guaranteed capture before processing
- **Instantaneous feedback** - Every action has visual response
- **Persistent state** - Building AI with memory AND personality
- **Frictionless capture** - Thought to storage in milliseconds

## Future Vision

**Processing Pipeline:**
```
Supabase → Vector DB (Pinecone) → Embeddings (OpenAI)
    ↓
Autonomous Agents (Fireworks, Modal, Anyscale)
    ↓
Persistent AI with State + Memory
```

**Planned Features:**
- Conversational calendar integration
- Task management with context awareness
- Learned behavioral patterns
- Multi-device state synchronization
- Offline queue with smart retry
- Cloud deployment for anywhere access

## Development Tools

```bash
# Monitor auto-commits
tail -f /tmp/datasenderapp-autocommit.log

# Check server health
curl http://localhost:8080/health

# Manual git push
./push_now.sh

# View recent auto-commits
git log --oneline -10
```

## Security Notes

- Local server is network-accessible (0.0.0.0:8080)
- No authentication in bootstrap phase
- Supabase keys in frontend (use RLS for production)
- HTTPS recommended for remote access