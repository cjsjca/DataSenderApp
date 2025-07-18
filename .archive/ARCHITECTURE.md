# DataSenderApp System Architecture

## Overview
A bootstrapping prototype for an autonomous AI agent system with persistent memory and state, focused on frictionless text streaming and instantaneous feedback loops.

## Current Architecture (Bootstrap Phase)

```
iPhone/Desktop → Web Interface → Local Server → Claude CLI (MCP) → Supabase
                                                         ↓
                                              Processing Pipeline (Future)
```

### Components

1. **Data Ingestion Layer**
   - `realtime_chat.html` - Primary web interface with real-time feedback
   - `simple_send.html` - Quick text input
   - `photo_upload.html` - Image uploads
   - Voice input via Mac accessibility settings

2. **Local Bridge Server** (`chat_server.py`)
   - Flask server running on Mac (port 8080)
   - WebSocket/SSE for real-time status
   - Process management and interrupts
   - Direct Claude CLI integration

3. **Claude CLI + MCP**
   - Runs on Mac with `--dangerously-skip-permissions-check`
   - MCP tools for Supabase and GitHub integration
   - Code execution capabilities
   - Direct file system access

4. **Storage Layer**
   - **Supabase** - Raw data collection point
   - All messages tagged with source (`[REALTIME_CHAT]`, `[TERMINAL]`, etc.)
   - Metadata includes timestamp, device, session info

5. **Version Control**
   - `auto_commit.sh` - fswatch-based auto-commit system
   - Commits after 5s of inactivity
   - Pushes every 30 minutes
   - Provides instant snapshots without workflow interruption

## Future Architecture (Production Vision)

```
                    ┌─────────────────┐
                    │   Web Interface  │
                    │  (iPhone/Desktop)│
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Cloud Gateway   │
                    │  (Edge Function) │
                    └────────┬────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
       ┌────────▼────────┐      ┌────────▼────────┐
       │    Supabase     │      │  Vector Store   │
       │  (Raw Storage)  │      │   (Pinecone)    │
       └────────┬────────┘      └────────┬────────┘
                │                         │
       ┌────────▼─────────────────────────▼────────┐
       │          Processing Pipeline              │
       │  • OpenAI Embeddings                      │
       │  • Fireworks LLM                          │
       │  • Modal (compute)                        │
       │  • Anyscale (orchestration)               │
       └────────┬──────────────────────────────────┘
                │
       ┌────────▼────────┐
       │  Persistent AI   │
       │  • Memory (facts)│
       │  • State (personality)│
       │  • Context preservation│
       └─────────────────┘
```

## Key Design Principles

1. **Everything is Text**
   - All data normalized to text for processing
   - Voice → text via accessibility
   - Images → descriptions/embeddings

2. **Supabase First**
   - Guaranteed capture before processing
   - No data loss, even if processing fails
   - Enables replay and reprocessing

3. **Instantaneous Feedback**
   - Real-time status indicators
   - Progress updates for long operations
   - Interrupt capability
   - Sub-second response initiation

4. **Persistent Memory vs State**
   - **Memory**: Facts, conversations, learned information (CLAUDE.md)
   - **State**: Personality, relationship context, behavioral patterns
   - Both preserved across sessions

## Server Options Analysis

### Option 1: Local Mac Server (Current)
**Pros:**
- Direct MCP access
- Zero latency to Claude CLI
- Full filesystem access
- Easy development

**Cons:**
- Mac must be running
- Network/firewall configuration
- No remote access without tunneling

### Option 2: Cloud + Local Hybrid (Recommended)
**Architecture:**
```
Cloud Gateway → Message Queue → Local Mac (when online)
                     ↓
              Offline Processing
```

**Implementation:**
- Vercel/Railway for gateway
- Redis/Supabase for queue
- Local server polls queue
- Fallback to async processing

### Option 3: Full Cloud (Future)
**Requirements:**
- Cloud-based code execution (Modal)
- MCP bridge or alternative
- Distributed file storage
- Higher complexity but full availability

## Getting Started

1. **Start Local Server:**
   ```bash
   ./start_server.sh
   ```

2. **Access from iPhone:**
   - Connect to same WiFi
   - Open: `http://YOUR_MAC_IP:8080/realtime_chat.html`

3. **Voice Input (Mac):**
   - System Preferences → Accessibility → Voice Control
   - Enable dictation in web interface

## Security Considerations

- Local server binds to 0.0.0.0 (network accessible)
- No authentication (bootstrap phase)
- HTTPS recommended for production
- Supabase API keys in frontend (use RLS in production)

## Performance Optimizations

- WebSocket preferred over polling
- Message batching for Supabase
- Local caching for offline capability
- Progressive enhancement for slow connections

## Next Steps

1. Implement message queue for offline capability
2. Add authentication layer
3. Build vector embedding pipeline
4. Create persistent state serialization
5. Develop conversational modules (calendar, tasks, etc.)