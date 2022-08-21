#!/usr/bin/env bash

main() {
    # """
    # Install Arch Linux base system.
    # @note Updated 2022-07-18.
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
    local app pkgs
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [pacman]="$(koopa_arch_locate_pacman)"
        [pacman_db_upgrade]="$(koopa_arch_locate_pacman_db_upgrade)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app['pacman']}" ]] || return 1
    [[ -x "${app['pacman_db_upgrade']}" ]] || return 1
    [[ -x "${app['sudo']}" ]] || return 1
    pkgs=(
        'awk'
        'base-devel'
        'bash'
        'bc'
        'cmake'
        'gcc-fortran'
        'git'
        'gmp'
        'libevent'
        'libffi'
        'man'
        'mpc'
        'mpfr'
        'pandoc'
        'procps' # ps
        'r'
        'tcl'
        'texlive-core'
        'tree'
        'unzip'
        'wget'
        'xz'
        'zsh'
    )
    # Arch symlinks '/usr/local/share/man' to '/usr/local/man' by default, which
    # is non-standard and can cause koopa's application link script to break.
    # > [[ -L '/usr/local/share/man' ]] && \
    # >     koopa_rm --sudo '/usr/local/share/man'
    "${app['sudo']}" "${app['pacman']}" -Syyu --noconfirm
    "${app['sudo']}" "${app['pacman']}" -Syy --noconfirm
    "${app['sudo']}" "${app['pacman_db_upgrade']}"
    "${app['sudo']}" "${app['pacman']}" -S --noconfirm "${pkgs[@]}"
    return 0
}
