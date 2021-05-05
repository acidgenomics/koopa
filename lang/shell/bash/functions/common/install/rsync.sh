#!/usr/bin/env bash

# FIXME Rename internal 'flags' variable to 'conf_args'.

koopa::install_rsync() { # {{{1
    koopa::install_app \
        --name='rsync' \
        "$@"
}

koopa:::install_rsync() { # {{{1
    # """
    # Install rsync.
    # @note Updated 2021-04-27.
    #
    # @seealso
    # - https://github.com/WayneD/rsync/blob/master/INSTALL.md
    # """
    local file flags jobs name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='rsync'
    jobs="$(koopa::cpu_count)"
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
