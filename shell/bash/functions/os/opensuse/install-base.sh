#!/usr/bin/env bash

koopa::opensuse_install_base() { # {{{1
    # """
    # Install openSUSE base system.
    # @note Updated 2020-07-02.
    #
    # zypper cheat sheet:
    # https://en.opensuse.org/images/1/17/Zypper-cheat-sheet-1.pdf
    # """
    local name_fancy packages
    koopa::assert_is_installed sudo zypper
    name_fancy="openSUSE base system"
    koopa::install_start "$name_fancy"
    sudo zypper refresh
    sudo zypper --non-interactive update
    packages=(
        # R-base
        # R-base-devel
        # texlive
        autoconf
        bzip2
        cmake
        curl
        gcc
        gcc-c++
        gcc-fortran
        gettext-devel
        git
        gmp-devel
        gzip
        libbz2-devel
        libcurl-devel
        libevent-devel
        libffi-devel
        libxml2-devel
        lzma-devel
        make
        man
        mpc-devel
        mpfr-devel
        ncurses-devel
        openssl-devel
        pcre2-devel
        readline-devel
        sudo
        tar
        texinfo  # note that this will install texlive
        tree
        unzip
        wget
        which
        xz
        zlib-devel
    )
    sudo zypper --non-interactive install "${packages[@]}"
    koopa::install_success "$name_fancy"
    return 0
}

