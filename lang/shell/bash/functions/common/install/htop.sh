#!/usr/bin/env bash

koopa::install_htop() { # {{{1
    koopa::install_app \
        --name='htop' \
        "$@"
}

koopa:::install_htop() { # {{{1
    # """
    # Install htop.
    # @note Updated 2021-05-06.
    #
    # Repo transferred from https://github.com/hishamhm/htop to 
    # https://github.com/htop-dev/htop in 2020-08.
    # """
    local conf_args file jobs name prefix url version
    koopa::assert_is_installed python3
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='htop'
    jobs="$(koopa::cpu_count)"
    file="${version}.tar.gz"
    url="https://github.com/${name}-dev/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./autogen.sh
    conf_args=(
        "--prefix=${prefix}"
        '--disable-unicode'
    )
    ./configure "${conf_args[@]}"
    make --jobs="$jobs"
    # > make check
    make install
    return 0
}
