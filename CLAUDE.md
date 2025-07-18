# DataSenderApp Project Conventions

## PROJECT VISION: Agent Bootstrap System
This Mac + Claude Code CLI setup is a proof-of-concept for an autonomous AI agent. It demonstrates:
- Central intelligence hub with code execution capability
- Instantaneous bidirectional communication
- Persistent memory and state preservation
- The type of agent we're ultimately building at scale

See AGENT_VISION.md for complete autonomous agent roadmap.

## Auto-Commit System
This project includes an automatic commit system (`auto_commit.sh`) that:
- **Watches for file changes** and commits after 5 seconds of inactivity
- **Pushes to GitHub** every 30 minutes
- **Performance optimized**: Uses minimal CPU with fswatch
- **Prevents duplicates** with lockfile at `/tmp/datasenderapp-autocommit.lock`
- **Logs output** to /tmp/datasenderapp-autocommit.log

### Starting Auto-Commit
**Currently running!** The auto-commit system is active and monitoring changes.

**Manual start** (if needed):
```bash
cd ~/Projects/DataSenderApp
./auto_commit.sh > /tmp/datasenderapp-autocommit.log 2>&1 &
```

**Check status**:
```bash
ps aux | grep fswatch | grep -v grep
tail -f /tmp/datasenderapp-autocommit.log
```

**Note**: Auto-start from .zshrc disabled to prevent conflicts. LaunchAgent available but manual start recommended.

## Primary Interface: Real-time Web Chat
- **Start server**: `./start_server.sh`
- **Local access**: http://localhost:8080/realtime_chat.html
- **iPhone access**: http://YOUR_MAC_IP:8080/realtime_chat.html
- **Features**: Real-time status, visual feedback, interrupt capability
- **Voice input**: Mac Accessibility → Voice Control

## Project Structure
- **Web interfaces**: HTML files for data capture
- **Backend/**: Server and storage integration
- **Auto-versioning**: Git commits via fswatch
- **Documentation**: Architecture, vision, and guides

## Environment & Security
- **Never commit real tokens**: Always use `.env` file for sensitive credentials
- **Use .env & .gitignore**: Environment variables must be loaded from `.env` file
- **Required env vars**:
  - `SUPABASE_URL`
  - `SUPABASE_KEY`
  - `SUPABASE_ACCESS_TOKEN`
  - `SUPABASE_PROJECT_REF`
  - `GITHUB_TOKEN`

## Supabase Integration
- **Primary data store**: All inputs go to Supabase first
- **Project reference**: `xvxyzmldrqewigrrccea`
- **MCP integration**: Direct database operations via Claude
- **Tables**: `texts` table for all captured data
- **Future**: Vector embeddings and processing pipeline

## Development Practices
- **Real-time feedback**: Every action has visual response
- **Interrupt capability**: Can stop long-running processes
- **Voice-first**: Optimize for speech input
- **Instant saves**: Auto-commit captures everything

## Agent Capabilities
- **Code execution**: Direct file system access via MCP
- **Memory persistence**: Context preserved in CLAUDE.md
- **State building**: Working towards persistent personality
- **Autonomous actions**: Can complete complex tasks independently

## Future Pipeline
- **Vector DB**: Pinecone for semantic search
- **Embeddings**: OpenAI for understanding
- **Processing**: Fireworks, Modal, Anyscale
- **Goal**: Fully autonomous cloud agent

## Git Workflow
- **Main branch**: Primary development branch
- **Feature branches**: Create branches for new features
- **Commit messages**: Clear and descriptive
- **Never commit .env**: Already in .gitignore

## Data Flow
- **Input**: Voice/text via web interface
- **Bridge**: Local server to Claude CLI
- **Storage**: Supabase with metadata
- **Versioning**: Git auto-commits
- **Future**: Processing pipeline for AI

## Key Files
- `realtime_chat.html`: Primary web interface with instant feedback
- `chat_server.py`: Local bridge server for Claude CLI integration
- `auto_commit.sh`: Automatic versioning system
- `AGENT_VISION.md`: Complete vision for autonomous agent system
- `ARCHITECTURE.md`: Technical system design
- `.env`: Environment configuration (never commit)