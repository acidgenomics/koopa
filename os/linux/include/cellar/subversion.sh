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

if koopa::is_fedora
then
    apr_config="/usr/bin/apr-1-config"
    apu_config="/usr/bin/apu-1-config"
else
    apr_config="apr-config"
    apu_config="apu-config"
fi

koopa::assert_is_installed "$apr_config" "$apu_config"

file="${name}-${version}.tar.bz2"
url="https://mirrors.ocf.berkeley.edu/apache/${name}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure \
    --prefix="$prefix" \
    --with-apr-config="$apr_config" \
    --with-apu-config="$apu_config" \
    --with-lz4="internal" \
    --with-utf8proc="internal"
make --jobs="$jobs"
make install
