#!/usr/bin/env bash

install_tmux() { # {{{1
    # """
    # Install Tmux.
    # @note Updated 2021-04-26.
    # """
    local file jobs name prefix url version
    jobs="${INSTALL_JOBS:?}"
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    file="${name}-${version}.tar.gz"
    url="https://github.com/${name}/${name}/releases/download/
${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    make install
    return 0
}

install_tmux "$@"
