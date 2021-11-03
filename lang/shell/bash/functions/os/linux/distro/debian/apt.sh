#!/usr/bin/env bash

# FIXME Create a standardized Debian repository list file generator
# https://wiki.debian.org/DebianRepository/Format

# FIXME Consider improving the consistency of repo configuration by defining
# a new shared function, similar to our key approach.

# FIXME koopa install llvm shouldn't warn about llvm-config...

koopa:::debian_apt_key_add() {  #{{{1
    # """
    # Add an apt key.
    # @note Updated 2021-11-03.
    #
    # @section Hardening against insecure URL failure:
    # 
    # Using '--insecure' flag here to handle some servers
    # (e.g. download.opensuse.org) that can fail otherwise.
    #
    # @section Regarding apt-key deprecation:
    #
    # Although adding keys directly to '/etc/apt/trusted.gpg.d/' is suggested by
    # 'apt-key' deprecation message, as per Debian Wiki, GPG keys for third
    # party repositories should be added to '/usr/share/keyrings', and
    # referenced with the 'signed-by' option in the '/etc/apt/sources.list.d'
    # entry.
    #
    # @section Alternative approach using tee:
    #
    # > koopa::parse_url --insecure "${dict[url]}" \
    # >     | "${app[gpg]}" --dearmor \
    # >     | "${app[sudo]}" "${app[tee]}" "${dict[file]}" \
    # >         >/dev/null 2>&1 \
    # >     || true
    #
    # @seealso
    # - https://github.com/docker/docker.github.io/issues/11625
    # - https://github.com/docker/docker.github.io/issues/
    #     11625#issuecomment-751388087
    # """
    local app dict
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [gpg]="$(koopa::locate_gpg)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [name]=''
        [name_fancy]=''
        [prefix]='/usr/share/keyrings'
        [url]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name')
                dict[name]="${2:?}"
                shift 2
                ;;
            '--name-fancy='*)
                dict[name_fancy]="${1#*=}"
                shift 1
                ;;
            '--name-fancy')
                dict[name_fancy]="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict[url]="${1#*=}"
                shift 1
                ;;
            '--url')
                dict[url]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_dir "${dict[prefix]}"
    dict[file]="${dict[prefix]}/koopa-${dict[name]}.gpg"
    [[ -f "${dict[file]}" ]] && return 0
    koopa::alert "Adding ${dict[name_fancy]} key at '${dict[file]}'."
    koopa::parse_url --insecure "${dict[url]}" \
        | "${app[sudo]}" "${app[gpg]}" \
            --dearmor \
            --output "${dict[file]}" \
            >/dev/null 2>&1 \
        || true
    koopa::assert_is_file "${dict[file]}"
    return 0
}

# FIXME Check that this is safe to remove following repo config updates.
koopa:::debian_apt_key_add_legacy() {  #{{{1
    # """
    # Add a legacy apt key (deprecated).
    # @note Updated 2021-11-02.
    #
    # For use with apt repos that don't yet support 'signed-by' approach.
    # """
    koopa::assert_has_args "$#"
    koopa:::debian_apt_key_add \
        --prefix='/etc/apt/trusted.gpg.d' \
        "$@"
    return 0
}

# FIXME Need to standardize with Debian repo list file generator function.
koopa::debian_apt_add_azure_cli_repo() { # {{{1
    # """
    # Add Microsoft Azure CLI apt repo.
    # @note Updated 2021-11-03.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A dict=(
        [arch]="$(koopa::arch2)"  # e.g. 'amd64'.
        [key_name]='microsoft'
        [key_prefix]="$(koopa::debian_apt_key_prefix)"
        [name]='azure-cli'
        [name_fancy]='Microsoft Azure CLI'
        [os]="$(koopa::os_codename)"
        [prefix]="$(koopa::debian_apt_sources_prefix)"
    )
    dict[file]="${dict[prefix]}/koopa-${dict[name]}.list"
    dict[url]="https://packages.microsoft.com/repos/${dict[name]}/"
    dict[signed_by]="${dict[key_prefix]}/koopa-${dict[key_name]}.gpg"
    dict[string]="deb [arch=${dict[arch]} signed-by=${dict[signed_by]}] \
${dict[url]} ${dict[os]} main"
    if [[ -f "${dict[file]}" ]]
    then
        koopa::alert_info "${dict[name_fancy]} repo exists at '${dict[file]}'."
        return 0
    fi
    koopa::debian_apt_add_microsoft_key
    koopa::alert "Adding ${dict[name_fancy]} repo at '${dict[file]}'."
    koopa::sudo_write_string "${dict[string]}" "${dict[file]}"
    return 0
}

