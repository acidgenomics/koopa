#!/usr/bin/env bash

koopa::install_pyenv() { # {{{1
    koopa::install_app \
        --name='pyenv' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa:::install_pyenv() { # {{{1
    # """
    # Install pyenv.
    # @note Updated 2021-09-17.
    # """
    local prefix url
    prefix="${INSTALL_PREFIX:?}"
    url='https://github.com/pyenv/pyenv.git'
    koopa::git_clone "$url" "$prefix"
    return 0
}

koopa::uninstall_pyenv() { # {{{1
    koopa::uninstall_app \
        --name='pyenv' \
        --no-link \
        "$@"
}

koopa::update_pyenv() { # {{{1
    koopa::update_app \
        --name='pyenv' \
        "$@"
}

koopa:::update_pyenv() { # {{{1
    # """
    # Update pyenv.
    # @note Updated 2021-09-17.
    # """
    koopa::assert_has_no_args "$#"
    koopa::activate_pyenv
    koopa::assert_is_installed 'pyenv'
    (
        koopa::cd "$(pyenv root)"
        koopa::git_pull
    )
    return 0
}
