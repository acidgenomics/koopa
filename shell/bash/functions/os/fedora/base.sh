#!/usr/bin/env bash

koopa::fedora_install_base() { # {{{1
    # """
    # Install Fedora base system.
    # @note Updated 2020-08-07.
    #
    # Refer to Debian install base script for more details on supported args.
    # """
    local compact dev extra name_fancy pkgs pos upgrade
    koopa::assert_is_installed dnf sudo
    compact=0
    dev=1
    extra=1
    full=0
    upgrade=1
    pos=()
    while (("$#"))
    do
        case "$1" in
            --compact)
                compact=1
                shift 1
                ;;
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
    if [[ "$compact" -eq 1 ]] && [[ "$full" -eq 1 ]]
    then
        koopa::stop "Set '--compact' or '--full' but not both."
    fi
    koopa::is_docker && [[ "$full" -eq 0 ]] && extra=0
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
        # 'coreutils' # This can error on RHEL.
        'autoconf'
        'automake'
        'bash'
        'bzip2'
        'cmake'
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
        'pkgconfig'  # This is now pkgconf wrapped.
        'readline'
        'systemd'
        'util-linux'
        'vim'
        'wget'
        'xz'
        'zip'
    )
    if ! koopa::is_rhel_ubi
    then
        pkgs+=(
            'byacc'
            'convmv'
            'cryptsetup'
            'qpdf'
            'squashfs-tools'
            'tmux'
            'tree'
            'xmlto'
            'yum-utils'
            'zsh'
        )
    fi
    if koopa::is_fedora
    then
        pkgs+=(
            'R'
            'python3-devel'
            'texinfo'
        )
    fi

    # Developer {{{2
    # --------------------------------------------------------------------------

    if [[ "$dev" -eq 1 ]]
    then
        koopa::h2 'Installing developer libraries.'
        if ! koopa::is_rhel_ubi
        then
            sudo dnf -y groupinstall 'Development Tools'
            pkgs+=(
                'bison-devel'
                'flex-devel'
                'gmp-devel'
                'gnutls-devel'
                'gsl-devel'
                'hdf5-devel'
                'libevent-devel'
                'libgit2-devel'
                'libmpc-devel'
                'libzstd-devel'  # rsync
                'llvm-devel'
                'mariadb-devel'
                'mpfr-devel'
                'openblas-devel'
                'openjpeg2-devel'  # GDAL
                'readline-devel'
            )
        fi
        pkgs+=(
            'apr-devel'  # subversion
            'apr-util-devel'  # subversion
            'bzip2-devel'
            'expat-devel'  # udunits
            'glib2-devel'  # ag
            'libcurl-devel'
            'libffi-devel'
            'libicu-devel'  # rJava
            'libseccomp-devel'
            'libssh2-devel'
            'libtiff-devel'
            'libuuid-devel'
            'libxml2-devel'
            'lz4-devel'  # rsync
            'openssl-devel'
            'pcre-devel'  # ag
            'pcre2-devel'  # rJava
            'postgresql-devel'
            'unixODBC-devel'
            'xxhash-devel'  # rsync
            'xz-devel'
            'zlib-devel'
        )
        if [[ "$compact" -eq 1 ]]
        then
            if ! koopa::is_rhel_ubi
            then
                pkgs+=(
                    'gdal-devel'
                )
            fi
            pkgs+=(
                'geos-devel'
                'proj-devel'
                'sqlite-devel'
                'udunits2-devel'
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