koopa::debian_apt_add_docker_key() { # {{{1
    # """
    # Add the Docker key.
    # @note Updated 2021-11-03.
    #
    # @seealso
    # - https://docs.docker.com/engine/install/debian/
    # - https://docs.docker.com/engine/install/ubuntu/
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [gpg]="$(koopa::locate_gpg)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [name]='docker'
        [name_fancy]='Docker'
        [os_id]="$(koopa::os_id)"
    )
    dict[url]="https://download.docker.com/linux/${dict[os_id]}/gpg"
    koopa:::debian_apt_key_add \
        --name-fancy="${dict[name_fancy]}" \
        --name="${dict[name]}" \
        --url="${dict[url]}"
    return 0
}

# FIXME Need to standardize with Debian repo list file generator function.
koopa::debian_apt_add_docker_repo() { # {{{1
    # """
    # Add Docker apt repo.
    # @note Updated 2021-11-03.
    #
    # @seealso
    # - https://docs.docker.com/engine/install/debian/
    # - https://docs.docker.com/engine/install/ubuntu/
    # """
    local dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A dict=(
        [arch]="$(koopa::arch2)"  # e.g. 'amd64'.
        [key_name]='docker'
        [key_prefix]="$(koopa::debian_apt_key_prefix)"
        [name]='docker'
        [name_fancy]='Docker'
        [os_codename]="$(koopa::os_codename)"
        [os_id]="$(koopa::os_id)"
        [repo_prefix]="$(koopa::debian_apt_sources_prefix)"
    )
    dict[file]="${dict[repo_prefix]}/${dict[name]}.list"
    dict[url]="https://download.docker.com/linux/${dict[os_id]}"
    dict[signed_by]="${dict[key_prefix]}/koopa-${dict[key_name]}.gpg"
    dict[string]="deb [arch=${dict[arch]} signed-by=${dict[signed_by]}] \
${dict[url]} ${dict[os_codename]} stable"
    if [[ -f "${dict[file]}" ]]
    then
        koopa::alert_info "${dict[name_fancy]} repo exists at '${dict[file]}'."
        return 0
    fi
    koopa::debian_apt_add_docker_key
    koopa::alert "Adding ${dict[name_fancy]} repo at '${dict[file]}'."
    koopa::sudo_write_string "${dict[string]}" "${dict[file]}"
    return 0
}

koopa::debian_apt_add_google_cloud_key() { # {{{1
    # """
    # Add the Google Cloud key.
    # @note Updated 2021-11-03.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install#deb
    # - https://github.com/docker/docker.github.io/issues/11625
    # """
    koopa::assert_has_no_args "$#"
    koopa:::debian_apt_key_add \
        --name-fancy='Google Cloud' \
        --name='google-cloud' \
        --url='https://packages.cloud.google.com/apt/doc/apt-key.gpg'
    return 0
}

