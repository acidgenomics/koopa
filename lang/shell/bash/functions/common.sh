#!/usr/bin/env bash
# shellcheck disable=all

__koopa_alert_process_start() {
    local dict
    declare -A dict
    dict['word']="${1:?}"
    shift 1
    koopa_assert_has_args_le "$#" 3
    dict['name']="${1:?}"
    dict['version']=''
    dict['prefix']=''
    if [[ "$#" -eq 2 ]]
    then
        dict['prefix']="${2:?}"
    elif [[ "$#" -eq 3 ]]
    then
        dict['version']="${2:?}"
        dict['prefix']="${3:?}"
    fi
    if [[ -n "${dict['prefix']}" ]] && [[ -n "${dict['version']}" ]]
    then
        dict['out']="${dict['word']} '${dict['name']}' ${dict['version']} \
at '${dict['prefix']}'."
    elif [[ -n "${dict['prefix']}" ]]
    then
        dict['out']="${dict['word']} '${dict['name']}' at '${dict['prefix']}'."
    else
        dict['out']="${dict['word']} '${dict['name']}'."
    fi
    koopa_alert "${dict['out']}"
    return 0
}

__koopa_alert_process_success() {
    local dict
    declare -A dict
    dict['word']="${1:?}"
    shift 1
    koopa_assert_has_args_le "$#" 2
    dict['name']="${1:?}"
    dict['prefix']="${2:-}"
    if [[ -n "${dict['prefix']}" ]]
    then
        dict['out']="${dict['word']} of '${dict['name']}' at \
'${dict['prefix']}' was successful."
    else
        dict['out']="${dict['word']} of '${dict['name']}' was successful."
    fi
    koopa_alert_success "${dict['out']}"
    return 0
}

__koopa_ansi_escape() {
    local escape
    case "${1:?}" in
        'nocolor')
            escape='0'
            ;;
        'default')
            escape='0;39'
            ;;
        'default-bold')
            escape='1;39'
            ;;
        'black')
            escape='0;30'
            ;;
        'black-bold')
            escape='1;30'
            ;;
        'blue')
            escape='0;34'
            ;;
        'blue-bold')
            escape='1;34'
            ;;
        'cyan')
            escape='0;36'
            ;;
        'cyan-bold')
            escape='1;36'
            ;;
        'green')
            escape='0;32'
            ;;
        'green-bold')
            escape='1;32'
            ;;
        'magenta')
            escape='0;35'
            ;;
        'magenta-bold')
            escape='1;35'
            ;;
        'red')
            escape='0;31'
            ;;
        'red-bold')
            escape='1;31'
            ;;
        'yellow')
            escape='0;33'
            ;;
        'yellow-bold')
            escape='1;33'
            ;;
        'white')
            escape='0;97'
            ;;
        'white-bold')
            escape='1;97'
            ;;
        *)
            return 1
            ;;
    esac
    printf '\033[%sm' "$escape"
    return 0
}

__koopa_file_detect() {
    local dict grep_args
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['file']=''
        ['mode']=''
        ['pattern']=''
        ['stdin']=1
        ['sudo']=0
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                dict['stdin']=0
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                dict['stdin']=0
                shift 2
                ;;
            '--mode='*)
                dict['mode']="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict['mode']="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--sudo')
                dict['sudo']=1
                shift 1
                ;;
            '-')
                dict['stdin']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${dict['stdin']}" -eq 1 ]]
    then
        dict['file']="$(</dev/stdin)"
    fi
    koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--mode' "${dict['mode']}" \
        '--pattern' "${dict['pattern']}"
    grep_args=(
        '--boolean'
        '--file' "${dict['file']}"
        '--mode' "${dict['mode']}"
        '--pattern' "${dict['pattern']}"
    )
    [[ "${dict['sudo']}" -eq 1 ]] && grep_args+=('--sudo')
    koopa_grep "${grep_args[@]}"
}

__koopa_get_version_arg() {
    local arg name
    koopa_assert_has_args_eq "$#" 1
    name="$(koopa_basename "${1:?}")"
    case "$name" in
        'apptainer' | \
        'docker-credential-pass' | \
        'go' | \
        'openssl' | \
        'rstudio-server')
            arg='version'
            ;;
        'exiftool')
            arg='-ver'
            ;;
        'lua')
            arg='-v'
            ;;
        'openssh' | \
        'ssh' | \
        'tmux')
            arg='-V'
            ;;
        *)
            arg='--version'
            ;;
    esac
    koopa_print "$arg"
    return 0
}

__koopa_h() {
    local dict
    koopa_assert_has_args_ge "$#" 2
    declare -A dict=(
        ['emoji']="$(koopa_acid_emoji)"
        ['level']="${1:?}"
    )
    shift 1
    case "${dict['level']}" in
        '1')
            koopa_print ''
            dict['prefix']='#'
            ;;
        '2')
            dict['prefix']='##'
            ;;
        '3')
            dict['prefix']='###'
            ;;
        '4')
            dict['prefix']='####'
            ;;
        '5')
            dict['prefix']='#####'
            ;;
        '6')
            dict['prefix']='######'
            ;;
        '7')
            dict['prefix']='#######'
            ;;
        *)
            koopa_stop 'Invalid header level.'
            ;;
    esac
    __koopa_msg 'magenta' 'default' "${dict['emoji']} ${dict['prefix']}" "$@"
    return 0
}

__koopa_is_ssh_enabled() {
    local app dict
    koopa_assert_has_args_eq "$#" 2
    declare -A app=(
        ['ssh']="$(koopa_locate_ssh)"
    )
    [[ -x "${app['ssh']}" ]] || return 1
    declare -A dict=(
        ['url']="${1:?}"
        ['pattern']="${2:?}"
    )
    dict['str']="$( \
        "${app['ssh']}" -T \
            -o StrictHostKeyChecking='no' \
            "${dict['url']}" 2>&1 \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_str_detect_fixed \
        --string="${dict['str']}" \
        --pattern="${dict['pattern']}"
}

__koopa_link_in_dir() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['name']=''
        ['prefix']=''
        ['source']=''
    )
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
            '--source='*)
                dict['source']="${1#*=}"
                shift 1
                ;;
            '--source')
                dict['source']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--source' "${dict['source']}"
    [[ ! -d "${dict['prefix']}" ]] && koopa_mkdir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    dict['target']="${dict['prefix']}/${dict['name']}"
    koopa_assert_is_existing "${dict['source']}"
    koopa_sys_ln "${dict['source']}" "${dict['target']}"
    return 0
}

__koopa_list_path_priority_unique() {
    local app str
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
        ['tac']="$(koopa_locate_tac)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['tac']}" ]] || return 1
    str="$( \
        __koopa_list_path_priority "$@" \
            | "${app['tac']}" \
            | "${app['awk']}" '!a[$0]++' \
            | "${app['tac']}" \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

__koopa_list_path_priority() {
    local str
    koopa_assert_has_args_le "$#" 1
    str="${1:-$PATH}"
    str="$(koopa_print "${str//:/$'\n'}")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

__koopa_msg() {
    local c1 c2 nc prefix str
    c1="$(__koopa_ansi_escape "${1:?}")"
    c2="$(__koopa_ansi_escape "${2:?}")"
    nc="$(__koopa_ansi_escape 'nocolor')"
    prefix="${3:?}"
    shift 3
    for str in "$@"
    do
        koopa_print "${c1}${prefix}${nc} ${c2}${str}${nc}"
    done
    return 0
}

__koopa_print_ansi() {
    local color nocolor str
    color="$(__koopa_ansi_escape "${1:?}")"
    nocolor="$(__koopa_ansi_escape 'nocolor')"
    shift 1
    for str in "$@"
    do
        printf '%s%b%s\n' "$color" "$str" "$nocolor"
    done
    return 0
}

__koopa_status() {
    local dict string
    koopa_assert_has_args_ge "$#" 3
    declare -A dict=(
        ['label']="$(printf '%10s\n' "${1:?}")"
        ['color']="$(__koopa_ansi_escape "${2:?}")"
        ['nocolor']="$(__koopa_ansi_escape 'nocolor')"
    )
    shift 2
    for string in "$@"
    do
        string="${dict['color']}${dict['label']}${dict['nocolor']} | ${string}"
        koopa_print "$string"
    done
    return 0
}

__koopa_str_detect() {
    local dict grep_args
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['mode']=''
        ['pattern']=''
        ['stdin']=1
        ['string']=''
        ['sudo']=0
    )
    while (("$#"))
    do
        case "$1" in
            '--mode='*)
                dict['mode']="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict['mode']="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                dict['stdin']=0
                shift 1
                ;;
            '--string')
                dict['string']="${2:-}"
                dict['stdin']=0
                shift 2
                ;;
            '--sudo')
                dict['sudo']=1
                shift 1
                ;;
            '-')
                dict['stdin']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${dict['stdin']}" -eq 1 ]]
    then
        dict['string']="$(</dev/stdin)"
    fi
    koopa_assert_is_set \
        '--mode' "${dict['mode']}" \
        '--pattern' "${dict['pattern']}"
    grep_args=(
        '--boolean'
        '--mode' "${dict['mode']}"
        '--pattern' "${dict['pattern']}"
        '--string' "${dict['string']}"
    )
    [[ "${dict['sudo']}" -eq 1 ]] && grep_args+=('--sudo')
    koopa_grep "${grep_args[@]}"
}

__koopa_unlink_in_dir() {
    local dict name names pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['allow_missing']=0
        ['prefix']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--allow-missing')
                dict['allow_missing']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_set '--prefix' "${dict['prefix']}"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    names=("$@")
    for name in "${names[@]}"
    do
        local file
        file="${dict['prefix']}/${name}"
        if [[ "${dict['allow_missing']}" -eq 1 ]]
        then
            if [[ -L "$file" ]]
            then
                koopa_rm "$file"
            fi
        else
            koopa_assert_is_symlink "$file"
            koopa_rm "$file"
        fi
    done
    return 0
}

koopa_acid_emoji() {
    koopa_print '🧪'
}

koopa_activate_app() {
    local app app_name dict pos
    koopa_assert_has_args "$#"
    declare -A app
    app['pkg_config']="$(koopa_locate_pkg_config --allow-missing)"
    declare -A dict=(
        ['build_only']=0
        ['opt_prefix']="$(koopa_opt_prefix)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--build-only')
                dict['build_only']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    CPPFLAGS="${CPPFLAGS:-}"
    LDFLAGS="${LDFLAGS:-}"
    LDLIBS="${LDLIBS:-}"
    for app_name in "$@"
    do
        local dict2
        declare -A dict2
        dict2['app_name']="$app_name"
        dict2['prefix']="${dict['opt_prefix']}/${dict2['app_name']}"
        koopa_assert_is_dir "${dict2['prefix']}"
        dict2['current_ver']="$(koopa_app_version "${dict2['app_name']}")"
        dict2['expected_ver']="$(koopa_app_json_version "${dict2['app_name']}")"
        if [[ "${#dict2['expected_ver']}" -eq 40 ]]
        then
            dict2['expected_ver']="${dict2['expected_ver']:0:7}"
        fi
        if [[ "${dict2['current_ver']}" != "${dict2['expected_ver']}" ]]
        then
            koopa_stop "'${dict2['app_name']}' version mismatch at \
'${dict2['prefix']}' (${dict2['current_ver']} != ${dict2['expected_ver']})."
        fi
        if koopa_is_empty_dir "${dict2['prefix']}"
        then
            koopa_stop "'${dict2['prefix']}' is empty."
        fi
        dict2['prefix']="$(koopa_realpath "${dict2['prefix']}")"
        if [[ "${dict['build_only']}" -eq 1 ]]
        then
            koopa_alert "Activating '${dict2['prefix']}' (build only)."
        else
            koopa_alert "Activating '${dict2['prefix']}'."
        fi
        koopa_add_to_path_start "${dict2['prefix']}/bin"
        readarray -t pkgconfig_dirs <<< "$( \
            koopa_find \
                --pattern='pkgconfig' \
                --prefix="${dict2['prefix']}" \
                --sort \
                --type='d' \
            || true \
        )"
        if koopa_is_array_non_empty "${pkgconfig_dirs:-}"
        then
            koopa_add_to_pkg_config_path "${pkgconfig_dirs[@]}"
        fi
        [[ "${dict['build_only']}" -eq 1 ]] && continue
        if koopa_is_array_non_empty "${pkgconfig_dirs:-}"
        then
            if [[ ! -x "${app['pkg_config']}" ]]
            then
                koopa_stop "'pkg-config' is not installed."
            fi
            local pc_files
            readarray -t pc_files <<< "$( \
                koopa_find \
                    --prefix="${dict2['prefix']}" \
                    --type='f' \
                    --pattern='*.pc' \
                    --sort \
            )"
            dict2['cflags']="$( \
                "${app['pkg_config']}" --cflags "${pc_files[@]}" \
            )"
            dict2['ldflags']="$( \
                "${app['pkg_config']}" --libs-only-L "${pc_files[@]}" \
            )"
            dict2['ldlibs']="$( \
                "${app['pkg_config']}" --libs-only-l "${pc_files[@]}" \
            )"
            [[ -n "${dict2['cflags']}" ]] && \
                CPPFLAGS="${CPPFLAGS:-} ${dict2['cflags']}"
            [[ -n "${dict2['ldflags']}" ]] && \
                LDFLAGS="${LDFLAGS:-} ${dict2['ldflags']}"
            [[ -n "${dict2['ldlibs']}" ]] && \
                LDLIBS="${LDLIBS:-} ${dict2['ldlibs']}"
        else
            [[ -d "${dict2['prefix']}/include" ]] && \
                CPPFLAGS="${CPPFLAGS:-} -I${dict2['prefix']}/include"
            [[ -d "${dict2['prefix']}/lib" ]] && \
                LDFLAGS="${LDFLAGS:-} -L${dict2['prefix']}/lib"
            [[ -d "${dict2['prefix']}/lib64" ]] && \
                LDFLAGS="${LDFLAGS:-} -L${dict2['prefix']}/lib64"
        fi
        koopa_add_rpath_to_ldflags \
            "${dict2['prefix']}/lib" \
            "${dict2['prefix']}/lib64"
    done
    export CPPFLAGS LDFLAGS LDLIBS
    return 0
}

koopa_activate_ensembl_perl_api() {
    local dict
    declare -A dict=(
        ['prefix']="$(koopa_ensembl_perl_api_prefix)"
    )
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_add_to_path_start "${dict['prefix']}/ensembl-git-tools/bin"
    PERL5LIB="${PERL5LIB:-}"
    PERL5LIB="${PERL5LIB}:${dict['prefix']}/bioperl-1.6.924"
    PERL5LIB="${PERL5LIB}:${dict['prefix']}/ensembl/modules"
    PERL5LIB="${PERL5LIB}:${dict['prefix']}/ensembl-compara/modules"
    PERL5LIB="${PERL5LIB}:${dict['prefix']}/ensembl-variation/modules"
    PERL5LIB="${PERL5LIB}:${dict['prefix']}/ensembl-funcgen/modules"
    export PERL5LIB
    return 0
}

koopa_activate_pkg_config() {
    local app str
    koopa_assert_has_args "$#"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for app in "$@"
    do
        [[ -x "$app" ]] || continue
        str="$("$app" --variable 'pc_path' 'pkg-config')"
        PKG_CONFIG_PATH="$( \
            __koopa_add_to_path_string_start "$PKG_CONFIG_PATH" "$str" \
        )"
    done
    export PKG_CONFIG_PATH
    return 0
}

koopa_add_conda_env_to_path() {
    local bin_dir name
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'conda'
    [[ -z "${CONDA_PREFIX:-}" ]] || return 1
    for name in "$@"
    do
        bin_dir="${CONDA_PREFIX}/envs/${name}/bin"
        if [[ ! -d "$bin_dir" ]]
        then
            koopa_warn "Conda environment missing: '${bin_dir}'."
            return 1
        fi
        koopa_add_to_path_start "$bin_dir"
    done
    return 0
}

koopa_add_make_prefix_link() {
    local dict
    koopa_assert_has_args_le "$#" 1
    koopa_is_shared_install || return 0
    koopa_assert_is_admin
    declare -A dict=(
        ['koopa_prefix']="${1:-}"
        ['make_prefix']='/usr/local'
    )
    if [[ -z "${dict['koopa_prefix']}" ]]
    then
        dict['koopa_prefix']="$(koopa_koopa_prefix)"
    fi
    dict['source_link']="${dict['koopa_prefix']}/bin/koopa"
    dict['target_link']="${dict['make_prefix']}/bin/koopa"
    [[ -d "${dict['make_prefix']}" ]] || return 0
    [[ -L "${dict['target_link']}" ]] && return 0
    koopa_alert "Adding 'koopa' link inside '${dict['make_prefix']}'."
    koopa_ln --sudo "${dict['source_link']}" "${dict['target_link']}"
    return 0
}

koopa_add_monorepo_config_link() {
    local dict subdir
    koopa_assert_has_args "$#"
    koopa_assert_has_monorepo
    declare -A dict=(
        ['prefix']="$(koopa_monorepo_prefix)"
    )
    for subdir in "$@"
    do
        koopa_add_config_link \
            "${dict['prefix']}/${subdir}" \
            "$subdir"
    done
    return 0
}

koopa_add_rpath_to_ldflags() {
    local dir
    koopa_assert_has_args "$#"
    LDFLAGS="${LDFLAGS:-}"
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        LDFLAGS="${LDFLAGS} -Wl,-rpath,${dir}"
    done
    export LDFLAGS
    return 0
}

koopa_add_to_pkg_config_path() {
    local dir
    koopa_assert_has_args "$#"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        PKG_CONFIG_PATH="$( \
            __koopa_add_to_path_string_start "$PKG_CONFIG_PATH" "$dir" \
        )"
    done
    export PKG_CONFIG_PATH
    return 0
}

koopa_add_to_user_profile() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['file']="$(koopa_find_user_profile)"
    )
    koopa_alert "Adding koopa activation to '${dict['file']}'."
    read -r -d '' "dict[string]" << END || true
__koopa_activate_user_profile() {
    local script xdg_config_home
    [ "\$#" -eq 0 ] || return 1
    xdg_config_home="\${XDG_CONFIG_HOME:-}"
    if [ -z "\$xdg_config_home" ]
    then
        xdg_config_home="\${HOME:?}/.config"
    fi
    script="\${xdg_config_home}/koopa/activate"
    if [ -r "\$script" ]
    then
        . "\$script"
    fi
    return 0
}

__koopa_activate_user_profile
END
    koopa_append_string \
        --file="${dict['file']}" \
        --string="\n${dict['string']}"
    return 0
}

koopa_admin_group() {
    local group
    koopa_assert_has_no_args "$#"
    if koopa_is_alpine
    then
        group='wheel'
    elif koopa_is_arch
    then
        group='wheel'
    elif koopa_is_debian_like
    then
        group='sudo'
    elif koopa_is_fedora_like
    then
        group='wheel'
    elif koopa_is_macos
    then
        group='admin'
    elif koopa_is_opensuse
    then
        group='wheel'
    else
        koopa_stop 'Failed to determine admin group.'
    fi
    koopa_print "$group"
    return 0
}

koopa_alert_coffee_time() {
    koopa_alert_note 'This step takes a while. Time for a coffee break! ☕'
}

koopa_alert_configure_start() {
    __koopa_alert_process_start 'Configuring' "$@"
}

koopa_alert_configure_success() {
    __koopa_alert_process_success 'Configuration' "$@"
}

koopa_alert_info() {
    __koopa_msg 'cyan' 'default' 'ℹ︎' "$@"
    return 0
}

koopa_alert_install_start() {
    __koopa_alert_process_start 'Installing' "$@"
}

koopa_alert_install_success() {
    __koopa_alert_process_success 'Installation' "$@"
}

koopa_alert_is_installed() {
    local name prefix
    name="${1:?}"
    prefix="${2:-}"
    x="'${name}' is installed"
    if [[ -n "$prefix" ]]
    then
        x="${x} at '${prefix}'"
    fi
    x="${x}."
    koopa_alert_note "$x"
    return 0
}

koopa_alert_is_not_installed() {
    local name prefix
    name="${1:?}"
    prefix="${2:-}"
    x="'${name}' not installed"
    if [[ -n "$prefix" ]]
    then
        x="${x} at '${prefix}'"
    fi
    x="${x}."
    koopa_alert_note "$x"
    return 0
}

koopa_alert_note() {
    __koopa_msg 'yellow' 'default' '**' "$@"
}

koopa_alert_restart() {
    koopa_alert_note 'Restart the shell.'
}

koopa_alert_success() {
    __koopa_msg 'green-bold' 'green' '✓' "$@"
}

koopa_alert_uninstall_start() {
    __koopa_alert_process_start 'Uninstalling' "$@"
}

koopa_alert_uninstall_success() {
    __koopa_alert_process_success 'Uninstallation' "$@"
}

koopa_alert_update_start() {
    __koopa_alert_process_start 'Updating' "$@"
}

koopa_alert_update_success() {
    __koopa_alert_process_success 'Update' "$@"
}

koopa_alert() {
    __koopa_msg 'default' 'default' '→' "$@"
    return 0
}

koopa_app_json_bin() {
    local app_name
    koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        koopa_parse_app_json \
            --app-name="$app_name" \
            --key='bin'
    done
}

koopa_app_json_man1() {
    local app_name
    koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        koopa_parse_app_json \
            --app-name="$app_name" \
            --key='man1'
    done
}

koopa_app_json_revdeps() {
    local app_name
    koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        koopa_parse_app_json \
            --app-name="$app_name" \
            --key='reverse_dependencies'
    done
    return 0
}

koopa_app_json_version() {
    local app_name
    koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        koopa_parse_app_json \
            --app-name="$app_name" \
            --key='version'
    done
}

koopa_app_prefix() {
    local dict pos
    declare -A dict=(
        ['allow_missing']=0
        ['app_prefix']="$(koopa_koopa_prefix)/app"
    )
    if [[ "$#" -eq 0 ]]
    then
        koopa_print "${dict['app_prefix']}"
        return 0
    fi
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--allow-missing')
                dict['allow_missing']=1
                shift 1
                ;;
            '--'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    for app_name in "$@"
    do
        local dict2
        declare -A dict2
        dict2['app_name']="$app_name"
        dict2['version']="$( \
            koopa_app_json_version "${dict2['app_name']}" || true \
        )"
        if [[ -z "${dict2['version']}" ]]
        then
            koopa_stop "Unsupported app: '${dict2['app_name']}'."
        fi
        if [[ "${#dict2['version']}" == 40 ]]
        then
            dict2['version']="${dict2['version']:0:7}"
        fi
        dict2['prefix']="${dict['app_prefix']}/${dict2['app_name']}/\
${dict2['version']}"
        if [[ "${dict['allow_missing']}" -eq 0 ]]
        then
            koopa_assert_is_dir "${dict2['prefix']}"
        fi
        if [[ -d "${dict2['prefix']}" ]]
        then
            dict2['prefix']="$(koopa_realpath "${dict2['prefix']}")"
        fi
        koopa_print "${dict2['prefix']}"
    done
    return 0
}

koopa_app_version() {
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        ['name']="${1:?}"
        ['opt_prefix']="$(koopa_opt_prefix)"
    )
    dict['symlink']="${dict['opt_prefix']}/${dict['name']}"
    koopa_assert_is_symlink "${dict['symlink']}"
    dict['realpath']="$(koopa_realpath "${dict['symlink']}")"
    dict['version']="$(koopa_basename "${dict['realpath']}")"
    koopa_print "${dict['version']}"
    return 0
}

koopa_append_string() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['file']=''
        ['string']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--string' "${dict['string']}"
    if [[ ! -f "${dict['file']}" ]]
    then
        koopa_mkdir "$(koopa_dirname "${dict['file']}")"
        koopa_touch "${dict['file']}"
    fi
    koopa_print "${dict['string']}" >> "${dict['file']}"
    return 0
}

koopa_arch2() {
    local str
    koopa_assert_has_no_args "$#"
    case "$(koopa_arch)" in
        'aarch64')
            str='arm64'
            ;;
        'x86_64')
            str='amd64'
            ;;
        *)
            return 1
            ;;
    esac
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_assert_are_identical() {
    koopa_assert_has_args_eq "$#" 2
    if [[ "${1:?}" != "${2:?}" ]]
    then
        koopa_stop "'${1}' is not identical to '${2}'."
    fi
    return 0
}

koopa_assert_are_not_identical() {
    koopa_assert_has_args_eq "$#" 2
    if [[ "${1:?}" == "${2:?}" ]]
    then
        koopa_stop "'${1}' is identical to '${2}'."
    fi
    return 0
}

koopa_assert_has_args_eq() {
    if [[ "$#" -ne 2 ]]
    then
        koopa_stop '"koopa_assert_has_args_eq" requires 2 args.'
    fi
    if [[ "${1:?}" -ne "${2:?}" ]]
    then
        koopa_stop 'Invalid number of arguments.'
    fi
    return 0
}

koopa_assert_has_args_ge() {
    if [[ "$#" -ne 2 ]]
    then
        koopa_stop '"koopa_assert_has_args_ge" requires 2 args.'
    fi
    if [[ ! "${1:?}" -ge "${2:?}" ]]
    then
        koopa_stop 'Invalid number of arguments.'
    fi
    return 0
}

koopa_assert_has_args_le() {
    if [[ "$#" -ne 2 ]]
    then
        koopa_stop '"koopa_assert_has_args_le" requires 2 args.'
    fi
    if [[ ! "${1:?}" -le "${2:?}" ]]
    then
        koopa_stop 'Invalid number of arguments.'
    fi
    return 0
}

koopa_assert_has_args() {
    if [[ "$#" -ne 1 ]]
    then
        koopa_stop \
            '"koopa_assert_has_args" requires 1 arg.' \
            'Pass "$#" not "$@" to this function.'
    fi
    if [[ "${1:?}" -eq 0 ]]
    then
        koopa_stop 'Required arguments missing.'
    fi
    return 0
}

koopa_assert_has_file_ext() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa_has_file_ext "$arg"
        then
            koopa_stop "No file extension: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_has_monorepo() {
    koopa_assert_has_no_args "$#"
    if ! koopa_has_monorepo
    then
        koopa_stop "No monorepo at '$(koopa_monorepo_prefix)'."
    fi
    return 0
}

koopa_assert_has_no_args() {
    if [[ "$#" -ne 1 ]]
    then
        koopa_stop \
            '"koopa_assert_has_no_args" requires 1 arg.' \
            'Pass "$#" not "$@" to this function.'
    fi
    if [[ "${1:?}" -ne 0 ]]
    then
        koopa_stop "Arguments are not allowed (${1} detected)."
    fi
    return 0
}

koopa_assert_has_no_envs() {
    koopa_assert_has_no_args "$#"
    if ! koopa_has_no_environments
    then
        koopa_stop "\
Active environment detected.
       (conda and/or python venv)

Deactivate using:
    venv:  deactivate
    conda: conda deactivate

Deactivate venv prior to conda, otherwise conda python may be left in PATH."
    fi
    return 0
}

koopa_assert_has_no_flags() {
    while (("$#"))
    do
        case "$1" in
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                shift 1
                ;;
        esac
    done
    return 0
}

koopa_assert_is_aarch64() {
    koopa_assert_has_no_args "$#"
    if ! koopa_is_aarch64
    then
        koopa_stop 'Architecture is not aarch64 (ARM 64-bit).'
    fi
    return 0
}

koopa_assert_is_admin() {
    koopa_assert_has_no_args "$#"
    if ! koopa_is_admin
    then
        koopa_stop 'Administrator account is required.'
    fi
    return 0
}

koopa_assert_is_array_non_empty() {
    if ! koopa_is_array_non_empty "$@"
    then
        koopa_stop 'Array is empty.'
    fi
    return 0
}

koopa_assert_is_conda_active() {
    koopa_assert_has_no_args "$#"
    if ! koopa_is_conda_active
    then
        koopa_stop 'No active Conda environment detected.'
    fi
    return 0
}

koopa_assert_is_dir() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -d "$arg" ]]
        then
            koopa_stop "Not directory: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_executable() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -x "$arg" ]]
        then
            koopa_stop "Not executable: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_existing() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -e "$arg" ]]
        then
            koopa_stop "Does not exist: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_file_type() {
    koopa_assert_has_args "$#"
    if ! koopa_is_file_type "$@"
    then
        koopa_stop 'Input does not match expected file type extension.'
    fi
    return 0
}

koopa_assert_is_file() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -f "$arg" ]]
        then
            koopa_stop "Not file: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_function() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa_is_function "$arg"
        then
            koopa_stop "Not function: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_git_repo() {
    koopa_assert_has_no_args "$#"
    if ! koopa_is_git_repo
    then
        koopa_stop "Not a Git repo: '${PWD:?}'."
    fi
    return 0
}

koopa_assert_is_github_ssh_enabled() {
    if ! koopa_is_github_ssh_enabled
    then
        koopa_stop 'GitHub SSH access is not configured correctly.'
    fi
    return 0
}

koopa_assert_is_gitlab_ssh_enabled() {
    if ! koopa_is_gitlab_ssh_enabled
    then
        koopa_stop 'GitLab SSH access is not configured correctly.'
    fi
    return 0
}

koopa_assert_is_gnu() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa_is_gnu "$arg"
        then
            koopa_stop "GNU ${arg} is not installed."
        fi
    done
    return 0
}

koopa_assert_is_installed() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa_is_installed "$arg"
        then
            koopa_stop "Not installed: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_koopa_app() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa_is_koopa_app "$arg"
        then
            koopa_stop "Not koopa app: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_macos() {
    if ! koopa_is_macos
    then
        koopa_stop 'macOS is required.'
    fi
    return 0
}

koopa_assert_is_matching_fixed() {
    local dict
    declare -A dict=(
        ['pattern']=''
        ['string']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--pattern' "${dict['pattern']}" \
        '--string' "${dict['string']}"
    if ! koopa_str_detect_fixed \
        --pattern="${dict['pattern']}" \
        --string="${dict['string']}"
    then
        koopa_stop "'${dict['string']}' doesn't match '${dict['pattern']}'."
    fi
    return 0
}

koopa_assert_is_matching_regex() {
    declare -A dict=(
        ['pattern']=''
        ['string']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--pattern' "${dict['pattern']}" \
        '--string' "${dict['string']}"
    if ! koopa_str_detect_regex \
        --pattern="${dict['pattern']}" \
        --string="${dict['string']}"
    then
        koopa_stop "'${dict['string']}' doesn't match regular expression \
pattern '${dict['pattern']}'."
    fi
    return 0
}

koopa_assert_is_non_existing() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -e "$arg" ]]
        then
            koopa_stop "Exists: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_nonzero_file() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -s "$arg" ]]
        then
            koopa_stop "Not non-zero file: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_not_aarch64() {
    koopa_assert_has_no_args "$#"
    if koopa_is_aarch64
    then
        koopa_stop 'ARM (aarch64) is not supported.'
    fi
    return 0
}

koopa_assert_is_not_dir() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -d "$arg" ]]
        then
            koopa_stop "Directory exists: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_not_file() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -f "$arg" ]]
        then
            koopa_stop "File exists: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_not_installed() {
    local arg where
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if koopa_is_installed "$arg"
        then
            where="$(koopa_which_realpath "$arg")"
            koopa_stop "'${arg}' is already installed at '${where}'."
        fi
    done
    return 0
}

koopa_assert_is_not_root() {
    koopa_assert_has_no_args "$#"
    if koopa_is_root
    then
        koopa_stop 'root user detected.'
    fi
    return 0
}

koopa_assert_is_not_symlink() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -L "$arg" ]]
        then
            koopa_stop "Symlink exists: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_r_package_installed() {
    koopa_assert_has_args "$#"
    if ! koopa_is_r_package_installed "$@"
    then
        koopa_stop "Required R packages missing: ${*}."
    fi
    return 0
}

koopa_assert_is_readable() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -r "$arg" ]]
        then
            koopa_stop "Not readable: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_root() {
    koopa_assert_has_no_args "$#"
    if ! koopa_is_root
    then
        koopa_stop 'root user is required.'
    fi
    return 0
}

koopa_assert_is_set_2() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa_is_set "$arg"
        then
            koopa_stop "'${arg}' is unset."
        fi
    done
    return 0
}

koopa_assert_is_set() {
    local name value
    koopa_assert_has_args_ge "$#" 2
    while (("$#"))
    do
        name="${1:?}"
        value="${2:-}"
        shift 2
        if [[ -z "${value}" ]]
        then
            koopa_stop "'${name}' is unset."
        fi
    done
    return 0
}

koopa_assert_is_symlink() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -L "$arg" ]]
        then
            koopa_stop "Not symlink: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_writable() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -r "$arg" ]]
        then
            koopa_stop "Not writable: '${arg}'."
        fi
    done
    return 0
}

koopa_autopad_zeros() {
    local files newname num padwidth oldname pos prefix stem
    koopa_assert_has_args "$#"
    prefix='sample'
    padwidth=2
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--padwidth='*)
                padwidth="${1#*=}"
                shift 1
                ;;
            '--padwidth')
                padwidth="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                prefix="${1#*=}"
                shift 1
                ;;
            '--prefix')
                prefix="${2:?}"
                shift 2
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    files=("$@")
    if koopa_is_array_empty "${files[@]:-}"
    then
        koopa_stop 'No files.'
    fi
    for file in "${files[@]}"
    do
        if [[ "$file" =~ ^([0-9]+)(.*)$ ]]
        then
            oldname="${BASH_REMATCH[0]}"
            num=${BASH_REMATCH[1]}
            num=$(printf "%.${padwidth}d" "$num")
            stem=${BASH_REMATCH[2]}
            newname="${prefix}_${num}${stem}"
            koopa_mv "$oldname" "$newname"
        else
            koopa_alert_note "Skipping '${file}'."
        fi
    done
    return 0
}

koopa_aws_batch_fetch_and_run() {
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_set 'BATCH_FILE_URL' "${BATCH_FILE_URL:-}"
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['file']="$(koopa_tmp_file)"
        ['profile']="${AWS_PROFILE:-}"
        ['url']="${BATCH_FILE_URL:?}"
    )
    [[ -z "${dict['profile']}" ]] && dict['profile']='default'
    case "${dict['url']}" in
        'ftp://'* | \
        'http://'*)
            koopa_download "${dict['url']}" "${dict['file']}"
            ;;
        's3://'*)
            "${app['aws']}" --profile="${dict['profile']}" \
                s3 cp "${dict['url']}" "${dict['file']}"
            ;;
        *)
            koopa_stop "Unsupported URL: '${dict['url']}'."
            ;;
    esac
    koopa_chmod 'u+x' "${dict['file']}"
    "${dict['file']}"
    return 0
}

koopa_aws_batch_list_jobs() {
    local app dict job_queue_array status status_array
    local -A app=(
        ['aws']="$(koopa_locate_aws)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    local -A dict=(
        ['account_id']="${AWS_BATCH_ACCOUNT_ID:-}"
        ['profile']="${AWS_PROFILE:-}"
        ['queue']="${AWS_BATCH_QUEUE:-}"
        ['region']="${AWS_BATCH_REGION:-}"
    )
    [[ -z "${dict['profile']}" ]] && dict['profile']='default'
    while (("$#"))
    do
        case "$1" in
            '--account-id='*)
                dict['account_id']="${1#*=}"
                shift 1
                ;;
            '--account-id')
                dict['account_id']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--queue='*)
                dict['queue']="${1#*=}"
                shift 1
                ;;
            '--queue')
                dict['queue']="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--account-id or AWS_BATCH_ACCOUNT_ID' "${dict['account_id']:-}" \
        '--queue or AWS_BATCH_QUEUE' "${dict['queue']:-}" \
        '--region or AWS_BATCH_REGION' "${dict['region']:-}" \
        '--profile or AWS_PROFILE' "${dict['profile']:-}"
    koopa_h1 "Checking AWS Batch job status for '${dict['profile']}' profile."
    job_queue_array=(
        'arn'
        'aws'
        'batch'
        "${dict['region']}"
        "${dict['account_id']}"
        "job-queue/${dict['queue']}"
    )
    status_array=(
        'SUBMITTED'
        'PENDING'
        'RUNNABLE'
        'STARTING'
        'RUNNING'
        'SUCCEEDED'
        'FAILED'
    )
    dict['job_queue']="$(koopa_paste --sep=':' "${job_queue_array[@]}")"
    for status in "${status_array[@]}"
    do
        koopa_h2 "$status"
        "${app['aws']}" --profile="${dict['profile']}" \
            batch list-jobs \
                --job-queue "${dict['job_queue']}" \
                --job-status "$status"
    done
    return 0
}

koopa_aws_codecommit_list_repositories() {
    local app dict
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
        ['jq']="$(koopa_locate_jq)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['jq']}" ]] || return 1
    declare -A dict
    dict['string']="$( \
        "${app['aws']}" codecommit list-repositories \
            | "${app['jq']}" --raw-output '.repositories[].repositoryName' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}

koopa_aws_ec2_instance_id() {
    local app str
    declare -A app
    if koopa_is_ubuntu_like
    then
        app['ec2_metadata']='/usr/bin/ec2metadata'
    else
        app['ec2_metadata']='/usr/bin/ec2-metadata'
    fi
    [[ -x "${app['ec2_metadata']}" ]] || return 1
    str="$("${app['ec2_metadata']}" --instance-id)"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_aws_ec2_suspend() {
    local app dict
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['id']="$(koopa_aws_ec2_instance_id)"
        ['profile']="${AWS_PROFILE:-}"
    )
    [[ -z "${dict['profile']}" ]] && dict['profile']='default'
    while (("$#"))
    do
        case "$1" in
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--profile or AWS_PROFILE' "${dict['profile']:-}"
    koopa_alert "Suspending EC2 instance '${dict['id']}'."
    "${app['aws']}" --profile="${dict['profile']}" \
        ec2 stop-instances --instance-id "${dict['id']}" \
        >/dev/null
    return 0
}

koopa_aws_ec2_terminate() {
    local app dict
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['id']="$(koopa_aws_ec2_instance_id)"
        ['profile']="${AWS_PROFILE:-}"
    )
    [[ -z "${dict['profile']}" ]] && dict['profile']='default'
    while (("$#"))
    do
        case "$1" in
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--profile or AWS_PROFILE' "${dict['profile']:-}"
    "${app['aws']}" --profile="${dict['profile']}" \
        ec2 terminate-instances --instance-id "${dict['id']}" \
        >/dev/null
    return 0
}

koopa_aws_s3_cp_regex() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['bucket_pattern']='^s3://.+/$'
        ['pattern']=''
        ['profile']="${AWS_PROFILE:-}"
        ['source_prefix']=''
        ['target_prefix']=''
    )
    [[ -z "${dict['profile']}" ]] && dict['profile']='default'
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--source_prefix='*)
                dict['source_prefix']="${1#*=}"
                shift 1
                ;;
            '--source_prefix')
                dict['source_prefix']="${2:?}"
                shift 2
                ;;
            '--target_prefix='*)
                dict['target_prefix']="${1#*=}"
                shift 1
                ;;
            '--target_prefix')
                dict['target_prefix']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--pattern' "${dict['pattern']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--source-prefix' "${dict['source_prefix']}" \
        '--target-prefix' "${dict['target_prefix']}"
    if ! koopa_str_detect_regex \
            --pattern="${dict['bucket_pattern']}" \
            --string "${dict['source_prefix']}" &&
        ! koopa_str_detect_regex \
            --pattern="${dict['bucket_pattern']}" \
            --string "${dict['target_prefix']}"
    then
        koopa_stop "Souce and or/target must match '${dict['bucket_pattern']}'."
    fi
    "${app['aws']}" --profile="${dict['profile']}" \
        s3 cp \
            --exclude='*' \
            --follow-symlinks \
            --include="${dict['pattern']}" \
            --recursive \
            "${dict['source_prefix']}" \
            "${dict['target_prefix']}"
    return 0
}

koopa_aws_s3_delete_versioned_glacier_objects() {
    local app dict i keys version_ids
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
        ['jq']="$(koopa_locate_jq)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['jq']}" ]] || return 1
    declare -A dict=(
        ['bucket']=''
        ['profile']="${AWS_PROFILE:-default}"
        ['region']="${AWS_REGION:-us-east-1}"
    )
    while (("$#"))
    do
        case "$1" in
            '--bucket='*)
                dict['bucket']="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict['bucket']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bucket' "${dict['bucket']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--region or AWS_REGION' "${dict['region']}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['bucket']}"
    dict['bucket']="$( \
        koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict['bucket']}" \
    )"
    dict['bucket']="$(koopa_strip_trailing_slash "${dict['bucket']}")"
    dict['json']="$( \
        "${app['aws']}" s3api list-object-versions \
            --bucket "${dict['bucket']}" \
            --output 'json' \
            --profile "${dict['profile']}" \
            --query "Versions[?StorageClass=='GLACIER']" \
            --region "${dict['region']}" \
    )"
    if [[ -z "${dict['json']}" ]] || [[ "${dict['json']}" == '[]' ]]
    then
        koopa_stop "No versioned Glacier objects found in '${dict['bucket']}'."
    fi
    koopa_alert "Deleting versioned Glacier objects in '${dict['bucket']}'."
    readarray -t keys <<< "$( \
        koopa_print "${dict['json']}" \
            | "${app['jq']}" --raw-output '.[].Key' \
    )"
    readarray -t version_ids <<< "$( \
        koopa_print "${dict['json']}" \
            | "${app['jq']}" --raw-output '.[].VersionId' \
    )"
    for i in "${!keys[@]}"
    do
        local dict2
        declare -A dict2=(
            ['key']="${keys[$i]}"
            ['version_id']="${version_ids[$i]}"
        )
        koopa_alert "Deleting '${dict2['key']}' (${dict2['version_id']})."
        "${app['aws']}" --profile "${dict['profile']}" \
            s3api delete-object \
                --bucket "${dict['bucket']}" \
                --key "${dict2['key']}" \
                --region "${dict['region']}" \
                --version-id "${dict2['version_id']}" \
            > /dev/null
    done
    return 0
}

koopa_aws_s3_find() {
    local dict exclude_arr include_arr ls_args pattern str
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['exclude']=0
        ['include']=0
        ['prefix']=''
        ['profile']="${AWS_PROFILE:-}"
        ['recursive']=0
    )
    [[ -z "${dict['profile']}" ]] && dict['profile']='default'
    exclude_arr=()
    include_arr=()
    while (("$#"))
    do
        case "$1" in
            '--exclude='*)
                dict['exclude']=1
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                dict['exclude']=1
                exclude_arr+=("${2:?}")
                shift 2
                ;;
            '--include='*)
                dict['include']=1
                include_arr+=("${1#*=}")
                shift 1
                ;;
            '--include')
                dict['include']=1
                include_arr+=("${2:?}")
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
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--recursive')
                dict['recursive']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['prefix']}"
    ls_args=(
        '--prefix' "${dict['prefix']}"
        '--profile' "${dict['profile']}"
        '--type' 'f'
    )
    [[ "${dict['recursive']}" -eq 1 ]] && ls_args+=('--recursive')
    str="$(koopa_aws_s3_ls "${ls_args[@]}")"
    [[ -n "$str" ]] || return 1
    if [[ "${dict['exclude']}" -eq 1 ]]
    then
        for pattern in "${exclude_arr[@]}"
        do
            if koopa_str_detect_regex \
                --pattern='^\^' \
                --string="$pattern"
            then
                pattern="$( \
                    koopa_sub \
                        --pattern='^\^' \
                        --replacement='' \
                        "$pattern" \
                )"
                pattern="${dict['prefix']}${pattern}"
            fi
            str="$( \
                koopa_grep \
                    --invert-match \
                    --pattern="$pattern" \
                    --regex \
                    --string="$str" \
            )"
            [[ -n "$str" ]] || return 1
        done
    fi
    if [[ "${dict['include']}" -eq 1 ]]
    then
        for pattern in "${include_arr[@]}"
        do
            if koopa_str_detect_regex \
                --pattern='^\^' \
                --string="$pattern"
            then
                pattern="$( \
                    koopa_sub \
                        --pattern='^\^' \
                        --replacement='' \
                        "$pattern" \
                )"
                pattern="${dict['prefix']}${pattern}"
            fi
            str="$( \
                koopa_grep \
                    --pattern="$pattern" \
                    --regex \
                    --string="$str" \
            )"
            [[ -n "$str" ]] || return 1
        done
    fi
    koopa_print "$str"
    return 0
}

koopa_aws_s3_list_large_files() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
        ['aws']="$(koopa_locate_aws)"
        ['jq']="$(koopa_locate_jq)"
        ['sort']="$(koopa_locate_sort)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['jq']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    declare -A dict=(
        ['bucket']=''
        ['num']='20'
        ['profile']="${AWS_PROFILE:-default}"
        ['region']="${AWS_REGION:-us-east-1}"
    )
    while (("$#"))
    do
        case "$1" in
            '--bucket='*)
                dict['bucket']="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict['bucket']="${2:?}"
                shift 2
                ;;
            '--num='*)
                dict['num']="${1#*=}"
                shift 1
                ;;
            '--num')
                dict['num']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bucket' "${dict['bucket']}" \
        '--num' "${dict['num']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--region or AWS_REGION' "${dict['region']}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['bucket']}"
    dict['bucket']="$( \
        koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict['bucket']}" \
    )"
    dict['bucket']="$(koopa_strip_trailing_slash "${dict['bucket']}")"
    dict['awk_string']="NR<=${dict['num']} {print \$1}"
    dict['str']="$( \
        "${app['aws']}" --profile="${dict['profile']}" \
            s3api list-object-versions \
                --bucket "${dict['bucket']}" \
                --region "${dict['region']}" \
            | "${app['jq']}" \
                --raw-output \
                '.Versions[] | "\(.Key)\t \(.Size)"' \
            | "${app['sort']}" --key=2 --numeric-sort --reverse \
            | "${app['awk']}" "${dict['awk_string']}" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_aws_s3_ls() {
    local app dict ls_args str
    koopa_assert_has_args "$#"
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
        ['aws']="$(koopa_locate_aws)"
        ['sed']="$(koopa_locate_sed)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict=(
        ['prefix']=''
        ['profile']="${AWS_PROFILE:-}"
        ['recursive']=0
        ['type']=''
    )
    [[ -z "${dict['profile']}" ]] && dict['profile']='default'
    ls_args=()
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--type='*)
                dict['type']="${1#*=}"
                shift 1
                ;;
            '--type')
                dict['type']="${2:?}"
                shift 2
                ;;
            '--recursive')
                dict['recursive']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['prefix']}"
    case "${dict['type']}" in
        '')
            dict['dirs']=1
            dict['files']=1
            ;;
        'd')
            dict['dirs']=1
            dict['files']=0
            ;;
        'f')
            dict['dirs']=0
            dict['files']=1
            ;;
        *)
            koopa_stop "Unsupported type: '${dict['type']}'."
            ;;
    esac
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        ls_args+=('--recursive')
        if [[ "${dict['type']}" == 'd' ]]
        then
            koopa_stop 'Recursive directory listing is not supported.'
        fi
    fi
    str="$( \
        "${app['aws']}" --profile="${dict['profile']}" \
            s3 ls "${ls_args[@]}" "${dict['prefix']}" \
            2>/dev/null \
    )"
    [[ -n "$str" ]] || return 1
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        dict['bucket_prefix']="$( \
            koopa_grep \
                --only-matching \
                --pattern='^s3://[^/]+' \
                --regex \
                --string="${dict['prefix']}" \
        )"
        files="$( \
            koopa_grep \
                --pattern='^[0-9]{4}-[0-9]{2}-[0-9]{2}' \
                --regex \
                --string="$str" \
            || true \
        )"
        [[ -n "$files" ]] || return 0
        files="$( \
            koopa_print "$files" \
                | "${app['awk']}" '{print $4}' \
                | "${app['awk']}" 'NF' \
                | "${app['sed']}" "s|^|${dict['bucket_prefix']}/|g" \
                | koopa_grep --pattern='^s3://.+[^/]$' --regex \
        )"
        koopa_print "$files"
        return 0
    fi
    if [[ "${dict['dirs']}" -eq 1 ]]
    then
        dirs="$( \
            koopa_grep \
                --only-matching \
                --pattern='^\s+PRE\s.+/$' \
                --regex \
                --string="$str" \
            || true \
        )"
        if [[ -n "$dirs" ]]
        then
            dirs="$( \
                koopa_print "$dirs" \
                    | "${app['sed']}" 's|^ \+PRE ||g' \
                    | "${app['awk']}" 'NF' \
                    | "${app['sed']}" "s|^|${dict['prefix']}|g" \
            )"
            koopa_print "$dirs"
        fi
    fi
    if [[ "${dict['files']}" -eq 1 ]]
    then
        files="$( \
            koopa_grep \
                --pattern='^[0-9]{4}-[0-9]{2}-[0-9]{2}' \
                --regex \
                --string="$str" \
            || true \
        )"
        if [[ -n "$files" ]]
        then
            files="$( \
                koopa_print "$files" \
                    | "${app['awk']}" '{print $4}' \
                    | "${app['awk']}" 'NF' \
                    | "${app['sed']}" "s|^|${dict['prefix']}|g" \
            )"
            koopa_print "$files"
        fi
    fi
    return 0
}

koopa_aws_s3_mv_to_parent() {
    local app dict
    local file files prefix
    koopa_assert_has_args "$#"
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['prefix']=''
        ['profile']="${AWS_PROFILE:-}"
    )
    [[ -z "${dict['profile']}" ]] && dict['profile']='default'
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--profile or AWS_PROFILE' "${dict['profile']:-}"
        '--prefix' "${dict['prefix']:-}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['prefix']}"
    dict['str']="$( \
        koopa_aws_s3_ls \
            --prefix="${dict['prefix']}" \
            --profile="${dict['profile']}" \
    )"
    if [[ -z "${dict['str']}" ]]
    then
        koopa_stop "No content detected in '${dict['prefix']}'."
    fi
    readarray -t files <<< "${dict['str']}"
    for file in "${files[@]}"
    do
        local dict2
        declare -A dict2=(
            ['bn']="$(koopa_basename "$file")"
            ['dn1']="$(koopa_dirname "$file")"
        )
        dict2['dn2']="$(koopa_dirname "${dict2['dn1']}")"
        dict2['target']="${dict2['dn2']}/${dict2['bn']}"
        "${app['aws']}" --profile="${dict['profile']}" \
            s3 mv \
                --recursive \
                "${dict2['file']}" \
                "${dict2['target']}"
    done
    return 0
}

koopa_aws_s3_sync() {
    local aws dict exclude_args exclude_patterns pattern pos sync_args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['profile']="${AWS_PROFILE:-}"
    )
    [[ -z "${dict['profile']}" ]] && dict['profile']='default'
    exclude_patterns=(
        '*.Rproj/*'
        '*.swp'
        '*.tmp'
        '.*'
        '.DS_Store'
        '.Rproj.user/*'
        '._*'
        '.git/*'
    )
    pos=()
    sync_args=()
    while (("$#"))
    do
        case "$1" in
            '--exclude='*)
                exclude_patterns+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                exclude_patterns+=("${2:?}")
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--source-prefix='*)
                dict['source_prefix']="${1#*=}"
                shift 1
                ;;
            '--source-prefix')
                dict['source_prefix']="${2:?}"
                shift 2
                ;;
            '--target-prefix='*)
                dict['target_prefix']="${1#*=}"
                shift 1
                ;;
            '--target-prefix')
                dict['target_prefix']="${2:?}"
                shift 2
                ;;
            '--delete' | \
            '--dryrun' | \
            '--exact-timestamps' | \
            '--follow-symlinks' | \
            '--no-follow-symlinks' | \
            '--no-progress' | \
            '--only-show-errors' | \
            '--size-only' | \
            '--quiet')
                sync_args+=("$1")
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -gt 0 ]]
    then
        koopa_assert_has_args_eq "$#" 2
        koopa_assert_has_no_flags "$@"
        sync_args+=("$@")
    else
        sync_args+=(
            "${dict['source_prefix']}"
            "${dict['target_prefix']}"
        )
    fi
    exclude_args=()
    for pattern in "${exclude_patterns[@]}"
    do
        exclude_args+=(
            "--exclude=${pattern}"
            "--exclude=*/${pattern}"
        )
    done
    "${app['aws']}" --profile="${dict['profile']}" \
        s3 sync \
            "${exclude_args[@]}" \
            "${sync_args[@]}"
    return 0
}

koopa_basename_sans_ext_2() {
    local app file str
    koopa_assert_has_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    for file in "$@"
    do
        str="$(koopa_basename "$file")"
        if koopa_has_file_ext "$str"
        then
            str="$( \
                koopa_print "$str" \
                | "${app['cut']}" -d '.' -f '1' \
            )"
        fi
        koopa_print "$str"
    done
    return 0
}

koopa_basename_sans_ext() {
    local file str
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        str="$(koopa_basename "$file")"
        if koopa_has_file_ext "$str"
        then
            str="${str%.*}"
        fi
        koopa_print "$str"
    done
    return 0
}

koopa_basename() {
    local arg
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for arg in "$@"
    do
        [[ -n "$arg" ]] || return 1
        arg="${arg%%+(/)}"
        arg="${arg##*/}"
        koopa_print "$arg"
    done
    return 0
}

koopa_bioconda_autobump_recipe() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
        ['vim']="$(koopa_locate_vim --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['vim']}" ]] || return 1
    declare -A dict=(
        ['recipe']="${1:?}"
        ['repo']="${HOME:?}/git/github/bioconda/bioconda-recipes"
    )
    dict['branch']="${dict['recipe']/-/_}"
    koopa_assert_is_dir "${dict['repo']}"
    (
        koopa_cd "${dict['repo']}"
        "${app['git']}" checkout master
        "${app['git']}" fetch --all
        "${app['git']}" pull
        "${app['git']}" checkout \
            -B "${dict['branch']}" \
            "origin/bump/${dict['branch']}"
        "${app['git']}" pull origin master
        koopa_mkdir "recipes/${dict['recipe']}"
        "${app['vim']}" "recipes/${dict['recipe']}/meta.yaml"
    )
    return 0
}

koopa_bowtie2_align_per_sample() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['bowtie2']="$(koopa_locate_bowtie2)"
        ['tee']="$(koopa_locate_tee)"
    )
    [[ -x "${app['bowtie2']}" ]] || return 1
    [[ -x "${app['tee']}" ]] || return 1
    declare -A dict=(
        ['fastq_r1_file']=''
        ['fastq_r1_tail']=''
        ['fastq_r2_file']=''
        ['fastq_r2_tail']=''
        ['index_dir']=''
        ['output_dir']=''
        ['threads']="$(koopa_cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--fastq-r2-tail' "${dict['fastq_r2_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
    dict['fastq_r1_file']="$(koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="${dict['fastq_r1_bn']/${dict['fastq_r1_tail']}/}"
    dict['fastq_r2_file']="$(koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="$(koopa_basename "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="${dict['fastq_r2_bn']/${dict['fastq_r2_tail']}/}"
    koopa_assert_are_identical "${dict['fastq_r1_bn']}" "${dict['fastq_r2_bn']}"
    dict['id']="${dict['fastq_r1_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Aligning '${dict['id']}' in '${dict['output_dir']}'."
    dict['index_base']="${dict['index_dir']}/bowtie2"
    dict['sam_file']="${dict['output_dir']}/${dict['id']}.sam"
    dict['log_file']="${dict['output_dir']}/align.log"
    align_args=(
        '--local'
        '--sensitive-local'
        '--rg-id' "${dict['id']}"
        '--rg' 'PL:illumina'
        '--rg' "PU:${dict['id']}"
        '--rg' "SM:${dict['id']}"
        '--threads' "${dict['threads']}"
        '-1' "${dict['fastq_r1_file']}"
        '-2' "${dict['fastq_r2_file']}"
        '-S' "${dict['sam_file']}"
        '-X' 2000
        '-q'
        '-x' "${dict['index_base']}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['bowtie2']}" "${align_args[@]}" \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}

koopa_bowtie2_align() {
    local dict fastq_r1_file fastq_r1_files
    declare -A dict=(
        ['fastq_dir']=''
        ['fastq_r1_tail']=''
        ['fastq_r2_tail']=''
        ['index_dir']=''
        ['output_dir']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--fastq-r2-tail' "${dict['fastq_r2_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running bowtie2 align.'
    koopa_dl \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_r1_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local fastq_r2_file
        fastq_r2_file="${fastq_r1_file/\
${dict['fastq_r1_tail']}/${dict['fastq_r2_tail']}}"
        koopa_bowtie2_align_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict['fastq_r1_tail']}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict['fastq_r2_tail']}" \
            --index-dir="${dict['index_dir']}" \
            --output-dir="${dict['samples_dir']}"
    done
    koopa_alert_success 'bowtie2 align was successful.'
    return 0
}

koopa_bowtie2_index() {
    local app dict index_args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['bowtie2_build']="$(koopa_locate_bowtie2_build)"
        ['tee']="$(koopa_locate_tee)"
    )
    [[ -x "${app['bowtie2_build']}" ]] || return 1
    [[ -x "${app['tee']}" ]] || return 1
    declare -A dict=(
        ['genome_fasta_file']=''
        ['output_dir']=''
        ['threads']="$(koopa_cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_file "${dict['genome_fasta_file']}"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Generating bowtie2 index at '${dict['output_dir']}'."
    dict['index_base']="${dict['output_dir']}/bowtie2"
    dict['log_file']="${dict['output_dir']}/index.log"
    index_args=(
        "--threads=${dict['threads']}"
        '--verbose'
        "${dict['genome_fasta_file']}"
        "${dict['index_base']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app['bowtie2_build']}" "${index_args[@]}" \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}

koopa_brew_cleanup() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['brew']="$(koopa_locate_brew)"
    )
    [[ -x "${app['brew']}" ]] || return 1
    "${app['brew']}" cleanup -s || true
    koopa_rm "$("${app['brew']}" --cache)"
    "${app['brew']}" autoremove || true
    return 0
}

koopa_brew_dump_brewfile() {
    local app today
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['brew']="$(koopa_locate_brew)"
    )
    [[ -x "${app['brew']}" ]] || return 1
    today="$(koopa_today)"
    "${app['brew']}" bundle dump \
        --file="brewfile-${today}" \
        --force
    return 0
}

koopa_brew_outdated() {
    local app x
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['brew']="$(koopa_locate_brew)"
    )
    [[ -x "${app['brew']}" ]] || return 1
    x="$("${app['brew']}" outdated --quiet)"
    koopa_print "$x"
    return 0
}

koopa_brew_reset_core_repo() {
    local app branch origin prefix repo
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['brew']="$(koopa_locate_brew)"
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['brew']}" ]] || return 1
    [[ -x "${app['git']}" ]] || return 1
    repo='homebrew/core'
    origin='origin'
    (
        prefix="$("${app['brew']}" --repo "$repo")"
        koopa_assert_is_dir "$prefix"
        koopa_cd "$prefix"
        branch="$(koopa_git_default_branch)"
        "${app['git']}" checkout -q "$branch"
        "${app['git']}" branch -q "$branch" -u "${origin}/${branch}"
        "${app['git']}" reset -q --hard "${origin}/${branch}"
        "${app['git']}" branch -vv
    )
    return 0
}

koopa_brew_reset_permissions() {
    local group prefix user
    koopa_assert_has_no_args "$#"
    user="$(koopa_user)"
    group="$(koopa_admin_group)"
    prefix="$(koopa_homebrew_prefix)"
    koopa_alert "Resetting ownership of files in \
'${prefix}' to '${user}:${group}'."
    koopa_chown \
        --no-dereference \
        --recursive \
        --sudo \
        "${user}:${group}" \
        "${prefix}/"*
    return 0
}

koopa_brew_uninstall_all_brews() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['brew']="$(koopa_locate_brew)"
        ['wc']="$(koopa_locate_wc)"
    )
    [[ -x "${app['brew']}" ]] || return 1
    [[ -x "${app['wc']}" ]] || return 1
    while [[ "$("${app['brew']}" list --formulae | "${app['wc']}" -l)" -gt 0 ]]
    do
        local brews
        readarray -t brews <<< "$("${app['brew']}" list --formulae)"
        "${app['brew']}" uninstall \
            --force \
            --ignore-dependencies \
            "${brews[@]}"
    done
    return 0
}

koopa_brew_upgrade_brews() {
    local app brew brews
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['brew']="$(koopa_locate_brew)"
    )
    [[ -x "${app['brew']}" ]] || return 1
    readarray -t brews <<< "$(koopa_brew_outdated)"
    koopa_is_array_non_empty "${brews[@]:-}" || return 0
    koopa_dl \
        "$(koopa_ngettext \
            --num="${#brews[@]}" \
            --middle=' outdated ' \
            --msg1='brew' \
            --msg2='brews' \
        )" \
        "$(koopa_to_string "${brews[@]}")"
    for brew in "${brews[@]}"
    do
        "${app['brew']}" reinstall --force "$brew" || true
        if koopa_is_macos
        then
            case "$brew" in
                'gcc' | \
                'gpg' | \
                'python@3.9' | \
                'vim')
                    "${app['brew']}" link --overwrite "$brew" || true
                    ;;
            esac
        fi
    done
    return 0
}

koopa_brew_version() {
    local app brew
    koopa_assert_has_args "$#"
    declare -A app=(
        ['brew']="$(koopa_locate_brew)"
        ['jq']="$(koopa_locate_jq)"
    )
    [[ -x "${app['brew']}" ]] || return 1
    [[ -x "${app['jq']}" ]] || return 1
    for brew in "$@"
    do
        local str
        str="$( \
            "${app['brew']}" info --json "$brew" \
                | "${app['jq']}" --raw-output '.[].versions.stable'
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}

koopa_cache_functions_dir() {
    local app prefix
    koopa_assert_has_args "$#"
    declare -A app=(
        ['grep']="$(koopa_locate_grep --allow-system)"
        ['perl']="$(koopa_locate_perl --allow-system)"
    )
    [[ -x "${app['grep']}" ]] || return 1
    [[ -x "${app['perl']}" ]] || return 1
    for prefix in "$@"
    do
        local dict file files header
        declare -A dict
        dict['prefix']="$prefix"
        koopa_assert_is_dir "${dict['prefix']}"
        dict['target_file']="${dict['prefix']}.sh"
        koopa_alert "Caching functions at '${dict['prefix']}' \
in '${dict['target_file']}'."
        readarray -t files <<< "$( \
            koopa_find \
                --pattern='*.sh' \
                --prefix="${dict['prefix']}" \
                --sort \
        )"
        koopa_assert_is_array_non_empty "${files[@]:-}"
        header=()
        if koopa_str_detect_fixed \
            --pattern='/bash/' \
            --string="${dict['prefix']}"
        then
            header+=('#!/usr/bin/env bash')
        else
            header+=('#!/bin/sh')
        fi
        header+=('# shellcheck disable=all')
        dict['header_string']="$(printf '%s\n' "${header[@]}")"
        koopa_write_string \
            --file="${dict['target_file']}" \
            --string="${dict['header_string']}"
        for file in "${files[@]}"
        do
            "${app['grep']}" -Eiv '^(\s+)?#' "$file" \
            >> "${dict['target_file']}"
        done
        dict['tmp_target_file']="${dict['target_file']}.tmp"
        "${app['perl']}" \
            -0pe 's/\n\n\n+/\n\n/g' \
            "${dict['target_file']}" \
            > "${dict['tmp_target_file']}"
        koopa_mv \
            "${dict['tmp_target_file']}" \
            "${dict['target_file']}"
    done
    return 0
}

koopa_cache_functions() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['koopa_prefix']="$(koopa_koopa_prefix)"
    )
    dict['shell_prefix']="${dict['koopa_prefix']}/lang/shell"
    koopa_cache_functions_dir \
        "${dict['shell_prefix']}/bash/functions/activate" \
        "${dict['shell_prefix']}/bash/functions/common" \
        "${dict['shell_prefix']}/bash/functions/os/linux/alpine" \
        "${dict['shell_prefix']}/bash/functions/os/linux/arch" \
        "${dict['shell_prefix']}/bash/functions/os/linux/common" \
        "${dict['shell_prefix']}/bash/functions/os/linux/debian" \
        "${dict['shell_prefix']}/bash/functions/os/linux/fedora" \
        "${dict['shell_prefix']}/bash/functions/os/linux/opensuse" \
        "${dict['shell_prefix']}/bash/functions/os/linux/rhel" \
        "${dict['shell_prefix']}/bash/functions/os/macos" \
        "${dict['shell_prefix']}/posix/functions"
    return 0
}

koopa_camel_case_simple() {
    local str
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        [[ -n "$str" ]] || return 1
        str="$( \
            koopa_gsub \
                --pattern='([ -_])([a-z])' \
                --regex \
                --replacement='\U\2' \
                "$str" \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}

koopa_camel_case() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliCamelCase' "$@"
}

koopa_can_install_binary() {
    [[ -n "${KOOPA_AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" ]]
}

koopa_capitalize() {
    local app str
    declare -A app
    app['tr']="$(koopa_locate_tr --allow-system)"
    [[ -x "${app['tr']}" ]] || return 1
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        [[ -n "$str" ]] || return 1
        str="$("${app['tr']}" '[:lower:]' '[:upper:]' <<< "${str:0:1}")${str:1}"
        koopa_print "$str"
    done
    return 0
}

koopa_cd() {
    local prefix
    koopa_assert_has_args_eq "$#" 1
    prefix="${1:?}"
    cd "$prefix" >/dev/null 2>&1 || return 1
    return 0
}

koopa_check_access_human() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['file']="${1:?}"
        ['code']="${2:?}"
    )
    if [[ ! -e "${dict['file']}" ]]
    then
        koopa_warn "'${dict['file']}' does not exist."
        return 1
    fi
    dict['access']="$(koopa_stat_access_human "${dict['file']}")"
    if [[ "${dict['access']}" != "${dict['code']}" ]]
    then
        koopa_warn "'${dict['file']}' current access '${dict['access']}' \
is not '${dict['code']}'."
        return 1
    fi
    return 0
}

koopa_check_access_octal() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['file']="${1:?}"
        ['code']="${2:?}"
    )
    if [[ ! -e "${dict['file']}" ]]
    then
        koopa_warn "'${dict['file']}' does not exist."
        return 1
    fi
    dict['access']="$(koopa_stat_access_octal "${dict['file']}")"
    if [[ "${dict['access']}" != "${dict['code']}" ]]
    then
        koopa_warn "'${dict['file']}' current access '${dict['access']}' \
is not '${dict['code']}'."
        return 1
    fi
    return 0
}

koopa_check_disk() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['limit']=90
        ['used']="$(koopa_disk_pct_used "$@")"
    )
    if [[ "${dict['used']}" -gt "${dict['limit']}" ]]
    then
        koopa_warn "Disk usage is ${dict['used']}%."
        return 1
    fi
    return 0
}

koopa_check_exports() {
    local vars
    koopa_assert_has_no_args "$#"
    koopa_is_rstudio && return 0
    vars=(
        'JAVA_HOME'
        'LD_LIBRARY_PATH'
        'PYTHONHOME'
        'R_HOME'
    )
    koopa_warn_if_export "${vars[@]}"
    return 0
}

koopa_check_group() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['file']="${1:?}"
        ['code']="${2:?}"
    )
    if [[ ! -e "${dict['file']}" ]]
    then
        koopa_warn "'${dict['file']}' does not exist."
        return 1
    fi
    dict['group']="$(koopa_stat_group "${dict['file']}")"
    if [[ "${dict['group']}" != "${dict['code']}" ]]
    then
        koopa_warn "'${dict['file']}' current group '${dict['group']}' \
is not '${dict['code']}'."
        return 1
    fi
    return 0
}

koopa_check_mount() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['wc']="$(koopa_locate_wc)"
    )
    declare -A dict=(
        ['prefix']="${1:?}"
    )
    if [[ ! -r "${dict['prefix']}" ]] || [[ ! -d "${dict['prefix']}" ]]
    then
        koopa_warn "'${dict['prefix']}' is not a readable directory."
        return 1
    fi
    dict['nfiles']="$( \
        koopa_find \
            --prefix="${dict['prefix']}" \
            --min-depth=1 \
            --max-depth=1 \
        | "${app['wc']}" -l \
    )"
    if [[ "${dict['nfiles']}" -eq 0 ]]
    then
        koopa_warn "'${dict['prefix']}' is unmounted and/or empty."
        return 1
    fi
    return 0
}

koopa_check_shared_object() {
    local app dict tool_args
    koopa_assert_has_args "$#"
    declare -A app
    declare -A dict=(
        ['file']=''
        ['name']=''
        ['prefix']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
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
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -z "${dict['file']}" ]]
    then
        koopa_assert_is_set \
            '--name' "${dict['name']}" \
            '--prefix' "${dict['prefix']}"
        if koopa_is_linux
        then
            dict['shared_ext']='so'
        elif koopa_is_macos
        then
            dict['shared_ext']='dylib'
        fi
        dict['file']="${dict['prefix']}/${dict['name']}.${dict['shared_ext']}"
    fi
    koopa_assert_is_file "${dict['file']}"
    tool_args=()
    if koopa_is_linux
    then
        app['tool']="$(koopa_linux_locate_ldd)"
    elif koopa_is_macos
    then
        app['tool']="$(koopa_macos_locate_otool)"
        tool_args+=('-L')
    fi
    [[ -x "${app['tool']}" ]] || return 1
    tool_args+=("${dict['file']}")
    "${app['tool']}" "${tool_args[@]}"
    return 0
}

koopa_check_system() {
    koopa_assert_has_no_args "$#"
    koopa_check_exports || return 1
    koopa_check_disk '/' || return 1
    if ! koopa_is_r_package_installed 'koopa'
    then
        koopa_install_r_koopa
    fi
    koopa_r_koopa 'cliCheckSystem'
    koopa_alert_success 'System passed all checks.'
    return 0
}

koopa_check_user() {
    local dict
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        ['file']="${1:?}"
        ['expected_user']="${2:?}"
    )
    if [[ ! -e "${dict['file']}" ]]
    then
        koopa_warn "'${dict['file']}' does not exist on disk."
        return 1
    fi
    dict['file']="$(koopa_realpath "${dict['file']}")"
    dict['current_user']="$(koopa_stat_user "${dict['file']}")"
    if [[ "${dict['current_user']}" != "${dict['expected_user']}" ]]
    then
        koopa_warn "'${dict['file']}' user '${dict['current_user']}' \
is not '${dict['expected_user']}'."
        return 1
    fi
    return 0
}

koopa_check_version() {
    local current expected status
    koopa_assert_has_args "$#"
    IFS='.' read -r -a current <<< "${1:?}"
    IFS='.' read -r -a expected <<< "${2:?}"
    status=0
    for i in "${!current[@]}"
    do
        if [[ ! "${current[$i]}" -ge "${expected[$i]}" ]]
        then
            status=1
            break
        fi
    done
    return "$status"
}

koopa_chgrp() {
    local app chgrp dict pos
    declare -A app=(
        ['chgrp']="$(koopa_locate_chgrp)"
    )
    [[ -x "${app['chgrp']}" ]] || return 1
    declare -A dict=(
        ['sudo']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        app['sudo']="$(koopa_locate_sudo)"
        [[ -x "${app['sudo']}" ]] || return 1
        chgrp=("${app['sudo']}" "${app['chgrp']}")
    else
        chgrp=("${app['chgrp']}")
    fi
    "${chgrp[@]}" "$@"
    return 0
}

koopa_chmod() {
    local app chmod dict pos
    declare -A app=(
        ['chmod']="$(koopa_locate_chmod)"
    )
    [[ -x "${app['chmod']}" ]] || return 1
    declare -A dict=(
        ['recursive']=0
        ['sudo']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--recursive' | \
            '-R')
                dict['recursive']=1
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        app['sudo']="$(koopa_locate_sudo)"
        [[ -x "${app['sudo']}" ]] || return 1
        chmod=("${app['sudo']}" "${app['chmod']}")
    else
        chmod=("${app['chmod']}")
    fi
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        chmod+=('-R')
    fi
    "${chmod[@]}" "$@"
    return 0
}

koopa_chown() {
    local app chown dict pos
    declare -A app=(
        ['chown']="$(koopa_locate_chown)"
    )
    [[ -x "${app['chown']}" ]] || return 1
    declare -A dict=(
        ['dereference']=1
        ['recursive']=0
        ['sudo']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--dereference' | \
            '-H')
                dict['dereference']=1
                shift 1
                ;;
            '--no-dereference' | \
            '-h')
                dict['dereference']=0
                shift 1
                ;;
            '--recursive' | \
            '-R')
                dict['recursive']=1
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        app['sudo']="$(koopa_locate_sudo)"
        [[ -x "${app['sudo']}" ]] || return 1
        chown=("${app['sudo']}" "${app['chown']}")
    else
        chown=("${app['chown']}")
    fi
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        chown+=('-R')
    fi
    if [[ "${dict['dereference']}" -eq 0 ]]
    then
        chown+=('-h')
    fi
    "${chown[@]}" "$@"
    return 0
}

koopa_cli_app() {
    local dict
    declare -A dict=(
        ['key']=''
    )
    case "${1:-}" in
        '--help' | \
        '-h')
            koopa_help "$(koopa_man_prefix)/man1/app.1"
            ;;
        'aws')
            case "${2:-}" in
                'batch')
                    case "${3:-}" in
                        'fetch-and-run' | \
                        'list-jobs')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                'codecommit')
                    case "${3:-}" in
                        'list-repositories')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                'ec2')
                    case "${3:-}" in
                        'instance-id' | \
                        'suspend' | \
                        'terminate')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                's3')
                    case "${3:-}" in
                        'delete-versioned-glacier-objects' | \
                        'find' | \
                        'list-large-files' | \
                        'ls' | \
                        'mv-to-parent' | \
                        'sync')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'bioconda')
            case "${2:-}" in
                'autobump-recipe')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'bowtie2' | \
        'rsem')
            case "${2:-}" in
                'align' | \
                'index')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'brew')
            case "${2:-}" in
                'cleanup' | \
                'dump-brewfile' | \
                'outdated' | \
                'reset-core-repo' | \
                'reset-permissions' | \
                'uninstall-all-brews' | \
                'upgrade-brews' | \
                'version')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'conda')
            case "${2:-}" in
                'create-env' | \
                'remove-env')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'docker')
            case "${2:-}" in
                'build' | \
                'build-all-images' | \
                'build-all-tags' | \
                'prune-all-images' | \
                'prune-all-stale-tags' | \
                'prune-old-images' | \
                'prune-stale-tags' | \
                'push' | \
                'remove' | \
                'run' | \
                'tag')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'ftp')
            case "${2:-}" in
                'mirror')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'git')
            case "${2:-}" in
                'checkout-recursive' | \
                'pull' | \
                'pull-recursive' | \
                'push-recursive' | \
                'push-submodules' | \
                'rename-master-to-main' | \
                'reset' | \
                'reset-fork-to-upstream' | \
                'rm-submodule' | \
                'rm-untracked' | \
                'status-recursive')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'gpg')
            case "${2:-}" in
                'prompt' | \
                'reload' | \
                'restart')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'jekyll')
            case "${2:-}" in
                'serve')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'kallisto' | \
        'salmon')
            case "${2:-}" in
                'index')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                'quant')
                    case "${3:-}" in
                        'paired-end' | \
                        'single-end')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'md5sum')
            case "${2:-}" in
                'check-to-new-md5-file')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'rnaeditingindexer')
            dict['key']="${1:?}"
            shift 1
            ;;
        'sra')
            case "${2:-}" in
                'download-accession-list' | \
                'download-run-info-table' | \
                'fastq-dump' | \
                'prefetch')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'ssh')
            case "${2:-}" in
                'generate-key')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'star')
            case "${2:-}" in
                'align')
                    case "${3:-}" in
                        'paired-end' | \
                        'single-end')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                'index')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'wget')
            case "${2:-}" in
                'recursive')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        *)
            koopa_cli_invalid_arg "$@"
            ;;
    esac
    [[ -z "${dict['key']}" ]] && koopa_cli_invalid_arg "$@"
    dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
    if ! koopa_is_function "${dict['fun']}"
    then
        koopa_stop 'Unsupported command.'
    fi
    "${dict['fun']}" "$@"
    return 0
}

koopa_cli_configure() {
    local app stem
    stem='configure'
    case "$1" in
        'system' | \
        'user')
            stem="${stem}-${1}"
            shift 1
            ;;
    esac
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        local dict
        declare -A dict=(
            ['key']="${stem}-${app}"
        )
        dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
        if ! koopa_is_function "${dict['fun']}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict['fun']}"
    done
    return 0
}

koopa_cli_install() {
    local app dict flags pos stem
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['allow_custom']=0
        ['custom_enabled']=0
        ['stem']='install'
    )
    case "${1:-}" in
        'koopa')
            dict['allow_custom']=1
            ;;
        '--all')
            koopa_install_all_apps
            return 0
            ;;
        '--all-binary')
            koopa_install_all_binary_apps
            return 0
            ;;
    esac
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--binary' | \
            '--push' | \
            '--reinstall' | \
            '--verbose')
                flags+=("$1")
                shift 1
                ;;
            '-'*)
                if [[ "${dict['allow_custom']}" -eq 1 ]]
                then
                    dict['custom_enabled']=1
                    pos+=("$1")
                    shift 1
                else
                    koopa_invalid_arg "$1"
                fi
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    case "${1:-}" in
        'system' | \
        'user')
            dict['stem']="${dict['stem']}-${1:?}"
            shift 1
            ;;
    esac
    koopa_assert_has_args "$#"
    if [[ "${dict['custom_enabled']}" -eq 1 ]]
    then
        dict['app']="${1:?}"
        shift 1
        dict['key']="${dict['stem']}-${dict['app']}"
        dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
        if ! koopa_is_function "${dict['fun']}"
        then
            koopa_stop "Unsupported app: '${dict['app']}'."
        fi
        "${dict['fun']}" "$@"
        return 0
    fi
    for app in "$@"
    do
        local dict2
        declare -A dict2
        dict2['app']="$app"
        dict2['key']="${dict['stem']}-${dict2['app']}"
        dict2['fun']="$(koopa_which_function "${dict2['key']}" || true)"
        if ! koopa_is_function "${dict2['fun']}"
        then
            koopa_stop "Unsupported app: '${dict2['app']}'."
        fi
        if koopa_is_array_non_empty "${flags[@]:-}"
        then
            "${dict2['fun']}" "${flags[@]:-}"
        else
            "${dict2['fun']}"
        fi
    done
    return 0
}

koopa_cli_invalid_arg() {
    if [[ "$#" -eq 0 ]]
    then
        koopa_stop "Missing required argument. \
Check autocompletion of supported arguments with <TAB>."
    else
        koopa_stop "Invalid and/or incomplete argument: '${*}'.\n\
Check autocompletion of supported arguments with <TAB>."
    fi
}

koopa_cli_reinstall() {
    case "${1:-}" in
        '--all-revdeps')
            shift 1
            koopa_reinstall_all_revdeps "$@"
            return 0
            ;;
    esac
    koopa_cli_install --reinstall "$@"
}

koopa_cli_system() {
    local dict
    declare -A dict=(
        ['key']=''
    )
    case "${1:-}" in
        'check')
            dict['key']='check-system'
            shift 1
            ;;
        'info')
            dict['key']='system-info'
            shift 1
            ;;
        'list')
            case "${2:-}" in
                'app-versions' | \
                'dotfiles' | \
                'launch-agents' | \
                'path-priority' | \
                'programs')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
            esac
            ;;
        'log')
            dict['key']='view-latest-tmp-log-file'
            shift 1
            ;;
        'prefix')
            case "${2:-}" in
                '')
                    dict['key']='koopa-prefix'
                    shift 1
                    ;;
                'koopa')
                    dict['key']='koopa-prefix'
                    shift 2
                    ;;
                *)
                    dict['key']="${2}-prefix"
                    shift 2
                    ;;
            esac
            ;;
        'version')
            dict['key']='get-version'
            shift 1
            ;;
        'which')
            dict['key']='which-realpath'
            shift 1
            ;;
        'cache-functions' | \
        'disable-passwordless-sudo' | \
        'enable-passwordless-sudo' | \
        'find-non-symlinked-make-files' | \
        'fix-zsh-permissions' | \
        'host-id' | \
        'os-string' | \
        'prune-app-binaries' | \
        'prune-apps' | \
        'push-all-app-builds' | \
        'push-app-build' | \
        'reload-shell' | \
        'roff' | \
        'set-permissions' | \
        'switch-to-develop' | \
        'test' | \
        'variable' | \
        'variables')
            dict['key']="${1:?}"
            shift 1
            ;;
        'conda-create-env')
            koopa_defunct 'koopa app conda create-env'
            ;;
        'conda-remove-env')
            koopa_defunct 'koopa app conda remove-env'
            ;;
    esac
    if [[ -z "${dict['key']}" ]]
    then
        if koopa_is_linux
        then
            case "${1:-}" in
                'delete-cache' | \
                'fix-sudo-setrlimit-error')
                    dict['key']="${1:?}"
                    shift 1
                    ;;
            esac
        elif koopa_is_macos
        then
            case "${1:-}" in
                'spotlight')
                    dict['key']='spotlight-find'
                    shift 1
                    ;;
                'clean-launch-services' | \
                'create-dmg' | \
                'disable-touch-id-sudo' | \
                'enable-touch-id-sudo' | \
                'flush-dns' | \
                'force-eject' | \
                'ifactive' | \
                'list-launch-agents' | \
                'reload-autofs')
                    dict['key']="${1:?}"
                    shift 1
                    ;;
            esac
        fi
    fi
    [[ -z "${dict['key']}" ]] && koopa_cli_invalid_arg "$@"
    dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
    if ! koopa_is_function "${dict['fun']}"
    then
        koopa_stop 'Unsupported command.'
    fi
    "${dict['fun']}" "$@"
    return 0
}

koopa_cli_uninstall() {
    local app
    [[ "$#" -eq 0 ]] && set -- 'koopa'
    stem='uninstall'
    case "$1" in
        'system' | \
        'user')
            stem="${stem}-${1}"
            shift 1
            ;;
    esac
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        local dict
        declare -A dict=(
            ['key']="${stem}-${app}"
        )
        dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
        if ! koopa_is_function "${dict['fun']}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict['fun']}"
    done
    return 0
}

koopa_cli_update() {
    local app stem
    [[ "$#" -eq 0 ]] && set -- 'koopa'
    stem='update'
    case "$1" in
        'system' | \
        'user')
            stem="${stem}-${1}"
            shift 1
            ;;
    esac
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        local dict
        declare -A dict=(
            ['key']="${stem}-${app}"
        )
        dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
        if ! koopa_is_function "${dict['fun']}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict['fun']}"
    done
    return 0
}

koopa_cli() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['nested']=0
    )
    case "${1:?}" in
        '--help' | \
        '-h')
            dict['manfile']="$(koopa_man_prefix)/man1/koopa.1"
            koopa_help "${dict['manfile']}"
            return 0
            ;;
        '--version' | \
        '-V' | \
        'version')
            dict['key']='koopa-version'
            shift 1
            ;;
        'header')
            dict['key']="$1"
            shift 1
            ;;
        'app' | \
        'configure' | \
        'install' | \
        'reinstall' | \
        'system' | \
        'uninstall' | \
        'update')
            dict['nested']=1
            dict['key']="cli-${1}"
            shift 1
            ;;
        *)
            koopa_cli_invalid_arg "$@"
            ;;
    esac
    if [[ "${dict['nested']}"  -eq 1 ]]
    then
        dict['fun']="koopa_${dict['key']//-/_}"
        koopa_assert_is_function "${dict['fun']}"
    else
        dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
    fi
    if ! koopa_is_function "${dict['fun']}"
    then
        koopa_stop 'Unsupported command.'
    fi
    "${dict['fun']}" "$@"
    return 0
}

koopa_clone() {
    local dict rsync_args
    koopa_assert_has_args_eq "$#" 2
    koopa_assert_has_no_flags "$@"
    declare -A dict=(
        ['source_dir']="${1:?}"
        ['target_dir']="${2:?}"
    )
    koopa_assert_is_dir "${dict['source_dir']}" "${dict['target_dir']}"
    dict['source_dir']="$( \
        koopa_realpath "${dict['source_dir']}" \
        | koopa_strip_trailing_slash \
    )"
    dict['target_dir']="$( \
        koopa_realpath "${dict['target_dir']}" \
        | koopa_strip_trailing_slash \
    )"
    koopa_dl \
        'Source dir' "${dict['source_dir']}" \
        'Target dir' "${dict['target_dir']}"
    rsync_args=(
        '--archive'
        '--delete-before'
        "--source-dir=${dict['source_dir']}"
        "--target-dir=${dict['target_dir']}"
    )
    koopa_rsync "${rsync_args[@]}"
    return 0
}

koopa_compress_ext_pattern() {
    koopa_assert_has_no_args "$#"
    koopa_print '\.(bz2|gz|xz|zip)$'
    return 0
}

koopa_conda_activate_env() {
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        ['env_name']="${1:?}"
        ['nounset']="$(koopa_boolean_nounset)"
    )
    dict['env_prefix']="$(koopa_conda_env_prefix "${dict['env_name']}" || true)"
    if [[ ! -d "${dict['env_prefix']}" ]]
    then
        koopa_alert_info "Attempting to install missing conda \
environment '${dict['env_name']}'."
        koopa_conda_create_env "${dict['env_name']}"
        dict['env_prefix']="$( \
            koopa_conda_env_prefix "${dict['env_name']}" || true \
        )"
    fi
    if [[ ! -d "${dict['env_prefix']}" ]]
    then
        koopa_stop "'${dict['env_name']}' conda environment is not installed."
    fi
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    koopa_is_conda_env_active && koopa_conda_deactivate
    koopa_activate_conda
    koopa_assert_is_function 'conda'
    conda activate "${dict['env_prefix']}"
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_conda_create_env() {
    local app dict pos string
    koopa_assert_has_args "$#"
    declare -A app=(
        ['conda']="$(koopa_locate_conda)"
        ['cut']="$(koopa_locate_cut)"
    )
    [[ -x "${app['conda']}" ]] || return 1
    [[ -x "${app['cut']}" ]] || return 1
    declare -A dict=(
        ['env_prefix']="$(koopa_conda_env_prefix)"
        ['force']=0
        ['latest']=0
        ['prefix']=''
        ['yaml_file']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['yaml_file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['yaml_file']="${2:?}"
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
            '--force' | \
            '--reinstall')
                dict['force']=1
                shift 1
                ;;
            '--latest')
                dict['latest']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ -n "${dict['yaml_file']}" ]]
    then
        koopa_assert_has_no_args "$#"
        koopa_assert_is_dir "${dict['prefix']}"
        [[ "${dict['force']}" -eq 0 ]] || return 1
        [[ "${dict['latest']}" -eq 0 ]] || return 1
        koopa_assert_is_file "${dict['yaml_file']}"
        dict['yaml_file']="$(koopa_realpath "${dict['yaml_file']}")"
        koopa_dl 'conda recipe file' "${dict['yaml_file']}"
        "${app['conda']}" env create \
            --file "${dict['yaml_file']}" \
            --prefix "${dict['prefix']}" \
            --quiet
        return 0
    elif [[ -n "${dict['prefix']}" ]]
    then
        koopa_assert_has_args "$#"
        koopa_assert_is_dir "${dict['prefix']}"
        [[ "${dict['force']}" -eq 0 ]] || return 1
        [[ "${dict['latest']}" -eq 0 ]] || return 1
        "${app['conda']}" create \
            --prefix "${dict['prefix']}" \
            --quiet \
            --yes \
            "$@"
        return 0
    fi
    koopa_assert_has_args "$#"
    [[ -z "${dict['yaml_file']}" ]] || return 1
    for string in "$@"
    do
        local dict2
        declare -A dict2
        dict2['env_string']="${string//@/=}"
        if [[ "${dict['latest']}" -eq 1 ]]
        then
            if koopa_str_detect_fixed \
                --string="${dict2['env_string']}" \
                --pattern='='
            then
                koopa_stop "Don't specify version when using '--latest'."
            fi
            koopa_alert "Obtaining latest version for '${dict2['env_string']}'."
            dict2['env_version']="$( \
                koopa_conda_env_latest_version "${dict2['env_string']}" \
            )"
            [[ -n "${dict2['env_version']}" ]] || return 1
            dict2['env_string']="${dict2['env_string']}=${dict2['env_version']}"
        elif ! koopa_str_detect_fixed \
            --string="${dict2['env_string']}" \
            --pattern='='
        then
            dict2['env_version']="$( \
                koopa_app_json_version "${dict2['env_string']}" \
                || true \
            )"
            if [[ -z "${dict2['env_version']}" ]]
            then
                koopa_stop 'Pinned environment version not defined in koopa.'
            fi
            dict2['env_string']="${dict2['env_string']}=${dict2['env_version']}"
        fi
        dict2['env_name']="$( \
            koopa_print "${dict2['env_string']//=/@}" \
            | "${app['cut']}" -d '@' -f '1-2' \
        )"
        dict2['env_prefix']="${dict['env_prefix']}/${dict2['env_name']}"
        if [[ -d "${dict2['env_prefix']}" ]]
        then
            if [[ "${dict['force']}" -eq 1 ]]
            then
                koopa_conda_remove_env "${dict2['env_name']}"
            else
                koopa_alert_note "Conda environment '${dict2['env_name']}' \
exists at '${dict2['env_prefix']}'."
                continue
            fi
        fi
        koopa_alert_install_start \
            "${dict2['env_name']}" "${dict2['env_prefix']}"
        "${app['conda']}" create \
            --name="${dict2['env_name']}" \
            --quiet \
            --yes \
            "${dict2['env_string']}"
        koopa_alert_install_success \
            "${dict2['env_name']}" "${dict2['env_prefix']}"
    done
    return 0
}

koopa_conda_deactivate() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['env_name']="$(koopa_conda_env_name)"
        ['nounset']="$(koopa_boolean_nounset)"
    )
    if [[ -z "${dict['env_name']}" ]]
    then
        koopa_stop 'conda is not active.'
    fi
    koopa_assert_is_function 'conda'
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    conda deactivate
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_conda_env_latest_version() {
    local app dict str
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
        ['conda']="$(koopa_locate_conda)"
        ['tail']="$(koopa_locate_tail)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['conda']}" ]] || return 1
    [[ -x "${app['tail']}" ]] || return 1
    declare -A dict=(
        ['env_name']="${1:?}"
    )
    str="$( \
        "${app['conda']}" search --quiet "${dict['env_name']}" \
            | "${app['tail']}" -n 1 \
            | "${app['awk']}" '{print $2}'
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_conda_env_list() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['conda']="$(koopa_locate_conda)"
    )
    [[ -x "${app['conda']}" ]] || return 1
    str="$("${app['conda']}" env list --json --quiet)"
    koopa_print "$str"
    return 0
}

koopa_conda_env_prefix() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['conda']="$(koopa_locate_conda)"
        ['jq']="$(koopa_locate_jq)"
        ['sed']="$(koopa_locate_sed)"
        ['tail']="$(koopa_locate_tail)"
    )
    [[ -x "${app['conda']}" ]] || return 1
    [[ -x "${app['jq']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    [[ -x "${app['tail']}" ]] || return 1
    declare -A dict=(
        ['env_name']="${1:-}"
    )
    dict['env_prefix']="$( \
        "${app['conda']}" info --json | \
            "${app['jq']}" --raw-output '.envs_dirs[0]' \
    )"
    [[ -n "${dict['env_prefix']}" ]] || return 1
    if [[ -z "${dict['env_name']}" ]]
    then
        koopa_print "${dict['env_prefix']}"
        return 0
    fi
    dict['prefix']="${dict['env_prefix']}/${dict['env_name']}"
    if [[ -d "${dict['prefix']}" ]]
    then
        koopa_print "${dict['prefix']}"
        return 0
    fi
    dict['env_list']="$(koopa_conda_env_list)"
    dict['env_list2']="$( \
        koopa_grep \
            --pattern="${dict['env_name']}" \
            --string="${dict['env_list']}" \
    )"
    [[ -n "${dict['env_list2']}" ]] || return 1
    dict['prefix']="$( \
        koopa_grep \
            --pattern="/${dict['env_name']}(@[.0-9]+)?\"" \
            --regex \
            --string="${dict['env_list']}" \
        | "${app['tail']}" -n 1 \
        | "${app['sed']}" -E 's/^.*"(.+)".*$/\1/' \
    )"
    [[ -d "${dict['prefix']}" ]] || return 1
    koopa_print "${dict['prefix']}"
    return 0
}

koopa_conda_pkg_cache_prefix() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['conda']="$(koopa_locate_conda)"
        ['jq']="$(koopa_locate_jq)"
    )
    [[ -x "${app['conda']}" ]] || return 1
    [[ -x "${app['jq']}" ]] || return 1
    declare -A dict
    dict['prefix']="$( \
        "${app['conda']}" info --json \
            | "${app['jq']}" --raw-output '.pkgs_dirs[0]' \
    )"
    [[ -n "${dict['prefix']}" ]] || return 1
    koopa_print "${dict['prefix']}"
    return 0
}

koopa_conda_remove_env() {
    local app dict name
    koopa_assert_has_args "$#"
    declare -A app=(
        ['conda']="$(koopa_locate_conda)"
    )
    [[ -x "${app['conda']}" ]] || return 1
    declare -A dict=(
        ['nounset']="$(koopa_boolean_nounset)"
    )
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    for name in "$@"
    do
        dict['prefix']="$(koopa_conda_env_prefix "$name")"
        koopa_assert_is_dir "${dict['prefix']}"
        dict['name']="$(koopa_basename "${dict['prefix']}")"
        koopa_alert_uninstall_start "${dict['name']}" "${dict['prefix']}"
        "${app['conda']}" env remove --name="${dict['name']}" --yes
        [[ -d "${dict['prefix']}" ]] && koopa_rm "${dict['prefix']}"
        koopa_alert_uninstall_success "${dict['name']}" "${dict['prefix']}"
    done
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_configure_r() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['r']="${1:-}"
    )
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    [[ -x "${app['r']}" ]] || return 1
    declare -A dict=(
        ['name']='r'
        ['system']=0
    )
    if ! koopa_is_koopa_app "${app['r']}"
    then
        koopa_assert_is_admin
        dict['system']=1
    fi
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['site_library']="${dict['r_prefix']}/site-library"
    koopa_alert_configure_start "${dict['name']}" "${dict['r_prefix']}"
    koopa_assert_is_dir "${dict['r_prefix']}"
    if koopa_is_macos && [[ ! -f '/usr/local/include/omp.h' ]]
    then
        koopa_stop \
            "'libomp' is not installed." \
            "Run 'koopa install system r-openmp' to resolve."
    fi
    koopa_r_link_files_in_etc "${app['r']}"
    koopa_r_configure_environ "${app['r']}"
    koopa_r_configure_makevars "${app['r']}"
    koopa_r_configure_ldpaths "${app['r']}"
    koopa_r_configure_java "${app['r']}"
    case "${dict['system']}" in
        '0')
            if [[ -L "${dict['site_library']}" ]]
            then
                koopa_rm "${dict['site_library']}"
            fi
            koopa_sys_mkdir "${dict['site_library']}"
            ;;
        '1')
            dict['group']="$(koopa_admin_group)"
            dict['user']="$(koopa_user)"
            if [[ -L "${dict['site_library']}" ]]
            then
                koopa_rm --sudo "${dict['site_library']}"
            fi
            koopa_mkdir --sudo "${dict['site_library']}"
            koopa_chmod --sudo '0775' "${dict['site_library']}"
            koopa_chown --sudo --recursive \
                "${dict['user']}:${dict['group']}" \
                "${dict['site_library']}"
            dict['site_library_2']='/usr/local/lib/R/site-library'
            if [[ -d "${dict['site_library_2']}" ]]
            then
                koopa_chmod --sudo '0775' "${dict['site_library_2']}"
                koopa_chown --sudo --recursive \
                    "${dict['user']}:${dict['group']}" \
                    "${dict['site_library_2']}"
            fi
            koopa_r_configure_makeconf "${app['r']}"
            koopa_r_rebuild_docs "${app['r']}"
            ;;
    esac
    koopa_alert_configure_success "${dict['name']}" "${dict['r_prefix']}"
    return 0
}

koopa_configure_system_r() {
    local app
    declare -A app
    app['r']="$(koopa_locate_system_r)"
    [[ -x "${app['r']}" ]] || return 1
    koopa_configure_r "${app['r']}"
    return 0
}

koopa_configure_user_chemacs() {
    local dict
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        ['source_prefix']="${1:-}"
        ['opt_prefix']="$(koopa_opt_prefix)"
        ['target_prefix']="${HOME:?}/.emacs.d"
    )
    if [[ -z "${dict['source_prefix']}" ]]
    then
        dict['source_prefix']="${dict['opt_prefix']}/chemacs"
    fi
    koopa_assert_is_dir "${dict['source_prefix']}"
    dict['source_prefix']="$(koopa_realpath "${dict['source_prefix']}")"
    koopa_ln "${dict['source_prefix']}" "${dict['target_prefix']}"
    return 0
}

koopa_configure_user_dotfiles() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['bash']="$(koopa_locate_bash --allow-system)"
    )
    [[ -x "${app['bash']}" ]] || return 1
    declare -A dict=(
        ['cm_prefix']="$(koopa_xdg_data_home)/chezmoi"
        ['name']='dotfiles'
        ['prefix']="${1:-}"
    )
    [[ -z "${dict['prefix']}" ]] && dict['prefix']="$(koopa_dotfiles_prefix)"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['script']="${dict['prefix']}/install"
    koopa_assert_is_file "${dict['script']}"
    koopa_ln "${dict['prefix']}" "${dict['cm_prefix']}"
    koopa_add_config_link "${dict['prefix']}" "${dict['name']}"
    koopa_add_to_path_start "$(koopa_dirname "${app['bash']}")"
    "${app['bash']}" "${dict['script']}"
    return 0
}

koopa_contains() {
    local string x
    koopa_assert_has_args_ge "$#" 2
    string="${1:?}"
    shift 1
    for x
    do
        [[ "$x" == "$string" ]] && return 0
    done
    return 1
}

koopa_convert_fastq_to_fasta() {
    local app dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut)"
        ['paste']="$(koopa_locate_paste)"
        ['sed']="$(koopa_locate_sed)"
        ['tr']="$(koopa_locate_tr)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['paste']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    [[ -x "${app['tr']}" ]] || return 1
    declare -A dict=(
        ['source_dir']=''
        ['target_dir']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--source-dir='*)
                dict['source_dir']="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict['source_dir']="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--source-dir' "${dict['source_dir']}" \
        '--target-dir' "${dict['target_dir']}"
    koopa_assert_is_dir "${dict['source_dir']}"
    dict['source_dir']="$(koopa_realpath "${dict['source_dir']}")"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.fastq' \
            --prefix="${dict['source_dir']}" \
            --sort \
            --type='f' \
    )"
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa_stop "No FASTQ files detected in '${dict['source_dir']}'."
    fi
    dict['target_dir']="$(koopa_init_dir "${dict['target_dir']}")"
    for fastq_file in "${fastq_files[@]}"
    do
        local fasta_file
        fasta_file="${fastq_file%.fastq}.fasta"
        "${app['paste']}" - - - - < "$fastq_file" \
            | "${app['cut']}" -f '1,2' \
            | "${app['sed']}" 's/^@/>/' \
            | "${app['tr']}" '\t' '\n' > "$fasta_file"
    done
    return 0
}

koopa_convert_line_endings_from_crlf_to_lf() {
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        ['perl']="$(koopa_locate_perl)"
    )
    [[ -x "${app['perl']}" ]] || return 1
    for file in "$@"
    do
        "${app['perl']}" -pe 's/\r$//g' < "$file" > "${file}.tmp"
        koopa_mv "${file}.tmp" "$file"
    done
    return 0
}

koopa_convert_line_endings_from_lf_to_crlf() {
    local app file
    koopa_assert_has_ars "$#"
    declare -A app=(
        ['perl']="$(koopa_locate_perl)"
    )
    [[ -x "${app['perl']}" ]] || return 1
    for file in "$@"
    do
        "${app['perl']}" -pe 's/(?<!\r)\n/\r\n/g' < "$file" > "${file}.tmp"
        koopa_mv "${file}.tmp" "$file"
    done
    return 0
}

koopa_convert_sam_to_bam() {
    local bam_file keep_sam pos sam_file sam_files
    keep_sam=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--keep-sam')
                keep_sam=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    dir="${1:-.}"
    koopa_assert_is_dir "$dir"
    dir="$(koopa_realpath "$dir")"
    readarray -t sam_files <<< "$( \
        find "$dir" \
            -maxdepth 3 \
            -mindepth 1 \
            -type f \
            -iname '*.sam' \
            -print \
        | sort \
    )"
    if ! koopa_is_array_non_empty "${sam_files[@]:-}"
    then
        koopa_stop "No SAM files detected in '${dir}'."
    fi
    koopa_h1 "Converting SAM files in '${dir}' to BAM format."
    koopa_conda_activate_env 'samtools'
    case "$keep_sam" in
        '0')
            koopa_alert_note 'SAM files will be deleted.'
            ;;
        '1')
            koopa_alert_note 'SAM files will be preserved.'
            ;;
    esac
    for sam_file in "${sam_files[@]}"
    do
        bam_file="${sam_file%.sam}.bam"
        koopa_samtools_convert_sam_to_bam \
            --input-sam="$sam_file" \
            --output-bam="$bam_file"
        [[ "$keep_sam" -eq 0 ]] && koopa_rm "$sam_file"
    done
    koopa_conda_deactivate
    return 0
}

koopa_convert_utf8_nfd_to_nfc() {
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        ['convmv']="$(koopa_locate_convmv)"
    )
    [[ -x "${app['convmv']}" ]] || return 1
    koopa_assert_is_file "$@"
    "${app['convmv']}" \
        -r \
        -f 'utf8' \
        -t 'utf8' \
        --nfc \
        --notest \
        "$@"
    return 0
}

koopa_cp() {
    local app cp cp_args dict mkdir pos rm
    declare -A app=(
        ['cp']="$(koopa_locate_cp --allow-system)"
        ['mkdir']='koopa_mkdir'
        ['rm']='koopa_rm'
    )
    [[ -x "${app['cp']}" ]] || return 1
    declare -A dict=(
        ['sudo']=0
        ['symlink']=0
        ['target_dir']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--target-directory='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '--symbolic-link' | \
            '--symlink' | \
            '-s')
                dict['symlink']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        app['sudo']="$(koopa_locate_sudo)"
        [[ -x "${app['sudo']}" ]] || return 1
        cp=("${app['sudo']}" "${app['cp']}")
        mkdir=("${app['mkdir']}" '--sudo')
        rm=("${app['rm']}" '--sudo')
    else
        cp=("${app['cp']}")
        mkdir=("${app['mkdir']}")
        rm=("${app['rm']}")
    fi
    cp_args=('-afv')
    [[ "${dict['symlink']}" -eq 1 ]] && cp_args+=('-s')
    cp_args+=("$@")
    if [[ -n "${dict['target_dir']}" ]]
    then
        koopa_assert_is_existing "$@"
        dict['target_dir']="$( \
            koopa_strip_trailing_slash "${dict['target_dir']}" \
        )"
        if [[ ! -d "${dict['target_dir']}" ]]
        then
            "${mkdir[@]}" "${dict['target_dir']}"
        fi
        cp_args+=("${dict['target_dir']}")
    else
        koopa_assert_has_args_eq "$#" 2
        dict['source_file']="${1:?}"
        koopa_assert_is_existing "${dict['source_file']}"
        dict['target_file']="${2:?}"
        if [[ -e "${dict['target_file']}" ]]
        then
            "${rm[@]}" "${dict['target_file']}"
        fi
        dict['target_parent']="$(koopa_dirname "${dict['target_file']}")"
        if [[ ! -d "${dict['target_parent']}" ]]
        then
            "${mkdir[@]}" "${dict['target_parent']}"
        fi
    fi
    "${cp[@]}" "${cp_args[@]}"
    return 0
}

koopa_current_bcbio_nextgen_version() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    str="$( \
        koopa_parse_url "https://raw.githubusercontent.com/bcbio/\
bcbio-nextgen/master/requirements-conda.txt" \
            | koopa_grep --pattern='bcbio-nextgen=' \
            | "${app['cut']}" -d '=' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_current_bioconductor_version() {
    local str
    koopa_assert_has_no_args "$#"
    str="$(koopa_parse_url 'https://bioconductor.org/bioc-version')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_current_ensembl_version() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut)"
        ['sed']="$(koopa_locate_sed)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    str="$( \
        koopa_parse_url 'ftp://ftp.ensembl.org/pub/current_README' \
        | "${app['sed']}" -n '3p' \
        | "${app['cut']}" -d ' ' -f '3' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_current_flybase_version() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
        ['tail']="$(koopa_locate_tail --allow-system)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['tail']}" ]] || return 1
    str="$( \
        koopa_parse_url --list-only "ftp://ftp.flybase.net/releases/" \
        | koopa_grep --pattern='^FB[0-9]{4}_[0-9]{2}$' --regex \
        | "${app['tail']}" -n 1 \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_current_gencode_version() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['curl']="$(koopa_locate_curl --allow-system)"
        ['cut']="$(koopa_locate_cut --allow-system)"
        ['grep']="$(koopa_locate_grep --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['curl']}" ]] || return 1
    [[ -x "${app['grep']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    declare -A dict=(
        ['organism']="${1:-}"
    )
    [[ -z "${dict['organism']}" ]] && dict['organism']='Homo sapiens'
    case "${dict['organism']}" in
        'Homo sapiens' | \
        'human')
            dict['short_name']='human'
            dict['pattern']='Release [0-9]+'
            ;;
        'Mus musculus' | \
        'mouse')
            dict['short_name']='mouse'
            dict['pattern']='Release M[0-9]+'
            ;;
        *)
            koopa_stop "Unsupported organism: '${dict['organism']}'."
            ;;
    esac
    dict['base_url']='https://www.gencodegenes.org'
    dict['url']="${dict['base_url']}/${dict['short_name']}/"
    dict['str']="$( \
        koopa_parse_url "${dict['url']}" \
        | koopa_grep \
            --only-matching \
            --pattern="${dict['pattern']}" \
            --regex \
        | "${app['head']}" -n 1 \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_current_refseq_version() {
    local str url
    koopa_assert_has_no_args "$#"
    url='ftp://ftp.ncbi.nlm.nih.gov/refseq/release/RELEASE_NUMBER'
    str="$(koopa_parse_url "$url")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_current_wormbase_version() {
    local app str url
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    url="ftp://ftp.wormbase.org/pub/wormbase/\
releases/current-production-release"
    str="$( \
        koopa_parse_url --list-only "${url}/" \
            | koopa_grep \
                --only-matching \
                --pattern='letter.WS[0-9]+' \
                --regex \
            | "${app['cut']}" -d '.' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_datetime() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app
    app['date']="$(koopa_locate_date --allow-system)"
    [[ -x "${app['date']}" ]] || return 1
    str="$("${app['date']}" '+%Y%m%d-%H%M%S')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_decompress() {
    local cmd cmd_args dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['compress_ext_pattern']="$(koopa_compress_ext_pattern)"
        ['stdout']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--stdout')
                dict['stdout']=1
                shift 1
                ;;
            '-')
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_le "$#" 2
    dict['source_file']="${1:?}"
    dict['target_file']="${2:-}"
    koopa_assert_is_file "${dict['source_file']}"
    case "${dict['stdout']}" in
        '0')
            if [[ -z "${dict['target_file']}" ]]
            then
                dict['target_file']="$( \
                    koopa_sub \
                        --pattern="${dict['compress_ext_pattern']}" \
                        --replacement='' \
                        "${dict['source_file']}" \
                )"
            fi
            if [[ "${dict['source_file']}" == "${dict['target_file']}" ]]
            then
                return 0
            fi
            ;;
        '1')
            [[ -z "${dict['target_file']}" ]] || return 1
            ;;
    esac
    dict['source_file']="$(koopa_realpath "${dict['source_file']}")"
    case "${dict['source_file']}" in
        *'.bz2' | *'.gz' | *'.xz')
            case "${dict['source_file']}" in
                *'.bz2')
                    cmd="$(koopa_locate_bzip2)"
                    ;;
                *'.gz')
                    cmd="$(koopa_locate_gzip)"
                    ;;
                *'.xz')
                    cmd="$(koopa_locate_xz)"
                    ;;
            esac
            [[ -x "$cmd" ]] || return 1
            cmd_args=(
                '-c' # '--stdout'.
                '-d' # '--decompress'.
                '-f' # '--force'.
                '-k' # '--keep'.
                "${dict['source_file']}"
            )
            case "${dict['stdout']}" in
                '0')
                    "$cmd" "${cmd_args[@]}" > "${dict['target_file']}"
                    ;;
                '1')
                    "$cmd" "${cmd_args[@]}" || true
                    ;;
            esac
            ;;
        *)
            case "${dict['stdout']}" in
                '0')
                    koopa_cp "${dict['source_file']}" "${dict['target_file']}"
                    ;;
                '1')
                    cmd="$(koopa_locate_cat --allow-system)"
                    [[ -x "$cmd" ]] || return 1
                    "$cmd" "${dict['source_file']}" || true
                    ;;
            esac
            ;;
    esac
    if [[ "${dict['stdout']}" -eq 0 ]]
    then
        koopa_assert_is_file "${dict['target_file']}"
    fi
    return 0
}

koopa_defunct() {
    local msg new
    new="${1:-}"
    msg='Defunct.'
    if [[ -n "$new" ]]
    then
        msg="${msg} Use '${new}' instead."
    fi
    koopa_stop "${msg}"
}

koopa_activate_conda_env() {
    koopa_conda_activate_env "$@"
}

koopa_deactivate_conda() {
    koopa_conda_deactivate "$@"
}

koopa_brew_update() {
    koopa_defunct 'koopa_update_homebrew'
}

koopa_check_data_disk() {
    koopa_defunct
}

koopa_configure_start() {
    koopa_defunct 'koopa_alert_configure_start'
}

koopa_configure_success() {
    koopa_defunct 'koopa_alert_configure_success'
}

koopa_data_disk_link_prefix() {
    koopa_defunct
}

koopa_file_match_fixed() {
    koopa_defunct 'koopa_file_detect_fixed'
}

koopa_file_match_regex() {
    koopa_defunct 'koopa_file_detect_regex'
}

koopa_info() {
    koopa_defunct 'koopa_alert_info'
}

koopa_install_start() {
    koopa_defunct 'koopa_alert_install_start'
}

koopa_install_success() {
    koopa_defunct 'koopa_alert_install_success'
}

koopa_is_darwin() {
    koopa_defunct 'koopa_is_macos'
}

koopa_is_matching_fixed() {
    koopa_defunct 'koopa_str_detect_fixed'
}

koopa_is_matching_regex() {
    koopa_defunct 'koopa_str_detect_regex'
}

koopa_local_app_prefix() {
    koopa_defunct 'koopa_local_data_prefix'
}

koopa_note() {
    koopa_defunct 'koopa_alert_note'
}

koopa_quiet_cd() {
    koopa_defunct 'koopa_cd'
}

koopa_remove_broken_symlinks() {
    koopa_defunct 'koopa_delete_broken_symlinks'
}

koopa_remove_empty_dirs() {
    koopa_defunct 'koopa_delete_empty_dirs'
}

koopa_restart() {
    koopa_defunct 'koopa_alert_restart'
}

koopa_str_match_fixed() {
    koopa_defunct 'koopa_str_detect_fixed'
}

koopa_str_match_regex() {
    koopa_defunct 'koopa_str_detect_regex'
}

koopa_success() {
    koopa_defunct 'koopa_alert_success'
}

koopa_uninstall_start() {
    koopa_defunct 'koopa_alert_uninstall_start'
}

koopa_uninstall_success() {
    koopa_defunct 'koopa_alert_uninstall_success'
}

koopa_update_start() {
    koopa_defunct 'koopa_alert_update_start'
}

koopa_update_success() {
    koopa_defunct 'koopa_alert_update_success'
}

koopa_delete_broken_symlinks() {
    local prefix file files
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        readarray -t files <<< "$(koopa_find_broken_symlinks "$prefix")"
        koopa_is_array_non_empty "${files[@]:-}" || continue
        koopa_alert_note "Removing ${#files[@]} broken symlinks."
        for file in "${files[@]}"
        do
            [[ -z "$file" ]] && continue
            koopa_alert "Removing '${file}'."
            koopa_rm "$file"
        done
    done
    return 0
}

koopa_delete_dotfile() {
    local dict name pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['config']=0
        ['xdg_config_home']="$(koopa_xdg_config_home)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--config')
                dict['config']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    for name in "$@"
    do
        local filepath
        if [[ "${dict['config']}" -eq 1 ]]
        then
            filepath="${dict['xdg_config_home']}/${name}"
        else
            filepath="${HOME:?}/.${name}"
        fi
        if [[ -L "$filepath" ]]
        then
            koopa_alert "Removing '${filepath}'."
            koopa_rm "$filepath"
        elif [[ -f "$filepath" ]] || [[ -d "$filepath" ]]
        then
            koopa_warn "Not a symlink: '${filepath}'."
        fi
    done
    return 0
}

koopa_delete_empty_dirs() {
    local dir dirs prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        while [[ -d "$prefix" ]] && \
            [[ -n "$(koopa_find_empty_dirs "$prefix")" ]]
        do
            readarray -t dirs <<< "$(koopa_find_empty_dirs "$prefix")"
            koopa_is_array_non_empty "${dirs[@]:-}" || continue
            for dir in "${dirs[@]}"
            do
                [[ -d "$dir" ]] || continue
                koopa_alert "Deleting '${dir}'."
                koopa_rm "$dir"
            done
        done
    done
    return 0
}

koopa_delete_named_subdirs() {
    local dict matches
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        ['prefix']="${1:?}"
        ['subdir_name']="${2:?}"
    )
    readarray -t matches <<< "$( \
        koopa_find \
            --pattern="${dict['subdir_name']}" \
            --prefix="${dict['prefix']}" \
            --type='d' \
    )"
    koopa_is_array_non_empty "${matches[@]:-}" || return 1
    koopa_print "${matches[@]}"
    koopa_rm "${matches[@]}"
    return 0
}

koopa_detab() {
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        ['vim']="$(koopa_locate_vim)"
    )
    [[ -x "${app['vim']}" ]] || return 1
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app['vim']}" \
            -c 'set expandtab tabstop=4 shiftwidth=4' \
            -c ':%retab' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}

koopa_df() {
    local app
    declare -A app=(
        ['df']="$(koopa_locate_df)"
    )
    [[ -x "${app['df']}" ]] || return 1
    "${app['df']}" \
        --portability \
        --print-type \
        --si \
        "$@"
    return 0
}

koopa_dirname() {
    local arg
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for arg in "$@"
    do
        local str
        [[ -n "$arg" ]] || return 1
        if [[ -e "$arg" ]]
        then
            arg="$(koopa_realpath "$arg")"
        fi
        if koopa_str_detect_fixed --string="$arg" --pattern='/'
        then
            str="${arg%/*}"
        else
            str='.'
        fi
        koopa_print "$str"
    done
    return 0
}

koopa_disable_passwordless_sudo() {
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A dict
    dict['group']="$(koopa_admin_group)"
    dict['file']="/etc/sudoers.d/koopa-${dict['group']}"
    if [[ -f "${dict['file']}" ]]
    then
        koopa_alert "Removing sudo permission file at '${file}'."
        koopa_rm --sudo "$file"
    fi
    koopa_alert_success 'Passwordless sudo is disabled.'
    return 0
}

koopa_disk_512k_blocks() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['awk']="$(koopa_locate_awk --allow-system)"
        ['df']="$(koopa_locate_df --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
        ['sed']="$(koopa_locate_sed --allow-system)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['df']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict=(
        ['disk']="${1:?}"
    )
    dict['str']="$( \
        POSIXLY_CORRECT=1 \
        "${app['df']}" -P "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $2}' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_disk_gb_free() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['awk']="$(koopa_locate_awk --allow-system)"
        ['df']="$(koopa_locate_df --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
        ['sed']="$(koopa_locate_sed --allow-system)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['df']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict
    dict['disk']="${1:?}"
    koopa_assert_is_readable "${dict['disk']}"
    dict['str']="$( \
        POSIXLY_CORRECT=0 \
        "${app['df']}" --block-size='G' "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $4}' \
            | "${app['sed']}" 's/G$//' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_disk_gb_total() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['awk']="$(koopa_locate_awk --allow-system)"
        ['df']="$(koopa_locate_df --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
        ['sed']="$(koopa_locate_sed --allow-system)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['df']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict
    dict['disk']="${1:?}"
    koopa_assert_is_readable "${dict['disk']}"
    dict['str']="$( \
        POSIXLY_CORRECT=0 \
        "${app['df']}" --block-size='G' "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $2}' \
            | "${app['sed']}" 's/G$//' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_disk_gb_used() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['awk']="$(koopa_locate_awk --allow-system)"
        ['df']="$(koopa_locate_df --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
        ['sed']="$(koopa_locate_sed --allow-system)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['df']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict
    dict['disk']="${1:?}"
    koopa_assert_is_readable "${dict['disk']}"
    dict['str']="$( \
        POSIXLY_CORRECT=0 \
        "${app['df']}" --block-size='G' "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $3}' \
            | "${app['sed']}" 's/G$//' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_disk_pct_free() {
    local disk pct_free pct_used
    koopa_assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa_assert_is_readable "$disk"
    pct_used="$(koopa_disk_pct_used "$disk")"
    pct_free="$((100 - pct_used))"
    koopa_print "$pct_free"
    return 0
}

koopa_disk_pct_used() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['awk']="$(koopa_locate_awk --allow-system)"
        ['df']="$(koopa_locate_df --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
        ['sed']="$(koopa_locate_sed --allow-system)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['df']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict
    dict['disk']="${1:?}"
    koopa_assert_is_readable "${dict['disk']}"
    dict['str']="$( \
        POSIXLY_CORRECT=1 \
        "${app['df']}" "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $5}' \
            | "${app['sed']}" 's/%$//' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_dl() {
    koopa_assert_has_args_ge "$#" 2
    while [[ "$#" -ge 2 ]]
    do
        __koopa_msg 'default-bold' 'default' "${1:?}:" "${2:-}"
        shift 2
    done
    return 0
}

koopa_docker_build_all_images() {
    local app build_args image images
    local pos repo repos
    declare -A app=(
        ['basename']="$(koopa_locate_basename)"
        ['docker']="$(koopa_locate_docker)"
        ['xargs']="$(koopa_locate_xargs)"
    )
    [[ -x "${app['basename']}" ]] || return 1
    [[ -x "${app['docker']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    declare -A dict=(
        ['days']=7
        ['docker_dir']="$(koopa_docker_prefix)"
        ['force']=0
        ['prune']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--days='*)
                dict['days']="${1#*=}"
                shift 1
                ;;
            '--days')
                dict['days']="${2:?}"
                shift 2
                ;;
            '--docker-dir='*)
                dict['docker_dir']="${1#*=}"
                shift 1
                ;;
            '--docker-dir')
                dict['docker_dir']="${2:?}"
                shift 2
                ;;
            '--force')
                dict['force']=1
                shift 1
                ;;
            '--prune')
                dict['prune']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    build_args=("--days=${dict['days']}")
    if [[ "${dict['force']}" -eq 1 ]]
    then
        build_args+=('--force')
    fi
    if [[ "$#" -gt 0 ]]
    then
        repos=("$@")
    else
        repos=("${dict['docker_dir']}/acidgenomics")
    fi
    koopa_assert_is_dir "${repos[@]}"
    if [[ "${dict['prune']}" -eq 1 ]]
    then
        koopa_docker_prune_all_images
    fi
    "${app['docker']}" login >/dev/null || return 1
    for repo in "${repos[@]}"
    do
        local build_file repo_name
        repo_name="$(koopa_basename "$(koopa_realpath "$repo")")"
        koopa_h1 "Building '${repo_name}' images."
        build_file="${repo}/build.txt"
        if [[ -f "$build_file" ]]
        then
            readarray -t images <<< "$( \
                koopa_grep \
                    --file="$build_file" \
                    --pattern='^[-_a-z0-9]+$' \
                    --regex \
            )"
        else
            readarray -t images <<< "$( \
                koopa_find \
                    --max-depth=1 \
                    --min-depth=1 \
                    --prefix="${PWD:?}" \
                    --print0 \
                    --sort \
                    --type='d' \
                | "${app['xargs']}" -0 -n 1 "${app['basename']}" \
            )"
        fi
        koopa_assert_is_array_non_empty "${images[@]:-}"
        koopa_dl \
            "${#images[@]} images" \
            "$(koopa_to_string "${images[@]}")"
        for image in "${images[@]}"
        do
            image="${repo_name}/${image}"
            if [[ "${dict['force']}" -eq 0 ]]
            then
                if koopa_docker_is_build_recent \
                    --days="${dict['days']}" \
                    "$image"
                then
                    koopa_alert_note "'${image}' was built recently. Skipping."
                    continue
                fi
            fi
            koopa_docker_build_all_tags "${build_args[@]}" "$image"
        done
    done
    [[ "${dict['prune']}" -eq 1 ]] && koopa_docker_prune_all_images
    koopa_alert_success 'All Docker images built successfully.'
    return 0
}

koopa_docker_build_all_tags() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDockerBuildAllTags' "$@"
    return 0
}

koopa_docker_build() {
    local app dict pos
    koopa_assert_has_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut)"
        ['date']="$(koopa_locate_date)"
        ['docker']="$(koopa_locate_docker)"
        ['sort']="$(koopa_locate_sort)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['date']}" ]] || return 1
    [[ -x "${app['docker']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    declare -A dict=(
        ['docker_dir']="$(koopa_docker_prefix)"
        ['delete']=0
        ['memory']=''
        ['push']=1
        ['server']='docker.io'
        ['tag']='latest'
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--docker-dir='*)
                dict['docker_dir']="${1#*=}"
                shift 1
                ;;
            '--docker-dir')
                dict['docker_dir']="${2:?}"
                shift 2
                ;;
            '--memory='*)
                dict['memory']="${1#*=}"
                shift 1
                ;;
            '--memory')
                dict['memory']="${2:?}"
                shift 2
                ;;
            '--server='*)
                dict['server']="${1#*=}"
                shift 1
                ;;
            '--server')
                dict['server']="${2:?}"
                shift 2
                ;;
            '--tag='*)
                dict['tag']="${1#*=}"
                shift 1
                ;;
            '--tag')
                dict['tag']="${2:?}"
                shift 2
                ;;
            '--delete')
                dict['delete']=1
                shift 1
                ;;
            '--no-delete')
                dict['delete']=0
                shift 1
                ;;
            '--no-push')
                dict['push']=0
                shift 1
                ;;
            '--push')
                dict['push']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    for image in "$@"
    do
        local build_args dict2 image_ids platforms tag tags
        declare -A dict2
        dict2['image']="$image"
        build_args=()
        platforms=()
        tags=()
        if ! koopa_str_detect_fixed \
            --string="${dict2['image']}" \
            --pattern='/'
        then
            dict2['image']="acidgenomics/${dict2['image']}"
        fi
        if koopa_str_detect_fixed \
            --string="${dict2['image']}" \
            --pattern=':'
        then
            dict2['tag']="$( \
                koopa_print "${dict2['image']}" \
                | "${app['cut']}" -d ':' -f '2' \
            )"
            dict2['image']="$( \
                koopa_print "${dict2['image']}" \
                | "${app['cut']}" -d ':' -f '1' \
            )"
        else
            dict2['tag']="${dict['tag']}"
        fi
        dict2['source_image']="${dict['docker_dir']}/\
${dict2['image']}/${dict2['tag']}"
        koopa_assert_is_dir "${dict2['source_image']}"
        dict2['tags_file']="${dict2['source_image']}/tags.txt"
        if [[ -f "${dict2['tags_file']}" ]]
        then
            readarray -t tags < "${dict2['tags_file']}"
        fi
        if [[ -L "${dict2['source_image']}" ]]
        then
            tags+=("${dict2['tag']}")
            dict2['source_image']="$(koopa_realpath "${dict2['source_image']}")"
            dict2['tag']="$(koopa_basename "${dict2['source_image']}")"
        fi
        tags+=(
            "${dict2['tag']}"
            "${dict2['tag']}-$(${app['date']} '+%Y%m%d')"
        )
        readarray -t tags <<< "$( \
            koopa_print "${tags[@]}" \
            | "${app['sort']}" -u \
        )"
        for tag in "${tags[@]}"
        do
            build_args+=("--tag=${dict2['image']}:${tag}")
        done
        platforms=('linux/amd64')
        dict2['platforms_file']="${dict2['source_image']}/platforms.txt"
        if [[ -f "${dict2['platforms_file']}" ]]
        then
            readarray -t platforms < "${dict2['platforms_file']}"
        fi
        dict2['platforms_string']="$(koopa_paste --sep=',' "${platforms[@]}")"
        build_args+=("--platform=${dict2['platforms_string']}")
        if [[ -n "${dict['memory']}" ]]
        then
            build_args+=(
                "--memory=${dict['memory']}"
                "--memory-swap=${dict['memory']}"
            )
        fi
        build_args+=(
            '--no-cache'
            '--progress=auto'
            '--pull'
        )
        if [[ "${dict['push']}" -eq 1 ]]
        then
            build_args+=('--push')
        fi
        build_args+=("${dict2['source_image']}")
        if [[ "${dict['delete']}" -eq 1 ]]
        then
            koopa_alert "Pruning images '${dict2['image']}:${dict2['tag']}'."
            readarray -t image_ids <<< "$( \
                "${app['docker']}" image ls \
                    --filter reference="${dict2['image']}:${dict2['tag']}" \
                    --quiet \
            )"
            if koopa_is_array_non_empty "${image_ids[@]:-}"
            then
                "${app['docker']}" image rm --force "${image_ids[@]}"
            fi
        fi
        koopa_alert "Building '${dict2['source_image']}' Docker image."
        koopa_dl 'Build args' "${build_args[*]}"
        "${app['docker']}" login "${dict['server']}" >/dev/null || return 1
        dict2['build_name']="$(koopa_basename "${dict2['image']}")"
        "${app['docker']}" buildx rm \
            "${dict2['build_name']}" \
            &>/dev/null \
            || true
        "${app['docker']}" buildx create \
            --name="${dict2['build_name']}" \
            --use \
            >/dev/null
        "${app['docker']}" buildx build "${build_args[@]}" || return 1
        "${app['docker']}" buildx rm "${dict2['build_name']}"
        "${app['docker']}" image ls \
            --filter \
            reference="${dict2['image']}:${dict2['tag']}"
        koopa_alert_success "Build of '${dict2['source_image']}' \
was successful."
    done
    return 0
}

koopa_docker_ghcr_login() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['docker']="$(koopa_locate_docker)"
    )
    [[ -x "${app['docker']}" ]] || return 1
    declare -A dict=(
        ['pat']="${GHCR_PAT:?}"
        ['server']='ghcr.io'
        ['user']="${GHCR_USER:?}"
    )
    koopa_print "${dict['pat']}" \
        | "${app['docker']}" login \
            "${dict['server']}" \
            -u "${dict['user']}" \
            --password-stdin
    return 0
}

koopa_docker_ghcr_push() {
    local app dict
    koopa_assert_has_args_eq "$#" 3
    declare -A app=(
        ['docker']="$(koopa_locate_docker)"
    )
    [[ -x "${app['docker']}" ]] || return 1
    declare -A dict=(
        ['image_name']="${2:?}"
        ['owner']="${1:?}"
        ['server']='ghcr.io'
        ['version']="${3:?}"
    )
    dict['url']="${dict['server']}/${dict['owner']}/\
${dict['image_name']}:${dict['version']}"
    koopa_docker_ghcr_login
    "${app['docker']}" push "${dict['url']}"
    return 0
}

koopa_docker_is_build_recent() {
    local app dict image pos
    koopa_assert_has_args "$#"
    declare -A app=(
        ['date']="$(koopa_locate_date)"
        ['docker']="$(koopa_locate_docker)"
        ['sed']="$(koopa_locate_sed)"
    )
    [[ -x "${app['date']}" ]] || return 1
    [[ -x "${app['docker']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict=(
        ['days']=7
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--days='*)
                dict['days']="${1#*=}"
                shift 1
                ;;
            '--days')
                dict['days']="${2:?}"
                shift 2
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    dict['seconds']="$((dict[days] * 86400))"
    for image in "$@"
    do
        local dict2
        declare -A dict2=(
            ['current']="$("${app['date']}" -u '+%s')"
            ['image']="$image"
        )
        "${app['docker']}" pull "${dict2['image']}" >/dev/null
        dict2['json']="$( \
            "${app['docker']}" inspect \
                --format='{{json .Created}}' \
                "${dict2['image']}" \
        )"
        dict2['created']="$( \
            koopa_grep \
                --only-matching \
                --pattern='[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}' \
                --regex \
                --string="${dict2['json']}" \
            | "${app['sed']}" 's/T/ /' \
            | "${app['sed']}" 's/\$/ UTC/'
        )"
        dict2['created']="$( \
            "${app['date']}" --utc --date="${dict2['created']}" '+%s' \
        )"
        dict2['diff']=$((dict2['current'] - dict2['created']))
        [[ "${dict2['diff']}" -le "${dict['seconds']}" ]] && continue
        return 1
    done
    return 0
}

koopa_docker_prune_all_images() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['docker']="$(koopa_locate_docker)"
    )
    [[ -x "${app['docker']}" ]] || return 1
    koopa_alert 'Pruning Docker images.'
    "${app['docker']}" system prune --all --force || true
    "${app['docker']}" images
    koopa_alert 'Pruning Docker buildx.'
    "${app['docker']}" buildx prune --all --force --verbose || true
    "${app['docker']}" buildx ls
    return 0
}

koopa_docker_prune_all_stale_tags() {
    koopa_assert_has_no_args "$#"
    koopa_r_koopa 'cliDockerPruneAllStaleTags' "$@"
    return 0
}

koopa_docker_prune_old_images() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['docker']="$(koopa_locate_docker)"
    )
    [[ -x "${app['docker']}" ]] || return 1
    koopa_alert 'Pruning Docker images older than 3 months.'
    "${app['docker']}" image prune \
        --all \
        --filter 'until=2160h' \
        --force \
        || true
    "${app['docker']}" image prune --force || true
    return 0
}

koopa_docker_prune_stale_tags() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDockerPruneStaleTags' "$@"
    return 0
}

koopa_docker_push() {
    local app dict pattern
    koopa_assert_has_args "$#"
    declare -A app=(
        ['docker']="$(koopa_locate_docker)"
        ['sed']="$(koopa_locate_sed)"
        ['sort']="$(koopa_locate_sort)"
        ['tr']="$(koopa_locate_tr)"
    )
    [[ -x "${app['docker']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['tr']}" ]] || return 1
    declare -A dict=(
        ['server']='docker.io'
    )
    for pattern in "$@"
    do
        local dict2 image images
        declare -A dict2=(
            ['pattern']="$pattern"
        )
        koopa_assert_is_matching_regex \
            --string="${dict2['pattern']}" \
            --pattern='^.+/.+$'
        dict2['json']="$( \
            "${app['docker']}" inspect \
                --format="{{json .RepoTags}}" \
                "${dict2['pattern']}" \
        )"
        readarray -t images <<< "$( \
            koopa_print "${dict2['json']}" \
                | "${app['tr']}" ',' '\n' \
                | "${app['sed']}" 's/^\[//' \
                | "${app['sed']}" 's/\]$//' \
                | "${app['sed']}" 's/^\"//g' \
                | "${app['sed']}" 's/\"$//g' \
                | "${app['sort']}" \
        )"
        if koopa_is_array_empty "${images[@]:-}"
        then
            koopa_stop "Failed to match any images with '${dict2['pattern']}'."
        fi
        for image in "${images[@]}"
        do
            koopa_alert "Pushing '${image}' to '${dict['server']}'."
            "${app['docker']}" push "${dict['server']}/${image}"
        done
    done
    return 0
}

koopa_docker_remove() {
    local app pattern
    koopa_assert_has_args "$#"
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
        ['docker']="$(koopa_locate_docker)"
        ['xargs']="$(koopa_locate_xargs)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['docker']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    for pattern in "$@"
    do
        "${app['docker']}" images \
            | koopa_grep --pattern="$pattern" \
            | "${app['awk']}" '{print $3}' \
            | "${app['xargs']}" "${app['docker']}" rmi --force
    done
    return 0
}

koopa_docker_run() {
    local app dict pos run_args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['docker']="$(koopa_locate_docker)"
    )
    [[ -x "${app['docker']}" ]] || return 1
    declare -A dict=(
        ['arm']=0
        ['bash']=0
        ['bind']=0
        ['workdir']='/mnt/work'
        ['x86']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--arm')
                dict['arm']=1
                shift 1
                ;;
            '--bash')
                dict['bash']=1
                shift 1
                ;;
            '--bind')
                dict['bind']=1
                shift 1
                ;;
            '--x86')
                dict['x86']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_eq "$#" 1
    dict['image']="${1:?}"
    "${app['docker']}" pull "${dict['image']}"
    run_args=(
        '--interactive'
        '--tty'
    )
    if [[ "${dict['bind']}" -eq 1 ]]
    then
        if [[ "${HOME:?}" == "${PWD:?}" ]]
        then
            koopa_stop "Do not set '--bind' when running at HOME."
        fi
        run_args+=(
            "--volume=${PWD:?}:${dict['workdir']}"
            "--workdir=${dict['workdir']}"
        )
    fi
    if [[ "${dict['arm']}" -eq 1 ]]
    then
        run_args+=('--platform=linux/arm64')
    elif [[ "${dict['x86']}" -eq 1 ]]
    then
        run_args+=('--platform=linux/amd64')
    fi
    run_args+=("${dict['image']}")
    if [[ "${dict['bash']}" -eq 1 ]]
    then
        run_args+=('bash' '-il')
    fi
    "${app['docker']}" run "${run_args[@]}"
    return 0
}

koopa_docker_tag() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['docker']="$(koopa_locate_docker)"
    )
    [[ -x "${app['docker']}" ]] || return 1
    declare -A dict=(
        ['dest_tag']="${3:-}"
        ['image']="${1:?}"
        ['server']='docker.io'
        ['source_tag']="${2:?}"
    )
    [[ -z "${dict['dest_tag']}" ]] && dict['dest_tag']='latest'
    if ! koopa_str_detect_fixed \
        --string="${dict['image']}" \
        --pattern='/'
    then
        dict['image']="acidgenomics/${dict['image']}"
    fi
    if [[ "${dict['source_tag']}" == "${dict['dest_tag']}" ]]
    then
        koopa_alert_info "Source tag identical to destination \
('${dict['source_tag']}')."
        return 0
    fi
    koopa_alert "Tagging '${dict['image']}:${dict['source_tag']}' \
as '${dict['dest_tag']}'."
    "${app['docker']}" login "${dict['server']}" >/dev/null || return 1
    "${app['docker']}" pull \
        "${dict['server']}/${dict['image']}:${dict['source_tag']}"
    "${app['docker']}" tag \
        "${dict['image']}:${dict['source_tag']}" \
        "${dict['image']}:${dict['dest_tag']}"
    "${app['docker']}" push \
        "${dict['server']}/${dict['image']}:${dict['dest_tag']}"
    return 0
}

koopa_dotfiles_config_link() {
    koopa_assert_has_no_args "$#"
    koopa_print "$(koopa_config_prefix)/dotfiles"
    return 0
}

koopa_download_cran_latest() {
    local app file name pattern url
    koopa_assert_has_args "$#"
    declare -A app=(
        ['head']="$(koopa_locate_head --allow-system)"
    )
    [[ -x "${app['head']}" ]] || return 1
    for name in "$@"
    do
        url="https://cran.r-project.org/web/packages/${name}/"
        pattern="${name}_[-.0-9]+.tar.gz"
        file="$( \
            koopa_parse_url "$url" \
            | koopa_grep \
                --only-matching \
                --pattern="$pattern" \
                --regex \
            | "${app['head']}" -n 1 \
        )"
        koopa_download "https://cran.r-project.org/src/contrib/${file}"
    done
    return 0
}

koopa_download_github_latest() {
    local api_url app repo tag tarball_url
    koopa_assert_has_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut --allow-system)"
        ['tr']="$(koopa_locate_tr --allow-system)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['tr']}" ]] || return 1
    for repo in "$@"
    do
        api_url="https://api.github.com/repos/${repo}/releases/latest"
        tarball_url="$( \
            koopa_parse_url "$api_url" \
            | koopa_grep --pattern='tarball_url' \
            | "${app['cut']}" -d ':' -f '2,3' \
            | "${app['tr']}" --delete ' ,"' \
        )"
        tag="$(koopa_basename "$tarball_url")"
        koopa_download "$tarball_url" "${tag}.tar.gz"
    done
    return 0
}

koopa_download() {
    local app bool dict download_args pos
    koopa_assert_has_args "$#"
    declare -A bool=(
        ['decompress']=0
        ['extract']=0
        ['progress']=1
    )
    declare -A dict=(
        ['engine']='curl'
        ['file']="${2:-}"
        ['url']="${1:?}"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--engine='*)
                dict['engine']="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict['engine']="${2:?}"
                shift 2
                ;;
            '--decompress')
                bool['decompress']=1
                shift 1
                ;;
            '--extract')
                bool['extract']=1
                shift 1
                ;;
            '--progress')
                bool['progress']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_le "$#" 2
    declare -A app
    app['download']="$("koopa_locate_${dict['engine']}" --allow-system)"
    [[ -x "${app['download']}" ]] || return 1
    if [[ -z "${dict['file']}" ]]
    then
        dict['file']="$(koopa_basename "${dict['url']}")"
        if koopa_str_detect_fixed --string="${dict['file']}" --pattern='%'
        then
            dict['file']="$( \
                koopa_print "${dict['file']}" \
                | koopa_gsub \
                    --fixed \
                    --pattern='%2D' \
                    --replacement='-' \
                | koopa_gsub \
                    --fixed \
                    --pattern='%2E' \
                    --replacement='.' \
                | koopa_gsub \
                    --fixed \
                    --pattern='%5F' \
                    --replacement='_' \
                | koopa_gsub \
                    --fixed \
                    --pattern='%20' \
                    --replacement='_' \
            )"
        fi
    fi
    if ! koopa_str_detect_fixed \
        --string="${dict['file']}" \
        --pattern='/'
    then
        dict['file']="${PWD:?}/${dict['file']}"
    fi
    download_args=()
    case "${dict['engine']}" in
        'curl')
            download_args+=(
                '--disable' # Ignore '~/.curlrc'. Must come first.
                '--create-dirs'
                '--fail'
                '--location'
                '--output' "${dict['file']}"
                '--retry' 5
                '--show-error'
            )
            if [[ "${bool['progress']}" -eq 0 ]]
            then
                download_args+=('--silent')
            fi
            ;;
        'wget')
            download_args+=(
                "--output-document=${dict['file']}"
                '--no-verbose'
            )
            if [[ "${bool['progress']}" -eq 0 ]]
            then
                download_args+=('--quiet')
            fi
            ;;
    esac
    download_args+=("${dict['url']}")
    koopa_alert "Downloading '${dict['url']}' to '${dict['file']}'."
    "${app['download']}" "${download_args[@]}"
    if [[ "${bool['decompress']}" -eq 1 ]]
    then
        koopa_decompress "${dict['file']}"
    elif [[ "${bool['extract']}" -eq 1 ]]
    then
        koopa_extract "${dict['file']}"
    fi
    return 0
}

koopa_enable_passwordless_sudo() {
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A dict
    dict['group']="$(koopa_admin_group)"
    dict['file']="/etc/sudoers.d/koopa-${dict['group']}"
    if [[ -f "${dict['file']}" ]]
    then
        koopa_alert_success "Passwordless sudo for '${dict['group']}' group \
already enabled at '${dict['file']}'."
        return 0
    fi
    koopa_alert "Modifying '${dict['file']}' to include '${dict['group']}'."
    dict['string']="%${dict['group']} ALL=(ALL) NOPASSWD: ALL"
    koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    koopa_chmod --sudo '0440' "${dict['file']}"
    koopa_alert_success "Passwordless sudo enabled for '${dict['group']}' \
at '${dict['file']}'."
    return 0
}

koopa_enable_shell_for_all_users() {
    local app apps dict
    koopa_assert_has_args "$#"
    koopa_is_admin || return 0
    declare -A dict=(
        ['etc_file']='/etc/shells'
        ['user']="$(koopa_user)"
    )
    apps=("$@")
    for app in "${apps[@]}"
    do
        if koopa_file_detect_fixed \
            --file="${dict['etc_file']}" \
            --pattern="$app"
        then
            continue
        fi
        koopa_alert "Updating '${dict['etc_file']}' to include '${app}'."
        koopa_sudo_append_string \
            --file="${dict['etc_file']}" \
            --string="$app"
        koopa_alert_info "Run 'chsh -s ${app} ${dict['user']}' to change the \
default shell."
    done
    return 0
}

koopa_ensure_newline_at_end_of_file() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['tail']="$(koopa_locate_tail)"
    )
    [[ -x "${app['tail']}" ]] || return 1
    declare -A dict=(
        ['file']="${1:?}"
    )
    [[ -n "$("${app['tail']}" --bytes=1 "${dict['file']}")" ]] || return 0
    printf '\n' >> "${dict['file']}"
    return 0
}

koopa_entab() {
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        ['vim']="$(koopa_locate_vim)"
    )
    [[ -x "${app['vim']}" ]] || return 1
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app['vim']}" \
            -c 'set noexpandtab tabstop=4 shiftwidth=4' \
            -c ':%retab!' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}

koopa_eol_lf() {
    local app file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    declare -A app
    app['perl']="$(koopa_locate_perl)"
    [[ -x "${app['perl']}" ]] || return 1
    for file in "$@"
    do
        koopa_alert "Setting EOL as LF in '${file}'."
        "${app['perl']}" -pi -e 's/\r\n/\n/g' "$file"
        "${app['perl']}" -pi -e 's/\r/\n/g' "$file"
    done
}

koopa_exec_dir() {
    local file prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        koopa_assert_is_dir "$prefix"
        for file in "${prefix}/"*'.sh'
        do
            [ -x "$file" ] || continue
            "$file"
        done
    done
    return 0
}

koopa_extract_all() {
    local file
    koopa_assert_has_args_ge "$#" 2
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        koopa_assert_is_matching_regex \
            --pattern='\.tar\.(bz2|gz|xz)$' \
            --string="$file"
        koopa_extract "$file"
    done
    return 0
}

koopa_extract_version() {
    local app arg dict
    declare -A app
    app['head']="$(koopa_locate_head --allow-system)"
    [[ -x "${app['head']}" ]] || return 1
    declare -A dict=(
        ['pattern']="$(koopa_version_pattern)"
    )
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for arg in "${args[@]}"
    do
        local str
        str="$( \
            koopa_grep \
                --only-matching \
                --pattern="${dict['pattern']}" \
                --regex \
                --string="$arg" \
            | "${app['head']}" -n 1 \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}

koopa_extract() {
    local app cmd_args dict file
    koopa_assert_has_args "$#"
    declare -A app
    declare -A dict
    dict['orig_path']="${PATH:-}"
    for file in "$@"
    do
        koopa_assert_is_file "$file"
        file="$(koopa_realpath "$file")"
        koopa_alert "Extracting '${file}'."
        case "$file" in
            *'.tar.bz2' | \
            *'.tar.gz' | \
            *'.tar.xz')
                app['cmd']="$(koopa_locate_tar --allow-system)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-x' # '--extract'.
                )
                case "$file" in
                    *'.bz2')
                        app['cmd2']="$(koopa_locate_bzip2 --allow-system)"
                        [[ -x "${app['cmd2']}" ]] || return 1
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app['cmd2']}")"
                        cmd_args+=('-j') # '--bzip2'.
                        ;;
                    *'.gz')
                        app['cmd2']="$(koopa_locate_gzip --allow-system)"
                        [[ -x "${app['cmd2']}" ]] || return 1
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app['cmd2']}")"
                        cmd_args+=('-z') # '--gzip'.
                        ;;
                    *'.xz')
                        app['cmd2']="$(koopa_locate_xz --allow-system)"
                        [[ -x "${app['cmd2']}" ]] || return 1
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app['cmd2']}")"
                        cmd_args+=('-J') # '--xz'.
                        ;;
                esac
                ;;
            *'.bz2')
                app['cmd']="$(koopa_locate_bunzip2 --allow-system)"
                cmd_args=("$file")
                ;;
            *'.gz')
                app['cmd']="$(koopa_locate_gzip --allow-system)"
                cmd_args=(
                    '-d' # '--decompress'.
                    "$file"
                )
                ;;
            *'.tar')
                app['cmd']="$(koopa_locate_tar --allow-system)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-x' # '--extract'.
                )
                ;;
            *'.tbz2')
                app['cmd']="$(koopa_locate_tar --allow-system)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-j' # '--bzip2'.
                    '-x' # '--extract'.
                )
                ;;
            *'.tgz')
                app['cmd']="$(koopa_locate_tar --allow-system)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-x' # '--extract'.
                    '-z' # '--gzip'.
                )
                ;;
            *'.xz')
                app['cmd']="$(koopa_locate_xz --allow-system)"
                cmd_args=(
                    '-d' # '--decompress'.
                    "$file"
                    )
                ;;
            *'.zip')
                app['cmd']="$(koopa_locate_unzip --allow-system)"
                cmd_args=(
                    '-qq'
                    "$file"
                )
                ;;
            *'.Z')
                app['cmd']="$(koopa_locate_uncompress --allow-system)"
                cmd_args=("$file")
                ;;
            *'.7z')
                app['cmd']="$(koopa_locate_7z)"
                cmd_args=(
                    '-x'
                    "$file"
                )
                ;;
            *)
                koopa_stop "Unsupported extension: '${file}'."
                ;;
        esac
        [[ -x "${app['cmd']}" ]] || return 1
        "${app['cmd']}" "${cmd_args[@]}"
    done
    export PATH="${dict['orig_path']}"
    return 0
}

koopa_fasta_generate_chromosomes_file() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut)"
        ['grep']="$(koopa_locate_grep)"
        ['sed']="$(koopa_locate_sed)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['grep']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict=(
        ['genome_fasta_file']=''
        ['output_file']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--output-file='*)
                dict['output_file']="${1#*=}"
                shift 1
                ;;
            '--output-file')
                dict['output_file']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--output-file' "${dict['output_file']}"
    koopa_assert_is_not_file "${dict['output_file']}"
    koopa_assert_is_file "${dict['genome_fasta_file']}"
    koopa_alert "Generating '${dict['output_file']}' from \
'${dict['genome_fasta_file']}'."
    "${app['grep']}" '^>' \
        <(koopa_decompress --stdout "${dict['genome_fasta_file']}") \
        | "${app['cut']}" -d ' ' -f '1' \
        > "${dict['output_file']}"
    "${app['sed']}" \
        -i.bak \
        's/>//g' \
        "${dict['output_file']}"
    koopa_assert_is_file "${dict['output_file']}"
    return 0
}

koopa_fasta_generate_decoy_transcriptome_file() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['cat']="$(koopa_locate_cat --allow-system)"
    )
    [[ -x "${app['cat']}" ]] || return 1
    declare -A dict=(
        ['genome_fasta_file']=''
        ['output_file']='' # 'gentrome.fa.gz'
        ['transcriptome_fasta_file']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--output-file='*)
                dict['output_file']="${1#*=}"
                shift 1
                ;;
            '--output-file')
                dict['output_file']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--output-file' "${dict['output_file']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    koopa_assert_is_not_file "${dict['output_file']}"
    koopa_assert_is_file \
        "${dict['genome_fasta_file']}" \
        "${dict['transcriptome_fasta_file']}"
    dict['genome_fasta_file']="$(koopa_realpath "${dict['genome_fasta_file']}")"
    dict['transcriptome_fasta_file']="$( \
        koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    koopa_assert_is_matching_regex \
        --pattern='\.gz$' \
        --string="${dict['genome_fasta_file']}"
    koopa_assert_is_matching_regex \
        --pattern='\.gz$' \
        --string="${dict['transcriptome_fasta_file']}"
    koopa_assert_is_matching_regex \
        --pattern='\.gz$' \
        --string="${dict['output_file']}"
    koopa_alert "Generating decoy-aware transcriptome \
at '${dict['output_file']}'."
    koopa_dl \
        'Genome FASTA file' "${dict['genome_fasta_file']}" \
        'Transcriptome FASTA file' "${dict['transcriptome_fasta_file']}"
    "${app['cat']}" \
        "${dict['transcriptome_fasta_file']}" \
        "${dict['genome_fasta_file']}" \
        > "${dict['output_file']}"
    koopa_assert_is_file "${dict['output_file']}"
    return 0
}

koopa_fastq_detect_quality_score() {
    local app file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    declare -A app=(
        ['awk']="$(koopa_locate_awk --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
        ['od']="$(koopa_locate_od --allow-system)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['od']}" ]] || return 1
    for file in "$@"
    do
        local str
        str="$( \
            "${app['head']}" -n 1000 \
                <(koopa_decompress --stdout "$file") \
            | "${app['awk']}" '{if(NR%4==0) printf("%s",$0);}' \
            | "${app['od']}" \
                --address-radix='n' \
                --format='u1' \
            | "${app['awk']}" 'BEGIN{min=100;max=0;} \
                {for(i=1;i<=NF;i++) \
                    {if($i>max) max=$i; \
                        if($i<min) min=$i;}}END \
                    {if(max<=74 && min<59) \
                        print "Phred+33"; \
                    else if(max>73 && min>=64) \
                        print "Phred+64"; \
                    else if(min>=59 && min<64 && max>73) \
                        print "Solexa+64"; \
                    else print "Unknown"; \
                }' \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}

koopa_fastq_lanepool() {
    local app basenames dict fastq_files head i out tail
    declare -A app=(
        ['cat']="$(koopa_locate_cat --allow-system)"
    )
    [[ -x "${app['cat']}" ]] || return 1
    declare -A dict=(
        ['prefix']='lanepool'
        ['source_dir']="${PWD:?}"
        ['target_dir']="${PWD:?}"
    )
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--source-dir='*)
                dict['source_dir']="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict['source_dir']="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict['source_dir']}"
    dict['source_dir']="$(koopa_realpath "${dict['source_dir']}")"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*_L001_*.fastq*' \
            --prefix="${dict['source_dir']}" \
            --sort \
            --type='f' \
    )"
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa_stop "No lane-split FASTQ files in '${dict['source_dir']}'."
    fi
    dict['target_dir']="$(koopa_init_dir "${dict['target_dir']}")"
    basenames=()
    for i in "${fastq_files[@]}"
    do
        basenames+=("$(koopa_basename "$i")")
    done
    head=()
    for i in "${basenames[@]}"
    do
        i="${i//_L001_*/}"
        head+=("$i")
    done
    tail=()
    for i in "${basenames[@]}"
    do
        i="${i//*_L001_/}"
        tail+=("$i")
    done
    out=()
    for i in "${basenames[@]}"
    do
        i="${i//_L001/}"
        i="${dict['target_dir']}/${dict['prefix']}_${i}"
        out+=("$i")
    done
    for i in "${!out[@]}"
    do
        "${app['cat']}" \
            "${dict['source_dir']}/${head[$i]}_L00"[1-9]"_${tail[$i]}" \
            > "${out[$i]}"
    done
    return 0
}

koopa_fastq_number_of_reads() {
    local app file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
        ['wc']="$(koopa_locate_wc)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['wc']}" ]] || return 1
    for file in "$@"
    do
        local num
        num="$( \
            "${app['wc']}" -l \
                <(koopa_decompress --stdout "$file") \
            | "${app['awk']}" '{print $1/4}' \
        )"
        [[ -n "$num" ]] || return 1
        koopa_print "$num"
    done
    return 0
}

koopa_file_count() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['wc']="$(koopa_locate_wc)"
    )
    [[ -x "${app['wc']}" ]] || return 1
    declare -A dict=(
        ['prefix']="${1:?}"
    )
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    dict['out']="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --type='f' \
            --prefix="${dict['prefix']}" \
        | "${app['wc']}" -l \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}

koopa_file_detect_fixed() {
    __koopa_file_detect --mode='fixed' "$@"
}

koopa_file_detect_regex() {
    __koopa_file_detect --mode='regex' "$@"
}

koopa_file_ext_2() {
    local app file x
    koopa_assert_has_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    for file in "$@"
    do
        if koopa_has_file_ext "$file"
        then
            x="$( \
                koopa_print "$file" \
                | "${app['cut']}" -d '.' -f '2-' \
            )"
        else
            x=''
        fi
        koopa_print "$x"
    done
    return 0
}

koopa_file_ext() {
    local file x
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        if koopa_has_file_ext "$file"
        then
            x="${file##*.}"
        else
            x=''
        fi
        koopa_print "$x"
    done
    return 0
}

koopa_find_and_move_in_sequence() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliFindAndMoveInSequence' "$@"
    return 0
}

koopa_find_and_replace_in_file() {
    local app dict flags perl_cmd pos
    koopa_assert_has_args "$#"
    declare -A app
    app['perl']="$(koopa_locate_perl --allow-system)"
    [[ -x "${app['perl']}" ]] || return 1
    declare -A dict=(
        ['multiline']=0
        ['pattern']=''
        ['regex']=0
        ['replacement']=''
        ['sudo']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--replacement='*)
                dict['replacement']="${1#*=}"
                shift 1
                ;;
            '--replacement')
                dict['replacement']="${2:-}"
                shift 2
                ;;
            '--fixed')
                dict['regex']=0
                shift 1
                ;;
            '--multiline')
                dict['multiline']=1
                shift 1
                ;;
            '--regex')
                dict['regex']=1
                shift 1
                ;;
            '--sudo')
                dict['sudo']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict['pattern']}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    if [[ "${dict['regex']}" -eq 1 ]]
    then
        dict['expr']="s|${dict['pattern']}|${dict['replacement']}|g"
    else
        dict['expr']=" \
            \$pattern = quotemeta '${dict['pattern']}'; \
            \$replacement = '${dict['replacement']}'; \
            s/\$pattern/\$replacement/g; \
        "
    fi
    flags=('-i' '-p')
    [[ "${dict['multiline']}" -eq 1 ]] && flags+=('-0')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        koopa_assert_is_admin
        app['sudo']="$(koopa_locate_sudo)"
        [[ -x "${app['sudo']}" ]] || return 1
        perl_cmd+=("${app['sudo']}" "${app['perl']}")
    else
        perl_cmd=("${app['perl']}")
    fi
    "${perl_cmd[@]}" "${flags[@]}" -e "${dict['expr']}" "$@"
    return 0
}

koopa_find_app_version() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['sort']="$(koopa_locate_sort)"
        ['tail']="$(koopa_locate_tail)"
    )
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['tail']}" ]] || return 1
    declare -A dict=(
        ['app_prefix']="$(koopa_app_prefix)"
        ['name']="${1:?}"
    )
    dict['prefix']="${dict['app_prefix']}/${dict['name']}"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['hit']="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['prefix']}" \
            --type='d' \
        | "${app['sort']}" \
        | "${app['tail']}" -n 1 \
    )"
    [[ -d "${dict['hit']}" ]] || return 1
    dict['hit_bn']="$(koopa_basename "${dict['hit']}")"
    koopa_print "${dict['hit_bn']}"
    return 0
}

koopa_find_broken_symlinks() {
    local prefix str
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        str="$( \
            koopa_find \
                --engine='find' \
                --min-depth=1 \
                --prefix="$prefix" \
                --sort \
                --type='broken-symlink' \
        )"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}

koopa_find_dotfiles() {
    local app dict
    koopa_assert_has_args_eq "$#" 2
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
        ['basename']="$(koopa_locate_basename)"
        ['xargs']="$(koopa_locate_xargs)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['basename']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    declare -A dict=(
        ['type']="${1:?}"
        ['header']="${2:?}"
    )
    dict['str']="$( \
        koopa_find \
            --max-depth=1 \
            --pattern='.*' \
            --prefix="${HOME:?}" \
            --print0 \
            --sort \
            --type="${dict['type']}" \
        | "${app['xargs']}" -0 -n 1 "${app['basename']}" \
        | "${app['awk']}" '{print "    -",$0}' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_h2 "${dict['header']}:"
    koopa_print "${dict['str']}"
    return 0
}

koopa_find_empty_dirs() {
    local prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local str
        str="$( \
            koopa_find \
                --empty \
                --prefix="$prefix" \
                --sort \
                --type='d' \
        )"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}

koopa_find_files_without_line_ending() {
    local app files prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    declare -A app=(
        ['pcregrep']="$(koopa_locate_pcregrep)"
    )
    [[ -x "${app['pcregrep']}" ]] || return 1
    for prefix in "$@"
    do
        local str
        readarray -t files <<< "$(
            koopa_find \
                --min-depth=1 \
                --prefix="$(koopa_realpath "$prefix")" \
                --sort \
                --type='f' \
        )"
        koopa_is_array_non_empty "${files[@]:-}" || continue
        str="$("${app['pcregrep']}" -LMr '\n$' "${files[@]}")"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}

koopa_find_large_dirs() {
    local app prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    declare -A app=(
        ['du']="$(koopa_locate_du)"
        ['sort']="$(koopa_locate_sort)"
        ['tail']="$(koopa_locate_tail)"
    )
    [[ -x "${app['du']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['tail']}" ]] || return 1
    for prefix in "$@"
    do
        local str
        prefix="$(koopa_realpath "$prefix")"
        str="$( \
            "${app['du']}" \
                --max-depth=10 \
                --threshold=100000000 \
                "${prefix}"/* \
                2>/dev/null \
            | "${app['sort']}" --numeric-sort \
            | "${app['tail']}" -n 50 \
            || true \
        )"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}

koopa_find_large_files() {
    local app prefix str
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    declare -A app
    app['head']="$(koopa_locate_head --allow-system)"
    [[ -x "${app['head']}" ]] || return 1
    for prefix in "$@"
    do
        str="$( \
            koopa_find \
                --min-depth=1 \
                --prefix="$prefix" \
                --size='+100000000c' \
                --sort \
                --type='f' \
            | "${app['head']}" -n 50 \
        )"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}

koopa_find_non_symlinked_make_files() {
    local dict find_args
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['brew_prefix']="$(koopa_homebrew_prefix)"
        ['make_prefix']="$(koopa_make_prefix)"
    )
    find_args=(
        '--min-depth' 1
        '--prefix' "${dict['make_prefix']}"
        '--sort'
        '--type' 'f'
    )
    if koopa_is_linux
    then
        find_args+=(
            '--exclude' 'share/applications/**'
            '--exclude' 'share/emacs/site-lisp/**'
            '--exclude' 'share/zsh/site-functions/**'
        )
    elif koopa_is_macos
    then
        find_args+=(
            '--exclude' 'MacGPG2/**'
            '--exclude' 'gfortran/**'
            '--exclude' 'texlive/**'
        )
    fi
    if [[ "${dict['brew_prefix']}" == "${dict['make_prefix']}" ]]
    then
        find_args+=(
            '--exclude' 'Caskroom/**'
            '--exclude' 'Cellar/**'
            '--exclude' 'Homebrew/**'
            '--exclude' 'var/homebrew/**'
        )
    fi
    dict['out']="$(koopa_find "${find_args[@]}")"
    koopa_print "${dict['out']}"
    return 0
}

koopa_find_symlinks() {
    local dict hits symlink symlinks
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['source_prefix']=''
        ['target_prefix']=''
        ['verbose']=0
    )
    hits=()
    while (("$#"))
    do
        case "$1" in
            '--source-prefix='*)
                dict['source_prefix']="${1#*=}"
                shift 1
                ;;
            '--source-prefix')
                dict['source_prefix']="${2:?}"
                shift 2
                ;;
            '--target-prefix='*)
                dict['target_prefix']="${1#*=}"
                shift 1
                ;;
            '--target-prefix')
                dict['target_prefix']="${2:?}"
                shift 2
                ;;
            '--verbose')
                dict['verbose']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--source-prefix' "${dict['source_prefix']}" \
        '--target-prefix' "${dict['target_prefix']}"
    koopa_assert_is_dir "${dict['source_prefix']}" "${dict['target_prefix']}"
    dict['source_prefix']="$(koopa_realpath "${dict['source_prefix']}")"
    dict['target_prefix']="$(koopa_realpath "${dict['target_prefix']}")"
    readarray -t symlinks <<< "$(
        koopa_find \
            --prefix="${dict['target_prefix']}" \
            --sort \
            --type='l' \
    )"
    for symlink in "${symlinks[@]}"
    do
        local symlink_real
        symlink_real="$(koopa_realpath "$symlink")"
        if koopa_str_detect_regex \
            --pattern="^${dict['source_prefix']}/" \
            --string="$symlink_real"
        then
            if [[ "${dict['verbose']}" -eq 1 ]]
            then
                koopa_warn "${symlink} -> ${symlink_real}"
            fi
            hits+=("$symlink")
        fi
    done
    koopa_is_array_empty "${hits[@]}" && return 1
    koopa_print "${hits[@]}"
    return 0
}

koopa_find_user_profile() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['shell']="$(koopa_default_shell_name)"
    )
    case "${dict['shell']}" in
        'bash')
            dict['file']="${HOME}/.bashrc"
            ;;
        'zsh')
            dict['file']="${HOME}/.zshrc"
            ;;
        *)
            dict['file']="${HOME}/.profile"
            ;;
    esac
    [[ -n "${dict['file']}" ]] || return 1
    koopa_print "${dict['file']}"
    return 0
}

koopa_find() {
    local app dict exclude_arg exclude_arr find find_args results sorted_results
    declare -A app
    declare -A dict=(
        ['days_modified_gt']=''
        ['days_modified_lt']=''
        ['empty']=0
        ['engine']="${KOOPA_FIND_ENGINE:-}"
        ['exclude']=0
        ['max_depth']=''
        ['min_depth']=1
        ['pattern']=''
        ['print0']=0
        ['size']=''
        ['sort']=0
        ['sudo']=0
        ['type']=''
        ['verbose']=0
    )
    exclude_arr=()
    while (("$#"))
    do
        case "$1" in
            '--days-modified-before='*)
                dict['days_modified_gt']="${1#*=}"
                shift 1
                ;;
            '--days-modified-before')
                dict['days_modified_gt']="${2:?}"
                shift 2
                ;;
            '--days-modified-within='*)
                dict['days_modified_lt']="${1#*=}"
                shift 1
                ;;
            '--days-modified-within')
                dict['days_modified_lt']="${2:?}"
                shift 2
                ;;
            '--engine='*)
                dict['engine']="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict['engine']="${2:?}"
                shift 2
                ;;
            '--exclude='*)
                dict['exclude']=1
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                dict['exclude']=1
                exclude_arr+=("${2:?}")
                shift 2
                ;;
            '--max-depth='*)
                dict['max_depth']="${1#*=}"
                shift 1
                ;;
            '--max-depth')
                dict['max_depth']="${2:?}"
                shift 2
                ;;
            '--min-depth='*)
                dict['min_depth']="${1#*=}"
                shift 1
                ;;
            '--min-depth')
                dict['min_depth']="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
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
            '--size='*)
                dict['size']="${1#*=}"
                shift 1
                ;;
            '--size')
                dict['size']="${2:?}"
                shift 2
                ;;
            '--type='*)
                dict['type']="${1#*=}"
                shift 1
                ;;
            '--type')
                dict['type']="${2:?}"
                shift 2
                ;;
            '--empty')
                dict['empty']=1
                shift 1
                ;;
            '--print0')
                dict['print0']=1
                shift 1
                ;;
            '--sort')
                dict['sort']=1
                shift 1
                ;;
            '--sudo')
                dict['sudo']=1
                shift 1
                ;;
            '--verbose')
                dict['verbose']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    case "${dict['engine']}" in
        '')
            app['find']="$(koopa_locate_fd --allow-missing)"
            [[ -x "${app['find']}" ]] && dict['engine']='fd'
            if [[ -z "${dict['engine']}" ]]
            then
                dict['engine']='find'
                app['find']="$(koopa_locate_find --allow-system)"
                [[ -x "${app['find']}" ]] || return 1
            fi
            ;;
        'fd')
            app['find']="$(koopa_locate_fd)"
            [[ -x "${app['find']}" ]] || return 1
            ;;
        'find')
            app['find']="$(koopa_locate_find --allow-system)"
            [[ -x "${app['find']}" ]] || return 1
            ;;
    esac
    find=()
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        app['sudo']="$(koopa_locate_sudo)"
        [[ -x "${app['sudo']}" ]] || return 1
        find+=("${app['sudo']}")
    fi
    find+=("${app['find']}")
    case "${dict['engine']}" in
        'fd')
            find_args=(
                '--absolute-path'
                '--base-directory' "${dict['prefix']}"
                '--case-sensitive'
                '--glob'
                '--hidden'
                '--no-follow'
                '--no-ignore'
                '--one-file-system'
            )
            if [[ -n "${dict['min_depth']}" ]]
            then
                find_args+=('--min-depth' "${dict['min_depth']}")
            fi
            if [[ -n "${dict['max_depth']}" ]]
            then
                find_args+=('--max-depth' "${dict['max_depth']}")
            fi
            if [[ -n "${dict['type']}" ]]
            then
                case "${dict['type']}" in
                    'd')
                        dict['type']='directory'
                        ;;
                    'f')
                        dict['type']='file'
                        ;;
                    'l')
                        dict['type']='symlink'
                        ;;
                    *)
                        koopa_stop 'Invalid type argument for Rust fd.'
                        ;;
                esac
                find_args+=('--type' "${dict['type']}")
            fi
            if [[ "${dict['empty']}" -eq 1 ]]
            then
                find_args+=('--type' 'empty')
            fi
            if [[ -n "${dict['days_modified_gt']}" ]]
            then
                find_args+=(
                    '--changed-before'
                    "${dict['days_modified_gt']}d"
                )
            fi
            if [[ -n "${dict['days_modified_lt']}" ]]
            then
                find_args+=(
                    '--changed-within'
                    "${dict['days_modified_lt']}d"
                )
            fi
            if [[ "${dict['exclude']}" -eq 1 ]]
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    find_args+=('--exclude' "$exclude_arg")
                done
            fi
            if [[ -n "${dict['size']}" ]]
            then
                dict['size']="$( \
                    koopa_sub \
                        --pattern='c$' \
                        --replacement='b' \
                        "${dict['size']}" \
                )"
                find_args+=('--size' "${dict['size']}")
            fi
            if [[ "${dict['print0']}" -eq 1 ]]
            then
                find_args+=('--print0')
            fi
            if [[ -n "${dict['pattern']}" ]]
            then
                find_args+=("${dict['pattern']}")
            fi
            ;;
        'find')
            find_args=(
                "${dict['prefix']}"
                '-xdev'
            )
            if [[ -n "${dict['min_depth']}" ]]
            then
                find_args+=('-mindepth' "${dict['min_depth']}")
            fi
            if [[ -n "${dict['max_depth']}" ]]
            then
                find_args+=('-maxdepth' "${dict['max_depth']}")
            fi
            if [[ -n "${dict['pattern']}" ]]
            then
                if koopa_str_detect_fixed \
                    --pattern="{" \
                    --string="${dict['pattern']}"
                then
                    readarray -O "${#find_args[@]}" -t find_args <<< "$( \
                        local globs1 globs2 globs3 str
                        readarray -d ',' -t globs1 <<< "$( \
                            koopa_gsub \
                                --pattern='[{}]' \
                                --replacement='' \
                                "${dict['pattern']}" \
                        )"
                        globs2=()
                        for i in "${!globs1[@]}"
                        do
                            globs2+=(
                                "-name ${globs1[$i]}"
                            )
                        done
                        str="( $(koopa_paste --sep=' -o ' "${globs2[@]}") )"
                        readarray -d ' ' -t globs3 <<< "$(
                            koopa_print "$str"
                        )"
                        koopa_print "${globs3[@]}"
                    )"
                else
                    find_args+=('-name' "${dict['pattern']}")
                fi
            fi
            if [[ -n "${dict['type']}" ]]
            then
                case "${dict['type']}" in
                    'broken-symlink')
                        find_args+=('-xtype' 'l')
                        ;;
                    'd' | \
                    'f' | \
                    'l')
                        find_args+=('-type' "${dict['type']}")
                        ;;
                    *)
                        koopa_stop 'Invalid file type argument.'
                        ;;
                esac
            fi
            if [[ -n "${dict['days_modified_gt']}" ]]
            then
                find_args+=('-mtime' "+${dict['days_modified_gt']}")
            fi
            if [[ -n "${dict['days_modified_lt']}" ]]
            then
                find_args+=('-mtime' "-${dict['days_modified_lt']}")
            fi
            if [[ "${dict['exclude']}" -eq 1 ]]
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    exclude_arg="$( \
                        koopa_sub \
                            --pattern='^' \
                            --replacement="${dict['prefix']}/" \
                            "$exclude_arg" \
                    )"
                    find_args+=('-not' '-path' "$exclude_arg")
                done
            fi
            if [[ "${dict['empty']}" -eq 1 ]]
            then
                find_args+=('-empty')
            fi
            if [[ -n "${dict['size']}" ]]
            then
                find_args+=('-size' "${dict['size']}")
            fi
            if [[ "${dict['print0']}" -eq 1 ]]
            then
                find_args+=('-print0')
            else
                find_args+=('-print')
            fi
            ;;
        *)
            koopa_stop 'Invalid find engine.'
            ;;
    esac
    if [[ "${dict['verbose']}" -eq 1 ]]
    then
        koopa_warn "Find command: ${find[*]} ${find_args[*]}"
    fi
    if [[ "${dict['sort']}" -eq 1 ]]
    then
        app['sort']="$(koopa_locate_sort --allow-system)"
        [[ -x "${app['sort']}" ]] || return 1
    fi
    if [[ "${dict['print0']}" -eq 1 ]]
    then
        readarray -t -d '' results < <( \
            "${find[@]}" "${find_args[@]}" 2>/dev/null \
        )
        koopa_is_array_non_empty "${results[@]:-}" || return 1
        if [[ "${dict['sort']}" -eq 1 ]]
        then
            readarray -t -d '' sorted_results < <( \
                printf '%s\0' "${results[@]}" | "${app['sort']}" -z \
            )
            results=("${sorted_results[@]}")
        fi
        printf '%s\0' "${results[@]}"
    else
        readarray -t results <<< "$( \
            "${find[@]}" "${find_args[@]}" 2>/dev/null \
        )"
        koopa_is_array_non_empty "${results[@]:-}" || return 1
        if [[ "${dict['sort']}" -eq 1 ]]
        then
            readarray -t sorted_results <<< "$( \
                koopa_print "${results[@]}" | "${app['sort']}" \
            )"
            results=("${sorted_results[@]}")
        fi
        koopa_print "${results[@]}"
    fi
    return 0
}

koopa_fix_pyenv_permissions() {
    local pyenv_prefix
    koopa_assert_has_no_args "$#"
    pyenv_prefix="$(koopa_pyenv_prefix)"
    [[ -d "${pyenv_prefix}/shims" ]] || return 0
    koopa_chmod '0777' "${pyenv_prefix}/shims"
    return 0
}

koopa_fix_rbenv_permissions() {
    local rbenv_prefix
    koopa_assert_has_no_args "$#"
    rbenv_prefix="$(koopa_rbenv_prefix)"
    [[ -d "${rbenv_prefix}/shims" ]] || return 0
    koopa_chmod '0777' "${rbenv_prefix}/shims"
    return 0
}

koopa_fix_zsh_permissions() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['app_prefix']="$(koopa_app_prefix)"
        ['koopa_prefix']="$(koopa_koopa_prefix)"
    )
    if koopa_is_shared_install
    then
        dict['stat_user']="$( \
            koopa_stat_user "${dict['koopa_prefix']}/lang/shell/zsh" \
        )"
        if [[ "${dict['stat_user']}" != 0 ]]
        then
            koopa_chown --sudo 'root' \
                "${dict['koopa_prefix']}/lang/shell/zsh" \
                "${dict['koopa_prefix']}/lang/shell/zsh/functions"
            koopa_chmod --sudo 'g-w' \
                "${dict['koopa_prefix']}/lang/shell/zsh" \
                "${dict['koopa_prefix']}/lang/shell/zsh/functions"
        fi
    else
        koopa_chmod 'g-w' \
            "${dict['koopa_prefix']}/lang/shell/zsh" \
            "${dict['koopa_prefix']}/lang/shell/zsh/functions"
    fi
    if [[ -d "${dict['app_prefix']}/zsh" ]]
    then
        koopa_chmod 'g-w' \
            "${dict['app_prefix']}/zsh/"*'/share/zsh' \
            "${dict['app_prefix']}/zsh/"*'/share/zsh/'* \
            "${dict['app_prefix']}/zsh/"*'/share/zsh/'*'/functions'
    fi
    return 0
}

koopa_ftp_mirror() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['wget']="$(koopa_locate_wget)"
    )
    [[ -x "${app['wget']}" ]] || return 1
    declare -A dict=(
        ['dir']=''
        ['host']=''
        ['user']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--dir='*)
                dict['dir']="${1#*=}"
                shift 1
                ;;
            '--dir')
                dict['dir']="${2:?}"
                shift 2
                ;;
            '--host='*)
                dict['host']="${1#*=}"
                shift 1
                ;;
            '--host')
                dict['host']="${2:?}"
                shift 2
                ;;
            '--user='*)
                dict['user']="${1#*=}"
                shift 1
                ;;
            '--user')
                dict['user']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--host' "${dict['host']}" \
        '--user' "${dict['user']}"
    if [[ -n "${dict['dir']}" ]]
    then
        dict['dir']="${dict['host']}/${dict['dir']}"
    else
        dict['dir']="${dict['host']}"
    fi
    "${app['wget']}" \
        --ask-password \
        --mirror \
        "ftp://${dict['user']}@${dict['dir']}/"*
    return 0
}

koopa_gcrypt_url() {
    koopa_assert_has_no_args "$#"
    koopa_print 'https://gnupg.org/ftp/gcrypt'
    return 0
}

koopa_get_version() {
    local cmd
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        local dict
        declare -A dict
        dict['cmd']="$cmd"
        dict['bn']="$(koopa_basename "${dict['cmd']}")"
        dict['bn_snake']="$(koopa_snake_case_simple "${dict['bn']}")"
        dict['version_arg']="$(__koopa_get_version_arg "${dict['bn']}")"
        dict['version_fun']="koopa_${dict['bn_snake']}_version"
        if koopa_is_function "${dict['version_fun']}"
        then
            if [[ -x "${dict['cmd']}" ]] && \
                [[ ! -d "${dict['cmd']}" ]] && \
                koopa_is_installed "${dict['cmd']}"
            then
                dict['str']="$("${dict['version_fun']}" "${dict['cmd']}")"
            else
                dict['str']="$("${dict['version_fun']}")"
            fi
            [[ -n "${dict['str']}" ]] || return 1
            koopa_print "${dict['str']}"
            continue
        fi
        [[ -x "${dict['cmd']}" ]] || return 1
        [[ ! -d "${dict['cmd']}" ]] || return 1
        koopa_is_installed "${dict['cmd']}" || return 1
        dict['cmd']="$(koopa_realpath "${dict['cmd']}")"
        dict['str']="$("${dict['cmd']}" "${dict['version_arg']}" 2>&1 || true)"
        [[ -n "${dict['str']}" ]] || return 1
        dict['str']="$(koopa_extract_version "${dict['str']}")"
        [[ -n "${dict['str']}" ]] || return 1
        koopa_print "${dict['str']}"
    done
    return 0
}

koopa_gfortran_libs() {
    local app dict flibs gcc_libs i
    declare -A app=(
        ['dirname']="$(koopa_locate_dirname)"
        ['sort']="$(koopa_locate_sort)"
        ['xargs']="$(koopa_locate_xargs)"
    )
    [[ -x "${app['dirname']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['gcc']="$(koopa_app_prefix 'gcc')"
    )
    koopa_assert_is_dir "${dict['gcc']}"
    readarray -t gcc_libs <<< "$( \
        koopa_find \
            --prefix="${dict['gcc']}" \
            --pattern='*.a' \
            --type 'f' \
        | "${app['xargs']}" -I '{}' "${app['dirname']}" '{}' \
        | "${app['sort']}" --unique \
    )"
    koopa_assert_is_array_non_empty "${gcc_libs[@]:-}"
    for i in "${!gcc_libs[@]}"
    do
        flibs+=("-L${gcc_libs[$i]}")
    done
    flibs+=('-lgfortran' '-lm')
    case "${dict['arch']}" in
        'x86_64')
            flibs+=('-lquadmath')
            ;;
    esac
    koopa_print "${flibs[*]}"
    return 0
}

koopa_git_checkout_recursive() {
    local app dict dirs pos
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    declare -A dict=(
        ['branch']=''
        ['origin']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--branch='*)
                dict['branch']="${1#*=}"
                shift 1
                ;;
            '--branch')
                dict['branch']="${2:?}"
                shift 2
                ;;
            '--origin='*)
                dict['origin']="${1#*=}"
                shift 1
                ;;
            '--origin')
                dict['origin']="${2:?}"
                shift 2
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    dirs=("$@")
    koopa_is_array_empty "${dirs[@]}" && dirs[0]="${PWD:?}"
    koopa_assert_is_dir "${dirs[@]}"
    (
        local dir
        for dir in "${dirs[@]}"
        do
            local repo repos
            dir="$(koopa_realpath "$dir")"
            readarray -t repos <<< "$( \
                koopa_find \
                    --max-depth=3 \
                    --min-depth=2 \
                    --pattern='.git' \
                    --prefix="$dir" \
                    --sort \
            )"
            if koopa_is_array_empty "${repos[@]:-}"
            then
                koopa_stop "Failed to detect any repos in '${dir}'."
            fi
            koopa_h1 "Checking out ${#repos[@]} repos in '${dir}'."
            for repo in "${repos[@]}"
            do
                local dict2
                declare -A dict2
                koopa_h2 "$repo"
                koopa_cd "$repo"
                dict2['branch']="${dict['branch']}"
                dict2['default_branch']="$(koopa_git_default_branch)"
                if [[ -z "${dict2['branch']}" ]]
                then
                    dict2['branch']="${dict2['default_branch']}"
                fi
                if [[ -n "${dict['origin']}" ]]
                then
                    "${app['git']}" fetch --all
                    if [[ "${dict2['branch']}" \
                        != "${dict2['default_branch']}" ]]
                    then
                        "${app['git']}" checkout "${dict2['default_branch']}"
                        "${app['git']}" branch -D "${dict2['branch']}" || true
                    fi
                    "${app['git']}" checkout \
                        -B "${dict2['branch']}" \
                        "${dict['origin']}"
                else
                    "${app['git']}" checkout "${dict2['branch']}"
                fi
                "${app['git']}" branch -vv
            done
        done
    )
    return 0
}

koopa_git_clone() {
    local app clone_args dict
    koopa_assert_has_args "$#"
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    declare -A dict=(
        ['branch']=''
        ['commit']=''
        ['prefix']=''
        ['tag']=''
        ['url']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--branch='*)
                dict['branch']="${1#*=}"
                shift 1
                ;;
            '--branch')
                dict['branch']="${2:?}"
                shift 2
                ;;
            '--commit='*)
                dict['commit']="${1#*=}"
                shift 1
                ;;
            '--commit')
                dict['commit']="${2:?}"
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
            '--tag='*)
                dict['tag']="${1#*=}"
                shift 1
                ;;
            '--tag')
                dict['tag']="${2:?}"
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--url' "${dict['url']}"
    if [[ -d "${dict['prefix']}" ]]
    then
        koopa_rm "${dict['prefix']}"
    fi
    if koopa_str_detect_fixed \
        --string="${dict['url']}" \
        --pattern='git@github.com'
    then
        koopa_assert_is_github_ssh_enabled
    elif koopa_str_detect_fixed \
        --string="${dict['url']}" \
        --pattern='git@gitlab.com'
    then
        koopa_assert_is_gitlab_ssh_enabled
    fi
    clone_args=(
        '--quiet'
    )
    if [[ -n "${dict['branch']}" ]]
    then
        clone_args+=(
            '--depth=1'
            '--single-branch'
            "--branch=${dict['branch']}"
        )
    else
        clone_args+=(
            '--filter=blob:none'
        )
    fi
    clone_args+=("${dict['url']}" "${dict['prefix']}")
    "${app['git']}" clone "${clone_args[@]}"
    if [[ -n "${dict['commit']}" ]]
    then
        (
            koopa_cd "${dict['prefix']}"
            "${app['git']}" checkout --quiet "${dict['commit']}"
        )
    elif [[ -n "${dict['tag']}" ]]
    then
        (
            koopa_cd "${dict['prefix']}"
            "${app['git']}" fetch --quiet --tags
            "${app['git']}" checkout --quiet "tags/${dict['tag']}"
        )
    fi
    return 0
}

koopa_git_commit_date() {
    local app repos
    declare -A app=(
        ['date']="$(koopa_locate_date --allow-system)"
        ['git']="$(koopa_locate_git --allow-system)"
        ['xargs']="$(koopa_locate_xargs --allow-system)"
    )
    [[ -x "${app['date']}" ]] || return 1
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            local x
            koopa_cd "$repo"
            koopa_is_git_repo || return 1
            x="$( \
                "${app['git']}" log -1 --format='%at' \
                    | "${app['xargs']}" -I '{}' \
                        "${app['date']}" -d '@{}' '+%Y-%m-%d' \
                    2>/dev/null || true \
            )"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}

koopa_git_default_branch() {
    local app dict repos
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
        ['sed']="$(koopa_locate_sed --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict=(
        ['remote']='origin'
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            local x
            koopa_cd "$repo"
            koopa_is_git_repo || return 1
            x="$( \
                "${app['git']}" remote show "${dict['remote']}" \
                    | koopa_grep --pattern='HEAD branch' \
                    | "${app['sed']}" 's/.*: //' \
            )"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}

koopa_git_last_commit_local() {
    local app dict repos
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    declare -A dict=(
        ['ref']='HEAD'
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            local x
            koopa_cd "$repo"
            koopa_is_git_repo || return 1
            x="$( \
                "${app['git']}" rev-parse "${dict['ref']}" \
                    2>/dev/null || true \
            )"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}

koopa_git_last_commit_remote() {
    local app dict url
    koopa_assert_has_args "$#"
    declare -A app=(
        ['awk']="$(koopa_locate_awk --allow-system)"
        ['git']="$(koopa_locate_git --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    declare -A dict=(
        ['ref']='HEAD'
    )
    for url in "$@"
    do
        local x
        x="$( \
            "${app['git']}" ls-remote --quiet "$url" "${dict['ref']}" \
            | "${app['head']}" -n 1 \
            | "${app['awk']}" '{ print $1 }' \
        )"
        [[ -n "$x" ]] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_git_latest_tag() {
    local app repos
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            local rev tag
            koopa_cd "$repo"
            koopa_is_git_repo || return 1
            rev="$("${app['git']}" rev-list --tags --max-count=1)"
            tag="$("${app['git']}" describe --tags "$rev")"
            [[ -n "$tag" ]] || return 1
            koopa_print "$tag"
        done
    )
    return 0
}

koopa_git_pull_recursive() {
    local app dirs
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    dirs=("$@")
    koopa_is_array_empty "${dirs[@]}" && dirs[0]="${PWD:?}"
    koopa_assert_is_dir "${dirs[@]}"
    (
        local dir
        for dir in "${dirs[@]}"
        do
            local repo repos
            dir="$(koopa_realpath "$dir")"
            readarray -t repos <<< "$( \
                koopa_find \
                    --max-depth=3 \
                    --min-depth=2 \
                    --pattern='.git' \
                    --prefix="$dir" \
                    --sort \
            )"
            if koopa_is_array_empty "${repos[@]:-}"
            then
                koopa_stop "Failed to detect any git repos in '${dir}'."
            fi
            koopa_h1 "$(koopa_ngettext \
                --prefix='Pulling ' \
                --num="${#repos[@]}" \
                --msg1='repo' \
                --msg2='repos' \
                --suffix=" in '${dir}'." \
            )"
            for repo in "${repos[@]}"
            do
                koopa_h2 "$repo"
                koopa_cd "$repo"
                "${app['git']}" fetch --all
                "${app['git']}" pull --all
                "${app['git']}" status
            done
        done
    )
    return 0
}

koopa_git_pull() {
    local app repos
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    repos=("$@")
    koopa_assert_is_dir "${repos[@]}"
    (
        for repo in "${repos[@]}"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Pulling repo at '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            "${app['git']}" fetch --all --quiet
            "${app['git']}" pull --all --no-rebase --recurse-submodules
        done
    )
    return 0
}

koopa_git_push_recursive() {
    local app dirs
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    dirs=("$@")
    koopa_is_array_empty "${dirs[@]}" && dirs[0]="${PWD:?}"
    koopa_assert_is_dir "${dirs[@]}"
    (
        local dir
        for dir in "${dirs[@]}"
        do
            local repo repos
            dir="$(koopa_realpath "$dir")"
            readarray -t repos <<< "$( \
                koopa_find \
                    --max-depth=3 \
                    --min-depth=2 \
                    --pattern='.git' \
                    --prefix="$dir" \
                    --sort \
            )"
            if koopa_is_array_empty "${repos[@]:-}"
            then
                koopa_stop "Failed to detect any git repos in '${dir}'."
            fi
            koopa_h1 "$(koopa_ngettext \
                --prefix='Pushing ' \
                --num="${#repos[@]}" \
                --msg1='repo' \
                --msg2='repos' \
                --suffix=" in '${dir}'." \
            )"
            for repo in "${repos[@]}"
            do
                koopa_h2 "$repo"
                koopa_cd "$repo"
                "${app['git']}" push
            done
        done
    )
    return 0
}

koopa_git_push_submodules() {
    local app repos
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            koopa_cd "$repo"
            "${app['git']}" submodule update --remote --merge
            "${app['git']}" commit -m 'Update submodules.'
            "${app['git']}" push
        done
    )
    return 0
}

koopa_git_remote_url() {
    local app repos
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            local x
            koopa_cd "$repo"
            koopa_is_git_repo || return 1
            x="$("${app['git']}" config --get 'remote.origin.url' || true)"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}

koopa_git_rename_master_to_main() {
    local app dict repos
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    declare -A dict=(
        ['origin']='origin'
        ['old_branch']='master'
        ['new_branch']='main'
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            "${app['git']}" switch "${dict['old_branch']}"
            "${app['git']}" branch --move \
                "${dict['old_branch']}" \
                "${dict['new_branch']}"
            "${app['git']}" switch "${dict['new_branch']}"
            "${app['git']}" fetch --all --prune "${dict['origin']}"
            "${app['git']}" branch --unset-upstream
            "${app['git']}" branch \
                --set-upstream-to="${dict['origin']}/${dict['new_branch']}" \
                "${dict['new_branch']}"
            "${app['git']}" push --set-upstream \
                "${dict['origin']}" \
                "${dict['new_branch']}"
            "${app['git']}" push \
                "${dict['origin']}" \
                --delete "${dict['old_branch']}" \
                || true
            "${app['git']}" remote set-head "${dict['origin']}" --auto
        done
    )
    return 0
}

koopa_git_reset_fork_to_upstream() {
    local app repos
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            local dict
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            declare -A dict=(
                ['branch']="$(koopa_git_default_branch)"
                ['origin']='origin'
                ['upstream']='upstream'
            )
            "${app['git']}" checkout "${dict['branch']}"
            "${app['git']}" fetch "${dict['upstream']}"
            "${app['git']}" reset --hard "${dict['upstream']}/${dict['branch']}"
            "${app['git']}" push "${dict['origin']}" "${dict['branch']}" --force
        done
    )
    return 0
}

koopa_git_reset() {
    local app repos
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Resetting repo at '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            "${app['git']}" clean -dffx
            if [[ -s '.gitmodules' ]]
            then
                koopa_git_submodule_init
                "${app['git']}" submodule --quiet foreach --recursive \
                    "${app['git']}" clean -dffx
                "${app['git']}" reset --hard --quiet
                "${app['git']}" submodule --quiet foreach --recursive \
                    "${app['git']}" reset --hard --quiet
            fi
        done
    )
    return 0
}

koopa_git_rm_submodule() {
    local app module
    koopa_assert_has_args "$#"
    koopa_assert_is_git_repo
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    for module in "$@"
    do
        "${app['git']}" submodule deinit -f "$module"
        koopa_rm ".git/modules/${module}"
        "${app['git']}" rm -f "$module"
        "${app['git']}" add '.gitmodules'
        "${app['git']}" commit -m "Removed submodule '${module}'."
    done
    return 0
}

koopa_git_rm_untracked() {
    local app repos
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Removing untracked files in '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            "${app['git']}" clean -dfx
        done
    )
    return 0
}

koopa_git_set_remote_url() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    koopa_assert_is_git_repo
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    declare -A dict=(
        ['url']="${1:?}"
        ['origin']='origin'
    )
    "${app['git']}" remote set-url "${dict['origin']}" "${dict['url']}"
    return 0
}

koopa_git_status_recursive() {
    local app dirs
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    dirs=("$@")
    koopa_is_array_empty "${dirs[@]}" && dirs[0]="${PWD:?}"
    (
        local dir
        for dir in "${dirs[@]}"
        do
            local repo repos
            dir="$(koopa_realpath "$dir")"
            readarray -t repos <<< "$( \
                koopa_find \
                    --max-depth=3 \
                    --min-depth=2 \
                    --pattern='.git' \
                    --prefix="$dir" \
                    --sort \
            )"
            if koopa_is_array_empty "${repos[@]:-}"
            then
                koopa_stop "Failed to detect any git repos in '${dir}'."
            fi
            koopa_h1 "$(koopa_ngettext \
                --prefix='Checking status of ' \
                --num="${#repos[@]}" \
                --msg1='repo' \
                --msg2='repos' \
                --suffix=" in '${dir}'." \
            )"
            for repo in "${repos[@]}"
            do
                koopa_h2 "$repo"
                koopa_cd "$repo"
                "${app['git']}" status
            done
        done
    )
    return 0
}

koopa_git_submodule_init() {
    local app repos
    declare -A app=(
        ['awk']="$(koopa_locate_awk --allow-system)"
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['git']}" ]] || return 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            local dict lines string
            declare -A dict=(
                ['module_file']='.gitmodules'
            )
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Initializing submodules in '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            koopa_assert_is_nonzero_file "${dict['module_file']}"
            "${app['git']}" submodule init
            readarray -t lines <<< "$(
                "${app['git']}" config \
                    --file "${dict['module_file']}" \
                    --get-regexp '^submodule\..*\.path$' \
            )"
            if koopa_is_array_empty "${lines[@]:-}"
            then
                koopa_stop "Failed to detect submodules in '${repo}'."
            fi
            for string in "${lines[@]}"
            do
                local dict2
                declare -A dict2
                dict2['target_key']="$( \
                    koopa_print "$string" \
                    | "${app['awk']}" '{ print $1 }' \
                )"
                dict2['target']="$( \
                    koopa_print "$string" \
                    | "${app['awk']}" '{ print $2 }' \
                )"
                dict2['url_key']="${dict2['target_key']//\.path/.url}"
                dict2['url']="$( \
                    "${app['git']}" config \
                        --file "${dict['module_file']}" \
                        --get "${dict2['url_key']}" \
                )"
                koopa_dl "${dict2['target']}" "${dict2['url']}"
                if [[ ! -d "${dict2['target']}" ]]
                then
                    "${app['git']}" submodule add --force \
                        "${dict2['url']}" "${dict2['target']}" > /dev/null
                fi
            done
        done
    )
    return 0
}

koopa_github_latest_release() {
    local app repo
    koopa_assert_has_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut)"
        ['sed']="$(koopa_locate_sed)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    for repo in "$@"
    do
        local dict
        declare -A dict
        dict['repo']="$repo"
        dict['url']="https://api.github.com/repos/${dict['repo']}/\
releases/latest"
        dict['str']="$( \
            koopa_parse_url "${dict['url']}" \
                | koopa_grep --pattern='"tag_name":' \
                | "${app['cut']}" -d '"' -f '4' \
                | "${app['sed']}" 's/^v//' \
        )"
        [[ -n "${dict['str']}" ]] || return 1
        koopa_print "${dict['str']}"
    done
    return 0
}

koopa_gnu_mirror_url() {
    koopa_assert_has_no_args "$#"
    koopa_print 'https://ftpmirror.gnu.org'
    return 0
}

koopa_gpg_download_key_from_keyserver() {
    local app cp dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['gpg']="$(koopa_locate_gpg --allow-system)"
    )
    [[ -x "${app['gpg']}" ]] || return 1
    declare -A dict=(
        ['sudo']=0
        ['tmp_dir']="$(koopa_tmp_dir)"
    )
    dict['tmp_file']="${dict['tmp_dir']}/export.gpg"
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--key='*)
                dict['key']="${1#*=}"
                shift 1
                ;;
            '--key')
                dict['key']="${2:?}"
                shift 2
                ;;
            '--keyserver='*)
                dict['keyserver']="${1#*=}"
                shift 1
                ;;
            '--keyserver')
                dict['keyserver']="${2:?}"
                shift 2
                ;;
            '--sudo')
                dict['sudo']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ -f "${dict['file']}" ]] && return 0
    koopa_alert "Exporting GPG key '${dict['key']}' at '${dict['file']}'."
    cp=('koopa_cp')
    [[ "${dict['sudo']}" -eq 1 ]] && cp+=('--sudo')
    "${app['gpg']}" \
        --homedir "${dict['tmp_dir']}" \
        --quiet \
        --keyserver "${dict['keyserver']}" \
        --recv-keys "${dict['key']}"
    "${app['gpg']}" \
        --homedir "${dict['tmp_dir']}" \
        --list-public-keys "${dict['key']}"
    "${app['gpg']}" \
        --homedir "${dict['tmp_dir']}" \
        --export \
        --quiet \
        --output "${dict['tmp_file']}" \
        "${dict['key']}"
    koopa_assert_is_file "${dict['tmp_file']}"
    "${cp[@]}" "${dict['tmp_file']}" "${dict['file']}"
    koopa_rm "${dict['tmp_dir']}"
    koopa_assert_is_file "${dict['file']}"
    return 0
}

koopa_gpg_prompt() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['gpg']="$(koopa_locate_gpg --allow-system)"
    )
    [[ -x "${app['gpg']}" ]] || return 1
    printf '' | "${app['gpg']}" -s
    return 0
}

koopa_gpg_reload() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['gpg_connect_agent']="$(koopa_locate_gpg_connect_agent)"
    )
    [[ -x "${app['gpg_connect_agent']}" ]] || return 1
    "${app['gpg_connect_agent']}" reloadagent '/bye'
    return 0
}

koopa_gpg_restart() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['gpgconf']="$(koopa_locate_gpgconf)"
    )
    [[ -x "${app['gpgconf']}" ]] || return 1
    "${app['gpgconf']}" --kill 'gpg-agent'
    return 0
}

koopa_grep() {
    local app dict grep_args grep_cmd
    koopa_assert_has_args "$#"
    declare -A app
    declare -A dict=(
        ['boolean']=0
        ['engine']="${KOOPA_GREP_ENGINE:-}"
        ['file']=''
        ['invert_match']=0
        ['only_matching']=0
        ['mode']='fixed' # or 'regex'.
        ['pattern']=''
        ['stdin']=1
        ['string']=''
        ['sudo']=0
    )
    while (("$#"))
    do
        case "$1" in
            '--engine='*)
                dict['engine']="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict['engine']="${2:?}"
                shift 2
                ;;
            '--file='*)
                dict['file']="${1#*=}"
                dict['stdin']=0
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                dict['stdin']=0
                shift 2
                ;;
            '--mode='*)
                dict['mode']="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict['mode']="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                dict['stdin']=0
                shift 1
                ;;
            '--string')
                dict['string']="${2:-}"
                dict['stdin']=0
                shift 2
                ;;
            '--boolean' | \
            '--quiet')
                dict['boolean']=1
                shift 1
                ;;
            '--regex' | \
            '--extended-regexp')
                dict['mode']='regex'
                shift 1
                ;;
            '--fixed' | \
            '--fixed-strings')
                dict['mode']='fixed'
                shift 1
                ;;
            '--invert-match')
                dict['invert_match']=1
                shift 1
                ;;
            '--only-matching')
                dict['only_matching']=1
                shift 1
                ;;
            '--sudo')
                dict['sudo']=1
                shift 1
                ;;
            '-')
                dict['stdin']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict['pattern']}"
    case "${dict['engine']}" in
        '')
            app['grep']="$(koopa_locate_rg --allow-missing)"
            [[ -x "${app['grep']}" ]] && dict['engine']='rg'
            if [[ -z "${dict['engine']}" ]]
            then
                dict['engine']='grep'
                app['grep']="$(koopa_locate_grep --allow-system)"
                [[ -x "${app['grep']}" ]] || return 1
            fi
            ;;
        'grep')
            app['grep']="$(koopa_locate_grep --allow-system)"
            [[ -x "${app['grep']}" ]] || return 1
            ;;
        'rg')
            app['grep']="$(koopa_locate_ripgrep)"
            [[ -x "${app['grep']}" ]] || return 1
            ;;
    esac
    if [[ "${dict['stdin']}" -eq 1 ]]
    then
        dict['string']="$(</dev/stdin)"
    fi
    if [[ -n "${dict['file']}" ]] && [[ -n "${dict['string']}" ]]
    then
        koopa_stop "Use '--file' or '--string', but not both."
    fi
    grep_cmd=("${app['grep']}")
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        grep_cmd=('sudo' "${grep_cmd[@]}")
    fi
    grep_args=()
    case "${dict['engine']}" in
        'grep')
            case "${dict['mode']}" in
                'fixed')
                    grep_args+=('-F')
                    ;;
                'regex')
                    grep_args+=('-E')
                    ;;
            esac
            [[ "${dict['invert_match']}" -eq 1 ]] && \
                grep_args+=('-v')  # --invert-match
            [[ "${dict['only_matching']}" -eq 1 ]] && \
                grep_args+=('-o')  # --only-matching
            [[ "${dict['boolean']}" -eq 1 ]] && \
                grep_args+=('-q')  # --quiet
            ;;
        'rg')
            grep_args+=(
                '--case-sensitive'
            )
            if [[ -n "${dict['file']}" ]]
            then
                grep_args+=(
                    '--no-config'
                    '--no-ignore'
                    '--one-file-system'
                )
            fi
            case "${dict['mode']}" in
                'fixed')
                    grep_args+=('--fixed-strings')
                    ;;
                'regex')
                    grep_args+=('--engine' 'default')
                    ;;
            esac
            [[ "${dict['invert_match']}" -eq 1 ]] && \
                grep_args+=('--invert-match')
            [[ "${dict['only_matching']}" -eq 1 ]] && \
                grep_args+=('--only-matching')
            [[ "${dict['boolean']}" -eq 1 ]] && \
                grep_args+=('--quiet')
            ;;
        *)
            koopa_stop 'Invalid grep engine.'
            ;;
    esac
    grep_args+=("${dict['pattern']}")
    if [[ -n "${dict['file']}" ]]
    then
        koopa_assert_is_file "${dict['file']}"
        koopa_assert_is_readable "${dict['file']}"
        grep_args+=("${dict['file']}")
        if [[ "${dict['boolean']}" -eq 1 ]]
        then
            "${grep_cmd[@]}" "${grep_args[@]}" >/dev/null
        else
            "${grep_cmd[@]}" "${grep_args[@]}"
        fi
    else
        if [[ "${dict['boolean']}" -eq 1 ]]
        then
            koopa_print "${dict['string']}" \
                | "${grep_cmd[@]}" "${grep_args[@]}" >/dev/null
        else
            koopa_print "${dict['string']}" \
                | "${grep_cmd[@]}" "${grep_args[@]}"
        fi
    fi
}

koopa_gsub() {
    koopa_sub --global "$@"
}

koopa_h1() {
    __koopa_h 1 "$@"
}

koopa_h2() {
    __koopa_h 2 "$@"
}

koopa_h3() {
    __koopa_h 3 "$@"
}

koopa_h4() {
    __koopa_h 4 "$@"
}

koopa_h5() {
    __koopa_h 5 "$@"
}

koopa_h6() {
    __koopa_h 6 "$@"
}

koopa_h7() {
    __koopa_h 7 "$@"
}

koopa_has_file_ext() {
    local file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        koopa_str_detect_fixed \
            --string="$(koopa_print "$file")" \
            --pattern='.' \
        || return 1
    done
    return 0
}

koopa_has_large_system_disk() {
    local dict
    koopa_assert_has_args_le "$#" 1
    [[ "${KOOPA_BUILDER:-0}" -eq 1 ]] && return 0
    declare -A dict
    dict['disk']="${1:-/}"
    dict['blocks']="$(koopa_disk_512k_blocks "${dict['disk']}")"
    [[ "${dict['blocks']}" -ge 500000000 ]] && return 0
    return 1
}

koopa_has_monorepo() {
    [[ -d "$(koopa_monorepo_prefix)" ]]
}

koopa_has_no_environments() {
    koopa_assert_has_no_args "$#"
    koopa_is_conda_active && return 1
    koopa_is_python_venv_active && return 1
    return 0
}

koopa_has_passwordless_sudo() {
    local app
    koopa_assert_has_no_args "$#"
    koopa_is_root && return 0
    koopa_is_installed 'sudo' || return 1
    declare -A app=(
        ['sudo']="$(koopa_locate_sudo)"
    )
    [[ -x "${app['sudo']}" ]] || return 1
    "${app['sudo']}" -n true 2>/dev/null && return 0
    return 1
}

koopa_header() {
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        ['lang']="$(koopa_lowercase "${1:?}")"
        ['prefix']="$(koopa_koopa_prefix)/lang"
    )
    case "${dict['lang']}" in
        'bash' | \
        'posix' | \
        'zsh')
            dict['prefix']="${dict['prefix']}/shell"
            dict['ext']='sh'
            ;;
        'r')
            dict['ext']='R'
            ;;
        *)
            koopa_invalid_arg "${dict['lang']}"
            ;;
    esac
    dict['file']="${dict['prefix']}/${dict['lang']}/include/\
header.${dict['ext']}"
    koopa_assert_is_file "${dict['file']}"
    koopa_print "${dict['file']}"
    return 0
}

koopa_help_2() {
    local dict
    declare -A dict
    dict['script_file']="$(koopa_realpath "$0")"
    dict['script_name']="$(koopa_basename "${dict['script_file']}")"
    dict['man_prefix']="$( \
        koopa_parent_dir --num=2 "${dict['script_file']}" \
    )"
    dict['man_file']="${dict['man_prefix']}/man/\
man1/${dict['script_name']}.1"
    koopa_help "${dict['man_file']}"
}

koopa_help() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict
    dict['man_file']="${1:?}"
    [[ -f "${dict['man_file']}" ]] || return 1
    declare -A app=(
        ['head']="$(koopa_locate_head --allow-system)"
        ['man']="$(koopa_locate_man --allow-system)"
    )
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['man']}" ]] || return 1
    "${app['head']}" -n 10 "${dict['man_file']}" \
        | koopa_str_detect_fixed --pattern='.TH ' \
        || return 1
    "${app['man']}" "${dict['man_file']}"
    exit 0
}

koopa_hisat2_align_paired_end_per_sample() {
    local align_args app dict
    declare -A app=(
        ['hisat2']="$(koopa_locate_hisat2)"
    )
    [[ -x "${app['hisat2']}" ]] || return 1
    declare -A dict=(
        ['fastq_r1_file']=''
        ['fastq_r1_tail']=''
        ['fastq_r2_file']=''
        ['fastq_r2_tail']=''
        ['index_dir']=''
        ['lib_type']='A'
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=14
        ['output_dir']=''
        ['threads']="$(koopa_cpu_count)"
    )
    align_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--fastq-r2-tail' "${dict['fastq_r2_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "HISAT2 align requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
    dict['fastq_r1_file']="$(koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="${dict['fastq_r1_bn']/${dict['fastq_r1_tail']}/}"
    dict['fastq_r2_file']="$(koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="$(koopa_basename "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="${dict['fastq_r2_bn']/${dict['fastq_r2_tail']}/}"
    koopa_assert_are_identical "${dict['fastq_r1_bn']}" "${dict['fastq_r2_bn']}"
    dict['id']="${dict['fastq_r1_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    dict['hisat2_idx']="${dict['index_dir']}/index"
    dict['sam_file']="${dict['output_dir']}/${dict['id']}.sam"
    align_args+=(
        '-1' "${dict['fastq_r1_file']}"
        '-2' "${dict['fastq_r2_file']}"
        '-S' "${dict['sam_file']}"
        '-q'
        '-x' "${dict['hisat2_idx']}"
        '--new-summary'
        '--threads' "${dict['threads']}"
    )
    dict['lib_type']="$(koopa_hisat2_fastq_library_type "${dict['lib_type']}")"
    if [[ -n "${dict['lib_type']}" ]]
    then
        align_args+=('--rna-strandedness' "${dict['lib_type']}")
    fi
    dict['quality_flag']="$( \
        koopa_hisat2_fastq_quality_format "${dict['fastq_r1_file']}" \
    )"
    if [[ -n "${dict['quality_flag']}" ]]
    then
        align_args+=("${dict['quality_flag']}")
    fi
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['star']}" "${align_args[@]}"
    return 0
}

koopa_hisat2_align_paired_end() {
    local dict fastq_r1_files fastq_r1_file
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['fastq_dir']=''
        ['fastq_r1_tail']=''
        ['fastq_r2_tail']=''
        ['index_dir']=''
        ['lib_type']='A'
        ['mode']='paired-end'
        ['output_dir']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-tail' "${dict['fastq_r1_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running HISAT2 aligner.'
    koopa_dl \
        'Mode' "${dict['mode']}" \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_r1_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local fastq_r2_file
        fastq_r2_file="${fastq_r1_file/\
${dict['fastq_r1_tail']}/${dict['fastq_r2_tail']}}"
        koopa_hisat2_align_paired_end_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict['fastq_r1_tail']}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict['fastq_r2_tail']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict['output_dir']}"
    done
    koopa_alert_success 'HISAT2 alignment was successful.'
    return 0
}

koopa_hisat2_align_single_end_per_sample() {
    local align_args app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['hisat2']="$(koopa_locate_hisat2)"
    )
    [[ -x "${app['hisat2']}" ]] || return 1
    declare -A dict=(
        ['fastq_file']=''
        ['fastq_tail']=''
        ['index_dir']=''
        ['lib_type']='A'
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=14
        ['output_dir']=''
        ['threads']="$(koopa_cpu_count)"
    )
    align_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict['fastq_file']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "HISAT2 align requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_file']}"
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
    dict['fastq_bn']="${dict['fastq_bn']/${dict['tail']}/}"
    dict['id']="${dict['fastq_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    dict['hisat2_idx']="${dict['index_dir']}/index"
    dict['sam_file']="${dict['output_dir']}/${dict['id']}.sam"
    align_args+=(
        '-S' "${dict['sam_file']}"
        '-U' "${dict['fastq_file']}"
        '-q'
        '-x' "${dict['hisat2_idx']}"
        '--new-summary'
        '--threads' "${dict['threads']}"
    )
    dict['lib_type']="$(koopa_hisat2_fastq_library_type "${dict['lib_type']}")"
    if [[ -n "${dict['lib_type']}" ]]
    then
        align_args+=('--rna-strandedness' "${dict['lib_type']}")
    fi
    dict['quality_flag']="$( \
        koopa_hisat2_fastq_quality_format "${dict['fastq_r1_file']}" \
    )"
    if [[ -n "${dict['quality_flag']}" ]]
    then
        align_args+=("${dict['quality_flag']}")
    fi
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['star']}" "${align_args[@]}"
    return 0
}

koopa_hisat2_align_single_end() {
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['fastq_dir']=''
        ['fastq_tail']=''
        ['index_dir']=''
        ['lib_type']='A'
        ['mode']='single-end'
        ['output_dir']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running HISAT2 aligner.'
    koopa_dl \
        'Mode' "${dict['mode']}" \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ tail' "${dict['fastq_tail']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_tail']}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_file in "${fastq_files[@]}"
    do
        koopa_hisat2_align_single_end_per_sample \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict['fastq_tail']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict['output_dir']}"
    done
    koopa_alert_success 'HISAT2 alignment was successful.'
    return 0
}

koopa_hisat2_fastq_library_type() {
    local from to
    koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'A' | 'IU' | 'U')
            return 0
            ;;
        'ISF')
            to='FR'
            ;;
        'ISR')
            to='RF'
            ;;
        'SF')
            to='F'
            ;;
        'SR')
            to='R'
            ;;
        *)
            koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    koopa_print "$to"
    return 0
}

koopa_hisat2_fastq_quality_format() {
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        ['fastq_file']="${1:?}"
    )
    koopa_assert_is_file "${dict['fastq_file']}"
    dict['format']="$( \
        koopa_fastq_detect_quality_format "${dict['fastq_file']}" \
    )"
    case "${dict['format']}" in
        'Phread+33')
            dict['flag']='--phred33'
            ;;
        'Phread+64')
            dict['flag']='--phred64'
            ;;
        *)
            return 0
            ;;
    esac
    koopa_print "${dict['flag']}"
    return 0
}

koopa_hisat2_index() {
    local app dict index_args
    declare -A app=(
        ['hisat2_build']="$(koopa_locate_hisat2_build)"
    )
    [[ -x "${app['hisat2_build']}" ]] || return 1
    declare -A dict=(
        ['genome_fasta_file']=''
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=200
        ['output_dir']=''
        ['seed']=42
        ['threads']="$(koopa_cpu_count)"
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--output-dir' "${dict['output_dir']}"
    dict['ht2_base']="${dict['output_dir']}/index"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "'hisat2-build' requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file "${dict['genome_fasta_file']}"
    koopa_assert_is_matching_regex \
        --pattern='\.fa\.gz$' \
        --string="${dict['genome_fasta_file']}"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    koopa_alert "Generating HISAT2 index at '${dict['output_dir']}'."
    index_args+=(
        '--seed' "${dict['seed']}"
        '-f'
        '-p' "${dict['threads']}"
        "${dict['genome_fasta_file']}"
        "${dict['ht2_base']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app['hisat2_build']}" "${index_args[@]}"
    koopa_alert_success "HISAT2 index created at '${dict['output_dir']}'."
    return 0
}

koopa_ignore_pipefail() {
    local status
    status="${1:?}"
    [[ "$status" -eq 141 ]] && return 0
    return "$status"
}

koopa_info_box() {
    koopa_assert_has_args "$#"
    local array
    array=("$@")
    local barpad
    barpad="$(printf '━%.0s' {1..70})"
    printf '  %s%s%s  \n' '┏' "$barpad" '┓'
    for i in "${array[@]}"
    do
        printf '  ┃ %-68s ┃  \n' "${i::68}"
    done
    printf '  %s%s%s  \n\n' '┗' "$barpad" '┛'
    return 0
}

koopa_init_dir() {
    local dict mkdir pos
    declare -A dict=(
        ['sudo']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_eq "$#" 1
    dict['dir']="${1:?}"
    if koopa_str_detect_regex \
        --string="${dict['dir']}" \
        --pattern='^~'
    then
        dict['dir']="$( \
            koopa_sub \
                --pattern='^~' \
                --replacement="${HOME:?}" \
                "${dict['dir']}" \
        )"
    fi
    mkdir=('koopa_mkdir')
    [[ "${dict['sudo']}" -eq 1 ]] && mkdir+=('--sudo')
    if [[ ! -d "${dict['dir']}" ]]
    then
        "${mkdir[@]}" "${dict['dir']}"
    fi
    dict['realdir']="$(koopa_realpath "${dict['dir']}")"
    koopa_print "${dict['realdir']}"
    return 0
}

koopa_insert_at_line_number() {
    declare -A app=(
        ['perl']="$(koopa_locate_perl)"
    )
    [[ -x "${app['perl']}" ]] || return 1
    declare -A dict=(
        ['file']=''
        ['line_number']=''
        ['string']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--line-number='*)
                dict['line_number']="${1#*=}"
                shift 1
                ;;
            '--line-number')
                dict['line_number']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--line-number' "${dict['line_number']}" \
        '--string' "${dict['string']}"
    koopa_assert_is_file "${dict['file']}"
    dict['perl_cmd']="print '${dict['string']}' \
if \$. == ${dict['line_number']}"
    "${app['perl']}" -i -l -p -e "${dict['perl_cmd']}" "${dict['file']}"
    return 0
}

koopa_install_ack() {
    koopa_install_app \
        --name='ack' \
        "$@"
}

koopa_install_agat() {
    koopa_install_app \
        --name='agat' \
        "$@"
}

koopa_install_all_apps() {
    local app app_name apps bool push_apps
    koopa_assert_has_no_args "$#"
    declare -A app
    app['koopa']="$(koopa_locate_koopa)"
    [[ -x "${app['koopa']}" ]] || return 1
    declare -A bool
    bool['large']=0
    koopa_has_large_system_disk && bool['large']=1
    apps=()
    apps+=(
        'make'
        'pkg-config'
    )
    koopa_is_linux && apps+=('attr')
    apps+=(
        'zlib'
        'patch'
        'tar'
        'xz'
        'bzip2'
        'm4'
        'gmp'
        'gperf'
        'mpfr'
        'mpc'
        'gcc'
        'autoconf'
        'automake'
        'libtool'
        'unzip'
        'zip'
        'bison'
        'coreutils'
        'findutils'
        'sed'
        'ncurses'
        'icu4c'
        'readline'
        'libiconv'
        'libunistring'
        'libxml2'
        'gettext'
        'nano'
        'ca-certificates'
        'openssl1'
        'openssl3'
        'cmake'
        'zstd'
        'curl'
        'bash'
        'git'
        'lapack'
        'libffi'
        'libjpeg-turbo'
        'libpng'
        'libtiff'
        'openblas'
        'pcre'
        'pcre2'
        'expat'
        'gdbm'
        'sqlite'
        'mpdecimal'
        'libedit'
        'python3.10'
        'python3.11'
        'xorg-xorgproto'
        'xorg-xcb-proto'
        'xorg-libpthread-stubs'
        'xorg-xtrans'
        'xorg-libice'
        'xorg-libsm'
        'xorg-libxau'
        'xorg-libxdmcp'
        'xorg-libxcb'
        'xorg-libx11'
        'xorg-libxext'
        'xorg-libxrender'
        'xorg-libxt'
        'xorg-libxrandr'
        'tcl-tk'
        'perl'
        'texinfo'
        'meson'
        'ninja'
        'glib'
        'freetype'
        'fontconfig'
        'lzo'
        'pixman'
        'cairo'
        'hdf5'
        'openjdk'
        'libssh2'
        'libgit2'
        'jpeg'
        'nettle'
        'libzip'
        'imagemagick'
        'graphviz'
        'geos'
        'proj'
        'gdal'
        'fribidi'
        'harfbuzz'
        'gawk'
        'libuv'
        'udunits'
        'gzip'
        'groff'
        'less'
        'r'
        'apr'
        'apr-util'
        'armadillo'
        'aspell'
        'bc'
        'flex'
        'binutils'
        'cpufetch'
        'exiftool'
        'libtasn1'
        'texinfo'
        'gnutls'
        'emacs'
        'vim'
        'lua'
        'luarocks'
        'libevent'
        'utf8proc'
        'tmux'
        'htop'
        'boost'
        'fish'
        'zsh'
        'lame'
        'ffmpeg'
        'flac'
        'fltk'
        'libgpg-error'
        'libgcrypt'
        'libassuan'
        'libksba'
        'npth'
    )
    koopa_is_linux && apps+=('pinentry')
    apps+=(
        'gnupg'
        'grep'
        'gsl'
        'oniguruma'
        'jq'
        'lesspipe'
        'libidn'
        'libpipeline'
        'lz4'
        'man-db'
        'neofetch'
        'parallel'
        'password-store'
        'taglib'
        'pytaglib'
        'pytest'
        'xxhash'
        'rsync'
        'scons'
        'serf'
        'libyaml'
        'ruby'
        'subversion'
        'shellcheck'
        'shunit2'
        'sox'
        'stow'
        'tree'
        'units'
        'wget'
        'which'
        'libgeotiff'
        'swig'
    )
    koopa_is_linux && apps+=('elfutils')
    apps+=(
        'go'
        'chezmoi'
        'fzf'
        'git-lfs'
        'aws-cli'
        'autoflake'
        'black'
        'bpytop'
        'flake8'
        'glances'
        'httpie'
        'ipython'
        'isort'
        'latch'
        'pipx'
        'poetry'
        'py-spy'
        'pycodestyle'
        'pyflakes'
        'pygments'
        'pylint'
        'radian'
        'ranger-fm'
        'ruff'
        'visidata'
        'yt-dlp'
        'openssh'
        'c-ares'
        'jemalloc'
        'libev'
        'nghttp2'
        'node'
        'rust'
        'bat'
        'broot'
        'delta'
        'difftastic'
        'dog'
        'du-dust'
        'exa'
        'fd-find'
        'hyperfine'
        'lsd'
        'mcfly'
        'mdcat'
        'nushell'
        'procs'
        'ripgrep'
        'ripgrep-all'
        'starship'
        'tealdeer'
        'tokei'
        'tree-sitter'
        'tuc'
        'xsv'
        'zellij'
        'zoxide'
        'chemacs'
        'cheat'
        'gum'
        'yq'
        'bash-language-server'
        'gtop'
        'prettier'
        'ack'
        'rename'
        'bashcov'
        'colorls'
        'ronn'
        'pyenv'
        'rbenv'
        'dotfiles'
        'yarn'
        'asdf'
        'bfg'
        'convmv'
        'editorconfig'
        'markdownlint-cli'
        'nmap'
        'rmate'
        'neovim'
        'csvkit'
        'csvtk'
        'vulture'
        'diff-so-fancy'
        'bottom'
        'grex'
        'hexyl'
        'sd'
        'hugo'
        'llama'
    )
    if koopa_is_linux
    then
        if ! koopa_is_aarch64
        then
            apps+=('docker-credential-pass')
        fi
    fi
    if [[ "${bool['large']}" -eq 1 ]]
    then
        apps+=(
            'r-devel'
            'apache-airflow'
            'apache-spark'
            'azure-cli'
            'ensembl-perl-api'
            'google-cloud-sdk'
            'haskell-ghcup'
            'haskell-cabal'
            'llvm'
            'julia'
            'ghostscript'
        )
        if ! koopa_is_aarch64
        then
            apps+=(
                'haskell-stack'
                'hadolint'
                'pandoc'
                'conda'
                'agat'
                'anaconda'
                'autodock'
                'autodock-vina'
                'bamtools'
                'bedtools'
                'bioawk'
                'bowtie2'
                'bustools'
                'deeptools'
                'entrez-direct'
                'fastqc'
                'ffq'
                'fgbio'
                'fq'
                'gatk'
                'gffutils'
                'gget'
                'gseapy'
                'hisat2'
                'htseq'
                'jupyterlab'
                'kallisto'
                'minimap2'
                'multiqc'
                'nanopolish'
                'nextflow'
                'salmon'
                'sambamba'
                'samtools'
                'snakefmt'
                'snakemake'
                'star'
                'star-fusion'
                'sra-tools'
                'scalene'
            )
        fi
        apps+=(
            'cli11'
            'fmt'
            'googletest'
            'libarchive'
            'libsolv'
            'nlohmann-json'
            'pybind11'
            'reproc'
            'spdlog'
            'termcolor'
            'tl-expected'
            'yaml-cpp'
            'mamba'
        )
        if koopa_is_linux
        then
            apps+=(
                'apptainer'
                'aspera-connect'
                'lmod'
            )
        fi
    fi
    koopa_add_to_path_start '/usr/local/bin'
    for app_name in "${apps[@]}"
    do
        local prefix
        prefix="$(koopa_app_prefix --allow-missing "$app_name")"
        koopa_alert "$prefix"
        [[ -d "$prefix" ]] && continue
        "${app['koopa']}" install "$app_name"
        push_apps+=("$app_name")
    done
    if koopa_can_install_binary && \
        koopa_is_array_non_empty "${push_apps[@]:-}"
    then
        for app_name in "${push_apps[@]}"
        do
            koopa_push_app_build "$app_name"
        done
    fi
    return 0
}

koopa_install_all_binary_apps() {
    local app app_name apps bool
    koopa_assert_has_no_args "$#"
    declare -A app
    app['koopa']="$(koopa_locate_koopa)"
    [[ -x "${app['koopa']}" ]] || return 1
    declare -A bool
    bool['large']=0
    koopa_has_large_system_disk && bool['large']=1
    apps=()
    koopa_is_linux && apps+=('attr')
    apps+=(
        'zlib'
        'zstd'
        'bzip2'
        'ca-certificates'
        'openssl1'
        'openssl3'
        'curl'
        'm4'
        'gmp'
        'coreutils'
        'findutils'
        'gettext'
        'libiconv'
        'pcre'
        'pcre2'
        'grep'
        'sed'
    )
    apps+=(
        'ack'
        'apr'
        'apr-util'
        'armadillo'
        'asdf'
        'aspell'
        'autoconf'
        'autoflake'
        'automake'
        'bash'
        'bash-language-server'
        'bashcov'
        'bat'
        'bc'
        'bfg'
        'binutils'
        'bison'
        'black'
        'boost'
        'bottom'
        'bpytop'
        'broot'
        'c-ares'
        'cairo'
        'cheat'
        'chemacs'
        'chezmoi'
        'cmake'
        'colorls'
        'conda'
        'convmv'
        'cpufetch'
        'csvkit'
        'csvtk'
        'delta'
        'diff-so-fancy'
        'difftastic'
        'dog'
        'dotfiles'
        'du-dust'
        'editorconfig'
        'emacs'
        'entrez-direct'
        'exa'
        'exiftool'
        'expat'
        'fd-find'
        'ffmpeg'
        'fish'
        'flac'
        'flake8'
        'flex'
        'fltk'
        'fontconfig'
        'freetype'
        'fribidi'
        'fzf'
        'gawk'
        'gcc'
        'gdal'
        'gdbm'
        'geos'
        'git'
        'git-lfs'
        'glances'
        'glib'
        'gnupg'
        'gnutls'
        'go'
        'gperf'
        'graphviz'
        'grex'
        'groff'
        'gsl'
        'gtop'
        'gum'
        'gzip'
        'harfbuzz'
        'hdf5'
        'hexyl'
        'htop'
        'httpie'
        'hugo'
        'hyperfine'
        'icu4c'
        'imagemagick'
        'ipython'
        'isort'
        'jemalloc'
        'jpeg'
        'jq'
        'jupyterlab'
        'lame'
        'lapack'
        'latch'
        'less'
        'lesspipe'
        'libassuan'
        'libedit'
        'libev'
        'libevent'
        'libffi'
        'libgcrypt'
        'libgeotiff'
        'libgit2'
        'libgpg-error'
        'libidn'
        'libjpeg-turbo'
        'libksba'
        'libpipeline'
        'libpng'
        'libssh2'
        'libtasn1'
        'libtiff'
        'libtool'
        'libunistring'
        'libuv'
        'libxml2'
        'libyaml'
        'libzip'
        'llama'
        'lsd'
        'lua'
        'luarocks'
        'lz4'
        'lzo'
        'make'
        'man-db'
        'markdownlint-cli'
        'mcfly'
        'mdcat'
        'meson'
        'mpc'
        'mpdecimal'
        'mpfr'
        'nano'
        'ncurses'
        'neofetch'
        'neovim'
        'nettle'
        'nghttp2'
        'ninja'
        'nmap'
        'node'
        'npth'
        'nushell'
        'oniguruma'
        'openblas'
        'openjdk'
        'openssh'
        'pandoc'
        'parallel'
        'password-store'
        'patch'
        'perl'
        'pipx'
        'pixman'
        'pkg-config'
        'poetry'
        'prettier'
        'procs'
        'proj'
        'py-spy'
        'pycodestyle'
        'pyenv'
        'pyflakes'
        'pygments'
        'pylint'
        'pytaglib'
        'pytest'
        'python3.10'
        'python3.11'
        'r'
        'radian'
        'ranger-fm'
        'rbenv'
        'readline'
        'rename'
        'ripgrep'
        'ripgrep-all'
        'rmate'
        'ronn'
        'rsync'
        'ruby'
        'ruff'
        'scons'
        'sd'
        'serf'
        'shellcheck'
        'shunit2'
        'sox'
        'sqlite'
        'starship'
        'stow'
        'subversion'
        'swig'
        'taglib'
        'tar'
        'tcl-tk'
        'tealdeer'
        'texinfo'
        'tmux'
        'tokei'
        'tree'
        'tuc'
        'udunits'
        'units'
        'unzip'
        'utf8proc'
        'vim'
        'visidata'
        'vulture'
        'wget'
        'which'
        'xorg-libice'
        'xorg-libpthread-stubs'
        'xorg-libsm'
        'xorg-libx11'
        'xorg-libxau'
        'xorg-libxcb'
        'xorg-libxdmcp'
        'xorg-libxext'
        'xorg-libxrandr'
        'xorg-libxrender'
        'xorg-libxt'
        'xorg-xcb-proto'
        'xorg-xorgproto'
        'xorg-xtrans'
        'xsv'
        'xxhash'
        'xz'
        'yarn'
        'yq'
        'yt-dlp'
        'zellij'
        'zip'
        'zoxide'
        'zsh'
    )
    if ! koopa_is_aarch64
    then
        apps+=(
            'hadolint'
            'pandoc'
        )
    fi
    if koopa_is_linux
    then
        apps+=(
            'docker-credential-pass'
            'elfutils'
            'pinentry'
        )
    fi
    if [[ "${bool['large']}" -eq 1 ]]
    then
        apps+=(
            'apache-airflow'
            'apache-spark'
            'azure-cli'
            'cli11'
            'ensembl-perl-api'
            'fmt'
            'ghostscript'
            'google-cloud-sdk'
            'googletest'
            'gseapy'
            'haskell-cabal'
            'haskell-ghcup'
            'julia'
            'libarchive'
            'libsolv'
            'llvm'
            'mamba'
            'nlohmann-json'
            'pybind11'
            'r-devel'
            'reproc'
            'rust'
            'spdlog'
            'termcolor'
            'tl-expected'
            'yaml-cpp'
        )
        if ! koopa_is_aarch64
        then
            apps+=(
                'agat'
                'anaconda'
                'bamtools'
                'bedtools'
                'bioawk'
                'bowtie2'
                'bustools'
                'deeptools'
                'fastqc'
                'ffq'
                'fgbio'
                'gatk'
                'gffutils'
                'gget'
                'haskell-stack'
                'hisat2'
                'htseq'
                'kallisto'
                'minimap2'
                'multiqc'
                'nextflow'
                'salmon'
                'sambamba'
                'samtools'
                'scalene'
                'snakefmt'
                'snakemake'
                'sra-tools'
                'star'
                'star-fusion'
            )
        fi
        if koopa_is_linux
        then
            apps+=(
                'apptainer'
                'aspera-connect'
                'lmod'
            )
        fi
    fi
    koopa_add_to_path_start '/usr/local/bin'
    "${app['koopa']}" install 'aws-cli'
    for app_name in "${apps[@]}"
    do
        "${app['koopa']}" install --binary "$app_name"
    done
    return 0
}

koopa_install_anaconda() {
    koopa_install_app \
        --name='anaconda' \
        "$@"
}

koopa_install_apache_airflow() {
    koopa_install_app \
        --name='apache-airflow' \
        "$@"
}

koopa_install_apache_spark() {
    koopa_install_app \
        --name='apache-spark' \
        "$@"
}

koopa_install_app_from_binary_package() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['aws']="$(koopa_locate_aws --allow-system)"
        ['tar']="$(koopa_locate_tar --allow-system)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['tar']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch2)" # e.g. 'amd64'.
        ['aws_profile']="${AWS_PROFILE:-acidgenomics}"
        ['binary_prefix']='/opt/koopa'
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['os_string']="$(koopa_os_string)"
        ['s3_bucket']="s3://private.koopa.acidgenomics.com/binaries"
        ['tmp_dir']="$(koopa_tmp_dir)"
    )
    if [[ "${dict['koopa_prefix']}" != "${dict['binary_prefix']}" ]]
    then
        koopa_stop "Binary package installation not supported for koopa \
install located at '${dict['koopa_prefix']}'. Koopa must be installed at \
default '${dict['binary_prefix']}' location."
    fi
    koopa_assert_is_dir "$@"
    (
        koopa_cd "${dict['tmp_dir']}"
        for prefix in "$@"
        do
            local dict2
            declare -A dict2
            dict2['prefix']="$(koopa_realpath "$prefix")"
            dict2['name']="$( \
                koopa_print "${dict2['prefix']}" \
                    | koopa_dirname \
                    | koopa_basename \
            )"
            dict2['version']="$(koopa_basename "$prefix")"
            dict2['tar_file']="${dict['tmp_dir']}/\
${dict2['name']}-${dict2['version']}.tar.gz"
            dict2['tar_url']="${dict['s3_bucket']}/${dict['os_string']}/\
${dict['arch']}/${dict2['name']}/${dict2['version']}.tar.gz"
            "${app['aws']}" --profile="${dict['aws_profile']}" \
                s3 cp \
                    --only-show-errors \
                    "${dict2['tar_url']}" \
                    "${dict2['tar_file']}"
            koopa_assert_is_file "${dict2['tar_file']}"
            "${app['tar']}" -Pxzf "${dict2['tar_file']}"
            koopa_touch "${prefix}/.koopa-binary"
        done
    )
    koopa_rm "${dict['tmp_dir']}"
    return 0
}

koopa_install_app_subshell() {
    local dict pos
    declare -A dict=(
        ['installer_bn']=''
        ['installer_fun']='main'
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['mode']='shared'
        ['name']="${KOOPA_INSTALL_NAME:-}"
        ['platform']='common'
        ['prefix']="${KOOPA_INSTALL_PREFIX:-}"
        ['tmp_dir']="$(koopa_tmp_dir)"
        ['version']="${KOOPA_INSTALL_VERSION:-}"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--installer='*)
                dict['installer_bn']="${1#*=}"
                shift 1
                ;;
            '--installer')
                dict['installer_bn']="${2:?}"
                shift 2
                ;;
            '--mode='*)
                dict['mode']="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict['mode']="${2:?}"
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
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            '-D')
                pos+=("${2:?}")
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    [[ -z "${dict['installer_bn']}" ]] && dict['installer_bn']="${dict['name']}"
    dict['installer_file']="${dict['koopa_prefix']}/lang/shell/bash/include/\
install/${dict['platform']}/${dict['mode']}/${dict['installer_bn']}.sh"
    koopa_assert_is_file "${dict['installer_file']}"
    (
        koopa_cd "${dict['tmp_dir']}"
        export KOOPA_INSTALL_NAME="${dict['name']}"
        export KOOPA_INSTALL_PREFIX="${dict['prefix']}"
        export KOOPA_INSTALL_VERSION="${dict['version']}"
        source "${dict['installer_file']}"
        koopa_assert_is_function "${dict['installer_fun']}"
        "${dict['installer_fun']}" "$@"
        return 0
    )
    koopa_rm "${dict['tmp_dir']}"
    return 0
}

koopa_install_app() {
    local bin_arr bool dict i man1_arr pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A bool=(
        ['auto_prefix']=0
        ['binary']=0
        ['copy_log_files']=0
        ['link_in_bin']=''
        ['link_in_man1']=''
        ['link_in_opt']=''
        ['prefix_check']=1
        ['push']=0
        ['quiet']=0
        ['reinstall']=0
        ['subshell']=1
        ['update_ldconfig']=0
        ['verbose']=0
    )
    declare -A dict=(
        ['app_prefix']="$(koopa_app_prefix)"
        ['installer']=''
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['stderr_file']="$(koopa_tmp_log_file)"
        ['stdout_file']="$(koopa_tmp_log_file)"
        ['mode']='shared'
        ['name']=''
        ['platform']='common'
        ['prefix']=''
        ['version']=''
        ['version_key']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--installer='*)
                dict['installer']="${1#*=}"
                shift 1
                ;;
            '--installer')
                dict['installer']="${2:?}"
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
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            '--version-key='*)
                dict['version_key']="${1#*=}"
                shift 1
                ;;
            '--version-key')
                dict['version_key']="${2:?}"
                shift 2
                ;;
            '--binary')
                bool['binary']=1
                shift 1
                ;;
            '--push')
                bool['push']=1
                shift 1
                ;;
            '--reinstall')
                bool['reinstall']=1
                shift 1
                ;;
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            '--no-link-in-bin')
                bool['link_in_bin']=0
                shift 1
                ;;
            '--no-link-in-man1')
                bool['link_in_man1']=0
                shift 1
                ;;
            '--no-link-in-opt')
                bool['link_in_opt']=0
                shift 1
                ;;
            '--no-prefix-check')
                bool['prefix_check']=0
                shift 1
                ;;
            '--no-subshell')
                bool['subshell']=0
                shift 1
                ;;
            '--quiet')
                bool['quiet']=1
                shift 1
                ;;
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            '-D')
                pos+=("${1:?}" "${2:?}")
                shift 2
                ;;
            '')
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_set '--name' "${dict['name']}"
    [[ "${bool['verbose']}" -eq 1 ]] && set -o xtrace
    [[ -z "${dict['version_key']}" ]] && dict['version_key']="${dict['name']}"
    dict['current_version']="$(\
        koopa_app_json_version "${dict['version_key']}" \
            2>/dev/null || true \
    )"
    [[ -z "${dict['version']}" ]] && \
        dict['version']="${dict['current_version']}"
    case "${dict['mode']}" in
        'shared')
            if [[ -z "${dict['prefix']}" ]]
            then
                bool['auto_prefix']=1
                dict['version2']="${dict['version']}"
                [[ "${#dict['version']}" == 40 ]] && \
                    dict['version2']="${dict['version2']:0:7}"
                dict['prefix']="${dict['app_prefix']}/${dict['name']}/\
${dict['version2']}"
            fi
            if [[ "${dict['version']}" != "${dict['current_version']}" ]]
            then
                bool['link_in_bin']=0
                bool['link_in_man1']=0
                bool['link_in_opt']=0
            else
                [[ -z "${bool['link_in_bin']}" ]] && bool['link_in_bin']=1
                [[ -z "${bool['link_in_man1']}" ]] && bool['link_in_man1']=1
                [[ -z "${bool['link_in_opt']}" ]] && bool['link_in_opt']=1
            fi
            ;;
        'system')
            koopa_assert_is_admin
            bool['link_in_bin']=0
            bool['link_in_man1']=0
            bool['link_in_opt']=0
            koopa_is_linux && bool['update_ldconfig']=1
            ;;
        'user')
            bool['link_in_bin']=0
            bool['link_in_man1']=0
            bool['link_in_opt']=0
            ;;
    esac
    if [[ -n "${dict['prefix']}" ]] && [[ "${bool['prefix_check']}" -eq 1 ]]
    then
        if [[ -d "${dict['prefix']}" ]]
        then
            koopa_is_empty_dir "${dict['prefix']}" && bool['reinstall']=1
            if [[ "${bool['reinstall']}" -eq 1 ]]
            then
                [[ "${bool['quiet']}" -eq 0 ]] && \
                    koopa_alert_uninstall_start \
                        "${dict['name']}" "${dict['prefix']}"
                case "${dict['mode']}" in
                    'system')
                        koopa_rm --sudo "${dict['prefix']}"
                        ;;
                    *)
                        koopa_rm "${dict['prefix']}"
                        ;;
                esac
            fi
            if [[ -d "${dict['prefix']}" ]]
            then
                [[ "${bool['quiet']}" -eq 0 ]] && \
                    koopa_alert_is_installed \
                        "${dict['name']}" "${dict['prefix']}"
                return 0
            fi
        fi
        case "${dict['mode']}" in
            'system')
                dict['prefix']="$(koopa_init_dir --sudo "${dict['prefix']}")"
                ;;
            *)
                dict['prefix']="$(koopa_init_dir "${dict['prefix']}")"
                ;;
        esac
    fi
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        if [[ -n "${dict['prefix']}" ]]
        then
            koopa_alert_install_start "${dict['name']}" "${dict['prefix']}"
        else
            koopa_alert_install_start "${dict['name']}"
        fi
    fi
    case "${dict['mode']}" in
        'shared')
            case "${bool['binary']}" in
                '0')
                    local app env_vars path_arr
                    declare -A app
                    app['env']="$(koopa_locate_env --allow-system)"
                    app['tee']="$(koopa_locate_tee --allow-system)"
                    if koopa_is_macos
                    then
                        app['bash']='/usr/local/bin/bash'
                    else
                        app['bash']='/bin/bash'
                    fi
                    [[ -x "${app['bash']}" ]] || return 1
                    [[ -x "${app['env']}" ]] || return 1
                    [[ -x "${app['tee']}" ]] || return 1
                    path_arr=(
                        '/usr/bin'
                        '/usr/sbin'
                        '/bin'
                        '/sbin'
                    )
                    PKG_CONFIG_PATH=''
                    if koopa_is_linux && [[ -x '/usr/bin/pkg-config' ]]
                    then
                        koopa_activate_pkg_config '/usr/bin/pkg-config'
                    fi
                    env_vars=(
                        "HOME=${HOME:?}"
                        'KOOPA_ACTIVATE=0'
                        'KOOPA_INSTALL_APP_SUBSHELL=1'
                        "KOOPA_VERBOSE=${KOOPA_VERBOSE:-0}"
                        "LANG=${LANG:-}"
                        "LC_ALL=${LC_ALL:-}"
                        "LC_COLLATE=${LC_COLLATE:-}"
                        "LC_CTYPE=${LC_CTYPE:-}"
                        "LC_MESSAGES=${LC_MESSAGES:-}"
                        "LC_MONETARY=${LC_MONETARY:-}"
                        "LC_NUMERIC=${LC_NUMERIC:-}"
                        "LC_TIME=${LC_TIME:-}"
                        "PATH=$(koopa_paste --sep=':' "${path_arr[@]}")"
                        "PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-}"
                        "TMPDIR=${TMPDIR:-/tmp}"
                    )
                    if [[ -d "${dict['prefix']}" ]] && \
                        [[ "${dict['mode']}" != 'system' ]]
                    then
                        bool['copy_log_files']=1
                    fi
                    dict['header_file']="${dict['koopa_prefix']}/lang/shell/\
bash/include/header.sh"
                    "${app['env']}" -i \
                        "${env_vars[@]}" \
                        "${app['bash']}" \
                            --noprofile \
                            --norc \
                            -o errexit \
                            -o errtrace \
                            -o nounset \
                            -o pipefail \
                            -c "source '${dict['header_file']}'; \
                                koopa_install_app_subshell \
                                    --installer=${dict['installer']} \
                                    --mode=${dict['mode']} \
                                    --name=${dict['name']} \
                                    --platform=${dict['platform']} \
                                    --prefix=${dict['prefix']} \
                                    --version=${dict['version']} \
                                    ${*}" \
                        > >("${app['tee']}" "${dict['stdout_file']}") \
                        2> >("${app['tee']}" "${dict['stderr_file']}" >&2)
                    if [[ "${bool['copy_log_files']}" -eq 1 ]]
                    then
                        koopa_cp \
                            "${dict['stdout_file']}" \
                            "${dict['prefix']}/.koopa-install-stdout.log"
                        koopa_cp \
                            "${dict['stderr_file']}" \
                            "${dict['prefix']}/.koopa-install-stderr.log"
                    fi
                    ;;
                '1')
                    [[ "${dict['mode']}" == 'shared' ]] || return 1
                    [[ -n "${dict['prefix']}" ]] || return 1
                    koopa_install_app_from_binary_package "${dict['prefix']}"
                    ;;
            esac
            [[ "${bool['auto_prefix']}" -eq 1 ]] && \
                koopa_sys_set_permissions "$(koopa_dirname "${dict['prefix']}")"
            koopa_sys_set_permissions --recursive "${dict['prefix']}"
            [[ "${bool['link_in_opt']}" -eq 1 ]] && \
                koopa_link_in_opt \
                    --name="${dict['name']}" \
                    --source="${dict['prefix']}"
            if [[ "${bool['link_in_bin']}" -eq 1 ]]
            then
                readarray -t bin_arr <<< "$( \
                    koopa_app_json_bin "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if koopa_is_array_non_empty "${bin_arr[@]:-}"
                then
                    for i in "${!bin_arr[@]}"
                    do
                        local dict2
                        declare -A dict2
                        dict2['name']="${bin_arr[$i]}"
                        dict2['source']="${dict['prefix']}/bin/${dict2['name']}"
                        koopa_link_in_bin \
                            --name="${dict2['name']}" \
                            --source="${dict2['source']}"
                    done
                fi
            fi
            if [[ "${bool['link_in_man1']}" -eq 1 ]]
            then
                readarray -t man1_arr <<< "$( \
                    koopa_app_json_man1 "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if koopa_is_array_non_empty "${man1_arr[@]:-}"
                then
                    for i in "${!man1_arr[@]}"
                    do
                        local dict2
                        declare -A dict2
                        dict2['name']="${man1_arr[$i]}"
                        dict2['mf1']="${dict['prefix']}/share/man/\
man1/${dict2['name']}"
                        dict2['mf2']="${dict['prefix']}/man/\
man1/${dict2['name']}"
                        if [[ -f "${dict2['mf1']}" ]]
                        then
                            koopa_link_in_man1 \
                                --name="${dict2['name']}" \
                                --source="${dict2['mf1']}"
                        elif [[ -f "${dict2['mf2']}" ]]
                        then
                            koopa_link_in_man1 \
                                --name="${dict2['name']}" \
                                --source="${dict2['mf2']}"
                        fi
                    done
                fi
            fi
            [[ "${bool['push']}" -eq 1 ]] && \
                koopa_push_app_build "${dict['name']}"
            ;;
        'system')
            koopa_install_app_subshell \
                --installer="${dict['installer']}" \
                --mode="${dict['mode']}" \
                --name="${dict['name']}" \
                --platform="${dict['platform']}" \
                --prefix="${dict['prefix']}" \
                --version="${dict['version']}" \
                "$@"
            [[ "${bool['update_ldconfig']}" -eq 1 ]] && \
                koopa_linux_update_ldconfig
            ;;
        'user')
            koopa_install_app_subshell \
                --installer="${dict['installer']}" \
                --mode="${dict['mode']}" \
                --name="${dict['name']}" \
                --platform="${dict['platform']}" \
                --prefix="${dict['prefix']}" \
                --version="${dict['version']}" \
                "$@"
            [[ -d "${dict['prefix']}" ]] && \
                koopa_sys_set_permissions --recursive --user "${dict['prefix']}"
            ;;
    esac
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        if [[ -d "${dict['prefix']}" ]]
        then
            koopa_alert_install_success "${dict['name']}" "${dict['prefix']}"
        else
            koopa_alert_install_success "${dict['name']}"
        fi
    fi
    return 0
}

koopa_install_apr_util() {
    koopa_install_app \
        --name='apr-util' \
        "$@"
}

koopa_install_apr() {
    koopa_install_app \
        --name='apr' \
        "$@"
}

koopa_install_armadillo() {
    koopa_install_app \
        --name='armadillo' \
        "$@"
}

koopa_install_asdf() {
    koopa_install_app \
        --name='asdf' \
        "$@"
}

koopa_install_aspell() {
    koopa_install_app \
        --name='aspell' \
        "$@"
}

koopa_install_autoconf() {
    koopa_install_app \
        --name='autoconf' \
        "$@"
}

koopa_install_autodock_adfr() {
    koopa_install_app \
        --name='autodock-adfr' \
        "$@"
}

koopa_install_autodock_vina() {
    koopa_install_app \
        --name='autodock-vina' \
        "$@"
}

koopa_install_autodock() {
    koopa_install_app \
        --name='autodock' \
        "$@"
}

koopa_install_autoflake() {
    koopa_install_app \
        --name='autoflake' \
        "$@"
}

koopa_install_automake() {
    koopa_install_app \
        --name='automake' \
        "$@"
}

koopa_install_azure_cli() {
    koopa_install_app \
        --name='azure-cli' \
        "$@"
}

koopa_install_bamtools() {
    koopa_install_app \
        --name='bamtools' \
        "$@"
}

koopa_install_bandwhich() {
    koopa_install_app \
        --name='bandwhich' \
        "$@"
}

koopa_install_bash_language_server() {
    koopa_install_app \
        --name='bash-language-server' \
        "$@"
}

koopa_install_bash() {
    koopa_install_app \
        --name='bash' \
        "$@"
    koopa_enable_shell_for_all_users "$(koopa_bin_prefix)/bash"
    return 0
}

koopa_install_bashcov() {
    koopa_install_app \
        --name='bashcov' \
        "$@"
}

koopa_install_bat() {
    koopa_install_app \
        --name='bat' \
        "$@"
}

koopa_install_bc() {
    koopa_install_app \
        --name='bc' \
        "$@"
}

koopa_install_bedtools() {
    koopa_install_app \
        --name='bedtools' \
        "$@"
}

koopa_install_bfg() {
    koopa_install_app \
        --name='bfg' \
        "$@"
}

koopa_install_binutils() {
    koopa_install_app \
        --name='binutils' \
        "$@"
}

koopa_install_bioawk() {
    koopa_install_app \
        --name='bioawk' \
        "$@"
}

koopa_install_bioconda_utils() {
    koopa_install_app \
        --name='bioconda-utils' \
        "$@"
}

koopa_install_bison() {
    koopa_install_app \
        --name='bison' \
        "$@"
}

koopa_install_black() {
    koopa_install_app \
        --name='black' \
        "$@"
}

koopa_install_boost() {
    koopa_install_app \
        --name='boost' \
        "$@"
}

koopa_install_bottom() {
    koopa_install_app \
        --name='bottom' \
        "$@"
}

koopa_install_bowtie2() {
    koopa_install_app \
        --name='bowtie2' \
        "$@"
}

koopa_install_bpytop() {
    koopa_install_app \
        --name='bpytop' \
        "$@"
}

koopa_install_broot() {
    koopa_install_app \
        --name='broot' \
        "$@"
}

koopa_install_brotli() {
    koopa_install_app \
        --name='brotli' \
        "$@"
}

koopa_install_bustools() {
    koopa_install_app \
        --name='bustools' \
        "$@"
}

koopa_install_bzip2() {
    koopa_install_app \
        --name='bzip2' \
        "$@"
}

koopa_install_c_ares() {
    koopa_install_app \
        --name='c-ares' \
        "$@"
}

koopa_install_ca_certificates() {
    koopa_install_app \
        --name='ca-certificates' \
        "$@"
}

koopa_install_cairo() {
    koopa_install_app \
        --name='cairo' \
        "$@"
}

koopa_install_cheat() {
    koopa_install_app \
        --name='cheat' \
        "$@"
}

koopa_install_chemacs() {
    koopa_install_app \
        --name='chemacs' \
        "$@"
}

koopa_install_chezmoi() {
    koopa_install_app \
        --name='chezmoi' \
        "$@"
}

koopa_install_cli11() {
    koopa_install_app \
        --name='cli11' \
        "$@"
}

koopa_install_cmake() {
    koopa_install_app \
        --name='cmake' \
        "$@"
}

koopa_install_colorls() {
    koopa_install_app \
        --name='colorls' \
        "$@"
}

koopa_install_conda() {
    koopa_install_app \
        --name='conda' \
        "$@"
}

koopa_install_convmv() {
    koopa_install_app \
        --name='convmv' \
        "$@"
}

koopa_install_coreutils() {
    koopa_install_app \
        --name='coreutils' \
        "$@"
}

koopa_install_cpufetch() {
    koopa_install_app \
        --name='cpufetch' \
        "$@"
}

koopa_install_csvkit() {
    koopa_install_app \
        --name='csvkit' \
        "$@"
}

koopa_install_csvtk() {
    koopa_install_app \
        --name='csvtk' \
        "$@"
}

koopa_install_curl() {
    koopa_install_app \
        --name='curl' \
        "$@"
}

koopa_install_deeptools() {
    koopa_install_app \
        --name='deeptools' \
        "$@"
}

koopa_install_delta() {
    koopa_install_app \
        --name='delta' \
        "$@"
}

koopa_install_diff_so_fancy() {
    koopa_install_app \
        --name='diff-so-fancy' \
        "$@"
}

koopa_install_difftastic() {
    koopa_install_app \
        --name='difftastic' \
        "$@"
}

koopa_install_dog() {
    koopa_install_app \
        --name='dog' \
        "$@"
}

koopa_install_dotfiles() {
    koopa_install_app \
        --name='dotfiles' \
        "$@"
}

koopa_install_du_dust() {
    koopa_install_app \
        --name='du-dust' \
        "$@"
}

koopa_install_editorconfig() {
    koopa_install_app \
        --name='editorconfig' \
        "$@"
}

koopa_install_emacs() {
    koopa_install_app \
        --name='emacs' \
        "$@"
}

koopa_install_ensembl_perl_api() {
    koopa_install_app \
        --name='ensembl-perl-api' \
        "$@"
}

koopa_install_entrez_direct() {
    koopa_install_app \
        --name='entrez-direct' \
        "$@"
}

koopa_install_exa() {
    koopa_install_app \
        --name='exa' \
        "$@"
}

koopa_install_exiftool() {
    koopa_install_app \
        --name='exiftool' \
        "$@"
}

koopa_install_expat() {
    koopa_install_app \
        --name='expat' \
        "$@"
}

koopa_install_fastqc() {
    koopa_install_app \
        --name='fastqc' \
        "$@"
}

koopa_install_fd_find() {
    koopa_install_app \
        --name='fd-find' \
        "$@"
}

koopa_install_ffmpeg() {
    koopa_install_app \
        --name='ffmpeg' \
        "$@"
}

koopa_install_ffq() {
    koopa_install_app \
        --name='ffq' \
        "$@"
}

koopa_install_fgbio() {
    koopa_install_app \
        --name='fgbio' \
        "$@"
}

koopa_install_findutils() {
    koopa_install_app \
        --name='findutils' \
        "$@"
}

koopa_install_fish() {
    koopa_install_app \
        --name='fish' \
        "$@"
    koopa_enable_shell_for_all_users "$(koopa_bin_prefix)/fish"
    return 0
}

koopa_install_flac() {
    koopa_install_app \
        --name='flac' \
        "$@"
}

koopa_install_flake8() {
    koopa_install_app \
        --name='flake8' \
        "$@"
}

koopa_install_flex() {
    koopa_install_app \
        --name='flex' \
        "$@"
}

koopa_install_fltk() {
    koopa_install_app \
        --name='fltk' \
        "$@"
}

koopa_install_fmt() {
    koopa_install_app \
        --name='fmt' \
        "$@"
}

koopa_install_fontconfig() {
    koopa_install_app \
        --name='fontconfig' \
        "$@"
}

koopa_install_fq() {
    koopa_install_app \
        --name='fq' \
        "$@"
}

koopa_install_freetype() {
    koopa_install_app \
        --name='freetype' \
        "$@"
}

koopa_install_fribidi() {
    koopa_install_app \
        --name='fribidi' \
        "$@"
}

koopa_install_fzf() {
    koopa_install_app \
        --name='fzf' \
        "$@"
}

koopa_install_gatk() {
    koopa_install_app \
        --name='gatk' \
        "$@"
}

koopa_install_gawk() {
    koopa_install_app \
        --name='gawk' \
        "$@"
}

koopa_install_gcc() {
    koopa_install_app \
        --name='gcc' \
        "$@"
}

koopa_install_gdal() {
    koopa_install_app \
        --name='gdal' \
        "$@"
}

koopa_install_gdbm() {
    koopa_install_app \
        --name='gdbm' \
        "$@"
}

koopa_install_geos() {
    koopa_install_app \
        --name='geos' \
        "$@"
}

koopa_install_gettext() {
    koopa_install_app \
        --name='gettext' \
        "$@"
}

koopa_install_gffutils() {
    koopa_install_app \
        --name='gffutils' \
        "$@"
}

koopa_install_gget() {
    koopa_install_app \
        --name='gget' \
        "$@"
}

koopa_install_ghostscript() {
    koopa_install_app \
        --name='ghostscript' \
        "$@"
}

koopa_install_git_lfs() {
    koopa_install_app \
        --name='git-lfs' \
        "$@"
}

koopa_install_git() {
    koopa_install_app \
        --name='git' \
        "$@"
}

koopa_install_glances() {
    koopa_install_app \
        --name='glances' \
        "$@"
}

koopa_install_glib() {
    koopa_install_app \
        --name='glib' \
        "$@"
}

koopa_install_gmp() {
    koopa_install_app \
        --name='gmp' \
        "$@"
}

koopa_install_gnupg() {
    koopa_install_app \
        --name='gnupg' \
        "$@"
}

koopa_install_gnutls() {
    koopa_install_app \
        --name='gnutls' \
        "$@"
}

koopa_install_go() {
    koopa_install_app \
        --name='go' \
        "$@"
}

koopa_install_google_cloud_sdk() {
    koopa_install_app \
        --name='google-cloud-sdk' \
        "$@"
}

koopa_install_googletest() {
    koopa_install_app \
        --name='googletest' \
        "$@"
}

koopa_install_gperf() {
    koopa_install_app \
        --name='gperf' \
        "$@"
}

koopa_install_graphviz() {
    koopa_install_app \
        --name='graphviz' \
        "$@"
}

koopa_install_grep() {
    koopa_install_app \
        --name='grep' \
        "$@"
}

koopa_install_grex() {
    koopa_install_app \
        --name='grex' \
        "$@"
}

koopa_install_groff() {
    koopa_install_app \
        --name='groff' \
        "$@"
}

koopa_install_gseapy() {
    koopa_install_app \
        --name='gseapy' \
        "$@"
}

koopa_install_gsl() {
    koopa_install_app \
        --name='gsl' \
        "$@"
}

koopa_install_gtop() {
    koopa_install_app \
        --name='gtop' \
        "$@"
}

koopa_install_gum() {
    koopa_install_app \
        --name='gum' \
        "$@"
}

koopa_install_gzip() {
    koopa_install_app \
        --name='gzip' \
        "$@"
}

koopa_install_hadolint() {
    koopa_install_app \
        --name='hadolint' \
        "$@"
}

koopa_install_harfbuzz() {
    koopa_install_app \
        --name='harfbuzz' \
        "$@"
}

koopa_install_haskell_cabal() {
    koopa_install_app \
        --name='haskell-cabal' \
        "$@"
}

koopa_install_haskell_ghcup() {
    koopa_install_app \
        --name='haskell-ghcup' \
        "$@"
}

koopa_install_haskell_stack() {
    koopa_install_app \
        --name='haskell-stack' \
        "$@"
}

koopa_install_hdf5() {
    koopa_install_app \
        --name='hdf5' \
        "$@"
}

koopa_install_hexyl() {
    koopa_install_app \
        --name='hexyl' \
        "$@"
}

koopa_install_hisat2() {
    koopa_install_app \
        --name='hisat2' \
        "$@"
}

koopa_install_htop() {
    koopa_install_app \
        --name='htop' \
        "$@"
}

koopa_install_htseq() {
    koopa_install_app \
        --name='htseq' \
        "$@"
}

koopa_install_httpie() {
    koopa_install_app \
        --name='httpie' \
        "$@"
}

koopa_install_hugo() {
    koopa_install_app \
        --name='hugo' \
        "$@"
}

koopa_install_hyperfine() {
    koopa_install_app \
        --name='hyperfine' \
        "$@"
}

koopa_install_icu4c() {
    koopa_install_app \
        --name='icu4c' \
        "$@"
}

koopa_install_imagemagick() {
    koopa_install_app \
        --name='imagemagick' \
        "$@"
}

koopa_install_ipython() {
    koopa_install_app \
        --name='ipython' \
        "$@"
}

koopa_install_isort() {
    koopa_install_app \
        --name='isort' \
        "$@"
}

koopa_install_jemalloc() {
    koopa_install_app \
        --name='jemalloc' \
        "$@"
}

koopa_install_jpeg() {
    koopa_install_app \
        --name='jpeg' \
        "$@"
}

koopa_install_jq() {
    koopa_install_app \
        --name='jq' \
        "$@"
}

koopa_install_julia_packages() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['julia']="$(koopa_locate_julia)"
    )
    [[ -x "${app['julia']}" ]] || return 1
    declare -A dict=(
        ['script_prefix']="$(koopa_julia_script_prefix)"
    )
    dict['script']="${dict['script_prefix']}/install-packages.jl"
    koopa_assert_is_file "${dict['script']}"
    koopa_activate_julia
    "${app['julia']}" "${dict['script']}"
    return 0
}

koopa_install_julia() {
    koopa_install_app \
        --name='julia' \
        "$@"
}

koopa_install_jupyterlab() {
    koopa_install_app \
        --name='jupyterlab' \
        "$@"
}

koopa_install_kallisto() {
    koopa_install_app \
        --name='kallisto' \
        "$@"
}

koopa_install_koopa() {
    local bool dict
    koopa_assert_is_installed \
        'cp' 'curl' 'cut' 'find' 'git' 'grep' 'mkdir' \
        'mktemp' 'mv' 'perl' 'readlink' 'rm' 'sed' 'tar' 'tr' 'unzip'
    declare -A bool=(
        ['add_to_user_profile']=1
        ['interactive']=1
        ['passwordless_sudo']=0
        ['shared']=0
    )
    declare -A dict=(
        ['config_prefix']="$(koopa_config_prefix)"
        ['prefix']=''
        ['source_prefix']="$(koopa_koopa_prefix)"
        ['user_profile']="$(koopa_find_user_profile)"
        ['xdg_data_home']="$(koopa_xdg_data_home)"
    )
    dict['koopa_prefix_system']='/opt/koopa'
    dict['koopa_prefix_user']="${dict['xdg_data_home']}/koopa"
    koopa_is_admin && bool['shared']=1
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--add-to-user-profile')
                bool['add_to_user_profile']=1
                shift 1
                ;;
            '--no-add-to-user-profile')
                bool['add_to_user_profile']=0
                shift 1
                ;;
            '--interactive')
                bool['interactive']=1
                shift 1
                ;;
            '--non-interactive')
                bool['interactive']=0
                shift 1
                ;;
            '--passwordless-sudo')
                bool['passwordless_sudo']=1
                shift 1
                ;;
            '--no-passwordless-sudo')
                bool['passwordless_sudo']=0
                shift 1
                ;;
            '--shared')
                bool['shared']=1
                shift 1
                ;;
            '--no-shared')
                bool['shared']=0
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${bool['interactive']}" -eq 1 ]]
    then
        if koopa_is_admin && [[ -z "${dict['prefix']}" ]]
        then
            bool['shared']="$( \
                koopa_read_yn \
                    'Install for all users' \
                    "${bool['shared']}" \
            )"
        fi
        if [[ -z "${dict['prefix']}" ]]
        then
            if [[ "${bool['shared']}" -eq 1 ]]
            then
                dict['prefix']="${dict['koopa_prefix_system']}"
            else
                dict['prefix']="${dict['koopa_prefix_user']}"
            fi
        fi
        dict['koopa_prefix']="$( \
            koopa_read \
                'Install prefix' \
                "${dict['prefix']}" \
        )"
        if koopa_str_detect_regex \
            --string="${dict['prefix']}" \
            --pattern="^${HOME:?}"
        then
            bool['shared']=0
        else
            bool['shared']=1
        fi
        if [[ "${bool['shared']}" -eq 1 ]]
        then
            bool['passwordless_sudo']="$( \
                koopa_read_yn \
                    'Enable passwordless sudo' \
                    "${bool['passwordless_sudo']}" \
            )"
        fi
        if ! koopa_is_defined_in_user_profile && \
            [[ ! -L "${dict['user_profile']}" ]]
        then
            koopa_alert_note 'Koopa activation missing in user profile.'
            bool['add_to_user_profile']="$( \
                koopa_read_yn \
                    "Modify '${dict['user_profile']}'" \
                    "${bool['add_to_user_profile']}" \
            )"
        fi
    else
        if [[ -z "${dict['prefix']}" ]]
        then
            if [[ "${bool['shared']}" -eq 1 ]]
            then
                dict['prefix']="${dict['koopa_prefix_system']}"
            else
                dict['prefix']="${dict['koopa_prefix_user']}"
            fi
        fi
    fi
    koopa_assert_is_not_dir "${dict['prefix']}"
    koopa_rm "${dict['config_prefix']}"
    if [[ "${bool['shared']}" -eq 1 ]]
    then
        koopa_alert_info 'Shared installation detected.'
        koopa_alert_note 'Admin (sudo) permissions are required.'
        koopa_assert_is_admin
        koopa_rm --sudo "${dict['prefix']}"
        koopa_cp --sudo "${dict['source_prefix']}" "${dict['prefix']}"
        koopa_sys_set_permissions --recursive "${dict['prefix']}"
        koopa_add_make_prefix_link "${dict['prefix']}"
    else
        koopa_cp "${dict['source_prefix']}" "${dict['prefix']}"
    fi
    export KOOPA_PREFIX="${dict['prefix']}"
    if [[ "${bool['shared']}" -eq 1 ]]
    then
        if [[ "${bool['passwordless_sudo']}" -eq 1 ]]
        then
            koopa_enable_passwordless_sudo
        fi
        if koopa_is_linux
        then
            koopa_linux_update_etc_profile_d
        fi
    fi
    if [[ "${bool['add_to_user_profile']}" -eq 1 ]]
    then
        koopa_add_to_user_profile
    fi
    koopa_fix_zsh_permissions
    koopa_add_config_link "${dict['prefix']}/activate" 'activate'
    return 0
}

koopa_install_lame() {
    koopa_install_app \
        --name='lame' \
        "$@"
}

koopa_install_lapack() {
    koopa_install_app \
        --name='lapack' \
        "$@"
}

koopa_install_latch() {
    koopa_install_app \
        --name='latch' \
        "$@"
}

koopa_install_less() {
    koopa_install_app \
        --name='less' \
        "$@"
}

koopa_install_lesspipe() {
    koopa_install_app \
        --name='lesspipe' \
        "$@"
}

koopa_install_libarchive() {
    koopa_install_app \
        --name='libarchive' \
        "$@"
}

koopa_install_libassuan() {
    koopa_install_app \
        --name='libassuan' \
        "$@"
}

koopa_install_libedit() {
    koopa_install_app \
        --name='libedit' \
        "$@"
}

koopa_install_libev() {
    koopa_install_app \
        --name='libev' \
        "$@"
}

koopa_install_libevent() {
    koopa_install_app \
        --name='libevent' \
        "$@"
}

koopa_install_libffi() {
    koopa_install_app \
        --name='libffi' \
        "$@"
}

koopa_install_libgcrypt() {
    koopa_install_app \
        --name='libgcrypt' \
        "$@"
}

koopa_install_libgeotiff() {
    koopa_install_app \
        --name='libgeotiff' \
        "$@"
}

koopa_install_libgit2() {
    koopa_install_app \
        --name='libgit2' \
        "$@"
}

koopa_install_libgpg_error() {
    koopa_install_app \
        --name='libgpg-error' \
        "$@"
}

koopa_install_libiconv() {
    koopa_install_app \
        --name='libiconv' \
        "$@"
}

koopa_install_libidn() {
    koopa_install_app \
        --name='libidn' \
        "$@"
}

koopa_install_libjpeg_turbo() {
    koopa_install_app \
        --name='libjpeg-turbo' \
        "$@"
}

koopa_install_libksba() {
    koopa_install_app \
        --name='libksba' \
        "$@"
}

koopa_install_libluv() {
    koopa_install_app \
        --name='libluv' \
        "$@"
}

koopa_install_libpipeline() {
    koopa_install_app \
        --name='libpipeline' \
        "$@"
}

koopa_install_libpng() {
    koopa_install_app \
        --name='libpng' \
        "$@"
}

koopa_install_libsolv() {
    koopa_install_app \
        --name='libsolv' \
        "$@"
}

koopa_install_libssh2() {
    koopa_install_app \
        --name='libssh2' \
        "$@"
}

koopa_install_libtasn1() {
    koopa_install_app \
        --name='libtasn1' \
        "$@"
}

koopa_install_libtermkey() {
    koopa_install_app \
        --name='libtermkey' \
        "$@"
}

koopa_install_libtiff() {
    koopa_install_app \
        --name='libtiff' \
        "$@"
}

koopa_install_libtool() {
    koopa_install_app \
        --name='libtool' \
        "$@"
}

koopa_install_libunistring() {
    koopa_install_app \
        --name='libunistring' \
        "$@"
}

koopa_install_libuv() {
    koopa_install_app \
        --name='libuv' \
        "$@"
}

koopa_install_libvterm() {
    koopa_install_app \
        --name='libvterm' \
        "$@"
}

koopa_install_libxml2() {
    koopa_install_app \
        --name='libxml2' \
        "$@"
}

koopa_install_libyaml() {
    koopa_install_app \
        --name='libyaml' \
        "$@"
}

koopa_install_libzip() {
    koopa_install_app \
        --name='libzip' \
        "$@"
}

koopa_install_llama() {
    koopa_install_app \
        --name='llama' \
        "$@"
}

koopa_install_llvm() {
    koopa_install_app \
        --name='llvm' \
        "$@"
}

koopa_install_lsd() {
    koopa_install_app \
        --name='lsd' \
        "$@"
}

koopa_install_lua() {
    koopa_install_app \
        --name='lua' \
        "$@"
}

koopa_install_luajit() {
    koopa_install_app \
        --name='luajit' \
        "$@"
}

koopa_install_luarocks() {
    koopa_install_app \
        --name='luarocks' \
        "$@"
}

koopa_install_lz4() {
    koopa_install_app \
        --name='lz4' \
        "$@"
}

koopa_install_lzo() {
    koopa_install_app \
        --name='lzo' \
        "$@"
}

koopa_install_m4() {
    koopa_install_app \
        --name='m4' \
        "$@"
}

koopa_install_make() {
    koopa_install_app \
        --name='make' \
        "$@"
}

koopa_install_mamba() {
    koopa_install_app \
        --name='mamba' \
        "$@"
}

koopa_install_man_db() {
    koopa_install_app \
        --name='man-db' \
        "$@"
}

koopa_install_markdownlint_cli() {
    koopa_install_app \
        --name='markdownlint-cli' \
        "$@"
}

koopa_install_mcfly() {
    koopa_install_app \
        --name='mcfly' \
        "$@"
}

koopa_install_mdcat() {
    koopa_install_app \
        --name='mdcat' \
        "$@"
}

koopa_install_meson() {
    koopa_install_app \
        --name='meson' \
        "$@"
}

koopa_install_minimap2() {
    koopa_install_app \
        --name='minimap2' \
        "$@"
}

koopa_install_misopy() {
    koopa_install_app \
        --name='misopy' \
        "$@"
}

koopa_install_mpc() {
    koopa_install_app \
        --name='mpc' \
        "$@"
}

koopa_install_mpdecimal() {
    koopa_install_app \
        --name='mpdecimal' \
        "$@"
}

koopa_install_mpfr() {
    koopa_install_app \
        --name='mpfr' \
        "$@"
}

koopa_install_msgpack() {
    koopa_install_app \
        --name='msgpack' \
        "$@"
}

koopa_install_multiqc() {
    koopa_install_app \
        --name='multiqc' \
        "$@"
}

koopa_install_nano() {
    koopa_install_app \
        --name='nano' \
        "$@"
}

koopa_install_nanopolish() {
    koopa_install_app \
        --name='nanopolish' \
        "$@"
}

koopa_install_ncurses() {
    koopa_install_app \
        --name='ncurses' \
        "$@"
}

koopa_install_neofetch() {
    koopa_install_app \
        --name='neofetch' \
        "$@"
}

koopa_install_neovim() {
    koopa_install_app \
        --name='neovim' \
        "$@"
}

koopa_install_nettle() {
    koopa_install_app \
        --name='nettle' \
        "$@"
}

koopa_install_nextflow() {
    koopa_install_app \
        --name='nextflow' \
        "$@"
}

koopa_install_nghttp2() {
    koopa_install_app \
        --name='nghttp2' \
        "$@"
}

koopa_install_nim() {
    koopa_install_app \
        --name='nim' \
        "$@"
}

koopa_install_ninja() {
    koopa_install_app \
        --name='ninja' \
        "$@"
}

koopa_install_nlohmann_json() {
    koopa_install_app \
        --name='nlohmann-json' \
        "$@"
}

koopa_install_nmap() {
    koopa_install_app \
        --name='nmap' \
        "$@"
}

koopa_install_node() {
    koopa_install_app \
        --name='node' \
        "$@"
}

koopa_install_npth() {
    koopa_install_app \
        --name='npth' \
        "$@"
}

koopa_install_nushell() {
    koopa_install_app \
        --name='nushell' \
        "$@"
    koopa_enable_shell_for_all_users "$(koopa_bin_prefix)/nu"
    return 0
}

koopa_install_oniguruma() {
    koopa_install_app \
        --name='oniguruma' \
        "$@"
}

koopa_install_ont_guppy() {
    koopa_install_app \
        --name='ont-guppy' \
        "$@"
    koopa_alert_note "Installation requires agreement to terms of service at: \
'https://nanoporetech.com/support/nanopore-sequencing-data-analysis'."
    return 0
}

koopa_install_openbb() {
    koopa_install_app \
        --name='openbb' \
        "$@"
}

koopa_install_openblas() {
    koopa_install_app \
        --name='openblas' \
        "$@"
}

koopa_install_openjdk() {
    koopa_install_app \
        --name='openjdk' \
        "$@"
}

koopa_install_openssh() {
    koopa_install_app \
        --name='openssh' \
        "$@"
}

koopa_install_openssl1() {
    koopa_install_app \
        --name='openssl1' \
        "$@"
}

koopa_install_openssl3() {
    koopa_install_app \
        --name='openssl3' \
        "$@"
}

koopa_install_pandoc() {
    koopa_install_app \
        --name='pandoc' \
        "$@"
}

koopa_install_parallel() {
    koopa_install_app \
        --name='parallel' \
        "$@"
}

koopa_install_password_store() {
    koopa_install_app \
        --name='password-store' \
        "$@"
}

koopa_install_patch() {
    koopa_install_app \
        --name='patch' \
        "$@"
}

koopa_install_pcre() {
    koopa_install_app \
        --name='pcre' \
        "$@"
}

koopa_install_pcre2() {
    koopa_install_app \
        --name='pcre2' \
        "$@"
}

koopa_install_perl() {
    koopa_install_app \
        --name='perl' \
        "$@"
}

koopa_install_pipx() {
    koopa_install_app \
        --name='pipx' \
        "$@"
}

koopa_install_pixman() {
    koopa_install_app \
        --name='pixman' \
        "$@"
}

koopa_install_pkg_config() {
    koopa_install_app \
        --name='pkg-config' \
        "$@"
}

koopa_install_poetry() {
    koopa_install_app \
        --name='poetry' \
        "$@"
}

koopa_install_prettier() {
    koopa_install_app \
        --name='prettier' \
        "$@"
}

koopa_install_procs() {
    koopa_install_app \
        --name='procs' \
        "$@"
}

koopa_install_proj() {
    koopa_install_app \
        --name='proj' \
        "$@"
}

koopa_install_py_spy() {
    koopa_install_app \
        --name='py-spy' \
        "$@"
}

koopa_install_pybind11() {
    koopa_install_app \
        --name='pybind11' \
        "$@"
}

koopa_install_pycodestyle() {
    koopa_install_app \
        --name='pycodestyle' \
        "$@"
}

koopa_install_pyenv() {
    koopa_install_app \
        --name='pyenv' \
        "$@"
}

koopa_install_pyflakes() {
    koopa_install_app \
        --name='pyflakes' \
        "$@"
}

koopa_install_pygments() {
    koopa_install_app \
        --name='pygments' \
        "$@"
}

koopa_install_pylint() {
    koopa_install_app \
        --name='pylint' \
        "$@"
}

koopa_install_pytaglib() {
    koopa_install_app \
        --name='pytaglib' \
        "$@"
}

koopa_install_pytest() {
    koopa_install_app \
        --name='pytest' \
        "$@"
}

koopa_install_python310() {
    koopa_install_app \
        --installer='python' \
        --name='python3.10' \
        "$@"
}

koopa_install_python311() {
    local dict
    declare -A dict=(
        ['app_prefix']="$(koopa_app_prefix)"
        ['bin_prefix']="$(koopa_bin_prefix)"
        ['man1_prefix']="$(koopa_man1_prefix)"
        ['opt_prefix']="$(koopa_opt_prefix)"
    )
    koopa_install_app \
        --installer='python' \
        --name='python3.11' \
        "$@"
    (
        koopa_alert "Linking 'python' in '${dict['app_prefix']}'."
        koopa_cd "${dict['app_prefix']}"
        koopa_ln 'python3.11' 'python'
        koopa_alert "Linking 'python' in '${dict['bin_prefix']}'."
        koopa_cd "${dict['bin_prefix']}"
        koopa_ln 'python3.11' 'python3'
        koopa_ln 'python3.11' 'python'
        koopa_alert "Linking 'python' in '${dict['man1_prefix']}'."
        koopa_cd "${dict['man1_prefix']}"
        koopa_ln 'python3.11.1' 'python3.1'
        koopa_ln 'python3.11.1' 'python.1'
        koopa_alert "Linking 'python' in '${dict['opt_prefix']}'."
        koopa_cd "${dict['opt_prefix']}"
        koopa_ln 'python3.11' 'python'
    )
    return 0
}

koopa_install_r_devel() {
    koopa_install_app \
        --name='r-devel' \
        "$@"
}

koopa_install_r_koopa() {
    local app
    koopa_assert_has_args_le "$#" 1
    declare -A app
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    app['rscript']="${app['r']}script"
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['rscript']}" ]] || return 1
    "${app['rscript']}" -e " \
        if (!requireNamespace('BiocManager', quietly = TRUE)) { ; \
            install.packages('BiocManager') ; \
        } ; \
        install.packages(
            pkgs = 'koopa',
            repos = c(
                'https://r.acidgenomics.com',
                BiocManager::repositories()
            ),
            dependencies = TRUE
        ); \
    "
    return 0
}

koopa_install_r_packages() {
    local app
    koopa_assert_has_args_le "$#" 1
    declare -A app
    app['r']="${1:-}"
    if [[ -z "${app['r']}" ]] && koopa_is_macos
    then
        app['r']="$(koopa_macos_r_prefix)/bin/R"
    fi
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    app['rscript']="${app['r']}script"
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['rscript']}" ]] || return 1
    koopa_configure_r "${app['r']}"
    "${app['rscript']}" -e " \
        if (!requireNamespace('AcidDevTools', quietly = TRUE)) { ; \
            install.packages('AcidDevTools') ; \
        } ; \
        AcidDevTools::installRecommendedPackages(); \
    "
    return 0
}

koopa_install_r() {
    koopa_install_app \
        --name='r' \
        "$@"
}

koopa_install_radian() {
    koopa_install_app \
        --name='radian' \
        "$@"
}

koopa_install_ranger_fm() {
    koopa_install_app \
        --name='ranger-fm' \
        "$@"
}

koopa_install_rbenv() {
    koopa_install_app \
        --name='rbenv' \
        "$@"
}

koopa_install_readline() {
    koopa_install_app \
        --name='readline' \
        "$@"
}

koopa_install_rename() {
    koopa_install_app \
        --name='rename' \
        "$@"
}

koopa_install_reproc() {
    koopa_install_app \
        --name='reproc' \
        "$@"
}

koopa_install_ripgrep_all() {
    koopa_install_app \
        --name='ripgrep-all' \
        "$@"
}

koopa_install_ripgrep() {
    koopa_install_app \
        --name='ripgrep' \
        "$@"
}

koopa_install_rmate() {
    koopa_install_app \
        --name='rmate' \
        "$@"
}

koopa_install_ronn() {
    koopa_install_app \
        --name='ronn' \
        "$@"
}

koopa_install_rsem() {
    koopa_install_app \
        --name='rsem' \
        "$@"
}

koopa_install_rsync() {
    koopa_install_app \
        --name='rsync' \
        "$@"
}

koopa_install_ruby() {
    koopa_install_app \
        --name='ruby' \
        "$@"
}

koopa_install_ruff() {
    koopa_install_app \
        --name='ruff' \
        "$@"
}

koopa_install_rust() {
    koopa_install_app \
        --name='rust' \
        "$@"
}

koopa_install_salmon() {
    koopa_install_app \
        --name='salmon' \
        "$@"
}

koopa_install_sambamba() {
    koopa_install_app \
        --name='sambamba' \
        "$@"
}

koopa_install_samtools() {
    koopa_install_app \
        --name='samtools' \
        "$@"
}

koopa_install_scalene() {
    koopa_install_app \
        --name='scalene' \
        "$@"
}

koopa_install_scons() {
    koopa_install_app \
        --name='scons' \
        "$@"
}

koopa_install_sd() {
    koopa_install_app \
        --name='sd' \
        "$@"
}

koopa_install_sed() {
    koopa_install_app \
        --name='sed' \
        "$@"
}

koopa_install_serf() {
    koopa_install_app \
        --name='serf' \
        "$@"
}

koopa_install_shellcheck() {
    koopa_install_app \
        --name='shellcheck' \
        "$@"
}

koopa_install_shunit2() {
    koopa_install_app \
        --name='shunit2' \
        "$@"
}

koopa_install_snakefmt() {
    koopa_install_app \
        --name='snakefmt' \
        "$@"
}

koopa_install_snakemake() {
    koopa_install_app \
        --name='snakemake' \
        "$@"
}

koopa_install_sox() {
    koopa_install_app \
        --name='sox' \
        "$@"
}

koopa_install_spdlog() {
    koopa_install_app \
        --name='spdlog' \
        "$@"
}

koopa_install_sqlite() {
    koopa_install_app \
        --name='sqlite' \
        "$@"
}

koopa_install_sra_tools() {
    koopa_install_app \
        --name='sra-tools' \
        "$@"
}

koopa_install_star_fusion() {
    koopa_install_app \
        --name='star-fusion' \
        "$@"
}

koopa_install_star() {
    koopa_install_app \
        --name='star' \
        "$@"
}

koopa_install_starship() {
    koopa_install_app \
        --name='starship' \
        "$@"
}

koopa_install_stow() {
    koopa_install_app \
        --name='stow' \
        "$@"
}

koopa_install_subversion() {
    koopa_install_app \
        --name='subversion' \
        "$@"
}

koopa_install_swig() {
    koopa_install_app \
        --name='swig' \
        "$@"
}

koopa_install_system_homebrew_bundle() {
    koopa_install_app \
        --name='homebrew-bundle' \
        --system \
        "$@"
}

koopa_install_system_homebrew() {
    koopa_install_app \
        --name='homebrew' \
        --no-prefix-check \
        --prefix="$(koopa_homebrew_prefix)" \
        --system \
        "$@"
}

koopa_install_system_tex_packages() {
    koopa_install_app \
        --name='tex-packages' \
        --system \
        "$@"
}

koopa_install_system_vscode_server() {
    koopa_install_app \
        --name='vscode-server' \
        --system \
        "$@"
}

koopa_install_taglib() {
    koopa_install_app \
        --name='taglib' \
        "$@"
}

koopa_install_tar() {
    koopa_install_app \
        --name='tar' \
        "$@"
}

koopa_install_tcl_tk() {
    koopa_install_app \
        --name='tcl-tk' \
        "$@"
}

koopa_install_tealdeer() {
    koopa_install_app \
        --name='tealdeer' \
        "$@"
}

koopa_install_termcolor() {
    koopa_install_app \
        --name='termcolor' \
        "$@"
}

koopa_install_texinfo() {
    koopa_install_app \
        --name='texinfo' \
        "$@"
}

koopa_install_tl_expected() {
    koopa_install_app \
        --name='tl-expected' \
        "$@"
}

koopa_install_tmux() {
    koopa_install_app \
        --name='tmux' \
        "$@"
}

koopa_install_tokei() {
    koopa_install_app \
        --name='tokei' \
        "$@"
}

koopa_install_tree_sitter() {
    koopa_install_app \
        --name='tree-sitter' \
        "$@"
}

koopa_install_tree() {
    koopa_install_app \
        --name='tree' \
        "$@"
}

koopa_install_tuc() {
    koopa_install_app \
        --name='tuc' \
        "$@"
}

koopa_install_udunits() {
    koopa_install_app \
        --name='udunits' \
        "$@"
}

koopa_install_unibilium() {
    koopa_install_app \
        --name='unibilium' \
        "$@"
}

koopa_install_units() {
    koopa_install_app \
        --name='units' \
        "$@"
}

koopa_install_unzip() {
    koopa_install_app \
        --name='unzip' \
        "$@"
}

koopa_install_user_doom_emacs() {
    koopa_install_app \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}

koopa_install_user_prelude_emacs() {
    koopa_install_app \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        --user \
        "$@"
}

koopa_install_user_spacemacs() {
    koopa_install_app \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        --user \
        "$@"
}

koopa_install_user_spacevim() {
    koopa_install_app \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --user \
        "$@"
}

koopa_install_utf8proc() {
    koopa_install_app \
        --name='utf8proc' \
        "$@"
}

koopa_install_vim() {
    koopa_install_app \
        --name='vim' \
        "$@"
}

koopa_install_visidata() {
    koopa_install_app \
        --name='visidata' \
        "$@"
}

koopa_install_vulture() {
    koopa_install_app \
        --name='vulture' \
        "$@"
}

koopa_install_wget() {
    koopa_install_app \
        --name='wget' \
        "$@"
}

koopa_install_which() {
    koopa_install_app \
        --name='which' \
        "$@"
}

koopa_install_xorg_libice() {
    koopa_install_app \
        --name='xorg-libice' \
        "$@"
}

koopa_install_xorg_libpthread_stubs() {
    koopa_install_app \
        --name='xorg-libpthread-stubs' \
        "$@"
}

koopa_install_xorg_libsm() {
    koopa_install_app \
        --name='xorg-libsm' \
        "$@"
}

koopa_install_xorg_libx11() {
    koopa_install_app \
        --name='xorg-libx11' \
        "$@"
}

koopa_install_xorg_libxau() {
    koopa_install_app \
        --name='xorg-libxau' \
        "$@"
}

koopa_install_xorg_libxcb() {
    koopa_install_app \
        --name='xorg-libxcb' \
        "$@"
}

koopa_install_xorg_libxdmcp() {
    koopa_install_app \
        --name='xorg-libxdmcp' \
        "$@"
}

koopa_install_xorg_libxext() {
    koopa_install_app \
        --name='xorg-libxext' \
        "$@"
}

koopa_install_xorg_libxrandr() {
    koopa_install_app \
        --name='xorg-libxrandr' \
        "$@"
}

koopa_install_xorg_libxrender() {
    koopa_install_app \
        --name='xorg-libxrender' \
        "$@"
}

koopa_install_xorg_libxt() {
    koopa_install_app \
        --name='xorg-libxt' \
        "$@"
}

koopa_install_xorg_xcb_proto() {
    koopa_install_app \
        --name='xorg-xcb-proto' \
        "$@"
}

koopa_install_xorg_xorgproto() {
    koopa_install_app \
        --name='xorg-xorgproto' \
        "$@"
}

koopa_install_xorg_xtrans() {
    koopa_install_app \
        --name='xorg-xtrans' \
        "$@"
}

koopa_install_xsv() {
    koopa_install_app \
        --name='xsv' \
        "$@"
}

koopa_install_xxhash() {
    koopa_install_app \
        --name='xxhash' \
        "$@"
}

koopa_install_xz() {
    koopa_install_app \
        --name='xz' \
        "$@"
}

koopa_install_yaml_cpp() {
    koopa_install_app \
        --name='yaml-cpp' \
        "$@"
}

koopa_install_yarn() {
    koopa_install_app \
        --name='yarn' \
        "$@"
}

koopa_install_yq() {
    koopa_install_app \
        --name='yq' \
        "$@"
}

koopa_install_yt_dlp() {
    koopa_install_app \
        --name='yt-dlp' \
        "$@"
}

koopa_install_zellij() {
    koopa_install_app \
        --name='zellij' \
        "$@"
}

koopa_install_zip() {
    koopa_install_app \
        --name='zip' \
        "$@"
}

koopa_install_zlib() {
    koopa_install_app \
        --name='zlib' \
        "$@"
}

koopa_install_zoxide() {
    koopa_install_app \
        --name='zoxide' \
        "$@"
}

koopa_install_zsh() {
    koopa_install_app \
        --name='zsh' \
        "$@"
    koopa_fix_zsh_permissions
    koopa_enable_shell_for_all_users "$(koopa_bin_prefix)/zsh"
    return 0
}

koopa_install_zstd() {
    koopa_install_app \
        --name='zstd' \
        "$@"
}

koopa_int_to_yn() {
    local str
    koopa_assert_has_args_eq "$#" 1
    case "${1:?}" in
        '0')
            str='no'
            ;;
        '1')
            str='yes'
            ;;
        *)
            koopa_stop "Invalid choice: requires '0' or '1'."
            ;;
    esac
    koopa_print "$str"
    return 0
}

koopa_invalid_arg() {
    local arg str
    if [[ "$#" -gt 0 ]]
    then
        arg="${1:-}"
        str="Invalid argument: '${arg}'."
    else
        str='Invalid argument.'
    fi
    koopa_stop "$str"
}

koopa_ip_address() {
    local dict
    declare -A dict=(
        ['type']='public'
    )
    while (("$#"))
    do
        case "$1" in
            '--local')
                dict['type']='local'
                shift 1
                ;;
            '--public')
                dict['type']='public'
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    case "${dict['type']}" in
        'local')
            koopa_local_ip_address
            ;;
        'public')
            koopa_public_ip_address
            ;;
    esac
    return 0
}

koopa_is_aarch64() {
    [[ "$(koopa_arch)" = 'aarch64' ]]
}

koopa_is_admin() {
    local app dict
    koopa_assert_has_no_args "$#"
    case "${KOOPA_ADMIN:-}" in
        '0')
            return 1
            ;;
        '1')
            return 0
            ;;
    esac
    koopa_is_root && return 0
    koopa_is_installed 'sudo' || return 1
    koopa_has_passwordless_sudo && return 0
    declare -A app
    app['groups']="$(koopa_locate_groups --allow-system)"
    [[ -x "${app['groups']}" ]] || return 1
    declare -A dict=(
        ['groups']="$("${app['groups']}")"
        ['pattern']='\b(admin|root|sudo|wheel)\b'
    )
    [[ -n "${dict['groups']}" ]] || return 1
    koopa_str_detect_regex \
        --string="${dict['groups']}" \
        --pattern="${dict['pattern']}" \
        && return 0
    return 1
}

koopa_is_alpine() {
    koopa_is_os 'alpine'
}

koopa_is_anaconda() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['conda']="${1:-}"
    )
    [[ -z "${app['conda']}" ]] && app['conda']="$(koopa_locate_conda)"
    [[ -x "${app['conda']}" ]] || return 1
    declare -A dict=(
        ['prefix']="$(koopa_parent_dir --num=2 "${app['conda']}")"
    )
    [[ -x "${dict['prefix']}/bin/anaconda" ]] || return 1
    return 0
}

koopa_is_arch() {
    koopa_is_os 'arch'
}

koopa_is_array_empty() {
    ! koopa_is_array_non_empty "$@"
}

koopa_is_array_non_empty() {
    local arr
    [[ "$#" -gt 0 ]] || return 1
    arr=("$@")
    [[ "${#arr[@]}" -gt 0 ]] || return 1
    [[ -n "${arr[0]}" ]] || return 1
    return 0
}

koopa_is_broken_symlink() {
    local file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        if [[ -L "$file" ]] && [[ ! -e "$file" ]]
        then
            continue
        fi
        return 1
    done
    return 0
}

koopa_is_conda_active() {
    [[ -n "${CONDA_DEFAULT_ENV:-}" ]]
}

koopa_is_conda_env_active() {
    [[ "${CONDA_SHLVL:-1}" -gt 1 ]] && return 0
    [[ "${CONDA_DEFAULT_ENV:-base}" != 'base' ]] && return 0
    return 1
}

koopa_is_debian_like() {
    koopa_is_os_like 'debian'
}

koopa_is_defined_in_user_profile() {
    local file
    koopa_assert_has_no_args "$#"
    file="$(koopa_find_user_profile)"
    [[ -f "$file" ]] || return 1
    koopa_file_detect_fixed --file="$file" --pattern='koopa'
}

koopa_is_docker() {
    [[ "${KOOPA_IS_DOCKER:-0}" -eq 1 ]] && return 0
    [[ -f '/.dockerenv' ]] && return 0
    return 1
}

koopa_is_doom_emacs_installed() {
    local init_file prefix
    koopa_assert_has_no_args "$#"
    koopa_is_installed 'emacs' || return 1
    prefix="$(koopa_emacs_prefix)"
    init_file="${prefix}/init.el"
    [[ -s "$init_file" ]] || return 1
    koopa_file_detect_fixed --file="$init_file" --pattern='doom-emacs'
}

koopa_is_empty_dir() {
    local prefix
    koopa_assert_has_args "$#"
    for prefix in "$@"
    do
        local out
        [[ -d "$prefix" ]] || return 1
        out="$(\
            koopa_find \
            --empty \
            --engine='find' \
            --max-depth=0 \
            --min-depth=0 \
            --prefix="$prefix" \
            --type='d'
        )"
        [[ -n "$out" ]] || return 1
    done
    return 0
}

koopa_is_export() {
    local arg exports
    koopa_assert_has_args "$#"
    exports="$(export -p)"
    for arg in "$@"
    do
        koopa_str_detect_regex \
            --string="$exports" \
            --pattern="\b${arg}\b=" \
        || return 1
    done
    return 0
}

koopa_is_fedora_like() {
    koopa_is_os_like 'fedora'
}

koopa_is_file_system_case_sensitive() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['find']="$(koopa_locate_find)"
        ['wc']="$(koopa_locate_wc)"
    )
    [[ -x "${app['find']}" ]] || return 1
    [[ -x "${app['wc']}" ]] || return 1
    declare -A dict=(
        ['prefix']="${PWD:?}"
        ['tmp_stem']='.koopa.tmp.'
    )
    dict['file1']="${dict['tmp_stem']}checkcase"
    dict['file2']="${dict['tmp_stem']}checkCase"
    koopa_touch "${dict['file1']}" "${dict['file2']}"
    dict['count']="$( \
        "${app['find']}" \
            "${dict['prefix']}" \
            -maxdepth 1 \
            -mindepth 1 \
            -name "${dict['file1']}" \
        | "${app['wc']}" -l \
    )"
    koopa_rm "${dict['tmp_stem']}"*
    [[ "${dict['count']}" -eq 2 ]]
}

koopa_is_file_type() {
    local dict file pos
    declare -A dict=(
        ['ext']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--ext='*)
                dict['ext']="${1#*=}"
                shift 1
                ;;
            '--ext')
                dict['ext']="${2:?}"
                shift 2
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--ext' "${dict['ext']}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        [[ -f "$file" ]] || return 1
        koopa_str_detect_regex \
            --string="$file" \
            --pattern="\.${dict['ext']}$" \
        || return 1
    done
    return 0
}

koopa_is_function() {
    local fun
    koopa_assert_has_args "$#"
    for fun in "$@"
    do
        [[ "$(type -t "$fun")" == 'function' ]] || return 1
    done
    return 0
}

koopa_is_github_ssh_enabled() {
    koopa_assert_has_no_args "$#"
    __koopa_is_ssh_enabled 'git@github.com' 'successfully authenticated'
}

koopa_is_gitlab_ssh_enabled() {
    koopa_assert_has_no_args "$#"
    __koopa_is_ssh_enabled 'git@gitlab.com' 'Welcome to GitLab'
}

koopa_is_gnu() {
    local cmd str
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        koopa_is_installed "$cmd" || return 1
        str="$("$cmd" --version 2>&1 || true)"
        koopa_str_detect_posix "$str" 'GNU' || return 1
    done
    return 0
}

koopa_is_koopa_app() {
    local app_prefix str
    koopa_assert_has_args "$#"
    app_prefix="$(koopa_app_prefix)"
    [[ -d "$app_prefix" ]] || return 1
    for str in "$@"
    do
        if koopa_is_installed "$str"
        then
            str="$(koopa_which_realpath "$str")"
        elif [[ -e "$str" ]]
        then
            str="$(koopa_realpath "$str")"
        else
            return 1
        fi
        koopa_str_detect_regex \
            --string="$str" \
            --pattern="^${app_prefix}" \
            || return 1
    done
    return 0
}

koopa_is_opensuse() {
    koopa_is_os 'opensuse'
}

koopa_is_os_like() {
    local app dict
    declare -A app dict
    dict['id']="${1:?}"
    koopa_is_os "${dict['id']}" && return 0
    dict['file']='/etc/os-release'
    [[ -r "${dict['file']}" ]] || return 1
    app['grep']="$(koopa_locate_grep --allow-system)"
    [[ -x "${app['grep']}" ]] || return 1
    "${app['grep']}" 'ID=' "${dict['file']}" \
        | "${app['grep']}" -q "${dict['id']}" \
        && return 0
    "${app['grep']}" 'ID_LIKE=' "${dict['file']}" \
        | "${app['grep']}" -q "${dict['id']}" \
        && return 0
    return 1
}

koopa_is_os() {
    [[ "$(koopa_os_id)" = "${1:?}" ]]
}

koopa_is_powerful_machine() {
    local cores
    koopa_assert_has_no_args "$#"
    cores="$(koopa_cpu_count)"
    [[ "$cores" -ge 7 ]] && return 0
    return 1
}

koopa_is_python_venv_active() {
    [[ -n "${VIRTUAL_ENV:-}" ]]
}

koopa_is_r_package_installed() {
    local app dict pkg
    koopa_assert_has_args "$#"
    declare -A app
    declare -A dict
    app['r']="$(koopa_locate_r)"
    [[ -x "${app['r']}" ]] || return 1
    dict['prefix']="$(koopa_r_packages_prefix "${app['r']}")"
    for pkg in "$@"
    do
        [[ -d "${dict['prefix']}/${pkg}" ]] || return 1
    done
    return 0
}

koopa_is_recent() {
    local app dict file
    koopa_assert_has_args "$#"
    declare -A app=(
        ['find']="$(koopa_locate_find)"
    )
    [[ -x "${app['find']}" ]] || return 1
    declare -A dict=(
        ['days']=14
    )
    for file in "$@"
    do
        local exists
        [[ -e "$file" ]] || return 1
        exists="$( \
            "${app['find']}" "$file" \
                -mindepth 0 \
                -maxdepth 0 \
                -mtime "-${dict['days']}" \
            2>/dev/null \
        )"
        [[ -n "$exists" ]] || return 1
    done
    return 0
}

koopa_is_rhel_like() {
    koopa_is_os_like 'rhel'
}

koopa_is_rstudio() {
    [[ -n "${RSTUDIO:-}" ]]
}

koopa_is_shared_install() {
    ! koopa_is_user_install
}

koopa_is_spacemacs_installed() {
    local init_file prefix
    koopa_assert_has_no_args "$#"
    koopa_is_installed 'emacs' || return 1
    prefix="$(koopa_emacs_prefix)"
    init_file="${prefix}/init.el"
    [[ -s "$init_file" ]] || return 1
    koopa_file_detect_fixed --file="$init_file" --pattern='Spacemacs'
}

koopa_is_symlink() {
    local file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        if [[ -L "$file" ]] && [[ -e "$file" ]]
        then
            continue
        fi
        return 1
    done
    return 0
}

koopa_is_ubuntu_like() {
    koopa_is_os_like 'ubuntu'
}

koopa_is_url_active() {
    local app url
    koopa_assert_has_args "$#"
    declare -A app
    declare -A dict
    app['curl']="$(koopa_locate_curl --allow-system)"
    [[ -x "${app['curl']}" ]] || return 1
    dict['url_pattern']='://'
    for url in "$@"
    do
        koopa_str_detect_fixed \
            --pattern="${dict['url_pattern']}" \
            --string="$url" \
            || return 1
        "${app['curl']}" \
            --disable \
            --fail \
            --head \
            --location \
            --output /dev/null \
            --silent \
            "$url" \
            || return 1
        continue
    done
    return 0
}

koopa_is_variable_defined() {
    local dict var
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['nounset']="$(koopa_boolean_nounset)"
    )
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    for var
    do
        local x value
        x="$(declare -p "$var" 2>/dev/null || true)"
        [[ -n "${x:-}" ]] || return 1
        value="${!var}"
        [[ -n "${value:-}" ]] || return 1
    done
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_jekyll_deploy_to_aws() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
        ['bundle']="$(koopa_locate_bundle)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['bundle']}" ]] || return 1
    declare -A dict=(
        ['bucket_prefix']=''
        ['distribution_id']=''
        ['local_prefix']='_site'
        ['profile']="${AWS_PROFILE:-}"
    )
    [[ -z "${dict['profile']}" ]] && dict['profile']='default'
    while (("$#"))
    do
        case "$1" in
            '--bucket='*)
                dict['bucket_prefix']="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict['bucket_prefix']="${2:?}"
                shift 2
                ;;
            '--distribution-id='*)
                dict['distribution_id']="${1#*=}"
                shift 1
                ;;
            '--distribution-id')
                dict['distribution_id']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bucket' "${dict['bucket_prefix']:-}" \
        '--distribution-id' "${dict['distribution_id']:-}" \
        '--profile' "${dict['profile']:-}"
    dict['bucket_prefix']="$( \
        koopa_strip_trailing_slash "${dict['bucket_prefix']}" \
    )"
    dict['local_prefix']="$( \
        koopa_strip_trailing_slash "${dict['local_prefix']}" \
    )"
    koopa_assert_is_file 'Gemfile'
    [[ -f 'Gemfile.lock' ]] && koopa_rm 'Gemfile.lock'
    "${app['bundle']}" install
    "${app['bundle']}" exec jekyll build
    koopa_aws_s3_sync --profile="${dict['profile']}" \
        "${dict['local_prefix']}/" \
        "${dict['bucket_prefix']}/"
    koopa_alert "Invalidating CloudFront cache at '${dict['distribution_id']}'."
    "${app['aws']}" --profile="${dict['profile']}" \
        cloudfront create-invalidation \
            --distribution-id="${dict['distribution_id']}" \
            --paths='/*' \
            >/dev/null
    [[ -f 'Gemfile.lock' ]] && koopa_rm 'Gemfile.lock'
    return 0
}

koopa_jekyll_serve() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['bundle']="$(koopa_locate_bundle)"
    )
    [[ -x "${app['bundle']}" ]] || return 1
    declare -A dict=(
        ['prefix']="${1:-}"
    )
    [[ -z "${dict['prefix']}" ]] && dict['prefix']="${PWD:?}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    koopa_alert "Serving Jekyll website in '${dict['prefix']}'."
    (
        koopa_cd "${dict['prefix']}"
        koopa_assert_is_file 'Gemfile'
        if [[ -f 'Gemfile.lock' ]]
        then
            "${app['bundle']}" update --bundler
        fi
        "${app['bundle']}" install
        "${app['bundle']}" exec jekyll serve
    )
    return 0
}

koopa_julia_script_prefix() {
    koopa_print "$(koopa_koopa_prefix)/lang/julia/include"
    return 0
}

koopa_kallisto_fastq_library_type() {
    local from to
    koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'A' | 'IU' | 'U')
            return 0
            ;;
        'ISF')
            to='--fr-stranded'
            ;;
        'ISR')
            to='--rf-stranded'
            ;;
        *)
            koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    koopa_print "$to"
    return 0
}

koopa_kallisto_index() {
    local app dict index_args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['kallisto']="$(koopa_locate_kallisto)"
    )
    [[ -x "${app['kallisto']}" ]] || return 1
    declare -A dict=(
        ['kmer_size']=31
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=14
        ['output_dir']=''
        ['transcriptome_fasta_file']=''
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "kallisto index requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file "${dict['transcriptome_fasta_file']}"
    dict['transcriptome_fasta_file']="$( \
        koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    koopa_assert_is_matching_regex \
        --pattern='\.fa(sta)?' \
        --string="${dict['transcriptome_fasta_file']}"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    dict['index_file']="${dict['output_dir']}/kallisto.idx"
    koopa_alert "Generating kallisto index at '${dict['output_dir']}'."
    index_args+=(
        "--index=${dict['index_file']}"
        "--kmer-size=${dict['kmer_size']}"
        '--make-unique'
        "${dict['transcriptome_fasta_file']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app['kallisto']}" index "${index_args[@]}"
    koopa_alert_success "kallisto index created at '${dict['output_dir']}'."
    return 0
}

koopa_kallisto_quant_paired_end_per_sample() {
    local app dict quant_args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['kallisto']="$(koopa_locate_kallisto)"
    )
    [[ -x "${app['kallisto']}" ]] || return 1
    declare -A dict=(
        ['bootstraps']=30
        ['fastq_r1_file']=''
        ['fastq_r1_tail']=''
        ['fastq_r2_file']=''
        ['fastq_r2_tail']=''
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=14
        ['threads']="$(koopa_cpu_count)"
    )
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--fastq-r2-tail' "${dict['fastq_r2_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "kallisto quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['index_file']="${dict['index_dir']}/kallisto.idx"
    koopa_assert_is_file \
        "${dict['fastq_r1_file']}" \
        "${dict['fastq_r2_file']}" \
        "${dict['index_file']}"
    dict['fastq_r1_file']="$(koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="${dict['fastq_r1_bn']/${dict['fastq_r1_tail']}/}"
    dict['fastq_r2_file']="$(koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="$(koopa_basename "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="${dict['fastq_r2_bn']/${dict['fastq_r2_tail']}/}"
    koopa_assert_are_identical "${dict['fastq_r1_bn']}" "${dict['fastq_r2_bn']}"
    dict['id']="${dict['fastq_r1_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' into '${dict['output_dir']}'."
    quant_args+=(
        "--bootstrap-samples=${dict['bootstraps']}"
        "--index=${dict['index_file']}"
        "--output-dir=${dict['output_dir']}"
        "--threads=${dict['threads']}"
        '--bias'
        '--verbose'
    )
    dict['lib_type']="$( \
        koopa_kallisto_fastq_library_type "${dict['lib_type']}" \
    )"
    if [[ -n "${dict['lib_type']}" ]]
    then
        quant_args+=("${dict['lib_type']}")
    fi
    quant_args+=("${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}")
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['kallisto']}" quant "${quant_args[@]}"
    return 0
}

koopa_kallisto_quant_paired_end() {
    local dict fastq_r1_files fastq_r1_file
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['fastq_dir']=''
        ['fastq_r1_tail']=''
        ['fastq_r2_tail']=''
        ['index_dir']=''
        ['lib_type']='A'
        ['mode']='paired-end'
        ['output_dir']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-tail' "${dict['fastq_r1_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running kallisto quant.'
    koopa_dl \
        'Mode' "${dict['mode']}" \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_r1_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type 'f' \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local fastq_r2_file
        fastq_r2_file="${fastq_r1_file/\
${dict['fastq_r1_tail']}/${dict['fastq_r2_tail']}}"
        koopa_kallisto_quant_paired_end_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict['fastq_r1_tail']}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict['fastq_r2_tail']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict['output_dir']}"
    done
    koopa_alert_success 'kallisto quant was successful.'
    return 0
}

koopa_kallisto_quant_single_end_per_sample() {
    local app dict quant_args
    declare -A app=(
        ['kallisto']="$(koopa_locate_kallisto)"
    )
    [[ -x "${app['kallisto']}" ]] || return 1
    declare -A dict=(
        ['bootstraps']=30
        ['fastq_file']=''
        ['fastq_tail']=''
        ['fragment_length']=200
        ['index_dir']=''
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=14
        ['output_dir']=''
        ['sd']=25
    )
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
                shift 2
                ;;
            '--fragment-length='*)
                dict['fragment_length']="${1#*=}"
                shift 1
                ;;
            '--fragment-length')
                dict['fragment_length']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict['fastq_file']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--fragment-length' "${dict['fragment_length']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "kallisto quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['index_file']="${dict['index_dir']}/kallisto.idx"
    koopa_assert_is_file "${dict['fastq_file']}" "${dict['index_file']}"
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
    dict['fastq_bn']="${dict['fastq_bn']/${dict['fastq_tail']}/}"
    dict['id']="${dict['fastq_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' into '${dict['output_dir']}'."
    quant_args+=(
        "--bootstrap-samples=${dict['bootstraps']}"
        "--fragment-length=${dict['fragment_length']}"
        "--index=${dict['index_file']}"
        "--output-dir=${dict['output_dir']}"
        "--sd=${dict['sd']}"
        '--single'
        "--threads=${dict['threads']}"
        '--verbose'
    )
    quant_args+=("$fastq_file")
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['kallisto']}" quant "${quant_args[@]}"
    return 0
}

koopa_kallisto_quant_single_end() {
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['fastq_dir']=''
        ['fastq_tail']=''
        ['index_dir']=''
        ['mode']='single-end'
        ['output_dir']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq-tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running kallisto quant.'
    koopa_dl \
        'Mode' "${dict['mode']}" \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ tail' "${dict['fastq_tail']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_tail']}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_file in "${fastq_files[@]}"
    do
        koopa_kallisto_quant_single_end_per_sample \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict['fastq_tail']}" \
            --index-dir="${dict['index_dir']}" \
            --output-dir="${dict['output_dir']}"
    done
    koopa_alert_success 'kallisto quant was successful.'
    return 0
}

koopa_kebab_case_simple() {
    local str
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        [[ -n "$str" ]] || return 1
        str="$(\
            koopa_gsub \
                --pattern='[^-A-Za-z0-9]' \
                --regex \
                --replacement='-' \
                "$str" \
        )"
        str="$(koopa_lowercase "$str")"
        koopa_print "$str"
    done
    return 0
}

koopa_kebab_case() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliKebabCase' "$@"
}

koopa_local_ip_address() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['awk']="$(koopa_locate_awk --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
        ['tail']="$(koopa_locate_tail --allow-system)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['tail']}" ]] || return 1
    if koopa_is_macos
    then
        app['ifconfig']="$(koopa_macos_locate_ifconfig)"
        [[ -x "${app['ifconfig']}" ]] || return 1
        str="$( \
            "${app['ifconfig']}" \
            | koopa_grep --pattern='inet ' \
            | koopa_grep --pattern='broadcast' \
            | "${app['awk']}" '{print $2}' \
            | "${app['tail']}" -n 1 \
        )"
    else
        app['hostname']="$(koopa_locate_hostname)"
        [[ -x "${app['hostname']}" ]] || return 1
        str="$( \
            "${app['hostname']}" -I \
            | "${app['awk']}" '{print $1}' \
            | "${app['head']}" -n 1 \
        )"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_koopa_url() {
    koopa_assert_has_no_args "$#"
    koopa_print 'https://koopa.acidgenomics.com'
    return 0
}

koopa_koopa_version() {
    local app dict
    declare -A app
    declare -A dict
    koopa_assert_has_no_args "$#"
    app['cat']="$(koopa_locate_cat --allow-system)"
    [[ -x "${app['cat']}" ]] || return 1
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['version_file']="${dict['koopa_prefix']}/VERSION"
    koopa_assert_is_file "${dict['version_file']}"
    dict['version']="$("${app['cat']}" "${dict['version_file']}")"
    koopa_print "${dict['version']}"
    return 0
}

koopa_line_count() {
    local app file str
    koopa_assert_has_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut)"
        ['wc']="$(koopa_locate_wc)"
        ['xargs']="$(koopa_locate_xargs)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['wc']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    for file in "$@"
    do
        str="$( \
            "${app['wc']}" --lines "$file" \
                | "${app['xargs']}" \
                | "${app['cut']}" -d ' ' -f '1' \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}

koopa_link_dotfile() {
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['dotfiles_config_link']="$(koopa_dotfiles_config_link)"
        ['dotfiles_prefix']="$(koopa_dotfiles_prefix)"
        ['dotfiles_private_prefix']="$(koopa_dotfiles_private_prefix)"
        ['into_xdg_config_home']=0
        ['overwrite']=0
        ['private']=0
        ['xdg_config_home']="$(koopa_xdg_config_home)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--into-xdg-config-home')
                dict['into_xdg_config_home']=1
                shift 1
                ;;
            '--overwrite')
                dict['overwrite']=1
                shift 1
                ;;
            '--private')
                dict['private']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_le "$#" 2
    dict['source_subdir']="${1:?}"
    dict['symlink_basename']="${2:-}"
    if [[ -z "${dict['symlink_basename']}" ]]
    then
        dict['symlink_basename']="$(koopa_basename "${dict['source_subdir']}")"
    fi
    if [[ "${dict['private']}" -eq 1 ]]
    then
        dict['source_prefix']="${dict['dotfiles_private_prefix']}"
    else
        dict['source_prefix']="${dict['dotfiles_config_link']}"
        if [[ ! -L "${dict['source_prefix']}" ]]
        then
            koopa_ln "${dict['dotfiles_prefix']}" "${dict['source_prefix']}"
        fi
    fi
    dict['source_path']="${dict['source_prefix']}/${dict['source_subdir']}"
    koopa_assert_is_existing "${dict['source_path']}"
    if [[ "${dict['into_xdg_config_home']}" -eq 1 ]]
    then
        dict['symlink_prefix']="${dict['xdg_config_home']}"
    else
        dict['symlink_prefix']="${HOME:?}"
        dict['symlink_basename']=".${dict['symlink_basename']}"
    fi
    dict['symlink_path']="${dict['symlink_prefix']}/${dict['symlink_basename']}"
    if [[ "${dict['overwrite']}" -eq 1 ]] ||
        { [[ -L "${dict['symlink_path']}" ]] && \
            [[ ! -e "${dict['symlink_path']}" ]]; }
    then
        koopa_rm "${dict['symlink_path']}"
    fi
    if [[ -e "${dict['symlink_path']}" ]] && \
        [[ ! -L "${dict['symlink_path']}" ]]
    then
        koopa_alert_note "Exists and not symlink: '${dict['symlink_path']}'."
        return 0
    fi
    dict['symlink_dirname']="$(koopa_dirname "${dict['symlink_path']}")"
    if [[ "${dict['symlink_dirname']}" != "${HOME:?}" ]]
    then
        koopa_mkdir "${dict['symlink_dirname']}"
    fi
    koopa_ln "${dict['source_path']}" "${dict['symlink_path']}"
    return 0
}

koopa_link_in_bin() {
    __koopa_link_in_dir --prefix="$(koopa_bin_prefix)" "$@"
}

koopa_link_in_make() {
    local cp_args dict exclude_arr files_arr find_args i include_arr
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['app_prefix']=''
        ['make_prefix']="$(koopa_make_prefix)"
    )
    exclude_arr=('libexec')
    include_arr=()
    while (("$#"))
    do
        case "$1" in
            '--exclude='*)
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                exclude_arr+=("${2:?}")
                shift 2
                ;;
            '--include='*)
                include_arr+=("${1#*=}")
                shift 1
                ;;
            '--include')
                include_arr+=("${2:?}")
                shift 2
                ;;
            '--prefix='*)
                dict['app_prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['app_prefix']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--prefix' "${dict['app_prefix']}"
    koopa_assert_is_dir "${dict['app_prefix']}" "${dict['make_prefix']}"
    dict['app_prefix']="$(koopa_realpath "${dict['app_prefix']}")"
    if koopa_is_array_non_empty "${include_arr[@]:-}"
    then
        for i in "${!include_arr[@]}"
        do
            files_arr[$i]="${dict['app_prefix']}/${include_arr[$i]}"
        done
    else
        find_args=(
            '--max-depth=1'
            '--min-depth=1'
            "--prefix=${dict['app_prefix']}"
            '--sort'
            '--type=d'
        )
        if koopa_is_array_non_empty "${exclude_arr[@]:-}"
        then
            for i in "${!exclude_arr[@]}"
            do
                find_args+=("--exclude=${exclude_arr[$i]}")
            done
        fi
        readarray -t files_arr <<< "$(koopa_find "${find_args[@]}")"
    fi
    if koopa_is_array_empty "${files_arr[@]:-}"
    then
        koopa_stop "No files from '${dict['app_prefix']}' to link \
into '${dict['make_prefix']}'."
    fi
    koopa_assert_is_existing "${files_arr[@]}"
    koopa_sys_set_permissions --recursive "${dict['app_prefix']}"
    koopa_delete_broken_symlinks "${dict['app_prefix']}"
    cp_args=('--symbolic-link')
    koopa_is_shared_install && cp_args+=('--sudo')
    cp_args+=(
        "--target-directory=${dict['make_prefix']}"
        "${files_arr[@]}"
    )
    koopa_cp "${cp_args[@]}"
    return 0
}

koopa_link_in_man1() {
    __koopa_link_in_dir --prefix="$(koopa_man_prefix)/man1" "$@"
}

koopa_link_in_opt() {
    __koopa_link_in_dir --prefix="$(koopa_opt_prefix)" "$@"
}

koopa_list_app_versions() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['prefix']="$(koopa_app_prefix)"
    )
    if [[ ! -d "${dict['prefix']}" ]]
    then
        koopa_alert_note "No apps are installed in '${dict['prefix']}'."
        return 0
    fi
    dict['str']="$( \
        koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='d' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_list_dotfiles() {
    koopa_assert_has_no_args "$#"
    koopa_h1 "Listing dotfiles in '${HOME:?}'."
    koopa_find_dotfiles 'd' 'Directories'
    koopa_find_dotfiles 'f' 'Files'
    koopa_find_dotfiles 'l' 'Symlinks'
}

koopa_list_path_priority() {
    local all_arr app dict unique_arr
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    declare -A dict
    readarray -t all_arr <<< "$( \
        __koopa_list_path_priority "$@" \
    )"
    koopa_is_array_non_empty "${all_arr[@]:-}" || return 1
    readarray -t unique_arr <<< "$( \
        koopa_print "${all_arr[@]}" \
            | "${app['awk']}" '!a[$0]++' \
    )"
    koopa_is_array_non_empty "${unique_arr[@]:-}" || return 1
    dict['n_all']="${#all_arr[@]}"
    dict['n_unique']="${#unique_arr[@]}"
    dict['n_dupes']="$((dict['n_all'] - dict['n_unique']))"
    if [[ "${dict['n_dupes']}" -gt 0 ]]
    then
        koopa_alert_note "$(koopa_ngettext \
            --num="${dict['n_dupes']}" \
            --msg1='duplicate' \
            --msg2='duplicates' \
            --suffix=' detected.' \
        )"
    fi
    koopa_print "${all_arr[@]}"
    return 0
}

koopa_lmod_prefix() {
    koopa_print "$(koopa_opt_prefix)/lmod"
}

koopa_ln() {
    local app dict ln ln_args mkdir pos rm
    declare -A app=(
        ['ln']="$(koopa_locate_ln --allow-system)"
        ['mkdir']='koopa_mkdir'
        ['rm']='koopa_rm'
    )
    [[ -x "${app['ln']}" ]] || return 1
    declare -A dict=(
        ['quiet']=0
        ['sudo']=0
        ['target_dir']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--target-directory='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            '--quiet')
                dict['quiet']=1
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        app['sudo']="$(koopa_locate_sudo)"
        [[ -x "${app['sudo']}" ]] || return 1
        ln=("${app['sudo']}" "${app['ln']}")
        mkdir=("${app['mkdir']}" '--sudo')
        rm=("${app['rm']}" '--sudo')
    else
        ln=("${app['ln']}")
        mkdir=("${app['mkdir']}")
        rm=("${app['rm']}")
    fi
    ln_args=('-fns')
    [[ "${dict['quiet']}" -eq 0 ]] && ln_args+=('-v')
    ln_args+=("$@")
    if [[ -n "${dict['target_dir']}" ]]
    then
        koopa_assert_is_existing "$@"
        dict['target_dir']="$( \
            koopa_strip_trailing_slash "${dict['target_dir']}" \
        )"
        if [[ ! -d "${dict['target_dir']}" ]]
        then
            "${mkdir[@]}" "${dict['target_dir']}"
        fi
        ln_args+=("${dict['target_dir']}")
    else
        koopa_assert_has_args_eq "$#" 2
        dict['source_file']="${1:?}"
        koopa_assert_is_existing "${dict['source_file']}"
        dict['target_file']="${2:?}"
        if [[ -e "${dict['target_file']}" ]]
        then
            "${rm[@]}" "${dict['target_file']}"
        fi
        dict['target_parent']="$(koopa_dirname "${dict['target_file']}")"
        if [[ ! -d "${dict['target_parent']}" ]]
        then
            "${mkdir[@]}" "${dict['target_parent']}"
        fi
    fi
    "${ln[@]}" "${ln_args[@]}"
    return 0
}

koopa_locate_7z() {
    koopa_locate_app \
        --app-name='p7zip' \
        --bin-name='7z' \
        "$@"
}

koopa_locate_anaconda() {
    koopa_locate_app \
        --app-name='anaconda' \
        --bin-name='conda' \
        --no-allow-koopa-bin \
        "$@"
}

koopa_locate_app() {
    local bool dict pos
    declare -A bool=(
        ['allow_koopa_bin']=1
        ['allow_missing']=0
        ['allow_system']=0
        ['realpath']=0
    )
    declare -A dict=(
        ['app']=''
        ['app_name']=''
        ['bin_name']=''
        ['bin_prefix']="$(koopa_bin_prefix)"
        ['opt_prefix']="$(koopa_opt_prefix)"
        ['system_bin_name']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--app-name='*)
                dict['app_name']="${1#*=}"
                shift 1
                ;;
            '--app-name')
                dict['app_name']="${2:?}"
                shift 2
                ;;
            '--bin-name='*)
                dict['bin_name']="${1#*=}"
                shift 1
                ;;
            '--bin-name')
                dict['bin_name']="${2:?}"
                shift 2
                ;;
            '--system-bin-name='*)
                dict['system_bin_name']="${1#*=}"
                shift 1
                ;;
            '--system-bin-name')
                dict['system_bin_name']="${2:?}"
                shift 2
                ;;
            '--allow-missing')
                bool['allow_missing']=1
                shift 1
                ;;
            '--allow-system')
                bool['allow_system']=1
                shift 1
                ;;
            '--no-allow-koopa-bin')
                bool['allow_koopa_bin']=0
                shift 1
                ;;
            '--realpath')
                bool['realpath']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    if [[ "${#pos[@]}" -gt 0 ]]
    then
        set -- "${pos[@]}"
        [[ "$#" -eq 1 ]] || return 1
        dict['app']="${1:?}"
        if [[ -x "${dict['app']}" ]] && \
            koopa_is_installed "${dict['app']}"
        then
            if [[ "${bool['realpath']}" -eq 1 ]]
            then
                dict['app']="$(koopa_realpath "${dict['app']}")"
            fi
            koopa_print "${dict['app']}"
            return 0
        fi
        [[ "${bool['allow_missing']}" -eq 1 ]] && return 0
        koopa_stop "Failed to locate '${dict['app']}'."
    fi
    [[ -n "${dict['app_name']}" ]] || return 1
    [[ -n "${dict['bin_name']}" ]] || return 1
    if [[ "${bool['allow_koopa_bin']}" -eq 1 ]]
    then
        dict['app']="${dict['bin_prefix']}/${dict['bin_name']}"
    fi
    if [[ -x "${dict['app']}" ]]
    then
        if [[ "${bool['realpath']}" -eq 1 ]]
        then
            dict['app']="$(koopa_realpath "${dict['app']}")"
        fi
        koopa_print "${dict['app']}"
        return 0
    fi
    dict['app']="${dict['opt_prefix']}/${dict['app_name']}/\
bin/${dict['bin_name']}"
    if [[ ! -x "${dict['app']}" ]] && \
        [[ "${bool['allow_system']}" -eq 1 ]]
    then
        [[ -z "${dict['system_bin_name']}" ]] && \
            dict['system_bin_name']="${dict['bin_name']}"
        if [[ -x "/usr/bin/${dict['system_bin_name']}" ]]
        then
            dict['app']="/usr/bin/${dict['system_bin_name']}"
        elif [[ -x "/bin/${dict['system_bin_name']}" ]]
        then
            dict['app']="/bin/${dict['system_bin_name']}"
        fi
    fi
    if [[ -x "${dict['app']}" ]]
    then
        if [[ "${bool['realpath']}" -eq 1 ]]
        then
            dict['app']="$(koopa_realpath "${dict['app']}")"
        fi
        koopa_print "${dict['app']}"
        return 0
    fi
    [[ "${bool['allow_missing']}" -eq 1 ]] && return 0
    koopa_stop \
        "Failed to locate '${dict['bin_name']}'." \
        "Run 'koopa install '${dict['app_name']}' to resolve."
}

koopa_locate_ascp() {
    koopa_locate_app \
        --app-name='aspera-connect' \
        --bin-name='ascp' \
        "$@"
}

koopa_locate_aspell() {
    koopa_locate_app \
        --app-name='aspell' \
        --bin-name='aspell' \
        "$@"
}

koopa_locate_autoreconf() {
    koopa_locate_app \
        --app-name='autoconf' \
        --bin-name='autoreconf' \
        "$@"
}

koopa_locate_autoupdate() {
    koopa_locate_app \
        --app-name='autoconf' \
        --bin-name='autoupdate' \
        "$@"
}

koopa_locate_awk() {
    koopa_locate_app \
        --app-name='gawk' \
        --bin-name='awk' \
        "$@"
}

koopa_locate_aws() {
    koopa_locate_app \
        --app-name='aws-cli' \
        --bin-name='aws' \
        "$@"
}

koopa_locate_basename() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gbasename' \
        "$@"
}

koopa_locate_bash() {
    koopa_locate_app \
        --app-name='bash' \
        --bin-name='bash' \
        "$@"
}

koopa_locate_bc() {
    koopa_locate_app \
        --app-name='bc' \
        --bin-name='bc' \
        "$@"
}

koopa_locate_bedtools() {
    koopa_locate_app \
        --app-name='bedtools' \
        --bin-name='bedtools' \
        "$@"
}

koopa_locate_bowtie2_build() {
    koopa_locate_app \
        --app-name='bowtie2' \
        --bin-name='bowtie2-build' \
        "$@"
}

koopa_locate_bowtie2() {
    koopa_locate_app \
        --app-name='bowtie2' \
        --bin-name='bowtie2' \
        "$@"
}

koopa_locate_bpytop() {
    koopa_locate_app \
        --app-name='python-packages' \
        --bin-name='bpytop' \
        "$@"
}

koopa_locate_brew() {
    koopa_locate_app \
        "$(koopa_homebrew_prefix)/Homebrew/bin/brew" \
        "$@"
}

koopa_locate_bundle() {
    koopa_locate_app \
        --app-name='ruby-packages' \
        --bin-name='bundle' \
        "$@"
}

koopa_locate_bunzip2() {
    koopa_locate_app \
        --app-name='bzip2' \
        --bin-name='bunzip2' \
        "$@"
}

koopa_locate_bzip2() {
    koopa_locate_app \
        --app-name='bzip2' \
        --bin-name='bzip2' \
        "$@"
}

koopa_locate_cabal() {
    koopa_locate_app \
        --app-name='haskell-cabal' \
        --bin-name='cabal' \
        "$@"
}

koopa_locate_cargo() {
    koopa_locate_app \
        --app-name='rust' \
        --bin-name='cargo' \
        "$@"
}

koopa_locate_cat() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gcat' \
        --system-bin-name='cat' \
        "$@"
}

koopa_locate_chezmoi() {
    koopa_locate_app \
        --app-name='chezmoi' \
        --bin-name='chezmoi' \
        "$@"
}

koopa_locate_chgrp() {
    koopa_locate_app \
        '/usr/bin/chgrp' \
        "$@"
}

koopa_locate_chmod() {
    koopa_locate_app \
        '/bin/chmod' \
        "$@"
}

koopa_locate_chown() {
    local args
    args=()
    if koopa_is_macos
    then
        args+=('/usr/sbin/chown')
    else
        args+=('/bin/chown')
    fi
    koopa_locate_app "${args[@]}" "$@"
}

koopa_locate_cmake() {
    koopa_locate_app \
        --app-name='cmake' \
        --bin-name='cmake' \
        "$@"
}

koopa_locate_conda() {
    koopa_locate_app \
        --app-name='conda' \
        --bin-name='conda' \
        "$@"
}

koopa_locate_convmv() {
    koopa_locate_app \
        --app-name='convmv' \
        --bin-name='convmv' \
        "$@"
}

koopa_locate_cp() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gcp' \
        --system-bin-name='cp' \
        "$@"
}

koopa_locate_cpan() {
    koopa_locate_app \
        --app-name='perl' \
        --bin-name='cpan' \
        "$@"
}

koopa_locate_ctest() {
    koopa_locate_app \
        --app-name='cmake' \
        --bin-name='ctest' \
        "$@"
}

koopa_locate_curl() {
    koopa_locate_app \
        --app-name='curl' \
        --bin-name='curl' \
        "$@"
}

koopa_locate_cut() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gcut' \
        --system-bin-name='cut' \
        "$@"
}

koopa_locate_date() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdate' \
        --system-bin-name='date' \
        "$@"
}

koopa_locate_df() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdf' \
        --system-bin-name='df' \
        "$@"
}

koopa_locate_dig() {
    koopa_locate_app \
        --app-name='bind' \
        --bin-name='dig' \
        "$@"
}

koopa_locate_dirname() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdirname' \
        "$@"
}

koopa_locate_docker() {
    local args
    args=()
    if koopa_is_macos
    then
        args+=('/usr/local/bin/docker')
    else
        args+=('/usr/bin/docker')
    fi
    koopa_locate_app "${args[@]}" "$@"
}

koopa_locate_doom() {
    koopa_locate_app \
        "$(koopa_doom_emacs_prefix)/bin/doom" \
        "$@"
}

koopa_locate_du() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdu' \
        "$@"
}

koopa_locate_echo() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gecho' \
        "$@"
}

koopa_locate_efetch() {
    koopa_locate_app \
        --app-name='entrez-direct' \
        --bin-name='efetch' \
        "$@"
}

koopa_locate_emacs() {
    koopa_locate_app \
        --app-name='emacs' \
        --bin-name='emacs' \
        "$@"
}

koopa_locate_env() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='genv' \
        --system-bin-name='env' \
        "$@"
}

koopa_locate_esearch() {
    koopa_locate_app \
        --app-name='entrez-direct' \
        --bin-name='esearch' \
        "$@"
}

koopa_locate_exiftool() {
    koopa_locate_app \
        --app-name='exiftool' \
        --bin-name='exiftool' \
        "$@"
}

koopa_locate_fasterq_dump() {
    koopa_locate_app \
        --app-name='sra-tools' \
        --bin-name='fasterq-dump' \
        "$@"
}

koopa_locate_fd() {
    koopa_locate_app \
        --app-name='fd-find' \
        --bin-name='fd' \
        "$@"
}

koopa_locate_ffmpeg() {
    koopa_locate_app \
        --app-name='ffmpeg' \
        --bin-name='ffmpeg' \
        "$@"
}

koopa_locate_find() {
    koopa_locate_app \
        --app-name='findutils' \
        --bin-name='gfind' \
        --system-bin-name='find' \
        "$@"
}

koopa_locate_fish() {
    koopa_locate_app \
        --app-name='fish' \
        --bin-name='fish' \
        "$@"
}

koopa_locate_flake8() {
    koopa_locate_app \
        --app-name='flake8' \
        --bin-name='flake8' \
        "$@"
}

koopa_locate_gcc() {
    koopa_locate_app \
        --app-name='gcc' \
        --bin-name='gcc' \
        "$@"
}

koopa_locate_gcloud() {
    koopa_locate_app \
        --app-name='google-cloud-sdk' \
        --bin-name='gcloud' \
        "$@"
}

koopa_locate_gcxx() {
    koopa_locate_app \
        --app-name='gcc' \
        --bin-name='g++' \
        "$@"
}

koopa_locate_gdal_config() {
    koopa_locate_app \
        --app-name='gdal' \
        --bin-name='gdal-config' \
        "$@"
}

koopa_locate_gem() {
    koopa_locate_app \
        --app-name='ruby' \
        --bin-name='gem' \
        "$@"
}

koopa_locate_geos_config() {
    koopa_locate_app \
        --app-name='geos' \
        --bin-name='geos-config' \
        "$@"
}

koopa_locate_gfortran() {
    koopa_locate_app \
        --app-name='gcc' \
        --bin-name='gfortran' \
        "$@"
}

koopa_locate_ghcup() {
    koopa_locate_app \
        --app-name='haskell-ghcup' \
        --bin-name='ghcup' \
        "$@"
}

koopa_locate_git() {
    koopa_locate_app \
        --app-name='git' \
        --bin-name='git' \
        "$@"
}

koopa_locate_go() {
    koopa_locate_app \
        --app-name='go' \
        --bin-name='go' \
        "$@"
}

koopa_locate_gpg_agent() {
    koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpg-agent' \
        "$@"
}

koopa_locate_gpg_connect_agent() {
    koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpg-connect-agent' \
        "$@"
}

koopa_locate_gpg() {
    koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpg' \
        "$@"
}

koopa_locate_gpgconf() {
    koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpgconf' \
        "$@"
}

koopa_locate_grep() {
    koopa_locate_app \
        --app-name='grep' \
        --bin-name='ggrep' \
        --system-bin-name='grep' \
        "$@"
}

koopa_locate_groups() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='ggroups' \
        --system-bin-name='groups' \
        "$@"
}

koopa_locate_gs() {
    koopa_locate_app \
        --app-name='ghostscript' \
        --bin-name='gs' \
        "$@"
}

koopa_locate_gsl_config() {
    koopa_locate_app \
        --app-name='gsl' \
        --bin-name='gsl-config' \
        "$@"
}

koopa_locate_gzip() {
    koopa_locate_app \
        --app-name='gzip' \
        --bin-name='gzip' \
        "$@"
}

koopa_locate_h5cc() {
    koopa_locate_app \
        --app-name='hdf5' \
        --bin-name='h5cc' \
        "$@"
}

koopa_locate_head() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='ghead' \
        --system-bin-name='head' \
        "$@"
}

koopa_locate_hostname() {
    koopa_locate_app \
        '/bin/hostname' \
        "$@"
}

koopa_locate_icu_config() {
    koopa_locate_app \
        --app-name='icu4c' \
        --bin-name='icu-config' \
        "$@"
}

koopa_locate_id() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gid' \
        "$@"
}

koopa_locate_jar() {
    koopa_locate_app \
        --app-name='openjdk' \
        --bin-name='jar' \
        "$@"
}

koopa_locate_java() {
    koopa_locate_app \
        --app-name='openjdk' \
        --bin-name='java' \
        "$@"
}

koopa_locate_javac() {
    koopa_locate_app \
        --app-name='openjdk' \
        --bin-name='javac' \
        "$@"
}

koopa_locate_jq() {
    koopa_locate_app \
        --app-name='jq' \
        --bin-name='jq' \
        "$@"
}

koopa_locate_julia() {
    koopa_locate_app \
        --app-name='julia' \
        --bin-name='julia' \
        "$@"
}

koopa_locate_kallisto() {
    koopa_locate_app \
        --app-name='kallisto' \
        --bin-name='kallisto' \
        "$@"
}

koopa_locate_koopa() {
    koopa_locate_app \
        "$(koopa_koopa_prefix)/bin/koopa" \
        "$@"
}

koopa_locate_less() {
    koopa_locate_app \
        --app-name='less' \
        --bin-name='less' \
        "$@"
}

koopa_locate_lesspipe() {
    koopa_locate_app \
        --app-name='lesspipe' \
        --bin-name='lesspipe.sh' \
        "$@"
}

koopa_locate_libtoolize() {
    koopa_locate_app \
        --app-name='libtool' \
        --bin-name='glibtoolize' \
        "$@"
}

koopa_locate_ln() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gln' \
        --system-bin-name='ln' \
        "$@"
}

koopa_locate_locale() {
    koopa_locate_app \
        '/usr/bin/locale' \
        "$@"
}

koopa_locate_localedef() {
    if koopa_is_alpine
    then
        koopa_alpine_locate_localedef "$@"
    else
        koopa_locate_app \
            '/usr/bin/localedef' \
            "$@"
    fi
}

koopa_locate_lpr() {
    koopa_locate_app \
        '/usr/bin/lpr' \
        "$@"
}

koopa_locate_ls() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gls' \
        "$@"
}

koopa_locate_lua() {
    koopa_locate_app \
        --app-name='lua' \
        --bin-name='lua' \
        "$@"
}

koopa_locate_luac() {
    koopa_locate_app \
        --app-name='lua' \
        --bin-name='luac' \
        "$@"
}

koopa_locate_luajit() {
    koopa_locate_app \
        --app-name='luajit' \
        --bin-name='luajit' \
        "$@"
}

koopa_locate_luarocks() {
    koopa_locate_app \
        --app-name='luarocks' \
        --bin-name='luarocks' \
        "$@"
}

koopa_locate_magick_core_config() {
    koopa_locate_app \
        --app-name='imagemagick' \
        --bin-name='MagickCore-config' \
        "$@"
}

koopa_locate_make() {
    koopa_locate_app \
        --app-name='make' \
        --bin-name='gmake' \
        --system-bin-name='make' \
        "$@"
}

koopa_locate_mamba() {
    koopa_locate_app \
        --app-name='conda' \
        --bin-name='mamba' \
        "$@"
}

koopa_locate_man() {
    koopa_locate_app \
        --app-name='man-db' \
        --bin-name='gman' \
        --system-bin-name='man' \
        "$@"
}

koopa_locate_md5sum() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmd5sum' \
        "$@"
}

koopa_locate_meson() {
    koopa_locate_app \
        --app-name='meson' \
        --bin-name='meson' \
        "$@"
}

koopa_locate_mkdir() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmkdir' \
        --system-bin-name='mkdir' \
        "$@"
}

koopa_locate_mktemp() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmktemp' \
        --system-bin-name='mktemp' \
        "$@"
}

koopa_locate_mv() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmv' \
        --system-bin-name='mv' \
        "$@"
}

koopa_locate_neofetch() {
    koopa_locate_app \
        --app-name='neofetch' \
        --bin-name='neofetch' \
        "$@"
}

koopa_locate_newgrp() {
    koopa_locate_app \
        '/usr/bin/newgrp' \
        "$@"
}

koopa_locate_nim() {
    koopa_locate_app \
        --app-name='nim' \
        --bin-name='nim' \
        "$@"
}

koopa_locate_nimble() {
    koopa_locate_app \
        --app-name='nim' \
        --bin-name='nimble' \
        "$@"
}

koopa_locate_ninja() {
    koopa_locate_app \
        --app-name='ninja' \
        --bin-name='ninja' \
        "$@"
}

koopa_locate_node() {
    koopa_locate_app \
        --app-name='node' \
        --bin-name='node' \
        "$@"
}

koopa_locate_npm() {
    koopa_locate_app \
        --app-name='node' \
        --bin-name='npm' \
        "$@"
}

koopa_locate_nproc() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gnproc' \
        "$@"
}

koopa_locate_numfmt() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gnumfmt' \
        "$@"
}

koopa_locate_od() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='god' \
        "$@"
}

koopa_locate_open() {
    koopa_locate_app \
        '/usr/bin/open' \
        "$@"
}

koopa_locate_openssl() {
    koopa_locate_app \
        --app-name='openssl3' \
        --bin-name='openssl' \
        "$@"
}

koopa_locate_parallel() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gparallel' \
        "$@"
}

koopa_locate_passwd() {
    koopa_locate_app \
        '/usr/bin/passwd' \
        "$@"
}

koopa_locate_paste() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gpaste' \
        "$@"
}

koopa_locate_patch() {
    koopa_locate_app \
        --app-name='patch' \
        --bin-name='patch' \
        "$@"
}

koopa_locate_pcre2_config() {
    koopa_locate_app \
        --app-name='pcre2' \
        --bin-name='pcre2-config' \
        "$@"
}

koopa_locate_pcregrep() {
    koopa_locate_app \
        --app-name='pcre2' \
        --bin-name='pcre2grep' \
        "$@"
}

koopa_locate_perl() {
    koopa_locate_app \
        --app-name='perl' \
        --bin-name='perl' \
        "$@"
}

koopa_locate_pkg_config() {
    koopa_locate_app \
        --app-name='pkg-config' \
        --bin-name='pkg-config' \
        "$@"
}

koopa_locate_prefetch() {
    koopa_locate_app \
        --app-name='sratoolkit' \
        --bin-name='prefetch' \
        "$@"
}

koopa_locate_proj() {
    koopa_locate_app \
        --app-name='proj' \
        --bin-name='proj' \
        "$@"
}

koopa_locate_pyenv() {
    koopa_locate_app \
        --app-name='pyenv' \
        --bin-name='pyenv' \
        "$@"
}

koopa_locate_pylint() {
    koopa_locate_app \
        --app-name='pylint' \
        --bin-name='pylint' \
        "$@"
}

koopa_locate_python() {
    koopa_locate_app \
        --app-name='python' \
        --bin-name='python3' \
        "$@"
}

koopa_locate_python310() {
    koopa_locate_app \
        --app-name='python3.10' \
        --bin-name='python3.10' \
        "$@"
}

koopa_locate_python311() {
    koopa_locate_app \
        --app-name='python3.11' \
        --bin-name='python3.11' \
        "$@"
}

koopa_locate_r() {
    koopa_locate_app \
        --app-name='r' \
        --bin-name='R' \
        "$@"
}

koopa_locate_rbenv() {
    koopa_locate_app \
        --app-name='rbenv' \
        --bin-name='rbenv' \
        "$@"
}

koopa_locate_readlink() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='greadlink' \
        "$@"
}

koopa_locate_realpath() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='grealpath' \
        "$@"
}

koopa_locate_rename() {
    koopa_locate_app \
        --app-name='rename' \
        --bin-name='rename' \
        "$@"
}

koopa_locate_rg() {
    koopa_locate_app \
        --app-name='ripgrep' \
        --bin-name='rg' \
        "$@"
}

koopa_locate_rm() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='grm' \
        --system-bin-name='rm' \
        "$@"
}

koopa_locate_ronn() {
    koopa_locate_app \
        --app-name='ronn' \
        --bin-name='ronn' \
        "$@"
}

koopa_locate_rscript() {
    koopa_locate_app \
        --app-name='r' \
        --bin-name='Rscript' \
        "$@"
}

koopa_locate_rsem_prepare_reference() {
    koopa_locate_app \
        --app-name='rsem' \
        --bin-name='rsem-prepare-reference' \
        "$@"
}

koopa_locate_rsync() {
    koopa_locate_app \
        --app-name='rsync' \
        --bin-name='rsync' \
        "$@"
}

koopa_locate_ruby() {
    koopa_locate_app \
        --app-name='ruby' \
        --bin-name='ruby' \
        "$@"
}

koopa_locate_rustc() {
    koopa_locate_app \
        --app-name='rust' \
        --bin-name='rustc' \
        "$@"
}

koopa_locate_salmon() {
    koopa_locate_app \
        --app-name='salmon' \
        --bin-name='salmon' \
        "$@"
}

koopa_locate_sambamba() {
    koopa_locate_app \
        --app-name='sambamba' \
        --bin-name='sambamba' \
        "$@"
}

koopa_locate_samtools() {
    koopa_locate_app \
        --app-name='samtools' \
        --bin-name='samtools' \
        "$@"
}

koopa_locate_scons() {
    koopa_locate_app \
        --app-name='scons' \
        --bin-name='scons' \
        "$@"
}

koopa_locate_scp() {
    koopa_locate_app \
        --app-name='openssh' \
        --bin-name='scp' \
        "$@"
}

koopa_locate_sed() {
    koopa_locate_app \
        --app-name='sed' \
        --bin-name='gsed' \
        --system-bin-name='sed' \
        "$@"
}

koopa_locate_sh() {
    koopa_locate_app \
        '/bin/sh' \
        "$@"
}

koopa_locate_shellcheck() {
    koopa_locate_app \
        --app-name='shellcheck' \
        --bin-name='shellcheck' \
        "$@"
}

koopa_locate_shunit2() {
    koopa_locate_app \
        --app-name='shunit2' \
        --bin-name='shunit2' \
        "$@"
}

koopa_locate_sort() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gsort' \
        --system-bin-name='sort' \
        "$@"
}

koopa_locate_sox() {
    koopa_locate_app \
        --app-name='sox' \
        --bin-name='sox' \
        "$@"
}

koopa_locate_ssh_add() {
    local args
    args=()
    if koopa_is_macos
    then
        args+=('/usr/bin/ssh-add')
    else
        args+=(
            '--app-name=openssh'
            '--bin-name=ssh-add'
        )
    fi
    koopa_locate_app "${args[@]}" "$@"
}

koopa_locate_ssh_keygen() {
    koopa_locate_app \
        --app-name='openssh' \
        --bin-name='ssh-keygen' \
        "$@"
}

koopa_locate_ssh() {
    koopa_locate_app \
        --app-name='openssh' \
        --bin-name='ssh' \
        "$@"
}

koopa_locate_stack() {
    koopa_locate_app \
        --app-name='haskell-stack' \
        --bin-name='stack' \
        "$@"
}

koopa_locate_star() {
    koopa_locate_app \
        --app-name='star' \
        --bin-name='STAR' \
        "$@"
}

koopa_locate_stat() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gstat' \
        --system-bin-name='stat' \
        "$@"
}

koopa_locate_sudo() {
    koopa_locate_app \
        '/usr/bin/sudo' \
        "$@"
}

koopa_locate_svn() {
    koopa_locate_app \
        --app-name='subversion' \
        --bin-name='svn' \
        "$@"
}

koopa_locate_swig() {
    koopa_locate_app \
        --app-name='swig' \
        --bin-name='swig' \
        "$@"
}

koopa_locate_system_r() {
    local cmd
    if koopa_is_macos
    then
        cmd='/Library/Frameworks/R.framework/Resources/bin/R'
    else
        cmd='/usr/bin/R'
    fi
    koopa_locate_app "$cmd"
}

koopa_locate_tac() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtac' \
        "$@"
}

koopa_locate_tail() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtail' \
        --system-bin-name='tail' \
        "$@"
}

koopa_locate_tar() {
    koopa_locate_app \
        --app-name='tar' \
        --bin-name='gtar' \
        --system-bin-name='tar' \
        "$@"
}

koopa_locate_tee() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtee' \
        --system-bin-name='tee' \
        "$@"
}

koopa_locate_tex() {
    local args
    args=()
    if koopa_is_macos
    then
        args+=('/Library/TeX/texbin/tex')
    else
        args+=('/usr/bin/tex')
    fi
    koopa_locate_app "${args[@]}" "$@"
}

koopa_locate_texi2dvi() {
    koopa_locate_app \
        --app-name='texinfo' \
        --bin-name='texi2dvi' \
        "$@"
}

koopa_locate_tlmgr() {
    local args
    args=()
    if koopa_is_macos
    then
        args+=('/Library/TeX/texbin/tlmgr')
    else
        args+=('/usr/bin/tlmgr')
    fi
    koopa_locate_app "${args[@]}" "$@"
}

koopa_locate_touch() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtouch' \
        --system-bin-name='touch' \
        "$@"
}

koopa_locate_tr() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtr' \
        --system-bin-name='tr' \
        "$@"
}

koopa_locate_uname() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='guname' \
        --system-bin-name='uname' \
        "$@"
}

koopa_locate_uncompress() {
    koopa_locate_app \
        --app-name='gzip' \
        --bin-name='uncompress' \
        "$@"
}

koopa_locate_uniq() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='guniq' \
        "$@"
}

koopa_locate_unzip() {
    koopa_locate_app \
        --app-name='unzip' \
        --bin-name='unzip' \
        --system-bin-name='unzip' \
        "$@"
}

koopa_locate_vim() {
    koopa_locate_app \
        --app-name='vim' \
        --bin-name='vim' \
        "$@"
}

koopa_locate_wc() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gwc' \
        "$@"
}

koopa_locate_wget() {
    koopa_locate_app \
        --app-name='wget' \
        --bin-name='wget' \
        "$@"
}

koopa_locate_whoami() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gwhoami' \
        "$@"
}

koopa_locate_xargs() {
    koopa_locate_app \
        --app-name='findutils' \
        --bin-name='gxargs' \
        --system-bin-name='xargs' \
        "$@"
}

koopa_locate_xz() {
    koopa_locate_app \
        --app-name='xz' \
        --bin-name='xz' \
        "$@"
}

koopa_locate_yacc() {
    koopa_locate_app \
        --app-name='bison' \
        --bin-name='yacc' \
        "$@"
}

koopa_locate_yes() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gyes' \
        "$@"
}

koopa_locate_yq() {
    koopa_locate_app \
        --app-name='yq' \
        --bin-name='yq' \
        "$@"
}

koopa_locate_yt_dlp() {
    koopa_locate_app \
        --app-name='yt-dlp' \
        --bin-name='yt-dlp' \
        "$@"
}

koopa_locate_zcat() {
    koopa_locate_app \
        --app-name='gzip' \
        --bin-name='zcat' \
        "$@"
}

koopa_locate_zip() {
    koopa_locate_app \
        --app-name='zip' \
        --bin-name='zip' \
        --system-bin-name='zip' \
        "$@"
}

koopa_log_file() {
    local dict
    declare -A dict
    koopa_assert_has_no_args "$#"
    dict['datetime']="$(koopa_datetime)"
    dict['hostname']="$(koopa_hostname)"
    dict['log_file']="${HOME:?}/logs/${dict['hostname']}/\
${dict['datetime']}.log"
    koopa_touch "${dict['log_file']}"
    koopa_print "${dict['log_file']}"
    return 0
}

koopa_lowercase() {
    local app str
    declare -A app
    app['tr']="$(koopa_locate_tr --allow-system)"
    [[ -x "${app['tr']}" ]] || return 1
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        [[ -n "$str" ]] || return 1
        koopa_print "$str" \
            | "${app['tr']}" '[:upper:]' '[:lower:]'
    done
    return 0
}

koopa_make_build_string() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['arch']="$(koopa_arch)"
    )
    if koopa_is_linux
    then
        dict['os_type']='linux-gnu'
    else
        dict['os_type']="$(koopa_os_type)"
    fi
    koopa_print "${dict['arch']}-${dict['os_type']}"
    return 0
}

koopa_man_prefix() {
    koopa_print "$(koopa_koopa_prefix)/share/man"
    return 0
}

koopa_man1_prefix() {
    koopa_print "$(koopa_man_prefix)/man1"
    return 0
}

koopa_md5sum_check_parallel() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['md5sum']="$(koopa_locate_md5sum)"
        ['sh']="$(koopa_locate_sh)"
        ['xargs']="$(koopa_locate_xargs)"
    )
    [[ -x "${app['md5sum']}" ]] || return 1
    [[ -x "${app['sh']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
    )
    koopa_find \
        --max-depth=1 \
        --min-depth=1 \
        --pattern='*.md5' \
        --prefix='.' \
        --print0 \
        --sort \
        --type='f' \
    | "${app['xargs']}" \
        -0 \
        -I {} \
        -P "${dict['jobs']}" \
            "${app['sh']}" -c "${app['md5sum']} -c {}"
    return 0
}

koopa_md5sum_check_to_new_md5_file() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['md5sum']="$(koopa_locate_md5sum)"
        ['tee']="$(koopa_locate_tee)"
    )
    [[ -x "${app['md5sum']}" ]] || return 1
    [[ -x "${app['tee']}" ]] || return 1
    declare -A dict=(
        ['datetime']="$(koopa_datetime)"
    )
    dict['log_file']="md5sum-${dict['datetime']}.md5"
    koopa_assert_is_not_file "${dict['log_file']}"
    koopa_assert_is_file "$@"
    "${app['md5sum']}" "$@" 2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}

koopa_mem_gb() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['awk']='awk'
    )
    declare -A dict
    if koopa_is_macos
    then
        app['sysctl']="$(koopa_macos_locate_sysctl)"
        dict['mem']="$("${app['sysctl']}" -n 'hw.memsize')"
        dict['denom']=1073741824  # 1024^3; bytes
    elif koopa_is_linux
    then
        dict['meminfo']='/proc/meminfo'
        koopa_assert_is_file "${dict['meminfo']}"
        dict['mem']="$( \
            "${app['awk']}" '/MemTotal/ {print $2}' "${dict['meminfo']}" \
        )"
        dict['denom']=1048576  # 1024^2; KB
    else
        koopa_stop 'Unsupported system.'
    fi
    dict['str']="$( \
        "${app['awk']}" \
            -v denom="${dict['denom']}" \
            -v mem="${dict['mem']}" \
            'BEGIN{ printf "%.0f\n", mem / denom }' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_merge_pdf() {
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        ['gs']="$(koopa_locate_gs)"
    )
    [[ -x "${app['gs']}" ]] || return 1
    koopa_assert_is_file "$@"
    "${app['gs']}" \
        -dBATCH \
        -dNOPAUSE \
        -q \
        -sDEVICE='pdfwrite' \
        -sOutputFile='merge.pdf' \
        "$@"
    return 0
}

koopa_missing_arg() {
    koopa_stop 'Missing required argument.'
}

koopa_mkdir() {
    local app dict mkdir mkdir_args pos
    declare -A app
    app['mkdir']="$(koopa_locate_mkdir --allow-system)"
    [[ -x "${app['mkdir']}" ]] || return 1
    declare -A dict
    dict['sudo']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    mkdir_args=('-p')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        app['sudo']="$(koopa_locate_sudo)"
        [[ -x "${app['sudo']}" ]] || return 1
        mkdir=("${app['sudo']}" "${app['mkdir']}")
    else
        mkdir=("${app['mkdir']}")
    fi
    "${mkdir[@]}" "${mkdir_args[@]}" "$@"
    return 0
}

koopa_mktemp() {
    local app dict mktemp_args str
    declare -A app
    app['mktemp']="$(koopa_locate_mktemp --allow-system)"
    [[ -x "${app['mktemp']}" ]] || return 1
    declare -A dict=(
        ['date_id']="$(koopa_datetime)"
        ['user_id']="$(koopa_user_id)"
    )
    dict['template']="koopa-${dict['user_id']}-${dict['date_id']}-XXXXXXXXXX"
    mktemp_args=(
        "$@"
        '-t' "${dict['template']}"
    )
    str="$("${app['mktemp']}" "${mktemp_args[@]}")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_move_files_in_batch() {
    local app dict files
    koopa_assert_has_args_eq "$#" 3
    declare -A app=(
        ['head']="$(koopa_locate_head --allow-system)"
    )
    [[ -x "${app['head']}" ]] || return 1
    declare -A dict=(
        ['num']=''
        ['source_dir']=''
        ['target_dir']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--num='*)
                dict['num']="${1#*=}"
                shift 1
                ;;
            '--num')
                dict['num']="${2:?}"
                shift 2
                ;;
            '--source-dir='*)
                dict['source_dir']="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict['source_dir']="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--num' "${dict['num']}" \
        '--source-dir' "${dict['source_dir']}" \
        '--target-dir' "${dict['target_dir']}"
    koopa_assert_is_dir "${dict['target_dir']}"
    dict['target_dir']="$(koopa_init_dir "${dict['target_dir']}")"
    readarray -t files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['source_dir']}" \
            --sort \
            --type='f' \
        | "${app['head']}" -n "${dict['num']}" \
    )"
    koopa_is_array_non_empty "${files[@]:-}" || return 1
    koopa_mv --target-directory="${dict['target_dir']}" "${files[@]}"
    return 0
}

koopa_move_files_up_1_level() {
    local dict files
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        ['prefix']="${1:-}"
    )
    [[ -z "${dict['prefix']}" ]] && dict['prefix']="${PWD:?}"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    readarray -t files <<< "$( \
        koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict['prefix']}" \
            --type='f' \
    )"
    koopa_is_array_non_empty "${files[@]:-}" || return 1
    koopa_mv --target-directory="${dict['prefix']}" "${files[@]}"
    return 0
}

koopa_move_into_dated_dirs_by_filename() {
    local file grep_array grep_string
    koopa_assert_has_args "$#"
    grep_array=(
        '^([0-9]{4})'
        '([-_])?'
        '([0-9]{2})'
        '([-_])?'
        '([0-9]{2})'
        '([-_])?'
        '(.+)$'
    )
    grep_string="$(koopa_paste0 "${grep_array[@]}")"
    for file in "$@"
    do
        local dict
        declare -A dict=(
            ['file']="$file"
        )
        if [[ "${dict['file']}" =~ $grep_string ]]
        then
            dict['year']="${BASH_REMATCH[1]}"
            dict['month']="${BASH_REMATCH[3]}"
            dict['day']="${BASH_REMATCH[5]}"
            dict['subdir']="${dict['year']}/${dict['month']}/${dict['day']}"
            koopa_mv --target-directory="${dict['subdir']}" "${dict['file']}"
        else
            koopa_stop "Does not contain date: '${dict['file']}'."
        fi
    done
    return 0
}

koopa_move_into_dated_dirs_by_timestamp() {
    local file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        local subdir
        subdir="$(koopa_stat_modified '%Y/%m/%d' "$file")"
        koopa_mv --target-directory="$subdir" "$file"
    done
    return 0
}

koopa_mv() {
    local app dict mkdir mv mv_args pos rm
    declare -A app=(
        ['mv']="$(koopa_locate_mv --allow-system)"
        ['mkdir']='koopa_mkdir'
        ['rm']='koopa_rm'
    )
    koopa_is_macos && app['mv']='/bin/mv'
    [[ -x "${app['mv']}" ]] || return 1
    declare -A dict=(
        ['sudo']=0
        ['target_dir']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--target-directory='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        app['sudo']="$(koopa_locate_sudo)"
        mkdir=("${app['mkdir']}" '--sudo')
        mv=("${app['sudo']}" "${app['mv']}")
        rm=("${app['rm']}" '--sudo')
    else
        mkdir=("${app['mkdir']}")
        mv=("${app['mv']}")
        rm=("${app['rm']}")
    fi
    mv_args=('-fv')
    mv_args+=("$@")
    if [[ -n "${dict['target_dir']}" ]]
    then
        koopa_assert_is_existing "$@"
        dict['target_dir']="$( \
            koopa_strip_trailing_slash "${dict['target_dir']}" \
        )"
        if [[ ! -d "${dict['target_dir']}" ]]
        then
            "${mkdir[@]}" "${dict['target_dir']}"
        fi
        mv_args+=("${dict['target_dir']}")
    else
        koopa_assert_has_args_eq "$#" 2
        dict['source_file']="$(koopa_strip_trailing_slash "${1:?}")"
        koopa_assert_is_existing "${dict['source_file']}"
        dict['target_file']="$(koopa_strip_trailing_slash "${2:?}")"
        if [[ -e "${dict['target_file']}" ]]
        then
            "${rm[@]}" "${dict['target_file']}"
        fi
        dict['target_parent']="$(koopa_dirname "${dict['target_file']}")"
        if [[ ! -d "${dict['target_parent']}" ]]
        then
            "${mkdir[@]}" "${dict['target_parent']}"
        fi
    fi
    "${mv[@]}" "${mv_args[@]}"
    return 0
}

koopa_nfiletypes() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['sed']="$(koopa_locate_sed)"
        ['sort']="$(koopa_locate_sort)"
        ['uniq']="$(koopa_locate_uniq)"
    )
    [[ -x "${app['sed']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['uniq']}" ]] || return 1
    declare -A dict=(
        ['prefix']="${1:?}"
    )
    koopa_assert_is_dir "${dict['prefix']}"
    dict['out']="$( \
        koopa_find \
            --exclude='.*' \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.*' \
            --prefix="${dict['prefix']}" \
            --type='f' \
        | "${app['sed']}" 's/.*\.//' \
        | "${app['sort']}" \
        | "${app['uniq']}" --count \
        | "${app['sort']}" --numeric-sort \
        | "${app['sed']}" 's/^ *//g' \
        | "${app['sed']}" 's/ /\t/g' \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}

koopa_ngettext() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['middle']=' '
        ['msg1']=''
        ['msg2']=''
        ['num']=''
        ['prefix']=''
        ['str']=''
        ['suffix']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--middle='*)
                dict['middle']="${1#*=}"
                shift 1
                ;;
            '--middle')
                dict['middle']="${2:?}"
                shift 2
                ;;
            '--msg1='*)
                dict['msg1']="${1#*=}"
                shift 1
                ;;
            '--msg1')
                dict['msg1']="${2:?}"
                shift 2
                ;;
            '--msg2='*)
                dict['msg2']="${1#*=}"
                shift 1
                ;;
            '--msg2')
                dict['msg2']="${2:?}"
                shift 2
                ;;
            '--num='*)
                dict['num']="${1#*=}"
                shift 1
                ;;
            '--num')
                dict['num']="${2:?}"
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
            '--suffix='*)
                dict['suffix']="${1#*=}"
                shift 1
                ;;
            '--suffix')
                dict['suffix']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--middle' "${dict['middle']}"  \
        '--msg1' "${dict['msg1']}"  \
        '--msg2' "${dict['msg2']}"  \
        '--num' "${dict['num']}"
    case "${dict['num']}" in
        '1')
            dict['msg']="${dict['msg1']}"
            ;;
        *)
            dict['msg']="${dict['msg2']}"
            ;;
    esac
    dict['str']="${dict['prefix']}${dict['num']}${dict['middle']}\
${dict['msg']}${dict['suffix']}"
    koopa_print "${dict['str']}"
    return 0
}

koopa_os_id() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app dict
    app['cut']="$(koopa_locate_cut --allow-system)"
    [[ -x "${app['cut']}" ]] || return 1
    dict['string']="$( \
        koopa_os_string \
        | "${app['cut']}" -d '-' -f '1' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}

koopa_os_string() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app dict
    if koopa_is_macos
    then
        dict['id']='macos'
        dict['version']="$(koopa_macos_os_version)"
        dict['version']="$(koopa_major_version "${dict['version']}")"
    elif koopa_is_linux
    then
        app['awk']="$(koopa_locate_awk --allow-system)"
        app['tr']="$(koopa_locate_tr --allow-system)"
        [[ -x "${app['awk']}" ]] || return 1
        [[ -x "${app['tr']}" ]] || return 1
        dict['release_file']='/etc/os-release'
        if [[ -r "${dict['release_file']}" ]]
        then
            dict['id']="$( \
                "${app['awk']}" -F= \
                    "\$1==\"ID\" { print \$2 ;}" \
                    "${dict['release_file']}" \
                | "${app['tr']}" -d '"' \
            )"
            dict['version']="$( \
                "${app['awk']}" -F= \
                    "\$1==\"VERSION_ID\" { print \$2 ;}" \
                    "${dict['release_file']}" \
                | "${app['tr']}" -d '"' \
            )"
            if [[ -n "${dict['version']}" ]]
            then
                dict['version']="$(koopa_major_version "${dict['version']}")"
            else
                dict['version']='rolling'
            fi
        else
            dict['id']='linux'
        fi
    fi
    [[ -n "${dict['id']}" ]] || return 1
    dict['string']="${dict['id']}"
    if [[ -n "${dict['version']:-}" ]]
    then
        dict['string']="${dict['string']}-${dict['version']}"
    fi
    koopa_print "${dict['string']}"
    return 0
}

koopa_os_type() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['tr']="$(koopa_locate_tr --allow-system)"
        ['uname']="$(koopa_locate_uname --allow-system)"
    )
    [[ -x "${app['tr']}" ]] || return 1
    [[ -x "${app['uname']}" ]] || return 1
    str="$( \
        "${app['uname']}" -s \
        | "${app['tr']}" '[:upper:]' '[:lower:]' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_pager() {
    local app args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['less']="$(koopa_locate_less)"
    )
    [[ -x "${app['less']}" ]] || return 1
    args=("$@")
    koopa_assert_is_file "${args[-1]}"
    "${app['less']}" -R "${args[@]}"
    return 0
}

koopa_parent_dir() {
    local app dict file parent pos
    declare -A app=(
        ['sed']="$(koopa_locate_sed)"
    )
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict=(
        ['cd_tail']=''
        ['n']=1
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--num='*)
                dict['n']="${1#*=}"
                shift 1
                ;;
            '--num' | \
            '-n')
                dict['n']="${2:?}"
                shift 2
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    [[ "${dict['n']}" -ge 1 ]] || dict['n']=1
    if [[ "${dict['n']}" -ge 2 ]]
    then
        dict['n']="$((dict[n]-1))"
        dict['cd_tail']="$( \
            printf "%${dict['n']}s" \
            | "${app['sed']}" 's| |/..|g' \
        )"
    fi
    for file in "$@"
    do
        [[ -e "$file" ]] || return 1
        parent="$(koopa_dirname "$file")"
        parent="${parent}${dict['cd_tail']}"
        parent="$(koopa_cd "$parent" && pwd -P)"
        koopa_print "$parent"
    done
    return 0
}

koopa_parse_app_json() {
    local cmd
    koopa_assert_has_args "$#"
    cmd="$(koopa_koopa_prefix)/lang/python/parse-app-json.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$@"
}

koopa_parse_url() {
    local app curl_args pos
    koopa_assert_has_args "$#"
    declare -A app
    app['curl']="$(koopa_locate_curl --allow-system)"
    [[ -x "${app['curl']}" ]] || return 1
    curl_args=(
        '--disable' # Ignore '~/.curlrc'. Must come first.
        '--fail'
        '--location'
        '--retry' 5
        '--show-error'
        '--silent'
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--insecure' | \
            '--list-only')
                curl_args+=("$1")
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_eq "$#" 1
    curl_args+=("${1:?}")
    "${app['curl']}" "${curl_args[@]}"
    return 0
}

koopa_paste() {
    local IFS pos sep str
    sep=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sep='*)
                sep="${1#*=}"
                shift 1
                ;;
            '--sep')
                sep="${2:?}"
                shift 2
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    IFS=''
    str="${*/#/$sep}"
    str="${str:${#sep}}"
    koopa_print "$str"
    return 0
}

koopa_paste0() {
    koopa_paste --sep='' "$@"
}

koopa_print_black_bold() {
    __koopa_print_ansi 'black-bold' "$@"
    return 0
}

koopa_print_black() {
    __koopa_print_ansi 'black' "$@"
    return 0
}

koopa_print_blue_bold() {
    __koopa_print_ansi 'blue-bold' "$@"
    return 0
}

koopa_print_blue() {
    __koopa_print_ansi 'blue' "$@"
    return 0
}

koopa_print_cyan_bold() {
    __koopa_print_ansi 'cyan-bold' "$@"
    return 0
}

koopa_print_cyan() {
    __koopa_print_ansi 'cyan' "$@"
    return 0
}

koopa_print_default_bold() {
    __koopa_print_ansi 'default-bold' "$@"
    return 0
}

koopa_print_default() {
    __koopa_print_ansi 'default' "$@"
    return 0
}

koopa_print_env() {
    export -p
    return 0
}

koopa_print_green_bold() {
    __koopa_print_ansi 'green-bold' "$@"
    return 0
}

koopa_print_green() {
    __koopa_print_ansi 'green' "$@"
    return 0
}

koopa_print_magenta_bold() {
    __koopa_print_ansi 'magenta-bold' "$@"
    return 0
}

koopa_print_magenta() {
    __koopa_print_ansi 'magenta' "$@"
    return 0
}

koopa_print_red_bold() {
    __koopa_print_ansi 'red-bold' "$@"
    return 0
}

koopa_print_red() {
    __koopa_print_ansi 'red' "$@"
    return 0
}

koopa_print_white_bold() {
    __koopa_print_ansi 'white-bold' "$@"
    return 0
}

koopa_print_white() {
    __koopa_print_ansi 'white' "$@"
    return 0
}

koopa_print_yellow_bold() {
    __koopa_print_ansi 'yellow-bold' "$@"
    return 0
}

koopa_print_yellow() {
    __koopa_print_ansi 'yellow' "$@"
    return 0
}

koopa_private_installers_url() {
    koopa_assert_has_no_args "$#"
    koopa_print 's3://private.koopa.acidgenomics.com/installers'
}

koopa_prune_app_binaries() {
    koopa_r_koopa 'cliPruneAppBinaries' "$@"
    return 0
}

koopa_prune_apps() {
    koopa_r_koopa 'cliPruneApps' "$@"
    return 0
}

koopa_public_ip_address() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app
    app['dig']="$(koopa_locate_dig --allow-missing)"
    if [[ -x "${app['dig']}" ]]
    then
        str="$( \
            "${app['dig']}" +short \
                'myip.opendns.com' \
                '@resolver1.opendns.com' \
                -4 \
        )"
    else
        str="$(koopa_parse_url 'https://ipecho.net/plain')"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_push_all_app_builds() {
    local app_names dict
    declare -A dict
    dict['opt_prefix']="$(koopa_opt_prefix)"
    readarray -t app_names <<< "$( \
        koopa_find \
            --days-modified-within=7 \
            --min-depth=1 \
            --max-depth=1 \
            --prefix="${dict['opt_prefix']}" \
            --sort \
            --type='l' \
        | koopa_basename \
    )"
    if koopa_is_array_empty "${app_names[@]}"
    then
        koopa_stop 'No apps were built recently.'
    fi
    koopa_push_app_build "${app_names[@]}"
    return 0
}

koopa_push_app_build() {
    local app dict name
    koopa_assert_has_args "$#"
    koopa_can_install_binary || return 1
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
        ['tar']="$(koopa_locate_tar)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['tar']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch2)" # e.g. 'amd64'.
        ['opt_prefix']="$(koopa_opt_prefix)"
        ['os_string']="$(koopa_os_string)"
        ['profile']='acidgenomics'
        ['s3_bucket']='s3://private.koopa.acidgenomics.com/binaries'
        ['tmp_dir']="$(koopa_tmp_dir)"
    )
    for name in "$@"
    do
        local dict2
        declare -A dict2
        dict2['name']="$name"
        dict2['prefix']="$( \
            koopa_realpath "${dict['opt_prefix']}/${dict2['name']}" \
        )"
        koopa_assert_is_dir "${dict2['prefix']}"
        if [[ -f "${dict2['prefix']}/.koopa-binary" ]]
        then
            koopa_alert_note "'${dict2['name']}' was installed as a binary."
            continue
        fi
        dict2['version']="$(koopa_basename "${dict2['prefix']}")"
        dict2['local_tar']="${dict['tmp_dir']}/\
${dict2['name']}/${dict2['version']}.tar.gz"
        dict2['s3_rel_path']="/${dict['os_string']}/${dict['arch']}/\
${dict2['name']}/${dict2['version']}.tar.gz"
        dict2['remote_tar']="${dict['s3_bucket']}${dict2['s3_rel_path']}"
        koopa_alert "Pushing '${dict2['prefix']}' to '${dict2['remote_tar']}'."
        koopa_mkdir "${dict['tmp_dir']}/${dict2['name']}"
        koopa_alert "Creating archive at '${dict2['local_tar']}'."
        "${app['tar']}" \
            --absolute-names \
            --create \
            --gzip \
            --totals \
            --verbose \
            --verbose \
            --file="${dict2['local_tar']}" \
            "${dict2['prefix']}/"
        koopa_alert "Copying to S3 at '${dict2['remote_tar']}'."
        "${app['aws']}" --profile="${dict['profile']}" \
            s3 cp "${dict2['local_tar']}" "${dict2['remote_tar']}"
    done
    koopa_rm "${dict['tmp_dir']}"
    return 0
}

koopa_python_activate_venv() {
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        ['active_env']="${VIRTUAL_ENV:-}"
        ['name']="${1:?}"
        ['nounset']="$(koopa_boolean_nounset)"
        ['prefix']="$(koopa_python_virtualenvs_prefix)"
    )
    dict['script']="${dict['prefix']}/${dict['name']}/bin/activate"
    koopa_assert_is_readable "${dict['script']}"
    if [[ -n "${dict['active_env']}" ]]
    then
        koopa_python_deactivate_venv "${dict['active_env']}"
    fi
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    source "${dict['script']}"
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_python_create_venv() {
    local app dict pkgs pos venv_args
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A app=(
        ['python']="$(koopa_locate_python)"
    )
    [[ -x "${app['python']}" ]] || return 1
    app['python']="$(koopa_realpath "${app['python']}")"
    declare -A dict=(
        ['name']=''
        ['pip']=1
        ['prefix']=''
        ['system_site_packages']=1
    )
    pos=()
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
            '--python='*)
                app['python']="${1#*=}"
                shift 1
                ;;
            '--python')
                app['python']="${2:?}"
                shift 2
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    pkgs=("$@")
    koopa_assert_is_set --python "${app['python']}"
    koopa_assert_is_installed "${app['python']}"
    dict['py_version']="$(koopa_get_version "${app['python']}")"
    dict['py_maj_min_ver']="$( \
        koopa_major_minor_version "${dict['py_version']}" \
    )"
    if [[ -z "${dict['prefix']}" ]]
    then
        koopa_assert_is_set --name "${dict['name']}"
        dict['venv_prefix']="$(koopa_python_virtualenvs_prefix)"
        dict['prefix']="${dict['venv_prefix']}/${dict['name']}"
        dict['app_bn']="$(koopa_basename "${dict['venv_prefix']}")"
        dict['app_prefix']="$(koopa_app_prefix)/${dict['app_bn']}/\
${dict['py_maj_min_ver']}"
        if [[ ! -d "${dict['app_prefix']}" ]]
        then
            koopa_alert "Configuring venv prefix at '${dict['app_prefix']}'."
            koopa_sys_mkdir "${dict['app_prefix']}"
            koopa_sys_set_permissions "$(koopa_dirname "${dict['app_prefix']}")"
        fi
        koopa_link_in_opt \
            --name="${dict['app_bn']}" \
            --source="${dict['app_prefix']}"
    fi
    [[ -d "${dict['prefix']}" ]] && koopa_rm "${dict['prefix']}"
    koopa_assert_is_not_dir "${dict['prefix']}"
    koopa_sys_mkdir "${dict['prefix']}"
    unset -v PYTHONPATH
    venv_args=()
    if [[ "${dict['pip']}" -eq 0 ]]
    then
        venv_args+=('--without-pip')
    fi
    if [[ "${dict['system_site_packages']}" -eq 1 ]]
    then
        venv_args+=('--system-site-packages')
    fi
    venv_args+=("${dict['prefix']}")
    "${app['python']}" -m venv "${venv_args[@]}"
    app['venv_python']="${dict['prefix']}/bin/python${dict['py_maj_min_ver']}"
    koopa_assert_is_installed "${app['venv_python']}"
    if [[ "${dict['pip']}" -eq 1 ]]
    then
        case "${dict['py_version']}" in
            '3.11.'* | \
            '3.10.'*)
                dict['pip_version']='22.3.1'
                dict['setuptools_version']='65.6.3'
                dict['wheel_version']='0.38.4'
                ;;
            *)
                koopa_stop "Unsupported Python: ${dict['py_version']}."
                ;;
        esac
        koopa_python_pip_install \
            --python="${app['venv_python']}" \
            "pip==${dict['pip_version']}" \
            "setuptools==${dict['setuptools_version']}" \
            "wheel==${dict['wheel_version']}"
    fi
    if koopa_is_array_non_empty "${pkgs[@]:-}"
    then
        koopa_python_pip_install --python="${app['venv_python']}" "${pkgs[@]}"
    fi
    koopa_sys_set_permissions --recursive "${dict['prefix']}"
    return 0
}

koopa_python_deactivate_venv() {
    local dict
    declare -A dict=(
        ['prefix']="${VIRTUAL_ENV:-}"
    )
    if [[ -z "${dict['prefix']}" ]]
    then
        koopa_stop 'Python virtual environment is not active.'
    fi
    koopa_remove_from_path "${dict['prefix']}/bin"
    unset -v VIRTUAL_ENV
    return 0
}

koopa_python_pip_install() {
    local app dict dl_args pkgs pos
    koopa_assert_has_args "$#"
    declare -A app
    app['python']="$(koopa_locate_python)"
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict
    dict['prefix']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--python='*)
                app['python']="${1#*=}"
                shift 1
                ;;
            '--python')
                app['python']="${2:?}"
                shift 2
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    pkgs=("$@")
    install_args=(
        '-vvv'
        '--default-timeout=300'
        '--disable-pip-version-check'
        '--ignore-installed'
        '--no-cache-dir'
        '--no-warn-script-location'
        '--progress-bar=on'
    )
    dl_args=(
        'Python' "${app['python']}"
        'Packages' "$(koopa_to_string "${pkgs[@]}")"
    )
    if [[ -n "${dict['prefix']}" ]]
    then
        install_args+=(
            "--target=${dict['prefix']}"
            '--upgrade'
        )
        dl_args+=('Target' "${dict['prefix']}")
    fi
    koopa_dl "${dl_args[@]}"
    export PIP_REQUIRE_VIRTUALENV='false'
    "${app['python']}" -m pip --isolated \
        install "${install_args[@]}" "${pkgs[@]}"
    return 0
}

koopa_python_system_packages_prefix() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['python']="${1:-}"
    )
    [[ -z "${app['python']}" ]] && app['python']="$(koopa_locate_python)"
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict
    dict['prefix']="$( \
        "${app['python']}" -c 'import site; print(site.getsitepackages()[0])' \
    )"
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_print "${dict['prefix']}"
    return 0
}

koopa_r_configure_environ() {
    local app conf_dict dict i key keys lines path_arr
    local app_pc_path_arr pc_path_arr
    koopa_assert_has_args_eq "$#" 1
    declare -A app
    declare -A dict
    app['r']="${1:?}"
    [[ -x "${app['r']}" ]] || return 1
    dict['system']=0
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    if [[ "${dict['system']}" -eq 1 ]] && koopa_is_docker
    then
        return 0
    fi
    app['bzip2']="$(koopa_locate_bzip2)"
    app['cat']="$(koopa_locate_cat)"
    app['gzip']="$(koopa_locate_gzip)"
    app['less']="$(koopa_locate_less)"
    app['lpr']="$(koopa_locate_lpr --allow-missing)"
    app['open']="$(koopa_locate_open --allow-missing)"
    app['pkg_config']="$(koopa_locate_pkg_config)"
    app['sort']="$(koopa_locate_sort)"
    app['texi2dvi']="$(koopa_locate_texi2dvi)"
    app['unzip']="$(koopa_locate_unzip)"
    app['zip']="$(koopa_locate_zip)"
    [[ -x "${app['bzip2']}" ]] || return 1
    [[ -x "${app['cat']}" ]] || return 1
    [[ -x "${app['gzip']}" ]] || return 1
    [[ -x "${app['less']}" ]] || return 1
    [[ -x "${app['pkg_config']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['texi2dvi']}" ]] || return 1
    [[ -x "${app['unzip']}" ]] || return 1
    [[ -x "${app['zip']}" ]] || return 1
    [[ ! -x "${app['lpr']}" ]] && app['lpr']='/usr/bin/lpr'
    [[ ! -x "${app['open']}" ]] && app['open']='/usr/bin/open'
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['tmp_file']="$(koopa_tmp_file)"
    dict['udunits2']="$(koopa_app_prefix 'udunits')"
    koopa_assert_is_dir \
        "${dict['r_prefix']}" \
        "${dict['udunits2']}"
    dict['file']="${dict['r_prefix']}/etc/Renviron.site"
    koopa_alert "Configuring '${dict['file']}'."
    declare -A conf_dict
    lines=()
    lines+=(
        "R_LIBS_SITE=\${R_HOME}/site-library"
        "R_LIBS_USER=\${R_LIBS_SITE}"
    )
    path_arr=()
    case "${dict['system']}" in
        '1')
            path_arr+=('/usr/local/bin')
            ;;
    esac
    path_arr+=(
        "${dict['koopa_prefix']}/bin"
        '/usr/bin'
        '/bin'
    )
    if koopa_is_macos
    then
        path_arr+=(
            '/Applications/quarto/bin'
            '/Library/TeX/texbin'
            '/usr/local/MacGPG2/bin'
            '/opt/X11/bin'
        )
    fi
    declare -A app_pc_path_arr
    keys=(
        'curl'
        'fontconfig'
        'freetype'
        'fribidi'
        'gdal'
        'geos'
        'glib'
        'graphviz'
        'harfbuzz'
        'icu4c'
        'imagemagick'
        'lapack'
        'libgit2'
        'libjpeg-turbo'
        'libpng'
        'libssh2'
        'libtiff'
        'libxml2'
        'openblas'
        'openssl3'
        'pcre'
        'pcre2'
        'proj'
        'python'
        'readline'
        'sqlite'
        'xz'
        'zlib'
        'zstd'
    )
    for key in "${keys[@]}"
    do
        local prefix
        prefix="$(koopa_app_prefix "$key")"
        koopa_assert_is_dir "$prefix"
        app_pc_path_arr[$key]="$prefix"
    done
    for i in "${!app_pc_path_arr[@]}"
    do
        app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/lib"
    done
    for i in "${!app_pc_path_arr[@]}"
    do
        app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/pkgconfig"
    done
    koopa_assert_is_dir "${app_pc_path_arr[@]}"
    pc_path_arr=()
    if [[ "${dict['system']}" -eq 1 ]]
    then
        pc_path_arr+=('/usr/local/lib/pkgconfig')
    fi
    pc_path_arr+=("${app_pc_path_arr[@]}")
    if [[ "${dict['system']}" -eq 1 ]]
    then
        local sys_pc_path_arr
        readarray -t sys_pc_path_arr <<< "$( \
            "${app['pkg_config']}" --variable 'pc_path' 'pkg-config' \
        )"
        pc_path_arr+=("${sys_pc_path_arr[@]}")
    fi
    conf_dict['path']="$(printf '%s:' "${path_arr[@]}")"
    conf_dict['pkg_config_path']="$(printf '%s:' "${pc_path_arr[@]}")"
    lines+=(
        "PAGER=${app['less']}"
        "PATH=${conf_dict['path']}"
        "PKG_CONFIG_PATH=${conf_dict['pkg_config_path']}"
        'R_BATCHSAVE=--no-save --no-restore'
        "R_BROWSER=${app['open']}"
        "R_BZIPCMD=${app['bzip2']}"
        "R_GZIPCMD=${app['gzip']}"
        'R_PAPERSIZE=letter'
        "R_PAPERSIZE_USER=\${R_PAPERSIZE}"
        "R_PDFVIEWER=${app['open']}"
        "R_PRINTCMD=${app['lpr']}"
        "R_TEXI2DVICMD=${app['texi2dvi']}"
        "R_UNZIPCMD=${app['unzip']}"
        "R_ZIPCMD=${app['zip']}"
        "TZ=\${TZ:-America/New_York}"
    )
    if koopa_is_linux
    then
        lines+=(
            'R_BROWSER=/usr/bin/xdg-open'
            'R_PRINTCMD=/usr/bin/lpr'
        )
    elif koopa_is_macos
    then
        lines+=('R_MAX_NUM_DLLS=153')
    fi
    lines+=('R_DATATABLE_NUM_PROCS_PERCENT=100')
    lines+=('RCMDCHECK_ERROR_ON=warning')
    lines+=(
        'R_REMOTES_STANDALONE=true'
        'R_REMOTES_UPGRADE=always'
    )
    lines+=(
        "WORKON_HOME=\${HOME}/.virtualenvs"
    )
    lines+=(
        'STRINGI_DISABLE_ICU_BUNDLE=1'
    )
    lines+=(
        "R_USER_CACHE_DIR=\${HOME}/.cache"
        "R_USER_CONFIG_DIR=\${HOME}/.config"
        "R_USER_DATA_DIR=\${HOME}/.local/share"
    )
    lines+=(
        "UDUNITS2_INCLUDE=${dict['udunits2']}/include"
        "UDUNITS2_LIBS=${dict['udunits2']}/lib"
    )
    if koopa_is_fedora_like
    then
        dict['oracle_ver']="$(koopa_app_json_version 'oracle-instant-client')"
        dict['oracle_ver']="$( \
            koopa_major_minor_version "${dict['oracle_ver']}" \
        )"
        lines+=(
            "OCI_VERSION=${dict['oracle_ver']}"
            "ORACLE_HOME=/usr/lib/oracle/\${OCI_VERSION}/client64"
            "OCI_INC=/usr/include/oracle/\${OCI_VERSION}/client64"
            "OCI_LIB=\${ORACLE_HOME}/lib"
            "PATH=\${PATH}:\${ORACLE_HOME}/bin"
            "TNS_ADMIN=\${ORACLE_HOME}/network/admin"
        )
    fi
    lines+=(
        '_R_CHECK_EXECUTABLES_=false'
        '_R_CHECK_EXECUTABLES_EXCLUSIONS_=false'
        "_R_CHECK_LENGTH_1_CONDITION_=package:_R_CHECK_PACKAGE_NAME_,\
abort,verbose"
        "_R_CHECK_LENGTH_1_LOGIC2_=package:_R_CHECK_PACKAGE_NAME_,\
abort,verbose"
        '_R_CHECK_S3_METHODS_NOT_REGISTERED_=true'
        'R_DEFAULT_INTERNET_TIMEOUT=600'
    )
    lines+=(
        '_R_CHECK_SYSTEM_CLOCK_=0'
        '_R_CHECK_TESTS_NLINES_=0'
    )
    if koopa_is_linux
    then
        lines+=(
            "_R_CHECK_COMPILATION_FLAGS_KNOWN_=-Wformat \
-Werror=format-security -Wdate-time"
        )
    fi
    dict['string']="$(koopa_print "${lines[@]}" | "${app['sort']}")"
    case "${dict['system']}" in
        '0')
            koopa_rm "${dict['file']}"
            koopa_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
        '1')
            koopa_rm --sudo "${dict['file']}"
            koopa_sudo_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
    esac
    return 0
}

koopa_r_configure_java() {
    local app conf_dict dict java_args r_cmd
    koopa_assert_has_args_eq "$#" 1
    declare -A app
    declare -A dict
    app['r']="${1:?}"
    [[ -x "${app['r']}" ]] || return 1
    dict['system']=0
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    if [[ "${dict['system']}" -eq 1 ]] && koopa_is_docker
    then
        return 0
    fi
    app['jar']="$(koopa_locate_jar --realpath)"
    app['java']="$(koopa_locate_java --realpath)"
    app['javac']="$(koopa_locate_javac --realpath)"
    app['sudo']="$(koopa_locate_sudo)"
    [[ -x "${app['jar']}" ]] || return 1
    [[ -x "${app['java']}" ]] || return 1
    [[ -x "${app['javac']}" ]] || return 1
    [[ -x "${app['sudo']}" ]] || return 1
    dict['openjdk']="$(koopa_app_prefix 'openjdk')"
    koopa_assert_is_dir "${dict['openjdk']}"
    koopa_alert 'Updating R Java configuration.'
    declare -A conf_dict=(
        ['java_home']="${dict['openjdk']}"
        ['jar']="${app['jar']}"
        ['java']="${app['java']}"
        ['javac']="${app['javac']}"
        ['javah']=''
    )
    java_args=(
        "JAR=${conf_dict['jar']}"
        "JAVA=${conf_dict['java']}"
        "JAVAC=${conf_dict['javac']}"
        "JAVAH=${conf_dict['javah']}"
        "JAVA_HOME=${conf_dict['java_home']}"
    )
    case "${dict[system]}" in
        '0')
            r_cmd=("${app['r']}")
            ;;
        '1')
            koopa_assert_is_admin
            r_cmd=("${app['sudo']}" "${app['r']}")
            ;;
    esac
    "${r_cmd[@]}" --vanilla CMD javareconf "${java_args[@]}"
    return 0
}

koopa_r_configure_ldpaths() {
    local app dict key keys ld_lib_arr ld_lib_app_arr lines
    koopa_assert_has_args_eq "$#" 1
    declare -A app
    declare -A dict
    app['r']="${1:?}"
    [[ -x "${app['r']}" ]] || return 1
    dict['system']=0
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    if [[ "${dict['system']}" -eq 1 ]] && koopa_is_docker
    then
        return 0
    fi
    dict['arch']="$(koopa_arch)"
    dict['java_home']="$(koopa_app_prefix 'openjdk')"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    koopa_assert_is_dir \
        "${dict['java_home']}" \
        "${dict['r_prefix']}"
    dict['file']="${dict['r_prefix']}/etc/ldpaths"
    koopa_alert "Configuring '${dict['file']}'."
    lines=()
    lines+=(
        ": \${JAVA_HOME=${dict['java_home']}}"
        ": \${R_JAVA_LD_LIBRARY_PATH=\${JAVA_HOME}/libexec/lib/server}"
    )
    declare -A ld_lib_app_arr
    keys=(
        'bzip2'
        'curl'
        'fontconfig'
        'freetype'
        'fribidi'
        'gdal'
        'geos'
        'glib'
        'graphviz'
        'harfbuzz'
        'hdf5'
        'icu4c'
        'imagemagick'
        'lapack'
        'libgit2'
        'libiconv'
        'libjpeg-turbo'
        'libpng'
        'libssh2'
        'libtiff'
        'libxml2'
        'openblas'
        'openssl3'
        'pcre'
        'pcre2'
        'proj'
        'python'
        'readline'
        'sqlite'
        'xz'
        'zlib'
        'zstd'
    )
    if koopa_is_macos || [[ "${dict['system']}" -eq 0 ]]
    then
        keys+=('gettext')
    fi
    for key in "${keys[@]}"
    do
        local prefix
        prefix="$(koopa_app_prefix "$key")"
        koopa_assert_is_dir "$prefix"
        ld_lib_app_arr[$key]="$prefix"
    done
    for i in "${!ld_lib_app_arr[@]}"
    do
        ld_lib_app_arr[$i]="${ld_lib_app_arr[$i]}/lib"
    done
    koopa_assert_is_dir "${ld_lib_app_arr[@]}"
    ld_lib_arr=()
    ld_lib_arr+=("\${R_HOME}/lib")
    case "${dict['system']}" in
        '1')
            ld_lib_arr+=('/usr/local/lib')
            ;;
    esac
    ld_lib_arr+=("${ld_lib_app_arr[@]}")
    if koopa_is_linux
    then
        local sys_libdir
        sys_libdir="/usr/lib/${dict['arch']}-linux-gnu"
        koopa_assert_is_dir "$sys_libdir"
        ld_lib_arr+=("$sys_libdir")
    fi
    ld_lib_arr+=(
        '/usr/lib'
        "\${R_JAVA_LD_LIBRARY_PATH}"
    )
    lines+=(
        "LD_LIBRARY_PATH=\"$(printf '%s:' "${ld_lib_arr[@]}")\""
        'export LD_LIBRARY_PATH'
    )
    if koopa_is_macos
    then
        lines+=(
            "DYLD_FALLBACK_LIBRARY_PATH=\"\${LD_LIBRARY_PATH}\""
            'export DYLD_FALLBACK_LIBRARY_PATH'
        )
    fi
    dict['string']="$(koopa_print "${lines[@]}")"
    case "${dict['system']}" in
        '0')
            koopa_rm "${dict['file']}"
            koopa_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
        '1')
            koopa_rm --sudo "${dict['file']}"
            koopa_sudo_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
    esac
    return 0
}

koopa_r_configure_makeconf() {
    local app dict libs
    declare -A app
    declare -A dict
    app['r']="${1:?}"
    [[ -x "${app['r']}" ]] || return 1
    dict['system']=0
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    if [[ "${dict['system']}" -eq 1 ]] && koopa_is_docker
    then
        return 0
    fi
    app['pkg_config']="$(koopa_locate_pkg_config)"
    [[ -x "${app['pkg_config']}" ]] || return 1
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['icu4c']="$(koopa_app_prefix 'icu4c')"
    dict['libjpeg']="$(koopa_app_prefix 'libjpeg-turbo')"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['pcre2']="$(koopa_app_prefix 'pcre2')"
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['file']="${dict['r_prefix']}/etc/Makeconf"
    koopa_assert_is_dir \
        "${dict['bzip2']}" \
        "${dict['icu4c']}" \
        "${dict['libiconv']}" \
        "${dict['libjpeg']}" \
        "${dict['pcre2']}" \
        "${dict['r_prefix']}" \
        "${dict['zlib']}"
    koopa_alert "Updating ${dict['file']}"
    koopa_assert_is_file "${dict['file']}"
    koopa_add_to_pkg_config_path \
        "${dict['icu4c']}/lib/pkgconfig" \
        "${dict['libjpeg']}/lib/pkgconfig" \
        "${dict['pcre2']}/lib/pkgconfig" \
        "${dict['zlib']}/lib/pkgconfig"
    libs=(
        "$("${app['pkg_config']}" --libs \
            'icu-i18n' \
            'icu-uc' \
            'libjpeg' \
            'libpcre2-8' \
            'zlib' \
        )"
        "-L${dict['bzip2']}/lib"
        "-L${dict['libiconv']}/lib"
        '-ldl'
        '-lm'
    )
    koopa_is_linux && libs+=('-lrt' '-ltirpc')
    dict['pattern']='^LIBS = .+$'
    dict['replacement']="LIBS = ${libs[*]}"
    case "${dict['system']}" in
        '0')
            koopa_find_and_replace_in_file \
                --pattern="${dict['pattern']}" \
                --replacement="${dict['replacement']}" \
                --regex \
                "${dict['file']}"
            ;;
        '1')
            koopa_find_and_replace_in_file \
                --sudo \
                --pattern="${dict['pattern']}" \
                --replacement="${dict['replacement']}" \
                --regex \
                "${dict['file']}"
            ;;
    esac
    unset -v PKG_CONFIG_PATH
    return 0
}

koopa_r_configure_makevars() {
    local app conf_dict dict
    local cppflags ldflags lines
    koopa_assert_has_args_eq "$#" 1
    declare -A app
    declare -A dict
    app['r']="${1:?}"
    [[ -x "${app['r']}" ]] || return 1
    dict['system']=0
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    if [[ "${dict['system']}" -eq 1 ]] && koopa_is_docker
    then
        return 0
    fi
    app['ar']='/usr/bin/ar'
    app['awk']="$(koopa_locate_awk --realpath)"
    app['bash']="$(koopa_locate_bash --realpath)"
    app['echo']="$(koopa_locate_echo --realpath)"
    app['gfortran']="$(koopa_locate_gfortran --realpath)"
    app['make']="$(koopa_locate_make --realpath)"
    app['pkg_config']="$(koopa_locate_pkg_config)"
    app['ranlib']='/usr/bin/ranlib'
    app['sed']="$(koopa_locate_sed --realpath)"
    app['sort']="$(koopa_locate_sort)"
    app['strip']='/usr/bin/strip'
    app['tar']="$(koopa_locate_tar --realpath)"
    app['yacc']="$(koopa_locate_yacc --realpath)"
    [[ -x "${app['ar']}" ]] || return 1
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['bash']}" ]] || return 1
    [[ -x "${app['echo']}" ]] || return 1
    [[ -x "${app['gfortran']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['pkg_config']}" ]] || return 1
    [[ -x "${app['ranlib']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['strip']}" ]] || return 1
    [[ -x "${app['tar']}" ]] || return 1
    [[ -x "${app['yacc']}" ]] || return 1
    dict['arch']="$(koopa_arch)"
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['gettext']="$(koopa_app_prefix 'gettext')"
    dict['hdf5']="$(koopa_app_prefix 'hdf5')"
    dict['lapack']="$(koopa_app_prefix 'lapack')"
    dict['libjpeg']="$(koopa_app_prefix 'libjpeg-turbo')"
    dict['libpng']="$(koopa_app_prefix 'libpng')"
    dict['openblas']="$(koopa_app_prefix 'openblas')"
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    koopa_assert_is_dir \
        "${dict['bzip2']}" \
        "${dict['gettext']}" \
        "${dict['hdf5']}" \
        "${dict['lapack']}" \
        "${dict['libjpeg']}" \
        "${dict['libpng']}" \
        "${dict['openblas']}" \
        "${dict['r_prefix']}"
    koopa_add_to_pkg_config_path \
        "${dict['lapack']}/lib/pkgconfig" \
        "${dict['libjpeg']}/lib/pkgconfig" \
        "${dict['libpng']}/lib/pkgconfig" \
        "${dict['openblas']}/lib/pkgconfig"
    dict['file']="${dict['r_prefix']}/etc/Makevars.site"
    if koopa_is_macos
    then
        app['cc']='/usr/bin/clang'
        app['cxx']='/usr/bin/clang++'
    else
        case "${dict['system']}" in
            '0')
                app['cc']="$(koopa_locate_gcc --realpath)"
                app['cxx']="$(koopa_locate_gcxx --realpath)"
                ;;
            '1')
                app['cc']='/usr/bin/gcc'
                app['cxx']='/usr/bin/g++'
                ;;
        esac
    fi
    [[ -x "${app['cc']}" ]] || return 1
    [[ -x "${app['cxx']}" ]] || return 1
    koopa_alert "Configuring '${dict['file']}'."
    cppflags=()
    ldflags=()
    lines=()
    case "${dict['system']}" in
        '1')
            cppflags+=('-I/usr/local/include')
            ldflags+=('-L/usr/local/lib')
            ;;
    esac
    if koopa_is_linux
    then
        local app_pc_path_arr i key keys pkg_config
        declare -A app_pc_path_arr
        keys=(
            'curl'
            'fontconfig'
            'freetype'
            'fribidi'
            'gdal'
            'geos'
            'glib'
            'graphviz'
            'harfbuzz'
            'icu4c'
            'imagemagick'
            'lapack'
            'libgit2'
            'libjpeg-turbo'
            'libpng'
            'libssh2'
            'libtiff'
            'libxml2'
            'openblas'
            'openssl3'
            'pcre'
            'pcre2'
            'proj'
            'python'
            'readline'
            'sqlite'
            'xz'
            'zlib'
            'zstd'
        )
        for key in "${keys[@]}"
        do
            local prefix
            prefix="$(koopa_app_prefix "$key")"
            koopa_assert_is_dir "$prefix"
            app_pc_path_arr[$key]="$prefix"
        done
        for i in "${!app_pc_path_arr[@]}"
        do
            app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/lib"
        done
        for i in "${!app_pc_path_arr[@]}"
        do
            app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/pkgconfig"
        done
        koopa_assert_is_dir "${app_pc_path_arr[@]}"
        koopa_add_to_pkg_config_path "${app_pc_path_arr[@]}"
        pkg_config=(
            'fontconfig'
            'freetype2'
            'fribidi'
            'harfbuzz'
            'icu-i18n'
            'icu-uc'
            'libcurl'
            'libjpeg'
            'libpcre2-8'
            'libpng'
            'libtiff-4'
            'libxml-2.0'
            'libzstd'
            'zlib'
        )
        cppflags+=(
            "$("${app['pkg_config']}" --cflags "${pkg_config[@]}")"
        )
        ldflags+=(
            "$("${app['pkg_config']}" --libs-only-L "${pkg_config[@]}")"
        )
    fi
    cppflags+=(
        "-I${dict['bzip2']}/include"
        "-I${dict['hdf5']}/include"
        "-I${dict['libjpeg']}/include"
        "-I${dict['libpng']}/include"
    )
    ldflags+=(
        "-L${dict['bzip2']}/lib"
        "-L${dict['hdf5']}/lib"
        "-L${dict['libjpeg']}/lib"
        "-L${dict['libpng']}/lib"
    )
    if koopa_is_macos
    then
        cppflags+=("-I${dict['gettext']}/include")
        ldflags+=("-L${dict['gettext']}/lib")
    fi
    koopa_is_macos && ldflags+=('-lomp')
    declare -A conf_dict
    conf_dict['ar']="${app['ar']}"
    conf_dict['awk']="${app['awk']}"
    conf_dict['blas_libs']="$("${app['pkg_config']}" --libs 'openblas')"
    conf_dict['cc']="${app['cc']}"
    conf_dict['cflags']="-Wall -g -O2 \$(LTO)"
    conf_dict['cppflags']="${cppflags[*]}"
    conf_dict['cxx']="${app['cxx']} -std=gnu++14"
    conf_dict['echo']="${app['echo']}"
    conf_dict['f77']="${app['gfortran']}"
    conf_dict['fc']="${app['gfortran']}"
    conf_dict['fflags']="-Wall -g -O2 \$(LTO_FC)"
    conf_dict['flibs']="$(koopa_gfortran_libs)"
    conf_dict['lapack_libs']="$("${app['pkg_config']}" --libs 'lapack')"
    conf_dict['ldflags']="${ldflags[*]}"
    conf_dict['make']="${app['make']}"
    conf_dict['objc_libs']='-lobjc'
    conf_dict['objcflags']="-Wall -g -O2 -fobjc-exceptions \$(LTO)"
    conf_dict['ranlib']="${app['ranlib']}"
    conf_dict['safe_fflags']='-Wall -g -O2 -msse2 -mfpmath=sse'
    conf_dict['sed']="${app['sed']}"
    conf_dict['shell']="${app['bash']}"
    conf_dict['strip_shared_lib']="${app['strip']} -x"
    conf_dict['strip_static_lib']="${app['strip']} -S"
    conf_dict['tar']="${app['tar']}"
    conf_dict['yacc']="${app['yacc']}"
    conf_dict['cxx11']="${conf_dict['cxx']}"
    conf_dict['cxx14']="${conf_dict['cxx']}"
    conf_dict['cxx17']="${conf_dict['cxx']}"
    conf_dict['cxx20']="${conf_dict['cxx']}"
    conf_dict['cxxflags']="${conf_dict['cflags']}"
    conf_dict['cxx11flags']="${conf_dict['cxxflags']}"
    conf_dict['cxx14flags']="${conf_dict['cxxflags']}"
    conf_dict['cxx17flags']="${conf_dict['cxxflags']}"
    conf_dict['cxx20flags']="${conf_dict['cxxflags']}"
    conf_dict['f77flags']="${conf_dict['fflags']}"
    conf_dict['fcflags']="${conf_dict['fflags']}"
    conf_dict['objc']="${conf_dict['cc']}"
    conf_dict['objcxx']="${conf_dict['cxx']}"
    case "${dict['system']}" in
        '0')
            conf_dict['op']='+='
            ;;
        '1')
            conf_dict['op']='='
            ;;
    esac
    lines+=(
        "AR = ${conf_dict['ar']}"
        "AWK = ${conf_dict['awk']}"
        "BLAS_LIBS = ${conf_dict['blas_libs']}"
        "CC = ${conf_dict['cc']}"
        "CFLAGS = ${conf_dict['cflags']}"
        "CPPFLAGS ${conf_dict['op']} ${conf_dict['cppflags']}"
        "CXX = ${conf_dict['cxx']}"
        "CXX11 = ${conf_dict['cxx11']}"
        "CXX11FLAGS = ${conf_dict['cxx11flags']}"
        "CXX14 = ${conf_dict['cxx14']}"
        "CXX14FLAGS = ${conf_dict['cxx14flags']}"
        "CXX17 = ${conf_dict['cxx17']}"
        "CXX17FLAGS = ${conf_dict['cxx17flags']}"
        "CXX20 = ${conf_dict['cxx20']}"
        "CXX20FLAGS = ${conf_dict['cxx20flags']}"
        "CXXFLAGS = ${conf_dict['cxxflags']}"
        "ECHO = ${conf_dict['echo']}"
        "F77 = ${conf_dict['f77']}"
        "F77FLAGS = ${conf_dict['f77flags']}"
        "FC = ${conf_dict['fc']}"
        "FCFLAGS = ${conf_dict['fcflags']}"
        "FFLAGS = ${conf_dict['fflags']}"
        "FLIBS = ${conf_dict['flibs']}"
        "LAPACK_LIBS = ${conf_dict['lapack_libs']}"
        "LDFLAGS ${conf_dict['op']} ${conf_dict['ldflags']}"
        "MAKE = ${conf_dict['make']}"
        "OBJC = ${conf_dict['objc']}"
        "OBJCFLAGS = ${conf_dict['objcflags']}"
        "OBJCXX = ${conf_dict['objcxx']}"
        "OBJC_LIBS = ${conf_dict['objc_libs']}"
        "RANLIB = ${conf_dict['ranlib']}"
        "SAFE_FFLAGS = ${conf_dict['safe_fflags']}"
        "SED = ${conf_dict['sed']}"
        "SHELL = ${conf_dict['shell']}"
        "STRIP_SHARED_LIB = ${conf_dict['strip_shared_lib']}"
        "STRIP_STATIC_LIB = ${conf_dict['strip_static_lib']}"
        "TAR = ${conf_dict['tar']}"
        "YACC = ${conf_dict['yacc']}"
    )
    if koopa_is_macos
    then
        local libintl
        libintl=(
            '-Wl,-framework'
            '-Wl,CoreFoundation'
        )
        conf_dict['libintl']="${libintl[*]}"
        conf_dict['shlib_openmp_cflags']='-Xclang -fopenmp'
        lines+=(
            "LIBINTL = ${conf_dict['libintl']}"
            "SHLIB_OPENMP_CFLAGS = ${conf_dict['shlib_openmp_cflags']}"
        )
    fi
    dict['string']="$(koopa_print "${lines[@]}" | "${app['sort']}")"
    case "${dict['system']}" in
        '0')
            koopa_rm "${dict['file']}"
            koopa_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
        '1')
            koopa_rm --sudo "${dict['file']}"
            koopa_sudo_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
    esac
    unset -v PKG_CONFIG_PATH
    return 0
}

koopa_r_koopa() {
    local app code header_file fun pos rscript_args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['rscript']="$(koopa_locate_rscript)"
    )
    [[ -x "${app['rscript']}" ]] || return 1
    rscript_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--vanilla')
                rscript_args+=('--vanilla')
                shift 1
                ;;
            '--'*)
                pos+=("$1")
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    fun="${1:?}"
    shift 1
    header_file="$(koopa_koopa_prefix)/lang/r/include/header.R"
    koopa_assert_is_file "$header_file"
    code=("source('${header_file}');")
    if [[ "$fun" != 'header' ]]
    then
        code+=("koopa::${fun}();")
    fi
    pos=("$@")
    "${app['rscript']}" "${rscript_args[@]}" -e "${code[*]}" "${pos[@]@Q}"
    return 0
}

koopa_r_library_prefix() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['r']="${1:-}"
    )
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    [[ -x "${app['r']}" ]] || return 1
    app['rscript']="${app['r']}script"
    [[ -x "${app['rscript']}" ]] || return 1
    declare -A dict
    dict['prefix']="$( \
        "${app['rscript']}" -e 'cat(normalizePath(.libPaths()[[1L]]))' \
    )"
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_print "${dict['prefix']}"
    return 0
}

koopa_r_link_files_in_etc() {
    local app dict file files
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['r']="${1:?}"
    )
    [[ -x "${app['r']}" ]] || return 1
    declare -A dict=(
        ['r_etc_source']="$(koopa_koopa_prefix)/etc/R"
        ['r_prefix']="$(koopa_r_prefix "${app['r']}")"
        ['sudo']=0
        ['version']="$(koopa_r_version "${app['r']}")"
    )
    koopa_assert_is_dir "${dict['r_etc_source']}" "${dict['r_prefix']}"
    if koopa_is_linux && \
        ! koopa_is_koopa_app "${app['r']}" && \
        [[ -d '/etc/R' ]]
    then
        dict['r_etc_target']='/etc/R'
        dict['sudo']=1
    else
        dict['r_etc_target']="${dict['r_prefix']}/etc"
    fi
    files=(
        'Rprofile.site'
        'repositories'
    )
    for file in "${files[@]}"
    do
        if [[ "${dict['sudo']}" -eq 1 ]]
        then
            koopa_ln --sudo \
                "${dict['r_etc_source']}/${file}" \
                "${dict['r_etc_target']}/${file}"
        else
            koopa_sys_ln \
                "${dict['r_etc_source']}/${file}" \
                "${dict['r_etc_target']}/${file}"
        fi
    done
    return 0
}

koopa_r_package_version() {
    local app str vec
    koopa_assert_has_args "$#"
    declare -A app=(
        ['rscript']="$(koopa_locate_rscript)"
    )
    [[ -x "${app['rscript']}" ]] || return 1
    pkgs=("$@")
    koopa_is_r_package_installed "${pkgs[@]}" || return 1
    vec="$(koopa_r_paste_to_vector "${pkgs[@]}")"
    str="$( \
        "${app['rscript']}" -e " \
            cat(vapply( \
                X = ${vec}, \
                FUN = function(x) { \
                    as.character(packageVersion(x)) \
                }, \
                FUN.VALUE = character(1L) \
            ), sep = '\n') \
        " \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_r_packages_prefix() {
    local app dict
    declare -A app
    app['r']="${1:?}"
    [[ -x "${app['r']}" ]] || return 1
    declare -A dict
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['str']="${dict['r_prefix']}/site-library"
    [[ -d "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_r_paste_to_vector() {
    local str
    koopa_assert_has_args "$#"
    str="$(printf '"%s", ' "$@")"
    str="$(koopa_strip_right --pattern=', ' "$str")"
    str="$(printf 'c(%s)\n' "$str")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_r_prefix() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['r']="${1:-}"
    )
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    [[ -x "${app['r']}" ]] || return 1
    app['rscript']="${app['r']}script"
    [[ -x "${app['rscript']}" ]] || return 1
    declare -A dict
    dict['prefix']="$( \
        "${app['rscript']}" \
            --vanilla \
            -e 'cat(normalizePath(Sys.getenv("R_HOME")))' \
        2>/dev/null \
    )"
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_print "${dict['prefix']}"
    return 0
}

koopa_r_rebuild_docs() {
    local app doc_dir html_dir pkg_index rscript_args
    declare -A app=(
        ['r']="${1:?}"
    )
    koopa_assert_is_installed "${app['r']}"
    app['rscript']="${app['r']}script"
    koopa_assert_is_installed "${app['rscript']}"
    koopa_is_koopa_app "${app['rscript']}" || return 0
    declare -A dict
    koopa_alert 'Updating HTML package index.'
    rscript_args=('--vanilla')
    dict['doc_dir']="$( \
        "${app['rscript']}" "${rscript_args[@]}" -e 'cat(R.home("doc"))' \
    )"
    dict['html_dir']="${dict['doc_dir']}/html"
    dict['pkg_index']="${dict['html_dir']}/packages.html"
    dict['r_css']="${dict['html_dir']}/R.css"
    if [[ ! -d "${dict['html_dir']}" ]]
    then
        koopa_mkdir "${dict['html_dir']}"
    fi
    if [[ ! -f "${dict['pkg_index']}" ]]
    then
        koopa_touch "${dict['pkg_index']}"
    fi
    if [[ ! -f "${dict['r_css']}" ]]
    then
        koopa_touch "${dict['r_css']}"
    fi
    koopa_sys_set_permissions "${dict['pkg_index']}"
    "${app['rscript']}" "${rscript_args[@]}" -e 'utils::make.packages.html()'
    return 0
}

koopa_r_shiny_run_app() {
    local app dict
    declare -A app=(
        ['r']="$(koopa_locate_r)"
    )
    [[ -x "${app['r']}" ]] || return 1
    declare -A dict=(
        ['prefix']="${1:-}"
    )
    [[ -z "${dict['prefix']}" ]] && dict['prefix']="${PWD:?}"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    "${app['r']}" \
        --no-restore \
        --no-save \
        --quiet \
        -e "shiny::runApp('${dict['prefix']}')"
    return 0
}

koopa_r_system_library_prefix() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['r']="${1:-}"
    )
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    [[ -x "${app['r']}" ]] || return 1
    app['rscript']="${app['r']}script"
    [[ -x "${app['rscript']}" ]] || return 1
    declare -A dict
    dict['prefix']="$( \
        "${app['rscript']}" \
            --vanilla \
            -e 'cat(normalizePath(tail(.libPaths(), n = 1L)))' \
    )"
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_print "${dict['prefix']}"
    return 0
}

koopa_r_version() {
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['head']="$(koopa_locate_head --allow-system)"
        ['r']="${1:-}"
    )
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['r']}" ]] || return 1
    str="$( \
        R_HOME='' \
        "${app['r']}" --version 2>/dev/null \
            | "${app['head']}" -n 1 \
    )"
    if koopa_str_detect_fixed \
        --string="$str" \
        --pattern='R Under development (unstable)'
    then
        str='devel'
    else
        str="$(koopa_extract_version "$str")"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_read_prompt_yn() {
    local dict
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        ['input']="${2:?}"
        ['no']="$(koopa_print_red 'no')"
        ['no_default']="$(koopa_print_red_bold 'NO')"
        ['prompt']="${1:?}"
        ['yes']="$(koopa_print_green 'yes')"
        ['yes_default']="$(koopa_print_green_bold 'YES')"
    )
    case "${dict['input']}" in
        '0')
            dict['yn']="${dict['yes']}/${dict['no_default']}"
            ;;
        '1')
            dict['yn']="${dict['yes_default']}/${dict['no']}"
            ;;
        *)
            koopa_stop "Invalid choice: requires '0' or '1'."
            ;;
    esac
    koopa_print "${dict['prompt']}? [${dict['yn']}]: "
    return 0
}

koopa_read_yn() {
    local dict read_args
    koopa_assert_has_args_eq "$#" 2
    declare -A dict
    dict['prompt']="$(koopa_read_prompt_yn "$@")"
    dict['default']="$(koopa_int_to_yn "${2:?}")"
    read_args=(
        -e
        -i "${dict['default']}"
        -p "${dict['prompt']}"
        -r
    )
    read "${read_args[@]}" "dict[choice]"
    [[ -z "${dict['choice']}" ]] && dict['choice']="${dict['default']}"
    case "${dict['choice']}" in
        '1' | \
        'T' | \
        'TRUE' | \
        'True' | \
        'Y' | \
        'YES' | \
        'Yes' | \
        'true' | \
        'y' | \
        'yes')
            dict['int']=1
            ;;
        '0' | \
        'F' | \
        'FALSE' | \
        'False' | \
        'N' | \
        'NO' | \
        'No' | \
        'false' | \
        'n' | \
        'no')
            dict['int']=0
            ;;
        *)
            koopa_stop "Invalid 'yes/no' choice: '${dict['choice']}'."
            ;;
    esac
    koopa_print "${dict['int']}"
    return 0
}

koopa_read() {
    local dict read_args
    koopa_assert_has_args_eq "$#" 2
    declare -A dict
    dict['default']="${2:?}"
    dict['prompt']="${1:?} [${dict['default']}]: "
    read_args=(
        -e
        -i "${dict['default']}"
        -p "${dict['prompt']}"
        -r
    )
    read "${read_args[@]}" "dict[choice]"
    [[ -z "${dict['choice']}" ]] && dict['choice']="${dict['default']}"
    koopa_print "${dict['choice']}"
    return 0
}

koopa_reinstall_all_revdeps() {
    local app_name flags pos
    koopa_assert_has_args "$#"
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--'*)
                flags+=("$1")
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        local install_args revdeps
        install_args=()
        if koopa_is_array_non_empty "${flags[@]}"
        then
            install_args+=("${flags[@]}")
        fi
        install_args+=("$app_name")
        readarray -t revdeps <<< "$(koopa_app_json_revdeps "$app_name")"
        if koopa_is_array_non_empty "${revdeps[@]}"
        then
            install_args+=("${revdeps[@]}")
            koopa_dl \
                "${app_name} reverse dependencies" \
                "$(koopa_to_string "${revdeps[@]}")"
        else
            koopa_alert_note "${app_name} has no reverse dependencies."
        fi
        koopa_cli_reinstall "${install_args[@]}"
    done
    return 0
}

koopa_reinstall_app() {
    koopa_assert_has_args "$#"
    koopa_koopa install "$@" --reinstall
}

koopa_relink() {
    local app dict ln pos rm sudo
    declare -A app=(
        ['ln']='koopa_ln'
        ['rm']='koopa_rm'
    )
    declare -A dict=(
        ['sudo']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_eq "$#" 2
    ln=("${app['ln']}")
    rm=("${app['rm']}")
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        ln+=('--sudo')
        rm+=('--sudo')
    fi
    dict['source_file']="${1:?}"
    dict['dest_file']="${2:?}"
    [[ -e "${dict['source_file']}" ]] || return 0
    [[ -L "${dict['dest_file']}" ]] && return 0
    "${rm[@]}" "${dict['dest_file']}"
    "${ln[@]}" "${dict['source_file']}" "${dict['dest_file']}"
    return 0
}

koopa_reload_shell() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['shell']="$(koopa_locate_shell)"
    )
    [[ -x "${app['shell']}" ]] || return 1
    exec "${app['shell']}" -il
    return 0
}

koopa_rename_from_csv() {
    local file line
    koopa_assert_has_args "$#"
    file="${1:?}"
    koopa_assert_is_file_type --ext='csv' "$file"
    while read -r line
    do
        local from to
        from="${line%,*}"
        to="${line#*,}"
        koopa_mv "$from" "$to"
    done < "$file"
    return 0
}

koopa_rename_lowercase() {
    local app dict pos
    koopa_assert_has_args "$#"
    declare -A app=(
        ['rename']="$(koopa_locate_rename)"
        ['xargs']="$(koopa_locate_xargs)"
    )
    [[ -x "${app['rename']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    declare -A dict=(
        ['pattern']='y/A-Z/a-z/'
        ['recursive']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--recursive')
                dict['recursive']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        koopa_assert_has_args_le "$#" 1
        dict['prefix']="${1:-.}"
        koopa_assert_is_dir "${dict['prefix']}"
        koopa_find \
            --exclude='.*' \
            --min-depth=1 \
            --pattern='*[A-Z]*' \
            --prefix="${dict['prefix']}" \
            --print0 \
            --sort \
            --type='f' \
        | "${app['xargs']}" -0 -I {} \
            "${app['rename']}" \
                --force \
                --verbose \
                "${dict['pattern']}" \
                {}
        koopa_find \
            --exclude='.*' \
            --min-depth=1 \
            --pattern='*[A-Z]*' \
            --prefix="${dict['prefix']}" \
            --print0 \
            --type='d' \
        | "${app['xargs']}" -0 -I {} \
            "${app['rename']}" \
                --force \
                --verbose \
                "${dict['pattern']}" \
                {}
    else
        "${app['rename']}" \
            --force \
            --verbose \
            "${dict['pattern']}" \
            "$@"
    fi
    return 0
}

koopa_reset_permissions() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['chmod']="$(koopa_locate_chmod)"
        ['xargs']="$(koopa_locate_xargs)"
    )
    [[ -x "${app['chmod']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    declare -A dict=(
        ['group']="$(koopa_group)"
        ['prefix']="${1:?}"
        ['user']="$(koopa_user)"
    )
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    koopa_chown --recursive \
        "${dict['user']}:${dict['group']}" \
        "${dict['prefix']}"
    koopa_find \
        --prefix="${dict['prefix']}" \
        --print0 \
        --type='d' \
    | "${app['xargs']}" -0 -I {} \
        "${app['chmod']}" 'u=rwx,g=rwx,o=rx' {}
    koopa_find \
        --prefix="${dict['prefix']}" \
        --print0 \
        --type='f' \
    | "${app['xargs']}" -0 -I {} \
        "${app['chmod']}" 'u=rw,g=rw,o=r' {}
    koopa_find \
        --pattern='*.sh' \
        --prefix="${dict['prefix']}" \
        --print0 \
        --type='f' \
    | "${app['xargs']}" -0 -I {} \
        "${app['chmod']}" 'u=rwx,g=rwx,o=rx' {}
    return 0
}

koopa_rg_sort() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['rg']="$(koopa_locate_rg)"
    )
    [[ -x "${app['rg']}" ]] || return 1
    declare -A dict=(
        ['pattern']="${1:?}"
    )
    dict['str']="$( \
        "${app['rg']}" \
            --pretty \
            --sort 'path' \
            "${dict['pattern']}" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_rg_unique() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['rg']="$(koopa_locate_rg)"
        ['sort']="$(koopa_locate_sort)"
    )
    [[ -x "${app['rg']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    declare -A dict=(
        ['pattern']="${1:?}"
    )
    dict['str']="$( \
        "${app['rg']}" \
            --no-filename \
            --no-line-number \
            --only-matching \
            --sort 'none' \
            "${dict['pattern']}" \
        | "${app['sort']}" --unique \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_rm() {
    local app dict pos rm rm_args
    declare -A app
    app['rm']="$(koopa_locate_rm --allow-system)"
    [[ -x "${app['rm']}" ]] || return 1
    declare -A dict
    dict['sudo']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    rm_args=('-fr')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        app['sudo']="$(koopa_locate_sudo)"
        [[ -x "${app['sudo']}" ]] || return 1
        rm+=("${app['sudo']}" "${app['rm']}")
    else
        rm=("${app['rm']}")
    fi
    "${rm[@]}" "${rm_args[@]}" "$@"
    return 0
}

koopa_rnaeditingindexer() {
    local app dict run_args
    declare -A app=(
        ['docker']="$(koopa_locate_docker)"
    )
    [[ -x "${app['docker']}" ]] || return 1
    declare -A dict=(
        ['bam_suffix']='.Aligned.sortedByCoord.out.bam'
        ['docker_image']='acidgenomics/rnaeditingindexer'
        ['example']=0
        ['genome']='hg38'
        ['local_bam_dir']='bam'
        ['local_output_dir']='rnaedit'
        ['mnt_bam_dir']='/mnt/bam'
        ['mnt_output_dir']='/mnt/output'
    )
    while (("$#"))
    do
        case "$1" in
            '--bam-dir='*)
                dict['local_bam_dir']="${1#*=}"
                shift 1
                ;;
            '--bam-dir')
                dict['local_bam_dir']="${2:?}"
                shift 2
                ;;
            '--genome='*)
                dict['genome']="${1#*=}"
                shift 1
                ;;
            '--genome')
                dict['genome']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['local_output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['local_output_dir']="${2:?}"
                shift 2
                ;;
            '--example')
                dict['example']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    run_args=()
    if [[ "${dict['example']}" -eq 1 ]]
    then
        dict['bam_suffix']="_sampled_with_0.1.Aligned.sortedByCoord.out.\
bam.AluChr1Only.bam"
        dict['local_bam_dir']=''
        dict['mnt_bam_dir']='/bin/AEI/RNAEditingIndexer/TestResources/BAMs'
    else
        koopa_assert_is_dir "${dict['local_bam_dir']}"
        dict['local_bam_dir']="$(koopa_realpath "${dict['local_bam_dir']}")"
        koopa_rm "${dict['local_output_dir']}"
        dict['local_output_dir']="$( \
            koopa_init_dir "${dict['local_output_dir']}" \
        )"
        run_args+=(
            -v "${dict['local_bam_dir']}:${dict['mnt_bam_dir']}:ro"
            -v "${dict['local_output_dir']}:${dict['mnt_output_dir']}:rw"
        )
    fi
    run_args+=("${dict['docker_image']}")
    "${app['docker']}" run "${run_args[@]}" \
        RNAEditingIndex \
            --genome "${dict['genome']}" \
            --keep_cmpileup \
            --verbose \
            -d "${dict['mnt_bam_dir']}" \
            -f "${dict['bam_suffix']}" \
            -l "${dict['mnt_output_dir']}/logs" \
            -o "${dict['mnt_output_dir']}/cmpileups" \
            -os "${dict['mnt_output_dir']}/summary"
    return 0
}

koopa_roff() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['ronn']="$(koopa_locate_ronn)"
    )
    [[ -x "${app['ronn']}" ]] || return 1
    declare -A dict=(
        ['man_prefix']="$(koopa_man_prefix)"
    )
    (
        koopa_cd "${dict['man_prefix']}/man1-ronn"
        "${app['ronn']}" --roff ./*'.ronn'
        koopa_mv --target-directory="${dict['man_prefix']}/man1" ./*'.1'
    )
    return 0
}

koopa_rsem_index() {
    local app dict index_args
    declare -A app=(
        ['rsem_prepare_reference']="$(koopa_locate_rsem_prepare_reference)"
    )
    [[ -x "${app['rsem_prepare_reference']}" ]] || return 1
    declare -A dict=(
        ['genome_fasta_file']=''
        ['gtf_file']=''
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=10
        ['output_dir']=''
        ['threads']="$(koopa_cpu_count)"
        ['tmp_dir']="$(koopa_tmp_dir)"
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "RSEM requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    dict['genome_fasta_file']="$(koopa_realpath "${dict['genome_fasta_file']}")"
    dict['gtf_file']="$(koopa_realpath "${dict['gtf_file']}")"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    koopa_alert "Generating RSEM index at '${dict['output_dir']}'."
    dict['build_name']="$(koopa_basename "${dict['output_dir']}")"
    dict['tmp_genome_fasta_file']="${dict['tmp_dir']}/genome.fa"
    koopa_decompress \
        "${dict['genome_fasta_file']}" \
        "${dict['tmp_genome_fasta_file']}"
    dict['tmp_gtf_file']="${dict['tmp_dir']}/annotation.gtf"
    koopa_decompress \
        "${dict['gtf_file']}" \
        "${dict['tmp_gtf_file']}"
    index_args+=(
        '--gtf' "${dict['tmp_gtf_file']}"
        '--num-threads' "${dict['threads']}"
        "${dict['tmp_genome_fasta_file']}"
        "${dict['output_dir']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app['rsem_prepare_reference']}" "${index_args[@]}"
    koopa_rm "${dict['tmp_dir']}"
    koopa_alert_success "RSEM index created at '${dict['output_dir']}'."
    return 0
}

koopa_rsync_ignore() {
    local dict rsync_args
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['ignore_local']='.gitignore'
        ['ignore_global']="${HOME}/.gitignore"
    )
    rsync_args=(
        '--archive'
        '--exclude=.*'
    )
    if [[ -f "${dict['ignore_local']}" ]]
    then
        rsync_args+=(
            "--filter=dir-merge,- ${dict['ignore_local']}"
        )
    fi
    if [[ -f "${dict['ignore_global']}" ]]
    then
        rsync_args+=("--filter=dir-merge,- ${dict['ignore_global']}")
    fi
    koopa_rsync "${rsync_args[@]}" "$@"
    return 0
}

koopa_rsync() {
    local app dict rsync_args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['rsync']="$(koopa_locate_rsync)"
    )
    [[ -x "${app['rsync']}" ]] || return 1
    declare -A dict=(
        ['source_dir']=''
        ['target_dir']=''
    )
    rsync_args=(
        '--human-readable'
        '--progress'
        '--protect-args'
        '--recursive'
        '--stats'
        '--verbose'
    )
    if koopa_is_macos
    then
        rsync_args+=('--iconv=utf-8,utf-8-mac')
    fi
    while (("$#"))
    do
        case "$1" in
            '--exclude='*)
                rsync_args+=("$1")
                shift 1
                ;;
            '--exclude')
                rsync_args+=("--exclude=${2:?}")
                shift 2
                ;;
            '--filter='*)
                rsync_args+=("$1")
                shift 1
                ;;
            '--filter')
                rsync_args+=("--filter=${2:?}")
                shift 2
                ;;
            '--source-dir='*)
                dict['source_dir']="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict['source_dir']="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            '--log-file='*)
                rsync_args+=("$1")
                shift 1
                ;;
            '--archive' | \
            '--copy-links' | \
            '--delete' | \
            '--delete-before' | \
            '--dry-run' | \
            '--size-only')
                rsync_args+=("$1")
                shift 1
                ;;
            '--sudo')
                rsync_args+=('--rsync-path' 'sudo rsync')
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--source-dir' "${dict['source_dir']}" \
        '--target-dir' "${dict['target_dir']}"
    if [[ -d "${dict['source_dir']}" ]]
    then
        dict['source_dir']="$(koopa_realpath "${dict['source_dir']}")"
    fi
    if [[ -d "${dict['target_dir']}" ]]
    then
        dict['target_dir']="$(koopa_realpath "${dict['target_dir']}")"
    fi
    dict['source_dir']="$(koopa_strip_trailing_slash "${dict['source_dir']}")"
    dict['target_dir']="$(koopa_strip_trailing_slash "${dict['target_dir']}")"
    rsync_args+=("${dict['source_dir']}/" "${dict['target_dir']}/")
    koopa_dl 'rsync args' "${rsync_args[*]}"
    "${app['rsync']}" "${rsync_args[@]}"
    return 0
}

koopa_run_if_installed() {
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        local exe
        if ! koopa_is_installed "$arg"
        then
            koopa_alert_note "Skipping '${arg}'."
            continue
        fi
        exe="$(koopa_which_realpath "$arg")"
        "$exe"
    done
    return 0
}

koopa_salmon_detect_fastq_library_type() {
    local app dict quant_args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['head']="$(koopa_locate_head)"
        ['jq']="$(koopa_locate_jq)"
        ['salmon']="$(koopa_locate_salmon)"
    )
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['jq']}" ]] || return 1
    [[ -x "${app['salmon']}" ]] || return 1
    declare -A dict=(
        ['fastq_r1_file']=''
        ['fastq_r2_file']=''
        ['index_dir']=''
        ['lib_type']='A'
        ['n']='400000'
        ['threads']="$(koopa_cpu_count)"
        ['tmp_dir']="$(koopa_tmp_dir)"
    )
    dict['output_dir']="${dict['tmp_dir']}/quant"
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--index-dir' "${dict['index_dir']}"
    koopa_assert_is_file "${dict['fastq_r1_file']}"
    koopa_assert_is_dir "${dict['index_dir']}"
    quant_args=(
        "--index=${dict['index_dir']}"
        "--libType=${dict['lib_type']}"
        '--no-version-check'
        "--output=${dict['output_dir']}"
        '--quiet'
        '--skipQuant'
        "--threads=${dict['threads']}"
    )
    if [[ -n "${dict['fastq_r2_file']}" ]]
    then
        koopa_assert_is_file "${dict['fastq_r2_file']}"
        dict['mates1']="${dict['tmp_dir']}/mates1.fastq"
        dict['mates2']="${dict['tmp_dir']}/mates2.fastq"
        koopa_decompress --stdout "${dict['fastq_r1_file']}" \
            | "${app['head']}" -n "${dict['n']}" \
            > "${dict['mates1']}"
        koopa_decompress --stdout "${dict['fastq_r2_file']}" \
            | "${app['head']}" -n "${dict['n']}" \
            > "${dict['mates2']}"
        quant_args+=(
            "--mates1=${dict['mates1']}"
            "--mates2=${dict['mates2']}"
        )
    else
        dict['unmated_reads']="${dict['tmp_dir']}/reads.fastq"
        koopa_decompress --stdout "${dict['fastq_r1_file']}" \
            | "${app['head']}" -n "${dict['n']}" \
            > "${dict['unmated_reads']}"
        quant_args+=(
            "--unmatedReads=${dict['unmated_reads']}"
        )
    fi
    "${app['salmon']}" quant "${quant_args[@]}" &>/dev/null
    dict['json_file']="${dict['output_dir']}/lib_format_counts.json"
    koopa_assert_is_file "${dict['json_file']}"
    dict['lib_type']="$( \
        "${app['jq']}" --raw-output '.expected_format' "${dict['json_file']}" \
    )"
    koopa_print "${dict['lib_type']}"
    koopa_rm "${dict['tmp_dir']}"
    return 0
}

koopa_salmon_index() {
    local app dict index_args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['salmon']="$(koopa_locate_salmon)"
    )
    [[ -x "${app['salmon']}" ]] || return 1
    declare -A dict=(
        ['decoys']=1
        ['fasta_pattern']='\.fa(sta)?'
        ['gencode']=0
        ['genome_fasta_file']=''
        ['kmer_length']=31
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=14
        ['output_dir']=''
        ['threads']="$(koopa_cpu_count)"
        ['transcriptome_fasta_file']=''
        ['type']='puff'
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--decoys')
                dict['decoys']=1
                shift 1
                ;;
            '--gencode')
                dict['gencode']=1
                shift 1
                ;;
            '--no-decoys')
                dict['decoys']=0
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    [[ "${dict['decoys']}" -eq 1 ]] && dict['mem_gb_cutoff']=30
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "salmon index requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file "${dict['transcriptome_fasta_file']}"
    dict['transcriptome_fasta_file']="$( \
        koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    koopa_assert_is_matching_regex \
        --pattern="${dict['fasta_pattern']}" \
        --string="${dict['transcriptome_fasta_file']}"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Generating salmon index at '${dict['output_dir']}'."
    if [[ "${dict['gencode']}" -eq 0 ]] && \
        koopa_str_detect_regex \
            --string="$(koopa_basename "${dict['transcriptome_fasta_file']}")" \
            --pattern='^gencode\.'
    then
        dict['gencode']=1
    fi
    if [[ "${dict['gencode']}" -eq 1 ]]
    then
        koopa_alert_info 'Indexing against GENCODE reference genome.'
        index_args+=('--gencode')
    fi
    if [[ "${dict['decoys']}" -eq 1 ]]
    then
        koopa_alert 'Preparing decoy-aware reference transcriptome.'
        koopa_assert_is_set \
            '--genome-fasta-file' "${dict['genome_fasta_file']}"
        koopa_assert_is_file "${dict['genome_fasta_file']}"
        dict['genome_fasta_file']="$( \
            koopa_realpath "${dict['genome_fasta_file']}" \
        )"
        koopa_assert_is_matching_regex \
            --pattern="${dict['fasta_pattern']}" \
            --string="${dict['genome_fasta_file']}"
        koopa_assert_is_matching_regex \
            --pattern="${dict['fasta_pattern']}" \
            --string="${dict['transcriptome_fasta_file']}"
        dict['tmp_dir']="$(koopa_tmp_dir)"
        dict['decoys_file']="${dict['tmp_dir']}/decoys.txt"
        dict['gentrome_fasta_file']="${dict['tmp_dir']}/gentrome.fa.gz"
        koopa_fasta_generate_chromosomes_file \
            --genome-fasta-file="${dict['genome_fasta_file']}" \
            --output-file="${dict['decoys_file']}"
        koopa_assert_is_file "${dict['decoys_file']}"
        koopa_fasta_generate_decoy_transcriptome_file \
            --genome-fasta-file="${dict['genome_fasta_file']}" \
            --output-file="${dict['gentrome_fasta_file']}" \
            --transcriptome-fasta-file="${dict['transcriptome_fasta_file']}"
        koopa_assert_is_file "${dict['gentrome_fasta_file']}"
        index_args+=(
            "--decoys=${dict['decoys_file']}"
            "--transcripts=${dict['gentrome_fasta_file']}"
        )
    else
        index_args+=(
            "--transcripts=${dict['transcriptome_fasta_file']}"
        )
    fi
    index_args+=(
        "--index=${dict['output_dir']}"
        "--kmerLen=${dict['kmer_length']}"
        '--no-version-check'
        "--threads=${dict['threads']}"
        "--type=${dict['type']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app['salmon']}" index "${index_args[@]}"
    koopa_alert_success "salmon index created at '${dict['output_dir']}'."
    return 0
}

koopa_salmon_quant_paired_end_per_sample() {
    local app dict quant_args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['salmon']="$(koopa_locate_salmon)"
    )
    [[ -x "${app['salmon']}" ]] || return 1
    declare -A dict=(
        ['bootstraps']=30
        ['fastq_r1_file']=''
        ['fastq_r1_tail']=''
        ['fastq_r2_file']=''
        ['fastq_r2_tail']=''
        ['index_dir']=''
        ['lib_type']='A'
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=14
        ['output_dir']=''
        ['threads']="$(koopa_cpu_count)"
    )
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--fastq-r2-tail' "${dict['fastq_r2_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "salmon quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
    dict['fastq_r1_file']="$(koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="${dict['fastq_r1_bn']/${dict['fastq_r1_tail']}/}"
    dict['fastq_r2_file']="$(koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="$(koopa_basename "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="${dict['fastq_r2_bn']/${dict['fastq_r2_tail']}/}"
    koopa_assert_are_identical "${dict['fastq_r1_bn']}" "${dict['fastq_r2_bn']}"
    dict['id']="${dict['fastq_r1_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    quant_args+=(
        '--gcBias' # Recommended for DESeq2.
        "--index=${dict['index_dir']}"
        "--libType=${dict['lib_type']}"
        "--mates1=${dict['fastq_r1_file']}"
        "--mates2=${dict['fastq_r2_file']}"
        '--no-version-check'
        "--numBootstraps=${dict['bootstraps']}"
        "--output=${dict['output_dir']}"
        '--seqBias'
        "--threads=${dict['threads']}"
        '--useVBOpt'
    )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['salmon']}" quant "${quant_args[@]}"
    return 0
}

koopa_salmon_quant_paired_end() {
    local dict fastq_r1_files fastq_r1_file
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['fastq_dir']=''
        ['fastq_r1_tail']=''
        ['fastq_r2_tail']=''
        ['index_dir']=''
        ['lib_type']='A'
        ['mode']='paired-end'
        ['output_dir']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-tail' "${dict['fastq_r1_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running salmon quant.'
    koopa_dl \
        'Mode' "${dict['mode']}" \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_r1_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local fastq_r2_file
        fastq_r2_file="${fastq_r1_file/\
${dict['fastq_r1_tail']}/${dict['fastq_r2_tail']}}"
        koopa_salmon_quant_paired_end_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict['fastq_r1_tail']}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict['fastq_r2_tail']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict['output_dir']}"
    done
    koopa_alert_success 'salmon quant was successful.'
    return 0
}

koopa_salmon_quant_single_end_per_sample() {
    local app dict quant_args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['salmon']="$(koopa_locate_salmon)"
    )
    [[ -x "${app['salmon']}" ]] || return 1
    declare -A dict=(
        ['bootstraps']=30
        ['fastq_file']=''
        ['fastq_tail']=''
        ['index_dir']=''
        ['lib_type']='A'
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=14
        ['output_dir']=''
        ['threads']="$(koopa_cpu_count)"
    )
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict['fastq_file']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "salmon quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_file']}"
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
    dict['fastq_bn']="${dict['fastq_bn']/${dict['tail']}/}"
    dict['id']="${dict['fastq_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    quant_args+=(
        "--index=${dict['index_dir']}"
        "--libType=${dict['lib_type']}"
        "--numBootstraps=${dict['bootstraps']}"
        '--no-version-check'
        "--output=${dict['output_dir']}"
        '--seqBias'
        "--threads=${dict['threads']}"
        "--unmatedReads=${dict['fastq']}"
        '--useVBOpt'
    )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['salmon']}" quant "${quant_args[@]}"
    return 0
}

koopa_salmon_quant_single_end() {
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['fastq_dir']=''
        ['fastq_tail']=''
        ['index_dir']=''
        ['lib_type']='A'
        ['mode']='single-end'
        ['output_dir']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running salmon quant.'
    koopa_dl \
        'Mode' "${dict['mode']}" \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ tail' "${dict['fastq_tail']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_tail']}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_file in "${fastq_files[@]}"
    do
        koopa_salmon_quant_single_end_per_sample \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict['fastq_tail']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict['output_dir']}"
    done
    koopa_alert_success 'salmon quant was successful.'
    return 0
}

koopa_sambamba_filter_per_sample() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app
    app['sambamba']="$(koopa_locate_sambamba)"
    [[ -x "${app['sambamba']}" ]] || return 1
    declare -A dict=(
        ['filter']=''
        ['input']=''
        ['output']=''
        ['threads']="$(koopa_cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            '--filter='*)
                dict['filter']="${1#*=}"
                shift 1
                ;;
            '--filter')
                dict['filter']="${2:?}"
                shift 2
                ;;
            '--input-bam='*)
                dict['input']="${1#*=}"
                shift 1
                ;;
            '--input-bam')
                dict['input']="${2:?}"
                shift 2
                ;;
            '--output-bam='*)
                dict['output']="${1#*=}"
                shift 1
                ;;
            '--output-bam')
                dict['output']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--filter' "${dict['filter']}" \
        '--intput-bam' "${dict['input']}" \
        '--output-bam' "${dict['output']}"
    koopa_assert_is_file "${dict['input']}"
    koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${dict['input']}"
    koopa_assert_are_not_identical "${dict['input']}" "${dict['output']}"
    dict['input_bn']="$(koopa_basename "${dict['input']}")"
    dict['output_bn']="$(koopa_basename "${dict['output']}")"
    if [[ -f "${dict['output']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_bn']}'."
        return 0
    fi
    koopa_alert "Filtering '${dict['input_bn']}' to '${dict['output_bn']}'."
    koopa_dl 'Filter' "${dict['filter']}"
    "${app['sambamba']}" view \
        --filter="${dict['filter']}" \
        --format='bam' \
        --nthreads="${dict['threads']}" \
        --output-filename="${dict['output']}" \
        --show-progress \
        --with-header \
        "${dict['input']}"
    return 0
}

koopa_sambamba_filter() {
    local bam_file bam_files dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        ['pattern']='*.sorted.bam'
        ['prefix']="${1:?}"
    )
    koopa_assert_is_dir "${dict['prefix']}"
    readarray -t bam_files <<< "$( \
        koopa_find \
            --max-depth=3 \
            --min-depth=1 \
            --pattern="${dict['pattern']}" \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='f' \
    )"
    if ! koopa_is_array_non_empty "${bam_files[@]:-}"
    then
        koopa_stop "No BAM files detected in '${dict['prefix']}' matching \
pattern '${dict['pattern']}'."
    fi
    koopa_alert "Filtering BAM files in '${dict['prefix']}'."
    for bam_file in "${bam_files[@]}"
    do
        local dict2
        declare -A dict2
        dict2['input']="$bam_file"
        dict2['bn']="$(koopa_basename_sans_ext "${dict2['input']}")"
        dict2['prefix']="$(koopa_parent_dir "${dict['input']}")"
        dict2['stem']="${dict2['prefix']}/${dict2['bn']}"
        dict2['output']="${dict2['stem']}.filtered.bam"
        if [[ -f "${dict2['output']}" ]]
        then
            koopa_alert_note "Skipping '${dict2['output']}'."
            continue
        fi
        dict2['file_1']="${dict2['stem']}.filtered-1-no-duplicates.bam"
        dict2['file_2']="${dict2['stem']}.filtered-2-no-unmapped.bam"
        dict2['file_3']="${dict2['stem']}.filtered-3-no-multimappers.bam"
        koopa_sambamba_filter_per_sample \
            --filter='not duplicate' \
            --input-bam="${dict2['input']}" \
            --output-bam="${dict2['file_1']}"
        koopa_sambamba_filter_per_sample \
            --filter='not unmapped' \
            --input-bam="${dict2['file_1']}" \
            --output-bam="${dict2['file_2']}"
        koopa_sambamba_filter_per_sample \
            --filter='[XS] == null' \
            --input-bam="${dict2['file_2']}" \
            --output-bam="${dict2['file_3']}"
        koopa_cp "${dict2['file_3']}" "${dict2['output']}"
        koopa_sambamba_index "${dict2['output']}"
    done
    return 0
}

koopa_sambamba_index() {
    local app bam_file dict
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    declare -A app
    app['sambamba']="$(koopa_locate_sambamba)"
    [[ -x "${app['sambamba']}" ]] || return 1
    declare -A dict
    dict['threads']="$(koopa_cpu_count)"
    for bam_file in "$@"
    do
        koopa_assert_is_matching_regex \
            --pattern='\.bam$' \
            --string="$bam_file"
        koopa_alert "Indexing '${bam_file}'."
        "${app['sambamba']}" index \
            --nthreads="${dict['threads']}" \
            --show-progress \
            "$bam_file"
    done
    return 0
}

koopa_sambamba_sort_per_sample() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app
    app['sambamba']="$(koopa_locate_sambamba)"
    [[ -x "${app['sambamba']}" ]] || return 1
    declare -A dict=(
        ['input']="${1:?}"
        ['threads']="$(koopa_cpu_count)"
    )
    koopa_assert_is_file "${dict['input']}"
    koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${dict['input']}"
    dict['output']="${dict['input']%.bam}.sorted.bam"
    dict['input_bn']="$(koopa_basename "${dict['input']}")"
    dict['output_bn']="$(koopa_basename "${dict['output']}")"
    if [[ -f "${dict['output']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_bn']}'."
        return 0
    fi
    koopa_alert "Sorting '${dict['input_bn']}' to '${dict['output_bn']}'."
    "${app['sambamba']}" sort \
        --memory-limit='2GB' \
        --nthreads="${dict['threads']}" \
        --out="${dict['output']}" \
        --show-progress \
        "${dict['input']}"
    return 0
}

koopa_sambamba_sort() {
    local bam_file bam_files dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict
    dict['prefix']="${1:?}"
    koopa_assert_is_dir "${dict['prefix']}"
    readarray -t bam_files <<< "$( \
        koopa_find \
            --exclude='*.filtered.*' \
            --exclude='*.sorted.*' \
            --max-depth=3 \
            --min-depth=1 \
            --pattern='*.bam' \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='f' \
    )"
    if ! koopa_is_array_non_empty "${bam_files[@]:-}"
    then
        koopa_stop "No BAM files detected in '${dict['prefix']}'."
    fi
    koopa_alert "Sorting BAM files in '${dict['prefix']}'."
    for bam_file in "${bam_files[@]}"
    do
        koopa_sambamba_sort_per_sample "$bam_file"
    done
    return 0
}

koopa_samtools_convert_sam_to_bam() {
    local bam_bn input_sam output_bam sam_bn threads
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'samtools'
    while (("$#"))
    do
        case "$1" in
            '--input-sam='*)
                input_sam="${1#*=}"
                shift 1
                ;;
            '--input-sam')
                input_sam="${2:?}"
                shift 2
                ;;
            '--output-bam='*)
                output_bam="${1#*=}"
                shift 1
                ;;
            '--output-bam')
                output_bam="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--input-sam' "$input_sam" \
        '--output-bam' "$output_bam"
    sam_bn="$(koopa_basename "$input_sam")"
    bam_bn="$(koopa_basename "$output_bam")"
    if [[ -f "$output_bam" ]]
    then
        koopa_alert_note "Skipping '${bam_bn}'."
        return 0
    fi
    koopa_h2 "Converting '${sam_bn}' to '${bam_bn}'."
    koopa_assert_is_file "$input_sam"
    threads="$(koopa_cpu_count)"
    koopa_dl 'Threads' "$threads"
    "${app['samtools']}" view \
        -@ "$threads" \
        -b \
        -h \
        -o "$output_bam" \
        "$input_sam"
    return 0
}

koopa_sanitize_version() {
    local str
    koopa_assert_has_args "$#"
    for str in "$@"
    do
        koopa_str_detect_regex \
            --string="$str" \
            --pattern='[.0-9]+' \
            || return 1
        str="$( \
            koopa_sub \
                --pattern='^([.0-9]+).*$' \
                --regex \
                --replacement='\1' \
                "$str" \
        )"
        koopa_print "$str"
    done
    return 0
}

koopa_script_name() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    declare -A dict
    dict['file']="$( \
        caller \
        | "${app['head']}" -n 1 \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    dict['bn']="$(koopa_basename "${dict['file']}")"
    [[ -n "${dict['bn']}" ]] || return 0
    koopa_print "${dict['bn']}"
    return 0
}

koopa_shared_ext() {
    local str
    if koopa_is_macos
    then
        str='dylib'
    else
        str='so'
    fi
    koopa_print "$str"
    return 0
}

koopa_snake_case_simple() {
    local str
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        [[ -n "$str" ]] || return 1
        str="$( \
            koopa_gsub \
                --pattern='[^A-Za-z0-9_]' \
                --regex \
                --replacement='_' \
                "$str" \
        )"
        str="$(koopa_lowercase "$str")"
        koopa_print "$str"
    done
    return 0
}

koopa_snake_case() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliSnakeCase' "$@"
}

koopa_sort_lines() {
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        ['vim']="$(koopa_locate_vim)"
    )
    [[ -x "${app['vim']}" ]] || return 1
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app['vim']}" \
            -c ':sort' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}

koopa_source_dir() {
    local file prefix
    koopa_assert_has_args_eq "$#" 1
    prefix="${1:?}"
    koopa_assert_is_dir "$prefix"
    for file in "${prefix}/"*'.sh'
    do
        [[ -f "$file" ]] || continue
        . "$file"
    done
    return 0
}

koopa_spell() {
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        ['aspell']="$(koopa_locate_aspell)"
        ['tail']="$(koopa_locate_tail)"
    )
    [[ -x "${app['aspell']}" ]] || return 1
    [[ -x "${app['tail']}" ]] || return 1
    koopa_print "$@" \
        | "${app['aspell']}" pipe \
        | "${app['tail']}" -n '+2'
    return 0
}

koopa_sra_download_accession_list() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut)"
        ['efetch']="$(koopa_locate_efetch)"
        ['esearch']="$(koopa_locate_esearch)"
        ['sed']="$(koopa_locate_sed)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['efetch']}" ]] || return 1
    [[ -x "${app['esearch']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict=(
        ['acc_file']=''
        ['srp_id']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['acc_file']+=("${1#*=}")
                shift 1
                ;;
            '--file')
                dict['acc_file']+=("${2:?}")
                shift 2
                ;;
            '--srp-id='*)
                dict['srp_id']="${1#*=}"
                shift 1
                ;;
            '--srp-id')
                dict['srp_id']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--srp-id' "${dict['srp_id']}"
    if [[ -z "${dict['acc_file']}" ]]
    then
        dict['acc_file']="$(koopa_lowercase "${dict['srp_id']}")-\
accession-list.txt"
    fi
    koopa_alert "Downloading SRA accession list for '${dict['srp_id']}' \
to '${dict['acc_file']}'."
    "${app['esearch']}" -db 'sra' -query "${dict['srp_id']}" \
        | "${app['efetch']}" -format 'runinfo' \
        | "${app['sed']}" '1d' \
        | "${app['cut']}" -d ',' -f '1' \
        > "${dict['acc_file']}"
    return 0
}

koopa_sra_download_run_info_table() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['efetch']="$(koopa_locate_efetch)"
        ['esearch']="$(koopa_locate_esearch)"
    )
    [[ -x "${app['efetch']}" ]] || return 1
    [[ -x "${app['esearch']}" ]] || return 1
    declare -A dict=(
        ['run_info_file']=''
        ['srp_id']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['run_info_file']+=("${1#*=}")
                shift 1
                ;;
            '--file')
                dict['run_info_file']+=("${2:?}")
                shift 2
                ;;
            '--srp-id='*)
                dict['srp_id']="${1#*=}"
                shift 1
                ;;
            '--srp-id')
                dict['srp_id']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--srp-id' "${dict['srp_id']}"
    if [[ -z "${dict['run_info_file']}" ]]
    then
        dict['run_info_file']="$(koopa_lowercase "${dict['srp_id']}")-\
run-info-table.csv"
    fi
    koopa_alert "Downloading SRA run info table for '${dict['srp_id']}' \
to '${dict['run_info_file']}'."
    "${app['esearch']}" -db 'sra' -query "${dict['srp_id']}" \
        | "${app['efetch']}" -format 'runinfo' \
        > "${dict['run_info_file']}"
    return 0
}

koopa_sra_fastq_dump() {
    local app dict sra_file sra_files
    declare -A app=(
        ['fasterq_dump']="$(koopa_locate_fasterq_dump)"
        ['gzip']="$(koopa_locate_gzip)"
        ['parallel']="$(koopa_locate_parallel)"
    )
    [[ -x "${app['fasterq_dump']}" ]] || return 1
    [[ -x "${app['gzip']}" ]] || return 1
    [[ -x "${app['parallel']}" ]] || return 1
    declare -A dict=(
        ['acc_file']=''
        ['compress']=1
        ['fastq_dir']='fastq'
        ['prefetch_dir']='sra'
        ['threads']="$(koopa_cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            '--accession-file='*)
                dict['acc_file']="${1#*=}"
                shift 1
                ;;
            '--accession-file')
                dict['acc_file']="${2:?}"
                shift 2
                ;;
            '--fastq-directory='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-directory')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--prefetch-directory='*)
                dict['prefetch_dir']="${1#*=}"
                shift 1
                ;;
            '--prefetch-directory')
                dict['prefetch_dir']="${2:?}"
                shift 2
                ;;
            '--compress')
                dict['compress']=1
                shift 1
                ;;
            '--no-compress')
                dict['compress']=0
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set \
        '--accession-file' "${dict['acc_file']}" \
        '--fastq-directory' "${dict['fastq_dir']}" \
        '--prefetch-directory' "${dict['prefetch_dir']}"
    koopa_assert_is_file "${dict['acc_file']}"
    if [[ ! -d "${dict['prefetch_dir']}" ]]
    then
        koopa_sra_prefetch_parallel \
            --accession-file="${acc_file}" \
            --output-directory="${dict['prefetch_dir']}"
    fi
    koopa_assert_is_dir "${dict['prefetch_dir']}"
    koopa_alert "Extracting FASTQ to '${dict['fastq_dir']}'."
    readarray -t sra_files <<< "$(
        koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --pattern='*.sra' \
            --prefix="${dict['prefetch_dir']}" \
            --sort \
            --type='f' \
    )"
    koopa_assert_is_array_non_empty "${sra_files[@]:-}"
    for sra_file in "${sra_files[@]}"
    do
        local id
        id="$(koopa_basename_sans_ext "$sra_file")"
        if [[ ! -f "${dict['fastq_dir']}/${id}.fastq" ]] && \
            [[ ! -f "${dict['fastq_dir']}/${id}_1.fastq" ]] && \
            [[ ! -f "${dict['fastq_dir']}/${id}.fastq.gz" ]] && \
            [[ ! -f "${dict['fastq_dir']}/${id}_1.fastq.gz" ]]
        then
            koopa_alert "Extracting FASTQ in '${sra_file}'."
            "${app['fasterq_dump']}" \
                --details \
                --force \
                --outdir "${dict['fastq_dir']}" \
                --print-read-nr \
                --progress \
                --skip-technical \
                --split-3 \
                --strict \
                --threads "${dict['threads']}" \
                --verbose \
                "$sra_file"
        fi
    done
    if [[ "${dict['compress']}" -eq 1 ]]
    then
        koopa_alert 'Compressing FASTQ files.'
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.fastq' \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
        | "${app['parallel']}" \
            --bar \
            --eta \
            --jobs "${dict['threads']}" \
            --progress \
            --will-cite \
            "${app['gzip']} --force --verbose {}"
    fi
    return 0
}

koopa_sra_prefetch() {
    local app cmd dict
    declare -A app=(
        ['parallel']="$(koopa_locate_parallel)"
        ['prefetch']="$(koopa_locate_prefetch)"
    )
    [[ -x "${app['parallel']}" ]] || return 1
    [[ -x "${app['prefetch']}" ]] || return 1
    declare -A dict=(
        ['acc_file']=''
        ['jobs']="$(koopa_cpu_count)"
        ['output_dir']='sra'
    )
    while (("$#"))
    do
        case "$1" in
            '--accession-file='*)
                dict['acc_file']="${1#*=}"
                shift 1
                ;;
            '--accession-file')
                dict['acc_file']="${2:?}"
                shift 2
                ;;
            '--output-directory='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-directory')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set \
        '--accession-file' "${dict['acc_file']}" \
        '--output-directory' "${dict['output_dir']}"
    koopa_assert_is_file "${dict['acc_file']}"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Prefetching SRA files to '${dict['output_dir']}'."
    cmd=(
        "${app['prefetch']}"
        '--force' 'no'
        '--output-directory' "${dict['output_dir']}"
        '--progress'
        '--resume' 'yes'
        '--type' 'sra'
        '--verbose'
        '--verify' 'yes'
        '{}'
    )
    "${app['parallel']}" \
        --arg-file "${dict['acc_file']}" \
        --bar \
        --eta \
        --jobs "${dict['jobs']}" \
        --progress \
        --will-cite \
        "${cmd[*]}"
    return 0
}

koopa_ssh_generate_key() {
    local app dict ssh_args
    declare -A app=(
        ['ssh_keygen']="$(koopa_locate_ssh_keygen)"
    )
    [[ -x "${app['ssh_keygen']}" ]] || return 1
    declare -A dict=(
        ['hostname']="$(koopa_hostname)"
        ['key_name']='id_rsa' # or 'id_ed25519'.
        ['prefix']="${HOME:?}/.ssh"
        ['user']="$(koopa_user)"
    )
    while (("$#"))
    do
        case "$1" in
            '--key-name='*)
                dict['key_name']="${1#*=}"
                shift 1
                ;;
            '--key-name')
                dict['key_name']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    file="${dict['prefix']}/${dict['key_name']}"
    if [[ -f "${dict['file']}" ]]
    then
        koopa_alert_note "SSH key exists at '${dict['file']}'."
        return 0
    fi
    koopa_alert "Generating SSH key at '${dict['file']}'."
    ssh_args=(
        '-C' "${dict['user']}@${dict['hostname']}"
        '-N' ''
        '-f' "${dict['file']}"
        '-q'
    )
    case "${dict['key_name']}" in
        *'_ed25519')
            ssh_args+=(
                '-a' 100
                '-o'
                '-t' 'ed25519'
            )
            ;;
        *'_rsa')
            ssh_args+=(
                '-b' 4096
                '-t' 'rsa'
            )
            ;;
        *)
            koopa_stop "Unsupported key: '${dict['key_name']}'."
            ;;
    esac
    koopa_dl \
        'ssh-keygen' "${app['ssh_keygen']}" \
        'args' "${ssh_args[*]}"
    "${app['ssh_keygen']}" "${ssh_args[@]}"
    koopa_alert_success "Generated SSH key at '${dict['file']}'."
    return 0
}

koopa_ssh_key_info() {
    local app dict keyfile
    declare -A app=(
        ['ssh_keygen']="$(koopa_locate_ssh_keygen)"
        ['uniq']="$(koopa_locate_uniq)"
    )
    [[ -x "${app['ssh_keygen']}" ]] || return 1
    [[ -x "${app['uniq']}" ]] || return 1
    declare -A dict=(
        ['prefix']="${HOME:?}/.ssh"
        ['stem']='id_'
    )
    for keyfile in "${dict['prefix']}/${dict['stem']}"*
    do
        "${app['ssh_keygen']}" -l -f "$keyfile"
    done | "${app['uniq']}"
    return 0
}

koopa_star_align_paired_end_per_sample() {
    local align_args app dict
    declare -A app=(
        ['star']="$(koopa_locate_star)"
    )
    [[ -x "${app['star']}" ]] || return 1
    declare -A dict=(
        ['fastq_r1_file']=''
        ['fastq_r1_tail']=''
        ['fastq_r2_file']=''
        ['fastq_r2_tail']=''
        ['index_dir']=''
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=14
        ['output_dir']=''
        ['threads']="$(koopa_cpu_count)"
    )
    align_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--fastq-r2-tail' "${dict['fastq_r2_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "STAR 'alignReads' mode requires ${dict['mem_gb_cutoff']} \
GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
    dict['fastq_r1_file']="$(koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="${dict['fastq_r1_bn']/${dict['fastq_r1_tail']}/}"
    dict['fastq_r2_file']="$(koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="$(koopa_basename "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="${dict['fastq_r2_bn']/${dict['fastq_r2_tail']}/}"
    koopa_assert_are_identical "${dict['fastq_r1_bn']}" "${dict['fastq_r2_bn']}"
    dict['id']="${dict['fastq_r1_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    align_args+=(
        '--genomeDir' "${dict['index_dir']}"
        '--outFileNamePrefix' "${dict['output_dir']}/"
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--runMode' 'alignReads'
        '--runThreadN' "${dict['threads']}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['star']}" "${align_args[@]}" \
        --readFilesIn \
            <(koopa_decompress --stdout "${dict['fastq_r1_file']}") \
            <(koopa_decompress --stdout "${dict['fastq_r2_file']}")
    return 0
}

koopa_star_align_paired_end() {
    local dict fastq_r1_files fastq_r1_file
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['fastq_dir']=''
        ['fastq_r1_tail']=''
        ['fastq_r2_tail']=''
        ['index_dir']=''
        ['mode']='paired-end'
        ['output_dir']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-tail' "${dict['fastq_r1_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running STAR aligner.'
    koopa_dl \
        'Mode' "${dict['mode']}" \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_r1_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local fastq_r2_file
        fastq_r2_file="${fastq_r1_file/\
${dict['fastq_r1_tail']}/${dict['fastq_r2_tail']}}"
        koopa_star_align_paired_end_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict['fastq_r1_tail']}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict['fastq_r2_tail']}" \
            --index-dir="${dict['index_dir']}" \
            --output-dir="${dict['output_dir']}"
    done
    koopa_alert_success 'STAR alignment was successful.'
    return 0
}

koopa_star_align_single_end_per_sample() {
    local align_args app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['star']="$(koopa_locate_star)"
    )
    [[ -x "${app['star']}" ]] || return 1
    declare -A dict=(
        ['fastq_file']=''
        ['fastq_tail']=''
        ['index_dir']=''
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=14
        ['output_dir']=''
        ['threads']="$(koopa_cpu_count)"
    )
    align_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict['fastq_file']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "STAR 'alignReads' mode requires ${dict['mem_gb_cutoff']} \
GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_file']}"
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
    dict['fastq_bn']="${dict['fastq_bn']/${dict['tail']}/}"
    dict['id']="${dict['fastq_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    align_args+=(
        '--genomeDir' "${dict['index_dir']}"
        '--outFileNamePrefix' "${dict['output_dir']}/"
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--runMode' 'alignReads'
        '--runThreadN' "${dict['threads']}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['star']}" "${align_args[@]}" \
        --readFilesIn \
            <(koopa_decompress --stdout "${dict['fastq_file']}")
    return 0
}

koopa_star_align_single_end() {
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['fastq_dir']=''
        ['fastq_tail']=''
        ['index_dir']=''
        ['mode']='single-end'
        ['output_dir']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running STAR aligner.'
    koopa_dl \
        'Mode' "${dict['mode']}" \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ tail' "${dict['fastq_tail']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_tail']}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_file in "${fastq_files[@]}"
    do
        koopa_star_align_single_end_per_sample \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict['fastq_tail']}" \
            --index-dir="${dict['index_dir']}" \
            --output-dir="${dict['output_dir']}"
    done
    koopa_alert_success 'STAR alignment was successful.'
    return 0
}

koopa_star_index() {
    local app dict index_args
    declare -A app=(
        ['star']="$(koopa_locate_star)"
    )
    [[ -x "${app['star']}" ]] || return 1
    declare -A dict=(
        ['genome_fasta_file']=''
        ['gtf_file']=''
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=60
        ['output_dir']=''
        ['threads']="$(koopa_cpu_count)"
        ['tmp_dir']="$(koopa_tmp_dir)"
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "STAR 'genomeGenerate' mode requires \
${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    dict['genome_fasta_file']="$(koopa_realpath "${dict['genome_fasta_file']}")"
    dict['gtf_file']="$(koopa_realpath "${dict['gtf_file']}")"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    koopa_alert "Generating STAR index at '${dict['output_dir']}'."
    dict['build_name']="$(koopa_basename "${dict['output_dir']}")"
    dict['tmp_genome_fasta_file']="${dict['tmp_dir']}/genome.fa"
    koopa_decompress \
        "${dict['genome_fasta_file']}" \
        "${dict['tmp_genome_fasta_file']}"
    dict['tmp_gtf_file']="${dict['tmp_dir']}/annotation.gtf"
    koopa_decompress \
        "${dict['gtf_file']}" \
        "${dict['tmp_gtf_file']}"
    index_args+=(
        '--genomeDir' "${dict['build_name']}/"
        '--genomeFastaFiles' "${dict['tmp_genome_fasta_file']}"
        '--runMode' 'genomeGenerate'
        '--runThreadN' "${dict['threads']}"
        '--sjdbGTFfile' "${dict['tmp_gtf_file']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    (
        koopa_cd "${dict['tmp_dir']}"
        "${app['star']}" "${index_args[@]}"
        koopa_cp "${dict['build_name']}" "${dict['output_dir']}"
    )
    koopa_alert_success "STAR index created at '${dict['output_dir']}'."
    return 0
}

koopa_stat_access_human() {
    koopa_stat '%A' "$@"
}

koopa_stat_access_octal() {
    koopa_stat '%a' "$@"
}

koopa_stat_dereference() {
    koopa_stat '%N' "$@"
}

koopa_stat_group() {
    koopa_stat '%G' "$@"
}

koopa_stat_modified() {
    local app dict timestamp timestamps x
    koopa_assert_has_args_ge "$#" 2
    declare -A app=(
        ['date']="$(koopa_locate_date)"
    )
    [[ -x "${app['date']}" ]] || return 1
    declare -A dict=(
        ['format']="${1:?}"
    )
    shift 1
    readarray -t timestamps <<< "$(koopa_stat '%Y' "$@")"
    for timestamp in "${timestamps[@]}"
    do
        x="$("${app['date']}" -d "@${timestamp}" +"${dict['format']}")"
        [[ -n "$x" ]] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_stat_user() {
    koopa_stat '%u' "$@"
}

koopa_stat() {
    local app dict
    koopa_assert_has_args_ge "$#" 2
    declare -A app
    app['stat']="$(koopa_locate_stat --allow-system)"
    [[ -x "${app['stat']}" ]] || return 1
    declare -A dict=(
        ['format']="${1:?}"
    )
    shift 1
    dict['out']="$("${app['stat']}" -c "${dict['format']}" "$@")"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}

koopa_status_fail() {
    __koopa_status 'FAIL' 'red' "$@" >&2
}

koopa_status_note() {
    __koopa_status 'NOTE' 'yellow' "$@"
}

koopa_status_ok() {
    __koopa_status 'OK' 'green' "$@"
}

koopa_stop() {
    __koopa_msg 'red-bold' 'red' '!! Error:' "$@" >&2
    exit 1
}

koopa_str_detect_fixed() {
    __koopa_str_detect --mode='fixed' "$@"
}

koopa_str_detect_regex() {
    __koopa_str_detect --mode='regex' "$@"
}

koopa_strip_left() {
    local dict pos str
    declare -A dict=(
        ['pattern']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict['pattern']}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    for str in "$@"
    do
        printf '%s\n' "${str##"${dict['pattern']}"}"
    done
    return 0
}

koopa_strip_right() {
    local dict pos str
    declare -A dict=(
        ['pattern']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict['pattern']}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    for str in "$@"
    do
        printf '%s\n' "${str%%"${dict['pattern']}"}"
    done
    return 0
}

koopa_strip_trailing_slash() {
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    koopa_strip_right --pattern='/' "$@"
    return 0
}

koopa_sub() {
    local app dict pos
    declare -A app
    app['perl']="$(koopa_locate_perl --allow-system)"
    [[ -x "${app['perl']}" ]] || return 1
    declare -A dict=(
        ['global']=0
        ['pattern']=''
        ['perl_tail']=''
        ['regex']=0
        ['replacement']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--replacement='*)
                dict['replacement']="${1#*=}"
                shift 1
                ;;
            '--replacement')
                dict['replacement']="${2:-}"
                shift 2
                ;;
            '--fixed')
                dict['regex']=0
                shift 1
                ;;
            '--global')
                dict['global']=1
                shift 1
                ;;
            '--regex')
                dict['regex']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict['pattern']}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    [[ "${dict['global']}" -eq 1 ]] && dict['perl_tail']='g'
    if [[ "${dict['regex']}" -eq 1 ]]
    then
        dict['expr']="s|${dict['pattern']}|${dict['replacement']}|\
${dict['perl_tail']}"
    else
        dict['expr']=" \
            \$pattern = quotemeta '${dict['pattern']}'; \
            \$replacement = '${dict['replacement']}'; \
            s/\$pattern/\$replacement/${dict['perl_tail']}; \
        "
    fi
    printf '%s' "$@" | \
        LANG=C "${app['perl']}" -p -e "${dict['expr']}"
    return 0
}

koopa_sudo_append_string() {
    local app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        ['sudo']="$(koopa_locate_sudo)"
        ['tee']="$(koopa_locate_tee --allow-system)"
    )
    [[ -x "${app['sudo']}" ]] || return 1
    [[ -x "${app['tee']}" ]] || return 1
    declare -A dict=(
        ['file']=''
        ['string']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--string' "${dict['string']}"
    dict['parent_dir']="$(koopa_dirname "${dict['file']}")"
    if [[ ! -d "${dict['parent_dir']}" ]]
    then
        koopa_mkdir --sudo "${dict['parent_dir']}"
    fi
    if [[ ! -f "${dict['file']}" ]]
    then
        koopa_touch --sudo "${dict['file']}"
    fi
    koopa_print "${dict['string']}" \
        | "${app['sudo']}" "${app['tee']}" -a "${dict['file']}" >/dev/null
    return 0
}

koopa_sudo_write_string() {
    local app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        ['sudo']="$(koopa_locate_sudo)"
        ['tee']="$(koopa_locate_tee --allow-system)"
    )
    [[ -x "${app['sudo']}" ]] || return 1
    [[ -x "${app['tee']}" ]] || return 1
    declare -A dict=(
        ['file']=''
        ['string']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--string' "${dict['string']}"
    dict['parent_dir']="$(koopa_dirname "${dict['file']}")"
    if [[ ! -d "${dict['parent_dir']}" ]]
    then
        koopa_mkdir --sudo "${dict['parent_dir']}"
    fi
    if [[ ! -f "${dict['file']}" ]]
    then
        koopa_touch --sudo "${dict['file']}"
    fi
    koopa_print "${dict['string']}" \
        | "${app['sudo']}" "${app['tee']}" "${dict['file']}" >/dev/null
    return 0
}

koopa_switch_to_develop() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    declare -A dict=(
        ['branch']='develop'
        ['origin']='origin'
        ['prefix']="$(koopa_koopa_prefix)"
        ['user']="$(koopa_user)"
    )
    koopa_alert "Switching koopa at '${dict['prefix']}' to '${dict['branch']}'."
    if koopa_is_shared_install
    then
        koopa_chown --recursive --sudo "${dict['user']}" "${dict['prefix']}"
    fi
    koopa_sys_set_permissions --recursive "${dict['prefix']}"
    (
        koopa_cd "${dict['prefix']}"
        "${app['git']}" remote set-branches \
            --add "${dict['origin']}" "${dict['branch']}"
        "${app['git']}" fetch "${dict['origin']}"
        "${app['git']}" checkout --track "${dict['origin']}/${dict['branch']}"
    )
    koopa_sys_set_permissions --recursive "${dict['prefix']}"
    koopa_fix_zsh_permissions
    return 0
}

koopa_sys_group() {
    local group
    koopa_assert_has_no_args "$#"
    if koopa_is_shared_install
    then
        group="$(koopa_admin_group)"
    else
        group="$(koopa_group)"
    fi
    koopa_print "$group"
    return 0
}

koopa_sys_ln() {
    local dict
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        ['source']="${1:?}"
        ['target']="${2:?}"
    )
    koopa_rm "${dict['target']}"
    koopa_ln "${dict['source']}" "${dict['target']}"
    koopa_sys_set_permissions --no-dereference "${dict['target']}"
    return 0
}

koopa_sys_mkdir() {
    koopa_assert_has_args "$#"
    koopa_mkdir "$@"
    koopa_sys_set_permissions "$@"
    return 0
}

koopa_sys_set_permissions() {
    koopa_assert_has_args "$#"
    local arg chmod_args chown_args dict pos
    declare -A dict=(
        ['dereference']=1
        ['recursive']=0
        ['shared']=1
    )
    chmod_args=()
    chown_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--dereference' | \
            '-H')
                dict['dereference']=1
                shift 1
                ;;
            '--no-dereference' | \
            '-h')
                dict['dereference']=0
                shift 1
                ;;
            '--recursive' | \
            '-R' | \
            '-r')
                dict['recursive']=1
                shift 1
                ;;
            '--user' | \
            '-u')
                dict['shared']=0
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    case "${dict['shared']}" in
        '0')
            dict['group']="$(koopa_group)"
            dict['user']="$(koopa_user)"
            ;;
        '1')
            dict['group']="$(koopa_sys_group)"
            dict['user']="$(koopa_sys_user)"
            ;;
    esac
    chown_args+=('--no-dereference')
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        chmod_args+=('--recursive')
        chown_args+=('--recursive')
    fi
    if koopa_is_shared_install
    then
        chmod_args+=('u+rw,g+rw,o+r,o-w')
    else
        chmod_args+=('u+rw,g+r,g-w,o+r,o-w')
    fi
    chown_args+=("${dict['user']}:${dict['group']}")
    for arg in "$@"
    do
        if [[ "${dict['dereference']}" -eq 1 ]] && [[ -L "$arg" ]]
        then
            arg="$(koopa_realpath "$arg")"
        fi
        chmod_args+=("$arg")
        chown_args+=("$arg")
        koopa_chmod "${chmod_args[@]}"
        koopa_chown "${chown_args[@]}"
    done
    return 0
}

koopa_sys_user() {
    koopa_assert_has_no_args "$#"
    koopa_print "$(koopa_user)"
    return 0
}

koopa_system_info() {
    local app dict info nf_info
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['bash']="$(koopa_locate_bash --allow-system)"
        ['cat']="$(koopa_locate_cat --allow-system)"
    )
    [[ -x "${app['bash']}" ]] || return 1
    [[ -x "${app['cat']}" ]] || return 1
    declare -A dict=(
        ['app_prefix']="$(koopa_app_prefix)"
        ['arch']="$(koopa_arch)"
        ['arch2']="$(koopa_arch2)"
        ['bash_version']="$(koopa_get_version "${app['bash']}")"
        ['config_prefix']="$(koopa_config_prefix)"
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['koopa_url']="$(koopa_koopa_url)"
        ['koopa_version']="$(koopa_koopa_version)"
        ['opt_prefix']="$(koopa_opt_prefix)"
    )
    dict['ascii_turtle_file']="${dict['koopa_prefix']}/etc/\
koopa/ascii-turtle.txt"
    koopa_assert_is_file "${dict['ascii_turtle_file']}"
    info=(
        "koopa ${dict['koopa_version']}"
        "URL: ${dict['koopa_url']}"
    )
    if koopa_is_git_repo_top_level "${dict['koopa_prefix']}"
    then
        dict['git_remote']="$(koopa_git_remote_url "${dict['koopa_prefix']}")"
        dict['git_commit']="$( \
            koopa_git_last_commit_local "${dict['koopa_prefix']}" \
        )"
        dict['git_date']="$(koopa_git_commit_date "${dict['koopa_prefix']}")"
        info+=(
            ''
            'Git repo'
            '--------'
            "Remote: ${dict['git_remote']}"
            "Commit: ${dict['git_commit']}"
            "Date: ${dict['git_date']}"
        )
    fi
    info+=(
        ''
        'Configuration'
        '-------------'
        "Koopa Prefix: ${dict['koopa_prefix']}"
        "App Prefix: ${dict['app_prefix']}"
        "Opt Prefix: ${dict['opt_prefix']}"
        "Config Prefix: ${dict['config_prefix']}"
    )
    if koopa_is_macos
    then
        app['sw_vers']="$(koopa_macos_locate_sw_vers)"
        [[ -x "${app['sw_vers']}" ]] || return 1
        dict['os']="$( \
            printf '%s %s (%s)\n' \
                "$("${app['sw_vers']}" -productName)" \
                "$("${app['sw_vers']}" -productVersion)" \
                "$("${app['sw_vers']}" -buildVersion)" \
        )"
    else
        app['uname']="$(koopa_locate_uname --allow-system)"
        [[ -x "${app['uname']}" ]] || return 1
        dict['os']="$("${app['uname']}" --all)"
    fi
    info+=(
        ''
        'System information'
        '------------------'
        "OS: ${dict['os']}"
        "Architecture: ${dict['arch']} / ${dict['arch2']}"
        "Bash: ${dict['bash_version']}"
    )
    if koopa_is_installed 'neofetch'
    then
        app['neofetch']="$(koopa_locate_neofetch)"
        [[ -x "${app['neofetch']}" ]] || return 1
        readarray -t nf_info <<< "$("${app['neofetch']}" --stdout)"
        info+=(
            ''
            'Neofetch'
            '--------'
            "${nf_info[@]:2}"
        )
    fi
    "${app['cat']}" "${dict['ascii_turtle_file']}"
    koopa_info_box "${info[@]}"
    return 0
}

koopa_tar_multiple_dirs() {
    local app dict dir dirs pos
    koopa_assert_has_args "$#"
    declare -A app
    app['tar']="$(koopa_locate_tar --allow-system)"
    [[ -x "${app['tar']}" ]] || return 1
    declare -A dict=(
        ['delete']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--delete')
                dict['delete']=1
                shift 1
                ;;
            '--no-delete' | \
            '--keep')
                dict['delete']=0
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_dir "$@"
    readarray -t dirs <<< "$(koopa_realpath "$@")"
    (
        for dir in "${dirs[@]}"
        do
            local bn
            bn="$(koopa_basename "$dir")"
            koopa_alert "Compressing '${dir}'."
            koopa_cd "$(koopa_dirname "$dir")"
            "${app['tar']}" -czf "${bn}.tar.gz" "${bn}/"
            [[ "${dict['delete']}" -eq 1 ]] && koopa_rm "$dir"
        done
    )
    return 0
}

koopa_test_find_files_by_ext() {
    local all_files dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['ext']="${1:?}"
    )
    dict['pattern']="\.${dict['ext']}$"
    readarray -t all_files <<< "$(koopa_test_find_files)"
    dict['files']="$( \
        koopa_print "${all_files[@]}" \
        | koopa_grep \
            --pattern="${dict['pattern']}" \
            --regex \
        || true \
    )"
    if [[ -z "${dict['files']}" ]]
    then
        koopa_stop "Failed to find test files with extension '${dict['ext']}'."
    fi
    koopa_print "${dict['files']}"
    return 0
}

koopa_test_find_files_by_shebang() {
    local all_files app dict file files
    koopa_assert_has_args "$#"
    declare -A app=(
        ['head']="$(koopa_locate_head)"
        ['tr']="$(koopa_locate_tr)"
    )
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['tr']}" ]] || return 1
    declare -A dict=(
        ['pattern']="${1:?}"
    )
    readarray -t all_files <<< "$(koopa_test_find_files)"
    files=()
    for file in "${all_files[@]}"
    do
        local shebang
        [[ -s "$file" ]] || continue
        shebang="$( \
            "${app['tr']}" --delete '\0' < "$file" \
                | "${app['head']}" -n 1 \
                || true \
        )"
        [[ -n "$shebang" ]] || continue
        if koopa_str_detect_regex \
            --string="$shebang" \
            --pattern="${dict['pattern']}"
        then
            files+=("$file")
        fi
    done
    if koopa_is_array_empty "${files[@]}"
    then
        koopa_stop "Failed to find files with pattern '${dict['pattern']}'."
    fi
    koopa_print "${files[@]}"
    return 0
}

koopa_test_find_files() {
    local dict files
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['prefix']="$(koopa_koopa_prefix)"
    )
    readarray -t files <<< "$( \
        koopa_find \
            --exclude='*.swp' \
            --exclude='.*' \
            --exclude='.git/**' \
            --exclude='app/**' \
            --exclude='common.sh' \
            --exclude='coverage/**' \
            --exclude='etc/**' \
            --exclude='libexec/**' \
            --exclude='opt/**' \
            --exclude='share/**' \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${files[@]:-}"
    then
        koopa_stop 'Failed to find any test files.'
    fi
    koopa_print "${files[@]}"
}

koopa_test_grep() {
    local app dict failures file pos
    koopa_assert_has_args "$#"
    declare -A app
    app['grep']="$(koopa_locate_grep)"
    [[ -x "${app['grep']}" ]] || return 1
    declare -A dict=(
        ['ignore']=''
        ['name']=''
        ['pattern']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--ignore='*)
                dict['ignore']="${1#*=}"
                shift 1
                ;;
            '--ignore')
                dict['ignore']="${2:?}"
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
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--pattern' "${dict['pattern']}"
    failures=()

    for file in "$@"
    do
        local x
        if [[ -n "${dict['ignore']}" ]]
        then
            if "${app['grep']}" -Pq \
                --binary-files='without-match' \
                "^# koopa nolint=${dict['ignore']}$" \
                "$file"
            then
                continue
            fi
        fi
        x="$(
            "${app['grep']}" -HPn \
                --binary-files='without-match' \
                "${dict['pattern']}" \
                "$file" \
            || true \
        )"
        [[ -n "$x" ]] && failures+=("$x")
    done
    if [[ "${#failures[@]}" -gt 0 ]]
    then
        koopa_status_fail "${dict['name']} [${#failures[@]}]"
        printf '%s\n' "${failures[@]}"
        return 1
    fi
    koopa_status_ok "${dict['name']} [${#}]"
    return 0
}

koopa_test_true_color() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    "${app['awk']}" 'BEGIN{
        s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
        for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
        }
        printf "\n";
    }'
    return 0
}

koopa_test() {
    local prefix
    koopa_assert_has_no_args "$#"
    prefix="$(koopa_tests_prefix)"
    (
        koopa_cd "$prefix"
        ./linter
        ./shunit2
    )
    return 0
}

koopa_tests_prefix() {
    koopa_print "$(koopa_koopa_prefix)/etc/koopa/tests"
    return 0
}

koopa_tex_version() {
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['cut']="$(koopa_locate_cut --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
        ['tex']="${1:-}"
    )
    [[ -z "${app['tex']}" ]] && app['tex']="$(koopa_locate_tex)"
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['tex']}" ]] || return 1
    str="$( \
        "${app['tex']}" --version \
            | "${app['head']}" -n 1 \
            | "${app['cut']}" -d '(' -f '2' \
            | "${app['cut']}" -d ')' -f '1' \
            | "${app['cut']}" -d ' ' -f '3' \
            | "${app['cut']}" -d '/' -f '1' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_tmp_dir() {
    local x
    koopa_assert_has_no_args "$#"
    x="$(koopa_mktemp -d)"
    koopa_assert_is_dir "$x"
    x="$(koopa_realpath "$x")"
    koopa_print "$x"
    return 0
}

koopa_tmp_file() {
    local x
    koopa_assert_has_no_args "$#"
    x="$(koopa_mktemp)"
    koopa_assert_is_file "$x"
    x="$(koopa_realpath "$x")"
    koopa_print "$x"
    return 0
}

koopa_tmp_log_file() {
    koopa_assert_has_no_args "$#"
    koopa_tmp_file
    return 0
}

koopa_to_string() {
    koopa_assert_has_args "$#"
    koopa_paste0 --sep=', ' "$@"
    return 0
}

koopa_touch() {
    local app mkdir pos touch
    koopa_assert_has_args "$#"
    declare -A app=(
        ['mkdir']='koopa_mkdir'
        ['touch']="$(koopa_locate_touch --allow-system)"
    )
    [[ -x "${app['touch']}" ]] || return 1
    declare -A dict=(
        ['sudo']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    mkdir=("${app['mkdir']}")
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        app['sudo']="$(koopa_locate_sudo)"
        mkdir+=('--sudo')
        touch=("${app['sudo']}" "${app['touch']}")
    else
        touch=("${app['touch']}")
    fi
    for file in "$@"
    do
        local dn
        if [[ -e "$file" ]]
        then
            koopa_assert_is_not_dir "$file"
            koopa_assert_is_not_symlink "$file"
        fi
        dn="$(koopa_dirname "$file")"
        if [[ ! -d "$dn" ]] && \
            koopa_str_detect_fixed \
                --string="$dn" \
                --pattern='/'
        then
            "${mkdir[@]}" "$dn"
        fi
        "${touch[@]}" "$file"
    done
    return 0
}

koopa_trim_ws() {
    local str
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        str="${str#"${str%%[![:space:]]*}"}"
        str="${str%"${str##*[![:space:]]}"}"
        koopa_print "$str"
    done
    return 0
}

koopa_uninstall_ack() {
    koopa_uninstall_app \
        --name='ack' \
        "$@"
}

koopa_uninstall_agat() {
    koopa_uninstall_app \
        --name='agat' \
        "$@"
}

koopa_uninstall_anaconda() {
    koopa_uninstall_app \
        --name='anaconda' \
        "$@"
}

koopa_uninstall_apache_airflow() {
    koopa_uninstall_app \
        --name='apache-airflow' \
        "$@"
}

koopa_uninstall_apache_spark() {
    koopa_uninstall_app \
        --name='apache-spark' \
        "$@"
}

koopa_uninstall_app() {
    local bin_arr bool dict man1_arr
    declare -A bool=(
        ['quiet']=0
        ['unlink_in_bin']=''
        ['unlink_in_man1']=''
        ['unlink_in_opt']=''
        ['verbose']=0
    )
    declare -A dict=(
        ['app_prefix']="$(koopa_app_prefix)"
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['mode']='shared'
        ['name']=''
        ['opt_prefix']="$(koopa_opt_prefix)"
        ['platform']='common'
        ['prefix']=''
        ['uninstaller_bn']=''
        ['uninstaller_fun']='main'
    )
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
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
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
            '--uninstaller='*)
                dict['uninstaller_bn']="${1#*=}"
                shift 1
                ;;
            '--uninstaller')
                dict['uninstaller_bn']="${2:?}"
                shift 2
                ;;
            '--no-unlink-in-bin')
                bool['unlink_in_bin']=0
                shift 1
                ;;
            '--no-unlink-in-man1')
                bool['unlink_in_man1']=0
                shift 1
                ;;
            '--no-unlink-in-opt')
                bool['unlink_in_opt']=0
                shift 1
                ;;
            '--quiet')
                bool['quiet']=1
                shift 1
                ;;
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--name' "${dict['name']}"
    [[ "${bool['verbose']}" -eq 1 ]] && set -o xtrace
    case "${dict['mode']}" in
        'shared')
            [[ -z "${dict['prefix']}" ]] && \
                dict['prefix']="${dict['app_prefix']}/${dict['name']}"
            [[ -z "${bool['unlink_in_bin']}" ]] && bool['unlink_in_bin']=1
            [[ -z "${bool['unlink_in_man1']}" ]] && bool['unlink_in_man1']=1
            [[ -z "${bool['unlink_in_opt']}" ]] && bool['unlink_in_opt']=1
            ;;
        'system')
            koopa_assert_is_admin
            bool['unlink_in_bin']=0
            bool['unlink_in_man1']=0
            bool['unlink_in_opt']=0
            ;;
        'user')
            bool['unlink_in_bin']=0
            bool['unlink_in_man1']=0
            bool['unlink_in_opt']=0
            ;;
    esac
    if [[ -n "${dict['prefix']}" ]]
    then
        if [[ ! -d "${dict['prefix']}" ]]
        then
            koopa_alert_is_not_installed "${dict['name']}" "${dict['prefix']}"
            return 1
        fi
        dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    fi
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        if [[ -n "${dict['prefix']}" ]]
        then
            koopa_alert_uninstall_start "${dict['name']}" "${dict['prefix']}"
        else
            koopa_alert_uninstall_start "${dict['name']}"
        fi
    fi
    [[ -z "${dict['uninstaller_bn']}" ]] && \
        dict['uninstaller_bn']="${dict['name']}"
    dict['uninstaller_file']="${dict['koopa_prefix']}/lang/shell/bash/include/\
uninstall/${dict['platform']}/${dict['mode']}/${dict['uninstaller_bn']}.sh"
    if [[ -f "${dict['uninstaller_file']}" ]]
    then
        dict['tmp_dir']="$(koopa_tmp_dir)"
        (
            koopa_cd "${dict['tmp_dir']}"
            source "${dict['uninstaller_file']}"
            koopa_assert_is_function "${dict['uninstaller_fun']}"
            "${dict['uninstaller_fun']}"
        )
        koopa_rm "${dict['tmp_dir']}"
    fi
    if [[ -d "${dict['prefix']}" ]]
    then
        case "${dict['mode']}" in
            'system')
                koopa_rm --sudo "${dict['prefix']}"
                ;;
            *)
                koopa_rm "${dict['prefix']}"
                ;;
        esac
    fi
    case "${dict['mode']}" in
        'shared')
            if [[ "${bool['unlink_in_opt']}" -eq 1 ]]
            then
                koopa_unlink_in_opt "${dict['name']}"
            fi
            if [[ "${bool['unlink_in_bin']}" -eq 1 ]]
            then
                readarray -t bin_arr <<< "$( \
                    koopa_app_json_bin "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if koopa_is_array_non_empty "${bin_arr[@]:-}"
                then
                    koopa_unlink_in_bin "${bin_arr[@]}"
                fi
            fi
            if [[ "${bool['unlink_in_man1']}" -eq 1 ]]
            then
                readarray -t man1_arr <<< "$( \
                    koopa_app_json_man1 "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if koopa_is_array_non_empty "${man1_arr[@]:-}"
                then
                    koopa_unlink_in_man1 "${man1_arr[@]}"
                fi
            fi
            ;;
    esac
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        if [[ -n "${dict['prefix']}" ]]
        then
            koopa_alert_uninstall_success \
                "${dict['name']}" "${dict['prefix']}"
        else
            koopa_alert_uninstall_success "${dict['name']}"
        fi
    fi
    return 0
}

koopa_uninstall_apr_util() {
    koopa_uninstall_app \
        --name='apr-util' \
        "$@"
}

koopa_uninstall_apr() {
    koopa_uninstall_app \
        --name='apr' \
        "$@"
}

koopa_uninstall_armadillo() {
    koopa_uninstall_app \
        --name='armadillo' \
        "$@"
}

koopa_uninstall_asdf() {
    koopa_uninstall_app \
        --name='asdf' \
        "$@"
}

koopa_uninstall_aspell() {
    koopa_uninstall_app \
        --name='aspell' \
        "$@"
}

koopa_uninstall_autoconf() {
    koopa_uninstall_app \
        --name='autoconf' \
        "$@"
}

koopa_uninstall_autodock_adfr() {
    koopa_uninstall_app \
        --name='autodock-adfr' \
        "$@"
}

koopa_uninstall_autodock_vina() {
    koopa_uninstall_app \
        --name='autodock-vina' \
        "$@"
}

koopa_uninstall_autodock() {
    koopa_uninstall_app \
        --name='autodock' \
        "$@"
}

koopa_uninstall_autoflake() {
    koopa_uninstall_app \
        --name='autoflake' \
        "$@"
}

koopa_uninstall_automake() {
    koopa_uninstall_app \
        --name='automake' \
        "$@"
}

koopa_uninstall_aws_cli() {
    koopa_uninstall_app \
        --name='aws-cli' \
        "$@"
}

koopa_uninstall_azure_cli() {
    koopa_uninstall_app \
        --name='azure-cli' \
        "$@"
}

koopa_uninstall_bamtools() {
    koopa_uninstall_app \
        --name='bamtools' \
        "$@"
}

koopa_uninstall_bandwhich() {
    koopa_uninstall_app \
        --name='bandwhich' \
        "$@"
}

koopa_uninstall_bash_language_server() {
    koopa_uninstall_app \
        --name='bash-language-server' \
        "$@"
}

koopa_uninstall_bash() {
    koopa_uninstall_app \
        --name='bash' \
        "$@"
}

koopa_uninstall_bashcov() {
    koopa_uninstall_app \
        --name='bashcov' \
        "$@"
}

koopa_uninstall_bat() {
    koopa_uninstall_app \
        --name='bat' \
        "$@"
}

koopa_uninstall_bc() {
    koopa_uninstall_app \
        --name='bc' \
        "$@"
}

koopa_uninstall_bedtools() {
    koopa_uninstall_app \
        --name='bedtools' \
        "$@"
}

koopa_uninstall_bfg() {
    koopa_uninstall_app \
        --name='bfg' \
        "$@"
}

koopa_uninstall_binutils() {
    koopa_uninstall_app \
        --name='binutils' \
        "$@"
}

koopa_uninstall_bioawk() {
    koopa_uninstall_app \
        --name='bioawk' \
        "$@"
}

koopa_uninstall_bioconda_utils() {
    koopa_uninstall_app \
        --name='bioconda-utils' \
        "$@"
}

koopa_uninstall_bison() {
    koopa_uninstall_app \
        --name='bison' \
        "$@"
}

koopa_uninstall_black() {
    koopa_uninstall_app \
        --name='black' \
        "$@"
}

koopa_uninstall_boost() {
    koopa_uninstall_app \
        --name='boost' \
        "$@"
}

koopa_uninstall_bottom() {
    koopa_uninstall_app \
        --name='bottom' \
        "$@"
}

koopa_uninstall_bowtie2() {
    koopa_uninstall_app \
        --name='bowtie2' \
        "$@"
}

koopa_uninstall_bpytop() {
    koopa_uninstall_app \
        --name='bpytop' \
        "$@"
}

koopa_uninstall_broot() {
    koopa_uninstall_app \
        --name='broot' \
        "$@"
}

koopa_uninstall_brotli() {
    koopa_uninstall_app \
        --name='brotli' \
        "$@"
}

koopa_uninstall_bustools() {
    koopa_uninstall_app \
        --name='bustools' \
        "$@"
}

koopa_uninstall_bzip2() {
    koopa_uninstall_app \
        --name='bzip2' \
        "$@"
}

koopa_uninstall_c_ares() {
    koopa_uninstall_app \
        --name='c-ares' \
        "$@"
}

koopa_uninstall_ca_certificates() {
    koopa_uninstall_app \
        --name='ca-certificates' \
        "$@"
}

koopa_uninstall_cairo() {
    koopa_uninstall_app \
        --name='cairo' \
        "$@"
}

koopa_uninstall_cheat() {
    koopa_uninstall_app \
        --name='cheat' \
        "$@"
}

koopa_uninstall_chemacs() {
    koopa_uninstall_app \
        --name='chemacs' \
        "$@"
}

koopa_uninstall_chezmoi() {
    koopa_uninstall_app \
        --name='chezmoi' \
        "$@"
}

koopa_uninstall_cli11() {
    koopa_uninstall_app \
        --name='cli11' \
        "$@"
}

koopa_uninstall_cmake() {
    koopa_uninstall_app \
        --name='cmake' \
        "$@"
}

koopa_uninstall_colorls() {
    koopa_uninstall_app \
        --name='colorls' \
        "$@"
}

koopa_uninstall_conda() {
    koopa_uninstall_app \
        --name='conda' \
        "$@"
}

koopa_uninstall_convmv() {
    koopa_uninstall_app \
        --name='convmv' \
        "$@"
}

koopa_uninstall_coreutils() {
    koopa_uninstall_app \
        --name='coreutils' \
        "$@"
}

koopa_uninstall_cpufetch() {
    koopa_uninstall_app \
        --name='cpufetch' \
        "$@"
}

koopa_uninstall_csvkit() {
    koopa_uninstall_app \
        --name='csvkit' \
        "$@"
}

koopa_uninstall_csvtk() {
    koopa_uninstall_app \
        --name='csvtk' \
        "$@"
}

koopa_uninstall_curl() {
    koopa_uninstall_app \
        --name='curl' \
        "$@"
}

koopa_uninstall_deeptools() {
    koopa_uninstall_app \
        --name='deeptools' \
        "$@"
}

koopa_uninstall_delta() {
    koopa_uninstall_app \
        --name='delta' \
        "$@"
}

koopa_uninstall_diff_so_fancy() {
    koopa_uninstall_app \
        --name='diff-so-fancy' \
        "$@"
}

koopa_uninstall_difftastic() {
    koopa_uninstall_app \
        --name='difftastic' \
        "$@"
}

koopa_uninstall_dog() {
    koopa_uninstall_app \
        --name='dog' \
        "$@"
}

koopa_uninstall_dotfiles() {
    koopa_uninstall_app \
        --name='dotfiles' \
        "$@"
}

koopa_uninstall_du_dust() {
    koopa_uninstall_app \
        --name='du-dust' \
        "$@"
}

koopa_uninstall_editorconfig() {
    koopa_uninstall_app \
        --name='editorconfig' \
        "$@"
}

koopa_uninstall_emacs() {
    koopa_uninstall_app \
        --name='emacs' \
        "$@"
}

koopa_uninstall_ensembl_perl_api() {
    koopa_uninstall_app \
        --name='ensembl-perl-api' \
        "$@"
}

koopa_uninstall_entrez_direct() {
    koopa_uninstall_app \
        --name='entrez-direct' \
        "$@"
}

koopa_uninstall_exa() {
    koopa_uninstall_app \
        --name='exa' \
        "$@"
}

koopa_uninstall_exiftool() {
    koopa_uninstall_app \
        --name='exiftool' \
        "$@"
}

koopa_uninstall_expat() {
    koopa_uninstall_app \
        --name='expat' \
        "$@"
}

koopa_uninstall_fastqc() {
    koopa_uninstall_app \
        --name='fastqc' \
        "$@"
}

koopa_uninstall_fd_find() {
    koopa_uninstall_app \
        --name='fd-find' \
        "$@"
}

koopa_uninstall_ffmpeg() {
    koopa_uninstall_app \
        --name='ffmpeg' \
        "$@"
}

koopa_uninstall_ffq() {
    koopa_uninstall_app \
        --name='ffq' \
        "$@"
}

koopa_uninstall_fgbio() {
    koopa_uninstall_app \
        --name='fgbio' \
        "$@"
}

koopa_uninstall_findutils() {
    koopa_uninstall_app \
        --name='findutils' \
        "$@"
}

koopa_uninstall_fish() {
    koopa_uninstall_app \
        --name='fish' \
        "$@"
}

koopa_uninstall_flac() {
    koopa_uninstall_app \
        --name='flac' \
        "$@"
}

koopa_uninstall_flake8() {
    koopa_uninstall_app \
        --name='flake8' \
        "$@"
}

koopa_uninstall_flex() {
    koopa_uninstall_app \
        --name='flex' \
        "$@"
}

koopa_uninstall_fltk() {
    koopa_uninstall_app \
        --name='fltk' \
        "$@"
}

koopa_uninstall_fmt() {
    koopa_uninstall_app \
        --name='fmt' \
        "$@"
}

koopa_uninstall_fontconfig() {
    koopa_uninstall_app \
        --name='fontconfig' \
        "$@"
}

koopa_uninstall_fq() {
    koopa_uninstall_app \
        --name='fq' \
        "$@"
}

koopa_uninstall_freetype() {
    koopa_uninstall_app \
        --name='freetype' \
        "$@"
}

koopa_uninstall_fribidi() {
    koopa_uninstall_app \
        --name='fribidi' \
        "$@"
}

koopa_uninstall_fzf() {
    koopa_uninstall_app \
        --name='fzf' \
        "$@"
}

koopa_uninstall_gatk() {
    koopa_uninstall_app \
        --name='gatk' \
        "$@"
}

koopa_uninstall_gawk() {
    koopa_uninstall_app \
        --name='gawk' \
        "$@"
}

koopa_uninstall_gcc() {
    koopa_uninstall_app \
        --name='gcc' \
        "$@"
}

koopa_uninstall_gdal() {
    koopa_uninstall_app \
        --name='gdal' \
        "$@"
}

koopa_uninstall_gdbm() {
    koopa_uninstall_app \
        --name='gdbm' \
        "$@"
}

koopa_uninstall_geos() {
    koopa_uninstall_app \
        --name='geos' \
        "$@"
}

koopa_uninstall_gettext() {
    koopa_uninstall_app \
        --name='gettext' \
        "$@"
}

koopa_uninstall_gffutils() {
    koopa_uninstall_app \
        --name='gffutils' \
        "$@"
}

koopa_uninstall_gget() {
    koopa_uninstall_app \
        --name='gget' \
        "$@"
}

koopa_uninstall_ghostscript() {
    koopa_uninstall_app \
        --name='ghostscript' \
        "$@"
}

koopa_uninstall_git_lfs() {
    koopa_uninstall_app \
        --name='git-lfs' \
        "$@"
}

koopa_uninstall_git() {
    koopa_uninstall_app \
        --name='git' \
        "$@"
}

koopa_uninstall_glances() {
    koopa_uninstall_app \
        --name='glances' \
        "$@"
}

koopa_uninstall_glib() {
    koopa_uninstall_app \
        --name='glib' \
        "$@"
}

koopa_uninstall_gmp() {
    koopa_uninstall_app \
        --name='gmp' \
        "$@"
}

koopa_uninstall_gnupg() {
    koopa_uninstall_app \
        --name='gnupg' \
        "$@"
}

koopa_uninstall_gnutls() {
    koopa_uninstall_app \
        --name='gnutls' \
        "$@"
}

koopa_uninstall_go() {
    koopa_uninstall_app \
        --name='go' \
        "$@"
}

koopa_uninstall_google_cloud_sdk() {
    koopa_uninstall_app \
        --name='google-cloud-sdk' \
        "$@"
}

koopa_uninstall_googletest() {
    koopa_uninstall_app \
        --name='googletest' \
        "$@"
}

koopa_uninstall_gperf() {
    koopa_uninstall_app \
        --name='gperf' \
        "$@"
}

koopa_uninstall_graphviz() {
    koopa_uninstall_app \
        --name='graphviz' \
        "$@"
}

koopa_uninstall_grep() {
    koopa_uninstall_app \
        --name='grep' \
        "$@"
}

koopa_uninstall_grex() {
    koopa_uninstall_app \
        --name='grex' \
        "$@"
}

koopa_uninstall_groff() {
    koopa_uninstall_app \
        --name='groff' \
        "$@"
}

koopa_uninstall_gseapy() {
    koopa_uninstall_app \
        --name='gseapy' \
        "$@"
}

koopa_uninstall_gsl() {
    koopa_uninstall_app \
        --name='gsl' \
        "$@"
}

koopa_uninstall_gtop() {
    koopa_uninstall_app \
        --name='gtop' \
        "$@"
}

koopa_uninstall_gum() {
    koopa_uninstall_app \
        --name='gum' \
        "$@"
}

koopa_uninstall_gzip() {
    koopa_uninstall_app \
        --name='gzip' \
        "$@"
}

koopa_uninstall_hadolint() {
    koopa_uninstall_app \
        --name='hadolint' \
        "$@"
}

koopa_uninstall_harfbuzz() {
    koopa_uninstall_app \
        --name='harfbuzz' \
        "$@"
}

koopa_uninstall_haskell_cabal() {
    koopa_uninstall_app \
        --name='haskell-cabal' \
        "$@"
}

koopa_uninstall_haskell_ghcup() {
    koopa_uninstall_app \
        --name='haskell-ghcup' \
        "$@"
}

koopa_uninstall_haskell_stack() {
    koopa_uninstall_app \
        --name='haskell-stack' \
        "$@"
}

koopa_uninstall_hdf5() {
    koopa_uninstall_app \
        --name='hdf5' \
        "$@"
}

koopa_uninstall_hexyl() {
    koopa_uninstall_app \
        --name='hexyl' \
        "$@"
}

koopa_uninstall_hisat2() {
    koopa_uninstall_app \
        --name='hisat2' \
        "$@"
}

koopa_uninstall_htop() {
    koopa_uninstall_app \
        --name='htop' \
        "$@"
}

koopa_uninstall_htseq() {
    koopa_uninstall_app \
        --name='htseq' \
        "$@"
}

koopa_uninstall_httpie() {
    koopa_uninstall_app \
        --name='httpie' \
        "$@"
}

koopa_uninstall_hugo() {
    koopa_uninstall_app \
        --name='hugo' \
        "$@"
}

koopa_uninstall_hyperfine() {
    koopa_uninstall_app \
        --name='hyperfine' \
        "$@"
}

koopa_uninstall_icu4c() {
    koopa_uninstall_app \
        --name='icu4c' \
        "$@"
}

koopa_uninstall_imagemagick() {
    koopa_uninstall_app \
        --name='imagemagick' \
        "$@"
}

koopa_uninstall_ipython() {
    koopa_uninstall_app \
        --name='ipython' \
        "$@"
}

koopa_uninstall_isort() {
    koopa_uninstall_app \
        --name='isort' \
        "$@"
}

koopa_uninstall_jemalloc() {
    koopa_uninstall_app \
        --name='jemalloc' \
        "$@"
}

koopa_uninstall_jpeg() {
    koopa_uninstall_app \
        --name='jpeg' \
        "$@"
}

koopa_uninstall_jq() {
    koopa_uninstall_app \
        --name='jq' \
        "$@"
}

koopa_uninstall_julia_packages() {
    koopa_uninstall_app \
        --name='julia-packages' \
        --prefix="$(koopa_julia_packages_prefix)" \
        "$@"
}

koopa_uninstall_julia() {
    koopa_uninstall_app \
        --name='julia' \
        "$@"
}

koopa_uninstall_jupyterlab() {
    koopa_uninstall_app \
        --name='jupyterlab' \
        "$@"
}

koopa_uninstall_kallisto() {
    koopa_uninstall_app \
        --name='kallisto' \
        "$@"
}

koopa_uninstall_koopa() {
    local dict
    declare -A dict=(
        ['config_prefix']="$(koopa_config_prefix)"
        ['koopa_prefix']="$(koopa_koopa_prefix)"
    )
    if koopa_is_linux && koopa_is_shared_install
    then
        koopa_rm --sudo '/etc/profile.d/zzz-koopa.sh'
    fi
    koopa_uninstall_dotfiles
    koopa_rm \
        "${dict['config_prefix']}" \
        "${dict['koopa_prefix']}"
    return 0
}

koopa_uninstall_lame() {
    koopa_uninstall_app \
        --name='lame' \
        "$@"
}

koopa_uninstall_lapack() {
    koopa_uninstall_app \
        --name='lapack' \
        "$@"
}

koopa_uninstall_latch() {
    koopa_uninstall_app \
        --name='latch' \
        "$@"
}

koopa_uninstall_less() {
    koopa_uninstall_app \
        --name='autoconf' \
        "$@"
}

koopa_uninstall_lesspipe() {
    koopa_uninstall_app \
        --name='lesspipe' \
        "$@"
}

koopa_uninstall_libarchive() {
    koopa_uninstall_app \
        --name='libarchive' \
        "$@"
}

koopa_uninstall_libassuan() {
    koopa_uninstall_app \
        --name='libassuan' \
        "$@"
}

koopa_uninstall_libedit() {
    koopa_uninstall_app \
        --name='libedit' \
        "$@"
}

koopa_uninstall_libev() {
    koopa_uninstall_app \
        --name='libev' \
        "$@"
}

koopa_uninstall_libevent() {
    koopa_uninstall_app \
        --name='libevent' \
        "$@"
}

koopa_uninstall_libffi() {
    koopa_uninstall_app \
        --name='libffi' \
        "$@"
}

koopa_uninstall_libgcrypt() {
    koopa_uninstall_app \
        --name='libgcrypt' \
        "$@"
}

koopa_uninstall_libgeotiff() {
    koopa_uninstall_app \
        --name='libgeotiff' \
        "$@"
}

koopa_uninstall_libgit2() {
    koopa_uninstall_app \
        --name='libgit2' \
        "$@"
}

koopa_uninstall_libgpg_error() {
    koopa_uninstall_app \
        --name='libgpg-error' \
        "$@"
}

koopa_uninstall_libiconv() {
    koopa_uninstall_app \
        --name='libiconv' \
        "$@"
}

koopa_uninstall_libidn() {
    koopa_uninstall_app \
        --name='libidn' \
        "$@"
}

koopa_uninstall_libjpeg_turbo() {
    koopa_uninstall_app \
        --name='libjpeg-turbo' \
        "$@"
}

koopa_uninstall_libksba() {
    koopa_uninstall_app \
        --name='libksba' \
        "$@"
}

koopa_uninstall_libluv() {
    koopa_uninstall_app \
        --name='libluv' \
        "$@"
}

koopa_uninstall_libpipeline() {
    koopa_uninstall_app \
        --name='libpipeline' \
        "$@"
}

koopa_uninstall_libpng() {
    koopa_uninstall_app \
        --name='libpng' \
        "$@"
}

koopa_uninstall_libsolv() {
    koopa_uninstall_app \
        --name='libsolv' \
        "$@"
}

koopa_uninstall_libssh2() {
    koopa_uninstall_app \
        --name='libssh2' \
        "$@"
}

koopa_uninstall_libtasn1() {
    koopa_uninstall_app \
        --name='libtasn1' \
        "$@"
}

koopa_uninstall_libtermkey() {
    koopa_uninstall_app \
        --name='libtermkey' \
        "$@"
}

koopa_uninstall_libtiff() {
    koopa_uninstall_app \
        --name='libtiff' \
        "$@"
}

koopa_uninstall_libtool() {
    koopa_uninstall_app \
        --name='libtool' \
        "$@"
}

koopa_uninstall_libunistring() {
    koopa_uninstall_app \
        --name='libunistring' \
        "$@"
}

koopa_uninstall_libuv() {
    koopa_uninstall_app \
        --name='libuv' \
        "$@"
}

koopa_uninstall_libvterm() {
    koopa_uninstall_app \
        --name='libvterm' \
        "$@"
}

koopa_uninstall_libxml2() {
    koopa_uninstall_app \
        --name='libxml2' \
        "$@"
}

koopa_uninstall_libyaml() {
    koopa_uninstall_app \
        --name='libyaml' \
        "$@"
}

koopa_uninstall_libzip() {
    koopa_uninstall_app \
        --name='libzip' \
        "$@"
}

koopa_uninstall_llama() {
    koopa_uninstall_app \
        --name='llama' \
        "$@"
}

koopa_uninstall_llvm() {
    koopa_uninstall_app \
        --name='llvm' \
        "$@"
}

koopa_uninstall_lsd() {
    koopa_uninstall_app \
        --name='lsd' \
        "$@"
}

koopa_uninstall_lua() {
    koopa_uninstall_app \
        --name='lua' \
        "$@"
}

koopa_uninstall_luajit() {
    koopa_uninstall_app \
        --name='luajit' \
        "$@"
}

koopa_uninstall_luarocks() {
    koopa_uninstall_app \
        --name='luarocks' \
        "$@"
}

koopa_uninstall_lz4() {
    koopa_uninstall_app \
        --name='lz4' \
        "$@"
}

koopa_uninstall_lzo() {
    koopa_uninstall_app \
        --name='lzo' \
        "$@"
}

koopa_uninstall_m4() {
    koopa_uninstall_app \
        --name='m4' \
        "$@"
}

koopa_uninstall_make() {
    koopa_uninstall_app \
        --name='make' \
        "$@"
}

koopa_uninstall_mamba() {
    koopa_uninstall_app \
        --name='mamba' \
        "$@"
}

koopa_uninstall_man_db() {
    koopa_uninstall_app \
        --name='man-db' \
        "$@"
}

koopa_uninstall_markdownlint_cli() {
    koopa_uninstall_app \
        --name='markdownlint-cli' \
        "$@"
}

koopa_uninstall_mcfly() {
    koopa_uninstall_app \
        --name='mcfly' \
        "$@"
}

koopa_uninstall_mdcat() {
    koopa_uninstall_app \
        --name='mdcat' \
        "$@"
}

koopa_uninstall_meson() {
    koopa_uninstall_app \
        --name='meson' \
        "$@"
}

koopa_uninstall_minimap2() {
    koopa_uninstall_app \
        --name='minimap2' \
        "$@"
}

koopa_uninstall_misopy() {
    koopa_uninstall_app \
        --name='misopy' \
        "$@"
}

koopa_uninstall_mpc() {
    koopa_uninstall_app \
        --name='mpc' \
        "$@"
}

koopa_uninstall_mpdecimal() {
    koopa_uninstall_app \
        --name='mpdecimal' \
        "$@"
}

koopa_uninstall_mpfr() {
    koopa_uninstall_app \
        --name='mpfr' \
        "$@"
}

koopa_uninstall_msgpack() {
    koopa_uninstall_app \
        --name='msgpack' \
        "$@"
}

koopa_uninstall_multiqc() {
    koopa_uninstall_app \
        --name='multiqc' \
        "$@"
}

koopa_uninstall_nano() {
    koopa_uninstall_app \
        --name='nano' \
        "$@"
}

koopa_uninstall_nanopolish() {
    koopa_uninstall_app \
        --name='nanopolish' \
        "$@"
}

koopa_uninstall_ncurses() {
    koopa_uninstall_app \
        --name='ncurses' \
        "$@"
}

koopa_uninstall_neofetch() {
    koopa_uninstall_app \
        --name='neofetch' \
        "$@"
}

koopa_uninstall_neovim() {
    koopa_uninstall_app \
        --name='neovim' \
        "$@"
}

koopa_uninstall_nettle() {
    koopa_uninstall_app \
        --name='nettle' \
        "$@"
}

koopa_uninstall_nextflow() {
    koopa_uninstall_app \
        --name='nextflow' \
        "$@"
}

koopa_uninstall_nghttp2() {
    koopa_uninstall_app \
        --name='nghttp2' \
        "$@"
}

koopa_uninstall_nim() {
    koopa_uninstall_app \
        --name='nim' \
        "$@"
}

koopa_uninstall_ninja() {
    koopa_uninstall_app \
        --name='ninja' \
        "$@"
}

koopa_uninstall_nlohmann_json() {
    koopa_uninstall_app \
        --name='nlohmann-json' \
        "$@"
}

koopa_uninstall_nmap() {
    koopa_uninstall_app \
        --name='nmap' \
        "$@"
}

koopa_uninstall_node() {
    koopa_uninstall_app \
        --name='node' \
        "$@"
}

koopa_uninstall_npth() {
    koopa_uninstall_app \
        --name='npth' \
        "$@"
}

koopa_uninstall_nushell() {
    koopa_uninstall_app \
        --name='nushell' \
        "$@"
}

koopa_uninstall_oniguruma() {
    koopa_uninstall_app \
        --name='oniguruma' \
        "$@"
}

koopa_uninstall_ont_guppy() {
    koopa_uninstall_app \
        --name='ont-guppy' \
        "$@"
}

koopa_uninstall_openbb() {
    koopa_uninstall_app \
        --name='openbb' \
        "$@"
}

koopa_uninstall_openblas() {
    koopa_uninstall_app \
        --name='openblas' \
        "$@"
}

koopa_uninstall_openjdk() {
    koopa_uninstall_app \
        --name='openjdk' \
        "$@"
}

koopa_uninstall_openssh() {
    koopa_uninstall_app \
        --name='openssh' \
        "$@"
}

koopa_uninstall_openssl1() {
    koopa_uninstall_app \
        --name='openssl1' \
        "$@"
}

koopa_uninstall_openssl3() {
    koopa_uninstall_app \
        --name='openssl3' \
        "$@"
}

koopa_uninstall_pandoc() {
    koopa_uninstall_app \
        --name='pandoc' \
        "$@"
}

koopa_uninstall_parallel() {
    koopa_uninstall_app \
        --name='parallel' \
        "$@"
}

koopa_uninstall_password_store() {
    koopa_uninstall_app \
        --name='password-store' \
        "$@"
}

koopa_uninstall_patch() {
    koopa_uninstall_app \
        --name='patch' \
        "$@"
}

koopa_uninstall_pcre() {
    koopa_uninstall_app \
        --name='pcre' \
        "$@"
}

koopa_uninstall_pcre2() {
    koopa_uninstall_app \
        --name='pcre2' \
        "$@"
}

koopa_uninstall_perl() {
    koopa_uninstall_app \
        --name='perl' \
        "$@"
}

koopa_uninstall_pipx() {
    koopa_uninstall_app \
        --name='pipx' \
        "$@"
}

koopa_uninstall_pixman() {
    koopa_uninstall_app \
        --name='pixman' \
        "$@"
}

koopa_uninstall_pkg_config() {
    koopa_uninstall_app \
        --name='pkg-config' \
        "$@"
}

koopa_uninstall_poetry() {
    koopa_uninstall_app \
        --name='poetry' \
        "$@"
}

koopa_uninstall_prettier() {
    koopa_uninstall_app \
        --name='prettier' \
        "$@"
}

koopa_uninstall_procs() {
    koopa_uninstall_app \
        --name='procs' \
        "$@"
}

koopa_uninstall_proj() {
    koopa_uninstall_app \
        --name='proj' \
        "$@"
}

koopa_uninstall_py_spy() {
    koopa_uninstall_app \
        --name='py_spy' \
        "$@"
}

koopa_uninstall_pybind11() {
    koopa_uninstall_app \
        --name='pybind11' \
        "$@"
}

koopa_uninstall_pycodestyle() {
    koopa_uninstall_app \
        --name='pycodestyle' \
        "$@"
}

koopa_uninstall_pyenv() {
    koopa_uninstall_app \
        --name='pyenv' \
        "$@"
}

koopa_uninstall_pyflakes() {
    koopa_uninstall_app \
        --name='pyflakes' \
        "$@"
}

koopa_uninstall_pygments() {
    koopa_uninstall_app \
        --name='pygments' \
        "$@"
}

koopa_uninstall_pylint() {
    koopa_uninstall_app \
        --name='pylint' \
        "$@"
}

koopa_uninstall_pytaglib() {
    koopa_uninstall_app \
        --name='pytaglib' \
        "$@"
}

koopa_uninstall_pytest() {
    koopa_uninstall_app \
        --name='pytest' \
        "$@"
}

koopa_uninstall_python310() {
    koopa_uninstall_app \
        --name='python3.10' \
        "$@"
}

koopa_uninstall_python311() {
    local dict
    declare -A dict=(
        ['app_prefix']="$(koopa_app_prefix)"
        ['bin_prefix']="$(koopa_bin_prefix)"
        ['opt_prefix']="$(koopa_opt_prefix)"
    )
    koopa_uninstall_app \
        --name='python3.11' \
        "$@"
    koopa_alert "Unlinking 'python' and 'python3'."
    koopa_rm  \
        "${dict['app_prefix']}/python" \
        "${dict['bin_prefix']}/python" \
        "${dict['bin_prefix']}/python3" \
        "${dict['opt_prefix']}/python"
    return 0
}

koopa_uninstall_r_devel() {
    koopa_uninstall_app \
        --name='r-devel' \
        "$@"
}

koopa_uninstall_r_packages() {
    koopa_uninstall_app \
        --name='r-packages' \
        "$@"
}

koopa_uninstall_r() {
    koopa_uninstall_app \
        --name='r' \
        "$@"
}

koopa_uninstall_radian() {
    koopa_uninstall_app \
        --name='radian' \
        "$@"
}

koopa_uninstall_ranger_fm() {
    koopa_uninstall_app \
        --name='ranger-fm' \
        "$@"
}

koopa_uninstall_rbenv() {
    koopa_uninstall_app \
        --name='rbenv' \
        "$@"
}

koopa_uninstall_readline() {
    koopa_uninstall_app \
        --name='readline' \
        "$@"
}

koopa_uninstall_rename() {
    koopa_uninstall_app \
        --name='rename' \
        "$@"
}

koopa_uninstall_reproc() {
    koopa_uninstall_app \
        --name='reproc' \
        "$@"
}

koopa_uninstall_ripgrep_all() {
    koopa_uninstall_app \
        --name='ripgrep-all' \
        "$@"
}

koopa_uninstall_ripgrep() {
    koopa_uninstall_app \
        --name='ripgrep' \
        "$@"
}

koopa_uninstall_rmate() {
    koopa_uninstall_app \
        --name='rmate' \
        "$@"
}

koopa_uninstall_ronn() {
    koopa_uninstall_app \
        --name='ronn' \
        "$@"
}

koopa_uninstall_rsem() {
    koopa_uninstall_app \
        --name='rsem' \
        "$@"
}

koopa_uninstall_rsync() {
    koopa_uninstall_app \
        --name='rsync' \
        "$@"
}

koopa_uninstall_ruby() {
    koopa_uninstall_app \
        --name='ruby' \
        "$@"
}

koopa_uninstall_ruff() {
    koopa_uninstall_app \
        --name='ruff' \
        "$@"
}

koopa_uninstall_rust() {
    koopa_uninstall_app \
        --name='rust' \
        "$@"
}

koopa_uninstall_salmon() {
    koopa_uninstall_app \
        --name='salmon' \
        "$@"
}

koopa_uninstall_sambamba() {
    koopa_uninstall_app \
        --name='sambamba' \
        "$@"
}

koopa_uninstall_samtools() {
    koopa_uninstall_app \
        --name='samtools' \
        "$@"
}

koopa_uninstall_scalene() {
    koopa_uninstall_app \
        --name='scalene' \
        "$@"
}

koopa_uninstall_scons() {
    koopa_uninstall_app \
        --name='scons' \
        "$@"
}

koopa_uninstall_sd() {
    koopa_uninstall_app \
        --name='sd' \
        "$@"
}

koopa_uninstall_sed() {
    koopa_uninstall_app \
        --name='sed' \
        "$@"
}

koopa_uninstall_serf() {
    koopa_uninstall_app \
        --name='serf' \
        "$@"
}

koopa_uninstall_shellcheck() {
    koopa_uninstall_app \
        --name='shellcheck' \
        "$@"
}

koopa_uninstall_shunit2() {
    koopa_uninstall_app \
        --name='shunit2' \
        "$@"
}

koopa_uninstall_snakefmt() {
    koopa_uninstall_app \
        --name='snakefmt' \
        "$@"
}

koopa_uninstall_snakemake() {
    koopa_uninstall_app \
        --name='snakemake' \
        "$@"
}

koopa_uninstall_sox() {
    koopa_uninstall_app \
        --name='sox' \
        "$@"
}

koopa_uninstall_spdlog() {
    koopa_uninstall_app \
        --name='spdlog' \
        "$@"
}

koopa_uninstall_sqlite() {
    koopa_uninstall_app \
        --name='sqlite' \
        "$@"
}

koopa_uninstall_sra_tools() {
    koopa_uninstall_app \
        --name='sra-tools' \
        "$@"
}

koopa_uninstall_star_fusion() {
    koopa_uninstall_app \
        --name='star-fusion' \
        "$@"
}

koopa_uninstall_star() {
    koopa_uninstall_app \
        --name='star' \
        "$@"
}

koopa_uninstall_starship() {
    koopa_uninstall_app \
        --name='starship' \
        "$@"
}

koopa_uninstall_stow() {
    koopa_uninstall_app \
        --name='stow' \
        "$@"
}

koopa_uninstall_subversion() {
    koopa_uninstall_app \
        --name='subversion' \
        "$@"
}

koopa_uninstall_swig() {
    koopa_uninstall_app \
        --name='swig' \
        "$@"
}

koopa_uninstall_system_homebrew() {
    koopa_uninstall_app \
        --name='homebrew' \
        --system \
        "$@"
}

koopa_uninstall_system_vscode_server() {
    koopa_uninstall_app \
        --name='vscode-server' \
        --system \
        "$@"
}

koopa_uninstall_taglib() {
    koopa_uninstall_app \
        --name='taglib' \
        "$@"
}

koopa_uninstall_tar() {
    koopa_uninstall_app \
        --name='tar' \
        "$@"
}

koopa_uninstall_tcl_tk() {
    koopa_uninstall_app \
        --name='tcl-tk' \
        "$@"
}

koopa_uninstall_tealdeer() {
    koopa_uninstall_app \
        --name='tealdeer' \
        "$@"
}

koopa_uninstall_termcolor() {
    koopa_uninstall_app \
        --name='termcolor' \
        "$@"
}

koopa_uninstall_texinfo() {
    koopa_uninstall_app \
        --name='texinfo' \
        "$@"
}

koopa_uninstall_tl_expected() {
    koopa_uninstall_app \
        --name='tl-expected' \
        "$@"
}

koopa_uninstall_tmux() {
    koopa_uninstall_app \
        --name='tmux' \
        "$@"
}

koopa_uninstall_tokei() {
    koopa_uninstall_app \
        --name='tokei' \
        "$@"
}

koopa_uninstall_tree_sitter() {
    koopa_uninstall_app \
        --name='tree-sitter' \
        "$@"
}

koopa_uninstall_tree() {
    koopa_uninstall_app \
        --name='tree' \
        "$@"
}

koopa_uninstall_tuc() {
    koopa_uninstall_app \
        --name='tuc' \
        "$@"
}

koopa_uninstall_udunits() {
    koopa_uninstall_app \
        --name='udunits' \
        "$@"
}

koopa_uninstall_unibilium() {
    koopa_uninstall_app \
        --name='unibilium' \
        "$@"
}

koopa_uninstall_units() {
    koopa_uninstall_app \
        --name='units' \
        "$@"
}

koopa_uninstall_unzip() {
    koopa_uninstall_app \
        --name='unzip' \
        "$@"
}

koopa_uninstall_user_doom_emacs() {
    koopa_uninstall_app \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}

koopa_uninstall_user_prelude_emacs() {
    koopa_uninstall_app \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        --user \
        "$@"
}

koopa_uninstall_user_spacemacs() {
    koopa_uninstall_app \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        --user \
        "$@"
}

koopa_uninstall_user_spacevim() {
    koopa_uninstall_app \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --user \
        "$@"
}

koopa_uninstall_utf8proc() {
    koopa_uninstall_app \
        --name='utf8proc' \
        "$@"
}

koopa_uninstall_vim() {
    koopa_uninstall_app \
        --name='vim' \
        "$@"
}

koopa_uninstall_visidata() {
    koopa_uninstall_app \
        --name='visidata' \
        "$@"
}

koopa_uninstall_vulture() {
    koopa_uninstall_app \
        --name='vulture' \
        "$@"
}

koopa_uninstall_wget() {
    koopa_uninstall_app \
        --name='wget' \
        "$@"
}

koopa_uninstall_which() {
    koopa_uninstall_app \
        --name='which' \
        "$@"
}

koopa_uninstall_xorg_libice() {
    koopa_uninstall_app \
        --name='xorg-libice' \
        "$@"
}

koopa_uninstall_xorg_libpthread_stubs() {
    koopa_uninstall_app \
        --name='xorg-libpthread-stubs' \
        "$@"
}

koopa_uninstall_xorg_libsm() {
    koopa_uninstall_app \
        --name='xorg-libsm' \
        "$@"
}

koopa_uninstall_xorg_libx11() {
    koopa_uninstall_app \
        --name='xorg-libx11' \
        "$@"
}

koopa_uninstall_xorg_libxau() {
    koopa_uninstall_app \
        --name='xorg-libxau' \
        "$@"
}

koopa_uninstall_xorg_libxcb() {
    koopa_uninstall_app \
        --name='xorg-libxcb' \
        "$@"
}

koopa_uninstall_xorg_libxdmcp() {
    koopa_uninstall_app \
        --name='xorg-libxdmcp' \
        "$@"
}

koopa_uninstall_xorg_libxext() {
    koopa_uninstall_app \
        --name='xorg-libxext' \
        "$@"
}

koopa_uninstall_xorg_libxrandr() {
    koopa_uninstall_app \
        --name='xorg-libxrandr' \
        "$@"
}

koopa_uninstall_xorg_libxrender() {
    koopa_uninstall_app \
        --name='xorg-libxrender' \
        "$@"
}

koopa_uninstall_xorg_libxt() {
    koopa_uninstall_app \
        --name='xorg-libxt' \
        "$@"
}

koopa_uninstall_xorg_xcb_proto() {
    koopa_uninstall_app \
        --name='xorg-xcb-proto' \
        "$@"
}

koopa_uninstall_xorg_xorgproto() {
    koopa_uninstall_app \
        --name='xorg-xorgproto' \
        "$@"
}

koopa_uninstall_xorg_xtrans() {
    koopa_uninstall_app \
        --name='xorg-xtrans' \
        "$@"
}

koopa_uninstall_xsv() {
    koopa_uninstall_app \
        --name='xsv' \
        "$@"
}

koopa_uninstall_xxhash() {
    koopa_uninstall_app \
        --name='xxhash' \
        "$@"
}

koopa_uninstall_xz() {
    koopa_uninstall_app \
        --name='xz' \
        "$@"
}

koopa_uninstall_yaml_cpp() {
    koopa_uninstall_app \
        --name='yaml-cpp' \
        "$@"
}

koopa_uninstall_yarn() {
    koopa_uninstall_app \
        --name='yarn' \
        "$@"
}

koopa_uninstall_yq() {
    koopa_uninstall_app \
        --name='yq' \
        "$@"
}

koopa_uninstall_yt_dlp() {
    koopa_uninstall_app \
        --name='yt-dlp' \
        "$@"
}

koopa_uninstall_zellij() {
    koopa_uninstall_app \
        --name='zellij' \
        "$@"
}

koopa_uninstall_zip() {
    koopa_uninstall_app \
        --name='zip' \
        "$@"
}

koopa_uninstall_zlib() {
    koopa_uninstall_app \
        --name='zlib' \
        "$@"
}

koopa_uninstall_zoxide() {
    koopa_uninstall_app \
        --name='zoxide' \
        "$@"
}

koopa_uninstall_zsh() {
    koopa_uninstall_app \
        --name='zsh' \
        "$@"
}

koopa_uninstall_zstd() {
    koopa_uninstall_app \
        --name='zstd' \
        "$@"
}

koopa_unlink_in_bin() {
    __koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(koopa_bin_prefix)" \
        "$@"
}

koopa_unlink_in_make() {
    local app_prefix dict files
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['app_prefix']=''
        ['make_prefix']="$(koopa_make_prefix)"
    )
    koopa_assert_is_dir "${dict['make_prefix']}"
    for app_prefix in "$@"
    do
        dict['app_prefix']="$app_prefix"
        koopa_assert_is_dir "${dict['app_prefix']}"
        dict['app_prefix']="$(koopa_realpath "${dict['app_prefix']}")"
        readarray -t files <<< "$( \
            koopa_find_symlinks \
                --source-prefix="${dict['app_prefix']}" \
                --target-prefix="${dict['make_prefix']}" \
                --verbose \
        )"
        if koopa_is_array_empty "${files[@]:-}"
        then
            koopa_stop "No files from '${dict['app_prefix']}' detected."
        fi
        koopa_alert "$(koopa_ngettext \
            --prefix='Unlinking ' \
            --num="${#files[@]}" \
            --msg1='file' \
            --msg2='files' \
            --suffix=" from '${dict['app_prefix']}' in \
'${dict['make_prefix']}'." \
        )"
        for file in "${files[@]}"
        do
            koopa_rm "$file"
        done
    done
    return 0
}

koopa_unlink_in_man1() {
    __koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(koopa_man_prefix)/man1" \
        "$@"
}

koopa_unlink_in_opt() {
    __koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(koopa_opt_prefix)" \
        "$@"
}

koopa_update_app() {
    local bool dict
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A bool=(
        ['prefix_check']=1
        ['quiet']=0
        ['update_ldconfig']=0
        ['verbose']=0
    )
    declare -A dict=(
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['mode']='shared'
        ['name']=''
        ['opt_prefix']="$(koopa_opt_prefix)"
        ['platform']='common'
        ['prefix']=''
        ['tmp_dir']="$(koopa_tmp_dir)"
        ['updater_bn']=''
        ['updater_fun']='main'
        ['version']=''
    )
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
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
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
            '--updater='*)
                dict['updater_bn']="${1#*=}"
                shift 1
                ;;
            '--updater')
                dict['updater_bn']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            '--no-prefix-check')
                bool['prefix_check']=0
                shift 1
                ;;
            '--quiet')
                bool['quiet']=1
                shift 1
                ;;
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            '--verbose')
                dict['verbose']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--name' "${dict['name']}"
    [[ "${bool['verbose']}" -eq 1 ]] && set -o xtrace
    case "${dict['mode']}" in
        'shared')
            if [[ -z "${dict['prefix']}" ]]
            then
                dict['prefix']="${dict['opt_prefix']}/${dict['name']}"
            fi
            ;;
        'system')
            koopa_assert_is_admin
            koopa_is_linux && bool['update_ldconfig']=1
            ;;
    esac
    if [[ -n "${dict['prefix']}" ]]
    then
        if [[ ! -d "${dict['prefix']}" ]] && \
            [[ "${bool['prefix_check']}" -eq 1 ]]
        then
            koopa_alert_is_not_installed "${dict['name']}" "${dict['prefix']}"
            return 1
        fi
        dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    fi
    [[ -z "${dict['updater_bn']}" ]] && dict['updater_bn']="${dict['name']}"
    dict['updater_file']="${dict['koopa_prefix']}/lang/shell/bash/include/\
update/${dict['platform']}/${dict['mode']}/${dict['updater_bn']}.sh"
    koopa_assert_is_file "${dict['updater_file']}"
    source "${dict['updater_file']}"
    koopa_assert_is_function "${dict['updater_fun']}"
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        if [[ -d "${dict['prefix']}" ]]
        then
            koopa_alert_update_start "${dict['name']}" "${dict['prefix']}"
        else
            koopa_alert_update_start "${dict['name']}"
        fi
    fi
    (
        koopa_cd "${dict['tmp_dir']}"
        PATH='/usr/bin:/bin'
        export PATH
        if koopa_is_linux && \
            [[ -x '/usr/bin/pkg-config' ]]
        then
            koopa_activate_pkg_config \
                '/usr/bin/pkg-config'
        fi
        export UPDATE_PREFIX="${dict['prefix']}"
        "${dict['updater_fun']}"
    )
    koopa_rm "${dict['tmp_dir']}"
    case "${dict['mode']}" in
        'shared')
            [[ -d "${dict['prefix']}" ]] && \
                koopa_sys_set_permissions \
                    --recursive "${dict['prefix']}"
            ;;
        'system')
            [[ "${bool['update_ldconfig']}" -eq 1 ]] && \
                koopa_linux_update_ldconfig
            ;;
        'user')
            [[ -d "${dict['prefix']}" ]] && \
                koopa_sys_set_permissions \
                    --recursive --user "${dict['prefix']}"
            ;;
    esac
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        if [[ -d "${dict['prefix']}" ]]
        then
            koopa_alert_update_success "${dict['name']}" "${dict['prefix']}"
        else
            koopa_alert_update_success "${dict['name']}"
        fi
    fi
    return 0
}

koopa_update_koopa() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['prefix']="$(koopa_koopa_prefix)"
        ['user']="$(koopa_user)"
    )
    if ! koopa_is_git_repo_top_level "${dict['prefix']}"
    then
        koopa_alert_note "Pinned release detected at '${dict['prefix']}'."
        return 1
    fi
    if koopa_is_shared_install
    then
        koopa_alert "Resetting permissions at '${dict['prefix']}'."
        koopa_chown --recursive --sudo "${dict['user']}" "${dict['prefix']}"
    fi
    koopa_git_pull "${dict['prefix']}"
    koopa_alert "Resetting permissions at '${dict['prefix']}'."
    koopa_sys_set_permissions --recursive "${dict['prefix']}"
    koopa_fix_zsh_permissions
    return 0
}

koopa_update_r_packages() {
    koopa_update_app \
        --name='r-packages' \
        --no-prefix-check \
        "$@"
}

koopa_update_system_homebrew() {
    koopa_update_app \
        --name='homebrew' \
        --system \
        "$@"
}

koopa_update_system_tex_packages() {
    koopa_update_app \
        --name='tex-packages' \
        --system \
        "$@"
}

koopa_validate_json() {
    local app dict
    declare -A app
    declare -A dict
    koopa_assert_has_args_eq "$#" 1
    app['python']="$(koopa_locate_python)"
    dict['file']="${1:?}"
    "${app['python']}" -m 'json.tool' "${dict['file']}" >/dev/null
}

koopa_version_pattern() {
    koopa_assert_has_no_args "$#"
    koopa_print '[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([+a-z])?([0-9]+)?'
    return 0
}

koopa_view_latest_tmp_log_file() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['tail']="$(koopa_locate_tail)"
    )
    [[ -x "${app['tail']}" ]] || return 1
    declare -A dict=(
        ['tmp_dir']="${TMPDIR:-/tmp}"
        ['user_id']="$(koopa_user_id)"
    )
    dict['log_file']="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="koopa-${dict['user_id']}-*" \
            --prefix="${dict['tmp_dir']}" \
            --sort \
            --type='f' \
        | "${app['tail']}" -n 1 \
    )"
    if [[ ! -f "${dict['log_file']}" ]]
    then
        koopa_stop "No koopa log file detected in '${dict['tmp_dir']}'."
    fi
    koopa_alert "Viewing '${dict['log_file']}'."
    koopa_pager +G "${dict['log_file']}"
    return 0
}

koopa_warn_if_export() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if koopa_is_export "$arg"
        then
            koopa_warn "'${arg}' is exported."
        fi
    done
    return 0
}

koopa_warn() {
    __koopa_msg 'magenta-bold' 'magenta' '!!' "$@" >&2
    return 0
}

koopa_wget_recursive() {
    local app dict wget_args
    koopa_assert_has_args "$#"
    declare -A app=(
        ['wget']="$(koopa_locate_wget)"
    )
    [[ -x "${app['wget']}" ]] || return 1
    declare -A dict=(
        ['datetime']="$(koopa_datetime)"
        ['password']=''
        ['url']=''
        ['user']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--password='*)
                dict['password']="${1#*=}"
                shift 1
                ;;
            '--password')
                dict['password']="${2:?}"
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
            '--user='*)
                dict['user']="${1#*=}"
                shift 1
                ;;
            '--user')
                dict['user']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--password' "${dict['password']}" \
        '--url' "${dict['url']}" \
        '--user' "${dict['user']}"
    dict['log_file']="wget-${dict['datetime']}.log"
    dict['password']="${dict['password']@Q}"
    wget_args=(
        "--output-file=${dict['log_file']}"
        "--password=${dict['password']}"
        "--user=${dict['user']}"
        '--continue'
        '--debug'
        '--no-parent'
        '--recursive'
        "${dict['url']}"/*
    )
    "${app['wget']}" "${wget_args[@]}"
    return 0
}

koopa_which_function() {
    local dict
    koopa_assert_has_args_eq "$#" 1
    [[ -z "${1:-}" ]] && return 1
    declare -A dict=(
        ['input_key']="${1:?}"
    )
    if koopa_is_function "${dict['input_key']}"
    then
        koopa_print "${dict['input_key']}"
        return 0
    fi
    dict['key']="${dict['input_key']}"
    dict['key']="${dict['key']//-/_}"
    dict['key']="${dict['key']//\./}"
    dict['os_id']="$(koopa_os_id)"
    if koopa_is_function "koopa_${dict['os_id']}_${dict['key']}"
    then
        dict['fun']="koopa_${dict['os_id']}_${dict['key']}"
    elif koopa_is_rhel_like && \
        koopa_is_function "koopa_rhel_${dict['key']}"
    then
        dict['fun']="koopa_rhel_${dict['key']}"
    elif koopa_is_debian_like && \
        koopa_is_function "koopa_debian_${dict['key']}"
    then
        dict['fun']="koopa_debian_${dict['key']}"
    elif koopa_is_fedora_like && \
        koopa_is_function "koopa_fedora_${dict['key']}"
    then
        dict['fun']="koopa_fedora_${dict['key']}"
    elif koopa_is_linux && \
        koopa_is_function "koopa_linux_${dict['key']}"
    then
        dict['fun']="koopa_linux_${dict['key']}"
    else
        dict['fun']="koopa_${dict['key']}"
    fi
    koopa_is_function "${dict['fun']}" || return 1
    koopa_print "${dict['fun']}"
    return 0
}

koopa_which_realpath() {
    local cmd
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        cmd="$(koopa_which "$cmd")"
        [[ -n "$cmd" ]] || return 1
        cmd="$(koopa_realpath "$cmd")"
        [[ -x "$cmd" ]] || return 1
        koopa_print "$cmd"
    done
    return 0
}

koopa_which() {
    local cmd
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        if koopa_is_alias "$cmd"
        then
            unalias "$cmd"
        elif koopa_is_function "$cmd"
        then
            unset -f "$cmd"
        fi
        cmd="$(command -v "$cmd")"
        [[ -x "$cmd" ]] || return 1
        koopa_print "$cmd"
    done
    return 0
}

koopa_write_string() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['file']=''
        ['string']=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--string' "${dict['string']}"
    dict['parent_dir']="$(koopa_dirname "${dict['file']}")"
    if [[ ! -d "${dict['parent_dir']}" ]]
    then
        koopa_mkdir "${dict['parent_dir']}"
    fi
    koopa_print "${dict['string']}" > "${dict['file']}"
    return 0
}
