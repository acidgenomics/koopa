#!/usr/bin/env bash

install_from_source() {
    # """
    # Install Python.
    # @note Updated 2025-11-06.
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
    # To restrict compiler access to '/usr/local/lib' and '/usr/local/include',
    # comment out in 'setup.py':
    # > add_dir_to_list(self.compiler.library_dirs, '/usr/local/lib')
    # > add_dir_to_list(self.compiler.include_dirs, '/usr/local/include')
    #
    # See also:
    # - https://devguide.python.org/
    # - https://devguide.python.org/contrib/workflows/install-dependencies/
    # - https://docs.python.org/3/using/unix.html
    # - https://docs.brew.sh/Homebrew-and-Python
    # - Installing multiple versions:
    #   https://github.com/python/cpython#installing-multiple-versions
    # - Latest configuration recipe:
    #   https://github.com/python/cpython/blob/3.13/configure
    # - macOS install recipes:
    #   https://formulae.brew.sh/formula/python@3.13
    #   https://ports.macports.org/port/python312/
    # - OpenSSL configuration issues:
    #   https://stackoverflow.com/questions/45954528/
    #   https://stackoverflow.com/questions/41328451/
    # """
    local -A app dict
    local -a build_deps conf_args deps
    build_deps+=('make' 'pkg-config')
    if ! koopa_is_macos
    then
        deps+=(
            'bzip2'
            'libedit'
            'libffi'
            'libxcrypt'
            'ncurses'
            'readline'
            'unzip'
            'zlib'
        )
    fi
    deps+=(
        'expat'
        'mpdecimal'
        'openssl'
        'sqlite'
        'xz'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['cc']="$(koopa_locate_cc)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['cc_version']="$(koopa_get_version "${app['cc']}")"
    dict['jobs']="$(koopa_cpu_count)"
    dict['openssl']="$(koopa_app_prefix 'openssl')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    koopa_mkdir \
        "${dict['prefix']}/bin" \
        "${dict['prefix']}/lib"
    koopa_add_to_path_start "${dict['prefix']}/bin"
    koopa_add_rpath_to_ldflags "${dict['prefix']}/lib"
    conf_args+=(
        # > '--enable-lto'
        '--enable-ipv6'
        '--enable-loadable-sqlite-extensions'
        '--enable-shared'
        "--prefix=${dict['prefix']}"
        '--with-computed-gotos'
        '--with-ensurepip=install'
        "--with-openssl=${dict['openssl']}"
        # > '--with-system-expat'
        # > '--with-system-libmpdec'
        'PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1'
        'ac_cv_working_openssl_hashlib=yes'
        'ac_cv_working_openssl_ssl=yes'
        'py_cv_module__gdbm=disabled'
        'py_cv_module__tkinter=disabled'
    )
    if [[ "$(koopa_basename "${app['cc']}")" == 'gcc' ]] && \
        [[ "$(koopa_major_version "${dict['cc_version']}")" == 4 ]]
    then
        koopa_alert_note "${app['cc']} ${dict['cc_version']} does not \
support '--enable-optimizations' flag."
    else
        conf_args+=('--enable-optimizations')
    fi
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
    "${app['python']}" -c 'import hashlib'
    "${app['python']}" -c 'import pyexpat'
    "${app['python']}" -c 'import readline'
    "${app['python']}" -c 'import sqlite3'
    "${app['python']}" -c 'import ssl'
    "${app['python']}" -c 'import zlib'
    koopa_alert 'Checking pip configuration.'
    "${app['python']}" -m pip list --format='columns'
    koopa_alert 'Adding unversioned symlinks.'
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln --verbose 'idle3' 'idle'
        koopa_ln --verbose 'pip3' 'pip'
        koopa_ln --verbose 'pydoc3' 'pydoc'
        koopa_ln --verbose 'python3' 'python'
        koopa_ln --verbose 'python3-config' 'python-config'
        koopa_cd "${dict['prefix']}/share/man/man1"
        koopa_ln --verbose 'python3.1' 'python.1'
    )
    return 0
}

install_from_uv() {
    # """
    # Install Python using uv.
    # Updated 2026-02-06.
    # """
    local -A app dict
    app['uv']="$(koopa_locate_uv)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['uv_install_dir']='uv'
    koopa_print_env
    "${app['uv']}" python install \
        --install-dir "${dict['uv_install_dir']}" \
        --no-bin \
        --no-cache \
        --no-config \
        --verbose \
        "${dict['version']}"
    # Find the extracted cpython directory and move to install prefix.
    dict['source_dir']="$( \
        koopa_find --prefix='uv' --type=d --min-depth=1 --max-depth=1 \
    )"
    koopa_assert_is_dir "${dict['source_dir']}"
    koopa_mv "${dict['source_dir']}" "${dict['prefix']}"
    app['python']="${dict['prefix']}/bin/python${dict['maj_min_ver']}"
    koopa_assert_is_installed "${app['python']}"
    "${app['python']}" -m sysconfig
    koopa_check_shared_object --file="${app['python']}"
    koopa_alert 'Checking module integrity.'
    "${app['python']}" -c 'import _bz2'
    "${app['python']}" -c 'import _ctypes'
    "${app['python']}" -c 'import _decimal'
    "${app['python']}" -c 'import hashlib'
    "${app['python']}" -c 'import pyexpat'
    "${app['python']}" -c 'import readline'
    "${app['python']}" -c 'import sqlite3'
    "${app['python']}" -c 'import ssl'
    "${app['python']}" -c 'import zlib'
    koopa_alert 'Checking pip configuration.'
    "${app['python']}" -m pip list --format='columns'
    koopa_alert 'Adding unversioned symlinks.'
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln --verbose 'idle3' 'idle'
        koopa_ln --verbose 'pip3' 'pip'
        koopa_ln --verbose 'pydoc3' 'pydoc'
        koopa_ln --verbose 'python3' 'python'
        koopa_ln --verbose 'python3-config' 'python-config'
        koopa_cd "${dict['prefix']}/share/man/man1"
        koopa_ln --verbose 'python3.1' 'python.1'
    )
    return 0
}

main() {
    install_from_uv
    return 0
}