# FIXME Need to standardize with Debian repo list file generator function.
koopa::debian_apt_add_google_cloud_sdk_repo() { # {{{1
    # """
    # Add Google Cloud SDK apt repo.
    # @note Updated 2021-11-03.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A dict=(
        [arch]="$(koopa::arch2)"
        [channel]='cloud-sdk'
        [key_name]='google-cloud'
        [key_prefix]="$(koopa::debian_apt_key_prefix)"
        [name]='google-cloud-sdk'
        [name_fancy]='Google Cloud SDK'
        [repo_prefix]="$(koopa::debian_apt_sources_prefix)"
        [url]='https://packages.cloud.google.com/apt'
    )
    dict[file]="${dict[repo_prefix]}/koopa-${dict[name]}.list"
    dict[signed_by]="${dict[key_prefix]}/koopa-${dict[key_name]}.gpg"
    dict[string]="deb [arch=${dict[arch]} signed-by=${dict[signed_by]}] \
${dict[url]} ${dict[channel]} main"
    if [[ -f "${dict[file]}" ]]
    then
        koopa::alert_info "${dict[name_fancy]} repo exists at '${dict[file]}'."
        return 0
    fi
    koopa::debian_apt_add_google_cloud_key
    koopa::alert "Adding ${dict[name_fancy]} repo at '${dict[file]}'."
    koopa::sudo_write_string "${dict[string]}" "${dict[file]}"
    return 0
}

koopa::debian_apt_add_llvm_key() { # {{{1
    # """
    # Add the LLVM key.
    # @note Updated 2021-11-03.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::debian_apt_key_add \
        --basename='llvm.gpg' \
        --name-fancy='LLVM' \
        --url='https://apt.llvm.org/llvm-snapshot.gpg.key'
    return 0
}

# FIXME Need to standardize with Debian repo list file generator function.
koopa::debian_apt_add_llvm_repo() { # {{{1
    # """
    # Add LLVM apt repo.
    # @note Updated 2021-11-03.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [arch]="$(koopa::arch2)"
        [key_name]='llvm'
        [name]='llvm'
        [name_fancy]='LLVM'
        [os]="$(koopa::os_codename)"
        [repo_prefix]="$(koopa::debian_apt_sources_prefix)"
    )
    dict[file]="${dict[repo_prefix]}/koopa-${dict[name]}.list"
    dict[url]="http://apt.llvm.org/${dict[os]}/"
    dict[signed_by]="${dict[key_prefix]}/koopa-${dict[key_name]}.gpg"
    dict[version]="$(koopa::major_version "$(koopa::variable "${dict[name]}")")"
    dict[channel]="llvm-toolchain-${dict[os]}-${dict[version]}"
    dict[string]="deb [arch=${dict[arch]} signed-by=${dict[signed_by]}] \
${dict[url]} ${dict[channel]} main"
    if [[ -f "${dict[file]}" ]]
    then
        koopa::alert_info "${dict[name_fancy]} repo exists at '${dict[file]}'."
        return 0
    fi
    koopa::debian_apt_add_llvm_key
    koopa::alert "Adding ${dict[name_fancy]} repo at '${dict[file]}'."
    koopa::sudo_write_string "${dict[string]}" "${dict[file]}"
    return 0
}

koopa::debian_apt_add_microsoft_key() {  #{{{1
    # """
    # Add the Microsoft GPG key (for Azure CLI).
    # @note Updated 2021-11-03.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::debian_apt_key_add \
        --name-fancy='Microsoft' \
        --name='microsoft' \
        --url='https://packages.microsoft.com/keys/microsoft.asc'
    return 0
}

