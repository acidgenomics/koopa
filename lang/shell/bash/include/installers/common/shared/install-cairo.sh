#!/usr/bin/env bash

main() {
    # """
    # Install Cairo.
    # @note Updated 2022-07-20.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/cairo.rb
    # - https://github.com/archlinux/svntogit-packages/blob/master/cairo/
    #     trunk/PKGBUILD
    # """
    local app conf_args deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    deps=(
        'zlib'
        'gettext'
        'freetype'
        'libxml2'
        'fontconfig'
        'libffi'
        'pcre'
        'glib'
        'libpng'
        'lzo'
        'pixman'
        'xorg-xorgproto'
        'xorg-xcb-proto'
        'xorg-libpthread-stubs'
        'xorg-libxau'
        'xorg-libxdmcp'
        'xorg-libxcb'
        'xorg-libx11'
        'xorg-libxext'
        'xorg-libxrender'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='cairo'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://cairographics.org/releases/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-dependency-tracking'
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
