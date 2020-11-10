#!/usr/bin/env bash

koopa::fedora_install_base() { # {{{1
    # """
    # Install Fedora base system.
    # @note Updated 2020-11-10.
    #
    # Refer to Debian install base script for more details on supported args.
    # """
    local dev full name_fancy pkgs pos upgrade
    koopa::assert_is_installed dnf sudo
    dev=1
    full=0
    upgrade=1
    pos=()
    while (("$#"))
    do
        case "$1" in
            --full)
                full=1
                shift 1
                ;;
            "")
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_no_args "$#"
    name_fancy='Fedora base system'
    koopa::install_start "$name_fancy"
    if [[ "$full" -eq 1 ]] && koopa::is_rhel_ubi
    then
        koopa::stop 'Base configuration not yet supported for RHEL UBI.'
    fi

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
        #                                                           | RHEL UBI |
        # ----------------------------------------------------------|----------|
        # > 'coreutils'                                           # |       NO |
        'R'                                                       # |       NO |
        'autoconf'                                                # |      YES |
        'automake'                                                # |      YES |
        'bash'                                                    # |      YES |
        'byacc'                                                   # |       NO |
        'bzip2'                                                   # |      YES |
        'chkconfig'                                               # |        ? |
        'cmake'                                                   # |      YES |
        'convmv'                                                  # |       NO |
        'cryptsetup'                                              # |       NO |
        'curl'                                                    # |      YES |
        'diffutils'                                               # |      YES |
        'file'                                                    # |        ? |
        'findutils'                                               # |      YES |
        'gcc'                                                     # |      YES |
        'gcc-c++'                                                 # |      YES |
        'gcc-gfortran'                                            # |      YES |
        'gettext'                                                 # |      YES |
        'git'                                                     # |      YES |
        'gnupg2'                                                  # |      YES |
        'gnutls'                                                  # |      YES |
        'libtool'                                                 # |      YES |
        'libxcrypt-compat'  # Homebrew                            # |        ? |
        'lua'                                                     # |      YES |
        'make'                                                    # |      YES |
        'man-db'                                                  # |      YES |
        'ncurses'                                                 # |      YES |
        'openssl'                                                 # |      YES |
        'pkgconfig'  # This is now pkgconf wrapped.               # |      YES |
        'qpdf'                                                    # |       NO |
        'readline'                                                # |      YES |
        'ruby'                                                    # |        ? |
        'squashfs-tools'                                          # |       NO |
        'systemd'                                                 # |      YES |
        'texinfo'                                                 # |       NO |
        'tmux'                                                    # |       NO |
        'tree'                                                    # |       NO |
        'util-linux'                                              # |      YES |
        'vim'                                                     # |      YES |
        'wget'                                                    # |      YES |
        'xmlto'                                                   # |       NO |
        'xz'                                                      # |      YES |
        'yum-utils'                                               # |       NO |
        'zip'                                                     # |      YES |
        'zsh'                                                     # |       NO |
    )

    # Developer {{{2
    # --------------------------------------------------------------------------

    if [[ "$dev" -eq 1 ]]
    then
        koopa::h2 'Installing developer libraries.'
        sudo dnf -y groupinstall 'Development Tools'
        pkgs+=(
            #                                                       | RHEL UBI |
            # ------------------------------------------------------|----------|
            'apr-devel'  # subversion                             # |      YES |
            'apr-util-devel'  # subversion                        # |      YES |
            'bison-devel'                                         # |       NO |
            'bzip2-devel'                                         # |      YES |
            'cairo-devel'                                         # |       NO |
            'expat-devel'  # udunits                              # |      YES |
            'flex-devel'                                          # |       NO |
            'fontconfig-devel'                                    # |      YES |
            'freetype-devel'  # freetype / ragg                   # |      YES |
            'fribidi-devel'  # textshaping                        # |       NO |
            'glib2-devel'  # ag                                   # |      YES |
            'gmp-devel'                                           # |       NO |
            'gnutls-devel'                                        # |       NO |
            'gsl-devel'                                           # |       NO |
            'harfbuzz-devel'  # textshaping                       # |       NO |
            'hdf5-devel'                                          # |       NO |
            'libcurl-devel'                                       # |      YES |
            'libevent-devel'  # tmux                              # |       NO |
            'libffi-devel'                                        # |      YES |
            'libgit2-devel'                                       # |       NO |
            'libicu-devel'  # rJava                               # |      YES |
            'libjpeg-turbo-devel'  # freetype / ragg              # |      YES |
            'libmpc-devel'                                        # |       NO |
            'libpng-devel'  # freetype / ragg                     # |      YES |
            'libseccomp-devel'                                    # |      YES |
            'libssh2-devel'                                       # |      YES |
            'libtiff-devel'                                       # |      YES |
            'libuuid-devel'                                       # |      YES |
            'libxml2-devel'                                       # |      YES |
            'libzstd-devel'  # rsync                              # |       NO |
            'llvm-devel'                                          # |       NO |
            'lz4-devel'  # rsync                                  # |      YES |
            'mariadb-devel'                                       # |       NO |
            'mpfr-devel'                                          # |       NO |
            'ncurses-devel'                                       # |      YES |
            'openblas-devel'                                      # |       NO |
            'openjpeg2-devel'  # GDAL                             # |       NO |
            'openssl-devel'                                       # |      YES |
            'pcre-devel'  # ag                                    # |      YES |
            'pcre2-devel'  # rJava                                # |      YES |
            'postgresql-devel'                                    # |      YES |
            'python3-devel'                                       # |       NO |
            'readline-devel'  # R                                 # |       NO |
            'taglib-devel'                                        # |       NO |
            'unixODBC-devel'                                      # |      YES |
            'xxhash-devel'  # rsync                               # |      YES |
            'xz-devel'                                            # |      YES |
            'zlib-devel'                                          # |      YES |
        )
        if [[ "$full" -eq 0 ]]
        then
            pkgs+=(
                #                                                   | RHEL UBI |
                # --------------------------------------------------|----------|
                'gdal-devel'                                      # |       NO |
                'geos-devel'                                      # |      YES |
                'proj-devel'                                      # |       NO |
                'sqlite-devel'                                    # |      YES |
                'udunits2-devel'                                  # |      YES |
            )
        fi
    fi

    # Extra {{{2
    # --------------------------------------------------------------------------

    if [[ "$full" -eq 1 ]]
    then
        koopa::h2 'Installing extra recommended packages.'
        pkgs+=(
            # > emacs
            # > golang
            'jq'
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
