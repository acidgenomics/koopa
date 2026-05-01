#!/usr/bin/env bash
# shellcheck disable=all

_koopa_debian_apt_add_docker_key() {
    _koopa_assert_has_no_args "$#"
    _koopa_debian_apt_add_key \
        --name='docker' \
        --url="https://download.docker.com/linux/$(_koopa_os_id)/gpg"
    return 0
}

_koopa_debian_apt_add_docker_repo() {
    _koopa_assert_has_no_args "$#"
    _koopa_debian_apt_add_docker_key
    _koopa_debian_apt_add_repo \
        --component='stable' \
        --distribution="$(_koopa_debian_os_codename)" \
        --name='docker' \
        --url="https://download.docker.com/linux/$(_koopa_os_id)"
    return 0
}

_koopa_debian_apt_add_key() {
    local -A app dict
    _koopa_assert_has_args "$#"
    app['gpg']="$(_koopa_locate_gpg --only-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['name']=''
    dict['prefix']="$(_koopa_debian_apt_key_prefix)"
    dict['url']=''
    while (("$#"))
    do
        case "$1" in
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict['url']="${1#*=}"
                shift 1
                ;;
            '--url')
                dict['url']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_dir "${dict['prefix']}"
    dict['file']="${dict['prefix']}/koopa-${dict['name']}.gpg"
    [[ -f "${dict['file']}" ]] && return 0
    _koopa_alert "Adding '${dict['name']}' key at '${dict['file']}'."
    _koopa_parse_url --insecure "${dict['url']}" \
        | _koopa_sudo "${app['gpg']}" \
            --dearmor \
            --output "${dict['file']}" \
            >/dev/null 2>&1 \
        || true
    _koopa_assert_is_file "${dict['file']}"
    return 0
}

_koopa_debian_apt_add_microsoft_key() {
    _koopa_assert_has_no_args "$#"
    _koopa_debian_apt_add_key \
        --name='microsoft' \
        --url='https://packages.microsoft.com/keys/microsoft.asc'
    return 0
}

_koopa_debian_apt_add_r_key() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    dict['key_name']='r'
    dict['keyserver']='keyserver.ubuntu.com'
    dict['prefix']="$(_koopa_debian_apt_key_prefix)"
    dict['file']="${dict['prefix']}/koopa-${dict['key_name']}.gpg"
    if _koopa_is_ubuntu_like
    then
        dict['key']='E298A3A825C0D65DFD57CBB651716619E084DAB9'
    else
        dict['key']='95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7'
    fi
    [[ -f "${dict['file']}" ]] && return 0
    _koopa_gpg_download_key_from_keyserver \
        --file="${dict['file']}" \
        --key="${dict['key']}" \
        --keyserver="${dict['keyserver']}" \
        --sudo \
        || true
    return 0
}

_koopa_debian_apt_add_r_repo() {
    local -A dict
    _koopa_assert_has_args_le "$#" 1
    dict['name']='r'
    dict['os_codename']="$(_koopa_debian_os_codename)"
    dict['version']="${1:-}"
    if _koopa_is_ubuntu_like
    then
        dict['os_id']='ubuntu'
    else
        dict['os_id']='debian'
    fi
    if [[ -z "${dict['version']}" ]]
    then
        dict['version']="$(_koopa_app_json_version "${dict['name']}")"
    fi
    dict['version2']="$(_koopa_major_minor_version "${dict['version']}")"
    case "${dict['version2']}" in
        '4.'*)
            dict['version2']='4.0'
            ;;
        '3.'*)
            dict['version2']='3.5'
            ;;
    esac
    dict['version2']="$( \
        _koopa_gsub \
            --fixed \
            --pattern='.' \
            --replacement='' \
            "${dict['version2']}" \
    )"
    dict['url']="https://cloud.r-project.org/bin/linux/${dict['os_id']}"
    dict['distribution']="${dict['os_codename']}-cran${dict['version2']}/"
    _koopa_debian_apt_add_r_key || true
    _koopa_debian_apt_add_repo \
        --distribution="${dict['distribution']}" \
        --name="${dict['name']}" \
        --url="${dict['url']}"
    return 0
}

