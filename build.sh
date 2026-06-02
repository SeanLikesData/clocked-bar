#!/bin/bash
set -e
cd "$(dirname "$0")"

SDK=$(xcrun --sdk macosx --show-sdk-path)
ARCH=$(uname -m)
APP="Clocked.app"

echo "Building Clocked for $ARCH..."

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

# Copy Info.plist and substitute Xcode build variables that won't be expanded outside Xcode.
sed \
  -e 's/\$(EXECUTABLE_NAME)/Clocked/g' \
  -e 's/\$(PRODUCT_BUNDLE_IDENTIFIER)/com.seanlikesdata.clocked/g' \
  Clocked/Info.plist > "$APP/Contents/Info.plist"

SOURCES=$(find Clocked -name "*.swift" | sort)

swiftc \
  $SOURCES \
  -sdk "$SDK" \
  -target "${ARCH}-apple-macos13.0" \
  -parse-as-library \
  -o "$APP/Contents/MacOS/Clocked"

codesign --force --deep --sign - "$APP"

echo "Done — $APP"
