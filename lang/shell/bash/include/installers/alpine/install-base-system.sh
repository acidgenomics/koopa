#!/usr/bin/env bash

koopa:::alpine_install_base_system() { # {{{1
    # """
    # Install Alpine Linux base system.
    # @note Updated 2021-11-30.
    #
    # Use '<pkg>=~<version>' to pin package versions.
    #
    # Potentially useful flags:
    # > apk add --no-cache --virtual .build-dependencies
    # """
    local app dict pkgs
    declare -A app=(
        [apk]="$(koopa::alpine_locate_apk)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [base]=1
        [dev]=1
        [extra]=0
        [recommended]=1
        [upgrade]=1
    )
    while (("$#"))
    do
        case "$1" in
            '')
                shift 1
                ;;
            '--base-image')
                dict[base]=1
                dict[dev]=0
                dict[extra]=0
                dict[recommended]=0
                dict[upgrade]=0
                shift 1
                ;;
            '--full')
                dict[base]=1
                dict[dev]=1
                dict[extra]=1
                dict[recommended]=1
                dict[upgrade]=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    "${app[sudo]}" "${app[apk]}" --no-cache update
    if [[ "${dict[upgrade]}" -eq 1 ]]
    then
        koopa::alert 'Upgrading system.'
        "${app[sudo]}" "${app[apk]}" --no-cache upgrade
    fi
    pkgs=()
    # These packages should be included in base image.
    if [[ "${dict[base]}" -eq 1 ]]
    then
        pkgs+=(
            # > dpkg-dev
            'autoconf'
            'bash'
            'bash-completion'
            'bc'
            # Meta package containing: binutils, file, fortify-headers, g++,
            # gcc, libc-dev, path, and remake-make.
            'build-base'
            'ca-certificates'
            'coreutils'
            'curl'
            'findutils'
            'gcc'
            'gettext'  # msgfmt
            'git'
            'gnupg'
            'man-db'
            'ncurses-dev'  # zsh
            'openssl'
            'patch'
            'procps'  # ps
            'shadow'
            'sudo'
            'tar'
            'unzip'
            'xz'
        )
    fi
    # These packages will be installed in the Docker recommended image.
    if [[ "${dict[recommended]}" -eq 1 ]]
    then
        pkgs+=(
            # > R-dev
            # > R-doc
            # > fish
            # > pandoc
            # > texlive
            'R'
            'mdocml'
            'tcl'
            'tree'
            'wget'
            'zsh'
        )
    fi
    if [[ "${dict[dev]}" -eq 1 ]]
    then
        pkgs+=(
            'libevent-dev'
            'libffi-dev'
            'libxml2-dev'
            'ncurses-dev'
        )
    fi
    "${app[sudo]}" "${app[apk]}" --no-cache add "${pkgs[@]}"
    return 0
}

