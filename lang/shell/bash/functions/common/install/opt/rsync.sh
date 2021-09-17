#!/usr/bin/env bash

koopa::install_rsync() { # {{{1
    koopa:::install_app \
        --name='rsync' \
        "$@"
}

koopa:::install_rsync() { # {{{1
    # """
    # Install rsync.
    # @note Updated 2021-05-26.
    #
    # @seealso
    # - https://github.com/WayneD/rsync/blob/master/INSTALL.md
    # """
    local conf_args file jobs make name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='rsync'
    file="${name}-${version}.tar.gz"
    url="https://download.samba.org/pub/${name}/src/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    conf_args=("--prefix=${prefix}")
    if koopa::is_macos
    then
        # Even though Homebrew provides OpenSSL, hard to link.
        conf_args+=('--disable-openssl')
    elif koopa::is_linux
    then
        conf_args+=(
            # > '--without-included-zlib'
            '--disable-zstd'
        )
        if koopa::is_rhel_like
        then
            conf_args+=('--disable-xxhash')
        fi
    fi
    ./configure "${conf_args[@]}"
    "$make" --jobs="$jobs"
    "$make" install
    return 0
}

koopa::uninstall_rsync() { # {{{1
    koopa:::uninstall_app \
        --name='rsync' \
        "$@"
}
