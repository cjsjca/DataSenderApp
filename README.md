# DataSenderApp - CLI Data Ingestion System

A text-based data ingestion pipeline that sends everything to Supabase for persistent storage and AI processing.

## Architecture

```
iPhone (Termius SSH) → Mac (Claude CLI) → Supabase → Processing Pipeline
```

## Core Components

### 1. Terminal Chat Interface
- `terminal_chat.py` - Fast CLI chat that sends messages to Supabase
- `claude_listener.py` - Helper for monitoring messages

### 2. Web Interfaces (for browser access)
- `simple_send.html` - Basic text input
- `brain_input.html` - Stream of consciousness capture  
- `workout_logger.html` - Workout tracking
- `simple_chat.html` - Chat interface
- `photo_upload.html` - Photo uploader

### 3. MCP Integration
- Supabase MCP for database operations
- GitHub MCP for version control (when needed)
- Configuration in `Backend/MCP/.mcp.json`

### 4. Persistent Memory
- `CLAUDE.md` provides context persistence across Claude CLI sessions
- Run Claude CLI from this directory to maintain memory

## Usage

### Local Terminal
```bash
python3 terminal_chat.py
```

### Remote Access (via Termius)

#### Option 1: Terminal Chat (Always Works)
1. SSH into your Mac
2. Navigate to project: `cd ~/Projects/DataSenderApp`
3. Run: `python3 terminal_chat.py`

#### Option 2: Claude CLI via tmux (Uses Subscription)
1. **First time setup** (on Mac Terminal):
   ```bash
   cd ~/Projects/DataSenderApp
   ./claude_tmux.sh start  # Start authenticated session
   ```

2. **From Termius SSH**:
   ```bash
   cd ~/Projects/DataSenderApp
   ./claude_ssh.sh  # Attaches to existing session
   ```

3. **Detach without closing**: Press `Ctrl+B` then `D`
4. **Your subscription remains active** - no API charges!

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

### Quick Snapshots (alternative)
```bash
python3 snapshot.py  # Snapshots key files to Supabase
```

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
├── Backend/
│   └── MCP/
│       └── .mcp.json       # MCP configuration
├── terminal_chat.py        # Main CLI interface
├── claude_listener.py      # Message monitoring
├── snapshot.py            # Version snapshots
├── supabase_setup.sql     # Database schema
├── *.html                 # Web interfaces
├── CLAUDE.md              # Persistent memory
└── README.md              # This file
```

## Philosophy

- **Everything is text** - Simple, searchable, processable
- **Supabase first** - Guaranteed capture before processing
- **No complex sync** - Direct terminal → database flow
- **Version via snapshots** - Not git commits
- **CLI-centric** - Terminal is the primary interface

## Remote Setup

1. Enable SSH on Mac: System Settings → Sharing → Remote Login
2. Note your Mac's IP address or hostname
3. Install Termius on iPhone
4. Add Mac as host in Termius
5. SSH in and run terminal_chat.py

## Future Pipeline

Once text is in Supabase, background processes can:
- Send to LLMs for understanding
- Generate vector embeddings
- Route to specialized databases
- Build temporal knowledge graphs
- Create automated summaries

But the core principle remains: **capture first, process later**.