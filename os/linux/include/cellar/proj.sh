#!/usr/bin/env bash
# shellcheck disable=SC2154

koopa::assert_is_not_file /usr/bin/proj
koopa::assert_is_installed sqlite3
export SQLITE3_CFLAGS="-I${make_prefix}/include"
export SQLITE3_LIBS="-L${make_prefix}/lib -lsqlite3"
if koopa::is_debian
then
    export TIFF_CFLAGS='/usr/include/x86_64-linux-gnu'
    export TIFF_LIBS='/usr/lib/x86_64-linux-gnu -ltiff'
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
