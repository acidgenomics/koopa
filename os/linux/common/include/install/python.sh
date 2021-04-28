#!/usr/bin/env bash

install_python() { # {{{1
    # """
    # Install Python.
    # @note Updated 2021-04-28.
    #
    # Warning: 'make install' can overwrite or masquerade the python3 binary.
    # 'make altinstall' is therefore recommended instead of make install since
    # it only installs 'exec_prefix/bin/pythonversion'.
    #
    #
    # Ubuntu 18 LTS requires LDFLAGS to be set, otherwise we hit:
    # python3: error while loading shared libraries: libpython3.8.so.1.0:
    # cannot open shared object file: No such file or directory
    #
    # This alone works, but I've set other paths, as recommended.
    # LDFLAGS="-Wl,-rpath ${prefix}/lib"
    #
    # Check config with:
    # > ldd /usr/local/bin/python3
    #
    #
    # To resolve this warning:
    #
    # > checking for g++... no
    # > configure:
    # >
    # >   By default, distutils will build C++ extension modules with "g++".
    # >   If this is not intended, then set CXX on the configure command line.
    #
    # Specify `CXX` environment variable or `--with-cxx-main=/usr/bin/g++`.
    #
    #
    # See also:
    # - https://docs.python.org/3/using/unix.html
    # - https://stackoverflow.com/questions/43333207
    # """
    local file jobs name prefix url version
    koopa::assert_is_linux
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    minor_version="$(koopa::major_minor_version "$version")"
    jobs="$(koopa::cpu_count)"
    make_prefix="$(koopa::make_prefix)"
    # FIXME CONVERT THIS TO UPPER.
    file="Python-${version}.tar.xz"
    url="https://www.${name}.org/ftp/${name}/${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "Python-${version}"
    ./configure \
        --enable-optimizations \
        --enable-shared \
        --prefix="$prefix" \
        --without-ensurepip \
        LDFLAGS="-Wl,--rpath=${make_prefix}/lib"
    make --jobs="$jobs"
    # > make test
    # > Use 'make altinstall' here instead?
    make install

    python="${prefix}/bin/${name}${minor_version}"
    koopa::python_add_site_packages_to_sys_path "$python"
    return 0
}

install_python "$@"
