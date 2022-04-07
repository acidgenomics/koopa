#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Python.
    # @note Updated 2022-03-28.
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
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='python'
        [name2]='Python'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict[version]}")"
    dict[file]="${dict[name2]}-${dict[version]}.tar.xz"
    dict[url]="https://www.python.org/ftp/${dict[name]}/${dict[version]}/\
${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name2]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        # This slows down the installer a lot.
        # > '--enable-optimizations'
        '--enable-shared'
    )
    # Setting 'LDFLAGS' here doesn't work on macOS.
    if koopa_is_linux
    then
        conf_args+=("LDFLAGS=-Wl,-rpath=${dict[prefix]}/lib")
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
