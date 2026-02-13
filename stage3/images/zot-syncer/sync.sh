#!/bin/bash
set -e

echo "=========================================="
echo "  Zot Data Sync from Proart"
echo "  Source: rsync://hub-rsync.aiursoft.com/zot-data/blob/"
echo "  Target: /data/"
echo "  Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=========================================="

# ==========================================
# Phase 1: Additive sync (zot still running)
# Sync all blob data WITHOUT --delete and WITHOUT DB files
# This is safe because blobs are content-addressable (immutable)
# ==========================================
echo ""
echo "[Phase 1] Additive blob sync (zot is still running)..."
rsync -avx \
    --exclude='cache.db' \
    --exclude='meta.db' \
    rsync://hub-rsync.aiursoft.com/zot-data/blob/ /data/blob/
echo "[Phase 1] Done at $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# ==========================================
# Phase 2: Final sync with service stop
# Stop zot -> sync everything with --delete -> start zot
# This should be very fast since Phase 1 already synced most data
# ==========================================
echo ""
echo "[Phase 2] Stopping zot_server for final sync..."
docker service scale zot_server=0
sleep 10

echo "[Phase 2] Final rsync with --delete..."
rsync -avx --delete rsync://hub-rsync.aiursoft.com/zot-data/blob/ /data/blob/
echo "[Phase 2] Final sync done at $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

echo "[Phase 2] Starting zot_server..."
docker service scale zot_server=1

echo ""
echo "=========================================="
echo "  Sync completed at $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=========================================="
