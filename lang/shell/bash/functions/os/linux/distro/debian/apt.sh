#!/usr/bin/env bash

koopa:::debian_apt_key_add() {  #{{{1
    # """
    # Add an apt key.
    # @note Updated 2021-06-11.
    #
    # Using '-k/--insecure' flag here to handle some servers
    # (e.g. download.opensuse.org) that will fail otherwise.
    # """
    local curl name_fancy url key
    koopa::assert_has_args_le "$#" 3
    curl="$(koopa::locate_curl)"
    koopa::assert_is_installed 'apt-key'
    name_fancy="${1:?}"
    url="${2:?}"
    key="${3:-}"
    if [[ -n "$key" ]]
    then
        koopa::debian_apt_is_key_imported "$key" && return 0
    fi
    koopa::alert "Adding '${name_fancy}' key to apt."
    "$curl" -fksSL "$url" \
        | sudo apt-key add - \
        >/dev/null 2>&1 \
        || true
    return 0
}

koopa::debian_apt_add_azure_cli_repo() { # {{{1
    # """
    # Add Microsoft Azure CLI apt repo.
    # @note Updated 2021-06-11.
    # """
    local arch file name name_fancy os_codename string url
    koopa::assert_has_no_args "$#"
    name='azure-cli'
    name_fancy='Microsoft Azure CLI'
    file="/etc/apt/sources.list.d/${name}.list"
    if [[ -f "$file" ]]
    then
        koopa::alert_info "${name_fancy} repo exists at '${file}'."
        return 0
    fi
    koopa::alert "Adding ${name_fancy} repo at '${file}'."
    koopa::debian_apt_add_microsoft_key
    os_codename="$(koopa::os_codename)"
    arch="$(koopa::arch)"
    url="https://packages.microsoft.com/repos/${name}/"
    string="deb [arch=${arch}] ${url} ${os_codename} main"
    koopa::sudo_write_string "$string" "$file"
    return 0
}

koopa::debian_apt_add_docker_key() { # {{{1
    # """
    # Add the Docker key.
    # @note Updated 2021-06-11.
    # """
    local key name_fancy os_id url
    koopa::assert_has_no_args "$#"
    name_fancy='Docker'
    os_id="$(koopa::os_id)"
    url="https://download.docker.com/linux/${os_id}/gpg"
    key='9DC858229FC7DD38854AE2D88D81803C0EBFCD88'
    koopa:::debian_apt_key_add "$name_fancy" "$url" "$key"
    return 0
}

koopa::debian_apt_add_docker_repo() { # {{{1
    # """
    # Add Docker apt repo.
    # @note Updated 2021-06-11.
    #
    # Ubuntu 20 (Focal Fossa) not yet supported:
    # https://download.docker.com/linux/
    # """
    local arch file name name_fancy os_codename os_id string url
    koopa::assert_has_no_args "$#"
    name='docker'
    name_fancy='Docker'
    file="/etc/apt/sources.list.d/${name}.list"
    if [[ -f "$file" ]]
    then
        koopa::alert_info "${name_fancy} repo exists at '${file}'."
        return 0
    fi
    koopa::alert "Adding ${name_fancy} repo at '${file}'."
    koopa::debian_apt_add_docker_key
    os_id="$(koopa::os_id)"
    os_codename="$(koopa::os_codename)"
    arch="$(koopa::arch)"
    # Remap 20.04 LTS to 19.10.
    case "$os_codename" in
        focal)
            os_codename='eoan'
            ;;
    esac
    url="https://download.docker.com/linux/${os_id}"
    string="deb [arch=${arch}] ${url} ${os_codename} stable"
    koopa::sudo_write_string "$string" "$file"
    return 0
}

