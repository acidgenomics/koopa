#!/usr/bin/env bash

# FIXME Seeing this warning on macOS, likely need to tweak config:
# # Failed to build these modules:
# # _decimal              _tkinter
#
# FIXME Now seeing lots of this warning on macOS:
# ld: warning: -undefined dynamic_lookup may not work with chained fixups
#
# FIXME Still seeing this warning on macOS:
# clang: warning: argument unused during compilation: '-fno-semantic-interposition' [-Wunused-command-line-argument]

main() {
    # """
    # Install Python.
    # @note Updated 2022-09-26.
    #
    # Python includes '/usr/local' in '-I' and '-L' compilation arguments by
    # default. We should work on restricting this in a future build.
    #
    # Check config with:
    # > ldd /usr/local/bin/python3
    #
    # Warning: 'make install' can overwrite or masquerade the python3 binary.
    # 'make altinstall' is therefore recommended instead of make install since
    # it only installs 'exec_prefix/bin/pythonversion'.
    #
    # To customize g++ path, specify 'CXX' environment variable
    # or use '--with-cxx-main=/usr/bin/g++'.
    #
    # Consider adding a system check for zlib in a future update.
    #
    # See also:
    # - https://docs.python.org/3/using/unix.html
    # - https://stackoverflow.com/questions/43333207
    # - https://bugs.python.org/issue36659
    # """
    local app deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    deps=(
        # zlib deps: none.
        'zlib'
        # bzip2 deps: none.
        'bzip2'
        # expat deps: none.
        'expat'
        # libffi deps: none.
        'libffi'
        # mpdecimal deps: none.
        'mpdecimal'
        # ncurses deps: none.
        'ncurses'
        # openssl3 deps: none.
        'openssl3'
        # xz deps: none.
        'xz'
        # unzip deps: none.
        'unzip'
    )
    # Inclusion of readline is currently causing a cryptic build error on
    # macOS that is difficult to debug.
    if koopa_is_linux
    then
        deps+=(
            # readline deps: ncurses.
            'readline'
        )
    fi
    deps+=(
        # gdbm deps: readline.
        'gdbm'
        # sqlite deps: readline.
        'sqlite'
        'tcl-tk'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['bzip2']="$(koopa_app_prefix 'bzip2')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='python'
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['tcl_tk']="$(koopa_app_prefix 'tcl-tk')"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['bzip2']}" \
        "${dict['openssl']}" \
        "${dict['tcl_tk']}"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['file']="Python-${dict['version']}.tar.xz"
    dict['url']="https://www.python.org/ftp/${dict['name']}/${dict['version']}/\
${dict['file']}"
    koopa_mkdir \
        "${dict['prefix']}/bin" \
        "${dict['prefix']}/lib"
    koopa_add_to_path_start "${dict['prefix']}/bin"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "Python-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--enable-ipv6'
        '--enable-loadable-sqlite-extensions'
        '--enable-optimizations'
        '--with-dbmliborder=gdbm:ndbm'
        '--with-ensurepip=install' # or 'upgrade'.
        '--with-lto'
        "--with-openssl=${dict['openssl']}"
        '--with-openssl-rpath=auto'
        '--with-system-expat'
        '--with-system-ffi'
        '--with-system-libmpdec'
        "--with-tcltk-includes=-I${dict['tcl_tk']}/include"
        "--with-tcltk-libs=-L${dict['tcl_tk']}/lib"
    )
    if koopa_is_macos
    then
        app['dtrace']='/usr/sbin/dtrace'
        [[ -x "${app['dtrace']}" ]] || return 1
        dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
        conf_args+=(
            "--enable-framework=${dict['libexec']}"
            "--with-dtrace=${app['dtrace']}"
        )
    else
        conf_args+=('--enable-shared')
    fi
    # Can also set 'CFLAGS_NODIST', 'LDFLAGS_NODIST' here.
    conf_args+=(
        "CFLAGS=${CFLAGS:-}"
        "CPPFLAGS=${CPPFLAGS:-}"
        "LDFLAGS=${LDFLAGS:-}"
    )
    koopa_add_rpath_to_ldflags \
        "${dict['prefix']}/lib" \
        "${dict['bzip2']}/lib"
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    if koopa_is_macos
    then
        "${app['make']}" install PYTHONAPPSDIR="${dict['libexec']}"
        (
            local framework
            koopa_cd "${dict['prefix']}"
            framework="libexec/Python.framework/Versions/${dict['maj_min_ver']}"
            koopa_assert_is_dir "$framework"
            koopa_ln "${framework}/bin" 'bin'
            koopa_ln "${framework}/include" 'include'
            koopa_ln "${framework}/lib" 'lib'
            koopa_ln "${framework}/share" 'share'
        )
    else
        # > "${app['make']}" test
        "${app['make']}" install
    fi
    app['python']="${dict['prefix']}/bin/${dict['name']}${dict['maj_min_ver']}"
    koopa_assert_is_installed "${app['python']}"
    "${app['python']}" -m sysconfig
    koopa_check_shared_object --file="${app['python']}"
    return 0
}
