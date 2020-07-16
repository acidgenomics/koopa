#!/usr/bin/env bash

koopa::debian_enable_unattended_upgrades() { # {{{1
    # """
    # Enable unattended upgrades.
    # @note Updated 2020-07-14.
    #
    # @seealso
    # - https://wiki.debian.org/UnattendedUpgrades
    # - https://blog.confirm.ch/unattended-upgrades-in-debian/
    #
    # Default config:
    # - /etc/apt/apt.conf.d/50unattended-upgrades
    # - /etc/apt/apt.conf.d/20auto-upgrades
    #
    # Logs:
    # - /var/log/dpkg.log
    # - /var/log/unattended-upgrades/
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed dpkg-reconfigure
    koopa::apt_install apt-listchanges unattended-upgrades
    # The file '/etc/apt/apt.conf.d/20auto-upgrades' can be created manually or
    # by running the following command as root.
    sudo dpkg-reconfigure -plow unattended-upgrades
    # Check status.
    sudo unattended-upgrades -d
    return 0
}

koopa::debian_install_azure_cli() { # {{{1
    # """
    # Install Azure CLI.
    # @note Updated 2020-07-16.
    #
    # @seealso
    # - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt
    #
    # Required packages:
    # - apt-transport-https
    # - ca-certificates
    # - curl
    # - gnupg
    # - lsb-release
    #
    # Automated script:
    # > curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    # """
    local name_fancy
    koopa::exit_if_installed az
    name_fancy='Azure CLI'
    koopa::install_start "$name_fancy"
    koopa::apt_add_azure_cli_repo
    koopa::apt_install azure-cli
    koopa::install_success "$name_fancy"
    return 0
}

koopa::debian_install_base() { # {{{1
    # """
    # Install Debian base system.
    # @note Updated 2020-07-16.
    #
    # Check package source repo:
    # https://packages.ubuntu.com/
    #
    # How to replicate installed packages across machines:
    # https://serverfault.com/questions/56848
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
    # """
    local apt_installed compact dev enabled_repos extra legacy_pkgs name_fancy \
        pkg pkgs remove remove_pkgs upgrade
    koopa::assert_is_installed apt apt-get sed sudo
    # This is intended for compact mode configuration in 'configure-vm' script,
    # which when disabled builds a lot of GCC packages and other programs from
    # source, rather than relying on system binary packages.
    compact=0
    # Developer libraries.
    dev=1
    # Include extra packages.
    extra=1
    # Remove some system packages that can conflict with build from source.
    remove=1
    # Upgrade the operating system.
    upgrade=1
    pos=()
    while (("$#"))
    do
        case "$1" in
            --compact)
                compact=1
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
    koopa::is_docker && extra=0
    # Use system libraries for GDAL, etc. for these VM configs.
    [[ "$compact" -eq 1 ]] && remove=0
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
            'The Ubuntu "universe" repo is disabled.' \
            'Check "/etc/apt/sources.list".'
    fi

    # Upgrade {{{2
    # --------------------------------------------------------------------------

    if [[ "$upgrade" -eq 1 ]]
    then
        koopa::h2 'Upgrading install via "dist-upgrade".'
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
    )

    # Developer {{{2
    # --------------------------------------------------------------------------

    if [[ "$dev" -eq 1 ]]
    then
        koopa::h2 'Installing developer packages.'
        if [[ "$compact" -eq 1 ]]
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
            'libfreetype6-dev'
            'libgfortran5'  # R nlme
            'libgif-dev'
            'libgl1-mesa-dev'
            'libglu1-mesa-dev'
            'libgmp-dev'
            'libgnutls28-dev'
            'libglib2.0-dev'  # ag
            'libgsl-dev'
            'libgtk-3-0'
            'libgtk-3-dev'
            'libgtk2.0-0'
            'libgtk2.0-dev'
            'libgtkmm-2.4-dev'
            'libharfbuzz-dev'
            'libhdf5-dev'
            'liblapack-dev'
            'liblz4-dev'  # rsync
            'liblzma-dev'
            'libmagick++-dev'
            'libmariadb-dev'
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

    # Extra {{{1
    # ==========================================================================

    if [[ "$extra" -eq 1 ]]
    then
        koopa::h2 "Installing extra recommended packages."
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

