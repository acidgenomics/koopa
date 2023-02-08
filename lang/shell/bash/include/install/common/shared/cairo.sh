#!/usr/bin/env bash

# NOTE Latest version only supports meson / ninja and drops support for
# GNU make with configure script.

main() {
    # """
    # Install Cairo.
    # @note Updated 2023-02-08.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/cairo.rb
    # - https://github.com/archlinux/svntogit-packages/blob/master/cairo/
    #     trunk/PKGBUILD
    # """
    local app build_deps conf_args deps dict
    koopa_assert_has_no_args "$#"
    build_deps=(
        # > 'meson'
        # > 'ninja'
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
        'expat'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        # > ['meson']="$(koopa_locate_meson)"
        # > ['ninja']="$(koopa_locate_ninja)"
        ['make']="$(koopa_locate_make)"
    )
    # > [[ -x "${app['meson']}" ]] || return 1
    # > [[ -x "${app['ninja']}" ]] || return 1
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
    # > koopa_mkdir 'build'
    # > koopa_cd 'build'
    koopa_print_env
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
    # > meson_args=(
    # >     "--prefix=${dict['prefix']}"
    # >     '--buildtype=release'
    # >     # Avoid 'lib64' inconsistency on Linux.
    # >     '-Dlibdir=lib'
    # > )
    # > koopa_dl 'meson args' "${meson_args[*]}"
    # > "${app['meson']}" "${meson_args[@]}" ..
    # > "${app['ninja']}" -v
    # > "${app['ninja']}" install -v
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
