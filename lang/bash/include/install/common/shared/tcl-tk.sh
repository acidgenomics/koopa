#!/usr/bin/env bash

main() {
    # """
    # Install Tcl/Tk.
    # @note Updated 2023-06-02.
    #
    # @seealso
    # - https://www.tcl.tk/software/tcltk/download.html
    # - https://www.tcl.tk/doc/howto/compile.html
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/tcl-tk.rb
    # - https://github.com/macports/macports-ports/blob/master/lang/tcl/Portfile
    # - https://github.com/macports/macports-ports/blob/master/x11/tk/Portfile
    # """
    local -A dict
    local -a conf_args deps
    deps=('zlib')
    if koopa_is_linux
    then
        deps+=(
            'xorg-xorgproto'
            'xorg-xcb-proto'
            'xorg-libpthread-stubs'
            'xorg-libxau'
            'xorg-libxdmcp'
            'xorg-libxcb'
            'xorg-libx11'
        )
    fi
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    conf_args=(
        '--disable-static'
        '--enable-shared'
        '--enable-threads'
        "--prefix=${dict['prefix']}"
    )
    dict['tcl_url']="https://downloads.sourceforge.net/project/tcl/Tcl/\
${dict['version']}/tcl${dict['version']}-src.tar.gz"
    dict['tk_url']="https://downloads.sourceforge.net/project/tcl/Tcl/\
${dict['version']}/tk${dict['version']}-src.tar.gz"
    koopa_download "${dict['tcl_url']}"
    koopa_download "${dict['tk_url']}"
    koopa_extract "$(koopa_basename "${dict['tcl_url']}")" 'tcl-src'
    koopa_extract "$(koopa_basename "${dict['tk_url']}")" 'tk-src'
    (
        koopa_cd 'tcl-src/unix'
        koopa_make_build \
            --target='install' \
            --target='install-private-headers' \
            "${conf_args[@]}"
    )
    (
        local tk_conf_args
        tk_conf_args=(
            "${conf_args[@]}"
            "--with-tcl=${dict['prefix']}/lib"
        )
        if koopa_is_macos
        then
            tk_conf_args+=('--enable-aqua=yes')
        fi
        koopa_cd 'tk-src/unix'
        koopa_make_build \
            --target='install' \
            --target='install-private-headers' \
            "${tk_conf_args[@]}"
    )
    (
        # This is necessary for Lmod.
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln "tclsh${dict['maj_min_ver']}" 'tclsh'
        koopa_ln "wish${dict['maj_min_ver']}" 'wish'
    )
    return 0
}
