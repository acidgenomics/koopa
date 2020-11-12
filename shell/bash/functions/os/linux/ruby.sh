#!/usr/bin/env bash

koopa::linux_update_rbenv() { # {{{1
    # """
    # Update rbenv.
    # @note Updated 2020-11-12.
    # """
    local rbenv_root
    koopa::assert_has_no_args "$#"
    koopa::assert_is_linux
    koopa::assert_has_no_envs
    koopa::is_installed rbenv || return 0
    koopa::h1 'Updating rbenv.'
    rbenv_root="$(rbenv root)"
    koopa::assert_is_dir "$rbenv_root"
    (
        koopa::cd "$rbenv_root"
        git pull
    )
    return 0
}