koopa::debian_install_docker() {
    # """
    # Install Docker.
    # @note Updated 2020-07-14.
    #
    # @seealso
    # - https://docs.docker.com/install/linux/docker-ce/debian/
    # - https://docs.docker.com/install/linux/docker-ce/ubuntu/
    #
    # Currently supports overlay2, aufs and btrfs storage drivers.
    #
    # Configures at '/var/lib/docker/'.
    # """
    local name_fancy pkgs
    koopa::exit_if_docker
    koopa::exit_if_installed docker
    name_fancy='Docker'
    koopa::install_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    koopa::apt_add_docker_repo
    # Ready to install Docker.
    pkgs=(
        'containerd.io'
        'docker-ce'
        'docker-ce-cli'
    )
    koopa::apt_install "${pkgs[@]}"
    # Ensure current user is added to Docker group.
    koopa::add_user_to_group 'docker'
    # Move '/var/lib/docker' to '/n/var/lib/docker'.
    koopa::link_docker
    koopa::install_success "$name_fancy"
    koopa::restart
    return 0
}

koopa::debian_install_git_lfs() {
    local file name_fancy tmp_dir url
    koopa::assert_has_no_args "$#"
    name_fancy='Git LFS'
    koopa::install_start "$name_fancy"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='script.deb.sh'
        url="https://packagecloud.io/install/repositories/github/git-lfs/${file}"
        koopa::download "$url"
        chmod +x "$file"
        "$file"
    )
    koopa::rm "$tmp_dir"
    koopa::apt_install git git-lfs
    git lfs install
    koopa::install_success "$name_fancy"
    return 0
}

koopa::debian_install_google_cloud_sdk() {
    # """
    # https://cloud.google.com/sdk/docs/downloads-apt-get
    #
    # Required packages:
    # - apt-transport-https
    # - ca-certificates
    # - curl
    # """
    koopa::assert_has_no_args "$#"
    koopa::exit_if_installed gcloud
    name_fancy='Google Cloud SDK'
    koopa::install_start "$name_fancy"
    koopa::apt_add_google_cloud_sdk_repo
    koopa::apt_install google-cloud-sdk
    koopa::install_success "$name_fancy"
    return 0
}

koopa::debian_install_llvm() {
    # """
    # Install LLVM (clang).
    # @note Updated 2020-07-16.
    #
    # @seealso
    # - https://apt.llvm.org/
    #
    # Automatic script:
    # https://apt.llvm.org/llvm.sh
    # The 'llvm.sh' install script contains the GPG signing keys.
    #
    # Note that default llvm recipe currently installs version 6.
    # """
    local current_major_version current_version major_version name name_fancy \
        pos reinstall version
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --reinstall)
                reinstall=1
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
    # FIXME Convert to function.
    [[ "$reinstall" -eq 1 ]] && uninstall-llvm
    name='llvm'
    version="$(koopa::variable "$name")"
    major_version="$(koopa::major_version "$version")"
    name_fancy="LLVM ${major_version}"
    # Check if LLVM installation is current, or whether we need to update.
    if [[ -n "${LLVM_CONFIG:-}" ]]
    then
        current_version="$(koopa::get_version "$LLVM_CONFIG")"
        current_major_version="$(koopa::major_version "$current_version")"
        if [[ "$current_major_version" == "$major_version" ]]
        then
            koopa::note "${name_fancy} is installed."
            exit 0
        else
            koopa::dl 'LLVM config' "$LLVM_CONFIG"
            # FIXME Convert to function.
            uninstall-llvm
        fi
    fi
    koopa::install_start "$name_fancy"
    koopa::apt_add_llvm_repo
    pkgs=(
        "clang-${major_version}"
        "clangd-${major_version}"
        "lld-${major_version}"
        "lldb-${major_version}"
    )
    koopa::apt_install "${pkgs[@]}"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::debian_install_pandoc() {
    # """
    # Install Pandoc.
    # @note Updated 2020-07-16.
    # """
    local name name_fancy tmp_dir version
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed dpkg sudo
    name='pandoc'
    name_fancy='Pandoc'
    koopa::install_start "$name_fancy"
    version="$(koopa::variable "$name")"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="${name}-${version}-1-amd64.deb"
        url="https://github.com/jgm/${name}/releases/download/${version}/${file}"
        koopa::download "$url"
        sudo dpkg -i "$file"
        rm -rf "$file"
    )
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::debian_install_r_cran_binary() {
    # """
    # Install latest version of R from CRAN.
    # @note Updated 2020-07-16.
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://cran.r-project.org/bin/linux/ubuntu/README.html
    # """
    local name_fancy pkgs r version
    r='/usr/bin/R'
    koopa::exit_if_installed "$r"
    while (("$#"))
    do
        case "$1" in
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --version)
                version="$2"
                shift 2
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    [[ -z "${version:-}" ]] && version="$(koopa::variable r)"
    name_fancy="R CRAN ${version} binary package"
    koopa::install_start "$name_fancy"
    # This ensures we're starting fresh with the correct apt repo.
    koopa::rm -S \
        '/etc/R' \
        '/etc/apt/sources.list.d/r.list' \
        '/usr/lib/R/etc'
    koopa::apt_add_r_repo "$version"
    pkgs=('r-base' 'r-base-dev')
    koopa::apt_install "${pkgs[@]}"
    koopa::update_r_config "$r"
    # Ensure we don't have a duplicate site library.
    koopa::rm -S '/usr/local/lib/R'
    koopa::install_success "$name_fancy"
    return 0
}