koopa::debian_apt_add_google_cloud_key() { # {{{1
    # """
    # Add the Google Cloud key.
    # @note Updated 2020-08-17.
    # """
    local curl file url
    koopa::assert_has_no_args "$#"
    curl="$(koopa::locate_curl)"
    koopa::assert_is_installed 'apt-key'
    url='https://packages.cloud.google.com/apt/doc/apt-key.gpg'
    file='/usr/share/keyrings/cloud.google.gpg'
    [[ -e "$file" ]] && return 0
    koopa::alert "Adding Google Cloud keyring at '${file}'."
    "$curl" -fsSL "$url" \
        | sudo apt-key --keyring "$file" add - \
        >/dev/null 2>&1 \
        || true
    return 0
}

koopa::debian_apt_add_google_cloud_sdk_repo() { # {{{1
    # """
    # Add Google Cloud SDK apt repo.
    # @note Updated 2021-06-11.
    # """
    local file name name_fancy string
    koopa::assert_has_no_args "$#"
    name='google-cloud-sdk'
    name_fancy='Google Cloud SDK'
    file="/etc/apt/sources.list.d/${name}.list"
    if [[ -f "$file" ]]
    then
        koopa::alert_info "${name_fancy} repo exists at '${file}'."
        return 0
    fi
    koopa::alert "Adding ${name_fancy} repo at '${file}'."
    koopa::debian_apt_add_google_cloud_key
    string="deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
https://packages.cloud.google.com/apt cloud-sdk main"
    koopa::sudo_write_string "$string" "$file"
    return 0
}

koopa::debian_apt_add_llvm_key() { # {{{1
    # """
    # Add the LLVM key.
    # @note Updated 2021-06-11.
    # """
    local key name_fancy url
    koopa::assert_has_no_args "$#"
    name_fancy='LLVM'
    url='https://apt.llvm.org/llvm-snapshot.gpg.key'
    key='6084F3CF814B57C1CF12EFD515CF4D18AF4F7421'
    koopa:::debian_apt_key_add "$name_fancy" "$url" "$key"
    return 0
}

koopa::debian_apt_add_llvm_repo() { # {{{1
    # """
    # Add LLVM apt repo.
    # @note Updated 2021-06-11.
    # """
    local file name name_fancy os_codename string version
    koopa::assert_has_no_args "$#"
    name='llvm'
    name_fancy='LLVM'
    file="/etc/apt/sources.list.d/${name}.list"
    if [[ -f "$file" ]]
    then
        koopa::alert_info "${name_fancy} repo exists at '${file}'."
        return 0
    fi
    koopa::alert "Adding ${name_fancy} repo at '${file}'."
    koopa::debian_apt_add_llvm_key
    os_codename="$(koopa::os_codename)"
    version="$(koopa::variable "$name")"
    version="$(koopa::major_version "$version")"
    string="deb http://apt.llvm.org/${os_codename}/ \
llvm-toolchain-${os_codename}-${version} main"
    koopa::sudo_write_string "$string" "$file"
    return 0
}

koopa::debian_apt_add_microsoft_key() {  #{{{1
    # """
    # Add the Microsoft Azure CLI key.
    # @note Updated 2021-06-14.
    # """
    local curl file gpg tee url
    koopa::assert_has_no_args "$#"
    curl="$(koopa::locate_curl)"
    gpg="$(koopa::locate_gpg)"
    tee="$(koopa::locate_tee)"
    url='https://packages.microsoft.com/keys/microsoft.asc'
    file='/etc/apt/trusted.gpg.d/microsoft.asc.gpg'
    [[ -e "$file" ]] && return 0
    koopa::alert "Adding Microsoft key at '${file}'."
    "$curl" -fsSL "$url" \
        | "$gpg" --dearmor \
        | sudo "$tee" "$file" \
        >/dev/null 2>&1 \
        || true
    return 0
}