_koopa_debian_apt_add_repo() {
    local -A dict
    local -a components
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    dict['arch']="$(_koopa_arch2)" # e.g. 'amd64'.
    dict['distribution']=''
    dict['key_name']=''
    dict['key_prefix']="$(_koopa_debian_apt_key_prefix)"
    dict['name']=''
    dict['prefix']="$(_koopa_debian_apt_sources_prefix)"
    dict['signed_by']=''
    dict['url']=''
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
                dict['distribution']="${1#*=}"
                shift 1
                ;;
            '--distribution')
                dict['distribution']="${2:?}"
                shift 2
                ;;
            '--key-name='*)
                dict['key_name']="${1#*=}"
                shift 1
                ;;
            '--key-name')
                dict['key_name']="${2:?}"
                shift 2
                ;;
            '--key-prefix='*)
                dict['key_prefix']="${1#*=}"
                shift 1
                ;;
            '--key-prefix')
                dict['key_prefix']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--signed-by='*)
                dict['signed_by']="${1#*=}"
                shift 1
                ;;
            '--signed-by')
                dict['signed_by']="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict['url']="${1#*=}"
                shift 1
                ;;
            '--url')
                dict['url']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -z "${dict['key_name']:-}" ]]
    then
        dict['key_name']="${dict['name']}"
    fi
    _koopa_assert_is_set \
        '--distribution' "${dict['distribution']}" \
        '--key-name' "${dict['key_name']}" \
        '--key-prefix' "${dict['key_prefix']}" \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--url' "${dict['url']}"
    _koopa_assert_is_dir \
        "${dict['key_prefix']}" \
        "${dict['prefix']}"
    dict['signed_by']="${dict['key_prefix']}/koopa-${dict['key_name']}.gpg"
    dict['file']="${dict['prefix']}/koopa-${dict['name']}.list"
    if [[ -f "${dict['signed_by']}" ]]
    then
        dict['string']="deb [arch=${dict['arch']} \
signed-by=${dict['signed_by']}] ${dict['url']} ${dict['distribution']} \
${components[*]}"
    else
        _koopa_alert_note "GPG key does not exist at '${dict['signed_by']}'."
        dict['string']="deb [arch=${dict['arch']}] ${dict['url']} \
${dict['distribution']} ${components[*]}"
    fi
    if [[ -f "${dict['file']}" ]]
    then
        _koopa_alert_info "'${dict['name']}' repo exists at '${dict['file']}'."
        return 0
    fi
    _koopa_alert "Adding '${dict['name']}' repo at '${dict['file']}'."
    _koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    return 0
}

_koopa_debian_apt_add_wine_key() {
    _koopa_assert_has_no_args "$#"
    _koopa_debian_apt_add_key \
        --name='wine' \
        --url='https://dl.winehq.org/wine-builds/winehq.key'
    return 0
}

_koopa_debian_apt_add_wine_obs_key() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['name']='wine-obs'
    dict['os_string']="$(_koopa_os_string)"
    case "${dict['os_string']}" in
        'debian-10')
            dict['subdir']='Debian_10'
            ;;
        'debian-11')
            dict['subdir']='Debian_11'
            ;;
        'ubuntu-18')
            dict['subdir']='xUbuntu_18.04'
            ;;
        'ubuntu-20')
            dict['subdir']='xUbuntu_20.04'
            ;;
        *)
            _koopa_stop "Unsupported OS: '${dict['os_string']}'."
            ;;
    esac
    dict['url']="https://download.opensuse.org/repositories/\
Emulators:/Wine:/Debian/${dict['subdir']}/Release.key"
    _koopa_debian_apt_add_key \
        --name="${dict['name']}" \
        --url="${dict['url']}"
    return 0
}

