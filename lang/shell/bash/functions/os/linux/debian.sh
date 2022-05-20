#!/bin/sh
# shellcheck disable=all

koopa_debian_apt_add_azure_cli_repo() {
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_microsoft_key
    koopa_debian_apt_add_repo \
        --name-fancy='Microsoft Azure CLI' \
        --name='azure-cli' \
        --key-name='microsoft' \
        --url='https://packages.microsoft.com/repos/azure-cli/' \
        --distribution="$(koopa_os_codename)" \
        --component='main'
    return 0
}

koopa_debian_apt_add_docker_key() {
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_key \
        --name-fancy='Docker' \
        --name='docker' \
        --url="https://download.docker.com/linux/$(koopa_os_id)/gpg"
    return 0
}

koopa_debian_apt_add_docker_repo() {
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_docker_key
    koopa_debian_apt_add_repo \
        --name-fancy='Docker' \
        --name='docker' \
        --url="https://download.docker.com/linux/$(koopa_os_id)" \
        --distribution="$(koopa_os_codename)" \
        --component='stable'
    return 0
}

koopa_debian_apt_add_google_cloud_key() {
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_key \
        --name-fancy='Google Cloud' \
        --name='google-cloud' \
        --url='https://packages.cloud.google.com/apt/doc/apt-key.gpg'
    return 0
}

koopa_debian_apt_add_google_cloud_sdk_repo() {
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_google_cloud_key
    koopa_debian_apt_add_repo \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --key-name='google-cloud' \
        --url='https://packages.cloud.google.com/apt' \
        --distribution='cloud-sdk' \
        --component='main'
    return 0
}

koopa_debian_apt_add_key() {
    local app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [gpg]="$(koopa_locate_gpg)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [name]=''
        [name_fancy]=''
        [prefix]="$(koopa_debian_apt_key_prefix)"
        [url]=''
    )
    while (("$#"))
    do
        case "$1" in
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
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict[prefix]}"
    dict[file]="${dict[prefix]}/koopa-${dict[name]}.gpg"
    [[ -f "${dict[file]}" ]] && return 0
    koopa_alert "Adding ${dict[name_fancy]} key at '${dict[file]}'."
    koopa_parse_url --insecure "${dict[url]}" \
        | "${app[sudo]}" "${app[gpg]}" \
            --dearmor \
            --output "${dict[file]}" \
            >/dev/null 2>&1 \
        || true
    koopa_assert_is_file "${dict[file]}"
    return 0
}

koopa_debian_apt_add_llvm_key() {
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_key \
        --name-fancy='LLVM' \
        --name='llvm' \
        --url='https://apt.llvm.org/llvm-snapshot.gpg.key'
    return 0
}

koopa_debian_apt_add_llvm_repo() {
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        [component]='main'
        [name]='llvm'
        [name_fancy]='LLVM'
        [os]="$(koopa_os_codename)"
        [version]="${1:-}"
    )
    if [[ -z "${dict[version]}" ]]
    then
        dict[version]="$(koopa_variable "${dict[name]}")"
    fi
    dict[url]="http://apt.llvm.org/${dict[os]}/"
    dict[version2]="$(koopa_major_version "${dict[version]}")"
    dict[distribution]="llvm-toolchain-${dict[os]}-${dict[version2]}"
    koopa_debian_apt_add_llvm_key
    koopa_debian_apt_add_repo \
        --name-fancy="${dict[name_fancy]}" \
        --name="${dict[name]}" \
        --url="${dict[url]}" \
        --distribution="${dict[distribution]}" \
        --component="${dict[component]}"
    return 0
}

koopa_debian_apt_add_microsoft_key() {
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_key \
        --name-fancy='Microsoft' \
        --name='microsoft' \
        --url='https://packages.microsoft.com/keys/microsoft.asc'
    return 0
}

koopa_debian_apt_add_r_key() {
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A dict=(
        [key_name]='r'
        [keyserver]='keyserver.ubuntu.com'
        [prefix]="$(koopa_debian_apt_key_prefix)"
    )
    dict[file]="${dict[prefix]}/koopa-${dict[key_name]}.gpg"
    if koopa_is_ubuntu_like
    then
        dict[key]='E298A3A825C0D65DFD57CBB651716619E084DAB9'
    else
        dict[key]='95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7'
    fi
    [[ -f "${dict[file]}" ]] && return 0
    koopa_gpg_download_key_from_keyserver \
        --file="${dict[file]}" \
        --key="${dict[key]}" \
        --keyserver="${dict[keyserver]}" \
        --sudo
    return 0
}

