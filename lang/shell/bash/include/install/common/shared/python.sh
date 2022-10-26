#!/usr/bin/env bash

main() {
    # """
    # Install Python.
    # @note Updated 2022-10-26.
    #
    # 'make altinstall' target prevents the installation of files with only
    # Python's major version in its name. This allows us to link multiple
    # versioned Python formulae. 'make install' can overwrite or masquerade the
    # python3 binary.
    #
    # Python includes '/usr/local' in '-I' and '-L' compilation arguments by
    # default. We should work on restricting this in a future build.
    #
    # To customize g++ path, specify 'CXX' environment variable
    # or use '--with-cxx-main=/usr/bin/g++'.
    #
    # Enabling LTO on Linux makes 'libpython3.*.a' unusable for anyone whose
    # GCC install does not match exactly (major and minor version).
    # https://github.com/orgs/Homebrew/discussions/3734
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
    #   https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/python@3.11.rb
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
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['bzip2']}" \
        "${dict['openssl']}"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
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
        "--with-openssl=${dict['openssl']}"
        # NOTE Currently uses '-Wl,-rpath=' instead of '-Wl,-rpath,' on macOS,
        # which is incorrect for clang.
        # '--with-openssl-rpath=auto'
        '--with-readline=editline'
        '--with-system-expat'
        '--with-system-ffi'
        '--with-system-libmpdec'
    )
    if koopa_is_macos
    then
        app['dtrace']='/usr/sbin/dtrace'
        [[ -x "${app['dtrace']}" ]] || return 1
        dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
        conf_args+=(
            "--enable-framework=${dict['libexec']}"
            "--with-dtrace=${app['dtrace']}"
            '--with-lto'
        )
        # Override auto-detection of libmpdec, which assumes a universal build.
        # https://github.com/python/cpython/issues/98557.
        dict['arch']="$(koopa_arch)"
        case "${dict['arch']}" in
            'aarch64')
                dict['decimal_arch']='uint128'
                ;;
            'x86_64')
                dict['decimal_arch']='x64'
                ;;
            *)
                koopa_stop 'Unsupported architecture.'
                ;;
        esac
        export PYTHON_DECIMAL_WITH_MACHINE="${dict['decimal_arch']}"
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='libmpdec_machine=universal' \
            --replacement="libmpdec_machine=${dict['decimal_arch']}" \
            'configure'
    else
        conf_args+=('--enable-shared')
    fi
    conf_args+=(
        'PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1'
        # This is defined in the MacPorts recipe.
        # > 'SETUPTOOLS_USE_DISTUTILS=stdlib'
        # Avoid OpenSSL checks that are problematic for Python 3.11.0.
        # https://github.com/python/cpython/issues/98673
        'ac_cv_working_openssl_hashlib=yes'
        'ac_cv_working_openssl_ssl=yes'
        'py_cv_module__tkinter=disabled'
    )
    koopa_add_rpath_to_ldflags \
        "${dict['prefix']}/lib" \
        "${dict['bzip2']}/lib" \
        "${dict['openssl']}/lib"
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    if koopa_is_macos
    then
        "${app['make']}" altinstall PYTHONAPPSDIR="${dict['libexec']}"
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
        "${app['make']}" altinstall
    fi
    app['python']="${dict['prefix']}/bin/${dict['name']}${dict['maj_min_ver']}"
    koopa_assert_is_installed "${app['python']}"
    # Ensure 'python' symlink exists. Otherwise some programs, such as GATK can
    # break due to lack of correct 'python' binary in PATH.
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln \
            "${dict['name']}${dict['maj_min_ver']}" \
            "${dict['name']}${dict['maj_ver']}"
        koopa_ln \
            "${dict['name']}${dict['maj_min_ver']}" \
            "${dict['name']}"
    )
    "${app['python']}" -m sysconfig
    koopa_check_shared_object --file="${app['python']}"
    koopa_alert 'Checking module integrity.'
    "${app['python']}" -c 'import _ctypes'
    "${app['python']}" -c 'import _decimal'
    "${app['python']}" -c 'import _gdbm'
    "${app['python']}" -c 'import hashlib'
    "${app['python']}" -c 'import pyexpat'
    "${app['python']}" -c 'import sqlite3'
    "${app['python']}" -c 'import ssl'
    "${app['python']}" -c 'import zlib'
    koopa_alert 'Checking pip configuration.'
    "${app['python']}" -m pip list --format='columns'
    return 0
}
