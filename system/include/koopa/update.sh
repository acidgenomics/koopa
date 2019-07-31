#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

# Update koopa installation.
# Updated 2019-07-31.

# Clean up dot files.
rm -rf "${KOOPA_HOME}/dotfiles"

(
    cd "${KOOPA_HOME}/system/config/dotfiles/vim/pack/disk/start" || exit 0
    rm -rf Nvim-R vim-*
)

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
