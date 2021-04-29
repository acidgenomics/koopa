#!/usr/bin/env bash

install_python() { # {{{1
    # """
    # Install Python.
    # @note Updated 2021-04-29.
    #
    # Check config with:
    # > ldd /usr/local/bin/python3
    #
    # Warning: 'make install' can overwrite or masquerade the python3 binary.
    # 'make altinstall' is therefore recommended instead of make install since
    # it only installs 'exec_prefix/bin/pythonversion'.
    #
    # Ubuntu 18 LTS requires LDFLAGS to be set, otherwise we hit:
    # ## python3: error while loading shared libraries: libpython3.8.so.1.0:
    # ## cannot open shared object file: No such file or directory
    # This alone works, but I've set other paths, as recommended.
    # # > LDFLAGS="-Wl,-rpath ${prefix}/lib"
    #
    # To customize g++ path, specify `CXX` environment variable
    # or use `--with-cxx-main=/usr/bin/g++`.
    #
    # See also:
    # - https://docs.python.org/3/using/unix.html
    # - https://stackoverflow.com/questions/43333207
    # """
    local file flags jobs prefix url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    minor_version="$(koopa::major_minor_version "$version")"
    jobs="$(koopa::cpu_count)"
    make_prefix="$(koopa::make_prefix)"
    file="Python-${version}.tar.xz"
    url="https://www.python.org/ftp/python/${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "Python-${version}"
    flags=(
        # Disable automatic pip install with:
        # > '--without-ensurepip'
        "--prefix=${prefix}"
        "LDFLAGS=-Wl,--rpath=${make_prefix}/lib"
        '--enable-optimizations'
        '--enable-shared'
    )
    ./configure "${flags[@]}"
    make --jobs="$jobs"
    # > make test
    # > Use 'make altinstall' here instead?
    make install
    python="${prefix}/bin/python${minor_version}"
    koopa::assert_is_file "$python"
    koopa::python_add_site_packages_to_sys_path "$python"
    return 0
}

install_python "$@"
