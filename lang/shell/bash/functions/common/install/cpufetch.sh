#!/usr/bin/env bash

# [2021-05-27] macOS failure.

koopa::install_cpufetch() { # {{{1
    koopa::install_app \
        --name='cpufetch' \
        "$@"
}

koopa:::install_cpufetch() { # {{{1
    # """
    # Install cpufetch.
    # @note Updated 2021-05-25.
    # """
    local file jobs make name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='cpufetch'
    file="v${version}.tar.gz"
    url="https://github.com/Dr-Noob/${name}/archive/refs/tags/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    # Installer doesn't currently support 'configure' script.
    PREFIX="$prefix" "$make" --jobs="$jobs"
    PREFIX="$prefix" "$make" install
    return 0
}

koopa::uninstall_cpufetch() { # {{{1
    koopa::uninstall_app \
        --name='cpufetch' \
        "$@"
}
