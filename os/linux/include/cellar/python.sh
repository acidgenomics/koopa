#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# Ubuntu 18 LTS requires LDFLAGS to be set, otherwise we hit:
# python3: error while loading shared libraries: libpython3.8.so.1.0: cannot
# open shared object file: No such file or directory
#
# This alone works, but I've set other paths, as recommended.
# LDFLAGS="-Wl,-rpath ${prefix}/lib"
#
# Check config with:
# > ldd /usr/local/bin/python3
#
# See also:
# - https://stackoverflow.com/questions/43333207
# """

file="Python-${version}.tar.xz"
url="https://www.python.org/ftp/python/${version}/${file}"
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
make install

major_minor_version="$(koopa::major_minor_version "$version")"
cellar_site_pkgs="${prefix}/lib/python${major_minor_version}/site-packages"
koopa_site_pkgs="$(koopa::python_site_packages_prefix)"

# FIXME HOW TO WRITE LINES TO FILE?
