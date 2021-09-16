#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::install_fish() { # {{{1
    koopa:::install_app \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}

koopa:::install_fish() { # {{{1
    # """
    # Install Fish shell.
    # @note Updated 2021-05-27.
    # @seealso
    # - https://github.com/fish-shell/fish-shell/#building
    # """
    local cmake file jobs link_app name prefix url version
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix \
            'ncurses' \
            'pcre2'
    fi
    link_app="${INSTALL_LINK_APP:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    cmake="$(koopa::locate_cmake)"
    jobs="$(koopa::cpu_count)"
    name='fish'
    file="${name}-${version}.tar.xz"
    url="https://github.com/${name}-shell/${name}-shell/releases/download/\
${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    "$cmake" \
        -S . \
        -B 'build' \
        -DCMAKE_INSTALL_PREFIX="$prefix"
    "$cmake" \
        --build 'build' \
        --parallel "$jobs"
    "$cmake" --install 'build'
    if [[ "${link_app:-0}" -eq 1 ]]
    then
        koopa::enable_shell "$name"
    fi
    return 0
}

koopa::uninstall_fish() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}