# FIXME Rework using koopa::gpg_download_key_from_keyserver approach.
# FIXME May not need to use the array approach here now.
koopa::debian_apt_add_r_key() { # {{{1
    # """
    # Add the R key.
    # @note Updated 2021-11-03.
    #
    # Addition of signing key via keyserver directly into /etc/apt/trusted.gpg'
    # file is deprecated in Debian, but currently the only supported method for
    # installation of R CRAN binaries. Consider reworking this approach for
    # future R releases, if possible.
    #
    # @section Previous archive key:
    #
    # Additional archive key (required as of 2020-09): 'FCAE2A0E115C3D8A'
    #
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://cran.r-project.org/bin/linux/ubuntu/
    # """
    local app key keys keyserver
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_key]="$(koopa::debian_locate_apt_key)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        # Alternatively, may be able to use 'keys.gnupg.net'.
        [keyserver]='keyserver.ubuntu.com'
    )
    if koopa::is_ubuntu
    then
        # Release is signed by Michael Rutter <marutter@gmail.com>.
        dict[key]='E298A3A825C0D65DFD57CBB651716619E084DAB9'
    else
        # Release is signed by Johannes Ranke <jranke@uni-bremen.de>.
        dict[key]='E19F5F87128899B192B1A2C2AD5F960A256A04AF'
    fi
    # FIXME Rework this without loop approach, once we get
    # koopa::gpg_download_key_from_keyserver working.
    for key in "${keys[@]}"
    do
        koopa::debian_apt_is_key_imported "$key" && continue
        koopa::alert "Adding R key '${key}'."
        "${app[sudo]}" "${app[apt_key]}" adv \
            --keyserver "$keyserver" \
            --recv-key "$key" \
            >/dev/null 2>&1 \
            || true
    done
    return 0
}

# FIXME Don't include signed-by for this repo...
# FIXME Need to convert to using a dict approach here.
# FIXME Need to harden this.
# FIXME Need to standardize with Debian repo list file generator function.
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
        '4.1')
            version='4.0'
            ;;
        '3.6')
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
        if koopa::file_match_fixed "$file" "$version" && \
            koopa::file_match_fixed "$file" 'deb-src'
        then
            koopa::alert_info "${name_fancy} repo exists at '${file}'."
            return 0
        else
            koopa::rm --sudo "$file"
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
    # @note Updated 2021-11-03.
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
    koopa::assert_has_no_args "$#"
    koopa:::debian_apt_key_add \
        --name-fancy='Wine' \
        --name='wine' \
        --url='https://dl.winehq.org/wine-builds/winehq.key'
    return 0
}

# FIXME Rework using dict approach.
# FIXME Need to harden this.
# FIXME Need to standardize with Debian repo list file generator function.
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
    # FIXME Rework using prefix variable.
    file="/etc/apt/sources.list.d/koopa-${name}.list"
    if [[ -f "$file" ]]
    then
        koopa::alert_info "${name_fancy} repo exists at '${file}'."
        return 0
    fi
    koopa::debian_apt_add_wine_key
    os_id="$(koopa::os_id)"
    os_codename="$(koopa::os_codename)"
    url="https://dl.winehq.org/wine-builds/${os_id}/"
    # FIXME Need to include arch and signed-by.
    string="deb ${url} ${os_codename} main"
    koopa::alert "Adding ${name_fancy} repo at '${file}'."
    koopa::sudo_write_string "$string" "$file"
    return 0
}

# FIXME Need to harden this.
koopa::debian_apt_add_wine_obs_key() { # {{{1
    # """
    # Add the Wine OBS openSUSE key.
    # @note Updated 2021-11-02.
    # """
    local key name_fancy os_string subdir url
    koopa::assert_has_no_args "$#"
    name_fancy='Wine OBS'
    os_string="$(koopa::os_string)"
    # Signed by <Emulators@build.opensuse.org>.
    key='31CFB0B65659B5D40DEEC98DDFA175A75104960E'
    case "$os_string" in
        'debian-10')
            subdir='Debian_10'
            ;;
        'ubuntu-18')
            url='xUbuntu_18.04'
            ;;
        'ubuntu-20')
            url='xUbuntu_20.04'
            ;;
        *)
            koopa::stop "Unsupported OS: '${os_string}'."
            ;;
    esac
    url="https://download.opensuse.org/repositories/\
Emulators:/Wine:/Debian/${subdir}/Release.key"
    koopa:::debian_apt_key_add_legacy \
        "$name_fancy" \
        "$url" \
        "$key"
    return 0
}

