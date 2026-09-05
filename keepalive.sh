#!/bin/bash
# keepalive.sh - Prevents Oracle Cloud Always Free reclamation

# 1. Install stress-ng if it isn't already installed
if ! command -v stress-ng &> /dev/null; then
    echo "Installing stress-ng..."
    sudo apt-get update && sudo apt-get install -y stress-ng
fi

# 2. Get total system memory in Megabytes
TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')

# 3. Calculate 16% of total memory to stay safely above Oracle's 15% idle rule
LOCK_MEM=$(echo "$TOTAL_MEM * 0.16" | bc | cut -d'.' -f1)

echo "Total RAM: ${TOTAL_MEM}MB. Locking ${LOCK_MEM}MB to prevent Oracle reclamation."

# 4. Run stress-ng in the background
# This tells the system to permanently occupy 16% RAM and use 16% of 1 CPU core
nohup stress-ng --vm 1 --vm-bytes ${LOCK_MEM}M --cpu 1 --cpu-load 16 --quiet &

echo "Anti-idle engine successfully deployed in the background."
