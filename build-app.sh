#!/bin/bash
set -euo pipefail

APP_NAME="WebsiteMenuBar"
BUNDLE_ID="com.hanolee.websitemenubar"
VERSION="${1:-1.0.0}"
BUILD_NUMBER="${2:-1}"

APP_DIR="$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "▶ Building $APP_NAME $VERSION ($BUILD_NUMBER) for arm64"
swift build -c release --arch arm64 \
    -Xswiftc -target -Xswiftc arm64-apple-macos13.0
ARM64_BIN=".build/arm64-apple-macosx/release/$APP_NAME"

echo "▶ Building $APP_NAME $VERSION ($BUILD_NUMBER) for x86_64"
swift build -c release --arch x86_64 \
    -Xswiftc -target -Xswiftc x86_64-apple-macos13.0
X86_64_BIN=".build/x86_64-apple-macosx/release/$APP_NAME"

if [[ ! -f "AppIcon.icns" ]]; then
    echo "▶ AppIcon.icns not found, generating..."
    swift Scripts/generate-icon.swift
    iconutil -c icns AppIcon.iconset -o AppIcon.icns
fi

echo "▶ Assembling $APP_DIR (universal)"
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
lipo -create "$ARM64_BIN" "$X86_64_BIN" -output "$MACOS_DIR/$APP_NAME"
lipo -info "$MACOS_DIR/$APP_NAME" | sed 's/^/   /'
cp "AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>Website MenuBar</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$BUILD_NUMBER</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 hanolee</string>
</dict>
</plist>
PLIST

echo "▶ Ad-hoc code signing"
codesign --force --deep --sign - \
    --options runtime \
    --identifier "$BUNDLE_ID" \
    "$APP_DIR"

echo "▶ Verifying signature"
codesign --verify --deep --strict --verbose=2 "$APP_DIR" 2>&1 | sed 's/^/   /'

ZIP_NAME="$APP_NAME-$VERSION.zip"
echo "▶ Creating release archive: $ZIP_NAME"
rm -f "$ZIP_NAME"
ditto -c -k --keepParent "$APP_DIR" "$ZIP_NAME"

echo ""
echo "✓ $APP_DIR  ($(du -sh "$APP_DIR" | cut -f1))"
echo "✓ $ZIP_NAME ($(du -sh "$ZIP_NAME" | cut -f1))"
echo ""
echo "   실행: open \"$APP_DIR\""
echo "   설치: mv \"$APP_DIR\" /Applications/"