# FIXME Need to harden this.
# FIXME Need to standardize with Debian repo list file generator function.
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
        'debian-10')
            repo_url="${base_url}/Debian_10/"
            ;;
        'ubuntu-18')
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
    # @note Updated 2021-11-02.
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
    local app
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --yes autoremove
    "${app[sudo]}" "${app[apt_get]}" --yes clean
    # > koopa::rm --sudo '/var/lib/apt/lists/'*
    return 0
}

koopa::debian_apt_configure_sources() { # {{{1
    # """
    # Configure apt sources.
    # @note Updated 2021-11-02.
    #
    # Look up currently enabled sources with:
    # > grep -Eq '^deb\s' '/etc/apt/sources.list'
    #
    # Debian Docker images can also use snapshots:
    # http://snapshot.debian.org/archive/debian/20210326T030000Z
    #
    # @section AWS AMI instances:
    #
    # Debian 11 x86 defaults:
    # > deb http://cdn-aws.deb.debian.org/debian
    #       bullseye main
    # > deb http://security.debian.org/debian-security
    #       bullseye-security main
    # > deb http://cdn-aws.deb.debian.org/debian
    #       bullseye-updates main
    # > deb http://cdn-aws.deb.debian.org/debian
    #       bullseye-backports main
    #
    # Debian 11 ARM defaults:
    # deb http://cdn-aws.deb.debian.org/debian
    #     bullseye main
    # deb http://security.debian.org/debian-security
    #     bullseye-security main
    # deb http://cdn-aws.deb.debian.org/debian
    #     bullseye-updates main
    # deb http://cdn-aws.deb.debian.org/debian
    #     bullseye-backports main
    #
    # Ubuntu 20 LTS x86 defaults:
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal main restricted
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal-updates main restricted
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal universe
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal-updates universe
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal multiverse
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal-updates multiverse
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal-backports main restricted universe multiverse
    # > deb http://security.ubuntu.com/ubuntu
    #       focal-security main restricted
    # > deb http://security.ubuntu.com/ubuntu
    #       focal-security universe
    # > deb http://security.ubuntu.com/ubuntu
    #       focal-security multiverse
    #
    # Ubuntu ARM defaults:
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal main restricted
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal-updates main restricted
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal universe
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal-updates universe
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal multiverse
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal-updates multiverse
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal-backports main restricted universe multiverse
    # > deb http://ports.ubuntu.com/ubuntu-ports
    #       focal-security main restricted
    # > deb http://ports.ubuntu.com/ubuntu-ports
    #       focal-security universe
    # > deb http://ports.ubuntu.com/ubuntu-ports
    #       focal-security multiverse
    # """
    local app codenames repos urls
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [head]="$(koopa::locate_head)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [os_codename]="$(koopa::os_codename)"
        [os_id]="$(koopa::os_id)"
        [sources_list]='/etc/apt/sources.list'
        [sources_list_d]="$(koopa::debian_apt_sources_prefix)"
    )
    koopa::alert "Configuring apt sources in '${dict[sources_list]}'."
    koopa::assert_is_file "${dict[sources_list]}"
    declare -A codenames=(
        [main]="${dict[os_codename]}"
        [security]="${dict[os_codename]}-security"
        [updates]="${dict[os_codename]}-updates"
    )
    declare -A urls=(
        [main]="$( \
            koopa::grep \
                --extended-regexp \
                '^deb\s' \
                "${dict[sources_list]}" \
            | koopa::grep \
                --fixed-strings \
                " ${codenames[main]} main" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f 2 \
        )"
        [security]="$( \
            koopa::grep \
                --extended-regexp \
                    '^deb\s' \
                    "${dict[sources_list]}" \
            | koopa::grep \
                --fixed-strings \
                " ${codenames[security]} main" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f 2 \
        )"
    )
    if [[ -z "${urls[main]}" ]]
    then
        koopa::stop 'Failed to extract apt main URL.'
    fi
    if [[ -z "${urls[security]}" ]]
    then
        koopa::stop 'Failed to extract apt security URL.'
    fi
    urls[updates]="${urls[main]}"
    case "${dict[os_id]}" in
        'debian')
            # Can consider including 'backports' here.
            repos=('main')
            ;;
        'ubuntu')
            # Can consider including 'multiverse' here.
            repos=('main' 'restricted' 'universe')
            ;;
        *)
            koopa::stop "Unsupported OS: '${dict[os_id]}'."
            ;;
    esac
    # Configure primary apt sources.
    if [[ -L "${dict[sources_list]}" ]]
    then
        koopa::rm --sudo "${dict[sources_list]}"
    fi
    sudo "${app[tee]}" "${dict[sources_list]}" >/dev/null << END
