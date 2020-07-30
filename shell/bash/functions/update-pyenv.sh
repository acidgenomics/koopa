#!/usr/bin/env bash

koopa::update_pyenv() { # {{{1
    # """
    # Update pyenv.
    # @note Updated 2020-07-30.
    # """
    koopa::is_installed pyenv || return 0
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::h1 'Updating pyenv.'
    (
        koopa::cd "$(pyenv root)"
        git pull
    )
    return 0
}

