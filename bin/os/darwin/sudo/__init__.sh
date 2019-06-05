#!/usr/bin/env bash
set -Eeuxo pipefail

# Check for macOS.
if [[ "$KOOPA_OS_NAME" != "darwin" ]] ||
   [[ -z "${MACOS:-}" ]]
then
    echo "Error: macOS is required." >&2
    exit 1
fi
