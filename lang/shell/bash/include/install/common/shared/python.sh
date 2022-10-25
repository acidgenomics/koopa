#!/usr/bin/env bash

# FIXME Python 3.11 is not configuring ssl module correctly on macOS.
#
# Here are links to differences in configure script between 3.10 and 3.11:
# - https://github.com/python/cpython/blob/3.10/configure#L17844
# - https://github.com/python/cpython/blob/3.11/configure#L23194
#
# This is correct on Linux, erroring on macOS...
# checking whether OpenSSL provides required ssl module APIs... no
# checking whether OpenSSL provides required hashlib module APIs... no
#
# We're seeing ssl detection failure on macOS. Works on Linux though.
# MODULE__SSL_STATE = "missing"
#
# > WARNING: pip is configured with locations that require TLS/SSL,
# > however the ssl module in Python is not available.
# > "Can't connect to HTTPS URL because the SSL module is not available.
#
# >>> import ssl
# Traceback (most recent call last):
#   File "<stdin>", line 1, in <module>
#   File "/opt/koopa/app/python/3.11.0/libexec/Python.framework/Versions/3.11/lib/python3.11/ssl.py", line 100, in <module>
#     import _ssl             # if we can't import it, let the error propagate
#     ^^^^^^^^^^^
# ModuleNotFoundError: No module named '_ssl'

# FIXME tcl-tk doesn't seem to be getting picked up correctly for Python 3.11?
# Missing from sysconfig when comparing 3.10 to 3.11:
# > TCLTK_INCLUDES = "-I/opt/koopa/app/tcl-tk/8.6.12/include"
# > TCLTK_LIBS = "-L/opt/koopa/app/tcl-tk/8.6.12/lib"

main() {
    # """
    # Install Python.
    # @note Updated 2022-10-25.
    #
    # Python includes '/usr/local' in '-I' and '-L' compilation arguments by
    # default. We should work on restricting this in a future build.
    #
    # Check config with:
    # > ldd /usr/local/bin/python3
    #
    # 'make altinstall' target prevents the installation of files with only
    # Python's major version in its name. This allows us to link multiple
    # versioned Python formulae. 'make install' can overwrite or masquerade the
    # python3 binary. 'make altinstall' is therefore recommended instead of
    # 'make install' since it only installs 'exec_prefix/bin/pythonversion'.
    #
    # To customize g++ path, specify 'CXX' environment variable
    # or use '--with-cxx-main=/usr/bin/g++'.
    #
    # Consider adding a system check for zlib in a future update.
    #
    # See also:
    # - https://devguide.python.org/
    # - https://docs.python.org/3/using/unix.html
    # - https://docs.brew.sh/Homebrew-and-Python
    # - Installing multiple versions:
    #   https://github.com/python/cpython#installing-multiple-versions
    # - Latest configuration recipe:
    #   https://github.com/python/cpython/blob/3.11/configure
    # - macOS install recipes:
    #   https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/python@3.10.rb
    #   https://github.com/macports/macports-ports/blob/master/lang/
    #     python310/Portfile
    # - Python lib needs to be in rpath:
    #   https://stackoverflow.com/questions/43333207
    #   https://bugs.python.org/issue36659
    # - Python 3.11 update:
    #   https://github.com/Homebrew/homebrew-core/pull/113811
    # - OpenSSL configuration issues:
    #   https://stackoverflow.com/questions/45954528/
    #   https://stackoverflow.com/questions/41328451/
    # """
    local app deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
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
        # libedit deps: ncurses.
        'libedit'
        # gdbm deps: readline.
        'gdbm'
        # sqlite deps: readline.
        'sqlite'
        'tcl-tk'
    )
    koopa_activate_app "${deps[@]}"
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
        '--with-computed-gotos'
        '--with-dbmliborder=gdbm:ndbm'
        '--with-ensurepip=install' # or 'upgrade'.
        '--with-lto'
        "--with-openssl=${dict['openssl']}"
        "--with-openssl-rpath=${dict['openssl']}/lib" # or 'auto'.
        '--with-readline=editline'
        '--with-system-expat'
        '--with-system-ffi'
        '--with-system-libmpdec'
        # NOTE This option has been removed in Python 3.11.
        "--with-tcltk-includes=-I${dict['tcl_tk']}/include"
        # NOTE This option has been removed in Python 3.11.
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
    conf_args+=(
        'PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1'
        # > 'SETUPTOOLS_USE_DISTUTILS=stdlib'
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
    # Ensure 'python' symlink exists. Otherwise some programs, such as GATK can
    # break due to lack of correct 'python' binary in PATH.
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln "${dict['name']}${dict['maj_min_ver']}" "${dict['name']}"
    )
    "${app['python']}" -m sysconfig
    koopa_check_shared_object --file="${app['python']}"
    koopa_alert 'Checking OpenSSL configuration of ssl module.'
    "${app['python']}" -c 'import ssl'
    koopa_alert 'Checking pip configuration.'
    "${app['python']}" -m pip --version
    return 0
}