koopa_debian_apt_add_r_repo() {
    local dict
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        [name]='r'
        [name_fancy]='R'
        [os_codename]="$(koopa_os_codename)"
        [version]="${1:-}"
    )
    if koopa_is_ubuntu_like
    then
        dict[os_id]='ubuntu'
    else
        dict[os_id]='debian'
    fi
    if [[ -z "${dict[version]}" ]]
    then
        dict[version]="$(koopa_variable "${dict[name]}")"
    fi
    dict[version2]="$(koopa_major_minor_version "${dict[version]}")"
    case "${dict[version2]}" in
        '4.1')
            dict[version2]='4.0'
            ;;
        '3.6')
            dict[version2]='3.5'
            ;;
    esac
    dict[version2]="$( \
        koopa_gsub \
            --pattern='\.' \
            --replacement='' \
            "${dict[version2]}" \
    )"
    dict[url]="https://cloud.r-project.org/bin/linux/${dict[os_id]}"
    dict[distribution]="${dict[os_codename]}-cran${dict[version2]}/"
    koopa_debian_apt_add_r_key
    koopa_debian_apt_add_repo \
        --name-fancy="${dict[name_fancy]}" \
        --name="${dict[name]}" \
        --url="${dict[url]}" \
        --distribution="${dict[distribution]}"
    return 0
}

koopa_debian_apt_add_repo() {
    local components dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A dict=(
        [arch]="$(koopa_arch2)" # e.g. 'amd64'.
        [key_prefix]="$(koopa_debian_apt_key_prefix)"
        [prefix]="$(koopa_debian_apt_sources_prefix)"
    )
    components=()
    while (("$#"))
    do
        case "$1" in
            '--component='*)
                components+=("${1#*=}")
                shift 1
                ;;
            '--component')
                components+=("${2:?}")
                shift 2
                ;;
            '--distribution='*)
                dict[distribution]="${1#*=}"
                shift 1
                ;;
            '--distribution')
                dict[distribution]="${2:?}"
                shift 2
                ;;
            '--key-name='*)
                dict[key_name]="${1#*=}"
                shift 1
                ;;
            '--key-name')
                dict[key_name]="${2:?}"
                shift 2
                ;;
            '--key-prefix='*)
                dict[key_prefix]="${1#*=}"
                shift 1
                ;;
            '--key-prefix')
                dict[key_prefix]="${2:?}"
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
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name')
                dict[name]="${2:?}"
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
            '--signed-by='*)
                dict[signed_by]="${1#*=}"
                shift 1
                ;;
            '--signed-by')
                dict[signed_by]="${2:?}"
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
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -z "${dict[key_name]:-}" ]]
    then
        dict[key_name]="${dict[name]}"
    fi
    koopa_assert_is_set \
        '--distribution' "${dict[distribution]:-}" \
        '--key-name' "${dict[key_name]:-}" \
        '--key-prefix' "${dict[key_prefix]:-}" \
        '--name' "${dict[name]:-}" \
        '--name-fancy' "${dict[name_fancy]:-}" \
        '--prefix' "${dict[prefix]:-}" \
        '--url' "${dict[url]:-}"
    koopa_assert_is_dir \
        "${dict[key_prefix]}" \
        "${dict[prefix]}"
    dict[signed_by]="${dict[key_prefix]}/koopa-${dict[key_name]}.gpg"
    koopa_assert_is_file "${dict[signed_by]}"
    dict[file]="${dict[prefix]}/koopa-${dict[name]}.list"
    dict[string]="deb [arch=${dict[arch]} signed-by=${dict[signed_by]}] \
${dict[url]} ${dict[distribution]} ${components[*]}"
    if [[ -f "${dict[file]}" ]]
    then
        koopa_alert_info "${dict[name_fancy]} repo exists at '${dict[file]}'."
        return 0
    fi
    koopa_alert "Adding ${dict[name_fancy]} repo at '${dict[file]}'."
    koopa_sudo_write_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
    return 0
}

