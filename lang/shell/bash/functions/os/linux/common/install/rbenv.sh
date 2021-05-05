#!/usr/bin/env bash

koopa::linux_update_rbenv() { # {{{1
    # """
    # Update rbenv.
    # @note Updated 2021-05-05.
    # """
    local name_fancy rbenv_root
    koopa::assert_has_no_args "$#"
    koopa::assert_is_linux
    koopa::assert_has_no_envs
    koopa::is_installed rbenv || return 0
    name_fancy='rbenv'
    koopa::update_start "$name_fancy"
    rbenv_root="$(rbenv root)"
    koopa::assert_is_dir "$rbenv_root"
    (
        koopa::cd "$rbenv_root"
        git pull
    )
    koopa::update_success "$name_fancy"
    return 0
}
