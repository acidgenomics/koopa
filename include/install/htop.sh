#!/usr/bin/env bash

install_htop() { # {{{1
    # """
    # Install htop.
    # @note Updated 2021-04-27.
    #
    # Repo transferred from https://github.com/hishamhm/htop to 
    # https://github.com/htop-dev/htop in 2020-08.
    # """
    local file jobs name prefix url version
    koopa::assert_is_installed python3
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='htop'
    jobs="$(koopa::cpu_count)"
    file="${version}.tar.gz"
    url="https://github.com/htop-dev/htop/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./autogen.sh
    ./configure \
        --disable-unicode \
        --prefix="$prefix"
    make --jobs="$jobs"
    # > make check
    make install
    return 0
}

install_htop "$@"
