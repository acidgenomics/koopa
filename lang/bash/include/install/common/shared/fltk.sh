#!/usr/bin/env bash

main() {
    # """
    # Install FLTK.
    # @note Updated 2023-04-10.
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
    )
    if koopa_is_linux
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
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--enable-shared'
        '--enable-threads'
        "--prefix=${dict['prefix']}"
    )
    if koopa_is_linux
    then
        dict['x11']="$(koopa_app_prefix 'xorg-libx11')"
        conf_args+=(
            '--enable-x11'
            "--x-includes=${dict['x11']}/include"
            "--x-libraries=${dict['x11']}/lib"
        )
    fi
    dict['url']="https://www.fltk.org/pub/fltk/${dict['version']}/\
fltk-${dict['version']}-source.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    koopa_rm "${dict['prefix']}/lib/"*'.a'
    return 0
}
