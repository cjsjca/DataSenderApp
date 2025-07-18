# SSH Setup for Termius - DataSenderApp

Complete guide for accessing your Mac from iPhone, including Claude CLI with subscription authentication.

## Your Mac's Details
- **IP Address**: 192.168.0.116
- **Username**: loaner
- **Project Path**: /Users/loaner/Projects/DataSenderApp

## Prerequisites

### On Mac
```bash
# Install required tools
brew install tmux fswatch

# Verify Claude CLI is installed
claude --version
```

## Enable SSH on Mac

1. Open System Settings
2. Go to General → Sharing
3. Turn on "Remote Login"
4. Select "All users" or just your user account

## Add to Termius

1. Open Termius on iPhone
2. Tap + to add new host
3. Enter:
   - **Label**: DataSender Mac
   - **Address**: 192.168.0.116
   - **Port**: 22
   - **Username**: loaner
   - **Password**: [Your Mac password]

## Test Connection

1. Tap the host to connect
2. You should see your Mac terminal
3. Test with: `cd ~/Projects/DataSenderApp && ls`

## Claude CLI Authentication (✅ WORKING!)

### The Discovery
OAuth authentication WORKS through tmux from SSH! Here's how:

1. **Start tmux session** (from Termius SSH):
   ```bash
   cd ~/Projects/DataSenderApp
   ./claude_ssh.sh
   ```

2. **When prompted for login**:
   - Claude shows a browser URL
   - Open the URL on ANY device (iPhone, Mac, etc.)
   - Complete the OAuth login
   - The tmux session receives the authentication
   - Your $250/month subscription is active!

3. **Session persists**:
   - Detach with `Ctrl+B` then `D`
   - Reattach anytime with `./claude_ssh.sh`
   - Authentication survives disconnects

## Create Snippets in Termius

### Essential Snippets

#### 1. Claude CLI (Full Assistant)
```bash
cd ~/Projects/DataSenderApp && ./claude_ssh.sh
```

#### 2. Terminal Chat (Quick Data Capture)
```bash
cd ~/Projects/DataSenderApp && python3 terminal_chat.py
```

#### 3. Check Claude Session
```bash
tmux ls | grep claude-cli || echo "No Claude session running"
```

#### 4. Kill Claude Session (if needed)
```bash
tmux kill-session -t claude-cli 2>/dev/null && echo "Session killed" || echo "No session to kill"
```

### Legacy Snippets

#### Quick Send
```bash
cd ~/Projects/DataSenderApp && echo "$1" | python3 quick_send.py
```

#### Check Status
```bash
ps aux | grep claude | grep -v grep || echo "Claude not running"
```

#### Recent Messages
```bash
cd ~/Projects/DataSenderApp && python3 -c "from claude_listener import get_latest_message; msg = get_latest_message(); print(f'Latest: {msg['content']}' if msg else 'No messages')"
```

## For External Access

If you need access from outside your home network:

1. **Option A: Tailscale** (Recommended)
   - Install Tailscale on Mac and iPhone
   - Use Tailscale IP instead of local IP

2. **Option B: Port Forwarding**
   - Forward port 22 on your router
   - Use dynamic DNS service

3. **Option C: ZeroTier**
   - Similar to Tailscale
   - Creates virtual network