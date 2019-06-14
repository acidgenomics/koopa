#!/usr/bin/env bash
set -Eeuo pipefail

# Check for macOS.
if [[ "$KOOPA_OS_NAME" != "darwin" ]] ||
   [[ -z "${MACOS:-}" ]]
then
    >&2 echo "Error: macOS is required."
    exit 1
fi

# Source bash functions.
source "${KOOPA_DIR}/include/shell/bash/functions.sh"
