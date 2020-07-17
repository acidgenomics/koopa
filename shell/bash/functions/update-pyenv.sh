#!/usr/bin/env bash

koopa::update_pyenv() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::exit_if_not_installed pyenv
    koopa::assert_has_no_envs
    koopa::h1 'Updating pyenv.'
    (
        koopa::cd "$(pyenv root)"
        git pull
    )
    return 0
}

