#!/usr/bin/env bash

main() {
    # """
    # Install Python.
    # @note Updated 2023-10-02.
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
    #   https://github.com/python/cpython/blob/3.12/configure
    # - macOS install recipes:
    #   https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/python@3.11.rb
    #   https://github.com/macports/macports-ports/blob/master/lang/
    #     python311/Portfile
    # - OpenSSL configuration issues:
    #   https://stackoverflow.com/questions/45954528/
    #   https://stackoverflow.com/questions/41328451/
    # """
    local -A app dict
    local -a conf_args deps
    koopa_activate_app --build-only 'make' 'pkg-config'
    deps+=('zlib')
    ! koopa_is_macos && deps+=('bzip2')
    deps+=(
        'expat'
        'libffi'
        'mpdecimal'
        'ncurses'
        'openssl3'
        'xz'
        'unzip'
        'gdbm'
        'sqlite'
        'libedit'
    )
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    koopa_mkdir \
        "${dict['prefix']}/bin" \
        "${dict['prefix']}/lib"
    koopa_add_to_path_start "${dict['prefix']}/bin"
    conf_args=(
        '--enable-ipv6'
        '--enable-loadable-sqlite-extensions'
        '--enable-optimizations'
        '--enable-shared'
        "--prefix=${dict['prefix']}"
        '--with-computed-gotos'
        '--with-dbmliborder=gdbm:ndbm'
        '--with-ensurepip=install'
        "--with-openssl=${dict['openssl']}"
        '--with-system-expat'
        '--with-system-libmpdec'
        'PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1'
        # Avoid OpenSSL checks that are problematic for Python 3.11.0.
        # https://github.com/python/cpython/issues/98673
        'ac_cv_working_openssl_hashlib=yes'
        'ac_cv_working_openssl_ssl=yes'
        # Disable the optional tkinter module.
        'py_cv_module__tkinter=disabled'
    )
    if koopa_is_macos
    then
        app['dtrace']='/usr/sbin/dtrace'
        koopa_assert_is_executable "${app['dtrace']}"
        conf_args+=("--with-dtrace=${app['dtrace']}")
    fi
    dict['url']="https://www.python.org/ftp/python/${dict['version']}/\
Python-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    # Override auto-detection of libmpdec, which assumes a universal build.
    # https://github.com/python/cpython/issues/98557.
    if koopa_is_macos
    then
        dict['arch']="$(koopa_arch)"
        case "${dict['arch']}" in
            'aarch64' | 'arm64')
                dict['decimal_arch']='uint128'
                ;;
            'x86_64')
                dict['decimal_arch']='x64'
                ;;
            *)
                koopa_stop 'Unsupported architecture.'
                ;;
        esac
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='libmpdec_machine=universal' \
            --replacement="libmpdec_machine=${dict['decimal_arch']}" \
            'configure'
        export PYTHON_DECIMAL_WITH_MACHINE="${dict['decimal_arch']}"
    fi
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    app['python']="${dict['prefix']}/bin/python${dict['maj_min_ver']}"
    koopa_assert_is_installed "${app['python']}"
    "${app['python']}" -m sysconfig
    koopa_check_shared_object --file="${app['python']}"
    koopa_alert 'Checking module integrity.'
    "${app['python']}" -c 'import _bz2'
    "${app['python']}" -c 'import _ctypes'
    "${app['python']}" -c 'import _decimal'
    "${app['python']}" -c 'import _gdbm'
    "${app['python']}" -c 'import hashlib'
    "${app['python']}" -c 'import pyexpat'
    "${app['python']}" -c 'import readline'
    "${app['python']}" -c 'import sqlite3'
    "${app['python']}" -c 'import ssl'
    "${app['python']}" -c 'import zlib'
    koopa_alert 'Checking pip configuration.'
    "${app['python']}" -m pip list --format='columns'
    return 0
}