koopa::debian_apt_add_r_key() { # {{{1
    # """
    # Add the R key.
    # @note Updated 2021-06-11.
    #
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://cran.r-project.org/bin/linux/ubuntu/
    # """
    local key keys keyserver
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'apt-key'
    if koopa::is_ubuntu
    then
        # Release is signed by Michael Rutter <marutter@gmail.com>.
        keys=(
            'E298A3A825C0D65DFD57CBB651716619E084DAB9'
        )
        keyserver='keyserver.ubuntu.com'
    else
        # Release is signed by Johannes Ranke <jranke@uni-bremen.de>.
        keys=(
            'E19F5F87128899B192B1A2C2AD5F960A256A04AF'
            'FCAE2A0E115C3D8A'  # required as of 2020-09
        )
        # > keyserver='keys.gnupg.net'
        keyserver='keyserver.ubuntu.com'
    fi
    for key in "${keys[@]}"
    do
        koopa::debian_apt_is_key_imported "$key" && continue
        koopa::alert "Adding R key '${key}'."
        sudo apt-key adv \
            --keyserver "$keyserver" \
            --recv-key "$key" \
            >/dev/null 2>&1 \
            || true
    done
    return 0
}

koopa::debian_apt_add_r_repo() { # {{{1
    # """
    # Add R apt repo.
    # @note Updated 2021-06-11.
    # """
    local file name name_fancy os_codename os_id repo string version
    koopa::assert_has_args_le "$#" 1
    version="${1:-}"
    name='r'
    name_fancy='R'
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    version="$(koopa::major_minor_version "$version")"
    case "$version" in
        4.1)
            version='4.0'
            ;;
        3.6)
            version='3.5'
            ;;
    esac
    # Need to strip the periods here.
    version="$(koopa::gsub '\.' '' "$version")"
    version="cran${version}"
    file="/etc/apt/sources.list.d/${name}.list"
    if [[ -f "$file" ]]
    then
        # Early return if version matches and Debian source is enabled.
        if koopa::file_match "$file" "$version" && \
            koopa::file_match "$file" 'deb-src'
        then
            koopa::alert_info "${name_fancy} repo exists at '${file}'."
            return 0
        else
            koopa::rm -S "$file"
        fi
    fi
    koopa::alert "Adding ${name_fancy} repo at '${file}'."
    koopa::debian_apt_add_r_key
    os_id="$(koopa::os_id)"
    os_codename="$(koopa::os_codename)"
    repo="https://cloud.r-project.org/bin/linux/${os_id} \
${os_codename}-${version}/"
    # Note that 'read' will return status 1 here.
    # https://unix.stackexchange.com/questions/80045/
    read -r -d '' string << END || true
deb ${repo}
deb-src ${repo}
END
    koopa::sudo_write_string "$string" "$file"
    return 0
}

koopa::debian_apt_add_wine_key() { # {{{1
    # """
    # Add the WineHQ key.
    # @note Updated 2021-06-11.
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
    local key name_fancy url
    koopa::assert_has_no_args "$#"
    name_fancy='Wine'
    url='https://dl.winehq.org/wine-builds/winehq.key'
    key='D43F640145369C51D786DDEA76F1A20FF987672F'
    koopa:::debian_apt_key_add "$name_fancy" "$url" "$key"
    return 0
}

koopa::debian_apt_add_wine_repo() { # {{{1
    # """
    # Add WineHQ repo.
    # @note Updated 2021-06-11.
    #
    # - Debian:
    #   https://wiki.winehq.org/Debian
    # - Ubuntu:
    #   https://wiki.winehq.org/Ubuntu
    # """
    local file os_codename os_id string url
    koopa::assert_has_no_args "$#"
    name='wine'
    name_fancy='Wine'
    file="/etc/apt/sources.list.d/${name}.list"
    if [[ -f "$file" ]]
    then
        koopa::alert_info "${name_fancy} repo exists at '${file}'."
        return 0
    fi
    koopa::alert "Adding ${name_fancy} repo at '${file}'."
    koopa::debian_apt_add_wine_key
    os_id="$(koopa::os_id)"
    os_codename="$(koopa::os_codename)"
    url="https://dl.winehq.org/wine-builds/${os_id}/"
    string="deb ${url} ${os_codename} main"
    koopa::sudo_write_string "$string" "$file"
    return 0
}

