#!/usr/bin/env bash

koopa:::arch_install_base_system() { # {{{1
    # """
    # Install Arch Linux base system.
    # @note Updated 2021-11-30.
    #
    # base-devel:
    # 1) autoconf  2) automake  3) binutils  4) bison  5) fakeroot  6) file
    # 7) findutils  8) flex  9) gawk  10) gcc  11) gettext  12) grep  13) groff
    # 14) gzip  15) libtool  16) m4  17) make  18) pacman  19) patch
    # 20) pkgconf  21) sed  22) sudo  23) texinfo  24) which
    #
    # Optional dependencies for r
    #     tk: tcl/tk interface
    #     texlive-bin: latex sty files
    #     gcc-fortran: needed to compile some CRAN packages
    #     openblas: faster linear algebra
    #
    # Note that Arch is currently overwriting PS1 for root.
    # This is due to configuration in '/etc/profile'.
    # """
    local app dict pkgs
    declare -A app=(
        [pacman]="$(koopa::arch_locate_pacman)"
        [pacman_db_upgrade]="$(koopa::arch_locate_pacman_db_upgrade)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [base]=1
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
                dict[recommended]=0
                dict[upgrade]=0
                shift 1
                ;;
            '--full')
                dict[base]=1
                dict[recommended]=1
                dict[upgrade]=1
                shift 1
                ;;
            '--default' | \
            '--recommended')
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    # Arch symlinks '/usr/local/share/man' to '/usr/local/man' by default, which
    # is non-standard and can cause koopa's application link script to break.
    [[ -L '/usr/local/share/man' ]] && \
        koopa::rm --sudo '/usr/local/share/man'
    if [[ "${dict[upgrade]}" -eq 1 ]]
    then
        "${app[sudo]}" "${app[pacman]}" -Syyu --noconfirm
    fi
    pkgs=()
    if [[ "${dict[base]}" -eq 1 ]]
    then
        pkgs+=(
            'base-devel'
            'bash'
            'bc'
            'git'
            'man'
            'procps'  # ps
            'unzip'
            'xz'
        )
    fi
    if [[ "${dict[recommended]}" -eq 1 ]]
    then
        pkgs+=(
            'awk'
            'cmake'
            'gcc-fortran'
            'gmp'
            'libevent'
            'libffi'
            'mpc'
            'mpfr'
            'pandoc'
            'r'
            'tcl'
            'texlive-core'
            'tree'
            'wget'
            'zsh'
        )
    fi
    "${app[sudo]}" "${app[pacman]}" -Syy --noconfirm
    "${app[sudo]}" "${app[pacman_db_upgrade]}"
    "${app[sudo]}" "${app[pacman]}" -S --noconfirm "${pkgs[@]}"
    return 0
}
