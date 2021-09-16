#!/usr/bin/env bash

koopa::configure_python() { #{{{1
    # """
    # Configure Python.
    # @note Updated 2021-09-15.
    #
    # This creates a Python 'site-packages' directory and then links using
    # a 'koopa.pth' file into the Python system 'site-packages'.
    #
    # @seealso
    # > "$python" -m site
    # """
    local k_site_pkgs name name_fancy pth_file python sys_site_pkgs version
    python="${1:-}"
    if [[ -z "$python" ]]
    then
        koopa::activate_python
        python="$(koopa::locate_python)"
    fi
    koopa::assert_is_installed "$python"
    name='python'
    name_fancy='Python'
    version="$(koopa::get_version "$python")"
    sys_site_pkgs="$(koopa::python_system_packages_prefix "$python")"
    k_site_pkgs="$(koopa::python_packages_prefix "$version")"
    pth_file="${sys_site_pkgs:?}/koopa.pth"
    koopa::alert "Adding '${pth_file}' path file."
    if koopa::is_koopa_app "$python"
    then
        koopa::write_string "$k_site_pkgs" "$pth_file"
        # Don't assume this is linked into make prefix. May need to re-enable
        # this if we run into configuration issues.
        # > if ! koopa::is_macos
        # > then
        # >     koopa::link_app "$name"
        # > fi
    else
        koopa::sudo_write_string "$k_site_pkgs" "$pth_file"
    fi
    koopa:::configure_app_packages \
        --name-fancy="$name_fancy" \
        --name="$name" \
        --prefix="$k_site_pkgs"
    return 0
}

koopa::install_python() { # {{{1
    koopa:::install_app \
        --name-fancy='Python' \
        --name='python' \
        "$@"
    koopa::configure_python
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
    return 0
}

koopa::uninstall_python() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}
