#!/usr/bin/env bash

koopa::install_singularity() { # {{{1
    koopa::install_app \
        --name='singularity' \
        "$@"
}

koopa:::install_singularity() { # {{{1
    # """
    # Install Singularity.
    # @note Updated 2021-05-26.
    # """
    local file make name prefix url version
    if koopa::is_linux
    then
        koopa::activate_opt_prefix 'go'
    elif koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'go'
    fi
    koopa::assert_is_installed 'go'
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    make="$(koopa::locate_make)"
    name='singularity'
    file="${name}-${version}.tar.gz"
    url="https://github.com/sylabs/${name}/releases/download/\
v${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "$name"
    ./mconfig --prefix="$prefix"
    "$make" -C builddir
    "$make" -C builddir install  # FIXME Need sudo here?
    return 0
}
