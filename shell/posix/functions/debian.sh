#!/bin/sh
# shellcheck disable=SC2039

_koopa_apt_add_azure_cli_repo() {  # {{{1
    # """
    # Add Microsoft Azure CLI apt repo.
    # @note Updated 2020-06-02.
    # """
    local file
    file="/etc/apt/sources.list.d/azure-cli.list"
    [ -f "$file" ] && return 0
    _koopa_h2 "Adding Microsoft Azure CLI repo at '${file}'."
    _koopa_apt_add_microsoft_key
    local os_codename
    os_codename="$(_koopa_os_codename)"
    local url
    url="https://packages.microsoft.com/repos/azure-cli/"
    local string
    string="deb [arch=amd64] ${url} ${os_codename} main"
    _koopa_sudo_write_string "$string" "$file"
}

_koopa_apt_add_docker_key() {  # {{{1
    # """
    # Add the Docker key.
    # @note Updated 2020-06-02.
    # """
    local name
    name="Docker"
    local url
    url="https://download.docker.com/linux/$(_koopa_os_id)/gpg"
    local key
    key="9DC858229FC7DD38854AE2D88D81803C0EBFCD88"
    _koopa_apt_key_add "$name" "$url" "$key"
}

_koopa_apt_add_docker_repo() {  # {{{1
    # """
    # Add Docker apt repo.
    #
    # @note Updated 2020-06-02.
    #
    # Ubuntu 20 (Focal Fossa) not yet supported:
    # https://download.docker.com/linux/
    # """
    local file
    file="/etc/apt/sources.list.d/docker.list"
    [ -f "$file" ] && return 0
    _koopa_h2 "Adding Docker repo at '${file}'."
    _koopa_apt_add_docker_key
    local os_id
    os_id="$(_koopa_os_id)"
    local os_codename
    os_codename="$(_koopa_os_codename)"
    # Remap 20.04 LTS to 19.10.
    case "$os_codename" in
        focal)
            os_codename="eoan"
            ;;
    esac
    local url
    url="https://download.docker.com/linux/${os_id}"
    local string
    string="deb [arch=amd64] ${url} ${os_codename} stable"
    _koopa_sudo_write_string "$string" "$file"
}

_koopa_apt_add_google_cloud_key() {  # {{{1
    # """
    # Add the Google Cloud key.
    # @note Updated 2020-06-02.
    # """
    local url
    url="https://packages.cloud.google.com/apt/doc/apt-key.gpg"
    local file
    file="/usr/share/keyrings/cloud.google.gpg"
    [ -e "$file" ] && return 0
    _koopa_h3 "Adding Google Cloud keyring at '${file}'."
    curl -fsSL "$url" \
        | sudo apt-key --keyring "$file" add - \
        >/dev/null 2>&1
    return 0
}

_koopa_apt_add_google_cloud_sdk_repo() {  # {{{1
    # """
    # Add Google Cloud SDK apt repo.
    # @note Updated 2020-03-06.
    # """
    local file
    file="/etc/apt/sources.list.d/google-cloud-sdk.list"
    [ -f "$file" ] && return 0
    _koopa_h2 "Adding Google Cloud SDK repo at '${file}'."
    _koopa_apt_add_google_cloud_key
    local string
    string="deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
https://packages.cloud.google.com/apt cloud-sdk main"
    _koopa_sudo_write_string "$string" "$file"
}

_koopa_apt_add_llvm_key() {  # {{{1
    # """
    # Add the LLVM key.
    # @note Updated 2020-06-02.
    # """
    local name
    name="LLVM"
    local url
    url="https://apt.llvm.org/llvm-snapshot.gpg.key"
    local key
    key="6084F3CF814B57C1CF12EFD515CF4D18AF4F7421"
    _koopa_apt_key_add "$name" "$url" "$key"
}

