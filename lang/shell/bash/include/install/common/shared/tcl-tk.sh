#!/usr/bin/env bash

main() {
    # """
    # Install Tcl/Tk.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://www.tcl.tk/software/tcltk/download.html
    # - https://www.tcl.tk/doc/howto/compile.html
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/tcl-tk.rb
    # - https://github.com/macports/macports-ports/blob/master/lang/tcl/Portfile
    # - https://github.com/macports/macports-ports/blob/master/x11/tk/Portfile
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app 'zlib'
    if koopa_is_linux
    then
        koopa_activate_app --build-only 'make' 'pkg-config'
        koopa_activate_app \
            'xorg-xorgproto' \
            'xorg-xcb-proto' \
            'xorg-libpthread-stubs' \
            'xorg-libxau' \
            'xorg-libxdmcp' \
            'xorg-libxcb' \
            'xorg-libx11'
    fi
    local -A app
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url_stem']='https://prdownloads.sourceforge.net/tcl'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    conf_args=(
        '--disable-static'
        '--enable-shared'
        '--enable-threads'
        "--prefix=${dict['prefix']}"
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    dict['tcl_file']="tcl${dict['version']}-src.tar.gz"
    dict['tcl_url']="${dict['url_stem']}/${dict['tcl_file']}"
    koopa_download "${dict['tcl_url']}" "${dict['tcl_file']}"
    koopa_extract "${dict['tcl_file']}"
    (
        koopa_cd "tcl${dict['version']}/unix"
        ./configure --help
        ./configure "${conf_args[@]}"
        "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
        "${app['make']}" install
        "${app['make']}" install-private-headers
    )
    dict['tk_file']="tk${dict['version']}-src.tar.gz"
    dict['tk_url']="${dict['url_stem']}/${dict['tk_file']}"
    koopa_download "${dict['tk_url']}" "${dict['tk_file']}"
    koopa_extract "${dict['tk_file']}"
    (
        local conf_args_2
        conf_args_2=(
            "${conf_args[@]}"
            "--with-tcl=${dict['prefix']}/lib"
        )
        if koopa_is_macos
        then
            conf_args_2+=('--enable-aqua=yes')
        fi
        koopa_cd "tk${dict['version']}/unix"
        ./configure --help
        ./configure "${conf_args_2[@]}"
        "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
        "${app['make']}" install
        "${app['make']}" install-private-headers
    )
    (
        koopa_cd "${dict['prefix']}/bin"
        # This is necessary for Lmod install.
        koopa_ln "tclsh${dict['maj_min_ver']}" 'tclsh'
        koopa_ln "wish${dict['maj_min_ver']}" 'wish'
    )
    return 0
}