deb ${urls[main]} ${codenames[main]} ${repos[*]}
deb ${urls[security]} ${codenames[security]} ${repos[*]}
deb ${urls[updates]} ${codenames[updates]} ${repos[*]}
END
    # Configure secondary apt sources.
    if [[ -L "${dict[sources_list_d]}" ]]
    then
        koopa::rm --sudo "${dict[sources_list_d]}"
    fi
    if [[ ! -d "${dict[sources_list_d]}" ]]
    then
        koopa::mkdir --sudo "${dict[sources_list_d]}"
    fi
    return 0
}

# FIXME Use prefix variable here.
koopa::debian_apt_delete_repo() { # {{{1
    # """
    # Delete an apt repo file.
    # @note Updated 2021-11-02.
    # """
    local file name
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    for name in "$@"
    do
        file="/etc/apt/sources.list.d/koopa-${name}.list"
        koopa::assert_is_file "$file"
        koopa::rm --sudo "$file"
    done
    return 0
}

# FIXME Rework using apt_sources_file variable.
koopa::debian_apt_disable_deb_src() { # {{{1
    # """
    # Disable 'deb-src' source packages.
    # @note Updated 2021-11-02.
    # """
    local app dict
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sed]="$(koopa::locate_sed)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [file]="${1:-}"
    )
    [[ -z "${dict[file]}" ]] && dict[file]='/etc/apt/sources.list'
    koopa::assert_is_file "${dict[file]}"
    koopa::alert "Disabling Debian sources in '${dict[file]}'."
    if ! koopa::file_match_regex "${dict[file]}" '^deb-src '
    then
        koopa::alert_note "No lines to comment in '${dict[file]}'."
        return 0
    fi
    "${app[sudo]}" "${app[sed]}" -Ei 's/^deb-src /# deb-src /' "${dict[file]}"
    "${app[sudo]}" "${app[apt_get]}" update
    return 0
}

# FIXME Rework using apt_sources_file variable.
koopa::debian_apt_enable_deb_src() { # {{{1
    # """
    # Enable 'deb-src' source packages.
    # @note Updated 2021-11-02.
    # """
    local app dict
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sed]="$(koopa::locate_sed)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [file]="${1:-}"
    )
    [[ -z "${dict[file]}" ]] && dict[file]='/etc/apt/sources.list'
    koopa::assert_is_file "${dict[file]}"
    koopa::alert "Enabling Debian sources in '${dict[file]}'."
    if ! koopa::file_match_regex "${dict[file]}" '^# deb-src '
    then
        koopa::alert_note "No lines to uncomment in '${dict[file]}'."
        return 0
    fi
    "${app[sudo]}" "${app[sed]}" -Ei 's/^# deb-src /deb-src /' "${dict[file]}"
    "${app[sudo]}" "${app[apt_get]}" update
    return 0
}

# FIXME Rework using apt_sources_file variable.
koopa::debian_apt_enabled_repos() { # {{{1
    # """
    # Get a list of enabled default apt repos.
    # @note Updated 2021-11-02.
    # """
    local app file os_codename pattern x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
    )
    declare -A dict=(
        [file]='/etc/apt/sources.list'
        [os]="$(koopa::os_codename)"
    )
    dict[pattern]="^deb\s.+\s${dict[os]}\s.+$"
    x="$( \
        koopa::grep \
            --extended-regexp \
            "${dict[pattern]}" \
            "${dict[file]}" \
        | "${app[cut]}" -d ' ' -f '4-' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
}