_koopa_apt_add_llvm_repo() {  # {{{1
    # """
    # Add LLVM apt repo.
    # @note Updated 2020-06-02.
    # """
    local file
    file="/etc/apt/sources.list.d/llvm.list"
    [ -f "$file" ] && return 0
    _koopa_h2 "Adding LLVM repo at '${file}'."
    _koopa_apt_add_llvm_key
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

_koopa_apt_add_microsoft_key() {  #{{{1
    # """
    # Add the Microsoft Azure CLI key.
    # @note Updated 2020-06-02.
    # """
    local url
    url="https://packages.microsoft.com/keys/microsoft.asc"
    local file
    file="/etc/apt/trusted.gpg.d/microsoft.asc.gpg"
    [ -e "$file" ] && return 0
    _koopa_h3 "Adding Microsoft key at '${file}'."
    curl -fsSL "$url" \
        | gpg --dearmor \
        | sudo tee "$file" \
        >/dev/null 2>&1
    return 0
}

_koopa_apt_add_r_key() {  # {{{1
    # """
    # Add the R key.
    # @note Updated 2020-06-02.
    # """
    local key keyserver
    if _koopa_is_ubuntu
    then
        # Release is signed by Michael Rutter <marutter@gmail.com>.
        key="E298A3A825C0D65DFD57CBB651716619E084DAB9"
        keyserver="keyserver.ubuntu.com"
    else
        # Release is signed by Johannes Ranke <jranke@uni-bremen.de>.
        key="E19F5F87128899B192B1A2C2AD5F960A256A04AF"
        keyserver="keys.gnupg.net"
    fi
    _koopa_apt_is_key_imported "$key" && return 0
    _koopa_h3 "Adding R key."
    sudo apt-key adv \
        --keyserver "$keyserver" \
        --recv-key "$key" \
        >/dev/null 2>&1
    return 0
}

# shellcheck disable=SC2120
_koopa_apt_add_r_repo() {  # {{{1
    # """
    # Add R apt repo.
    # @note Updated 2020-06-02.
    # """
    local version
    version="${1:-}"
    if [ -z "$version" ]
    then
        version="$(_koopa_variable "r")"
    fi
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
        # Early return if version matches and Debian source is enabled.
        if _koopa_file_match "$file" "$version" && \
            _koopa_file_match "$file" "deb-src"
        then
            return 0
        else
            sudo rm -frv "$file"
        fi
    fi
    _koopa_h2 "Adding R repo at '${file}'."
    _koopa_apt_add_r_key
    local os_id
    os_id="$(_koopa_os_id)"
    local os_codename
    os_codename="$(_koopa_os_codename)"
    local repo
    repo="https://cloud.r-project.org/bin/linux/${os_id} \
${os_codename}-${version}/"
    # Note that 'read' will return status 1 here.
    # https://unix.stackexchange.com/questions/80045/
    local string
    read -r -d '' string << EOF || true
deb ${repo}
deb-src ${repo}
EOF
    _koopa_sudo_write_string "$string" "$file"
}

_koopa_apt_add_wine_key() {  # {{{1
    # """
    # Add the WineHQ key.
    #
    # @note Updated 2020-06-02.
    #
    # Email: <wine-devel@winehq.org>
    #
    # - Debian:
    #   https://wiki.winehq.org/Debian
    # - Ubuntu:
    #   https://wiki.winehq.org/Ubuntu
    #
    # > wget -O - https://dl.winehq.org/wine-builds/winehq.key \
    # >     | sudo apt-key add -
    #
    # > wget -nc https://dl.winehq.org/wine-builds/winehq.key
    # > sudo apt-key add winehq.key
    # """
    local name
    name="Wine"
    local url
    url="https://dl.winehq.org/wine-builds/winehq.key"
    local key
    key="D43F640145369C51D786DDEA76F1A20FF987672F"
    _koopa_apt_key_add "$name" "$url" "$key"
}

_koopa_apt_add_wine_repo() {  # {{{1
    # """
    # Add WineHQ repo.
    #
    # - Debian:
    #   https://wiki.winehq.org/Debian
    # - Ubuntu:
    #   https://wiki.winehq.org/Ubuntu
    #
    # @note Updated 2020-06-03.
    # """
    local file
    file="/etc/apt/sources.list.d/wine.list"
    [ -f "$file" ] && return 0
    _koopa_h2 "Adding Wine repo at '${file}'."
    _koopa_apt_add_wine_key
    local os_id
    os_id="$(_koopa_os_id)"
    local os_codename
    os_codename="$(_koopa_os_codename)"
    local url
    url="https://dl.winehq.org/wine-builds/${os_id}/"
    local string
    string="deb ${url} ${os_codename} main"
    _koopa_sudo_write_string "$string" "$file"
}

_koopa_apt_add_wine_obs_key() {  # {{{1
    # """
    # Add the Wine OBS openSUSE key.
    # @note Updated 2020-06-02.
    # """
    local name
    name="Wine OBS"
    local os_string
    os_string="$(_koopa_os_string)"
    local key url
    # Signed by <Emulators@build.opensuse.org>.
    key="31CFB0B65659B5D40DEEC98DDFA175A75104960E"
    local subdir
    case "$os_string" in
        debian-10)
            subdir="Debian_10"
            ;;
        ubuntu-18)
            url="xUbuntu_18.04"
            ;;
        ubuntu-20)
            url="xUbuntu_20.04"
            ;;
        *)
            _koopa_stop "Unsupported OS: '${os_string}'."
            ;;
    esac
    local url
    url="https://download.opensuse.org/repositories/\
Emulators:/Wine:/Debian/${subdir}/Release.key"
    _koopa_apt_key_add "$name" "$url" "$key"
}

