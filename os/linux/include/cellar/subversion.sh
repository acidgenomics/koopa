#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://subversion.apache.org/download.cgi
# https://subversion.apache.org/source-code.html
# https://svn.apache.org/repos/asf/subversion/trunk/INSTALL
# """

# configure: Apache Portable Runtime (APR) library configuration
# checking for APR... no
# configure: WARNING: APR not found
# The Apache Portable Runtime (APR) library cannot be found.
# Please install APR on this system and configure Subversion
# with the appropriate --with-apr option.
#
# You probably need to do something similar with the Apache
# Portable Runtime Utility (APRUTIL) library and then configure
# Subversion with both the --with-apr and --with-apr-util options.
#
# configure: error: no suitable APR found

# configure: error: Subversion requires LZ4 >= r129, or use --with-lz4=internal

# Debian: libapr1-dev libaprutil1-dev
_koopa_assert_is_installed apr-config apu-config


file="${name}-${version}.tar.bz2"
url="https://mirrors.ocf.berkeley.edu/apache/${name}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure \
    --prefix="$prefix" \
    --with-lz4="internal"
make --jobs="$jobs"
make install
