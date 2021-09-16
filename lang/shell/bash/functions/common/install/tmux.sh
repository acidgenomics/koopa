#!/usr/bin/env bash

koopa::install_tmux() { # {{{1
    koopa:::install_app \
        --name='tmux' \
        "$@"
}

koopa:::install_tmux() { # {{{1
    # """
    # Install Tmux.
    # @note Updated 2021-05-25.
    # """
    local file jobs make name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='tmux'
    file="${name}-${version}.tar.gz"
    url="https://github.com/${name}/${name}/releases/download/\
${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure --prefix="$prefix"
    "$make" --jobs="$jobs"
    "$make" install
    return 0
}

koopa::uninstall_tmux() { # {{{1
    koopa::uninstall_app \
        --name='tmux' \
        "$@"
}
