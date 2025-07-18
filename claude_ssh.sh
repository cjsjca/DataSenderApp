#!/bin/bash
# Simple Claude CLI access via SSH
# Just run: ./claude_ssh.sh

cd ~/Projects/DataSenderApp
tmux attach -t claude-cli || (echo "Starting Claude CLI..." && tmux new -s claude-cli "claude")