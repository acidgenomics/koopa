#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# pkg-config doesn't detect sqlite3 library correctly.
# https://github.com/OSGeo/PROJ/issues/1529
# 
# checking for SQLITE3... configure: error: Package requirements (sqlite3 >=
# 3.11) were not met:
#
# Requested 'sqlite3 >= 3.11' but version of SQLite is 3.7.17
#
# Consider adjusting the PKG_CONFIG_PATH environment variable if you
# installed software in a non-standard prefix.
#
# Alternatively, you may set the environment variables SQLITE3_CFLAGS
# and SQLITE3_LIBS to avoid the need to call pkg-config.
# See the pkg-config man page for more details.
# """

koopa::assert_is_not_file /usr/bin/proj
koopa::assert_is_installed sqlite3

export SQLITE3_CFLAGS="-I${make_prefix}/include"
export SQLITE3_LIBS="-L${make_prefix}/lib -lsqlite3"

file="${name}-${version}.tar.gz"
url="https://github.com/OSGeo/PROJ/releases/download/${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
cd "${name}-${version}" || exit 1
./configure \
    --prefix="$prefix" \
    CFLAGS="-I${make_prefix}/include" \
    LDFLAGS="-L${make_prefix}/lib"
make --jobs="$jobs"
make install
