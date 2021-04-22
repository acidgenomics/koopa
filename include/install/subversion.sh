#!/usr/bin/env bash
# 
# """
# Install Subversion.
# @note Updated 2020-11-17.
#
# @seealso
# - https://svn.apache.org/repos/asf/subversion/trunk/INSTALL
# - https://subversion.apache.org/download.cgi
# - https://subversion.apache.org/source-code.html
#
# Requires Apache Portable Runtime (APR) library and Apache Portable Runtime
# Utility (APRUTIL) library.
# """

if koopa::is_linux
then
    if koopa::is_fedora
    then
        koopa::ln -S '/usr/bin/apr-1-config' '/usr/bin/apr-config'
        koopa::ln -S '/usr/bin/apu-1-config' '/usr/bin/apu-config'
        koopa::force_add_to_pkg_config_path_start '/usr/lib64/pkgconfig'
    fi
    koopa::assert_is_installed apr-config apu-config sqlite3
fi
file="${name}-${version}.tar.bz2"
url="https://mirrors.ocf.berkeley.edu/apache/${name}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
flags=("--prefix=${prefix}")
if koopa::is_macos
then
    koopa::assert_is_installed brew
    brew_prefix="$(brew --prefix)"
    flags+=(
        "--with-apr=${brew_prefix}/opt/apr"
        "--with-apr-util=${brew_prefix}/opt/apr-util"
    )
elif koopa::is_linux
then
    flags+=(
        '--with-lz4=internal'
        '--with-utf8proc=internal'
    )
fi
./configure "${flags[@]}"
make --jobs="$jobs"
make install
