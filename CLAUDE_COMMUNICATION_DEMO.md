# Two Claude Instances Communicating via MCP

## The Concept

Two separate Claude CLI instances can communicate through Supabase MCP, demonstrating:
- **Autonomous agent coordination**
- **Persistent message passing**
- **Exponential capabilities through server integration**

## How It Works

### Terminal 1: Claude Instance 1
```bash
cd ~/Projects/DataSenderApp
./setup_mcp_communication.sh
```

Then in Claude:
```
# Send message to Instance 2
> Use MCP Supabase to insert a message with content "[CLAUDE_1] Hello Instance 2, can you process task X?"

# Check for responses
> Use MCP Supabase to select messages where content contains "[CLAUDE_TWIN]"
```

### Terminal 2: Claude Instance 2  
```bash
cd ~/Projects/DataSenderApp_Twin
claude --dangerously-skip-permissions-check
```

Then in Claude:
```
# Check for messages from Instance 1
> Use MCP Supabase to select messages where content contains "[CLAUDE_1]"

# Send response
> Use MCP Supabase to insert a message with content "[CLAUDE_TWIN] Task X completed, results stored in 'task_x_results' table"
```

## What This Demonstrates

1. **Distributed Processing**: Two Claudes can divide work
2. **Persistent Communication**: Messages survive session restarts
3. **Queryable History**: Can search all past communications
4. **Scalable Architecture**: Could expand to N instances

## Example Use Cases

### 1. Research Assistant + Code Writer
- Instance 1: Researches best practices
- Instance 2: Implements based on research
- Communication through Supabase

### 2. Monitor + Responder
- Instance 1: Monitors data changes
- Instance 2: Takes actions based on alerts
- Async, persistent communication

### 3. Planner + Executor
- Instance 1: Creates detailed plans
- Instance 2: Executes plans step by step
- Progress tracked in Supabase

## The MCP-First Difference

**Without MCP** (primitive approach):
- Write to local file
- Hope other instance reads it
- No persistence
- No querying
- Single machine only

**With MCP** (exponential approach):
- Write to Supabase
- Guaranteed delivery
- Full SQL queries
- Works across networks
- Enables true autonomous agents

## Try It Yourself

1. Open two terminals
2. Start Claude in each with MCP config
3. Have them communicate through Supabase
4. Watch autonomous coordination happen!

This is the future - not single CLI instances, but orchestrated networks of Claude agents working together through MCP servers.