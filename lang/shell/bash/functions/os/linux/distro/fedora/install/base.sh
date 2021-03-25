#!/usr/bin/env bash

koopa::fedora_install_base() { # {{{1
    # """
    # Install Fedora base system.
    # @note Updated 2021-03-25.
    #
    # Refer to Debian install base script for more details on supported args.
    # """
    local dict name_fancy pkgs pos
    koopa::assert_is_installed dnf sudo
    declare -A dict=(
        [base]=1
        [dev]=1
        [extra]=0
        [recommended]=1
        [upgrade]=1
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            --base-image)
                dict[base]=1
                dict[dev]=0
                dict[extra]=0
                dict[recommended]=0
                dict[upgrade]=0
                shift 1
                ;;
            --default|--recommended)
                shift 1
                ;;
            --full)
                dict[base]=1
                dict[dev]=1
                dict[extra]=1
                dict[recommended]=1
                dict[upgrade]=1
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
    if [[ "${dict[recommended]}" -eq 1 ]] && koopa::is_rhel_ubi
    then
        koopa::stop 'Recommended configuration not yet supported for RHEL UBI.'
    fi
    if [[ "${dict[upgrade]}" -eq 1 ]]
    then
        koopa::alert "Upgrading install via 'dnf update'."
        sudo dnf -y update
    fi
    pkgs=()
    if [[ "${dict[base]}" -eq 1 ]]
    then
        pkgs+=(
            'autoconf'
            'bash'
            'bc'
            'bzip2'
            'curl'
            'findutils'
            'gcc'
            'gcc-c++'
            'gettext'
            'git'
            'glibc-langpack-en'
            'glibc-locale-source'
            'less'
            'make'
            'man-db'
            'ncurses-devel'  # zsh
            'sudo'
            'unzip'
            'xz'
            'zsh'
        )
    fi
    if [[ "${dict[recommended]}" -eq 1 ]]
    then
        pkgs=(
            #                                                       | RHEL UBI |
            # ------------------------------------------------------|----------|
            # > 'coreutils'                                       # |       NO |
            'R'                                                   # |       NO |
            'automake'                                            # |      YES |
            'byacc'                                               # |       NO |
            'chkconfig'                                           # |        ? |
            'cmake'                                               # |      YES |
            'convmv'                                              # |       NO |
            'cryptsetup'                                          # |       NO |
            'curl'                                                # |      YES |
            'diffutils'                                           # |      YES |
            'file'                                                # |        ? |
            'gcc-gfortran'
            'gnupg2'                                              # |      YES |
            'gnutls'                                              # |      YES |
            'libtool'                                             # |      YES |
            'lua'                                                 # |      YES |
            'openssl'                                             # |      YES |
            'pkgconfig'  # This is now pkgconf wrapped.           # |      YES |
            'qpdf'                                                # |       NO |
            'readline'                                            # |      YES |
            'ruby'                                                # |        ? |
            'squashfs-tools'                                      # |       NO |
            'systemd'                                             # |      YES |
            'texinfo'                                             # |       NO |
            'tmux'                                                # |       NO |
            'tree'                                                # |       NO |
            'util-linux'                                          # |      YES |
            'vim'                                                 # |      YES |
            'wget'                                                # |      YES |
            'xmlto'                                               # |       NO |
            'yum-utils'                                           # |       NO |
            'zip'                                                 # |      YES |
            'zsh'                                                 # |       NO |
        )
        if koopa::is_fedora
        then
            pkgs+=(
            #                                                       | RHEL UBI |
            # ------------------------------------------------------|----------|
                'libxcrypt-compat'  # Homebrew                    # |        ? |
            )
        fi
    fi
    if [[ "${dict[dev]}" -eq 1 ]]
    then
        koopa::alert 'Installing developer libraries.'
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
        if [[ "${dict[extra]}" -eq 0 ]]
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
    if [[ "${dict[extra]}" -eq 1 ]]
    then
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
    sudo dnf -y install "${pkgs[@]}"
    sudo dnf clean all
    koopa::fedora_set_locale
    koopa::install_success "$name_fancy"
    return 0
}