koopa::debian_apt_add_wine_obs_key() { # {{{1
    # """
    # Add the Wine OBS openSUSE key.
    # @note Updated 2021-06-11.
    # """
    local key name_fancy os_string subdir url
    koopa::assert_has_no_args "$#"
    name_fancy='Wine OBS'
    os_string="$(koopa::os_string)"
    # Signed by <Emulators@build.opensuse.org>.
    key='31CFB0B65659B5D40DEEC98DDFA175A75104960E'
    case "$os_string" in
        debian-10)
            subdir='Debian_10'
            ;;
        ubuntu-18)
            url='xUbuntu_18.04'
            ;;
        ubuntu-20)
            url='xUbuntu_20.04'
            ;;
        *)
            koopa::stop "Unsupported OS: '${os_string}'."
            ;;
    esac
    url="https://download.opensuse.org/repositories/\
Emulators:/Wine:/Debian/${subdir}/Release.key"
    koopa:::debian_apt_key_add "$name_fancy" "$url" "$key"
    return 0
}

koopa::debian_apt_add_wine_obs_repo() { # {{{1
    # """
    # Add Wine OBS openSUSE repo.
    # @note Updated 2021-06-11.
    #
    # Required to install libfaudio0 dependency for Wine on Debian 10+.
    #
    # @seealso
    # - https://wiki.winehq.org/Debian
    # - https://forum.winehq.org/viewtopic.php?f=8&t=32192
    # """
    local base_url file name name_fancy os_string repo_url string
    koopa::assert_has_no_args "$#"
    name='wine-obs'
    name_fancy='Wine OBS'
    file="/etc/apt/sources.list.d/${name}.list"
    if [[ -f "$file" ]]
    then
        koopa::alert_info "${name_fancy} repo exists at '${file}'."
        return 0
    fi
    koopa::alert "Adding ${name_fancy} repo at '${file}'."
    koopa::debian_apt_add_wine_obs_key
    base_url="https://download.opensuse.org/repositories/\
Emulators:/Wine:/Debian"
    os_string="$(koopa::os_string)"
    case "$os_string" in
        debian-10)
            repo_url="${base_url}/Debian_10/"
            ;;
        ubuntu-18)
            repo_url="${base_url}/xUbuntu_18.04/"
            ;;
        *)
            koopa::stop "Unsupported OS: '${os_string}'."
            ;;
    esac
    string="deb ${repo_url} ./"
    koopa::sudo_write_string "$string" "$file"
    return 0
}

koopa::debian_apt_clean() { # {{{1
    # """
    # Clean up apt after an install/uninstall call.
    # @note Updated 2021-06-11.
    #
    # Alternatively, can consider using 'autoclean' here, which is lighter
    # than calling 'clean'.

    # - 'clean': Cleans the packages and install script in
    #       '/var/cache/apt/archives/'.
    # - 'autoclean': Cleans obsolete deb-packages, less than 'clean'.
    # - 'autoremove': Removes orphaned packages which are not longer needed from
    #       the system, but not purges them, use the '--purge' option together
    #       with the command for that.
    #
    # @seealso
    # - https://askubuntu.com/questions/984797/
    # - https://askubuntu.com/questions/3167/
    # - https://github.com/hadolint/hadolint/wiki/DL3009
    # """
    sudo apt-get --yes autoremove
    sudo apt-get --yes clean
    # > koopa::rm -S '/var/lib/apt/lists/'*
    return 0
}

