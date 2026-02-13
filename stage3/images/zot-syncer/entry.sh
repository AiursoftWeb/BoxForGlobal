#!/bin/bash
set -e

SESSION_NAME="zot-sync"
LOG_DIR="/var/log/zot-sync-runs"
mkdir -p "$LOG_DIR"

# Check if a sync session is already running
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "$(date -u '+%Y-%m-%d %H:%M:%S UTC') - Sync session already running, skipping."
    exit 0
fi

# Create a timestamped log file for this run
RUN_LOG="$LOG_DIR/$(date -u '+%Y-%m-%d_%H-%M-%S').log"
touch "$RUN_LOG"

# Start tmux session with the actual sync script
tmux new-session -d -s "$SESSION_NAME" "bash /app/sync.sh 2>&1 | tee $RUN_LOG; tmux kill-session -t $SESSION_NAME"

echo "$(date -u '+%Y-%m-%d %H:%M:%S UTC') - Started sync session, log: $RUN_LOG"
