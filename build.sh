#!/bin/bash
set -e
cd "$(dirname "$0")"

SDK=$(xcrun --sdk macosx --show-sdk-path)
ARCH=$(uname -m)
APP="Hours.app"

echo "Building Hours for $ARCH..."

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

# Copy Info.plist and substitute Xcode build variables that won't be expanded outside Xcode.
sed \
  -e 's/\$(EXECUTABLE_NAME)/Hours/g' \
  -e 's/\$(PRODUCT_BUNDLE_IDENTIFIER)/com.seanlikesdata.hours/g' \
  Hours/Info.plist > "$APP/Contents/Info.plist"

swiftc \
  Hours/HoursApp.swift \
  Hours/AppState.swift \
  Hours/Formatters.swift \
  Hours/Models/Project.swift \
  Hours/Views/MenuBarLabel.swift \
  Hours/Views/MenuBarView.swift \
  Hours/Views/ProjectRowView.swift \
  Hours/Views/EditProjectsView.swift \
  Hours/Views/ManualTimeEntryView.swift \
  -sdk "$SDK" \
  -target "${ARCH}-apple-macos13.0" \
  -parse-as-library \
  -o "$APP/Contents/MacOS/Hours"

codesign --force --deep --sign - "$APP"

echo "Done — $APP"
