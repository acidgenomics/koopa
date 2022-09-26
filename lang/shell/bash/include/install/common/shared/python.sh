#!/usr/bin/env bash

# FIXME Consider including mpdecimal for macOS.
#
# FIXME _bz2 import is failing on Ubuntu 22.
# Need to resolve this without installing system package. 
#
# NOTE Consider including support for:
# - libxcrypt
# - mpdecimal
# - unzip
#
# FIXME Consider including libnsl on Linux.
#
# NOTE Consider cleaning this up on macOS:
# clang: warning: argument unused during compilation:
# '-fno-semantic-interposition' [-Wunused-command-line-argument]
#
# NOTE Likely need to implement this to fix ncurses location on Linux:
# > inreplace "configure",
# >     'CPPFLAGS="$CPPFLAGS -I/usr/include/ncursesw"',
# >     "CPPFLAGS=\"$CPPFLAGS -I#{Formula["ncurses"].opt_include}\""

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
        # ncurses deps: none.
        'ncurses'
        # openssl3 deps: none.
        'openssl3'
        # xz deps: none.
        'xz'
        # FIXME Inclusion of readline is currently causing a build error on macOS.s
        # readline deps: ncurses.
        # > 'readline'
        # gdbm deps: readline.
        #'gdbm'
        # sqlite deps: readline.
        #'sqlite'
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
        ['version']="${KOOPA_INSTALL_VERSION:?}"
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
        # > '--with-system-libmpdec'
        "--prefix=${dict['prefix']}"
        '--enable-ipv6'
        '--enable-shared'
        # FIXME Is this the problem on macOS??
        # > '--enable-loadable-sqlite-extensions'
        '--enable-optimizations'
        # > '--with-dbmliborder=gdbm:ndbm'
        '--with-ensurepip'
        '--with-lto'
        "--with-openssl=${dict['openssl']}"
        '--with-openssl-rpath=auto'
        '--with-system-expat'
        '--with-system-ffi'
    )
    if koopa_is_macos
    then
        # FIXME What if we enable the framework?
        conf_args+=(
            '--enable-framework'
            '--with-dtrace=/usr/sbin/dtrace'
        )
    fi
    # NOTE May need to set 'CFLAGS_NODIST' and 'LDFLAGS_NODIST' here.
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
    # > "${app['make']}" test
    
    # FIXME May need to do this for macOS.
    # > system "make", "install", "PYTHONAPPSDIR=#{prefix}"
    # > system "make", "frameworkinstallextras", "PYTHONAPPSDIR=#{pkgshare}" if OS.mac?
    
    # Use 'altinstall' here instead?
    "${app['make']}" install
    app['python']="${dict['prefix']}/bin/${dict['name']}${dict['maj_min_ver']}"
    koopa_assert_is_installed "${app['python']}"
    "${app['python']}" -m sysconfig
    koopa_check_shared_object --file="${app['python']}"
    return 0
}
