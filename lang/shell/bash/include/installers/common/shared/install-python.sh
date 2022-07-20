#!/usr/bin/env bash

# NOTE Consider cleaning this up on macOS:
# clang: warning: argument unused during compilation:
# '-fno-semantic-interposition' [-Wunused-command-line-argument]

main() {
    # """
    # Install Python.
    # @note Updated 2022-07-20.
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
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix \
        'zlib' \
        'libffi' \
        'openssl3'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='python'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[openssl]="$(koopa_realpath "${dict[opt_prefix]}/openssl3")"
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict[version]}")"
    dict[file]="Python-${dict[version]}.tar.xz"
    dict[url]="https://www.python.org/ftp/${dict[name]}/${dict[version]}/\
${dict[file]}"
    koopa_mkdir \
        "${dict[prefix]}/bin" \
        "${dict[prefix]}/lib"
    koopa_add_to_path_start "${dict[prefix]}/bin"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "Python-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-optimizations'
        '--enable-shared'
        "--with-openssl=${dict[openssl]}"
    )
    koopa_add_rpath_to_ldflags "${dict[prefix]}/lib"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    # Use 'altinstall' here instead?
    "${app[make]}" install
    app[python]="${dict[prefix]}/bin/${dict[name]}${dict[maj_min_ver]}"
    koopa_assert_is_installed "${app[python]}"
    # FIXME Need to rework this as a function.
    if koopa_is_linux
    then
        app[ldd]="$(koopa_locate_ldd)"
        [[ -x "${app[ldd]}" ]] || return 1
        "${app[ldd]}" "${app[python]}"
    elif koopa_is_macos
    then
        app[otool]="$(koopa_macos_locate_otool)"
        [[ -x "${app[otool]}" ]] || return 1
        "${app[otool]}" -L "${app[python]}"
    fi
    return 0
}