koopa::debian_apt_configure_sources() { # {{{1
    # """
    # Configure apt sources.
    # @note Updated 2021-06-11.
    #
    # Debian Docker images can also use snapshots:
    # http://snapshot.debian.org/archive/debian/20210326T030000Z
    # """
    local arch codenames os_codename os_id repos sources_list tee
    local sources_list_d urls
    koopa::assert_has_no_args "$#"
    tee="$(koopa::locate_tee)"
    sources_list='/etc/apt/sources.list'
    koopa::alert "Configuring apt sources in '${sources_list}'."
    if [[ -L "$sources_list" ]]
    then
        koopa::rm -S "$sources_list"
    fi
    sources_list_d='/etc/apt/sources.list.d'
    if [[ -L "$sources_list_d" ]]
    then
        koopa::rm -S "$sources_list_d"
    fi
    if [[ ! -d "$sources_list_d" ]]
    then
        koopa::mkdir -S "$sources_list_d"
    fi
    os_id="$(koopa::os_id)"
    os_codename="$(koopa::os_codename)"
    arch="$(koopa::arch)"
    declare -A codenames
    declare -A urls
    case "$os_id" in
        debian)
            repos=('main')
            codenames[main]="$os_codename"
            codenames[security]="${os_codename}/updates"
            codenames[updates]="${os_codename}-updates"
            urls[main]='http://deb.debian.org/debian/'
            urls[security]='http://security.debian.org/debian-security/'
            urls[updates]='http://deb.debian.org/debian/'
            ;;
        ubuntu)
            # Can consider including 'multiverse' here as well.
            repos=('main' 'restricted' 'universe')
            codenames[main]="${os_codename}"
            codenames[security]="${os_codename}-security"
            codenames[updates]="${os_codename}-updates"
            case "$arch" in
                aarch64)
                    # ARM (e.g. Raspberry Pi).
                    urls[main]='http://ports.ubuntu.com/ubuntu-ports/'
                    urls[security]='http://ports.ubuntu.com/ubuntu-ports/'
                    urls[updates]='http://ports.ubuntu.com/ubuntu-ports/'
                    ;;
                *)
                    urls[main]='http://archive.ubuntu.com/ubuntu/'
                    urls[security]='http://security.ubuntu.com/ubuntu/'
                    urls[updates]='http://archive.ubuntu.com/ubuntu/'
                    ;;
            esac
            ;;
        *)
            koopa::stop "Unsupported OS: '${os_id}'."
            ;;
    esac
    sudo "$tee" "$sources_list" >/dev/null << END
deb ${urls[main]} ${codenames[main]} ${repos[*]}
deb ${urls[security]} ${codenames[security]} ${repos[*]}
deb ${urls[updates]} ${codenames[updates]} ${repos[*]}
END
    return 0
}

koopa::debian_apt_delete_repo() { # {{{1
    # """
    # Delete an apt repo file.
    # @note Updated 2021-06-16.
    # """
    local file name
    koopa::assert_has_args "$#"
    for name in "$@"
    do
        file="/etc/apt/sources.list.d/${name}.list"
        koopa::assert_is_file "$file"
        koopa::rm -S "$file"
    done
    return 0
}

koopa::debian_apt_disable_deb_src() { # {{{1
    # """
    # Enable 'deb-src' source packages.
    # @note Updated 2021-06-11.
    # """
    local file grep sed
    koopa::assert_has_args_le "$#" 1
    file="${1:-}"
    [[ -z "$file" ]] && file='/etc/apt/sources.list'
    file="$(koopa::realpath "$file")"
    koopa::alert "Disabling Debian sources in '${file}'."
    grep="$(koopa::locate_grep)"
    sed="$(koopa::locate_sed)"
    if ! "$grep" -Eq '^deb-src ' "$file"
    then
        koopa::alert_note "No 'deb-src' lines to comment in '${file}'."
        return 0
    fi
    "$sed" -Ei 's/^deb-src /# deb-src /' "$file"
    sudo apt-get update
    return 0
}

koopa::debian_apt_enable_deb_src() { # {{{1
    # """
    # Enable 'deb-src' source packages.
    # @note Updated 2021-06-11.
    # """
    local file grep sed
    koopa::assert_has_args_le "$#" 1
    grep="$(koopa::locate_grep)"
    sed="$(koopa::locate_sed)"
    file="${1:-}"
    [[ -z "$file" ]] && file='/etc/apt/sources.list'
    file="$(koopa::realpath "$file")"
    koopa::alert "Enabling Debian sources in '${file}'."
    if ! "$grep" -Eq '^# deb-src ' "$file"
    then
        koopa::alert_note "No '# deb-src' lines to uncomment in '${file}'."
        return 0
    fi
    sudo "$sed" -Ei 's/^# deb-src /deb-src /' "$file"
    sudo apt-get update
    return 0
}

