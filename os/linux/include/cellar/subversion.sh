#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://subversion.apache.org/download.cgi
# https://subversion.apache.org/source-code.html
# https://svn.apache.org/repos/asf/subversion/trunk/INSTALL
#
# Requires Apache Portable Runtime (APR) library and Apache Portable Runtime
# Utility (APRUTIL) library.
# """

_koopa_assert_is_installed apr-config apu-config

file="${name}-${version}.tar.bz2"
url="https://mirrors.ocf.berkeley.edu/apache/${name}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure \
    --prefix="$prefix" \
    --with-lz4="internal" \
    --with-utf8proc="internal"
make --jobs="$jobs"
make install
