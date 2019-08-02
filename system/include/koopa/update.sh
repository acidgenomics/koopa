#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

# Update koopa installation.
# Updated 2019-08-01.

# Update repo.
(
    cd "$KOOPA_HOME" || exit 1
    git pull
)

# Clean up dot files.
if [[ -d "${KOOPA_HOME}/dotfiles" ]]
then
    rm -rf "${KOOPA_HOME}/dotfiles"
fi

dotfiles_dir="$(koopa config-dir)/dotfiles"
if [[ -d "$dotfiles_dir" ]]
then
    printf "Updating dotfiles.\n"
    (
        cd "$dotfiles_dir" || exit 1
        git pull
        vim_plugins="${dotfiles_dir}/vim/pack/dist/start"
        if [[ -d "$vim_plugins" ]]
        then
            (
                cd "$vim_plugins" || exit 1
                rm -rf Nvim-R vim-*
            )
        fi
    )
fi

(
    cd "$KOOPA_HOME" || exit 1
    git submodule sync --recursive
    git status
)

cat << EOF
koopa updated successfully.
Shell must be reloaded for changes to take effect.
EOF
