#!/usr/bin/env bash

koopa::linux_install_vim() { # {{{1
    koopa::linux_install_app \
        --name='vim' \
        --name-fancy='Vim' \
        "$@"
}

koopa:::linux_install_vim() { # {{{1
    # """
    # Install Vim.
    # @note Updated 2021-05-04.
    # """
    local file flags jobs make_prefix name prefix python python_config \
        python_config_dir url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='vim'
    jobs="$(koopa::cpu_count)"
    make_prefix="$(koopa::make_prefix)"
    python="$(koopa::python)"
    python_config="${python}-config"
    koopa::assert_is_installed "$python" "$python_config"
    python_config_dir="$("$python_config" --configdir)"
    file="v${version}.tar.gz"
    url="https://github.com/${name}/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    flags=(
        "--prefix=${prefix}"
        "--with-python3-command=${python}"
        "--with-python3-config-dir=${python_config_dir}"
        '--enable-python3interp=yes'
        "LDFLAGS=-Wl,--rpath=${make_prefix}/lib"
    )
    ./configure "${flags[@]}"
    make --jobs="$jobs"
    # > make test
    make install
    return 0
}
