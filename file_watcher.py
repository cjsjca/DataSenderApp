#!/usr/bin/env python3
"""
Intelligent file watcher with semantic versioning
- Captures file changes with context
- Sends to Supabase with metadata for vector indexing
- Correlates changes with ongoing conversations
- Portable design for future cloud/Linux migration
"""

import os
import sys
import json
import time
import hashlib
import requests
import threading
import subprocess
from datetime import datetime
from pathlib import Path
from queue import Queue

# Supabase config
SUPABASE_URL = "https://xvxyzmldrqewigrrccea.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHl6bWxkcnFld2lncnJjY2VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3ODY0NDUsImV4cCI6MjA2ODM2MjQ0NX0.Y6F9a-L6VUdxPdUTNZTBNvAqTWwR6i2R-ACsoZZPxyE"

# Ignore patterns
IGNORE_PATTERNS = [
    '.git', '__pycache__', '.DS_Store', 'node_modules',
    '*.pyc', '*.swp', '*.tmp', '.claude.json*'
]

class FileWatcher:
    def __init__(self, root_path="."):
        self.root_path = Path(root_path).resolve()
        self.file_states = {}
        self.change_queue = Queue()
        self.session_id = hashlib.md5(str(datetime.now()).encode()).hexdigest()[:8]
        self.context_window = []  # Recent chat messages for correlation
        
    def should_ignore(self, path):
        """Check if file should be ignored"""
        path_str = str(path)
        for pattern in IGNORE_PATTERNS:
            if pattern in path_str:
                return True
        return False
    
    def get_file_hash(self, filepath):
        """Get hash of file contents"""
        try:
            with open(filepath, 'rb') as f:
                return hashlib.md5(f.read()).hexdigest()
        except:
            return None
    
    def capture_change_context(self, filepath, change_type):
        """Capture semantic context around the change"""
        context = {
            'file': str(filepath.relative_to(self.root_path)),
            'change_type': change_type,
            'timestamp': datetime.now().isoformat(),
            'session_id': self.session_id,
            'recent_messages': self.context_window[-5:] if self.context_window else []
        }
        
        # Add file type and purpose inference
        suffix = filepath.suffix.lower()
        if suffix in ['.py', '.js', '.ts']:
            context['file_type'] = 'code'
        elif suffix in ['.md', '.txt']:
            context['file_type'] = 'documentation'
        elif suffix in ['.html', '.css']:
            context['file_type'] = 'web'
        else:
            context['file_type'] = 'other'
            
        return context
    
    def send_to_supabase(self, filepath, content, metadata):
        """Send file snapshot with metadata to Supabase"""
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
        
        # Create semantic description for vector embedding
        semantic_desc = f"[FILE_CHANGE] {metadata['change_type']} in {metadata['file']} "
        semantic_desc += f"({metadata['file_type']} file) "
        if metadata['recent_messages']:
            semantic_desc += f"Context: Working on {metadata['recent_messages'][-1][:100]}..."
        
        data = {
            'content': f"{semantic_desc}\n\n```{filepath.suffix[1:]}\n{content}\n```",
            'metadata': metadata
        }
        
        try:
            response = requests.post(
                f"{SUPABASE_URL}/rest/v1/texts",
                headers=headers,
                json=data,
                timeout=5
            )
            return response.status_code == 201
        except:
            return False
    
    def scan_directory(self):
        """Initial scan of directory"""
        for filepath in self.root_path.rglob('*'):
            if filepath.is_file() and not self.should_ignore(filepath):
                file_hash = self.get_file_hash(filepath)
                if file_hash:
                    self.file_states[str(filepath)] = file_hash
    
    def watch_with_fswatch(self):
        """Use fswatch for efficient file monitoring"""
        # Check if fswatch is available
        try:
            subprocess.run(['which', 'fswatch'], check=True, capture_output=True)
        except:
            print("fswatch not found. Installing would enable better performance.")
            print("Install with: brew install fswatch")
            return self.fallback_watcher()
        
        # Run fswatch
        cmd = ['fswatch', '-r', '--exclude', '.git', '--exclude', '__pycache__', str(self.root_path)]
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, text=True)
        
        for line in process.stdout:
            filepath = Path(line.strip())
            if filepath.exists() and not self.should_ignore(filepath):
                self.check_file(filepath)
    
    def fallback_watcher(self):
        """Fallback polling watcher (portable)"""
        while True:
            for filepath in self.root_path.rglob('*'):
                if filepath.is_file() and not self.should_ignore(filepath):
                    self.check_file(filepath)
            time.sleep(2)  # Poll every 2 seconds
    
    def check_file(self, filepath):
        """Check if file has changed"""
        current_hash = self.get_file_hash(filepath)
        if not current_hash:
            return
            
        filepath_str = str(filepath)
        previous_hash = self.file_states.get(filepath_str)
        
        if previous_hash != current_hash:
            change_type = "created" if previous_hash is None else "modified"
            self.file_states[filepath_str] = current_hash
            
            # Read file content
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Capture context and send
                metadata = self.capture_change_context(filepath, change_type)
                if self.send_to_supabase(filepath, content, metadata):
                    print(f"✓ Captured {change_type}: {filepath.relative_to(self.root_path)}")
                else:
                    print(f"✗ Failed to capture: {filepath.relative_to(self.root_path)}")
            except:
                pass
    
    def update_context(self, message):
        """Update conversation context for correlation"""
        self.context_window.append(message)
        if len(self.context_window) > 10:
            self.context_window.pop(0)
    
    def background_git_sync(self):
        """Periodic git sync without interrupting workflow"""
        while True:
            time.sleep(300)  # Every 5 minutes
            try:
                # Check if there are changes
                result = subprocess.run(['git', 'status', '--porcelain'], 
                                      capture_output=True, text=True)
                if result.stdout.strip():
                    # Silently commit and push
                    subprocess.run(['git', 'add', '.'], capture_output=True)
                    subprocess.run(['git', 'commit', '-m', f'Auto-sync {datetime.now().strftime("%Y-%m-%d %H:%M")}'], 
                                 capture_output=True)
                    subprocess.run(['git', 'push'], capture_output=True)
            except:
                pass

if __name__ == "__main__":
    print("Starting intelligent file watcher...")
    print("- Instant versioning to Supabase")
    print("- Background Git sync every 5 minutes")
    print("- Semantic context capture for vector search")
    
    watcher = FileWatcher()
    watcher.scan_directory()
    
    # Start background Git sync
    git_thread = threading.Thread(target=watcher.background_git_sync, daemon=True)
    git_thread.start()
    
    # Start watching
    try:
        watcher.watch_with_fswatch()
    except KeyboardInterrupt:
        print("\nWatcher stopped.")