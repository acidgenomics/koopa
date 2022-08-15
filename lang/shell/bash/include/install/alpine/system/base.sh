#!/usr/bin/env bash

main() {
    # """
    # Install Alpine Linux base system.
    # @note Updated 2022-07-18.
    #
    # Use '<pkg>=~<version>' to pin package versions.
    #
    # 'build-base' is a meta package containing: binutils, file,
    # fortify-headers, g++, gcc, libc-dev, path, and remake-make.
    #
    # Potentially useful flags:
    # > apk add --no-cache --virtual .build-dependencies
    # """
    local app pkgs
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [apk]="$(koopa_alpine_locate_apk)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app[apk]}" ]] || return 1
    [[ -x "${app[sudo]}" ]] || return 1
    pkgs=(
        # > R-dev
        # > R-doc
        # > dpkg-dev
        # > fish
        # > pandoc
        # > texlive
        'R'
        'autoconf'
        'bash'
        'bash-completion'
        'bc'
        'build-base'
        'ca-certificates'
        'coreutils'
        'curl'
        'findutils'
        'gcc'
        'gettext' # msgfmt
        'git'
        'gnupg'
        'libevent-dev'
        'libffi-dev'
        'libxml2-dev'
        'man-db'
        'mdocml'
        'ncurses-dev' # zsh
        'openssl'
        'patch'
        'procps' # ps
        'shadow'
        'sudo'
        'tar'
        'tcl'
        'tree'
        'unzip'
        'wget'
        'xz'
        'zsh'
    )
    "${app[sudo]}" "${app[apk]}" --no-cache update
    "${app[sudo]}" "${app[apk]}" --no-cache upgrade
    "${app[sudo]}" "${app[apk]}" --no-cache add "${pkgs[@]}"
    return 0
}