koopa_debian_apt_add_wine_key() {
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_key \
        --name-fancy='Wine' \
        --name='wine' \
        --url='https://dl.winehq.org/wine-builds/winehq.key'
    return 0
}

koopa_debian_apt_add_wine_obs_key() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]='wine-obs'
        [name_fancy]='Wine OBS'
        [os_string]="$(koopa_os_string)"
    )
    case "${dict[os_string]}" in
        'debian-10')
            dict[subdir]='Debian_10'
            ;;
        'debian-11')
            dict[subdir]='Debian_11'
            ;;
        'ubuntu-18')
            dict[subdir]='xUbuntu_18.04'
            ;;
        'ubuntu-20')
            dict[subdir]='xUbuntu_20.04'
            ;;
        *)
            koopa_stop "Unsupported OS: '${dict[os_string]}'."
            ;;
    esac
    dict[url]="https://download.opensuse.org/repositories/\
Emulators:/Wine:/Debian/${dict[subdir]}/Release.key"
    koopa_debian_apt_add_key \
        --name-fancy="${dict[name_fancy]}" \
        --name="${dict[name]}" \
        --url="${dict[url]}"
    return 0
}

koopa_debian_apt_add_wine_obs_repo() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [base_url]="https://download.opensuse.org/repositories/\
Emulators:/Wine:/Debian"
        [distribution]='./'
        [name]='wine-obs'
        [name_fancy]='Wine OBS'
        [os_string]="$(koopa_os_string)"
    )
    case "${dict[os_string]}" in
        'debian-10')
            dict[url]="${dict[base_url]}/Debian_10/"
            ;;
        'debian-11')
            dict[url]="${dict[base_url]}/Debian_11/"
            ;;
        'ubuntu-18')
            dict[url]="${dict[base_url]}/xUbuntu_18.04/"
            ;;
        'ubuntu-20')
            dict[url]="${dict[base_url]}/xUbuntu_20.04/"
            ;;
        *)
            koopa_stop "Unsupported OS: '${dict[os_string]}'."
            ;;
    esac
    koopa_debian_apt_add_wine_obs_key
    koopa_debian_apt_add_repo \
        --name-fancy="${dict[name_fancy]}" \
        --name="${dict[name]}" \
        --url="${dict[url]}" \
        --distribution="${dict[distribution]}"
    return 0
}

koopa_debian_apt_add_wine_repo() {
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_wine_key
    koopa_debian_apt_add_repo \
        --name-fancy='Wine' \
        --name='wine' \
        --url="https://dl.winehq.org/wine-builds/$(koopa_os_id)/" \
        --distribution="$(koopa_os_codename)" \
        --component='main'
    return 0
}

koopa_debian_apt_clean() {

    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --yes autoremove
    "${app[sudo]}" "${app[apt_get]}" --yes clean
    return 0
}

koopa_debian_apt_configure_sources() {
    local app codenames repos urls
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [tee]="$(koopa_locate_tee)"
    )
    declare -A dict=(
        [os_codename]="$(koopa_os_codename)"
        [os_id]="$(koopa_os_id)"
        [sources_list]="$(koopa_debian_apt_sources_file)"
        [sources_list_d]="$(koopa_debian_apt_sources_prefix)"
    )
    koopa_alert "Configuring apt sources in '${dict[sources_list]}'."
    koopa_assert_is_file "${dict[sources_list]}"
    declare -A codenames=(
        [main]="${dict[os_codename]}"
        [security]="${dict[os_codename]}-security"
        [updates]="${dict[os_codename]}-updates"
    )
    declare -A urls=(
        [main]="$( \
            koopa_grep \
                --file="${dict[sources_list]}" \
                --pattern='^deb\s' \
                --regex \
            | koopa_grep \
                --fixed \
                --pattern=" ${codenames[main]} main" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '2' \
        )"
        [security]="$( \
            koopa_grep \
                --file="${dict[sources_list]}" \
                --pattern='^deb\s' \
                --regex \
            | koopa_grep \
                --fixed \
                --pattern=" ${codenames[security]} main" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '2' \
        )"
    )
    if [[ -z "${urls[main]}" ]]
    then
        koopa_stop 'Failed to extract apt main URL.'
    fi
    if [[ -z "${urls[security]}" ]]
    then
        koopa_stop 'Failed to extract apt security URL.'
    fi
    urls[updates]="${urls[main]}"
    case "${dict[os_id]}" in
        'debian')
            repos=('main')
            ;;
        'ubuntu')
            repos=('main' 'restricted' 'universe')
            ;;
        *)
            koopa_stop "Unsupported OS: '${dict[os_id]}'."
            ;;
    esac
    if [[ -L "${dict[sources_list]}" ]]
    then
        koopa_rm --sudo "${dict[sources_list]}"
    fi
    sudo "${app[tee]}" "${dict[sources_list]}" >/dev/null << END
