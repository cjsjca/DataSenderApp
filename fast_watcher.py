#!/usr/bin/env python3
"""
Fast, minimal file watcher
- Just captures changes instantly
- No analysis or interruption
- Background git sync
"""

import os
import subprocess
import time
import threading
from datetime import datetime
from pathlib import Path

# Just watch and snapshot, no analysis
class FastWatcher:
    def __init__(self):
        self.root = Path.cwd()
        
    def watch(self):
        """Simple fswatch wrapper"""
        cmd = ['fswatch', '-r', '--exclude', '.git', '.']
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, text=True)
        
        for line in process.stdout:
            filepath = line.strip()
            if filepath:
                # Just log it happened
                timestamp = datetime.now().strftime("%H:%M:%S")
                print(f"[{timestamp}] Changed: {filepath}")
                # Could snapshot to Supabase here if needed
    
    def git_background(self):
        """Silent git commits"""
        while True:
            time.sleep(300)  # 5 minutes
            try:
                subprocess.run(['git', 'add', '.'], capture_output=True)
                subprocess.run(['git', 'commit', '-m', 'Auto-sync'], capture_output=True)
                subprocess.run(['git', 'push'], capture_output=True)
            except:
                pass

if __name__ == "__main__":
    watcher = FastWatcher()
    
    # Background git
    git_thread = threading.Thread(target=watcher.git_background, daemon=True)
    git_thread.start()
    
    # Just watch
    print("Watching files (minimal overhead)...")
    watcher.watch()