#!/usr/bin/env bash

install_fish() { # {{{1
    # """
    # Install Fish shell.
    # @note Updated 2021-04-27.
    # @seealso
    # - https://github.com/fish-shell/fish-shell/#building
    # """
    local file jobs link_app name prefix url version
    jobs="${INSTALL_JOBS:?}"
    link_app="${INSTALL_LINK_APP:?}"
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    file="${name}-${version}.tar.gz"
    url="https://github.com/fish-shell/fish-shell/releases/download/\
${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    cmake -DCMAKE_INSTALL_PREFIX="$prefix"
    make --jobs="$jobs"
    # > make test
    make install
    if [[ "${link_app:-0}" -eq 1 ]]
    then
        koopa::enable_shell "$name"
    fi
    return 0
}

install_fish "$@"
