#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

# Update koopa installation.
# Updated 2019-06-27.

rm -rf "${KOOPA_HOME}/dotfiles"

(
    cd "$KOOPA_HOME" || exit 1
    git pull
    git submodule sync --recursive
    git status
)

cat << EOF
koopa updated successfully.
Shell must be reloaded for changes to take effect.
EOF
