#!/usr/bin/env bash

# NOTE Currently failing to build on macOS.
# checking uint32_t is 32 bits...
# configure: error: WRONG!  uint32_t not defined correctly.

koopa::install_vim() { # {{{1
    koopa::install_app \
        --name='vim' \
        --name-fancy='Vim' \
        "$@"
}

koopa:::install_vim() { # {{{1
    # """
    # Install Vim.
    # @note Updated 2021-05-05.
    # """
    local conf_args file jobs name prefix python python_config \
        python_config_dir url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='vim'
    jobs="$(koopa::cpu_count)"
    python="$(koopa::python)"
    python_config="${python}-config"
    koopa::assert_is_installed "$python" "$python_config"
    python_config_dir="$("$python_config" --configdir)"
    file="v${version}.tar.gz"
    url="https://github.com/${name}/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    conf_args=(
        "--prefix=${prefix}"
        "--with-python3-command=${python}"
        "--with-python3-config-dir=${python_config_dir}"
        '--enable-python3interp=yes'
    )
    # Setting 'LDFLAGS' here doesn't work on macOS.
    if koopa::is_linux
    then
        conf_args+=(
            "LDFLAGS=-Wl,-rpath=${prefix}/lib"
        )
    fi
    koopa::is_macos && koopa::reset_minimal_path
    ./configure "${conf_args[@]}"
    make --jobs="$jobs"
    # > make test
    make install
    return 0
}
