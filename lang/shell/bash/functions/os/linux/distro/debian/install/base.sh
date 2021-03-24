#!/usr/bin/env bash

koopa::debian_install_base() { # {{{1
    # """
    # Install Debian base system.
    # @note Updated 2021-03-24.
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
    local apt_installed legacy_pkgs name_fancy pkg pkgs pos remove_pkgs
    koopa::assert_is_installed apt apt-get sed sudo
    declare -A dict=(
        [apt_enabled_repos]="$(koopa::apt_enabled_repos)"
        [apt_installed]="$(sudo apt list --installed 2>/dev/null)"
        [base]=1
        [dev]=1
        [extra]=0
        [recommended]=1
        [remove_legacy]=0
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
                ;;
            --full)
                dict[base]=1
                dict[dev]=1
                dict[extra]=1
                dict[recommended]=1
                dict[upgrade]=1
                shift 1
                ;;
            --remove-legacy)
                dict[remove_legacy]=1
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
    name_fancy='Debian base system'
    koopa::install_start "$name_fancy"
    # Nuke caches before installing packages.
    koopa::rm -S \
        '/var/cache/apt/'* \
        '/var/lib/dpkg/available'
    sudo dpkg --clear-avail
    # Debian symlinks '/usr/local/man' to '/usr/local/share/man' by default,
    # which is non-standard and can cause koopa's application link script
    # to break.
    [[ -L '/usr/local/man' ]] && koopa::rm -S '/usr/local/man'
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
        koopa::h2 "Upgrading install via 'dist-upgrade'."
        koopa::apt_get dist-upgrade
    fi
    if [[ "${dict[remove_legacy]}" -eq 1 ]]
    then
        # This step is only recommended when cleaning up a persistent virtual
        # machine that may have a number of old packages installed.
        koopa::alert 'Removing legacy packages (not generally recommended).'
        legacy_pkgs=(
            'cargo'                   # use 'install-rust'
            'containerd'              # docker legacy
            'docker'                  # docker legacy
            'docker-engine'           # docker legacy
            'docker.io'               # docker legacy
            'emacs'                   # use 'install-emacs'
            'emacs25'                 # gets installed by zsh
            'fish'                    # use 'install-fish'
            'libgdal-dev'             # use 'install-gdal'
            'libgeos-dev'             # use 'install-geos'
            'libproj-dev'             # use 'install-proj'
            'proj-bin'                # use 'install-proj'
            'proj-data'               # use 'install-proj'
            'runc'                    # docker legacy
        )
        remove_pkgs=()
        for pkg in "${legacy_pkgs[@]}"
        do
            if koopa::str_match_regex "${dict[apt_installed]}" "^${pkg}/"
            then
                remove_pkgs+=("$pkg")
            fi
        done
        if koopa::is_array_non_empty "${remove_pkgs[@]}"
        then
            sudo apt-get --yes remove "${remove_pkgs[@]}"
        fi
    fi
    # These packages are required to install koopa.
    pkgs=(
        'bash'
        'bc'
        'ca-certificates'
        'coreutils'
        'curl'
        'findutils'
        'git'
        'lsb-release'
        'sudo'
    )
    # These packages should be included in the Docker base image.
    if [[ "${dict[base]}" -eq 1 ]]
    then
        pkgs+=(
            # The 'build-essential' package includes: dpkg-dev, g++, gcc,
            # libc-dev, and make, which are required to build packages.
            'build-essential'
            'bzip2'
            'gnupg'
            'less'
            'libncurses-dev'  # zsh
            'locales'
            'tzdata'
            'unzip'
            'wget'
            'xz-utils'
            'zsh'
        )
    fi
    # These packages will be installed in the Docker recommended image.
    if [[ "${dict[recommended]}" -eq 1 ]]
    then
        pkgs+=(
            'apt-listchanges'
            'apt-transport-https'
            'apt-utils'
            'autoconf'
            'automake'
            'byacc'
            'cmake'
            'diffutils'
            'dirmngr'
            'file'
            'fortran77-compiler'
            'g++'
            'gcc'
            'gdb'
            'gdebi-core'
            'gettext'
            'gfortran'
            'gpg-agent'
            'htop'
            'libtool'
            'libtool-bin'
            'make'
            'man-db'
            'nano'
            'parallel'
            'pkg-config'
            'procps'  # ps
            'psmisc'  # RStudio Server
            'rsync'
            'ruby'  # Homebrew
            'software-properties-common'
            'subversion'
            'sudo'
            'texinfo'  # makeinfo
            'tmux'
            'tree'
            'udunits-bin'
            'vim'
            'zip'
        )
    fi
    # Only include these when not building GDAL, GEOS, and PROJ from source,
    # which are enabled in full mode.
    if [[ "${dict[dev]}" -eq 1 ]] && [[ "${dict[extra]}" -eq 0 ]]
    then
        pkgs+=(
            'libgdal-dev'
            'libgeos-dev'
            'libproj-dev'
            'proj-bin'
        )
    fi
    if [[ "${dict[dev]}" -eq 1 ]]
    then
        pkgs+=(
            'dpkg-dev'
            'libacl1-dev'
            'libapparmor-dev'
            'libapr1-dev'  # subversion
            'libaprutil1-dev'  # subversion
            'libbz2-dev'
            'libc-dev'
            'libcairo2-dev'
            'libcurl4-gnutls-dev'
            'libevent-dev'
            'libffi-dev'
            'libfftw3-dev'
            'libfontconfig1-dev'
            'libfreetype6-dev'
            'libfribidi-dev'
            'libgfortran5'  # R nlme
            'libgif-dev'
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
            # > 'libmariadb-dev'
            # > 'libmysqlclient-dev'  # Conflicts with libmariadb-dev (Ubuntu)
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
            'libprotobuf-dev'
            'libprotoc-dev'
            'librdf0-dev'
            'libreadline-dev'
            'libsasl2-dev'
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
            'sqlite3'
            'tcl-dev'
            'tk-dev'
            'zlib1g-dev'
        )
    fi
    if [[ "${dict[extra]}" -eq 1 ]]
    then
        pkgs+=(
            # > default-jdk
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
            'pandoc'
            'pandoc-citeproc'
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
    koopa::apt_install "${pkgs[@]}"
    koopa::apt_configure_sources
    koopa::apt_clean
    koopa::debian_set_locale
    koopa::install_success "$name_fancy"
    return 0
}
