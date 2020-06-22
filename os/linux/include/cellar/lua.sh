#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# See also:
# - http://www.lua.org/manual/5.3/readme.html
# """

file="${name}-${version}.tar.gz"
url="http://www.lua.org/ftp/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
make linux
make test
make install INSTALL_TOP="$prefix"
