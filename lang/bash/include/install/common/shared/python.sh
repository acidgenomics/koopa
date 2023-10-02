#!/usr/bin/env bash

# FIXME Now our bzip2 import is failing?
#Following modules built successfully but were removed because they could not be imported: _bz2

# FIXME bz2 is failing on 3.12 for macOS:
# install: Modules/_bz2.cpython-312-darwin.so: No such file or directory
# gmake: *** [Makefile:2084: sharedinstall] Error 71

# FIXME Install without sqlite, for speed.

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

# How to suppress this for clang?
# clang: warning: argument unused during compilation: '-fno-semantic-interposition' [-Wunused-command-line-argument]

# Now seeing this with 3.12 update:
# clang: warning: argument unused during compilation: '-fno-semantic-interposition' [-Wunused-command-line-argument]
# clang: warning: argument unused during compilation: '-fno-semantic-interposition' [-Wunused-command-line-argument]
# gcc  -I./Modules/_hacl/include -D_BSD_SOURCE -D_DEFAULT_SOURCE -fno-strict-overflow -Wsign-compare -Wunreachable-code -DNDEBUG -g -O3 -Wall    -fno-semantic-interposition -flto -std=c11 -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -Wstrict-prototypes -Werror=implicit-function-declaration -fvisibility=hidden -fprofile-instr-generate -I./Include/internal  -I. -I./Include -I/opt/koopa/app/zlib/1.3/include -I/opt/koopa/app/bzip2/1.0.8/include -I/opt/koopa/app/expat/2.5.0/include -I/opt/koopa/app/libffi/3.4.4/include -I/opt/koopa/app/mpdecimal/2.5.1/include -D_DARWIN_C_SOURCE -DNCURSES_WIDECHAR -D_DARWIN_C_SOURCE -DNCURSES_WIDECHAR -D_DARWIN_C_SOURCE -DNCURSES_WIDECHAR -D_DARWIN_C_SOURCE -DNCURSES_WIDECHAR -D_DARWIN_C_SOURCE -DNCURSES_WIDECHAR -I/opt/koopa/app/ncurses/6.4/include/ncursesw -I/opt/koopa/app/ncurses/6.4/include -I/opt/koopa/app/ncurses/6.4/include/ncursesw -I/opt/koopa/app/ncurses/6.4/include -I/opt/koopa/app/ncurses/6.4/include/ncursesw -I/opt/koopa/app/ncurses/6.4/include -I/opt/koopa/app/ncurses/6.4/include/ncursesw -I/opt/koopa/app/ncurses/6.4/include -I/opt/koopa/app/ncurses/6.4/include/ncursesw -I/opt/koopa/app/ncurses/6.4/include -I/opt/koopa/app/openssl3/3.1.3/include -I/opt/koopa/app/xz/5.4.4/include -I/opt/koopa/app/libedit/20230828-3.1/include -I/opt/koopa/app/libedit/20230828-3.1/include/editline -I/opt/koopa/app/gdbm/1.23/include -I/opt/koopa/app/sqlite/3.43.0/include  -I/opt/koopa/app/zlib/1.3/include -I/opt/koopa/app/bzip2/1.0.8/include -I/opt/koopa/app/expat/2.5.0/include -I/opt/koopa/app/libffi/3.4.4/include -I/opt/koopa/app/mpdecimal/2.5.1/include -D_DARWIN_C_SOURCE -DNCURSES_WIDECHAR -D_DARWIN_C_SOURCE -DNCURSES_WIDECHAR -D_DARWIN_C_SOURCE -DNCURSES_WIDECHAR -D_DARWIN_C_SOURCE -DNCURSES_WIDECHAR -D_DARWIN_C_SOURCE -DNCURSES_WIDECHAR -I/opt/koopa/app/ncurses/6.4/include/ncursesw -I/opt/koopa/app/ncurses/6.4/include -I/opt/koopa/app/ncurses/6.4/include/ncursesw -I/opt/koopa/app/ncurses/6.4/include -I/opt/koopa/app/ncurses/6.4/include/ncursesw -I/opt/koopa/app/ncurses/6.4/include -I/opt/koopa/app/ncurses/6.4/include/ncursesw -I/opt/koopa/app/ncurses/6.4/include -I/opt/koopa/app/ncurses/6.4/include/ncursesw -I/opt/koopa/app/ncurses/6.4/include -I/opt/koopa/app/openssl3/3.1.3/include -I/opt/koopa/app/xz/5.4.4/include -I/opt/koopa/app/libedit/20230828-3.1/include -I/opt/koopa/app/libedit/20230828-3.1/include/editline -I/opt/koopa/app/gdbm/1.23/include -I/opt/koopa/app/sqlite/3.43.0/include   -c ./Modules/_hacl/Hacl_Hash_SHA1.c -o Modules/_hacl/Hacl_Hash_SHA1.o
# clang: warning: argument unused during compilation: '-fno-semantic-interposition' [-Wunused-command-line-argument]
# ./Modules/readline.c:448:21: error: expected expression
#         (VFunction *)on_completion_display_matches_hook : 0;
#                     ^
# ./Modules/readline.c:448:10: error: use of undeclared identifier 'VFunction'; did you mean 'function'?
#         (VFunction *)on_completion_display_matches_hook : 0;
#          ^~~~~~~~~
#          function
# ./Modules/readline.c:434:61: note: 'function' declared here
#                                                   PyObject *function)
#                                                             ^
# ./Modules/readline.c:448:22: error: expected ':'
#         (VFunction *)on_completion_display_matches_hook : 0;
#                      ^
#                      :
# ./Modules/readline.c:444:63: note: to match this '?'
#         readlinestate_global->completion_display_matches_hook ?
#                                                               ^
# ./Modules/readline.c:1018:16: warning: a function declaration without a prototype is deprecated in all versions of C [-Wstrict-prototypes]
# on_startup_hook()
#                ^
#                 void
# ./Modules/readline.c:1033:18: warning: a function declaration without a prototype is deprecated in all versions of C [-Wstrict-prototypes]
# on_pre_input_hook()
#                  ^
#                   void
# 2 warnings and 3 errors generated.
# gmake[2]: *** [Makefile:3026: Modules/readline.o] Error 1
# gmake[2]: *** Waiting for unfinished jobs....
# clang: warning: argument unused during compilation: '-fno-semantic-interposition' [-Wunused-command-line-argument]
# gmake[2]: Leaving directory '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/tmp.vs2GHGXd1K/src'
# gmake[1]: *** [Makefile:798: profile-gen-stamp] Error 2
# gmake[1]: Leaving directory '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/tmp.vs2GHGXd1K/src'
# gmake: *** [Makefile:810: profile-run-stamp] Error 2

