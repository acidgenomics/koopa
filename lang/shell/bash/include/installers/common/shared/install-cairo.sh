#!/usr/bin/env bash

main() {
    # """
    # Install Cairo.
    # @note Updated 2022-04-28.
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
        'gettext'
        'freetype'
        'fontconfig'
        'libffi'
        'pcre'
        'glib'
        'libpng'
        'lzo'
        'pixman'
    )
    if koopa_is_macos
    then
        koopa_add_to_pkg_config_path '/opt/X11/pkgconfig'
    else
        deps+=(
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
    fi
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
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
    if ! koopa_is_macos
    then
        conf_args+=(
            '--enable-xcb'
            '--enable-xlib'
            '--enable-xlib-xrender'
        )
    fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
