#!/usr/bin/env bash

install_gnupg_gcrypt() { # {{{1
    # """
    # Install GnuPG gcrypt library.
    # @note Updated 2021-04-27.
    # """
    local base_url gcrypt_url gpg gpg_agent jobs name prefix sig_file sig_url \
        tar_file tar_url version
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    gcrypt_url="$(koopa::gcrypt_url)"
    jobs="$(koopa::cpu_count)"
    base_url="${gcrypt_url}/${name}"
    tar_file="${name}-${version}.tar.bz2"
    tar_url="${base_url}/${tar_file}"
    koopa::download "$tar_url"
    gpg='/usr/bin/gpg'
    gpg_agent='/usr/bin/gpg-agent'
    if koopa::is_installed "$gpg_agent"
    then
        sig_file="${tar_file}.sig"
        sig_url="${base_url}/${sig_file}"
        koopa::download "$sig_url"
        "$gpg" --verify "$sig_file" || return 1
    fi
    koopa::extract "$tar_file"
    koopa::cd "${name}-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    make install
    return 0
}

install_gnupg_gcrypt "$@"
