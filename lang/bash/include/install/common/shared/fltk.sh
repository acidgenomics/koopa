#!/usr/bin/env bash

main() {
    # """
    # Install FLTK.
    # @note Updated 2024-12-26.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/fltk
    # - https://courses.cs.washington.edu/courses/csep557/14au/tools/
    #     fltk_install.html
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps+=('cmake' 'pkg-config')
    deps+=(
        'zlib'
        'libjpeg-turbo'
        'libpng'
        'freetype'
    )
    if _koopa_is_linux
    then
        deps+=(
            'xorg-xorgproto'
            'xorg-xtrans'
            'xorg-libpthread-stubs'
            'xorg-libxau'
            'xorg-libxdmcp'
            'xorg-libxcb'
            'xorg-libx11'
        )
    fi
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--enable-shared'
        '--enable-threads'
        "--prefix=${dict['prefix']}"
    )
    if _koopa_is_linux
    then
        dict['x11']="$(_koopa_app_prefix 'xorg-libx11')"
        conf_args+=(
            '--enable-x11'
            "--x-includes=${dict['x11']}/include"
            "--x-libraries=${dict['x11']}/lib"
        )
    fi
    dict['url']="https://github.com/fltk/fltk/releases/download/\
release-${dict['version']}/fltk-${dict['version']}-source.tar.bz2"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    _koopa_rm "${dict['prefix']}/lib/"*'.a'
    return 0
}
