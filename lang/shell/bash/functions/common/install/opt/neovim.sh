#!/usr/bin/env bash

# [2021-05-27] macOS failure.

koopa::install_neovim() { # {{{1
    koopa:::install_app \
        --name='neovim' \
        "$@"
}

koopa:::install_neovim() { # {{{1
    # """
    # Install Neovim.
    # @note Updated 2021-05-26.
    # @seealso
    # - https://github.com/neovim/neovim/wiki/Building-Neovim
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/neovim.rb
    # - https://github.com/neovim/neovim/issues/11192
    # """
    local file jobs make name prefix url version
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix \
            'cmake' \
            'luarocks' \
            'pkg-config'
    fi
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='neovim'
    file="${version}.tar.gz"
    case "$version" in
        'nightly')
            ;;
        *)
            file="v${file}"
            ;;
    esac
    url="https://github.com/${name}/${name}/archive/refs/tags/${file}"
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    # > "$make" distclean
    # Alterantively, can use:
    # CMAKE_BUILD_TYPE='RelWithDebInfo'
    "$make" \
        --jobs="$jobs" \
        CMAKE_BUILD_TYPE='Release' \
        CMAKE_INSTALL_PREFIX="$prefix"
    "$make" install
    return 0
}

koopa::uninstall_neovim() { # {{{1
    koopa:::uninstall_app \
        --name='neovim' \
        "$@"
}
