#!/usr/bin/env bash

install_gnupg_pinentry() { # {{{1
    # """
    # Install GnuPG pinentry library.
    # @note Updated 2021-04-27.
    # """
    local base_url gcrypt_url jobs name prefix sig_file sig_url \
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
    if koopa::is_installed gpg-agent
    then
        sig_file="${tar_file}.sig"
        sig_url="${base_url}/${sig_file}"
        koopa::download "$sig_url"
        gpg --verify "$sig_file" || return 1
    fi
    koopa::extract "$tar_file"
    koopa::cd "${name}-${version}"
    flags=("--prefix=${prefix}")
    if koopa::is_opensuse
    then
        # Build with ncurses is currently failing on openSUSE, due to
        # hard-coded link to '/usr/include/ncursesw' that isn't easy to resolve.
        # Falling back to using 'pinentry-tty' instead in this case.
        flags+=(
            '--disable-fallback-curses'
            '--disable-pinentry-curses'
            '--enable-pinentry-tty'
        )
    else
        flags+=('--enable-pinentry-curses')
    fi
    ./configure "${flags[@]}"
    make --jobs="$jobs"
    make install
    return 0
}

install_gnupg_pinentry "$@"