_koopa_apt_add_wine_obs_repo() {  # {{{1
    # """
    # Add Wine OBS openSUSE repo.
    # @note Updated 2020-06-03.
    #
    # Required to install libfaudio0 dependency for Wine on Debian 10+.
    #
    # See also:
    # - https://wiki.winehq.org/Debian
    # - https://forum.winehq.org/viewtopic.php?f=8&t=32192
    # """
    local file
    file="/etc/apt/sources.list.d/wine-obs.list"
    [ -f "$file" ] && return 0
    _koopa_h2 "Adding Wine OBS repo at '${file}'."
    _koopa_apt_add_wine_obs_key
    local base_url
    base_url="https://download.opensuse.org/repositories/\
Emulators:/Wine:/Debian"
    local os_string
    os_string="$(_koopa_os_string)"
    local repo_url
    case "$os_string" in
        debian-10)
            repo_url="${base_url}/Debian_10/"
            ;;
        ubuntu-18)
            repo_url="${base_url}/xUbuntu_18.04/"
            ;;
        *)
            _koopa_stop "Unsupported OS: '${os_string}'."
            ;;
    esac
    local string
    string="deb ${repo_url} ./"
    _koopa_sudo_write_string "$string" "$file"
    return 0
}

_koopa_apt_configure_sources() {  # {{{1
    # """
    # Configure apt sources.
    # @note Updated 2020-06-02.
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
        sudo tee "$sources_list" >/dev/null << EOF
deb http://archive.ubuntu.com/ubuntu/ ${os_codename} main restricted universe
deb http://archive.ubuntu.com/ubuntu/ ${os_codename}-updates main restricted universe
deb http://security.ubuntu.com/ubuntu/ ${os_codename}-security main restricted universe
EOF
    else
        sudo tee "$sources_list" >/dev/null << EOF
deb http://deb.debian.org/debian ${os_codename} main
deb http://deb.debian.org/debian ${os_codename}-updates main
deb http://security.debian.org/debian-security ${os_codename}/updates main
EOF
    fi

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

_koopa_apt_get() {  # {{{1
    # """
    # Non-interactive variant of apt-get, with saner defaults.
    # @note Updated 2020-05-12.
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

_koopa_apt_install() {  # {{{1
    # """
    # Install Debian apt package.
    # @note Updated 2020-05-12.
    # """
    _koopa_apt_get install "$@"
}

_koopa_apt_is_key_imported() {  # {{{1
    # """
    # Is a GPG key imported for apt?
    # @note Updated 2020-06-02.
    # """
    local key
    key="${1:?}"
    key="$( \
        _koopa_print "$key" \
        | sed 's/ //g' \
        | sed -E "s/\
^(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})\$/\
\1 \2 \3 \4 \5  \6 \7 \8 \9 \10/" \
    )"
    local x
    x="$(apt-key list 2>&1 || true)"
    _koopa_str_match "$x" "$key"
}

_koopa_apt_key_add() {  #{{{1
    # """
    # Add an apt key.
    # @note Updated 2020-06-02.
    #
    # Using '-k/--insecure' flag here to handle some servers
    # (e.g. download.opensuse.org) that will fail otherwise.
    # """
    local name url key
    name="${1:?}"
    url="${2:?}"
    key="${3:-}"
    if [ -n "$key" ]
    then
        _koopa_apt_is_key_imported "$key" && return 0
    fi
    _koopa_h3 "Adding ${name} key."
    curl -fksSL "$url" \
        | sudo apt-key add - \
        >/dev/null 2>&1
    return 0
}

_koopa_apt_remove() {  # {{{1
    # """
    # Remove Debian apt package.
    # @note Updated 2020-04-29.
    # """
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