deb ${urls[main]} ${codenames[main]} ${repos[*]}
deb ${urls[security]} ${codenames[security]} ${repos[*]}
deb ${urls[updates]} ${codenames[updates]} ${repos[*]}
END
    if [[ -L "${dict[sources_list_d]}" ]]
    then
        koopa_rm --sudo "${dict[sources_list_d]}"
    fi
    if [[ ! -d "${dict[sources_list_d]}" ]]
    then
        koopa_mkdir --sudo "${dict[sources_list_d]}"
    fi
    return 0
}

koopa_debian_apt_delete_repo() {
    local dict name
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A dict=(
        [prefix]="$(koopa_debian_apt_sources_prefix)"
    )
    for name in "$@"
    do
        local file
        file="${dict[prefix]}/koopa-${name}.list"
        koopa_assert_is_file "$file"
        koopa_rm --sudo "$file"
    done
    return 0
}

koopa_debian_apt_disable_deb_src() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    koopa_assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [sed]="$(koopa_locate_sed)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [file]="${1:-}"
    )
    [[ -z "${dict[file]}" ]] && dict[file]="$(koopa_debian_apt_sources_file)"
    koopa_assert_is_file "${dict[file]}"
    koopa_alert "Disabling Debian sources in '${dict[file]}'."
    if ! koopa_file_detect_regex \
        --file="${dict[file]}" \
        --pattern='^deb-src '
    then
        koopa_alert_note "No lines to comment in '${dict[file]}'."
        return 0
    fi
    "${app[sudo]}" "${app[sed]}" \
        -E \
        -i.bak \
        's/^deb-src /# deb-src /' \
        "${dict[file]}"
    "${app[sudo]}" "${app[apt_get]}" update
    return 0
}

koopa_debian_apt_enable_deb_src() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    koopa_assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [sed]="$(koopa_locate_sed)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [file]="${1:-}"
    )
    [[ -z "${dict[file]}" ]] && dict[file]="$(koopa_debian_apt_sources_file)"
    koopa_assert_is_file "${dict[file]}"
    koopa_alert "Enabling Debian sources in '${dict[file]}'."
    if ! koopa_file_detect_regex \
        --file="${dict[file]}" \
        --pattern='^# deb-src '
    then
        koopa_alert_note "No lines to uncomment in '${dict[file]}'."
        return 0
    fi
    "${app[sudo]}" "${app[sed]}" \
        -E \
        -i.bak \
        's/^# deb-src /deb-src /' \
        "${dict[file]}"
    "${app[sudo]}" "${app[apt_get]}" update
    return 0
}

koopa_debian_apt_enabled_repos() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    declare -A dict=(
        [file]="$(koopa_debian_apt_sources_file)"
        [os]="$(koopa_os_codename)"
    )
    dict[pattern]="^deb\s.+\s${dict[os]}\s.+$"
    dict[str]="$( \
        koopa_grep \
            --file="${dict[file]}" \
            --pattern="${dict[pattern]}" \
            --regex \
        | "${app[cut]}" -d ' ' -f '4-' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
}

koopa_debian_apt_get() {
    local app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [sudo]="$(koopa_locate_sudo)"
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

koopa_debian_apt_install() {
    koopa_assert_has_args "$#"
    koopa_debian_apt_get install "$@"
}

koopa_debian_apt_is_key_imported() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [apt_key]="$(koopa_debian_locate_apt_key)"
        [sed]="$(koopa_locate_sed)"
    )
    declare -A dict=(
        [key]="${1:?}"
    )
    dict[key_pattern]="$( \
        koopa_print "${dict[key]}" \
        | "${app[sed]}" 's/ //g' \
        | "${app[sed]}" -E \
            "s/^(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})\
