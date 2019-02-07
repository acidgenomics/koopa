#!/usr/bin/env bash
set -Eeuo pipefail

xattr -r -d com.apple.quarantine /Applications/*.app
