#!/usr/bin/env bash

koopa::arch_install_base() { # {{{1
    # """
    # Install Arch Linux base system.
    # @note Updated 2020-07-02.
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
    local name_fancy packages
    koopa::assert_is_installed pacman sudo
    name_fancy='Arch base system'
    koopa::install_start "$name_fancy"
    # Arch symlinks '/usr/local/share/man' to '/usr/local/man' by default, which
    # is non-standard and can cause cellar link script to break.
    [[ -L '/usr/local/share/man' ]] && koopa::rm -S /usr/local/share/man
    sudo pacman -Syyu --noconfirm
    sudo pacman-db-upgrade
    packages=(
        # pandoc
        # pandoc-citeproc
        # texlive-core
        awk
        base-devel
        bash
        bc
        cmake
        gcc-fortran
        git
        gmp
        libevent
        libffi
        man
        mpc
        mpfr
        r
        tcl
        tree
        wget
    )
    sudo pacman -S --noconfirm "${packages[@]}"
    koopa::install_success "$name_fancy"
    return 0
}

