#!/bin/sh
# shellcheck disable=SC2039

__koopa_apt_get() {  # {{{1
    # """
    # Non-interactive variant of apt-get, with saner defaults.
    # @note Updated 2020-04-29.
    #
    # Currently intended for:
    # - dist-upgrade
    # - install
    # """
    sudo apt-get update
    sudo DEBIAN_FRONTEND="noninteractive" \
        apt-get \
            --no-install-recommends \
            --quiet \
            --yes \
            "$@"
    return 0
}



_koopa_apt_add_azure_cli_repo() {  # {{{1
    # """
    # Add Microsoft Azure CLI apt repo.
    #
    # @note Updated 2020-04-28.
    #
    # Ubutu 20 (Focal Fossa) isn't supported yet:
    # https://packages.microsoft.com/repos/azure-cli/dists/
    # """
    local file
    file="/etc/apt/sources.list.d/azure-cli.list"
    [ -f "$file" ] && return 0
    local os_codename
    os_codename="$(_koopa_os_codename)"
    # Remap 20.04 LTS to 18.04 LTS.
    case "$os_codename" in
        focal)
            os_codename="bionic"
            ;;
    esac
    local string
    string="deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ \
${os_codename} main"
    _koopa_sudo_write_string "$string" "$file"
}

_koopa_apt_add_docker_repo() {  # {{{1
    # """
    # Add Docker apt repo.
    #
    # @note Updated 2020-04-28.
    #
    # Ubuntu 20 (Focal Fossa) not yet supported:
    # https://download.docker.com/linux/
    # """
    local file
    file="/etc/apt/sources.list.d/docker.list"
    [ -f "$file" ] && return 0
    local os_id
    os_id="$(_koopa_os_id)"
    local os_codename
    os_codename="$(_koopa_os_codename)"
    # Remap 20.04 LTS to 18.04 LTS.
    case "$os_codename" in
        focal)
            os_codename="bionic"
            ;;
    esac
    local string
    string="deb [arch=amd64] https://download.docker.com/linux/${os_id} \
${os_codename} stable"
    _koopa_sudo_write_string "$string" "$file"
}

_koopa_apt_add_google_cloud_sdk_repo() {  # {{{1
    # """
    # Add Google Cloud SDK apt repo.
    # @note Updated 2020-03-06.
    # """
    local file
    file="/etc/apt/sources.list.d/google-cloud-sdk.list"
    [ -f "$file" ] && return 0
    local string
    string="deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
https://packages.cloud.google.com/apt cloud-sdk main"
    _koopa_sudo_write_string "$string" "$file"
}

_koopa_apt_add_llvm_repo() {  # {{{1
    # """
    # Add LLVM apt repo.
    # @note Updated 2020-03-28.
    # """
    local file
    file="/etc/apt/sources.list.d/llvm.list"
    [ -f "$file" ] && return 0
    local os_codename
    os_codename="$(_koopa_os_codename)"
    local version
    version="$(_koopa_variable "llvm")"
    version="$(_koopa_major_version "$version")"
    local string
    string="deb http://apt.llvm.org/${os_codename}/ \
llvm-toolchain-${os_codename}-${version} main"

    _koopa_sudo_write_string "$string" "$file"
}

_koopa_apt_add_r_repo() {  # {{{1
    # """
    # Add R apt repo.
    # @note Updated 2020-04-29.
    # """
    local version
    version="$(_koopa_variable "r")"
    case "$version" in
        3.6*)
            version="3.5"
            ;;
    esac
    version="$(_koopa_major_minor_version "$version")"
    version="$(_koopa_gsub "$version" "\.")"
    version="cran${version}"

    local file
    file="/etc/apt/sources.list.d/r.list"
    if [ -f "$file" ]
    then
        if _koopa_file_match "$file" "$version"
        then
            return 0
        else
            sudo rm -frv "$file"
        fi
    fi

    local os_id
    os_id="$(_koopa_os_id)"

    local os_codename
    os_codename="$(_koopa_os_codename)"

    local repo
    repo="https://cloud.r-project.org/bin/linux/${os_id} \
${os_codename}-${version}/"

    # Note that we're enabling source repo, for R-devel.
    local string
    read -d '' string << EOF
deb ${repo}
deb-src ${repo}
EOF

    _koopa_sudo_write_string "$string" "$file"
}

_koopa_apt_configure_sources() {  # {{{1
    # """
    # Configure apt sources.
    # @note Updated 2020-02-24.
    #
    # Previously, we used a symlink approach until 2020-02-24.
    # """
    local sources_list
    sources_list="/etc/apt/sources.list"
    [ -L "$sources_list" ] && _koopa_rm "$sources_list"

    local sources_list_d
    sources_list_d="/etc/apt/sources.list.d"
    [ -L "$sources_list_d" ] && _koopa_rm "$sources_list_d"
    sudo mkdir -p "$sources_list_d"

    local os_codename
    os_codename="$(_koopa_os_codename)"

    if _koopa_is_ubuntu
    then
        sudo tee "$sources_list" > /dev/null << EOF
deb http://archive.ubuntu.com/ubuntu/ ${os_codename} main restricted universe
deb http://archive.ubuntu.com/ubuntu/ ${os_codename}-updates main restricted universe
deb http://security.ubuntu.com/ubuntu/ ${os_codename}-security main restricted universe
EOF
    else
        sudo tee "$sources_list" > /dev/null << EOF
deb http://deb.debian.org/debian ${os_codename} main
deb http://deb.debian.org/debian ${os_codename}-updates main
deb http://security.debian.org/debian-security ${os_codename}/updates main
EOF
    fi

    _koopa_apt_add_azure_cli_repo
    _koopa_apt_add_docker_repo
    _koopa_apt_add_google_cloud_sdk_repo
    _koopa_apt_add_llvm_repo
    _koopa_apt_add_r_repo

    return 0
}

