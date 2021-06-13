#!/usr/bin/env bash

# FIXME Need to add 'koopa::configure_start' and 'koopa::configure_success' functions.
koopa::configure_python() { #{{{1
    # """
    # Configure Python.
    # @note Updated 2021-06-13.
    # """
    local python
    python="${1:-}"
    [[ -z "$python" ]] && python="$(koopa::locate_python)"
    koopa::python_add_site_packages_to_sys_path "$python"
}

koopa::install_python() { # {{{1
    koopa::install_app \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

koopa:::install_python() { # {{{1
    # """
    # Install Python.
    # @note Updated 2021-05-26.
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
    local conf_args file jobs make name name2 prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='python'
    name2="$(koopa::capitalize "$name")"
    minor_version="$(koopa::major_minor_version "$version")"
    file="${name2}-${version}.tar.xz"
    url="https://www.${name}.org/ftp/${name}/${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name2}-${version}"
    conf_args=(
        "--prefix=${prefix}"
        '--enable-optimizations'
        '--enable-shared'
    )
    # Setting 'LDFLAGS' here doesn't work on macOS.
    if koopa::is_linux
    then
        conf_args+=("LDFLAGS=-Wl,-rpath=${prefix}/lib")
    fi
    ./configure "${conf_args[@]}"
    "$make" --jobs="$jobs"
    # > "$make" test
    # > Use 'make altinstall' here instead?
    "$make" install
    python="${prefix}/bin/${name}${minor_version}"
    koopa::assert_is_file "$python"
    koopa::configure_python "$python"
    return 0
}

koopa::uninstall_python() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}
