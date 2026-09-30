#!/bin/zsh
set -euo pipefail
cd "${0:A:h}"

bundle="Sync Delay.app"
mkdir -p "$bundle/Contents/MacOS" "$bundle/Contents/Resources"
cp SyncDelay-Info.plist "$bundle/Contents/Info.plist"
cp Assets/AppIcon.png "$bundle/Contents/Resources/AppIcon.png"
cp Assets/SyncDelay.icns "$bundle/Contents/Resources/SyncDelay.icns"
swiftc -parse-as-library -O sync-delay.swift \
  -module-cache-path /tmp/syncdelay-module-cache \
  -o "$bundle/Contents/MacOS/SyncDelay" \
  -framework SwiftUI -framework CoreAudio -framework AudioToolbox
codesign --force --sign - "$bundle" >/dev/null
echo "Built $bundle"
