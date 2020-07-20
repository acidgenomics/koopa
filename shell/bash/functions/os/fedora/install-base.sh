#!/usr/bin/env bash

koopa::fedora_install_base() { # {{{1
    # """
    # Install Fedora base system.
    # @note Updated 2020-07-16.
    # """
    local dev extra name_fancy pkgs upgrade
    koopa::assert_is_installed dnf sudo
    dev=1
    extra=1
    upgrade=1
    koopa::is_docker && extra=0
    name_fancy='Fedora base system'
    koopa::install_start "$name_fancy"

    # Upgrade {{{2
    # --------------------------------------------------------------------------

    if [[ "$upgrade" -eq 1 ]]
    then
        koopa::h2 "Upgrading install via 'dnf update'."
        sudo dnf -y update
    fi

    # Default {{{2
    # --------------------------------------------------------------------------

    koopa::h2 'Installing default packages.'
    pkgs=(
        'autoconf'
        'automake'
        'bash'
        'byacc'
        'bzip2'
        'cmake'
        'convmv'
        'coreutils'
        'cryptsetup'
        'curl'
        'diffutils'
        'findutils'
        'gcc'
        'gcc-c++'
        'gcc-gfortran'
        'git'
        'gnupg2'
        'gnutls'
        'libtool'
        'lua'
        'make'
        'man-db'
        'ncurses'
        'openssl'
        'pkgconfig'  # note this is now pkgconf
        'qpdf'
        'readline'
        'squashfs-tools'
        'systemd'
        'tmux'
        'tree'
        'util-linux'
        'vim'
        'wget'
        'xmlto'
        'xz'
        'yum-utils'
        'zip'
    )
    if ! koopa::is_rhel
    then
        pkgs+=('texinfo')
    fi

    # Developer {{{2
    # --------------------------------------------------------------------------

    if [[ "$dev" -eq 1 ]]
    then
        koopa::h2 'Installing developer libraries.'
        sudo dnf -y groupinstall 'Development Tools'
        pkgs+=(
            'apr-devel'  # subversion
            'apr-util-devel'  # subversion
            'bzip2-devel'
            'expat-devel'  # udunits
            'glib2-devel'  # ag
            'gmp-devel'
            'gnutls-devel'
            'gsl-devel'
            'libcurl-devel'
            'libevent-devel'
            'libffi-devel'
            'libicu-devel'  # rJava
            'libseccomp-devel'
            'libtiff-devel'
            'libuuid-devel'
            'libxml2-devel'
            'libzstd-devel'  # rsync
            'llvm-devel'
            'lz4-devel'  # rsync
            'mariadb-devel'
            'mpfr-devel'
            'openssl-devel'
            'pcre-devel'  # ag
            'pcre2-devel'  # rJava
            'postgresql-devel'
            'readline-devel'
            'unixODBC-devel'
            'xz-devel'
            'zlib-devel'
        )
        if ! koopa::is_rhel
        then
            pkgs+=(
                # udunits2-devel  # use 'install-udunits'.
                'bison-devel'
                'flex-devel'
                'libmpc-devel'
                'openblas-devel'
                'openjpeg2-devel'  # GDAL
                'xxhash-devel'  # rsync
            )
        fi
    fi

    # Extra {{{2
    # --------------------------------------------------------------------------

    if [[ "$extra" -eq 1 ]]
    then
        koopa::h2 'Installing extra recommended packages.'
        pkgs+=(
            # emacs
            # golang
            # zsh
            'llvm'
            'texlive'
            'texlive-bera'
            'texlive-caption'
            'texlive-changepage'
            'texlive-collection-fontsrecommended'
            'texlive-collection-latexrecommended'
            'texlive-enumitem'
            'texlive-etoolbox'
            'texlive-fancyhdr'
            'texlive-footmisc'
            'texlive-framed'
            'texlive-geometry'
            'texlive-hyperref'
            'texlive-latex-fonts'
            'texlive-natbib'
            'texlive-parskip'
            'texlive-pdftex'
            'texlive-placeins'
            'texlive-preprint'
            'texlive-sectsty'
            'texlive-soul'
            'texlive-titlesec'
            'texlive-titling'
            'texlive-xstring'
        )
    fi

    # Install packages {{{2
    # --------------------------------------------------------------------------

    sudo dnf -y install "${pkgs[@]}"
    koopa::install_success "$name_fancy"
    return 0
}

