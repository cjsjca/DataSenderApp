# SSH Setup for Termius

## Your Mac's Details
- **IP Address**: 192.168.0.116
- **Username**: loaner
- **Project Path**: /Users/loaner/Projects/DataSenderApp

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

## Create Snippets in Termius

### Snippet 1: Launch Chat
```bash
cd ~/Projects/DataSenderApp && python3 terminal_chat.py
```

### Snippet 2: Quick Send
```bash
cd ~/Projects/DataSenderApp && echo "$1" | python3 quick_send.py
```

### Snippet 3: Check Status
```bash
ps aux | grep claude | grep -v grep || echo "Claude not running"
```

### Snippet 4: Recent Messages
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