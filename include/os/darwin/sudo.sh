#!/usr/bin/env bash
set -Eeu -o pipefail

# Source bash functions.
# shellcheck source=/dev/null
source "${KOOPA_DIR}/include/shell/bash/functions.sh"

if ! has_sudo
then
    >&2 echo "Error: sudo is required for this script."
    exit 1
fi

# Check for macOS.
if [[ "$KOOPA_OS_NAME" != "darwin" ]] ||
   [[ -z "${MACOS:-}" ]]
then
    >&2 echo "Error: macOS is required."
    exit 1
fi

# shellcheck source=/dev/null
source "${KOOPA_DIR}/include/shell/bash/functions.sh"