_koopa_debian_apt_add_wine_obs_repo() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['base_url']="https://download.opensuse.org/repositories/Emulators:\
/Wine:/Debian"
    dict['distribution']='./'
    dict['name']='wine-obs'
    dict['os_string']="$(_koopa_os_string)"
    case "${dict['os_string']}" in
        'debian-10')
            dict['url']="${dict['base_url']}/Debian_10/"
            ;;
        'debian-11')
            dict['url']="${dict['base_url']}/Debian_11/"
            ;;
        'ubuntu-18')
            dict['url']="${dict['base_url']}/xUbuntu_18.04/"
            ;;
        'ubuntu-20')
            dict['url']="${dict['base_url']}/xUbuntu_20.04/"
            ;;
        *)
            _koopa_stop "Unsupported OS: '${dict['os_string']}'."
            ;;
    esac
    _koopa_debian_apt_add_wine_obs_key
    _koopa_debian_apt_add_repo \
        --distribution="${dict['distribution']}" \
        --name="${dict['name']}" \
        --url="${dict['url']}"
    return 0
}

_koopa_debian_apt_add_wine_repo() {
    _koopa_assert_has_no_args "$#"
    _koopa_debian_apt_add_wine_key
    _koopa_debian_apt_add_repo \
        --component='main' \
        --distribution="$(_koopa_debian_os_codename)" \
        --name='wine' \
        --url="https://dl.winehq.org/wine-builds/$(_koopa_os_id)/"
    return 0
}

_koopa_debian_apt_clean() {

    local -A app
    _koopa_assert_has_no_args "$#"
    app['apt_get']="$(_koopa_debian_locate_apt_get)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['apt_get']}" --yes autoremove
    _koopa_sudo "${app['apt_get']}" --yes clean
    return 0
}

_koopa_debian_apt_configure_sources() {
    local -A app codenames dict urls
    local -a repos
    _koopa_assert_has_no_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    app['tee']="$(_koopa_locate_tee --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['os_codename']="$(_koopa_debian_os_codename)"
    dict['os_id']="$(_koopa_os_id)"
    dict['sources_list']="$(_koopa_debian_apt_sources_file)"
    dict['sources_list_d']="$(_koopa_debian_apt_sources_prefix)"
    if [[ ! -f "${dict['sources_list']}" ]]
    then
        _koopa_alert_info "Skipping apt configuration at \
'${dict['sources_list']}'. File does not exist."
        return 0
    fi
    if _koopa_is_ubuntu_like && \
        [[ -f '/etc/apt/sources.list.d/ubuntu.sources' ]]
    then
        _koopa_alert_note "System is configured to use new 'ubuntu.sources'."
        return 0
    fi
    if ! _koopa_file_detect_regex \
        --file="${dict['sources_list']}" \
        --pattern='^deb\s'
    then
        _koopa_alert_note "Failed to detect 'deb' in '${dict['sources_list']}'."
        return 0
    fi
    _koopa_alert "Configuring apt sources in '${dict['sources_list']}'."
    codenames['main']="${dict['os_codename']}"
    codenames['security']="${dict['os_codename']}-security"
    codenames['updates']="${dict['os_codename']}-updates"
    urls['main']="$( \
        _koopa_grep \
            --file="${dict['sources_list']}" \
            --pattern='^deb\s' \
            --regex \
        | _koopa_grep \
            --fixed \
            --pattern=' main' \
        | "${app['head']}" -n 1 \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    urls['security']="$( \
        _koopa_grep \
            --file="${dict['sources_list']}" \
            --pattern='^deb\s' \
            --regex \
        | _koopa_grep \
            --fixed \
            --pattern='security main' \
        | "${app['head']}" -n 1 \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    if [[ -z "${urls['main']}" ]]
    then
        _koopa_stop 'Failed to extract apt main URL.'
    fi
    if [[ -z "${urls['security']}" ]]
    then
        _koopa_stop 'Failed to extract apt security URL.'
    fi
    urls['updates']="${urls['main']}"
    case "${dict['os_id']}" in
        'debian')
            repos=('main')
            ;;
        'ubuntu')
            repos=('main' 'restricted' 'universe')
            ;;
        *)
            _koopa_stop "Unsupported OS: '${dict['os_id']}'."
            ;;
    esac
    if [[ -L "${dict['sources_list']}" ]]
    then
        _koopa_rm --sudo "${dict['sources_list']}"
    fi
    if [[ -L "${dict['sources_list_d']}" ]]
    then
        _koopa_rm --sudo "${dict['sources_list_d']}"
    fi
    if [[ ! -d "${dict['sources_list_d']}" ]]
    then
        _koopa_mkdir --sudo "${dict['sources_list_d']}"
    fi
    read -r -d '' "dict[sources_list_string]" << END || true