koopa::debian_install_r_devel() {
    # """
    # Install latest version of R-devel from CRAN.
    # @note Updated 2020-07-16.
    #
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    #
    # The following NEW packages will be installed:
    # - bison
    # - ca-certificates-java
    # - default-jdk
    # - default-jdk-headless
    # - default-jre
    # - default-jre-headless
    # - java-common
    # - libasound2
    # - libasound2-data
    # - libbison-dev
    # - libpcsclite1
    # - mpack
    # - openjdk-11-jdk
    # - openjdk-11-jdk-headless
    # - openjdk-11-jre
    # - openjdk-11-jre-headless
    # - preview-latex-style
    # - texlive-extra-utils
    # - texlive-fonts-extra
    # - texlive-latex-extra
    # - texlive-pictures
    # - texlive-plain-generic
    # - xvfb
    # """
    koopa::apt_add_r_repo
    koopa::apt_get build-dep r-base
    koopa::install_cellar \
        --name='r' \
        --name-fancy='R' \
        --version='devel' \
        --script-name='r-devel' \
        "$@"
    return 0
}

koopa::debian_install_rstudio_server() {
    # """
    # Install RStudio Server on Debian / Ubuntu.
    # @note Updated 2020-07-16.
    #
    # @seealso
    # https://rstudio.com/products/rstudio/download-server/debian-ubuntu/
    #
    # System config:
    # /etc/rstudio
    #
    # Verify install:
    # > sudo rstudio-server stop
    # > sudo rstudio-server verify-installation
    # > sudo rstudio-server start
    # > sudo rstudio-server status
    #
    # Docker recipes:
    # - https://hub.docker.com/r/rocker/rstudio/dockerfile
    # - https://github.com/rocker-org/rocker-versioned/tree/master/rstudio
    # """
    local file name name_fancy os_codename pos reinstall tmp_dir url version
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed R gdebi sudo
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --reinstall)
                reinstall=1
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
    name='rstudio-server'
    version="$(koopa::variable "$name")"
    name_fancy="RStudio Server ${version}"
    ! koopa::is_current_version "$name" && reinstall=1
    [[ "$reinstall" -eq 0 ]] && koopa::exit_if_installed "$name"
    koopa::install_start "$name_fancy"
    os_codename="$(koopa::os_codename)"
    case "$os_codename" in
        buster|focal)
            os_codename='bionic'
            ;;
        bionic)
            ;;
        *)
            koopa::stop "Unsupported OS version: \"${os_codename}\"."
            ;;
    esac
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="rstudio-server-${version}-amd64.deb"
        url="https://download2.rstudio.org/server/bionic/amd64/${file}"
        koopa::download "$url"
        sudo gdebi --non-interactive "$file"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