(.{4})(.{4})(.{4})\$/\1 \2 \3 \4 \5  \6 \7 \8 \9/" \
    )"
    dict[string]="$("${app[apt_key]}" list 2>&1 || true)"
    koopa_str_detect_fixed \
        --string="${dict[string]}" \
        --pattern="${dict[key_pattern]}"
}

koopa_debian_apt_key_prefix() {
    koopa_assert_has_no_args "$#"
    koopa_print '/usr/share/keyrings'
}

koopa_debian_apt_remove() {
    local app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --yes remove --purge "$@"
    koopa_debian_apt_clean
    return 0
}

koopa_debian_apt_sources_file() {
    koopa_assert_has_no_args "$#"
    koopa_print '/etc/apt/sources.list'
}

koopa_debian_apt_sources_prefix() {
    koopa_assert_has_no_args "$#"
    koopa_print '/etc/apt/sources.list.d'
}

koopa_debian_apt_space_used_by_grep() {
    local app x
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [cut]="$(koopa_locate_cut)"
        [sudo]="$(koopa_locate_sudo)"
    )
    x="$( \
        "${app[sudo]}" "${app[apt_get]}" \
            --assume-no \
            autoremove "$@" \
        | koopa_grep --pattern='freed' \
        | "${app[cut]}" -d ' ' -f '4-5' \
    )"
    [[ -n "$x" ]] || return 1
    koopa_print "$x"
    return 0
}

koopa_debian_apt_space_used_by_no_deps() {
    local app x
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apt]="$(koopa_debian_locate_apt)"
        [sudo]="$(koopa_locate_sudo)"
    )
    x="$( \
        "${app[sudo]}" "${app[apt]}" show "$@" 2>/dev/null \
            | koopa_grep --pattern='Size' \
    )"
    [[ -n "$x" ]] || return 1
    koopa_print "$x"
    return 0
}

koopa_debian_apt_space_used_by() {
    local app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --assume-no autoremove "$@"
    return 0
}

koopa_debian_debian_version() {
    local file x
    file='/etc/debian_version'
    koopa_assert_is_file "$file"
    x="$(cat "$file")"
    koopa_print "$x"
    return 0
}

koopa_debian_enable_unattended_upgrades() {
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [dpkg_reconfigure]="$(koopa_debian_locate_dpkg_reconfigure)"
        [sudo]="$(koopa_locate_sudo)"
        [unattended_upgrades]="$(koopa_debian_locate_unattended_upgrades)"
    )
    koopa_debian_apt_install 'apt-listchanges' 'unattended-upgrades'
    "${app[sudo]}" "${app[dpkg_reconfigure]}" -plow 'unattended-upgrades'
    "${app[sudo]}" "${app[unattended_upgrades]}" -d
    return 0
}

koopa_debian_gdebi_install() {
    local app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [gdebi]="$(koopa_debian_locate_gdebi)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[gdebi]}" --non-interactive "$@"
    return 0
}

