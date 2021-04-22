#!/usr/bin/env bash

# """
# See also:
# - http://www.lua.org/manual/5.3/readme.html
# """

koopa::assert_is_linux
file="${name}-${version}.tar.gz"
url="http://www.lua.org/ftp/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
make linux
make test
make install INSTALL_TOP="$prefix"
