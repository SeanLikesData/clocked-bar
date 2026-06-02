#!/bin/bash
set -e
cd "$(dirname "$0")"

bash build.sh
pkill -f "Hours.app/Contents/MacOS/Hours" 2>/dev/null || true
sleep 0.2
open Hours.app
echo "Hours is running."
