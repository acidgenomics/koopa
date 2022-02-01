#!/usr/bin/env bash

koopa:::install_emacs() { # {{{1
    # """
    # Install Emacs.
    # @note Updated 2021-11-30.
    #
    # Consider defining '--enable-locallisppath' and '--infodir' args.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/emacs.rb
    # """
    local conf_args dict install_args pkg pkgs
    install_args=(
        '--name-fancy=Emacs'
        '--name=emacs'
        '--no-prefix-check'
        '--quiet'
    )
    conf_args=()
    if koopa::is_linux
    then
        conf_args+=(
            '--with-x-toolkit=no'
            '--with-xpm=no'
        )
    elif koopa::is_macos
    then
        declare -A dict
        dict[gcc_version]="$(koopa::variable 'gcc')"
        dict[gcc_maj_ver]="$(koopa::major_version "${dict[gcc_version]}")"
        pkgs=(
            "gcc@${dict[gcc_maj_ver]}"
            'gnutls'
            'pkg-config'
        )
        for pkg in "${pkgs[@]}"
        do
            install_args+=("--homebrew-opt=${pkg}")
        done
        export "CC=gcc-${dict[gcc_maj_ver]}"
        conf_args+=(
            # > "CC=gcc-${dict[gcc_maj_ver]}"
            '--disable-silent-rules'
            '--with-gnutls'
            '--with-modules'
            '--with-xml2'
            '--without-dbus'
            '--without-imagemagick'
            '--without-ns'
            '--without-selinux'
            '--without-x'
        )
    fi
    koopa::dl \
        'install args' "${install_args[*]}" \
        'conf args' "${conf_args[*]}"
    koopa::install_gnu_app \
        "${install_args[@]}" \
        "${conf_args[@]}" \
        "$@"
}
