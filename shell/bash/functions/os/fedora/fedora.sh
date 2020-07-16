#!/usr/bin/env bash

koopa::fedora_install_azure_cli() { # {{{1
    # """
    # Install Azure CLI.
    # @note Updated 2020-07-16.
    #
    # Note that recommended 'yumdownloader' approach doesn't work for Amazon
    # Linux, so get the corresponding RHEL 7 RPM file from
    # packages.microsoft.com instead.
    #
    # @seealso
    # - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum
    # """
    local file name name_fancy tmp_dir url version
    koopa::assert_has_no_args "$#"
    koopa::exit_if_installed az
    name='azure-cli'
    name_fancy='Azure CLI'
    koopa::install_start "$name_fancy"
    koopa::assert_is_installed python3
    koopa::yum_import_azure_cli_key
    koopa::yum_add_azure_cli_repo
    if koopa::is_rhel_7
    then
        # Install on RHEL 7.6 or other systems without Python 3.
        tmp_dir="$(koopa::tmp_dir)"
        (
            version="$(koopa::variable "$name")"
            file="${name}-${version}-1.el7.x86_64.rpm"
            url="https://packages.microsoft.com/yumrepos/${name}/${file}"
            koopa::download "$url"
            sudo rpm -ivh --nodeps "$file"
        )
        koopa::rm "$tmp_dir"
    else
        sudo dnf -y install azure-cli
    fi
    koopa::install_success "$name_fancy"
    return 0
}

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
        koopa::h2 'Upgrading install via "dnf update".'
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

koopa::fedora_install_google_cloud_sdk() { # {{{1
    # """
    # Install Google Cloud SDK.
    # @note Updated 2020-07-16.
    # @seealso
    # - https://cloud.google.com/sdk/docs/downloads-yum
    # """
    local name_fancy
    koopa::exit_if_installed gcloud
    name_fancy='Google Cloud SDK'
    koopa::install_start "$name_fancy"
    koopa::yum_add_google_cloud_sdk_repo
    sudo dnf -y install google-cloud-sdk
    koopa::install_success "$name_fancy"
    return 0
}

koopa::fedora_install_oracle_instantclient() {
    # """
    # Install Oracle InstantClient.
    # @note Updated 2020-07-16.
    # @seealso
    # - https://www.oracle.com/database/technologies/instant-client/
    #       linux-x86-64-downloads.html
    # """
    local minor_version name name_fancy stem stems tmp_dir url_prefix version
    koopa::assert_has_no_args "$#"
    name='oracle-instantclient'
    name_fancy='Oracle Instant Client'
    version="$(koopa::variable "$name")"
    minor_version="$(koopa::major_minor_version "$version")"
    koopa::install_start "$name_fancy"
    koopa::note "Removing previous version, if applicable."
    sudo dnf -y remove 'oracle-instantclient*'
    koopa::rm -S '/etc/ld.so.conf.d/oracle-instantclient.conf'
    url_prefix="https://download.oracle.com/otn_software/linux/instantclient/195000"
    stems=('basic' 'devel' 'sqlplus' 'jdbc' 'odbc')
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        for stem in "${stems[@]}"
        do
            file="oracle-instantclient${minor_version}-${stem}-${version}.x86_64.rpm"
            koopa::download "${url_prefix}/${file}"
            sudo rpm -i "$file"
        done
    )
    koopa::install_success "$name_fancy"
    return 0
}

koopa::fedora_install_wine() { # {{{1
    # """
    # Install Wine.
    # @note Updated 2020-07-16.
    #
    # Note that 'winehq-stable' is currently only available on Fedora 31.
    # Can use 'winehq-devel' on Fedora 32.
    #
    # @seealso
    # - https://wiki.winehq.org/Fedora
    # """
    local name_fancy repo_url version
    koopa::exit_if_installed wine
    name_fancy='Wine'
    koopa::install_start "$name_fancy"
    version="$( \
        grep 'VERSION_ID=' '/etc/os-release' \
            | cut -d '=' -f 2 \
    )"
    repo_url="https://dl.winehq.org/wine-builds/fedora/${version}/winehq.repo"
    dnf -y update
    dnf -y install dnf-plugins-core
    dnf config-manager --add-repo "$repo_url"
    dnf -y install \
        winehq-stable \
        xorg-x11-apps \
        xorg-x11-server-Xvfb \
        xorg-x11-xauth
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_fedora() {
    # """
    # Update Fedora.
    # @note Updated 2020-07-16.
    # """
    koopa::assert_has_no_args "$#"
    (
        sudo dnf update -y
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    return 0
}
