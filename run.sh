#!/bin/bash
set -e
cd "$(dirname "$0")"

bash build.sh
pkill -f "Clocked.app/Contents/MacOS/Clocked" 2>/dev/null || true
sleep 0.2
open Clocked.app
echo "Clocked is running."
