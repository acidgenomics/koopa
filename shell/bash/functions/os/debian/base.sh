#!/usr/bin/env bash

koopa::debian_install_base() { # {{{1
    # """
    # Install Debian base system.
    # @note Updated 2020-11-10.
    #
    # Flags:
    # --compact
    #     This is intended for compact mode configuration in 'configure-vm'
    #     script, which when disabled builds a lot of GCC packages and other
    #     programs from source, rather than relying on system binary packages.
    #
    # Backup:
    # > sudo dpkg --get-selections > /tmp/dpkglist.txt
    #
    # Restore:
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
    local apt_installed dev enabled_repos full legacy_pkgs name_fancy pkg pkgs \
        remove remove_pkgs upgrade
    koopa::assert_is_installed apt apt-get sed sudo
    dev=1
    full=0
    remove=1
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
    [[ "$full" -eq 1 ]] && remove=1
    name_fancy='Debian base system'
    koopa::install_start "$name_fancy"
    # Nuke caches before installing packages.
    koopa::rm -S '/var/cache/apt/'* '/var/lib/dpkg/available'
    sudo dpkg --clear-avail
    # Debian symlinks '/usr/local/man' to '/usr/local/share/man' by default,
    # which is non-standard and can cause cellar link script to break.
    [[ -L '/usr/local/man' ]] && koopa::rm -S '/usr/local/man'
    # Requiring universe repo to be enabled on Ubuntu.
    enabled_repos="$(koopa::apt_enabled_repos)"
    if koopa::is_ubuntu && ! koopa::str_match "$enabled_repos" 'universe'
    then
        koopa::stop \
            "The Ubuntu 'universe' repo is disabled." \
            "Check '/etc/apt/sources.list'."
    fi

    # Upgrade {{{2
    # --------------------------------------------------------------------------

    if [[ "$upgrade" -eq 1 ]]
    then
        koopa::h2 "Upgrading install via 'dist-upgrade'."
        koopa::apt_get dist-upgrade
    fi

    # Remove packages {{{2
    # --------------------------------------------------------------------------

    if [[ "$remove" -eq 1 ]]
    then
        koopa::h2 'Removing legacy packages.'
        # Alternative approach:
        # > apt_installed="$(dpkg --get-selections | grep -v deinstall)"
        # See also:
        # - https://askubuntu.com/questions/17823
        apt_installed="$(sudo apt list --installed 2> /dev/null)"
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
            'zsh'                     # use 'install-zsh'
            'zsh-common'
        )
        remove_pkgs=()
        for pkg in "${legacy_pkgs[@]}"
        do
            if koopa::str_match_regex "$apt_installed" "^${pkg}/"
            then
                remove_pkgs+=("$pkg")
            fi
        done
        if koopa::is_array_non_empty "${remove_pkgs[@]}"
        then
            sudo apt-get --yes remove "${remove_pkgs[@]}"
        fi
    fi

    # Default {{{2
    # --------------------------------------------------------------------------

    koopa::h2 'Installing default packages.'
    pkgs=(
        'apt-listchanges'
        'apt-transport-https'
        'apt-utils'
        'autoconf'
        'automake'
        'bash'
        'bc'
        'build-essential'
        'byacc'
        'bzip2'
        'ca-certificates'
        'cmake'
        'coreutils'
        'curl'
        'diffutils'
        'dirmngr'
        'file'
        'findutils'
        'fortran77-compiler'
        'g++'
        'gcc'
        'gdb'
        'gdebi-core'
        'gettext'
        'gfortran'
        'git'
        'gnupg'
        'gpg-agent'
        'htop'
        'less'
        'libtool'
        'libtool-bin'
        'lsb-release'
        'make'
        'man-db'
        'nano'
        'parallel'
        'pkg-config'
        'procps'  # ps
        'psmisc'  # RStudio Server
        'rsync'
        'software-properties-common'
        'subversion'
        'sudo'
        'texinfo'  # makeinfo
        'tmux'
        'tree'
        'tzdata'
        'unzip'
        'vim'
        'wget'
        'xz-utils'
        'zip'
        'zsh'
    )

    # Developer {{{2
    # --------------------------------------------------------------------------

    if [[ "$dev" -eq 1 ]]
    then
        koopa::h2 'Installing developer packages.'
        if [[ "$full" -eq 0 ]]
        then
            pkgs+=(
                'libgdal-dev'
                'libgeos-dev'
                'libproj-dev'
                'proj-bin'
            )
        fi
        pkgs+=(
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
            # 'libmariadb-dev'
            # 'libmysqlclient-dev'  # Conflicts with libmariadb-dev (Ubuntu)
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

    # Extra {{{2
    # --------------------------------------------------------------------------

    if [[ "$full" -eq 1 ]]
    then
        koopa::h2 'Installing extra recommended packages.'
        pkgs+=(
            # default-jdk
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
            koopa::info 'Installing Ubuntu-specific packages.'
            pkgs+=('firefox')
        fi
    fi

    # Install packages {{{2
    # --------------------------------------------------------------------------

    koopa::apt_install "${pkgs[@]}"
    koopa::apt_configure_sources
    sudo apt-get --yes clean
    sudo apt-get --yes autoremove
    koopa::install_success "$name_fancy"
    return 0
}
