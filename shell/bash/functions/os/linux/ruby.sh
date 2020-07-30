#!/usr/bin/env bash

koopa::update_rbenv() { # {{{1
    local rbenv_root
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::exit_if_not_installed rbenv
    koopa::h1 'Updating rbenv.'
    rbenv_root="$(rbenv root)"
    koopa::assert_is_dir "$rbenv_root"
    (
        koopa::cd "$rbenv_root"
        git pull
    )
    return 0
}