_koopa_apt_disable_deb_src() {  # {{{1
    # """
    # Enable 'deb-src' source packages.
    # @note Updated 2020-02-05.
    # """
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

_koopa_apt_enable_deb_src() {  # {{{1
    # """
    # Enable 'deb-src' source packages.
    # @note Updated 2020-02-05.
    # """
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

_koopa_apt_enabled_repos() {  # {{{1
    # """
    # Get a list of enabled default apt repos.
    # @note Updated 2020-02-24.
    # """
    local os_codename
    os_codename="$(_koopa_os_codename)"
    local x
    x="$( \
        grep -E "^deb\s.+\s${os_codename}\s.+$" /etc/apt/sources.list \
            | cut -d ' ' -f 4- \
    )"
    _koopa_print "$x"
}

_koopa_apt_import_azure_cli_key() {                                        #{{{1
    # """
    # Import the Microsoft Azure CLI public key.
    # @note Updated 2020-03-04.
    # """
    [ -e "/etc/apt/trusted.gpg.d/microsoft.asc.gpg" ] && return 0
    _koopa_assert_is_installed curl gpg
    _koopa_h2 "Importing Microsoft public key."
    curl -sL https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor \
        | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
    return 0
}

_koopa_apt_import_docker_key() {  # {{{1
    # """
    # Import the Docker public key.
    # @note Updated 2020-03-04.
    # """
    local key
    key="9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"
    _koopa_apt_is_key_imported "$key" && return 0
    _koopa_assert_is_installed curl
    _koopa_h2 "Importing Docker public key."
    # Expecting "debian" or "ubuntu" here.
    local os_id
    os_id="$(_koopa_os_id)"
    curl -fsSL "https://download.docker.com/linux/${os_id}/gpg" \
        | sudo apt-key add - \
        > /dev/null 2>&1
    return 0
}

_koopa_apt_import_google_cloud_key() {  # {{{1
    # """
    # Import the Google Cloud public key.
    # @note Updated 2020-03-04.
    # """
    [ -e "/usr/share/keyrings/cloud.google.gpg" ] && return 0
    _koopa_assert_is_installed curl
    _koopa_h2 "Importing Google Cloud SDK public key."
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    return 0
}

_koopa_apt_import_llvm_key() {  # {{{1
    # """
    # Import the LLVM public key.
    # @note Updated 2020-03-04.
    # """
    key="6084 F3CF 814B 57C1 CF12  EFD5 15CF 4D18 AF4F 7421"
    _koopa_apt_is_key_imported "$key" && return 0
    _koopa_assert_is_installed curl
    _koopa_h2 "Importing LLVM public key."
    curl -fsSL "https://apt.llvm.org/llvm-snapshot.gpg.key" \
        | sudo apt-key add - \
        > /dev/null 2>&1
    return 0
}

_koopa_apt_import_keys() {  # {{{1
    # """
    # Import GPG keys used to sign apt repositories.
    # @note Updated 2020-02-12.
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
    # - install-azure-cli
    # - install-docker
    # - install-google-cloud-sdk
    # - install-llvm
    # - install-r
    # """
    _koopa_h1 "Importing signatures for signed apt repositories."
    _koopa_apt_import_azure_cli_key
    _koopa_apt_import_docker_key
    _koopa_apt_import_google_cloud_key
    _koopa_apt_import_llvm_key
    _koopa_apt_import_r_key
    return 0
}

_koopa_apt_import_r_key() {  # {{{1
    # """
    # Import the R public key.
    # @note Updated 2020-03-04.
    # """
    if _koopa_is_ubuntu
    then
        key="E298 A3A8 25C0 D65D FD57  CBB6 5171 6619 E084 DAB9"
    else
        key="E19F 5F87 1288 99B1 92B1  A2C2 AD5F 960A 256A 04AF"
    fi
    _koopa_apt_is_key_imported "$key" && return 0
    _koopa_h2 "Importing R public key."
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

_koopa_apt_install() {  # {{{1
    # """
    # Install Debian apt package.
    # @note Updated 2020-04-29.
    # """
    __koopa_apt_get install "$@"
}

_koopa_apt_is_key_imported() {  # {{{1
    # """
    # Is a GPG key imported for apt?
    # @note Updated 2020-03-04.
    # """
    local key
    key="${1:?}"
    local x
    x="$(apt-key list 2>&1 || true)"
    _koopa_str_match "$x" "$key"
}

_koopa_apt_remove() {  # {{{1
    # """
    # Remove Debian apt package.
    # @note Updated 2020-04-29.
    # """
    # > sudo apt-get update
    sudo apt-get --yes remove --purge "$@"
    sudo apt-get --yes clean
    sudo apt-get --yes autoremove
    return 0
}

_koopa_apt_space_used_by() {  # {{{1
    # """
    # Check installed apt package size, with dependencies.
    # @note Updated 2020-01-31.
    #
    # Alternate approach that doesn't attempt to grep match.
    sudo apt-get --assume-no autoremove "$@"
    return 0
}

_koopa_apt_space_used_by_grep() {  # {{{1
    # """
    # Check installed apt package size, with dependencies.
    # @note Updated 2020-02-16.
    #
    # See also:
    # https://askubuntu.com/questions/490945
    # """
    local x
    x="$( \
        sudo apt-get --assume-no autoremove "$@" \
            | grep freed \
            | cut -d ' ' -f 4-5 \
    )"
    _koopa_print "$x"
}

_koopa_apt_space_used_by_no_deps() {  # {{{1
    # """
    # Check install apt package size, without dependencies.
    # @note Updated 2020-01-31.
    # """
    sudo apt show "$@" | grep 'Size'
    return 0
}
