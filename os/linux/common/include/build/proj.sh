#!/usr/bin/env bash
# shellcheck disable=SC2154

koopa::assert_is_linux
[[ "$reinstall" -ne 1 ]] && koopa::assert_is_not_file '/usr/bin/proj'
koopa::assert_is_installed sqlite3
# Ensure we're using our custom build of SQLite, in '/usr/local'.
export SQLITE3_CFLAGS="-I${make_prefix}/include"
export SQLITE3_LIBS="-L${make_prefix}/lib -lsqlite3"
# Fix needed to avoid libtiff-4 detection failure.
# Alternatively, can set '--disable-tiff' configure flag.
if koopa::is_debian_like
then
    # pkg-config: /usr/lib/x86_64-linux-gnu/pkgconfig/libtiff-4.pc
    export TIFF_CFLAGS='/usr/include/x86_64-linux-gnu'
    export TIFF_LIBS='/usr/lib/x86_64-linux-gnu -ltiff'
elif koopa::is_fedora_like
then
    # pkg-config: /usr/lib64/pkgconfig/libtiff-4.pc
    export TIFF_CFLAGS='/usr/include'
    export TIFF_LIBS='/usr/lib64 -ltiff'
fi
file="${name}-${version}.tar.gz"
url="https://github.com/OSGeo/PROJ/releases/download/${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure \
    --prefix="$prefix" \
    CFLAGS="-I${make_prefix}/include" \
    LDFLAGS="-L${make_prefix}/lib"
make --jobs="$jobs"
make install
