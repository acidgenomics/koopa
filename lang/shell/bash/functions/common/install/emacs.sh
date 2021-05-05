#!/usr/bin/env bash

koopa::install_emacs() { # {{{1
    koopa::install_app \
        --name='emacs' \
        --name-fancy='Emacs' \
        "$@"
}

# FIXME Can we pass to GNU function with the flags set?
# FIXME install_gnu_app should just pass the remaining positional args to
# configure script.
koopa:::install_emacs() { # {{{1
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

koopa::update_emacs() { # {{{1
    # """
    # Update Emacs.
    # @note Updated 2020-11-25.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_installed emacs
    then
        koopa::alert_note 'Emacs is not installed.'
        return 0
    fi
    if koopa::is_spacemacs_installed
    then
        koopa:::update_spacemacs
    elif koopa::is_doom_emacs_installed
    then
        koopa:::update_doom_emacs
    else
        koopa::alert_note 'Emacs configuration cannot be updated.'
        return 0
    fi
    return 0
}