# FIXME How to clean up the duplicate rpath here?
# Does this only happen when we enable LTO?
# ld: warning: duplicate -rpath '/opt/koopa/app/bzip2/1.0.8/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/bzip2/1.0.8/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/python3.12/3.12.0/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/sqlite/3.43.0/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/gdbm/1.23/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/libedit/20230828-3.1/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/xz/5.4.4/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/openssl3/3.1.3/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/ncurses/6.4/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/mpdecimal/2.5.1/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/libffi/3.4.4/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/expat/2.5.0/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/bzip2/1.0.8/lib' ignored
# ld: warning: duplicate -rpath '/opt/koopa/app/zlib/1.3/lib' ignored

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
    deps+=('zlib')
    # FIXME Can we enable and have this build?
    # > ! koopa_is_macos && deps+=('bzip2')
    deps+=('bzip2')
    deps+=(
        'expat'
        'libffi'
        'mpdecimal'
        'ncurses'
        'openssl3'
        'xz'
        'unzip'
        # > 'libedit'
        'gdbm'
        'sqlite'
    )
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir \
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
        '--with-system-expat'
        '--with-system-libmpdec'
        'PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1'
    )
    if koopa_is_macos
    then
        app['dtrace']='/usr/sbin/dtrace'
        koopa_assert_is_executable "${app['dtrace']}"
        conf_args+=("--with-dtrace=${app['dtrace']}")
    fi
    case "${dict['version']}" in
        '3.11.'*)
            conf_args+=(
                # Avoid OpenSSL checks that are problematic for Python 3.11.0.
                # https://github.com/python/cpython/issues/98673
                'ac_cv_working_openssl_hashlib=yes'
                'ac_cv_working_openssl_ssl=yes'
                'py_cv_module__tkinter=disabled'
            )
            ;;
    esac
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
    # FIXME How to check readline support?
    koopa_alert 'Checking pip configuration.'
    "${app['python']}" -m pip list --format='columns'
    return 0
}
