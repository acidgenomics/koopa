#!/usr/bin/env bash

main() {
    # """
    # Install Tcl/Tk.
    # @note Updated 2023-03-19.
    #
    # @seealso
    # - https://www.tcl.tk/software/tcltk/download.html
    # - https://www.tcl.tk/doc/howto/compile.html
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/tcl-tk.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app 'zlib'
    if koopa_is_linux
    then
        koopa_activate_app --build-only 'pkg-config'
        koopa_activate_app \
            'xorg-xorgproto' \
            'xorg-xcb-proto' \
            'xorg-libpthread-stubs' \
            'xorg-libxau' \
            'xorg-libxdmcp' \
            'xorg-libxcb' \
            'xorg-libx11'
    fi
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['url_stem']='https://prdownloads.sourceforge.net/tcl'
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--enable-shared'
        '--enable-threads'
        # This fails on Apple Silicon, so disabling.
        # > '--enable-64bit'
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
            '--without-x'
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
    return 0
}
