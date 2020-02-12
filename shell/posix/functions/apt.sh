#!/bin/sh
# shellcheck disable=SC2039

_koopa_apt_add_azure_cli_repo() {
    # """
    # Add Microsoft Azure CLI apt repo.
    # @note Updated 2020-02-12.
    # """
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    local sources_list
    sources_list="/etc/apt/sources.list.d/azure-cli.list"
    [ -f "$sources_list" ] && return 0
    local AZ_REPO
    AZ_REPO="$(lsb_release -cs)"
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ \
    ${AZ_REPO} main" | sudo tee "$sources_list"
}

_koopa_apt_disable_deb_src() {                                            # {{{1
    # """
    # Enable 'deb-src' source packages.
    # Updated 2020-02-05.
    # """
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    local file
    file="${1:-/etc/apt/sources.list}"
    file="$(realpath "$file")"
    _koopa_h2 "Disabling Debian sources in '${file}'."
    if ! grep -Eq '^deb-src ' "$file"
    then
        _koopa_note "No 'deb-src' lines to comment in '${file}'."
        return 0
    fi
    sed -Ei 's/^deb-src /# deb-src /' "$file"
    sudo apt-get update
    return 0
}

_koopa_apt_enable_deb_src() {                                             # {{{1
    # """
    # Enable 'deb-src' source packages.
    # Updated 2020-02-05.
    # """
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    local file
    file="${1:-/etc/apt/sources.list}"
    file="$(realpath "$file")"
    _koopa_h2 "Enabling Debian sources in '${file}'."
    if ! grep -Eq '^# deb-src ' "$file"
    then
        _koopa_note "No '# deb-src' lines to uncomment in '${file}'."
        return 0
    fi
    sudo sed -Ei 's/^# deb-src /deb-src /' "$file"
    sudo apt-get update
    return 0
}

_koopa_apt_enabled_repos() {                                              # {{{1
    # """
    # Get a list of enabled default apt repos.
    # Updated 2020-02-07.
    # """
    grep -E '^deb ' /etc/apt/sources.list \
        | cut -d ' ' -f 4 \
        | awk '!a[$0]++' \
        | sort
}

_koopa_apt_import_azure_cli_key() {                                        #{{{1
    # """
    # Import the Microsoft Azure CLI public key.
    # @note Updated 2020-02-12.
    # """
    _koopa_assert_has_sudo
    _koopa_assert_is_installed curl gpg
    # > _koopa_assert_is_file "/etc/apt/sources.list.d/azure-cli.list"
    _koopa_h2 "Adding official Microsoft public key."
    curl -sL https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor \
        | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
    return 0
}

_koopa_apt_import_docker_key() {                                          # {{{1
    # """
    # Import the Docker public key.
    # @note Updated 2020-02-12.
    # """
    _koopa_assert_has_sudo
    _koopa_assert_is_installed curl
    # > _koopa_assert_is_file "/etc/apt/sources.list.d/docker.list"
    _koopa_h2 "Adding official Docker public key."
    # Expecting "debian" or "ubuntu" here.
    local os_id
    os_id="$(_koopa_os_id)"
    curl -fsSL "https://download.docker.com/linux/${os_id}/gpg" \
        | sudo apt-key add - \
        > /dev/null 2>&1
    return 0
}

_koopa_apt_import_google_cloud_key() {                                    # {{{1
    # """
    # Import the Google Cloud public key.
    # @note Updated 2020-02-12.
    # """
    _koopa_assert_has_sudo
    _koopa_assert_is_installed curl
    # > _koopa_assert_is_file "/etc/apt/sources.list.d/google-cloud-sdk.list"
    _koopa_h2 "Adding official Google Cloud SDK public key."
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    return 0
}

_koopa_apt_import_llvm_key() {                                            # {{{1
    # """
    # Import the LLVM public key.
    # @note Updated 2020-02-12.
    # """
    _koopa_assert_has_sudo
    _koopa_assert_is_installed curl
    # > _koopa_assert_is_file "/etc/apt/sources.list.d/llvm.list"
    _koopa_h2 "Adding official LLVM public key."
    curl -fsSL "https://apt.llvm.org/llvm-snapshot.gpg.key" \
        | sudo apt-key add - \
        > /dev/null 2>&1
    return 0
}

