#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# Install Subversion.
# @note Updated 2020-07-24.
#
# @seealso
# - https://svn.apache.org/repos/asf/subversion/trunk/INSTALL
# - https://subversion.apache.org/download.cgi
# - https://subversion.apache.org/source-code.html
#
# Requires Apache Portable Runtime (APR) library and Apache Portable Runtime
# Utility (APRUTIL) library.
# """

if koopa::is_fedora
then
    koopa::ln -S '/usr/bin/apr-1-config' '/usr/bin/apr-config'
    koopa::ln -S /usr/bin/apu-1-config' /usr/bin/apu-config'
fi
koopa::assert_is_installed 'apr-config' 'apu-config'
file="${name}-${version}.tar.bz2"
url="https://mirrors.ocf.berkeley.edu/apache/${name}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure \
    --prefix="$prefix" \
    --with-lz4='internal' \
    --with-utf8proc='internal'
make --jobs="$jobs"
make install
