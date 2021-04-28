#!/usr/bin/env bash

install_vim() { # {{{1
    # """
    # Install Vim.
    # @note Updated 2021-04-28.
    #
    # Installing with Python 3 configuration.
    # """
    local file flags jobs make_prefix name prefix python3 python3_config_dir \
        url version
    koopa::assert_is_linux
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make_prefix="$(koopa::make_prefix)"
    python3='python3'
    python3_config="${python3}-config"
    koopa::assert_is_installed "$python3" "$python3_config"
    python3_config_dir="$("$python3_config" --configdir)"
    file="v${version}.tar.gz"
    url="https://github.com/${name}/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    flags=(
        "--prefix=${prefix}"
        "--with-python3-command=${python3}"
        "--with-python3-config-dir=${python3_config_dir}"
        '--enable-python3interp=yes'
        "LDFLAGS=-Wl,--rpath=${make_prefix}/lib"
    )
    ./configure "${flags[@]}"
    make --jobs="$jobs"
    # > make test
    make install
    return 0
}

install_vim "$@"
