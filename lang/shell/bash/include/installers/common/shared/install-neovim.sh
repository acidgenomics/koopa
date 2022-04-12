#!/usr/bin/env bash

# FIXME This is currently failing on macOS.

# FIXME Need to provide a link to glibtool, otherwise this will error.

main() { # {{{1
    # """
    # Install Neovim.
    # @note Updated 2022-04-12.
    #
    # @seealso
    # - https://github.com/neovim/neovim/wiki/Building-Neovim
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/neovim.rb
    # - https://github.com/neovim/neovim/issues/11192
    # - https://carlosahs.medium.com/how-to-install-neovim-from-source-on-
    #     ubuntu-20-04-lts-524b3a91b4c4
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix \
        'autoconf' \
        'automake' \
        'cmake' \
        'gettext' \
        'libtool' \
        'lua' \
        'luarocks' \
        'ncurses' \
        'ninja' \
        'pkg-config' \
        'python'
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
    # Need to create a 'glibtool' symlink and put it in path, otherwise this
    # will fail to install on macOS.
    dict[opt_prefix]="$(koopa_opt_prefix)"
    dict[bin_extra]="$(koopa_init_dir 'bin-extra')"
    app[glibtool]="${dict[bin_extra]}/glibtool"
    koopa_ln \
        "${dict[opt_prefix]}/libtool/bin/libtool" \
        "${app[glibtool]}"
    koopa_add_to_path_start "${dict[bin_extra]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    "${app[make]}" distclean
    # Alternatively, can use:
    # CMAKE_BUILD_TYPE='RelWithDebInfo'
    "${app[make]}" \
        --jobs="${dict[jobs]}" \
        CMAKE_BUILD_TYPE='Release' \
        CMAKE_INSTALL_PREFIX="${dict[prefix]}"
    "${app[make]}" install
    return 0
}
