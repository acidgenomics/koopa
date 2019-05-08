#!/usr/bin/env bash
set -Eeuxo pipefail

dir="$1"

# Check that directory exists
if [[ ! -d "$dir" ]]; then
    echo "${dir} directory does not exist."
    exit 1
fi

# Create disk image from directory.
# -ov = overwrite
hdiutil create -volname "$dir" -srcfolder "$dir" -ov "$dir".dmg