_koopa_apt_import_r_key() {                                               # {{{1
    # """
    # Import the R public key.
    # @note Updated 2020-02-12.
    # """
    _koopa_assert_has_sudo
    _koopa_h2 "Adding official R public key."
    # > _koopa_assert_is_file "/etc/apt/sources.list.d/r.list"
    if _koopa_is_ubuntu
    then
        # Release is signed by Michael Rutter <marutter@gmail.com>.
        sudo apt-key adv \
            --keyserver keyserver.ubuntu.com \
            --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
            > /dev/null 2>&1
    else
        # Release is signed by Johannes Ranke <jranke@uni-bremen.de>.
        sudo apt-key adv \
            --keyserver keys.gnupg.net \
            --recv-key E19F5F87128899B192B1A2C2AD5F960A256A04AF \
            > /dev/null 2>&1
    fi
    return 0
}

_koopa_apt_import_keys() {                                                # {{{1
    # """
    # Import GPG keys used to sign apt repositories.
    # Updated 2020-02-12.
    #
    # Refer to 'Secure apt' section for details.
    #
    # Get list of enabled apt repositories:
    # https://stackoverflow.com/questions/8647454
    #
    # Can use 'wget -O' instead of curl call below.
    #
    # Variables that may be useful:
    # > local distro
    # > distro="$(lsb_release -is)"
    # > local version
    # > version="$(lsb_release -sr)"
    # > local dist_version
    # > dist_version="${distro}_${version}"
    #
    # See also:
    # - install-docker
    # - install-llvm
    # - install-r
    # """
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    _koopa_assert_is_installed curl

    _koopa_h1 "Importing signatures for GPG-signed apt repositories."

    local apt_repos
    apt_repos="$( \
        grep -h '^deb' \
            /etc/apt/sources.list \
            /etc/apt/sources.list.d/* \
    )"

    # Docker.
    if _koopa_is_matching_fixed "$apt_repos" "download.docker.com"
    then
        _koopa_apt_import_docker_key
    fi

    # Google Cloud SDK.
    if _koopa_is_matching_fixed "$apt_repos" "cloud.google.com"
    then
        _koopa_apt_import_google_cloud_key
    fi

    # LLVM.
    if _koopa_is_matching_fixed "$apt_repos" "apt.llvm.org"
    then
        _koopa_apt_import_llvm_key
    fi

    # R.
    if _koopa_is_matching_fixed "$apt_repos" "cloud.r-project.org"
    then
        _koopa_apt_import_r_key
    fi

    return 0
}

_koopa_apt_link_sources() {                                               # {{{1
    # """
    # Symlink 'sources.list' files in '/etc/apt'.
    # Updated 2020-02-05.
    # """
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    local prefix
    prefix="$(_koopa_prefix)"
    local os_id
    os_id="$(_koopa_os_id)"
    local source_dir
    source_dir="${prefix}/os/${os_id}/etc/apt"
    _koopa_assert_is_dir "$source_dir"
    local target_dir
    target_dir="/etc/apt"
    _koopa_assert_is_dir "$target_dir"
    _koopa_h2 "Linking Debian sources in '${target_dir}'."
    sudo ln -fnsv \
        "${source_dir}/sources.list" \
        "${target_dir}/sources.list"
    sudo rm -fv "${target_dir}/sources.list~"
    sudo rm -frv "${target_dir}/sources.list.d"
    sudo ln -fnsv \
        "${source_dir}/sources.list.d" \
        "${target_dir}/sources.list.d"
    sudo apt-get update
    return 0
}


_koopa_apt_space_used_by() {                                              # {{{1
    # """
    # Check installed apt package size, with dependencies.
    # Updated 2020-01-31.
    #
    # Alternate approach that doesn't attempt to grep match.
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    sudo apt-get --assume-no autoremove "$@"
}

_koopa_apt_space_used_by_grep() {                                         # {{{1
    # """
    # Check installed apt package size, with dependencies.
    # Updated 2020-01-31.
    #
    # See also:
    # https://askubuntu.com/questions/490945
    # """
    _koopa_assert_is_debian
    _koopa_assert_has_sudo
    sudo apt-get --assume-no autoremove "$@" \
        | grep freed \
        | cut -d ' ' -f 4-5
}

_koopa_apt_space_used_by_no_deps() {                                      # {{{1
    # """
    # Check install apt package size, without dependencies.
    # Updated 2020-01-31.
    # """
    sudo apt show "$@" | grep 'Size'
}
