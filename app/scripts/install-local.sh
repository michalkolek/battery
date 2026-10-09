#!/bin/bash

# Installs the locally built (and afterPack re-signed) Battery.app into
# /Applications and launches it. Assumes `npm run build` already ran.

set -e
PATH=/usr/bin:/bin:/usr/sbin:/sbin

app_out_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/dist/mac-arm64"
app_name="battery.app"

if [[ ! -d "$app_out_dir/$app_name" ]]; then
	echo "❌ No built app found at $app_out_dir/$app_name — run 'npm run build' first."
	exit 1
fi

echo "[ 1 ] Stopping any running Battery app instances"
pkill -f "/Applications/${app_name}/Contents/MacOS" 2>/dev/null || true

echo "[ 2 ] Installing to /Applications"
rm -rf "/Applications/$app_name"
cp -R "$app_out_dir/$app_name" "/Applications/$app_name"

echo "[ 3 ] Verifying signature"
codesign --verify --verbose=1 "/Applications/$app_name" 2>&1 | tail -1

echo "[ 4 ] Launching"
open "/Applications/$app_name"

echo -e "\n🎉 Battery installed and running. Look for the battery icon in your menu bar.\n"
