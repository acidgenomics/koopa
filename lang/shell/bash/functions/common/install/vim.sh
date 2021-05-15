#!/usr/bin/env bash

koopa::install_vim() { # {{{1
    koopa::install_app \
        --name='vim' \
        --name-fancy='Vim' \
        "$@"
}

koopa:::install_vim() { # {{{1
    # """
    # Install Vim.
    # @note Updated 2021-05-06.
    # """
    local conf_args file jobs name prefix python python_config \
        python_config_dir url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='vim'
    jobs="$(koopa::cpu_count)"
    if koopa::is_linux
    then
        koopa::activate_opt_prefix python
    elif koopa::is_macos
    then
        koopa::macos_activate_python
    fi
    python="$(koopa::python)"
    python_config="${python}-config"
    koopa::assert_is_installed "$python" "$python_config"
    python_config_dir="$("$python_config" --configdir)"
    conf_args=(
        "--prefix=${prefix}"
        "--with-python3-command=${python}"
        "--with-python3-config-dir=${python_config_dir}"
        '--enable-cscope'
        '--enable-gui=no'
        '--enable-luainterp'
        '--enable-multibyte'
        '--enable-perlinterp'
        '--enable-python3interp'
        '--enable-python3interp=yes'
        '--enable-rubyinterp'
        '--enable-terminal'
        '--with-tlib=ncurses'
        '--without-x'
    )
    if koopa::is_linux
    then
        conf_args+=("LDFLAGS=-Wl,-rpath=${prefix}/lib")
    fi
    file="v${version}.tar.gz"
    url="https://github.com/${name}/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure "${conf_args[@]}"
    make --jobs="$jobs"
    # > make test
    make install
    return 0
}
