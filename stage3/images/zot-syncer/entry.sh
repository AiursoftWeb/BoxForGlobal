#!/bin/bash
set -e

echo "=========================================="
echo "  Zot Data Sync from Proart"
echo "  Source: rsync://hub-rsync.aiursoft.com/zot-data/blob/"
echo "  Target: /data/blob/"
echo "  Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=========================================="

echo "Starting rsync..."
rsync -avx --delete rsync://hub-rsync.aiursoft.com/zot-data/blob/ /data/blob/
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "Sync completed successfully at $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
else
    echo "Sync failed with exit code $exit_code at $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
fi

echo "=========================================="
