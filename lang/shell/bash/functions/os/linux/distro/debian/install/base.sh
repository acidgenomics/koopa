#!/usr/bin/env bash

koopa::debian_install_base() { # {{{1
    # """
    # Install Debian base system.
    # @note Updated 2021-09-14.
    #
    # Backup package configuration:
    # > sudo dpkg --get-selections > /tmp/dpkglist.txt
    #
    # Restore package configuration:
    # > sudo dpkg --set-selections < /tmp/dpkglist.txt
    # > sudo apt-get -y update
    # > sudo apt-get dselect-upgrade
    #
    # Configure time zone:
    # > sudo dpkg-reconfigure tzdata
    #
    # @seealso:
    # - Check package source repo.
    #   https://packages.ubuntu.com/
    # - How to replicate installed packages across machines.
    #   https://serverfault.com/questions/56848
    # """
    local dict name_fancy pkgs pos
    koopa::assert_is_installed 'apt' 'apt-get' 'sed' 'sudo'
    declare -A dict=(
        [apt_enabled_repos]="$(koopa::debian_apt_enabled_repos)"
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
            '')
                shift 1
                ;;
            '-'*)
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
    name_fancy='Debian base system'
    koopa::install_start "$name_fancy"
    # Nuke caches before installing packages.
    koopa::rm --sudo \
        '/var/cache/apt/'* \
        '/var/lib/dpkg/available'
    sudo dpkg --clear-avail
    # Debian symlinks '/usr/local/man' to '/usr/local/share/man' by default,
    # which is non-standard and can cause koopa's application link script
    # to break.
    [[ -L '/usr/local/man' ]] && \
        koopa::rm --sudo '/usr/local/man'
    # Requiring universe repo to be enabled on Ubuntu.
    if koopa::is_ubuntu && \
        ! koopa::str_match "${dict[apt_enabled_repos]}" universe
    then
        koopa::stop \
            "The Ubuntu 'universe' repo is disabled." \
            "Check '/etc/apt/sources.list'."
    fi
    if [[ "${dict[upgrade]}" -eq 1 ]]
    then
        koopa::alert "Upgrading system via 'dist-upgrade'."
        koopa::debian_apt_get dist-upgrade
    fi
    pkgs=()
    # These packages should be included in the Docker base image.
    if [[ "${dict[base]}" -eq 1 ]]
    then
        pkgs+=(
            # The 'build-essential' package includes: dpkg-dev, g++, gcc,
            # libc-dev, and make, which are required to build packages.
            'build-essential'
            'autoconf'
            'bash'
            'bc'
            'bzip2'
            'ca-certificates'
            'coreutils'
            'curl'
            'findutils'
            'gettext'
            'git'
            'gnupg'
            'less'
            'libncurses-dev'  # zsh
            'locales'
            'lsb-release'
            'man-db'
            'python3'
            'python3-venv'
            'sudo'
            'tzdata'
            'unzip'
            'wget'
            'xz-utils'
        )
    fi
    # These packages will be installed in the Docker recommended image.
    if [[ "${dict[recommended]}" -eq 1 ]]
    then
        pkgs+=(
            'apt-listchanges'
            'apt-transport-https'
            'apt-utils'
            'automake'
            'byacc'
            'cmake'
            'diffutils'
            'dirmngr'
            'file'
            'fortran77-compiler'
            'gdb'
            'gdebi-core'
            'gfortran'
            'gpg-agent'
            'htop'
            'libtool'
            'libtool-bin'
            'nano'
            'pandoc'  # R Markdown and URL checks
            'parallel'
            'pkg-config'
            'procps'  # ps
            'psmisc'  # RStudio Server
            'rsync'
            'ruby'  # Homebrew
            'software-properties-common'
            'subversion'
            'texinfo'  # makeinfo
            'tmux'
            'tree'
            'udunits-bin'
            'vim'
            'zip'
            'zsh'
        )
    fi
    if [[ "${dict[dev]}" -eq 1 ]]
    then
        pkgs+=(
            # > 'libmariadb-dev'
            # > 'libmysqlclient-dev'  # Conflicts with libmariadb-dev (Ubuntu)
            # > 'proj-bin'
            'libacl1-dev'
            'libapparmor-dev'
            'libapr1-dev'  # subversion
            'libaprutil1-dev'  # subversion
            'libbison-dev'
            'libboost-chrono-dev'  # bcl2fastq
            'libboost-date-time-dev'  # bcl2fastq
            'libboost-dev'  # bcl2fastq
            'libboost-filesystem-dev'  # bcl2fastq
            'libboost-iostreams-dev'  # bcl2fastq
            'libboost-program-options-dev'  # bcl2fastq
            'libboost-thread-dev'  # bcl2fastq
            'libboost-timer-dev'  # bcl2fastq
            'libbz2-dev'
            'libcairo2-dev'
            'libclang-dev'  # rstudio-server
            'libcurl4-gnutls-dev'
            'libevent-dev'
            'libffi-dev'
            'libfftw3-dev'
            'libfontconfig1-dev'
            'libfreetype6-dev'
            'libfribidi-dev'
            'libgdal-dev'
            'libgeos-dev'
            'libgfortran5'  # R nlme
            'libgif-dev'
            'libgit2-dev'
            'libgl1-mesa-dev'
            'libglib2.0-dev'  # ag
            'libglu1-mesa-dev'
            'libgmp-dev'
            'libgnutls28-dev'
            'libgsl-dev'
            'libgtk-3-0'
            'libgtk-3-dev'
            'libgtk2.0-0'
            'libgtk2.0-dev'
            'libgtkmm-2.4-dev'
            'libharfbuzz-dev'
            'libhdf5-dev'
            'libjpeg-dev'
            'liblapack-dev'
            'liblz4-dev'  # rsync
            'liblzma-dev'
            'libmagick++-dev'
            'libmodule-build-perl'
            'libmpc-dev'
            'libmpfr-dev'
            'libncurses-dev'
            'libnetcdf-dev'
            'libopenbabel-dev'
            'libopenblas-base'
            'libopenblas-dev'
            'libopenjp2-7-dev'  # GDAL
            'libopenmpi-dev'
            'libpcre2-dev'  # rJava
            'libpcre3-dev'  # ag
            'libperl-dev'
            'libpng-dev'
            'libpoppler-cpp-dev'
            'libpq-dev'
            'libproj-dev'
            'libprotobuf-dev'
            'libprotoc-dev'
            'librdf0-dev'
            'libreadline-dev'
            'libsasl2-dev'
            'libsodium-dev'
            'libssh2-1-dev'
            'libssl-dev'
            'libstdc++6'
            'libtag1-dev'
            'libtiff5-dev'
            'libudunits2-dev'
            'libv8-dev'
            'libx11-dev'
            'libxml2-dev'
            'libxpm-dev'
            'libxt-dev'
            'libxxhash-dev'  # rsync; not available on Ubuntu 18
            'libz-dev'
            'libzstd-dev'  # rsync
            'python3-dev'
            'sqlite3'
            'tcl-dev'
            'tk-dev'
            'zlib1g-dev'
        )
    fi
    if [[ "${dict[extra]}" -eq 1 ]]
    then
        pkgs+=(
            'alien'
            'biber'
            'ggobi'
            'gnutls-bin'
            'graphviz'
            'gtk-doc-tools'
            'imagemagick'
            'jags'
            'jq'
            'keyboard-configuration'
            'mpi-default-bin'
            'openmpi-bin'
            'openmpi-common'
            'openmpi-doc'
            'pass'
            'protobuf-compiler'
            'systemd'
            'tabix'
            'texlive'
            'unattended-upgrades'
            'xfonts-100dpi'
            'xfonts-75dpi'
            'xorg'
        )
        if koopa::is_ubuntu
        then
            pkgs+=('firefox')
        fi
    fi
    koopa::debian_apt_install "${pkgs[@]}"
    koopa::debian_apt_configure_sources
    koopa::debian_apt_clean
    koopa::debian_set_locale
    koopa::install_success "$name_fancy"
    return 0
}
