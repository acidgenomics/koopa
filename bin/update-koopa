#!/usr/bin/env bash
set -Eeuo pipefail

# Upgrade koopa installation.

(
    cd "$KOOPA_DIR"
    git pull
    git submodule sync --recursive
)

cat << EOF
koopa updated successfully.
Shell must be reloaded for changes to take effect.
EOF

exec "$KOOPA_SHELL"
