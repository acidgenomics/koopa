#!/usr/bin/env bash

koopa::configure_nim() { # {{{1
    # """
    # Configure Nim.
    # @note Updated 2021-09-29.
    # """
    local nim
    nim="$(koopa::locate_nim)"
    koopa:::configure_app_packages \
        --name='nim' \
        --name-fancy='Nim' \
        --which-app="$nim"
    return 0
}

koopa::install_nim() { # {{{1
    koopa:::install_app \
        --name='nim' \
        --name-fancy='Nim' \
        --link-include-dirs='bin' \
        "$@"
    koopa::configure_nim
    return 0
}

koopa:::install_nim() { # {{{1
    # """
    # Install Nim.
    # @note Updated 2021-10-05.
    # """
    local file name prefix url version
    name='nim'
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    file="${name}-${version}.tar.xz"
    url="https://nim-lang.org/download/${file}"
    tmp_dir="$(koopa::tmp_dir)"
    koopa::cd "$tmp_dir"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./build.sh
    bin/nim c koch
    ./koch boot -d:release
    ./koch tools
    koopa::cp --target="$prefix" 'bin'
    return 0
}

koopa::uninstall_nim() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}