koopa_debian_install_azure_cli() {
    koopa_install_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_base_system() {
    koopa_install_app \
        --name-fancy='Debian base system' \
        --name='base-system' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_bcbio_nextgen_vm() {
    koopa_install_app \
        --name='bcbio-nextgen-vm' \
        --platform='debian' \
        "$@"
}

koopa_debian_install_docker() {
    koopa_install_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_from_deb() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    koopa_assert_is_admin
    declare -A app=(
        [gdebi]="$(koopa_debian_locate_gdebi)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [file]="${1:?}"
    )
    "${app[sudo]}" "${app[gdebi]}" --non-interactive "${dict[file]}"
    return 0
}

koopa_debian_install_google_cloud_sdk() {
    koopa_install_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_llvm() {
    koopa_install_app \
        --name-fancy='LLVM' \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_nodesource_node_binary() {
    koopa_install_app \
        --name-fancy='NodeSource Node.js' \
        --name='nodesource-node-binary' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_pandoc_binary() {
    koopa_install_app \
        --installer='pandoc-binary' \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_r_binary() {
    koopa_install_app \
        --installer='r-binary' \
        --name-fancy='R CRAN binary' \
        --name='r' \
        --platform='debian' \
        --system \
        --version-key='r' \
        "$@"
}

koopa_debian_install_rstudio_server() {
    koopa_install_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_shiny_server() {
    koopa_install_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_wine() {
    koopa_install_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_locate_apt() {
    koopa_locate_app '/usr/bin/apt'
}

koopa_debian_locate_apt_get() {
    koopa_locate_app '/usr/bin/apt-get'
}

koopa_debian_locate_apt_key() {
    koopa_locate_app '/usr/bin/apt-key'
}

koopa_debian_locate_dpkg() {
    koopa_locate_app '/usr/bin/dpkg'
}

koopa_debian_locate_dpkg_reconfigure() {
    koopa_locate_app '/usr/sbin/dpkg-reconfigure'
}

koopa_debian_locate_gdebi() {
    koopa_locate_app '/usr/bin/gdebi'
}

koopa_debian_locate_locale_gen() {
    koopa_locate_app '/usr/sbin/locale-gen'
}

koopa_debian_locate_service() {
    koopa_locate_app '/usr/sbin/service'
}

koopa_debian_locate_timedatectl() {
    koopa_locate_app '/usr/bin/timedatectl'
}

koopa_debian_locate_unattended_upgrades() {
    koopa_locate_app '/usr/bin/unattended-upgrades'
}

koopa_debian_locate_update_locale() {
    koopa_locate_app '/usr/sbin/update-locale'
}

koopa_debian_set_locale() {
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [dpkg_reconfigure]="$(koopa_debian_locate_dpkg_reconfigure)"
        [locale]="$(koopa_locate_locale)"
        [locale_gen]="$(koopa_debian_locate_locale_gen)"
        [sudo]="$(koopa_locate_sudo)"
        [update_locale]="$(koopa_debian_locate_update_locale)" 
    )
    declare -A dict=(
        [charset]='UTF-8'
        [country]='US'
        [lang]='en'
        [locale_file]='/etc/locale.gen'
    )
    dict[lang_string]="${dict[lang]}_${dict[country]}.${dict[charset]}"
    koopa_alert "Setting locale to '${dict[lang_string]}'."
    koopa_sudo_write_string \
        --file="${dict[locale_file]}" \
        --string="${dict[lang_string]} ${dict[charset]}"
    "${app[sudo]}" "${app[locale_gen]}" --purge
    "${app[sudo]}" "${app[dpkg_reconfigure]}" \
        --frontend='noninteractive' \
        'locales'
    "${app[sudo]}" "${app[update_locale]}" LANG="${dict[lang_string]}"
    "${app[locale]}" -a
    return 0
}

koopa_debian_set_timezone() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    koopa_is_docker && return 0
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [timedatectl]="$(koopa_debian_locate_timedatectl)"
    )
    declare -A dict=(
        [tz]="${1:-}"
    )
    [[ -z "${dict[tz]}" ]] && dict[tz]='America/New_York'
    koopa_alert "Setting local timezone to '${dict[tz]}'."
    "${app[sudo]}" "${app[timedatectl]}" set-timezone "${dict[tz]}"
    return 0
}

koopa_debian_uninstall_azure_cli() {
    koopa_uninstall_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_bcbio_nextgen_vm() {
    koopa_uninstall_app \
        --name='bcbio-nextgen-vm' \
        --platform='debian' \
        "$@"
}

koopa_debian_uninstall_docker() {
    koopa_uninstall_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_google_cloud_sdk() {
    koopa_uninstall_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_llvm() {
    koopa_uninstall_app \
        --name-fancy='LLVM' \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_pandoc_binary() {
    koopa_uninstall_app \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --platform='debian' \
        --system \
        --uninstaller='pandoc-binary' \
        "$@"
}

koopa_debian_uninstall_r_binary() {
    koopa_uninstall_app \
        --name-fancy='R CRAN binary' \
        --name='r' \
        --platform='debian' \
        --system \
        --uninstaller='r-binary' \
        --unlink-in-bin='R' \
        --unlink-in-bin='Rscript' \
        "$@"
}

koopa_debian_uninstall_rstudio_server() {
    koopa_uninstall_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_shiny_server() {
    koopa_uninstall_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_wine() {
    koopa_uninstall_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}
