#!/usr/bin/env bash
# 
# """
# https://github.com/WayneD/rsync/blob/master/INSTALL.md
# """

# > if koopa::is_macos
# > then
# >     koopa::assert_is_installed brew
# >     openssl_prefix="$(brew --prefix)/opt/openssl@1.1"
# >     koopa::assert_is_dir "$openssl_prefix"
# >     koopa::activate_prefix "$openssl_prefix"
# > fi
file="${name}-${version}.tar.gz"
url="https://download.samba.org/pub/${name}/src/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
flags=("--prefix=${prefix}")
if koopa::is_macos
then
    # Even though Homebrew provides OpenSSL, hard to link.
    flags+=(
        '--disable-openssl'
    )
elif koopa::is_linux
then
    flags+=(
        # > '--without-included-zlib'
        '--disable-zstd'
    )
    if koopa::is_rhel_like
    then
        flags+=('--disable-xxhash')
    fi
fi
./configure "${flags[@]}"
make --jobs="$jobs"
make install
