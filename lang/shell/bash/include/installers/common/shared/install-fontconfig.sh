#!/usr/bin/env bash

# NOTE Consider adding expat as a requirement here.

main() {
    # """
    # Install fontconfig.
    # @note Updated 2022-04-23.
    #
    # @seealso
    # - https://www.freedesktop.org/wiki/Software/fontconfig/
    # - https://github.com/freedesktop/fontconfig/blob/master/INSTALL
    # - https://github.com/freedesktop/fontconfig
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/fontconfig.rb
    # - https://github.com/archlinux/svntogit-packages/blob/master/fontconfig/
    #     trunk/PKGBUILD
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix \
        'gperf' \
        'freetype' \
        'libxml2'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [name]='fontconfig'
        [jobs]="$(koopa_cpu_count)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://www.freedesktop.org/software/${dict[name]}/\
release/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-libxml2'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