deb ${urls['main']} ${codenames['main']} ${repos[*]}
deb ${urls['security']} ${codenames['security']} ${repos[*]}
deb ${urls['updates']} ${codenames['updates']} ${repos[*]}
END
    _koopa_sudo_write_string \
        --file="${dict['sources_list']}" \
        --string="${dict['sources_list_string']}"
    return 0
}

_koopa_debian_apt_delete_repo() {
    local -A dict
    local name
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    dict['prefix']="$(_koopa_debian_apt_sources_prefix)"
    for name in "$@"
    do
        local file
        file="${dict['prefix']}/koopa-${name}.list"
        if [[ ! -f "$file" ]]
        then
            _koopa_alert_note "File does not exist: '${file}'."
            continue
        fi
        _koopa_rm --sudo "$file"
    done
    return 0
}

_koopa_debian_apt_disable_deb_src() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    _koopa_assert_is_admin
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']="${1:-}"
    [[ -z "${dict['file']}" ]] && \
        dict['file']="$(_koopa_debian_apt_sources_file)"
    _koopa_assert_is_file "${dict['file']}"
    _koopa_alert "Disabling Debian sources in '${dict['file']}'."
    if ! _koopa_file_detect_regex \
        --file="${dict['file']}" \
        --pattern='^deb-src '
    then
        _koopa_alert_note "No lines to comment in '${dict['file']}'."
        return 0
    fi
    _koopa_sudo \
        "${app['sed']}" \
            -E \
            -i.bak \
            's/^deb-src /# deb-src /' \
            "${dict['file']}"
    _koopa_debian_apt_get update
    return 0
}

_koopa_debian_apt_enable_deb_src() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    _koopa_assert_is_admin
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']="${1:-}"
    [[ -z "${dict['file']}" ]] && \
        dict['file']="$(_koopa_debian_apt_sources_file)"
    _koopa_assert_is_file "${dict['file']}"
    _koopa_alert "Enabling Debian sources in '${dict['file']}'."
    if ! _koopa_file_detect_regex \
        --file="${dict['file']}" \
        --pattern='^# deb-src '
    then
        _koopa_alert_note "No lines to uncomment in '${dict['file']}'."
        return 0
    fi
    _koopa_sudo \
        "${app['sed']}" \
            -E \
            -i.bak \
            's/^# deb-src /deb-src /' \
            "${dict['file']}"
    _koopa_debian_apt_get update
    return 0
}

_koopa_debian_apt_enabled_repos() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']="$(_koopa_debian_apt_sources_file)"
    dict['os']="$(_koopa_debian_os_codename)"
    dict['pattern']="^deb\s.+\s${dict['os']}\s.+$"
    dict['str']="$( \
        _koopa_grep \
            --file="${dict['file']}" \
            --pattern="${dict['pattern']}" \
            --regex \
        | "${app['cut']}" -d ' ' -f '4-' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_debian_apt_get() {
    local -A app
    local -a apt_args
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['apt_get']="$(_koopa_debian_locate_apt_get)"
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['debconf_set_selections']="$( \
        _koopa_debian_locate_debconf_set_selections \
    )"
    _koopa_assert_is_executable "${app[@]}"
    apt_args=(
        '--assume-yes'
        '--no-install-recommends'
        '--quiet'
        '-o' 'Dpkg::Options::=--force-confdef'
        '-o' 'Dpkg::Options::=--force-confold'
    )
    (
        _koopa_add_to_path_end '/usr/sbin' '/sbin'
        export DEBCONF_NONINTERACTIVE_SEEN='true'
        export DEBIAN_FRONTEND='noninteractive'
        export DEBIAN_PRIORITY='critical'
        export LANG='C'
        export LANGUAGE='C'
        export LC_ALL='C'
        export NEEDRESTART_MODE='a'
        "${app['cat']}" << END | _koopa_sudo "${app['debconf_set_selections']}"
debconf debconf/frontend select Noninteractive
END
        _koopa_sudo "${app['apt_get']}" "${apt_args[@]}" "$@"
    )
    return 0
}

_koopa_debian_apt_install() {
    _koopa_assert_has_args "$#"
    _koopa_debian_apt_get update
    _koopa_debian_apt_get install "$@"
    return 0
}

