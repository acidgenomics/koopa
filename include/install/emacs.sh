#!/usr/bin/env bash

install_emacs() { # {{{1
    # """
    # Install Emacs.
    # @note Updated 2021-05-04.
    #
    # Seeing this error on macOS:
    # Nothing to be done for 'maybe-blessmail'.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # """
    local file gnu_mirror jobs name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='emacs'
    gnu_mirror="$(koopa::gnu_mirror_url)"
    jobs="$(koopa::cpu_count)"
    file="${name}-${version}.tar.xz"
    url="${gnu_mirror}/${name}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    flags=("--prefix=${prefix}")
    if koopa::is_macos
    then
        flags+=(
            '--disable-silent-rules'
            '--with-gnutls'
            '--with-modules'
            '--with-xml2'
            '--without-dbus'
            '--without-imagemagick'
            '--without-ns'
            '--without-x'
        )
    else
        flags+=(
            '--with-x-toolkit=no'
            '--with-xpm=no'
        )
    fi
    ./configure "${flags[@]}"
    make --jobs="$jobs"
    make install
    return 0
}

install_emacs "$@"
