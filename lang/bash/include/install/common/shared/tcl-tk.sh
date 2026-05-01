#!/usr/bin/env bash

main() {
    # """
    # Install Tcl/Tk.
    # @note Updated 2025-01-03.
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
    if _koopa_is_linux
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
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(_koopa_major_minor_version "${dict['version']}")"
    conf_args=(
        '--enable-shared'
        "--prefix=${dict['prefix']}"
    )
    dict['tcl_url']="https://koopa.acidgenomics.com/src/tcl/\
${dict['version']}.tar.gz"
    dict['tk_url']="https://koopa.acidgenomics.com/src/tk/\
${dict['version']}.tar.gz"
    _koopa_download "${dict['tcl_url']}" 'tcl.tar.gz'
    _koopa_download "${dict['tk_url']}" 'tk.tar.gz'
    _koopa_extract 'tcl.tar.gz' 'tcl-src'
    _koopa_extract 'tk.tar.gz' 'tk-src'
    (
        _koopa_cd 'tcl-src/unix'
        local -a tcl_conf_args
        tcl_conf_args+=(
            "${conf_args[@]}"
            '--enable-threads'
        )
        _koopa_make_build \
            --target='install' \
            --target='install-private-headers' \
            "${tcl_conf_args[@]}"
    )
    (
        local -a tk_conf_args
        tk_conf_args+=(
            "${conf_args[@]}"
            "--with-tcl=${dict['prefix']}/lib"
        )
        if _koopa_is_macos
        then
            tk_conf_args+=('--enable-aqua=yes')
        fi
        _koopa_cd 'tk-src/unix'
        _koopa_make_build \
            --target='install' \
            --target='install-private-headers' \
            "${tk_conf_args[@]}"
    )
    (
        # This is necessary for Lmod.
        _koopa_cd "${dict['prefix']}/bin"
        _koopa_ln "tclsh${dict['maj_min_ver']}" 'tclsh'
        _koopa_ln "wish${dict['maj_min_ver']}" 'wish'
    )
    return 0
}
