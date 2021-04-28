#!/usr/bin/env bash

install_pyenv() { # {{{1
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

install_pyenv "$@"
