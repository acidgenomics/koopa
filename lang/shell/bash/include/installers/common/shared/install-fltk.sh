#!/usr/bin/env bash

# FIXME This is having trouble locating '-lX11' on Ubuntu...

# NOTE Consider adding support for libxft.
# https://gitlab.freedesktop.org/xorg/lib/libxft

# FIXME Hitting this error consistently on Linux:
# /usr/bin/ar cr ../lib/libfltk.a ...
# g++ -L. -L/opt/koopa/app/xorg-libx11/1.7.2/lib -R/opt/koopa/app/xorg-libx11/1.7.2/lib -Wl,-no-undefined -Wl,-Bsymbolic-functions -Wl,-gc-sections -Wl,-soname,libfltk.so.1.3 -lXrender -lXext -lpthread -lm -lX11 -shared -fPIC -o libfltk.so.1.3 ...
# /usr/bin/ld: cannot find -lXrender: No such file or directory
# /usr/bin/ld: cannot find -lXext: No such file or directory
# /usr/bin/ld: cannot find -lXrender: No such file or directory
# /usr/bin/ld: cannot find -lXext: No such file or directory
# /usr/bin/ar cr ../lib/libfltk_forms.a ...
# collect2: error: ld returned 1 exit status
# make[1]: *** [Makefile:240: libfltk.so.1.3] Error 1



main() {
    # """
    # Install FLTK.
    # @note Updated 2022-07-12.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/fltk.rb
    # - https://courses.cs.washington.edu/courses/csep557/14au/tools/
    #     fltk_install.html
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    if koopa_is_linux
    then
        koopa_activate_opt_prefix \
            'freetype' \
            'xorg-xorgproto' \
            'xorg-xcb-proto' \
            'xorg-libpthread-stubs' \
            'xorg-libxau' \
            'xorg-libxdmcp' \
            'xorg-libxcb' \
            'xorg-libx11'
    fi
    # >     'xorg-xorgproto' \
    # >     'xorg-xtrans' \
    # >     'xorg-libpthread-stubs' \
    # >     'xorg-libxau' \
    # >     'xorg-libxdmcp' \
    # >     'xorg-libxcb' \
    # >     'xorg-libx11'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='fltk'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}-source.tar.gz"
    dict[url]="https://www.${dict[name]}.org/pub/${dict[name]}/\
${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    dict[opt_prefix]="$(koopa_opt_prefix)"
    dict[x11]="$(koopa_realpath "${dict[opt_prefix]}/xorg-libx11")"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-cairo'
        '--disable-xft'
        '--enable-shared'
        '--enable-threads'
    )
    if koopa_is_linux
    then
        conf_args+=(
            '--enable-x11'
            "--x-includes=${dict[x11]}/include"
            "--x-libraries=${dict[x11]}/lib"
        )
    elif koopa_is_macos
    then
        conf_args+=(
            '--disable-x11'
        )
    fi
    ./configure --help # FIXME
    # FIXME Remove these upon success.
    koopa_dl \
        'CFLAGS' "${CFLAGS:-}" \
        'CPPFLAGS' "${CPPFLAGS:-}" \
        'LDFLAGS' "${LDFLAGS:-}" \
        'LDLIBS' "${LDLIBS:-}" \
        'PKG_CONFIG_PATH' "${PKG_CONFIG_PATH:-}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
