#!/usr/bin/env bash

debian_install_base_system() { # {{{1
    # """
    # Install Debian base system.
    # @note Updated 2022-03-28.
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
    local app dict pkgs
    koopa_assert_is_admin
    declare -A app=(
        [dpkg]="$(koopa_debian_locate_dpkg)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [apt_enabled_repos]="$(koopa_debian_apt_enabled_repos)"
        [base]=1
        [dev]=1
        [extra]=0
        [recommended]=1
        [upgrade]=1
    )
    while (("$#"))
    do
        case "$1" in
            '')
                shift 1
                ;;
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
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    # Nuke caches before installing packages.
    koopa_rm --sudo \
        '/var/cache/apt/'* \
        '/var/lib/dpkg/available'
    "${app[sudo]}" "${app[dpkg]}" --clear-avail
    # Debian symlinks '/usr/local/man' to '/usr/local/share/man' by default,
    # which is non-standard and can cause koopa's application link script
    # to break.
    if [[ -L '/usr/local/man' ]]
    then
        koopa_rm --sudo '/usr/local/man'
    fi
    # Requiring universe repo to be enabled on Ubuntu.
    if koopa_is_ubuntu && \
        ! koopa_str_detect_fixed \
            --string="${dict[apt_enabled_repos]}" \
            --pattern='universe'
    then
        koopa_stop \
            "The Ubuntu 'universe' repo is disabled." \
            "Check '/etc/apt/sources.list'."
    fi
    if [[ "${dict[upgrade]}" -eq 1 ]]
    then
        koopa_alert "Upgrading system via 'dist-upgrade'."
        koopa_debian_apt_get 'dist-upgrade'
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
            'libncurses-dev' # zsh
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
            'default-jdk'
            'diffutils'
            'dirmngr'
            'expect-dev' # Installs unbuffer.
            'file'
            'fortran77-compiler'
            'gdb'
            'gdebi-core'
            'gfortran'
            'gpg-agent'
            'htop'
            'jq'
            'libtool'
            'libtool-bin'
            'nano'
            'pandoc' # R Markdown and URL checks.
            'parallel'
            'pkg-config'
            'procps' # ps
            'psmisc' # RStudio Server
            'rsync'
            'ruby' # Homebrew
            'software-properties-common'
            'subversion'
            'texinfo' # makeinfo
            'tmux'
            'tree'
            'udunits-bin'
            'vim'
            'visidata'
            'zip'
            'zsh'
        )
    fi
    if [[ "${dict[dev]}" -eq 1 ]]
    then
        pkgs+=(
            # > 'libmariadb-dev'
            # > 'libmysqlclient-dev' # Conflicts with libmariadb-dev (Ubuntu).
            # > 'proj-bin'
            'libacl1-dev'
            'libapparmor-dev'
            'libapr1-dev' # subversion
            'libaprutil1-dev' # subversion
            'libbison-dev'
            'libboost-chrono-dev' # bcl2fastq
            'libboost-date-time-dev' # bcl2fastq
            'libboost-dev' # bcl2fastq
            'libboost-filesystem-dev' # bcl2fastq
            'libboost-iostreams-dev' # bcl2fastq
            'libboost-program-options-dev' # bcl2fastq
            'libboost-thread-dev' # bcl2fastq
            'libboost-timer-dev' # bcl2fastq
            'libbz2-dev'
            'libcairo2-dev' # harfbuzz
            'libclang-dev' # rstudio-server
            'libcurl4-gnutls-dev'
            'libedit-dev' # openssh
            'libevent-dev'
            'libffi-dev'
            'libfftw3-dev'
            'libfido2-dev' # openssh
            'libfontconfig1-dev'
            'libfreetype6-dev' # harfbuzz
            'libfribidi-dev'
            'libgdal-dev'
            'libgeos-dev'
            'libgfortran5' # R nlme
            'libgif-dev'
            'libgit2-dev'
            'libgl1-mesa-dev'
            'libglib2.0-dev' # ag, harfbuzz
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
            'libldns-dev' # openssh
            'liblz4-dev' # rsync
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
            'libopenjp2-7-dev' # GDAL
            'libopenmpi-dev'
            'libpcre2-dev' # rJava
            'libpcre3-dev' # ag
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
            'libxxhash-dev' # rsync; not available on Ubuntu 18
            'libz-dev'
            'libzstd-dev' # rsync
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
            'keyboard-configuration'
            'mpi-default-bin'
            'nim'
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
        if koopa_is_ubuntu
        then
            pkgs+=('firefox')
        fi
    fi
    koopa_debian_apt_install "${pkgs[@]}"
    koopa_debian_apt_configure_sources
    koopa_debian_apt_clean
    koopa_debian_set_locale
    return 0
}
