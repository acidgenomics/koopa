#!/usr/bin/env bash
set -Eeuxo pipefail

# Upgrade koopa installation.

wd=$(pwd)
cd "$KOOPA_BASE_DIR"
git pull
cd "$wd"

cat << EOF
koopa updated successfully.
Shell must be reloaded for changes to take effect.
EOF
