#!/usr/bin/env bash

koopa:::install_htop() { # {{{1
    # """
    # Install htop.
    # @note Updated 2021-05-27.
    #
    # Repo transferred from https://github.com/hishamhm/htop to 
    # https://github.com/htop-dev/htop in 2020-08.
    # """
    local conf_args file jobs make name prefix url version
    if koopa::is_macos
    then
        koopa::activate_opt_prefix \
            'autoconf' \
            'automake'
        koopa::macos_activate_python
    else
        koopa::activate_opt_prefix 'python'
    fi
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='htop'
    file="${version}.tar.gz"
    url="https://github.com/${name}-dev/${name}/archive/${file}"
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./autogen.sh
    conf_args=(
        "--prefix=${prefix}"
        '--disable-unicode'
    )
    ./configure "${conf_args[@]}"
    "$make" --jobs="$jobs"
    # > "$make" check
    "$make" install
    return 0
}
