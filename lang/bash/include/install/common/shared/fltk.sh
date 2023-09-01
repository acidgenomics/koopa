#!/usr/bin/env bash

main() {
    # """
    # Install FLTK.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/fltk.rb
    # - https://courses.cs.washington.edu/courses/csep557/14au/tools/
    #     fltk_install.html
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    if koopa_is_linux
    then
        koopa_activate_app \
            'freetype' \
            'xorg-xorgproto' \
            'xorg-xtrans' \
            'xorg-libpthread-stubs' \
            'xorg-libxau' \
            'xorg-libxdmcp' \
            'xorg-libxcb' \
            'xorg-libx11'
    fi
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-cairo'
        '--disable-xft'
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
    elif koopa_is_macos
    then
        conf_args+=('--disable-x11')
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
