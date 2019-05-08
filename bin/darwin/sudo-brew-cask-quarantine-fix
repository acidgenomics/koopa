#!/usr/bin/env bash
set -Eeuxo pipefail

# Disable quarantine on installed applications.
# This is useful for installed Homebrew casks.

sudo xattr -r -d com.apple.quarantine /Applications/*.app