_koopa_debian_apt_key_prefix() {
    _koopa_assert_has_no_args "$#"
    _koopa_print '/usr/share/keyrings'
}

_koopa_debian_apt_remove() {
    _koopa_assert_has_args "$#"
    _koopa_debian_apt_get purge "$@"
    _koopa_debian_apt_clean
    return 0
}

_koopa_debian_apt_sources_file() {
    _koopa_assert_has_no_args "$#"
    _koopa_print '/etc/apt/sources.list'
}

_koopa_debian_apt_sources_prefix() {
    _koopa_assert_has_no_args "$#"
    _koopa_print '/etc/apt/sources.list.d'
}

_koopa_debian_apt_space_used_by_grep() {
    local -A app
    local str
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['apt_get']="$(_koopa_debian_locate_apt_get)"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        _koopa_sudo \
            "${app['apt_get']}" \
                --assume-no \
                autoremove "$@" \
        | _koopa_grep --pattern='freed' \
        | "${app['cut']}" -d ' ' -f '4-5' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_debian_apt_space_used_by_no_deps() {
    local -A app
    local str
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['apt']="$(_koopa_debian_locate_apt)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        _koopa_sudo \
            "${app['apt']}" show "$@" 2>/dev/null \
            | _koopa_grep --pattern='Size' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_debian_apt_space_used_by() {
    local -A app
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['apt_get']="$(_koopa_debian_locate_apt_get)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['apt_get']}" --assume-no autoremove "$@"
    return 0
}

_koopa_debian_configure_system_base() {
    _koopa_configure_app \
        --name='base' \
        --platform='debian' \
        --system \
        "$@"
}

_koopa_debian_debian_version() {
    local file x
    file='/etc/debian_version'
    _koopa_assert_is_file "$file"
    x="$(cat "$file")"
    _koopa_print "$x"
    return 0
}

_koopa_debian_enable_unattended_upgrades() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['dpkg_reconfigure']="$(_koopa_debian_locate_dpkg_reconfigure)"
    app['unattended_upgrades']="$(_koopa_debian_locate_unattended_upgrades)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_debian_apt_install 'apt-listchanges' 'unattended-upgrades'
    _koopa_sudo "${app['dpkg_reconfigure']}" -plow 'unattended-upgrades'
    _koopa_sudo "${app['unattended_upgrades']}" -d
    return 0
}

_koopa_debian_install_from_deb() {
    local -A app
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['gdebi']="$(_koopa_debian_locate_gdebi --allow-missing)"
    if [[ ! -x "${app['gdebi']}" ]]
    then
        _koopa_debian_apt_install 'gdebi-core'
        app['gdebi']="$(_koopa_debian_locate_gdebi)"
    fi
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['gdebi']}" --non-interactive "$@"
    return 0
}

_koopa_debian_install_system_aws_mountpoint_s3() {
    _koopa_install_app \
        --name='aws-mountpoint-s3' \
        --platform='debian' \
        --system \
        "$@"
}

_koopa_debian_install_system_docker() {
    _koopa_install_app \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

_koopa_debian_install_system_r() {
    _koopa_install_app \
        --name='r' \
        --platform='debian' \
        --system \
        --version-key='r' \
        "$@"
}

_koopa_debian_install_system_rstudio_server() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}

_koopa_debian_install_system_shiny_server() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}

_koopa_debian_install_system_wine() {
    _koopa_install_app \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}

_koopa_debian_locate_apt_get() {
    _koopa_locate_app \
        '/usr/bin/apt-get' \
        "$@"
}

_koopa_debian_locate_apt() {
    _koopa_locate_app \
        '/usr/bin/apt' \
        "$@"
}

_koopa_debian_locate_debconf_set_selections() {
    _koopa_locate_app \
        '/usr/bin/debconf-set-selections' \
        "$@"
}

_koopa_debian_locate_dpkg_reconfigure() {
    _koopa_locate_app \
        '/usr/sbin/dpkg-reconfigure' \
        "$@"
}

_koopa_debian_locate_dpkg() {
    _koopa_locate_app \
        '/usr/bin/dpkg' \
        "$@"
}

