#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Cairo.
    # @note Updated 2022-04-26.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/cairo.rb
    # - https://github.com/archlinux/svntogit-packages/blob/master/cairo/
    #     trunk/PKGBUILD
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix \
        'zlib' \
        'freetype' \
        'fontconfig' \
        'libffi' \
        'pcre' \
        'glib' \
        'libpng' \
        'libpthread-stubs' \
        'lzo' \
        'pixman' \
        'xorg-xorgproto' \
        'xorg-xcb-proto' \
        'xorg-libxau' \
        'xorg-libxdmcp' \
        'xorg-libxcb' \
        'xorg-libx11' \
        'xorg-libxext' \
        'xorg-libxrender'
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
    # Alternative approach that uses meson (from Arch Linux recipe):
    # How to handle multiple cores here?
    # > app[meson]="$(koopa_locate_meson)"
    # > "${app[meson]}" cairo build \
    # >     -D spectre=disabled \
    # >     -D tee=enabled \
    # >     -D tests=disabled \
    # >     -D symbol-lookup=disabled \
    # >     -D gtk_doc=true
    # > "${app[meson]}" compile -C build
    # > "${app[meson]}" install -C build --destdir "${dict[prefix]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-dependency-tracking'
        # > '--disable-valgrind'
        # > '--enable-gobject'
        # > '--enable-svg'
        # > '--enable-tee'
        '--enable-xcb'
        '--enable-xlib'
        '--enable-xlib-xrender'
    )
    # > if koopa_is_macos
    # > then
    # >     conf_args+=('--enable-quartz-image')
    # > fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
