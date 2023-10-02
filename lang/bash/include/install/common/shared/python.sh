#!/usr/bin/env bash

# NOTE Python 3.12 no longer installs setuptools by default:
# https://twitter.com/VictorStinner/status/1654124014632321025

# FIXME Need to take out this option:
# configure: WARNING: unrecognized options: --with-system-ffi

# FIXME Hitting a decimal-related build error with clang:
#
# ./Modules/_decimal/_decimal.c:4724:32: error: use of undeclared identifier 'inv10_p'
#         mpd_qpowmod(exp_hash, &inv10_p, tmp, &p, &maxctx, &status);
#                               ^
# ./Modules/_decimal/_decimal.c:4724:47: error: use of undeclared identifier 'p'
#         mpd_qpowmod(exp_hash, &inv10_p, tmp, &p, &maxctx, &status);
#                                              ^
# ./Modules/_decimal/_decimal.c:4739:25: error: use of undeclared identifier 'p'
#     mpd_qrem(tmp, tmp, &p, &maxctx, &status);
#                        ^
# 5 errors generated.
# clang: warning: argument unused during compilation: '-fno-semantic-interposition' [-Wunused-command-line-argument]
# gmake[2]: *** [Makefile:3012: Modules/_decimal/_decimal.o] Error 1
# gmake[2]: *** Waiting for unfinished jobs....

# Draft Homebrew pull request:
#
# https://github.com/Homebrew/homebrew-core/pull/149142
# https://github.com/Homebrew/homebrew-core/pull/149142/files#diff-2b638765de0666dff89595d3c97c19db17cf1f1b33d320ea7ba9e81be89372a1

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
    local -A app dict
    local -a conf_args deps
    koopa_activate_app --build-only 'make' 'pkg-config'
    deps=(
        'zlib'
        'bzip2'
        'expat'
        'libffi'
        'mpdecimal'
        'ncurses'
        'openssl3'
        'xz'
        'unzip'
        'libedit'
        'gdbm'
        'sqlite'
    )
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir \
        "${dict['bzip2']}" \
        "${dict['openssl']}"
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
        '--with-readline=editline'
        '--with-system-expat'
        '--with-system-ffi'
        '--with-system-libmpdec'
    )
    if koopa_is_macos
    then
        app['dtrace']='/usr/sbin/dtrace'
        koopa_assert_is_executable "${app['dtrace']}"
        conf_args+=(
            "--with-dtrace=${app['dtrace']}"
            '--with-lto'
        )
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
        "${dict['bzip2']}/lib"
    dict['url']="https://www.python.org/ftp/python/${dict['version']}/\
Python-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    if koopa_is_macos
    then
        # Override auto-detection of libmpdec, which assumes a universal build.
        # https://github.com/python/cpython/issues/98557.
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
        export PYTHON_DECIMAL_WITH_MACHINE="${dict['decimal_arch']}"
        case "${dict['version']}" in
            '3.11.'*)
                koopa_find_and_replace_in_file \
                    --fixed \
                    --pattern='libmpdec_machine=universal' \
                    --replacement="libmpdec_machine=${dict['decimal_arch']}" \
                    'configure'
                ;;
        esac
    fi
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" altinstall
    app['python']="${dict['prefix']}/bin/python${dict['maj_min_ver']}"
    koopa_assert_is_installed "${app['python']}"
    case "${dict['version']}" in
        '3.11.'*)
            koopa_rm "${dict['prefix']}/bin/pip3.10"
            ;;
    esac
    "${app['python']}" -m sysconfig
    koopa_check_shared_object --file="${app['python']}"
    koopa_alert 'Checking module integrity.'
    case "${dict['version']}" in
        '3.9.'*)
            ;;
        *)
            "${app['python']}" -c 'import _decimal'
            ;;
    esac
    "${app['python']}" -c 'import _ctypes'
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
