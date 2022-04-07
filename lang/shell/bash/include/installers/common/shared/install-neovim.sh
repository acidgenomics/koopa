#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Neovim.
    # @note Updated 2022-04-07.
    #
    # @seealso
    # - https://github.com/neovim/neovim/wiki/Building-Neovim
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/neovim.rb
    # - https://github.com/neovim/neovim/issues/11192
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'cmake' 'luarocks' 'pkg-config'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
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
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # > "${app[make]}" distclean
    # Alternatively, can use:
    # CMAKE_BUILD_TYPE='RelWithDebInfo'
    "${app[make]}" \
        --jobs="${dict[jobs]}" \
        CMAKE_BUILD_TYPE='Release' \
        CMAKE_INSTALL_PREFIX="${dict[prefix]}"
    "${app[make]}" install
    return 0
}
