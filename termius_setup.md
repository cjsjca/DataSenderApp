# Termius Setup Guide

## Mac SSH Server Setup

1. **Enable Remote Login**
   - System Settings → General → Sharing
   - Turn on "Remote Login"
   - Note your username and IP address

2. **Find Your Mac's Address**
   ```bash
   # Get local IP
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # Or use hostname
   hostname
   ```

## Termius Configuration

### 1. Add Host
- Name: "DataSender Mac"
- Hostname: [Your Mac's IP or hostname]
- Port: 22
- Username: [Your Mac username]
- Password: [Your Mac password] or use SSH key

### 2. Create Snippets

**Chat Launch**
```bash
cd ~/Projects/DataSenderApp && python3 terminal_chat.py
```

**Quick Message**
```bash
cd ~/Projects/DataSenderApp && echo "$1" | python3 -c "
import sys
import requests
msg = sys.stdin.read().strip()
if msg:
    response = requests.post(
        'https://xvxyzmldrqewigrrccea.supabase.co/rest/v1/texts',
        headers={
            'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE',
            'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE',
            'Content-Type': 'application/json'
        },
        json={'content': f'[TERMIUS] {msg}'}
    )
    print('Sent!' if response.status_code == 201 else 'Failed')
"
```

**Check Claude Status**
```bash
ps aux | grep claude | grep -v grep || echo "Claude CLI not running"
```

**Start Claude CLI**
```bash
cd ~/Projects/DataSenderApp && claude
```

### 3. Advanced Snippets

**Voice Note Transcription** (if you add Whisper later)
```bash
# Record audio on iPhone, upload to Supabase, trigger transcription
echo "Future: Transcribe audio from Supabase storage"
```

**Daily Summary**
```bash
cd ~/Projects/DataSenderApp && python3 -c "
from datetime import datetime, timedelta
import requests

# Get today's messages
today = datetime.now().date()
# Query logic here
print(f'Messages today: [count]')
"
```

## Usage Patterns

### Quick Thought Capture
1. Open Termius
2. Tap your Mac connection
3. Run "Quick Message" snippet
4. Type thought and press enter

### Full Chat Session
1. Connect to Mac
2. Run "Chat Launch" snippet
3. Have full conversation with terminal_chat.py

### Background Monitoring
- I can monitor Supabase for your messages
- You'll see my responses in terminal_chat.py
- Everything is logged with timestamps

## Security Notes

- Use SSH keys instead of passwords
- Enable Touch/Face ID in Termius
- Consider using Tailscale for secure remote access
- Your Supabase keys are already in the scripts

## Tips

1. **Snippet Variables**: Use $1, $2 for input parameters
2. **Auto-run on Connect**: Set a snippet to run automatically
3. **Multi-tab**: Open multiple sessions for different tasks
4. **Gestures**: Swipe for Tab, shake for special keys