koopa::debian_apt_get() { # {{{1
    # """
    # Non-interactive variant of apt-get, with saner defaults.
    # @note Updated 2021-11-02.
    #
    # Currently intended for:
    # - dist-upgrade
    # - install
    # """
    local app
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" update
    "${app[sudo]}" DEBIAN_FRONTEND='noninteractive' \
        "${app[apt_get]}" \
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
    # @note Updated 2021-11-02.
    #
    # sed only supports up to 9 elements in replacement, even though our
    # input contains 10. Need to switch to awk or another approach to make
    # this matching even more exact.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [apt_key]="$(koopa::debian_locate_apt_key)"
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [key]="${1:?}"
    )
    dict[key_pattern]="$( \
        koopa::print "${dict[key]}" \
        | "${app[sed]}" 's/ //g' \
        | "${app[sed]}" -E "s/^(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})\
(.{4})(.{4})(.{4})\$/\1 \2 \3 \4 \5  \6 \7 \8 \9/" \
    )"
    dict[string]="$("${app[apt_key]}" list 2>&1 || true)"
    koopa::str_match_fixed "${dict[string]}" "${dict[key_pattern]}"
}

koopa::debian_apt_key_prefix() { # {{{1
    # """
    # Debian apt key prefix.
    # @note Updated 2021-11-02.
    # @seealso
    # - '/etc/apt/trusted.gpg.d' (alternate location for apt).
    # """
    koopa::assert_has_no_args "$#"
    koopa::print '/usr/share/keyrings'
}

koopa::debian_apt_remove() { # {{{1
    # """
    # Remove Debian apt package.
    # @note Updated 2021-11-02.
    # """
    local app
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --yes remove --purge "$@"
    koopa::debian_apt_clean
    return 0
}

koopa::debian_apt_sources_file() { # {{{1
    # """
    # Debian apt sources file.
    # @note Updated 2021-11-02.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print '/etc/apt/sources.list'
}

koopa::debian_apt_sources_prefix() { # {{{1
    # """
    # Debian apt sources directory.
    # @note Updated 2021-11-02.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print '/etc/apt/sources.list.d'
}

koopa::debian_apt_space_used_by() { # {{{1
    # """
    # Check installed apt package size, with dependencies.
    # @note Updated 2021-11-02.
    #
    # Alternate approach that doesn't attempt to grep match.
    # """
    local app
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --assume-no autoremove "$@"
    return 0
}

koopa::debian_apt_space_used_by_grep() { # {{{1
    # """
    # Check installed apt package size, with dependencies.
    # @note Updated 2021-11-02.
    #
    # See also:
    # https://askubuntu.com/questions/490945
    # """
    local app x
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [cut]="$(koopa::locate_cut)"
        [sudo]="$(koopa::locate_sudo)"
    )
    x="$( \
        "${app[sudo]}" "${app[apt_get]}" \
            --assume-no \
            autoremove "$@" \
        | koopa::grep 'freed' \
        | "${app[cut]}" -d ' ' -f '4-5' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::debian_apt_space_used_by_no_deps() { # {{{1
    # """
    # Check install apt package size, without dependencies.
    # @note Updated 2021-11-02.
    # """
    local app x
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt]="$(koopa::debian_locate_apt)"
        [sudo]="$(koopa::locate_sudo)"
    )
    x="$( \
        "${app[sudo]}" "${app[apt]}" show "$@" 2>/dev/null \
            | koopa::grep 'Size' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::debian_install_from_deb() { # {{{1
    # """
    # Install directly from a '.deb' file.
    # @note Updated 2021-11-02.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_admin
    declare -A app=(
        [gdebi]="$(koopa::debian_locate_gdebi)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [file]="${1:?}"
    )
    "${app[sudo]}" "${app[gdebi]}" --non-interactive "${dict[file]}"
    return 0
}
