# Claude Web Interface with MCP Support

A web interface for interacting with Claude CLI using the Model Context Protocol (MCP) for stateful sessions on macOS.

## Prerequisites

- macOS (tested on macOS 12+)
- Node.js 18+ (`brew install node`)
- Claude CLI installed and authenticated with Pro/Max subscription
- No raw API keys or Docker required

## Setup Instructions

### 1. Start the MCP Server

First, start the MCP server that will handle stateful Claude sessions:

```bash
claude mcp serve --transport http --port 9090 --dangerously-skip-permissions
```

Keep this terminal open - the MCP server needs to stay running.

### 2. Register MCP Endpoints

In a new terminal, register two endpoints for different purposes:

```bash
# Register design-server endpoint for architectural/planning discussions
claude mcp add --transport http design-server http://127.0.0.1:9090

# Register exec-server endpoint for code execution tasks
claude mcp add --transport http exec-server http://127.0.0.1:9090
```

### 3. Install Dependencies

Navigate to the project directory and install Node.js dependencies:

```bash
cd my-claude-web
npm install
```

### 4. Start the Web Server

```bash
npm start
```

The server will start at http://localhost:3000

## Usage

1. Open http://localhost:3000 in your browser
2. Type or paste your prompt in the text area
3. Click "Send to Claude" or press Enter
4. View the response with stateful context maintained across requests

## Architecture

- **MCP Server**: Maintains stateful Claude sessions at port 9090
- **Web Server**: Node.js/Express server that communicates with MCP
- **Frontend**: Simple HTML interface for sending prompts

## How MCP Works

The Model Context Protocol allows:
- **Stateful Sessions**: Context is maintained between requests
- **Multiple Endpoints**: Different servers for different purposes (design vs execution)
- **No API Keys**: Uses your existing Claude subscription authentication

## Troubleshooting

### "MCP server not found"
- Ensure the MCP server is running: `claude mcp serve --transport http --port 9090 --dangerously-skip-permissions`
- Check that port 9090 is not in use: `lsof -i :9090`

### "Endpoint not registered"
- Re-register the endpoints using the commands in step 2
- Verify endpoints are registered: `claude mcp list`

### "Authentication required"
- Ensure you're logged into Claude CLI: `claude login`
- The `--dangerously-skip-permissions` flag should bypass permission prompts

### Port already in use
- Web server: Change port with `PORT=3001 npm start`
- MCP server: Use a different port in both serve and add commands

## Advanced Usage

### Using Different Endpoints

By default, the web interface uses the `design-server` endpoint. To use `exec-server` instead, modify the `MCP_ENDPOINT` in server.js:

```javascript
const MCP_ENDPOINT = 'exec-server'; // Change from 'design-server'
```

### Running as a Background Service

To run the web server as a background service:

```bash
# Install PM2 globally
npm install -g pm2

# Start the service
pm2 start server.js --name claude-web

# View logs
pm2 logs claude-web

# Stop the service
pm2 stop claude-web
```

## Notes

- The MCP server must be running before starting the web server
- Sessions are stateful - Claude remembers previous messages in the conversation
- For production use, consider adding authentication to the web interface
- The `--dangerously-skip-permissions` flag is required for headless operation

## License

MIT