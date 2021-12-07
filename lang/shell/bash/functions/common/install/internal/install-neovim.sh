#!/usr/bin/env bash

koopa:::install_neovim() { # {{{1
    # """
    # Install Neovim.
    # @note Updated 2021-12-07.
    #
    # @seealso
    # - https://github.com/neovim/neovim/wiki/Building-Neovim
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/neovim.rb
    # - https://github.com/neovim/neovim/issues/11192
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='neovim'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[version]}.tar.gz"
    case "${dict[version]}" in
        'nightly')
            ;;
        *)
            dict[file]="v${dict[file]}"
            ;;
    esac
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/archive/\
refs/tags/${dict[file]}"
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'cmake' 'luarocks' 'pkg-config'
    fi
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    # > "${app[make]}" distclean
    # Alternatively, can use:
    # CMAKE_BUILD_TYPE='RelWithDebInfo'
    "${app[make]}" \
        --jobs="${dict[jobs]}" \
        CMAKE_BUILD_TYPE='Release' \
        CMAKE_INSTALL_PREFIX="${dict[prefix]}"
    "$make" install
    return 0
}
