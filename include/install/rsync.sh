#!/usr/bin/env bash

install_rsync() { # {{{1
    # """
    # Install rsync.
    # @note Updated 2021-04-27.
    #
    # @seealso
    # - https://github.com/WayneD/rsync/blob/master/INSTALL.md
    # """
    local file flags jobs name prefix url version
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    # > if koopa::is_macos
    # > then
    # >     koopa::assert_is_installed brew
    # >     openssl_prefix="$(koopa::homebrew_prefix)/opt/openssl@1.1"
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
        flags+=('--disable-openssl')
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
    return 0
}

install_rsync "$@"
