# Claude Web Interface for macOS

A lightweight web interface for interacting with Claude CLI on macOS. This native Node.js application provides a simple browser-based UI to send prompts to your locally authenticated Claude CLI session.

## Why Native?

Running natively on macOS (without virtualization or containers) provides:
- **Minimal CPU usage** - No Linux VM overhead
- **Less heat generation** - Your Mac stays cooler
- **Direct CLI access** - Uses your existing Claude authentication
- **Fast startup** - No container initialization

## Prerequisites

- macOS (tested on macOS 12+)
- Node.js 18+ (`brew install node`)
- Claude CLI installed and authenticated
- Either:
  - An active Claude OAuth session (via `claude login`), or
  - `ANTHROPIC_API_KEY` environment variable set

## Installation

1. Clone or download this project
2. Navigate to the project directory:
   ```bash
   cd my-claude-web
   ```
3. Install dependencies:
   ```bash
   npm install
   ```

## Running the Application

### Option 1: Direct execution (foreground)

```bash
npm start
```

Then open http://localhost:3000 in your browser.

### Option 2: With environment variable

```bash
ANTHROPIC_API_KEY="your-api-key" npm start
```

### Option 3: Background service with PM2

1. Install PM2 globally:
   ```bash
   npm install -g pm2
   ```

2. Start the service:
   ```bash
   pm2 start ecosystem.config.js
   ```

3. Manage the service:
   ```bash
   pm2 status        # Check status
   pm2 logs          # View logs
   pm2 stop claude-web    # Stop service
   pm2 restart claude-web # Restart service
   pm2 delete claude-web  # Remove from PM2
   ```

4. Auto-start on boot (optional):
   ```bash
   pm2 startup
   pm2 save
   ```

### Option 4: Using launchd (macOS native)

Create a plist file at `~/Library/LaunchAgents/com.claude.web.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claude.web</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/node</string>
        <string>/path/to/my-claude-web/server.js</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>WorkingDirectory</key>
    <string>/path/to/my-claude-web</string>
</dict>
</plist>
```

Then load it:
```bash
launchctl load ~/Library/LaunchAgents/com.claude.web.plist
```

## Usage

1. Open http://localhost:3000 in your browser
2. Type or paste your prompt in the text area
3. Click "Send to Claude" or press Enter
4. View the response below

## Troubleshooting

### "Claude CLI not found"
- Ensure Claude is installed: `which claude`
- Add Claude to your PATH if needed

### "Authentication required"
- Run `claude login` to authenticate via browser
- Or set `ANTHROPIC_API_KEY` environment variable

### Port already in use
- Change the port: `PORT=3001 npm start`
- Or kill the existing process: `lsof -ti:3000 | xargs kill`

## Configuration

- **Port**: Set via `PORT` environment variable (default: 3000)
- **Timeout**: Requests timeout after 60 seconds
- **Security**: Server only listens on localhost (127.0.0.1)

## Development

For development with auto-reload:
```bash
npm install -g nodemon
nodemon server.js
```

## Notes

- The server executes Claude CLI for each request (stateless)
- Large responses may take time - be patient
- For production use, consider adding authentication
- Logs are written to console (stdout/stderr)

## License

MIT