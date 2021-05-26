#!/usr/bin/env bash

koopa::install_fish() { # {{{1
    koopa::install_app \
        --name='fish' \
        --name-fancy='Fish' \
        "$@"
}

koopa:::install_fish() { # {{{1
    # """
    # Install Fish shell.
    # @note Updated 2021-05-26.
    # @seealso
    # - https://github.com/fish-shell/fish-shell/#building
    # """
    local cmake file jobs link_app make name prefix url version
    link_app="${INSTALL_LINK_APP:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    cmake="$(koopa::locate_cmake)"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    file="${name}-${version}.tar.xz"
    name='fish'
    url="https://github.com/${name}-shell/${name}-shell/releases/download/\
${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    "$cmake" -DCMAKE_INSTALL_PREFIX="$prefix"
    "$make" --jobs="$jobs"
    # > "$make" test
    "$make" install
    if [[ "${link_app:-0}" -eq 1 ]]
    then
        koopa::enable_shell "$name"
    fi
    return 0
}
