#!/usr/bin/env bash

main() {
    # """
    # Install Cairo.
    # @note Updated 2022-11-08.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/cairo.rb
    # - https://github.com/archlinux/svntogit-packages/blob/master/cairo/
    #     trunk/PKGBUILD
    # """
    local app build_deps conf_args deps dict
    koopa_assert_has_no_args "$#"
    build_deps=(
        # > 'autoconf'
        # > 'automake'
        # > 'gettext'
        # > 'gtk-doc'
        # > 'libtool'
        'pkg-config'
    )
    deps=(
        'zlib'
        'gettext'
        'freetype'
        'libxml2'
        'fontconfig'
        'libffi'
        'pcre2'
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
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='cairo'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://cairographics.org/snapshots/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # Consider adding support for:
    # * '--enable-qt'
    # * '--enable-xml'
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-valgrind'
        '--enable-gobject'
        '--enable-svg'
        '--enable-tee'
        '--enable-xcb'
        '--enable-xlib'
        '--enable-xlib-xcb'
        '--enable-xlib-xrender'
    )
    if koopa_is_macos
    then
        conf_args+=('--enable-quartz-image')
    fi
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    # NOTE Need GtkDoc to run autogen.
    # https://wiki.gnome.org/DocumentationProject/GtkDoc
    # > ./autogen.sh
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
