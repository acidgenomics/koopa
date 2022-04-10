#!/usr/bin/env bash

# FIXME Hitting this issue with koopa python:
# WARNING: pip is configured with locations that require TLS/SSL, however the
# ssl module in Python is not available.

# FIXME May need to add lzma support:
# Failed to build these modules: _lzma

main() { # {{{1
    # """
    # Install Python.
    # @note Updated 2022-04-09.
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
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'openssl'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='python'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[openssl_prefix]="${dict[opt_prefix]}/openssl"
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict[version]}")"
    dict[file]="Python-${dict[version]}.tar.xz"
    dict[url]="https://www.python.org/ftp/${dict[name]}/${dict[version]}/\
${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "Python-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-optimizations'
        "--with-openssl=${dict[openssl_prefix]}"
    )
    if [[ "${INSTALL_LINK_IN_MAKE:?}" -eq 1 ]]
    then
        conf_args+=(
            '--enable-shared'
        )
    fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    # Use 'altinstall' here instead?
    "${app[make]}" install
    app[python]="${dict[prefix]}/bin/${dict[name]}${dict[maj_min_ver]}"
    koopa_assert_is_installed "${app[python]}"
    koopa_configure_python "${app[python]}"
    return 0
}
