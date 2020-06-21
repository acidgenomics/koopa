#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://subversion.apache.org/download.cgi
# https://subversion.apache.org/source-code.html
# https://svn.apache.org/repos/asf/subversion/trunk/INSTALL
# """

file="${name}-${version}.tar.bz2"
url="https://mirrors.ocf.berkeley.edu/apache/${name}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
