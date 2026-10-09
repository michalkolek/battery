#!/bin/bash

# OFFLINE FORK: this script no longer downloads anything. It refreshes the
# installed battery script and smc binary from the local repository clone,
# optionally pulling the latest changes with git first.

echo -e "🔋 Starting battery update (local)\n"

# Running as root or user: reset PATH to safe defaults
PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Ensure Ctrl+C stops the entire script, not just the current command
trap 'exit 130' INT

binfolder="/usr/local/co.palokaj.battery"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$repo_dir/battery.sh" ]]; then
	echo "❌ Could not find battery.sh next to update.sh — run it from the repo clone."
	exit 1
fi

# Optional: let 'update.sh --pull' also run git pull before installing
if [[ "$1" == "--pull" ]]; then
	echo "[ 1 ] Pulling latest changes in $repo_dir"
	git -C "$repo_dir" pull --ff-only || {
		echo "❌ git pull failed — resolve manually, nothing was installed."
		exit 1
	}
else
	echo "[ 1 ] Skipping git pull (pass --pull to enable)"
fi

echo "[ 2 ] Writing script to $binfolder/battery"
sudo install -d -m 755 -o root -g wheel "$binfolder"
sudo install -m 755 -o root -g wheel "$repo_dir/battery.sh" "$binfolder/battery"

echo "[ 3 ] Updating smc binary"
sudo install -m 755 -o root -g wheel "$repo_dir/dist/smc" "$binfolder/smc"

echo "[ 4 ] Refreshing visudo configuration"
$binfolder/battery visudo

echo -e "\n🎉 Battery tool updated from local repository.\n"
