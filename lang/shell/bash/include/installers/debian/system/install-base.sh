#!/usr/bin/env bash

main() {
    # """
    # Install Debian base system.
    # @note Updated 2022-07-18.
    #
    # The 'build-essential' package includes: dpkg-dev, g++, gcc, libc-dev, and
    # make, which are required to build packages.
    #
    # @section Look up reverse dependencies:
    # > sudo apt-cache rdepends --installed 'libnode-dev'
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
    declare -A app=(
        [dpkg]="$(koopa_debian_locate_dpkg)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app[dpkg]}" ]] || return 1
    [[ -x "${app[sudo]}" ]] || return 1
    declare -A dict=(
        [apt_enabled_repos]="$(koopa_debian_apt_enabled_repos)"
    )
    pkgs=(
        # > 'alien'
        # > 'biber'
        # > 'ggobi'
        # > 'ghc' # haskell-stack
        # > 'gnutls-bin'
        # > 'graphviz'
        # > 'jags'
        # > 'keyboard-configuration'
        # > 'libgdal-dev' # libspatial
        # > 'libgeos-dev' # libspatial
        # > 'libmariadb-dev'
        # > 'libmysqlclient-dev' # Conflicts with libmariadb-dev (Ubuntu).
        # > 'libproj-dev' # libspatial
        # > 'librdf0-dev' # Problematic on 2022-03-29.
        # > 'mpi-default-bin'
        # > 'nim'
        # > 'openmpi-bin'
        # > 'openmpi-common'
        # > 'openmpi-doc'
        # > 'pass'
        # > 'proj-bin'
        # > 'protobuf-compiler'
        # > 'systemd'
        # > 'tabix'
        # > 'unattended-upgrades'
        # > 'xorg'
        'apt-listchanges'
        'apt-transport-https'
        'apt-utils'
        'attr' # coreutils
        'autoconf'
        'automake'
        'bash'
        'bash-completion'
        'bc'
        'bison' # r-devel
        'build-essential'
        'byacc'
        'bzip2'
        'ca-certificates'
        'cmake'
        'coreutils'
        'curl'
        'debhelper' # r-devel
        'default-jdk'
        'diffutils'
        'dirmngr'
        'expect-dev' # Installs unbuffer.
        'file'
        'findutils'
        'fortran77-compiler'
        'gdb' # r-devel
        'gdebi-core'
        'gettext'
        'gfortran'
        'git'
        'gnupg'
        'gperf'
        'gpg-agent'
        'groff-base' # r-devel
        'gtk-doc-tools' # harfbuzz
        'htop'
        'imagemagick'
        'jq'
        'less'
        'libacl1-dev' # coreutils
        'libapparmor-dev'
        'libapr1-dev' # subversion
        'libaprutil1-dev' # subversion
        'libatlas-base-dev' # armadillo
        'libattr1-dev' # coreutils
        'libbison-dev'
        'libblas-dev'
        'libboost-chrono-dev' # bcl2fastq
        'libboost-date-time-dev' # bcl2fastq
        'libboost-dev' # bcl2fastq
        'libboost-filesystem-dev' # bcl2fastq
        'libboost-iostreams-dev' # bcl2fastq
        'libboost-program-options-dev' # bcl2fastq
        'libboost-thread-dev' # bcl2fastq
        'libboost-timer-dev' # bcl2fastq
        'libbrotli-dev' # node.js
        'libbz2-dev'
        'libc-ares-dev' # node.js
        'libcairo2-dev' # harfbuzz
        'libcap-dev' # coreutils
        'libclang-dev' # rstudio-server
        'libcurl4-openssl-dev' # or 'libcurl4-gnutls-dev'; r-devel
        'libedit-dev' # openssh
        'libevent-dev'
        'libffi-dev'
        'libfftw3-dev'
        'libfido2-dev' # openssh
        'libfontconfig1-dev'
        'libfreetype6-dev' # harfbuzz
        'libfribidi-dev'
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
        'libjpeg-turbo8-dev'
        'libkrb5-dev' # openssh
        'liblapack-dev'
        'libldns-dev' # openssh
        'liblz4-dev' # rsync
        # > 'liblzma-dev'
        'libmagick++-dev'
        'libmodule-build-perl'
        'libmpc-dev'
        'libmpfr-dev'
        'libncurses-dev'
        'libncurses-dev' # zsh
        'libncurses5-dev' # r-devel
        'libnetcdf-dev'
        'libnghttp2-dev' # node.js
        'libopenbabel-dev'
        'libopenblas-base'
        'libopenblas-dev'
        'libopenjp2-7-dev' # GDAL
        'libopenmpi-dev'
        'libpam0g-dev' # openssh
        'libpango1.0-dev' # r-devel
        'libpcre2-dev' # rJava
        'libpcre3-dev' # ag; r-devel
        'libperl-dev'
        'libpng-dev'
        'libpoppler-cpp-dev'
        'libpq-dev'
        'libprotobuf-dev'
        'libprotoc-dev'
        'libreadline-dev'
        'libsasl2-dev'
        'libserf-dev' # subversion (for HTTPS)
        'libsodium-dev'
        'libssh2-1-dev'
        'libssl-dev'
        'libstdc++6'
        'libtag1-dev'
        'libtiff5-dev'
        'libtool'
        'libtool-bin'
        'libudunits2-dev'
        'libv8-dev'
        'libx11-dev'
        'libxml2-dev'
        'libxpm-dev'
        'libxt-dev'
        'libxxhash-dev' # rsync; not available on Ubuntu 18
        'libz-dev'
        'libzstd-dev' # rsync
        'locales'
        'lsb-release'
        'man-db'
        'meson' # harfbuzz
        'mpack' # r-devel
        'nano'
        'ninja-build' # harfbuzz
        'pandoc' # nodejs
        'parallel'
        'pkg-config'
        'procps' # ps
        'psmisc' # RStudio Server
        'python3'
        'python3-dev'
        'python3-venv'
        'rsync'
        'ruby' # Homebrew
        'software-properties-common'
        'sqlite3'
        'subversion' # r-devel
        'sudo'
        'tcl-dev'
        'tcl8.6-dev' # r-devel
        'texinfo' # makeinfo
        'texlive'
        'texlive-base' # r-devel
        'texlive-extra-utils' # r-devel
        'texlive-fonts-extra' # r-devel
        'texlive-fonts-recommended' # r-devel
        'texlive-latex-base' # r-devel
        'texlive-latex-extra' # r-devel
        'texlive-latex-recommended' # r-devel
        'tk-dev'
        'tk8.6-dev' # r-devel
        'tmux'
        'tree'
        'tzdata'
        'udunits-bin'
        'unzip'
        'vim'
        'visidata'
        'wget'
        'x11proto-core-dev' # r-devel
        'xauth' # r-devel
        'xdg-utils' # r-devel
        'xfonts-100dpi'
        'xfonts-75dpi'
        'xfonts-base' # r-devel
        'xvfb' # r-devel
        'xz-utils'
        'zip'
        'zlib1g-dev' # r-devel
        'zsh'
    )
    if koopa_is_ubuntu
    then
        pkgs+=('firefox')
    fi
    koopa_rm --sudo \
        '/var/cache/apt/'* \
        '/var/lib/dpkg/available'
    "${app[sudo]}" "${app[dpkg]}" --clear-avail
    if koopa_is_ubuntu && \
        ! koopa_str_detect_fixed \
            --string="${dict[apt_enabled_repos]}" \
            --pattern='universe'
    then
        koopa_stop \
            "The Ubuntu 'universe' repo is disabled." \
            "Check '/etc/apt/sources.list'."
    fi
    koopa_debian_apt_get 'upgrade'
    koopa_debian_apt_get 'dist-upgrade'
    koopa_debian_apt_install "${pkgs[@]}"
    koopa_debian_apt_configure_sources
    koopa_debian_apt_clean
    koopa_debian_set_locale
    koopa_debian_set_timezone
    koopa_linux_update_system_sshd_config
    return 0
}
