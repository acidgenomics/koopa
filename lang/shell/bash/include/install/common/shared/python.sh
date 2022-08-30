#!/usr/bin/env bash

# FIXME _bz2 import is failing on Ubuntu 22.
# Need to resolve this without installing system package.

# NOTE It looks like Python includes '/usr/local' in '-I' and '-L' compilation
# arguments by default. We should work on restricting this in a future build.

# NOTE Consider including support for:
# - libxcrypt
# - mpdecimal
# - unzip

# NOTE Consider cleaning this up on macOS:
# clang: warning: argument unused during compilation:
# '-fno-semantic-interposition' [-Wunused-command-line-argument]

# NOTE Likely need to implement this to fix ncurses location on Linux:
# > inreplace "configure",
# >     'CPPFLAGS="$CPPFLAGS -I/usr/include/ncursesw"',
# >     "CPPFLAGS=\"$CPPFLAGS -I#{Formula["ncurses"].opt_include}\""

# NOTE Now seeing this warning:
# > warning: "_XOPEN_SOURCE" redefined

main() {
    # """
    # Install Python.
    # @note Updated 2022-08-30.
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
        # ncurses deps: none.
        'ncurses'
        # openssl3 deps: none.
        'openssl3'
        # xz deps: none.
        'xz'
        # readline deps: ncurses.
        'readline'
        # gdbm deps: readline.
        'gdbm'
        # sqlite deps: readline.
        'sqlite'
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
        ['prefix']="${INSTALL_PREFIX:?}"
        ['version']="${INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['bzip2']}" \
        "${dict['openssl']}"
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
        '--enable-shared'
        '--with-dbmliborder=gdbm:ndbm'
        '--with-ensurepip'
        '--with-lto'
        "--with-openssl=${dict['openssl']}"
        '--with-openssl-rpath=auto'
    )
    if koopa_is_macos
    then
        conf_args+=(
            '--disable-framework'
            '--with-dtrace'
        )
    fi
    conf_args+=(
        "CFLAGS=${CFLAGS:-}"
        "LDFLAGS=${LDFLAGS:-}"
    )
    koopa_add_rpath_to_ldflags \
        "${dict['prefix']}/lib" \
        "${dict['bzip2']}/lib"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    # > "${app['make']}" test
    # Use 'altinstall' here instead?
    "${app['make']}" install
    app['python']="${dict['prefix']}/bin/${dict['name']}${dict['maj_min_ver']}"
    koopa_assert_is_installed "${app['python']}"
    "${app['python']}" -m sysconfig
    koopa_check_shared_object --file="${app['python']}"
    return 0
}
