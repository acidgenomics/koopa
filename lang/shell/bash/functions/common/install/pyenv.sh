#!/usr/bin/env bash

koopa::install_pyenv() { # {{{1
    koopa::install_app \
        --name='pyenv' \
        "$@"
}

koopa:::install_pyenv() { # {{{1
    # """
    # Install pyenv.
    # @note Updated 2021-04-27.
    # """
    local prefix url
    prefix="${INSTALL_PREFIX:?}"
    url='https://github.com/pyenv/pyenv.git'
    koopa::mkdir "$prefix"
    git clone "$url" "$prefix"
    return 0
}

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