_koopa_debian_locate_gdebi() {
    _koopa_locate_app \
        '/usr/bin/gdebi' \
        "$@"
}

_koopa_debian_locate_locale_gen() {
    _koopa_locate_app \
        '/usr/sbin/locale-gen' \
        "$@"
}

_koopa_debian_locate_lsb_release() {
    _koopa_locate_app \
        '/usr/bin/lsb_release' \
        "$@"
}

_koopa_debian_locate_service() {
    _koopa_locate_app \
        '/usr/sbin/service' \
        "$@"
}

_koopa_debian_locate_timedatectl() {
    _koopa_locate_app \
        '/usr/bin/timedatectl' \
        "$@"
}

_koopa_debian_locate_unattended_upgrades() {
    _koopa_locate_app \
        '/usr/bin/unattended-upgrades' \
        "$@"
}

_koopa_debian_locate_update_locale() {
    _koopa_locate_app \
        '/usr/sbin/update-locale' \
        "$@"
}

_koopa_debian_needrestart_noninteractive() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['file']='/etc/needrestart/needrestart.conf'
    [[ -f "${dict['file']}" ]] || return 0
    if ! _koopa_file_detect_fixed \
        --file="${dict['file']}" \
        --pattern="#\$nrconf{restart} = 'i';"
    then
        return 0
    fi
    _koopa_assert_is_admin
    _koopa_alert "Modifying '${dict['file']}'."
    _koopa_find_and_replace_in_file \
        --fixed \
        --pattern="#\$nrconf{restart} = \'i\';" \
        --replacement="\$nrconf{restart} = \'a\';" \
        --sudo \
        "${dict['file']}"
    return 0
}

_koopa_debian_os_codename() {
    local -A app dict
    app['lsb_release']="$(_koopa_debian_locate_lsb_release)"
    _koopa_assert_is_executable "${app[@]}"
    dict['string']="$("${app['lsb_release']}" -cs)"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}

_koopa_debian_set_locale() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['dpkg_reconfigure']="$(_koopa_debian_locate_dpkg_reconfigure)"
    app['locale']="$(_koopa_locate_locale)"
    app['locale_gen']="$(_koopa_debian_locate_locale_gen)"
    app['update_locale']="$(_koopa_debian_locate_update_locale)"
    _koopa_assert_is_executable "${app[@]}"
    dict['charset']='UTF-8'
    dict['country']='US'
    dict['lang']='en'
    dict['locale_file']='/etc/locale.gen'
    dict['lang_string']="${dict['lang']}_${dict['country']}.${dict['charset']}"
    _koopa_alert "Setting locale to '${dict['lang_string']}'."
    _koopa_sudo_write_string \
        --file="${dict['locale_file']}" \
        --string="${dict['lang_string']} ${dict['charset']}"
    _koopa_sudo "${app['locale_gen']}" --purge
    _koopa_sudo "${app['dpkg_reconfigure']}" \
        --frontend='noninteractive' \
        'locales'
    _koopa_sudo "${app['update_locale']}" LANG="${dict['lang_string']}"
    "${app['locale']}" -a
    return 0
}

_koopa_debian_set_timezone() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    _koopa_assert_is_admin
    _koopa_linux_is_init_systemd || return 0
    app['timedatectl']="$(_koopa_debian_locate_timedatectl)"
    _koopa_assert_is_executable "${app[@]}"
    dict['tz']="${1:-}"
    [[ -z "${dict['tz']}" ]] && dict['tz']='America/New_York'
    _koopa_alert "Setting local timezone to '${dict['tz']}'."
    _koopa_sudo "${app['timedatectl']}" set-timezone "${dict['tz']}"
    return 0
}

_koopa_debian_uninstall_shiny_server() {
    _koopa_uninstall_app \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}

_koopa_debian_uninstall_system_docker() {
    _koopa_uninstall_app \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

_koopa_debian_uninstall_system_r() {
    _koopa_uninstall_app \
        --name='r' \
        --platform='debian' \
        --system \
        "$@"
}

_koopa_debian_uninstall_system_rstudio_server() {
    _koopa_uninstall_app \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}

_koopa_debian_uninstall_system_wine() {
    _koopa_uninstall_app \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}
