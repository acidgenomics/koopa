#!/usr/bin/env bash
set -Eeu -o pipefail

# Update koopa installation.
# Modified 2019-06-17.

rm -rf "${KOOPA_DIR}/dotfiles"

(
    cd "$KOOPA_DIR" || exit 1
    git pull
    git submodule sync --recursive
)

cat << EOF
koopa updated successfully.
Shell must be reloaded for changes to take effect.
EOF
