#!/bin/bash
set -e

cd "$(dirname "$0")"

if ! command -v xcodegen &>/dev/null; then
  echo "xcodegen not found. Install with: brew install xcodegen"
  exit 1
fi

echo "Generating Xcode project..."
xcodegen generate

echo ""
echo "Done. Open Clocked.xcodeproj to build and run."
echo "  open Clocked.xcodeproj"