koopa::debian_apt_enabled_repos() { # {{{1
    # """
    # Get a list of enabled default apt repos.
    # @note Updated 2021-06-11.
    # """
    local cut file grep os_codename pattern x
    koopa::assert_has_no_args "$#"
    cut="$(koopa::locate_cut)"
    grep="$(koopa::locate_grep)"
    os_codename="$(koopa::os_codename)"
    file='/etc/apt/sources.list'
    pattern="^deb\s.+\s${os_codename}\s.+$"
    x="$( \
        "$grep" -E "$pattern" "$file" \
            | "$cut" -d ' ' -f '4-' \
    )"
    koopa::print "$x"
}

koopa::debian_apt_get() { # {{{1
    # """
    # Non-interactive variant of apt-get, with saner defaults.
    # @note Updated 2020-07-05.
    #
    # Currently intended for:
    # - dist-upgrade
    # - install
    # """
    koopa::assert_has_args "$#"
    sudo apt-get update
    sudo DEBIAN_FRONTEND='noninteractive' \
        apt-get \
            --no-install-recommends \
            --quiet \
            --yes \
            "$@"
    return 0
}

koopa::debian_apt_install() { # {{{1
    # """
    # Install Debian apt package.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    koopa::debian_apt_get install "$@"
}

koopa::debian_apt_is_key_imported() { # {{{1
    # """
    # Is a GPG key imported for apt?
    # @note Updated 2020-06-30.
    # """
    local key sed x
    koopa::assert_has_args_eq "$#" 1
    sed="$(koopa::locate_sed)"
    koopa::assert_is_installed 'apt-key'
    key="${1:?}"
    key="$( \
        koopa::print "$key" \
        | "$sed" 's/ //g' \
        | "$sed" -E "s/\
^(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})\$/\
\1 \2 \3 \4 \5  \6 \7 \8 \9 \10/" \
    )"
    x="$(apt-key list 2>&1 || true)"
    koopa::str_match "$x" "$key"
}

koopa::debian_apt_remove() { # {{{1
    # """
    # Remove Debian apt package.
    # @note Updated 2021-03-24.
    # """
    koopa::assert_has_args "$#"
    sudo apt-get --yes remove --purge "$@"
    koopa::debian_apt_clean
    return 0
}

koopa::debian_apt_space_used_by() { # {{{1
    # """
    # Check installed apt package size, with dependencies.
    # @note Updated 2020-06-30.
    #
    # Alternate approach that doesn't attempt to grep match.
    # """
    koopa::assert_has_args "$#"
    sudo apt-get --assume-no autoremove "$@"
    return 0
}

koopa::debian_apt_space_used_by_grep() { # {{{1
    # """
    # Check installed apt package size, with dependencies.
    # @note Updated 2021-06-11.
    #
    # See also:
    # https://askubuntu.com/questions/490945
    # """
    local cut grep x
    koopa::assert_has_args "$#"
    cut="$(koopa::locate_cut)"
    grep="$(koopa::locate_grep)"
    x="$( \
        sudo apt-get --assume-no autoremove "$@" \
            | "$grep" 'freed' \
            | "$cut" -d ' ' -f '4-5' \
    )"
    koopa::print "$x"
    return 0
}

koopa::debian_apt_space_used_by_no_deps() { # {{{1
    # """
    # Check install apt package size, without dependencies.
    # @note Updated 2021-06-11.
    # """
    local grep
    grep="$(koopa::locate_grep)"
    koopa::assert_has_args "$#"
    sudo apt show "$@" | "$grep" 'Size'
    return 0
}
