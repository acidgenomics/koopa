#!/usr/bin/env bash

koopa:::install_python() { # {{{1
    # """
    # Install Python.
    # @note Updated 2021-11-30.
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
    # See also:
    # - https://docs.python.org/3/using/unix.html
    # - https://stackoverflow.com/questions/43333207
    # """
    local app dict
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='python'
        [name2]='Python'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_min_ver]="$(koopa::major_minor_version "${dict[version]}")"
    dict[file]="${dict[name2]}-${dict[version]}.tar.xz"
    dict[url]="https://www.python.org/ftp/${dict[name]}/${dict[version]}/\
${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name2]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-optimizations'
        '--enable-shared'
    )
    # Setting 'LDFLAGS' here doesn't work on macOS.
    if koopa::is_linux
    then
        conf_args+=("LDFLAGS=-Wl,-rpath=${dict[prefix]}/lib")
    fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    # Use 'altinstall' here instead?
    "${app[make]}" install
    app[python]="${dict[prefix]}/bin/${dict[name]}${dict[maj_min_ver]}"
    koopa::assert_is_installed "${app[python]}"
    return 0
}
