#!/bin/sh
# shellcheck disable=all

__koopa_alert_process_start() {
    local dict
    declare -A dict
    dict[word]="${1:?}"
    shift 1
    koopa_assert_has_args_le "$#" 3
    dict[name]="${1:?}"
    dict[version]=''
    dict[prefix]=''
    if [[ "$#" -eq 2 ]]
    then
        dict[prefix]="${2:?}"
    elif [[ "$#" -eq 3 ]]
    then
        dict[version]="${2:?}"
        dict[prefix]="${3:?}"
    fi
    if [[ -n "${dict[prefix]}" ]] && [[ -n "${dict[version]}" ]]
    then
        dict[out]="${dict[word]} '${dict[name]}' ${dict[version]} \
at '${dict[prefix]}'."
    elif [[ -n "${dict[prefix]}" ]]
    then
        dict[out]="${dict[word]} '${dict[name]}' at '${dict[prefix]}'."
    else
        dict[out]="${dict[word]} '${dict[name]}'."
    fi
    koopa_alert "${dict[out]}"
    return 0
}

__koopa_alert_process_success() {
    local dict
    declare -A dict
    dict[word]="${1:?}"
    shift 1
    koopa_assert_has_args_le "$#" 2
    dict[name]="${1:?}"
    dict[prefix]="${2:-}"
    if [[ -n "${dict[prefix]}" ]]
    then
        dict[out]="${dict[word]} of '${dict[name]}' at '${dict[prefix]}' \
was successful."
    else
        dict[out]="${dict[word]} of '${dict[name]}' was successful."
    fi
    koopa_alert_success "${dict[out]}"
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
        [file]=''
        [mode]=''
        [pattern]=''
        [stdin]=1
        [sudo]=0
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict[file]="${1#*=}"
                dict[stdin]=0
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                dict[stdin]=0
                shift 2
                ;;
            '--mode='*)
                dict[mode]="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict[mode]="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            '--sudo')
                dict[sudo]=1
                shift 1
                ;;
            '-')
                dict[stdin]=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${dict[stdin]}" -eq 1 ]]
    then
        dict[file]="$(</dev/stdin)"
    fi
    koopa_assert_is_set \
        '--file' "${dict[file]}" \
        '--mode' "${dict[mode]}" \
        '--pattern' "${dict[pattern]}"
    grep_args=(
        '--boolean'
        '--file' "${dict[file]}"
        '--mode' "${dict[mode]}"
        '--pattern' "${dict[pattern]}"
    )
    [[ "${dict[sudo]}" -eq 1 ]] && grep_args+=('--sudo')
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
        [emoji]="$(koopa_acid_emoji)"
        [level]="${1:?}"
    )
    shift 1
    case "${dict[level]}" in
        '1')
            koopa_print ''
            dict[prefix]='#'
            ;;
        '2')
            dict[prefix]='##'
            ;;
        '3')
            dict[prefix]='###'
            ;;
        '4')
            dict[prefix]='####'
            ;;
        '5')
            dict[prefix]='#####'
            ;;
        '6')
            dict[prefix]='######'
            ;;
        '7')
            dict[prefix]='#######'
            ;;
        *)
            koopa_stop 'Invalid header level.'
            ;;
    esac
    __koopa_msg 'magenta' 'default' "${dict[emoji]} ${dict[prefix]}" "$@"
    return 0
}

__koopa_is_ssh_enabled() {
    local app dict
    koopa_assert_has_args_eq "$#" 2
    declare -A app=(
        [ssh]="$(koopa_locate_ssh)"
    )
    [[ -x "${app[ssh]}" ]] || return 1
    declare -A dict=(
        [url]="${1:?}"
        [pattern]="${2:?}"
    )
    dict[str]="$( \
        "${app[ssh]}" -T \
            -o StrictHostKeyChecking='no' \
            "${dict[url]}" 2>&1 \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_str_detect_fixed \
        --string="${dict[str]}" \
        --pattern="${dict[pattern]}"
}

__koopa_link_in_dir() {
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [allow_missing]=0
        [prefix]=''
        [quiet]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--allow-missing')
                dict[allow_missing]=1
                shift 1
                ;;
            '--quiet')
                dict[quiet]=1
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
    koopa_assert_has_args_ge "$#" 2
    koopa_assert_is_set '--prefix' "${dict[prefix]}"
    [[ ! -d "${dict[prefix]}" ]] && koopa_mkdir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    while [[ "$#" -ge 2 ]]
    do
        local dict2
        declare -A dict2=(
            [source_file]="${1:?}"
            [target_name]="${2:?}"
        )
        dict2[target_file]="${dict[prefix]}/${dict2[target_name]}"
        if [[ ! -e "${dict2[source_file]}" ]] && \
            [[ "${dict[allow_missing]}" -eq 0 ]]
        then
            if [[ "${dict[quiet]}" -eq 0 ]]
            then
                koopa_alert_note "Skipping link of '${dict2[source_file]}'."
            fi
            return 0
        fi
        if [[ "${dict[quiet]}" -eq 0 ]]
        then
            koopa_alert "Linking '${dict2[source_file]}' -> \
'${dict2[target_file]}'."
        fi
        koopa_sys_ln "${dict2[source_file]}" "${dict2[target_file]}"
        shift 2
    done
    return 0
}

__koopa_list_path_priority_unique() {
    local app str
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [tac]="$(koopa_locate_tac)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[tac]}" ]] || return 1
    str="$( \
        __koopa_list_path_priority "$@" \
            | "${app[tac]}" \
            | "${app[awk]}" '!a[$0]++' \
            | "${app[tac]}" \
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
        [label]="$(printf '%10s\n' "${1:?}")"
        [color]="$(__koopa_ansi_escape "${2:?}")"
        [nocolor]="$(__koopa_ansi_escape 'nocolor')"
    )
    shift 2
    for string in "$@"
    do
        string="${dict[color]}${dict[label]}${dict[nocolor]} | ${string}"
        koopa_print "$string"
    done
    return 0
}

__koopa_str_detect() {
    local dict grep_args
    koopa_assert_has_args "$#"
    declare -A dict=(
        [mode]=''
        [pattern]=''
        [stdin]=1
        [string]=''
        [sudo]=0
    )
    while (("$#"))
    do
        case "$1" in
            '--mode='*)
                dict[mode]="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict[mode]="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict[string]="${1#*=}"
                dict[stdin]=0
                shift 1
                ;;
            '--string')
                dict[string]="${2:-}"
                dict[stdin]=0
                shift 2
                ;;
            '--sudo')
                dict[sudo]=1
                shift 1
                ;;
            '-')
                dict[stdin]=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${dict[stdin]}" -eq 1 ]]
    then
        dict[string]="$(</dev/stdin)"
    fi
    koopa_assert_is_set \
        '--mode' "${dict[mode]}" \
        '--pattern' "${dict[pattern]}"
    grep_args=(
        '--boolean'
        '--mode' "${dict[mode]}"
        '--pattern' "${dict[pattern]}"
        '--string' "${dict[string]}"
    )
    [[ "${dict[sudo]}" -eq 1 ]] && grep_args+=('--sudo')
    koopa_grep "${grep_args[@]}"
}

__koopa_unlink_in_dir() {
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [prefix]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
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
    koopa_assert_is_set '--prefix' "${dict[prefix]}"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    names=("$@")
    files=()
    for i in "${!names[@]}"
    do
        files+=("${dict[prefix]}/${names[$i]}")
    done
    koopa_rm "${files[@]}"
    return 0
}

koopa_acid_emoji() {
    koopa_print '🧪'
}

koopa_activate_build_opt_prefix() {
    koopa_activate_opt_prefix --build-only "$@"
}

koopa_activate_ensembl_perl_api() {
    local dict
    declare -A dict=(
        [prefix]="$(koopa_ensembl_perl_api_prefix)"
    )
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_add_to_path_start "${dict[prefix]}/ensembl-git-tools/bin"
    PERL5LIB="${PERL5LIB:-}"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/bioperl-1.6.924"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/ensembl/modules"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/ensembl-compara/modules"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/ensembl-variation/modules"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/ensembl-funcgen/modules"
    export PERL5LIB
    return 0
}

koopa_activate_opt_prefix() {
    local app dict name pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [pkg_config]="$(koopa_locate_pkg_config --allow-missing)"
    )
    declare -A dict=(
        [build_only]=0
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--build-only')
                dict[build_only]=1
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
    for name in "$@"
    do
        local current_ver expected_ver pkgconfig_dirs prefix
        prefix="${dict[opt_prefix]}/${name}"
        koopa_assert_is_dir "$prefix"
        current_ver="$(koopa_opt_version "$name")"
        expected_ver="$(koopa_variable "$name")"
        if [[ "$current_ver" != "$expected_ver" ]]
        then
            koopa_stop "'${name}' version mismatch at '${prefix}' \
(${current_ver} != ${expected_ver})."
        fi
        if koopa_is_empty_dir "$prefix"
        then
            koopa_stop "'${prefix}' is empty."
        fi
        prefix="$(koopa_realpath "$prefix")"
        if [[ "${dict[build_only]}" -eq 1 ]]
        then
            koopa_alert "Activating '${prefix}' (build only)."
        else
            koopa_alert "Activating '${prefix}'."
        fi
        koopa_add_to_path_start "${prefix}/bin"
        readarray -t pkgconfig_dirs <<< "$( \
            koopa_find \
                --pattern='pkgconfig' \
                --prefix="$prefix" \
                --sort \
                --type='d' \
            || true \
        )"
        if koopa_is_array_non_empty "${pkgconfig_dirs:-}"
        then
            koopa_add_to_pkg_config_path "${pkgconfig_dirs[@]}"
        fi
        [[ "${dict[build_only]}" -eq 1 ]] && continue
        if koopa_is_array_non_empty "${pkgconfig_dirs:-}"
        then
            local cflags ldflags ldlibs pc_files
            if [[ ! -x "${app[pkg_config]}" ]]
            then
                koopa_stop "'pkg-config' is not installed."
            fi
            readarray -t pc_files <<< "$( \
                koopa_find \
                    --prefix="$prefix" \
                    --type='f' \
                    --pattern='*.pc' \
                    --sort \
            )"
            cflags="$("${app[pkg_config]}" --cflags "${pc_files[@]}")"
            [[ -n "$cflags" ]] && CPPFLAGS="${CPPFLAGS:-} ${cflags}"
            ldflags="$("${app[pkg_config]}" --libs-only-L "${pc_files[@]}")"
            [[ -n "$ldflags" ]] && LDFLAGS="${LDFLAGS:-} ${ldflags}"
            ldlibs="$("${app[pkg_config]}" --libs-only-l "${pc_files[@]}")"
            [[ -n "$ldlibs" ]] && LDLIBS="${LDLIBS:-} ${ldlibs}"
        else

            [[ -d "${prefix}/include" ]] && \
                CPPFLAGS="${CPPFLAGS:-} -I${prefix}/include"
            [[ -d "${prefix}/lib" ]] && \
                LDFLAGS="${LDFLAGS:-} -L${prefix}/lib"
            [[ -d "${prefix}/lib64" ]] && \
                LDFLAGS="${LDFLAGS:-} -L${prefix}/lib64"
        fi
        koopa_add_rpath_to_ldflags \
            "${prefix}/lib" \
            "${prefix}/lib64"
    done
    export CPPFLAGS LDFLAGS LDLIBS
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
        [koopa_prefix]="${1:-}"
        [make_prefix]='/usr/local'
    )
    if [[ -z "${dict[koopa_prefix]}" ]]
    then
        dict[koopa_prefix]="$(koopa_koopa_prefix)"
    fi
    dict[source_link]="${dict[koopa_prefix]}/bin/koopa"
    dict[target_link]="${dict[make_prefix]}/bin/koopa"
    [[ -d "${dict[make_prefix]}" ]] || return 0
    [[ -L "${dict[target_link]}" ]] && return 0
    koopa_alert "Adding 'koopa' link inside '${dict[make_prefix]}'."
    koopa_ln --sudo "${dict[source_link]}" "${dict[target_link]}"
    return 0
}

koopa_add_monorepo_config_link() {
    local dict subdir
    koopa_assert_has_args "$#"
    koopa_assert_has_monorepo
    declare -A dict=(
        [prefix]="$(koopa_monorepo_prefix)"
    )
    for subdir in "$@"
    do
        koopa_add_config_link \
            "${dict[prefix]}/${subdir}" \
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

koopa_add_to_pkg_config_path_2() {
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
        [file]="$(koopa_find_user_profile)"
    )
    koopa_alert "Adding koopa activation to '${dict[file]}'."
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
        --file="${dict[file]}" \
        --string="\n${dict[string]}"
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

koopa_anaconda_version() {
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [conda]="${1:-}"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -z "${app[conda]}" ]] && app[conda]="$(koopa_locate_anaconda)"
    [[ -x "${app[conda]}" ]] || return 1
    koopa_is_anaconda "${app[conda]}" || return 1
    str="$( \
        "${app[conda]}" list 'anaconda' \
            | koopa_grep \
                --pattern='^anaconda ' \
                --regex \
            | "${app[awk]}" '{print $2}' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_app_prefix() {
    local dict
    koopa_assert_has_args_le "$#" 1
    declare -A dict
    dict[name]="${1:-}"
    if [[ -n "${dict[name]}" ]]
    then
        dict[opt_prefix]="$(koopa_opt_prefix)"
        dict[str]="${dict[opt_prefix]}/${dict[name]}"
        [[ -d "${dict[str]}" ]] || return 1
        dict[str]="$(koopa_realpath "${dict[str]}")"
    else
        dict[str]="$(koopa_koopa_prefix)/app"
    fi
    koopa_print "${dict[str]}"
    return 0
}

koopa_append_string() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [file]=''
        [string]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict[file]="${1#*=}"
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict[string]="${1#*=}"
                shift 1
                ;;
            '--string')
                dict[string]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--file' "${dict[file]}" \
        '--string' "${dict[string]}"
    if [[ ! -f "${dict[file]}" ]]
    then
        koopa_mkdir "$(koopa_dirname "${dict[file]}")"
        koopa_touch "${dict[file]}"
    fi
    koopa_print "${dict[string]}" >> "${dict[file]}"
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

koopa_armadillo_version() {
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config \
        --opt-name='armadillo' \
        --pc-name='armadillo'
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
        [pattern]=''
        [string]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict[string]="${1#*=}"
                shift 1
                ;;
            '--string')
                dict[string]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--pattern' "${dict[pattern]}" \
        '--string' "${dict[string]}"
    if ! koopa_str_detect_fixed \
        --pattern="${dict[pattern]}" \
        --string="${dict[string]}"
    then
        koopa_stop "'${dict[string]}' doesn't match '${dict[pattern]}'."
    fi
    return 0
}

koopa_assert_is_matching_regex() {
    declare -A dict=(
        [pattern]=''
        [string]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict[string]="${1#*=}"
                shift 1
                ;;
            '--string')
                dict[string]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--pattern' "${dict[pattern]}" \
        '--string' "${dict[string]}"
    if ! koopa_str_detect_regex \
        --pattern="${dict[pattern]}" \
        --string="${dict[string]}"
    then
        koopa_stop "'${dict[string]}' doesn't match regex '${dict[pattern]}'."
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
        koopa_dl 'Args' "$*"
        koopa_stop 'Required R packages missing.'
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
        [aws]="$(koopa_locate_aws)"
    )
    [[ -x "${app[aws]}" ]] || return 1
    declare -A dict=(
        [file]="$(koopa_tmp_file)"
        [profile]="${AWS_PROFILE:-}"
        [url]="${BATCH_FILE_URL:?}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    case "${dict[url]}" in
        'ftp://'* | \
        'http://'*)
            koopa_download "${dict[url]}" "${dict[file]}"
            ;;
        's3://'*)
            "${app[aws]}" --profile="${dict[profile]}" \
                s3 cp "${dict[url]}" "${dict[file]}"
            ;;
        *)
            koopa_stop "Unsupported URL: '${dict[url]}'."
            ;;
    esac
    koopa_chmod 'u+x' "${dict[file]}"
    "${dict[file]}"
    return 0
}

koopa_aws_batch_list_jobs() {
    local app dict job_queue_array status status_array
    local -A app=(
        [aws]="$(koopa_locate_aws)"
    )
    [[ -x "${app[aws]}" ]] || return 1
    local -A dict=(
        [account_id]="${AWS_BATCH_ACCOUNT_ID:-}"
        [profile]="${AWS_PROFILE:-}"
        [queue]="${AWS_BATCH_QUEUE:-}"
        [region]="${AWS_BATCH_REGION:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    while (("$#"))
    do
        case "$1" in
            '--account-id='*)
                dict[account_id]="${1#*=}"
                shift 1
                ;;
            '--account-id')
                dict[account_id]="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            '--queue='*)
                dict[queue]="${1#*=}"
                shift 1
                ;;
            '--queue')
                dict[queue]="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict[region]="${1#*=}"
                shift 1
                ;;
            '--region')
                dict[region]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--account-id or AWS_BATCH_ACCOUNT_ID' "${dict[account_id]:-}" \
        '--queue or AWS_BATCH_QUEUE' "${dict[queue]:-}" \
        '--region or AWS_BATCH_REGION' "${dict[region]:-}" \
        '--profile or AWS_PROFILE' "${dict[profile]:-}"
    koopa_h1 "Checking AWS Batch job status for '${dict[profile]}' profile."
    job_queue_array=(
        'arn'
        'aws'
        'batch'
        "${dict[region]}"
        "${dict[account_id]}"
        "job-queue/${dict[queue]}"
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
    dict[job_queue]="$(koopa_paste --sep=':' "${job_queue_array[@]}")"
    for status in "${status_array[@]}"
    do
        koopa_h2 "$status"
        "${app[aws]}" --profile="${dict[profile]}" \
            batch list-jobs \
                --job-queue "${dict[job_queue]}" \
                --job-status "$status"
    done
    return 0
}

koopa_aws_ec2_instance_id() {
    local app
    declare -A app
    if koopa_is_ubuntu
    then
        app[ec2_metadata]='/usr/bin/ec2metadata'
    else
        app[ec2_metadata]='/usr/bin/ec2-metadata'
    fi
    [[ -x "${app[ec2_metadata]}" ]] || return 1
    str="$("${app[ec2_metadata]}" --instance-id)"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_aws_ec2_suspend() {
    local app dict
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
    )
    [[ -x "${app[aws]}" ]] || return 1
    declare -A dict=(
        [id]="$(koopa_aws_ec2_instance_id)"
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    while (("$#"))
    do
        case "$1" in
            '--profile='*)
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--profile or AWS_PROFILE' "${dict[profile]:-}"
    "${app[aws]}" --profile="${dict[profile]}" \
        ec2 stop-instances --instance-id "${dict[id]}" \
        >/dev/null
    return 0
}

koopa_aws_ec2_terminate() {
    local app dict
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
    )
    [[ -x "${app[aws]}" ]] || return 1
    declare -A dict=(
        [id]="$(koopa_aws_ec2_instance_id)"
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    while (("$#"))
    do
        case "$1" in
            '--profile='*)
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--profile or AWS_PROFILE' "${dict[profile]:-}"
    "${app[aws]}" --profile="${dict[profile]}" \
        ec2 terminate-instances --instance-id "${dict[id]}" \
        >/dev/null
    return 0
}

koopa_aws_s3_cp_regex() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
    )
    [[ -x "${app[aws]}" ]] || return 1
    declare -A dict=(
        [bucket_pattern]='^s3://.+/$'
        [pattern]=''
        [profile]="${AWS_PROFILE:-}"
        [source_prefix]=''
        [target_prefix]=''
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            '--source_prefix='*)
                dict[source_prefix]="${1#*=}"
                shift 1
                ;;
            '--source_prefix')
                dict[source_prefix]="${2:?}"
                shift 2
                ;;
            '--target_prefix='*)
                dict[target_prefix]="${1#*=}"
                shift 1
                ;;
            '--target_prefix')
                dict[target_prefix]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--pattern' "${dict[pattern]}" \
        '--profile or AWS_PROFILE' "${dict[profile]}" \
        '--source-prefix' "${dict[source_prefix]}" \
        '--target-prefix' "${dict[target_prefix]}"
    if ! koopa_str_detect_regex \
            --pattern="${dict[bucket_pattern]}" \
            --string "${dict[source_prefix]}" &&
        ! koopa_str_detect_regex \
            --pattern="${dict[bucket_pattern]}" \
            --string "${dict[target_prefix]}"
    then
        koopa_stop "Souce and or/target must match '${dict[bucket_pattern]}'."
    fi
    "${app[aws]}" --profile="${dict[profile]}" \
        s3 cp \
            --exclude='*' \
            --follow-symlinks \
            --include="${dict[pattern]}" \
            --recursive \
            "${dict[source_prefix]}" \
            "${dict[target_prefix]}"
    return 0
}

koopa_aws_s3_find() {
    local dict exclude_arr include_arr ls_args pattern str
    koopa_assert_has_args "$#"
    declare -A dict=(
        [exclude]=0
        [include]=0
        [prefix]=''
        [profile]="${AWS_PROFILE:-}"
        [recursive]=0
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    exclude_arr=()
    include_arr=()
    while (("$#"))
    do
        case "$1" in
            '--exclude='*)
                dict[exclude]=1
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                dict[exclude]=1
                exclude_arr+=("${2:?}")
                shift 2
                ;;
            '--include='*)
                dict[include]=1
                include_arr+=("${1#*=}")
                shift 1
                ;;
            '--include')
                dict[include]=1
                include_arr+=("${2:?}")
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
            '--profile='*)
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            '--recursive')
                dict[recursive]=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--prefix' "${dict[prefix]}" \
        '--profile or AWS_PROFILE' "${dict[profile]}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict[prefix]}"
    ls_args=(
        '--prefix' "${dict[prefix]}"
        '--profile' "${dict[profile]}"
        '--type' 'f'
    )
    [[ "${dict[recursive]}" -eq 1 ]] && ls_args+=('--recursive')
    str="$(koopa_aws_s3_ls "${ls_args[@]}")"
    [[ -n "$str" ]] || return 1
    if [[ "${dict[exclude]}" -eq 1 ]]
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
                pattern="${dict[prefix]}${pattern}"
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
    if [[ "${dict[include]}" -eq 1 ]]
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
                pattern="${dict[prefix]}${pattern}"
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
        [awk]="$(koopa_locate_awk)"
        [aws]="$(koopa_locate_aws)"
        [jq]="$(koopa_locate_jq)"
        [sort]="$(koopa_locate_sort)"
        [tail]="$(koopa_locate_tail)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[aws]}" ]] || return 1
    [[ -x "${app[jq]}" ]] || return 1
    [[ -x "${app[sort]}" ]] || return 1
    [[ -x "${app[tail]}" ]] || return 1
    declare -A dict=(
        [bucket]=''
        [num]='20'
        [profile]='acidgenomics'
    )
    while (("$#"))
    do
        case "$1" in
            '--bucket='*)
                dict[bucket]="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict[bucket]="${2:?}"
                shift 2
                ;;
            '--num='*)
                dict[num]="${1#*=}"
                shift 1
                ;;
            '--num')
                dict[num]="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bucket' "${dict[bucket]}" \
        '--num' "${dict[num]}" \
        '--profile or AWS_PROFILE' "${dict[profile]}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict[bucket]}"
    dict[bucket]="$( \
        koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict[bucket]}" \
    )"
    dict[bucket]="$(koopa_strip_trailing_slash "${dict[bucket]}")"
    dict[str]="$( \
        "${app[aws]}" --profile="${dict[profile]}" \
            s3api list-object-versions --bucket "${dict[bucket]}" \
            | "${app[jq]}" \
                --raw-output \
                '.Versions[] | "\(.Key)\t \(.Size)"' \
            | "${app[sort]}" --key=2 --numeric-sort \
            | "${app[awk]}" '{ print $1 }' \
            | "${app[tail]}" -n "${dict[num]}" \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

koopa_aws_s3_ls() {
    local app dict ls_args str
    koopa_assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [aws]="$(koopa_locate_aws)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[aws]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    declare -A dict=(
        [prefix]=''
        [profile]="${AWS_PROFILE:-}"
        [recursive]=0
        [type]=''
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    ls_args=()
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            '--type='*)
                dict[type]="${1#*=}"
                shift 1
                ;;
            '--type')
                dict[type]="${2:?}"
                shift 2
                ;;
            '--recursive')
                dict[recursive]=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--prefix' "${dict[prefix]}" \
        '--profile or AWS_PROFILE' "${dict[profile]}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict[prefix]}"
    case "${dict[type]}" in
        '')
            dict[dirs]=1
            dict[files]=1
            ;;
        'd')
            dict[dirs]=1
            dict[files]=0
            ;;
        'f')
            dict[dirs]=0
            dict[files]=1
            ;;
        *)
            koopa_stop "Unsupported type: '${dict[type]}'."
            ;;
    esac
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        ls_args+=('--recursive')
        if [[ "${dict[type]}" == 'd' ]]
        then
            koopa_stop 'Recursive directory listing is not supported.'
        fi
    fi
    str="$( \
        "${app[aws]}" --profile="${dict[profile]}" \
            s3 ls "${ls_args[@]}" "${dict[prefix]}" \
            2>/dev/null \
    )"
    [[ -n "$str" ]] || return 1
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        dict[bucket_prefix]="$( \
            koopa_grep \
                --only-matching \
                --pattern='^s3://[^/]+' \
                --regex \
                --string="${dict[prefix]}" \
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
                | "${app[awk]}" '{print $4}' \
                | "${app[awk]}" 'NF' \
                | "${app[sed]}" "s|^|${dict[bucket_prefix]}/|g" \
                | koopa_grep --pattern='^s3://.+[^/]$' --regex \
        )"
        koopa_print "$files"
        return 0
    fi
    if [[ "${dict[dirs]}" -eq 1 ]]
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
                    | "${app[sed]}" 's|^ \+PRE ||g' \
                    | "${app[awk]}" 'NF' \
                    | "${app[sed]}" "s|^|${dict[prefix]}|g" \
            )"
            koopa_print "$dirs"
        fi
    fi
    if [[ "${dict[files]}" -eq 1 ]]
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
                    | "${app[awk]}" '{print $4}' \
                    | "${app[awk]}" 'NF' \
                    | "${app[sed]}" "s|^|${dict[prefix]}|g" \
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
        [aws]="$(koopa_locate_aws)"
    )
    [[ -x "${app[aws]}" ]] || return 1
    declare -A dict=(
        [prefix]=''
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--profile or AWS_PROFILE' "${dict[profile]:-}"
        '--prefix' "${dict[prefix]:-}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict[prefix]}"
    dict[str]="$( \
        koopa_aws_s3_ls \
            --prefix="${dict[prefix]}" \
            --profile="${dict[profile]}" \
    )"
    if [[ -z "${dict[str]}" ]]
    then
        koopa_stop "No content detected in '${dict[prefix]}'."
    fi
    readarray -t files <<< "${dict[str]}"
    for file in "${files[@]}"
    do
        local dict2
        declare -A dict2=(
            [bn]="$(koopa_basename "$file")"
            [dn1]="$(koopa_dirname "$file")"
        )
        dict2[dn2]="$(koopa_dirname "${dict2[dn1]}")"
        dict2[target]="${dict2[dn2]}/${dict2[bn]}"
        "${app[aws]}" --profile="${dict[profile]}" \
            s3 mv \
                --recursive \
                "${dict2[file]}" \
                "${dict2[target]}"
    done
    return 0
}

koopa_aws_s3_sync() {
    local aws dict exclude_args exclude_patterns pattern pos sync_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
    )
    [[ -x "${app[aws]}" ]] || return 1
    declare -A dict=(
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
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
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            '--source-prefix='*)
                dict[source_prefix]="${1#*=}"
                shift 1
                ;;
            '--source-prefix')
                dict[source_prefix]="${2:?}"
                shift 2
                ;;
            '--target-prefix='*)
                dict[target_prefix]="${1#*=}"
                shift 1
                ;;
            '--target-prefix')
                dict[target_prefix]="${2:?}"
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
            "${dict[source_prefix]}"
            "${dict[target_prefix]}"
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
    "${app[aws]}" --profile="${dict[profile]}" \
        s3 sync \
            "${exclude_args[@]}" \
            "${sync_args[@]}"
    return 0
}

koopa_bam_filter() {
    local bam_file bam_files dir final_output_bam final_output_tail input_bam
    local input_tail output_bam output_tail
    koopa_assert_has_args_le "$#" 1
    dir="${1:-.}"
    koopa_assert_is_dir "$dir"
    dir="$(koopa_realpath "$dir")"
    readarray -t bam_files <<< "$( \
        koopa_find \
            --max-depth=3 \
            --min-depth=1 \
            --pattern='*.sorted.bam' \
            --prefix="$dir" \
            --sort \
            --type='f' \
    )"
    if ! koopa_is_array_non_empty "${bam_files[@]:-}"
    then
        koopa_stop "No BAM files detected in '${dir}'."
    fi
    koopa_h1 "Filtering BAM files in '${dir}'."
    koopa_conda_activate_env 'sambamba'
    for bam_file in "${bam_files[@]}"
    do
        final_output_tail='filtered'
        final_output_bam="${bam_file%.bam}.${final_output_tail}.bam"
        if [[ -f "$final_output_bam" ]]
        then
            koopa_alert_note "Skipping '${final_output_bam}'."
            continue
        fi
        input_bam="$bam_file"
        output_tail='filtered-1-no-duplicates'
        output_bam="${input_bam%.bam}.${output_tail}.bam"
        koopa_sambamba_filter_duplicates \
            --input-bam="$input_bam" \
            --output-bam="$output_bam"
        input_tail="$output_tail"
        input_bam="$output_bam"
        output_tail='filtered-2-no-unmapped'
        output_bam="${input_bam/${input_tail}/${output_tail}}"
        koopa_sambamba_filter_unmapped \
            --input-bam="$input_bam" \
            --output-bam="$output_bam"
        input_tail="$output_tail"
        input_bam="$output_bam"
        output_tail='filtered-3-no-multimappers'
        output_bam="${input_bam/${input_tail}/${output_tail}}"
        koopa_sambamba_filter_multimappers \
            --input-bam="$input_bam" \
            --output-bam="$output_bam"
        koopa_cp "$output_bam" "$final_output_bam"
        koopa_sambamba_index "$final_output_bam"
    done
    koopa_conda_deactivate
    return 0
}

koopa_bam_sort() {
    local bam_file bam_files dir
    koopa_assert_has_args_le "$#" 1
    dir="${1:-.}"
    koopa_assert_is_dir "$dir"
    dir="$(koopa_realpath "$dir")"
    readarray -t bam_files <<< "$( \
        find "$dir" \
            -maxdepth 3 \
            -mindepth 1 \
            -type f \
            -iname '*.bam' \
            -not -iname '*.filtered.*' \
            -not -iname '*.sorted.*' \
            -print \
        | sort \
    )"
    if ! koopa_is_array_non_empty "${bam_files[@]:-}"
    then
        koopa_stop "No BAM files detected in '${dir}'."
    fi
    koopa_h1 "Sorting BAM files in '${dir}'."
    koopa_conda_activate_env 'sambamba'
    for bam_file in "${bam_files[@]}"
    do
        koopa_sambamba_sort "$bam_file"
    done
    koopa_conda_deactivate
    return 0
}

koopa_basename_sans_ext_2() {
    local app file str
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    for file in "$@"
    do
        str="$(koopa_basename "$file")"
        if koopa_has_file_ext "$str"
        then
            str="$( \
                koopa_print "$str" \
                | "${app[cut]}" -d '.' -f '1' \
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
        koopa_print "${arg##*/}"
    done
    return 0
}

koopa_bioconda_autobump_recipe() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [git]="$(koopa_locate_git)"
        [vim]="$(koopa_locate_vim)"
    )
    [[ -x "${app[git]}" ]] || return 1
    [[ -x "${app[vim]}" ]] || return 1
    declare -A dict=(
        [recipe]="${1:?}"
        [repo]="${HOME:?}/git/bioconda-recipes"
    )
    dict[branch]="${dict[recipe]/-/_}"
    koopa_assert_is_dir "${dict[repo]}"
    (
        koopa_cd "${dict[repo]}"
        "${app[git]}" checkout master
        "${app[git]}" fetch --all
        "${app[git]}" pull
        "${app[git]}" checkout \
            -B "${dict[branch]}" \
            "origin/bump/${dict[branch]}"
        koopa_mkdir "recipes/${dict[recipe]}"
        "${app[vim]}" "recipes/${dict[recipe]}/meta.yaml"
    )
    return 0
}

koopa_boost_version() {
    local app dict gcc_args
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bc]="$(koopa_locate_bc)"
        [gcc]="$(koopa_locate_gcc)"
    )
    [[ -x "${app[bc]}" ]] || return 1
    [[ -x "${app[gcc]}" ]] || return 1
    declare -A dict
    gcc_args=()
    if koopa_is_macos
    then
        dict[brew_prefix]="$(koopa_homebrew_prefix)"
        gcc_args+=("-I${dict[brew_prefix]}/opt/boost/include")
    fi
    gcc_args+=(
        '-x' 'c++'
        '-E' '-'
    )
    dict[version]="$( \
        koopa_print '#include <boost/version.hpp>\nBOOST_VERSION' \
        | "${app[gcc]}" "${gcc_args[@]}" \
        | koopa_grep --pattern='^[0-9]+$' --regex \
    )"
    [[ -n "${dict[version]}" ]] || return 1
    dict[major]="$(koopa_print "${dict[version]} / 100000" | "${app[bc]}")"
    dict[minor]="$(koopa_print "${dict[version]} / 100 % 1000" | "${app[bc]}")"
    dict[patch]="$(koopa_print "${dict[version]} % 100" | "${app[bc]}")"
    koopa_print "${dict[major]}.${dict[minor]}.${dict[patch]}"
    return 0
}

koopa_bowtie2_align() {
    local app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'bowtie2'
    declare -A app=(
        [tee]="$(koopa_locate_tee)"
    )
    [[ -x "${app[tee]}" ]] || return 1
    declare -A dict=(
        [threads]="$(koopa_cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1='*)
                dict[fastq_r1]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1')
                dict[fastq_r1]="${2:?}"
                shift 2
                ;;
            '--fastq-r2='*)
                dict[fastq_r2]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2')
                dict[fastq_r2]="${2:?}"
                shift 2
                ;;
            '--index-base='*)
                dict[index_base]="${1#*=}"
                shift 1
                ;;
            '--index-base')
                dict[index_base]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            '--r1-tail='*)
                dict[r1_tail]="${1#*=}"
                shift 1
                ;;
            '--r1-tail')
                dict[r1_tail]="${2:?}"
                shift 2
                ;;
            '--r2-tail='*)
                dict[r2_tail]="${1#*=}"
                shift 1
                ;;
            '--r2-tail')
                dict[r2_tail]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_file "${dict[fastq_r1]}" "${dict[fastq_r2]}"
    dict[fastq_r1_bn]="$(koopa_basename "${dict[fastq_r1]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[r1_tail]}/}"
    dict[fastq_r2_bn]="$(koopa_basename "${dict[fastq_r2]}")"
    dict[fastq_r2_bn]="${dict[fastq_r2_bn]/${dict[r2_tail]}/}"
    koopa_assert_are_identical "${dict[fastq_r1_bn]}" "${dict[fastq_r2_bn]}"
    id="${dict[fastq_r1_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    koopa_h2 "Aligning '${dict[id]}' into '${dict[output_dir]}'."
    koopa_mkdir "${dict[output_dir]}"
    sam_file="${dict[output_dir]}/${dict[id]}.sam"
    log_file="${dict[output_dir]}/align.log"
    align_args=(
        '--local'
        '--sensitive-local'
        '--rg-id' "$id"
        '--rg' 'PL:illumina'
        '--rg' "PU:${id}"
        '--rg' "SM:${id}"
        '--threads' "${dict[threads]}"
        '-1' "$fastq_r1"
        '-2' "$fastq_r2"
        '-S' "$sam_file"
        '-X' 2000
        '-q'
        '-x' "${dict[index_base]}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    bowtie2 "${align_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

koopa_bowtie2_index() {
    local app dict index_args
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'bowtie2-build'
    declare -A app=(
        [tee]="$(koopa_locate_tee)"
    )
    [[ -x "${app[tee]}" ]] || return 1
    declare -A dict=(
        [threads]="$(koopa_cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            '--fasta-file='*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict[fasta_file]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_file "${dict[fasta_file]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note \
            "bowtie2 genome index exists at '${dict[output_dir]}'." \
            "Skipping on-the-fly indexing of '${dict[fasta_file]}'."
        return 0
    fi
    koopa_h2 "Generating bowtie2 index at '${dict[output_dir]}'."
    koopa_mkdir "${dict[output_dir]}"
    dict[index_base]="${dict[output_dir]}/bowtie2"
    dict[log_file]="${dict[output_dir]}/index.log"
    index_args=(
        "--threads=${dict[threads]}"
        '--verbose'
        "${dict[fasta_file]}"
        "${dict[index_base]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    bowtie2-build "${index_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

koopa_bowtie2() {
    local dict fastq_r1_file fastq_r1_files
    declare -A dict=(
        [fastq_dir]=''
        [fastq_r1_tail]='' # '_R1_001.fastq.gz'
        [fastq_r2_tail]='' # '_R2_001.fastq.gz'
        [genome_fasta_file]=''
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--genome-fasta-file='*)
                dict[genome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict[genome_fasta_file]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_h1 'Running bowtie2.'
    koopa_assert_is_file "${dict[fasta_file]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    dict[index_dir]="${dict[output_dir]}/index"
    dict[index_base]="${dict[index_dir]}/bowtie2"
    dict[samples_dir]="${dict[output_dir]}/samples"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[r1_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if [[ "${#fastq_r1_files[@]}" -eq 0 ]]
    then
        koopa_stop "No FASTQ files in '${dict[fastq_dir]}' ending \
with '${dict[r1_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    koopa_bowtie2_index \
        --fasta-file="${dict[fasta_file]}" \
        --output-dir="${dict[index_dir]}"
    koopa_assert_is_dir "${dict[index_dir]}"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local fastq_r2_file
        fastq_r2_file="${fastq_r1_file/${dict[r1_tail]}/${dict[r2_tail]}}"
        koopa_bowtie2_align \
            --fastq-r1="$fastq_r1_file" \
            --fastq-r2="$fastq_r2_file" \
            --index-base="${dict[index_base]}" \
            --output-dir="${dict[samples_dir]}" \
            --r1-tail="${dict[r1_tail]}" \
            --r2-tail="${dict[r2_tail]}"
    done
    koopa_alert_success 'bowtie2 alignment completed successfully.'
    return 0
}

koopa_bpytop_version() {
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [bpytop]="${1:-}"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -z "${app[bpytop]}" ]] && app[bpytop]="$(koopa_locate_bpytop)"
    [[ -x "${app[bpytop]}" ]] || return 1
    str="$( \
        "${app[bpytop]}" --version \
            | koopa_grep --pattern='bpytop version:' \
            | "${app[awk]}" '{ print $NF }' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_brew_cleanup() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    [[ -x "${app[brew]}" ]] || return 1
    "${app[brew]}" cleanup -s || true
    koopa_rm "$("${app[brew]}" --cache)"
    "${app[brew]}" autoremove || true
    return 0
}

koopa_brew_dump_brewfile() {
    local app today
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    [[ -x "${app[brew]}" ]] || return 1
    today="$(koopa_today)"
    "${app[brew]}" bundle dump \
        --file="brewfile-${today}" \
        --force
    return 0
}

koopa_brew_outdated() {
    local app x
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    [[ -x "${app[brew]}" ]] || return 1
    x="$("${app[brew]}" outdated --quiet)"
    koopa_print "$x"
    return 0
}

koopa_brew_reset_core_repo() {
    local app branch origin prefix repo
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[brew]}" ]] || return 1
    [[ -x "${app[git]}" ]] || return 1
    repo='homebrew/core'
    origin='origin'
    (
        prefix="$("${app[brew]}" --repo "$repo")"
        koopa_assert_is_dir "$prefix"
        koopa_cd "$prefix"
        branch="$(koopa_git_default_branch)"
        "${app[git]}" checkout -q "$branch"
        "${app[git]}" branch -q "$branch" -u "${origin}/${branch}"
        "${app[git]}" reset -q --hard "${origin}/${branch}"
        "${app[git]}" branch -vv
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
        [brew]="$(koopa_locate_brew)"
        [wc]="$(koopa_locate_wc)"
    )
    [[ -x "${app[brew]}" ]] || return 1
    [[ -x "${app[wc]}" ]] || return 1
    while [[ "$("${app[brew]}" list --formulae | "${app[wc]}" -l)" -gt 0 ]]
    do
        local brews
        readarray -t brews <<< "$("${app[brew]}" list --formulae)"
        "${app[brew]}" uninstall \
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
        [brew]="$(koopa_locate_brew)"
    )
    [[ -x "${app[brew]}" ]] || return 1
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
        "${app[brew]}" reinstall --force "$brew" || true
        if koopa_is_macos
        then
            case "$brew" in
                'gcc' | \
                'gpg' | \
                'python@3.9' | \
                'vim')
                    "${app[brew]}" link --overwrite "$brew" || true
                    ;;
            esac
        fi
    done
    return 0
}

koopa_build_all_apps() {
    local pkgs
    koopa_assert_has_no_args "$#"
    pkgs=(
        'pkg-config'
        'make'
        'xz'
        'm4'
        'gmp'
        'gperf'
        'coreutils'
        'patch'
        'bash'
        'mpfr'
        'mpc'
        'gcc'
        'autoconf'
        'automake'
        'bison'
        'libtool'
        'bash'
        'attr'
        'coreutils'
        'findutils'
        'sed'
        'ncurses'
        'icu4c'
        'readline'
        'libxml2'
        'gettext'
        'zlib'
        'openssl1'
        'openssl3'
        'cmake'
        'curl'
        'git'
        'lapack'
        'libffi'
        'libjpeg-turbo'
        'libpng'
        'zstd'
        'libtiff'
        'openblas'
        'bzip2'
        'pcre'
        'pcre2'
        'python'
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
        'imagemagick'
        'graphviz'
        'geos'
        'proj'
        'gdal'
        'r'
        'conda'
        'sqlite'
        'apr'
        'apr-util'
        'armadillo'
        'aspell'
        'bc'
        'binutils'
        'cpufetch'
        'exiftool'
        'libtasn1'
        'libunistring'
        'nettle'
        'texinfo'
        'gnutls'
        'emacs'
        'vim'
        'lua'
        'luarocks'
        'neovim'
        'libevent'
        'utf8proc'
        'tmux'
        'htop'
        'boost'
        'fish'
        'zsh'
        'gawk'
        'aspera-connect'
        'docker-credential-pass'
        'lame'
        'ffmpeg'
        'flac'
        'fltk'
        'fribidi'
        'gdbm'
        'gnupg'
        'grep'
        'groff'
        'gsl'
        'gzip'
        'harfbuzz'
        'hyperfine'
        'jpeg'
        'oniguruma'
        'jq'
        'less'
        'lesspipe'
        'libidn'
        'libpipeline'
        'libuv'
        'libzip'
        'lz4'
        'man-db'
        'neofetch'
        'nim'
        'parallel'
        'password-store'
        'taglib'
        'pytaglib'
        'pytest'
        'xxhash'
        'rsync'
        'serf'
        'subversion'
        'shellcheck'
        'shunit2'
        'sox'
        'stow'
        'tar'
        'tokei'
        'tree'
        'tuc'
        'udunits'
        'units'
        'wget'
        'which'
        'libgeotiff'
        'go'
        'apptainer'
        'chezmoi'
        'fzf'
        'aws-cli'
        'azure-cli'
        'google-cloud-sdk'
        'black'
        'bpytop'
        'flake8'
        'glances'
        'ipython'
        'isort'
        'latch'
        'poetry'
        'pipx'
        'pyflakes'
        'pygments'
        'ranger-fm'
        'scons'
        'serf'
        'yt-dlp'
        'node'
        'bash-language-server'
        'gtop'
        'prettier'
        'ack'
        'rename'
        'ruby'
        'bashcov'
        'colorls'
        'ronn'
        'rust'
        'bat'
        'broot'
        'delta'
        'difftastic'
        'du-dust'
        'exa'
        'mcfly'
        'mdcat'
        'procs'
        'ripgrep'
        'starship'
        'tealdeer'
        'tokei'
        'xsv'
        'zellij'
        'zoxide'
        'julia'
        'julia-packages'
        'ffq'
        'gget'
        'chemacs'
        'dotfiles'
    )
    if ! koopa_is_aarch64
    then
        pkgs+=(
            'anaconda'
            'haskell-stack'
            'hadolint'
            'pandoc'
            'kallisto'
            'salmon'
            'snakemake'
        )
    fi
    if koopa_is_linux
    then
        pkgs+=(
            'lmod'
        )
    fi
    pkgs+=('r-packages')
    koopa_cli_reinstall "${pkgs[@]}"
    koopa_push_all_apps
    return 0
}

koopa_cache_functions_dir() {
    local app prefix
    koopa_assert_has_args "$#"
    declare -A app=(
        [grep]="$(koopa_locate_grep)"
        [perl]="$(koopa_locate_perl)"
    )
    [[ -x "${app[grep]}" ]] || return 1
    [[ -x "${app[perl]}" ]] || return 1
    for prefix in "$@"
    do
        local dict file files
        declare -A dict=(
            [prefix]="$prefix"
        )
        koopa_assert_is_dir "${dict[prefix]}"
        dict[target_file]="${dict[prefix]}.sh"
        koopa_alert "Caching functions at '${dict[prefix]}' \
in '${dict[target_file]}'."
        readarray -t files <<< "$( \
            koopa_find \
                --pattern='*.sh' \
                --prefix="${dict[prefix]}" \
                --sort \
        )"
        koopa_write_string \
            --file="${dict[target_file]}" \
            --string='#!/bin/sh\n# shellcheck disable=all'
        for file in "${files[@]}"
        do
            "${app[grep]}" \
                --extended-regexp \
                --ignore-case \
                --invert-match \
                '^(\s+)?#' \
                "$file" \
            >> "${dict[target_file]}"
        done
        dict[tmp_target_file]="${dict[target_file]}.tmp"
        "${app[perl]}" \
            -0pe 's/\n\n\n+/\n\n/g' \
            "${dict[target_file]}" \
            > "${dict[tmp_target_file]}"
        koopa_mv \
            "${dict[tmp_target_file]}" \
            "${dict[target_file]}"
    done
    return 0
}

koopa_cache_functions() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    dict[shell_prefix]="${dict[koopa_prefix]}/lang/shell"
    koopa_cache_functions_dir \
        "${dict[shell_prefix]}/bash/functions/activate" \
        "${dict[shell_prefix]}/bash/functions/common" \
        "${dict[shell_prefix]}/bash/functions/os/linux/alpine" \
        "${dict[shell_prefix]}/bash/functions/os/linux/arch" \
        "${dict[shell_prefix]}/bash/functions/os/linux/common" \
        "${dict[shell_prefix]}/bash/functions/os/linux/debian" \
        "${dict[shell_prefix]}/bash/functions/os/linux/fedora" \
        "${dict[shell_prefix]}/bash/functions/os/linux/opensuse" \
        "${dict[shell_prefix]}/bash/functions/os/linux/rhel" \
        "${dict[shell_prefix]}/bash/functions/os/macos" \
        "${dict[shell_prefix]}/posix/functions"
    return 0
}

koopa_cairo_version() {
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config \
        --opt-name='cairo' \
        --pc-name='cairo'
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

koopa_capitalize() {
    local app str
    declare -A app=(
        [tr]="$(koopa_locate_tr)"
    )
    [[ -x "${app[tr]}" ]] || return 1
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        [[ -n "$str" ]] || return 1
        str="$("${app[tr]}" '[:lower:]' '[:upper:]' <<< "${str:0:1}")${str:1}"
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
        [file]="${1:?}"
        [code]="${2:?}"
    )
    if [[ ! -e "${dict[file]}" ]]
    then
        koopa_warn "'${dict[file]}' does not exist."
        return 1
    fi
    dict[access]="$(koopa_stat_access_human "${dict[file]}")"
    if [[ "${dict[access]}" != "${dict[code]}" ]]
    then
        koopa_warn "'${dict[file]}' current access '${dict[access]}' \
is not '${dict[code]}'."
        return 1
    fi
    return 0
}

koopa_check_access_octal() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [file]="${1:?}"
        [code]="${2:?}"
    )
    if [[ ! -e "${dict[file]}" ]]
    then
        koopa_warn "'${dict[file]}' does not exist."
        return 1
    fi
    dict[access]="$(koopa_stat_access_octal "${dict[file]}")"
    if [[ "${dict[access]}" != "${dict[code]}" ]]
    then
        koopa_warn "'${dict[file]}' current access '${dict[access]}' \
is not '${dict[code]}'."
        return 1
    fi
    return 0
}

koopa_check_bin_man_consistency() {
    koopa_assert_has_no_args "$#"
    koopa_r_koopa 'cliCheckBinManConsistency' "$@"
    return 0
}

koopa_check_disk() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [limit]=90
        [used]="$(koopa_disk_pct_used "$@")"
    )
    if [[ "${dict[used]}" -gt "${dict[limit]}" ]]
    then
        koopa_warn "Disk usage is ${dict[used]}%."
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
        [file]="${1:?}"
        [code]="${2:?}"
    )
    if [[ ! -e "${dict[file]}" ]]
    then
        koopa_warn "'${dict[file]}' does not exist."
        return 1
    fi
    dict[group]="$(koopa_stat_group "${dict[file]}")"
    if [[ "${dict[group]}" != "${dict[code]}" ]]
    then
        koopa_warn "'${dict[file]}' current group '${dict[group]}' \
is not '${dict[code]}'."
        return 1
    fi
    return 0
}

koopa_check_mount() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [wc]="$(koopa_locate_wc)"
    )
    declare -A dict=(
        [prefix]="${1:?}"
    )
    if [[ ! -r "${dict[prefix]}" ]] || [[ ! -d "${dict[prefix]}" ]]
    then
        koopa_warn "'${dict[prefix]}' is not a readable directory."
        return 1
    fi
    dict[nfiles]="$( \
        koopa_find \
            --prefix="${dict[prefix]}" \
            --min-depth=1 \
            --max-depth=1 \
        | "${app[wc]}" -l \
    )"
    if [[ "${dict[nfiles]}" -eq 0 ]]
    then
        koopa_warn "'${dict[prefix]}' is unmounted and/or empty."
        return 1
    fi
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
    koopa_r_koopa --vanilla 'cliCheckSystem'
    koopa_alert_success 'System passed all checks.'
    return 0
}

koopa_check_user() {
    local dict
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        [file]="${1:?}"
        [expected_user]="${2:?}"
    )
    if [[ ! -e "${dict[file]}" ]]
    then
        koopa_warn "'${dict[file]}' does not exist on disk."
        return 1
    fi
    dict[file]="$(koopa_realpath "${dict[file]}")"
    dict[current_user]="$(koopa_stat_user "${dict[file]}")"
    if [[ "${dict[current_user]}" != "${dict[expected_user]}" ]]
    then
        koopa_warn "'${dict[file]}' user '${dict[current_user]}' \
is not '${dict[expected_user]}'."
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
        [chgrp]="$(koopa_locate_chgrp)"
    )
    [[ -x "${app[chgrp]}" ]] || return 1
    declare -A dict=(
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict[sudo]=1
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
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        [[ -x "${app[sudo]}" ]] || return 1
        chgrp=("${app[sudo]}" "${app[chgrp]}")
    else
        chgrp=("${app[chgrp]}")
    fi
    "${chgrp[@]}" "$@"
    return 0
}

koopa_chmod() {
    local app chmod dict pos
    declare -A app=(
        [chmod]="$(koopa_locate_chmod)"
    )
    [[ -x "${app[chmod]}" ]] || return 1
    declare -A dict=(
        [recursive]=0
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--recursive' | \
            '-R')
                dict[recursive]=1
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict[sudo]=1
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
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        [[ -x "${app[sudo]}" ]] || return 1
        chmod=("${app[sudo]}" "${app[chmod]}")
    else
        chmod=("${app[chmod]}")
    fi
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        chmod+=('-R')
    fi
    "${chmod[@]}" "$@"
    return 0
}

koopa_chown() {
    local app chown dict pos
    declare -A app=(
        [chown]="$(koopa_locate_chown)"
    )
    [[ -x "${app[chown]}" ]] || return 1
    declare -A dict=(
        [dereference]=1
        [recursive]=0
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--dereference' | \
            '-H')
                dict[dereference]=1
                shift 1
                ;;
            '--no-dereference' | \
            '-h')
                dict[dereference]=0
                shift 1
                ;;
            '--recursive' | \
            '-R')
                dict[recursive]=1
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict[sudo]=1
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
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        [[ -x "${app[sudo]}" ]] || return 1
        chown=("${app[sudo]}" "${app[chown]}")
    else
        chown=("${app[chown]}")
    fi
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        chown+=('-R')
    fi
    if [[ "${dict[dereference]}" -eq 0 ]]
    then
        chown+=('-h')
    fi
    "${chown[@]}" "$@"
    return 0
}

koopa_cli_app() {
    local dict
    declare -A dict=(
        [key]=''
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
                            dict[key]="${1:?}-${2:?}-${3:?}"
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
                            dict[key]="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                's3')
                    case "${3:-}" in
                        'find' | \
                        'list-large-files' | \
                        'ls' | \
                        'mv-to-parent' | \
                        'sync')
                            dict[key]="${1:?}-${2:?}-${3:?}"
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
                    dict[key]="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'bowtie2')
            case "${2:-}" in
                'align' | \
                'index')
                    dict[key]="${1:?}-${2:?}"
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
                    dict[key]="${1:?}-${2:?}"
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
                    dict[key]="${1:?}-${2:?}"
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
                    dict[key]="${1:?}-${2:?}"
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
                    dict[key]="${1:?}-${2:?}"
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
                    dict[key]="${1:?}-${2:?}"
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
                    dict[key]="${1:?}-${2:?}"
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
                    dict[key]="${1:?}-${2:?}"
                    shift 2
                    ;;
                'quant')
                    case "${3:-}" in
                        'paired-end' | \
                        'single-end')
                            dict[key]="${1:?}-${2:?}-${3:?}"
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
                    dict[key]="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'rnaeditingindexer')
            dict[key]="${1:?}"
            shift 1
            ;;
        'sra')
            case "${2:-}" in
                'download-accession-list' | \
                'download-run-info-table' | \
                'fastq-dump' | \
                'prefetch')
                    dict[key]="${1:?}-${2:?}"
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
                    dict[key]="${1:?}-${2:?}"
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
                            dict[key]="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                'index')
                    dict[key]="${1:?}-${2:?}"
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
                    dict[key]="${1:?}-${2:?}"
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
    [[ -z "${dict[key]}" ]] && koopa_cli_invalid_arg "$@"
    dict[fun]="$(koopa_which_function "${dict[key]}" || true)"
    if ! koopa_is_function "${dict[fun]}"
    then
        koopa_stop 'Unsupported command.'
    fi
    "${dict[fun]}" "$@"
    return 0
}

koopa_cli_configure() {
    local app
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        local dict
        declare -A dict=(
            [key]="configure-${app}"
        )
        dict[fun]="$(koopa_which_function "${dict[key]}" || true)"
        if ! koopa_is_function "${dict[fun]}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict[fun]}"
    done
    return 0
}

koopa_cli_install() {
    local app dict flags pos stem
    koopa_assert_has_args "$#"
    declare -A dict=(
        [allow_custom]=0
        [custom_enabled]=0
        [stem]='install'
    )
    case "${1:-}" in
        'koopa')
            dict[allow_custom]=1
            ;;
        '--all')
            koopa_install_all_apps
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
                if [[ "${dict[allow_custom]}" -eq 1 ]]
                then
                    dict[custom_enabled]=1
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
            dict[stem]="${dict[stem]}-${1:?}"
            shift 1
            ;;
    esac
    koopa_assert_has_args "$#"
    if [[ "${dict[custom_enabled]}" -eq 1 ]]
    then
        dict[app]="${1:?}"
        shift 1
        dict[key]="${dict[stem]}-${dict[app]}"
        dict[fun]="$(koopa_which_function "${dict[key]}" || true)"
        if ! koopa_is_function "${dict[fun]}"
        then
            koopa_stop "Unsupported app: '${dict[app]}'."
        fi
        "${dict[fun]}" "$@"
        return 0
    fi
    for app in "$@"
    do
        local dict2
        declare -A dict2
        dict2[app]="$app"
        dict2[key]="${dict[stem]}-${dict2[app]}"
        dict2[fun]="$(koopa_which_function "${dict2[key]}" || true)"
        if ! koopa_is_function "${dict2[fun]}"
        then
            koopa_stop "Unsupported app: '${dict2[app]}'."
        fi
        if koopa_is_array_non_empty "${flags[@]:-}"
        then
            "${dict2[fun]}" "${flags[@]:-}"
        else
            "${dict2[fun]}"
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
    koopa_cli_install --reinstall "$@"
}

koopa_cli_system() {
    local dict
    declare -A dict=(
        [key]=''
    )
    case "${1:-}" in
        'check')
            dict[key]='check-system'
            shift 1
            ;;
        'info')
            dict[key]='system-info'
            shift 1
            ;;
        'list')
            case "${2:-}" in
                'app-versions' | \
                'dotfiles' | \
                'launch-agents' | \
                'path-priority' | \
                'programs')
                    dict[key]="${1:?}-${2:?}"
                    shift 2
                    ;;
            esac
            ;;
        'log')
            dict[key]='view-latest-tmp-log-file'
            shift 1
            ;;
        'prefix')
            case "${2:-}" in
                '')
                    dict[key]='koopa-prefix'
                    shift 1
                    ;;
                'koopa')
                    dict[key]='koopa-prefix'
                    shift 2
                    ;;
                *)
                    dict[key]="${2}-prefix"
                    shift 2
                    ;;
            esac
            ;;
        'version')
            dict[key]='get-version'
            shift 1
            ;;
        'which')
            dict[key]='which-realpath'
            shift 1
            ;;
        'brew-dump-brewfile' | \
        'brew-outdated' | \
        'build-all-apps' | \
        'cache-functions' | \
        'disable-passwordless-sudo' | \
        'enable-passwordless-sudo' | \
        'find-non-symlinked-make-files' | \
        'fix-zsh-permissions' | \
        'host-id' | \
        'os-string' | \
        'push-all-app-builds' | \
        'push-app-build' | \
        'reload-shell' | \
        'roff' | \
        'set-permissions' | \
        'switch-to-develop' | \
        'test' | \
        'variable' | \
        'variables')
            dict[key]="${1:?}"
            shift 1
            ;;
        'conda-create-env')
            koopa_defunct 'koopa app conda create-env'
            ;;
        'conda-remove-env')
            koopa_defunct 'koopa app conda remove-env'
            ;;
    esac
    if [[ -z "${dict[key]}" ]]
    then
        if koopa_is_linux
        then
            case "${1:-}" in
                'delete-cache' | \
                'fix-sudo-setrlimit-error')
                    dict[key]="${1:?}"
                    shift 1
                    ;;
            esac
        elif koopa_is_macos
        then
            case "${1:-}" in
                'spotlight')
                    dict[key]='spotlight-find'
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
                    dict[key]="${1:?}"
                    shift 1
                    ;;
            esac
        fi
    fi
    [[ -z "${dict[key]}" ]] && koopa_cli_invalid_arg "$@"
    dict[fun]="$(koopa_which_function "${dict[key]}" || true)"
    if ! koopa_is_function "${dict[fun]}"
    then
        koopa_stop 'Unsupported command.'
    fi
    "${dict[fun]}" "$@"
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
            [key]="${stem}-${app}"
        )
        dict[fun]="$(koopa_which_function "${dict[key]}" || true)"
        if ! koopa_is_function "${dict[fun]}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict[fun]}"
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
            [key]="${stem}-${app}"
        )
        dict[fun]="$(koopa_which_function "${dict[key]}" || true)"
        if ! koopa_is_function "${dict[fun]}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict[fun]}"
    done
    return 0
}

koopa_cli() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [nested]=0
    )
    case "${1:?}" in
        '--help' | \
        '-h')
            dict[manfile]="$(koopa_man_prefix)/man1/koopa.1"
            koopa_help "${dict[manfile]}"
            return 0
            ;;
        '--version' | \
        '-V' | \
        'version')
            dict[key]='koopa-version'
            shift 1
            ;;
        'header')
            dict[key]="$1"
            shift 1
            ;;
        'app' | \
        'configure' | \
        'install' | \
        'reinstall' | \
        'system' | \
        'uninstall' | \
        'update')
            dict[nested]=1
            dict[key]="cli-${1}"
            shift 1
            ;;
        *)
            koopa_cli_invalid_arg "$@"
            ;;
    esac
    if [[ "${dict[nested]}"  -eq 1 ]]
    then
        dict[fun]="koopa_${dict[key]//-/_}"
        koopa_assert_is_function "${dict[fun]}"
    else
        dict[fun]="$(koopa_which_function "${dict[key]}" || true)"
    fi
    if ! koopa_is_function "${dict[fun]}"
    then
        koopa_stop 'Unsupported command.'
    fi
    "${dict[fun]}" "$@"
    return 0
}

koopa_clone() {
    local dict rsync_args
    koopa_assert_has_args_eq "$#" 2
    koopa_assert_has_no_flags "$@"
    declare -A dict=(
        [source_dir]="${1:?}"
        [target_dir]="${2:?}"
    )
    koopa_assert_is_dir "${dict[source_dir]}" "${dict[target_dir]}"
    dict[source_dir]="$( \
        koopa_realpath "${dict[source_dir]}" \
        | koopa_strip_trailing_slash \
    )"
    dict[target_dir]="$( \
        koopa_realpath "${dict[target_dir]}" \
        | koopa_strip_trailing_slash \
    )"
    koopa_dl \
        'Source dir' "${dict[source_dir]}" \
        'Target dir' "${dict[target_dir]}"
    rsync_args=(
        '--archive'
        '--delete-before'
        "--source-dir=${dict[source_dir]}"
        "--target-dir=${dict[target_dir]}"
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
        [env_name]="${1:?}"
        [nounset]="$(koopa_boolean_nounset)"
    )
    dict[env_prefix]="$(koopa_conda_env_prefix "${dict[env_name]}" || true)"
    if [[ ! -d "${dict[env_prefix]}" ]]
    then
        koopa_alert_info "Attempting to install missing conda \
environment '${dict[env_name]}'."
        koopa_conda_create_env "${dict[env_name]}"
        dict[env_prefix]="$(koopa_conda_env_prefix "${dict[env_name]}" || true)"
    fi
    if [[ ! -d "${dict[env_prefix]}" ]]
    then
        koopa_stop "'${dict[env_name]}' conda environment is not installed."
    fi
    [[ "${dict[nounset]}" -eq 1 ]] && set +o nounset
    koopa_is_conda_env_active && koopa_conda_deactivate
    koopa_activate_conda
    koopa_assert_is_function 'conda'
    conda activate "${dict[env_prefix]}"
    [[ "${dict[nounset]}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_conda_create_env() {
    local app dict pos string
    koopa_assert_has_args "$#"
    declare -A app=(
        [conda]="$(koopa_locate_mamba_or_conda)"
        [cut]="$(koopa_locate_cut)"
    )
    [[ -x "${app[conda]}" ]] || return 1
    [[ -x "${app[cut]}" ]] || return 1
    declare -A dict=(
        [conda_prefix]="$(koopa_conda_prefix)"
        [force]=0
        [latest]=0
        [prefix]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--force' | \
            '--reinstall')
                dict[force]=1
                shift 1
                ;;
            '--latest')
                dict[latest]=1
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
    if [[ -n "${dict[prefix]}" ]]
    then
        koopa_assert_has_args_eq "$#" 1
        koopa_assert_is_dir "${dict[prefix]}"
        "${app[conda]}" create \
            --prefix "${dict[prefix]}" \
            --quiet \
            --yes \
            "$@"
        return 0
    fi
    for string in "$@"
    do
        local dict2
        declare -A dict2
        dict2[env_string]="${string//@/=}"
        if [[ "${dict[latest]}" -eq 1 ]]
        then
            if koopa_str_detect_fixed \
                --string="${dict2[env_string]}" \
                --pattern='='
            then
                koopa_stop "Don't specify version when using '--latest'."
            fi
            koopa_alert "Obtaining latest version for '${dict2[env_string]}'."
            dict2[env_version]="$( \
                koopa_conda_env_latest_version "${dict2[env_string]}" \
            )"
            [[ -n "${dict2[env_version]}" ]] || return 1
            dict2[env_string]="${dict2[env_string]}=${dict2[env_version]}"
        elif ! koopa_str_detect_fixed \
            --string="${dict2[env_string]}" \
            --pattern='='
        then
            dict2[env_version]="$( \
                koopa_variable "${dict2[env_string]}" \
                || true \
            )"
            if [[ -z "${dict2[env_version]}" ]]
            then
                koopa_stop 'Pinned environment version not defined in koopa.'
            fi
            dict2[env_string]="${dict2[env_string]}=${dict2[env_version]}"
        fi
        dict2[env_name]="$( \
            koopa_print "${dict2[env_string]//=/@}" \
            | "${app[cut]}" -d '@' -f '1-2' \
        )"
        dict2[env_prefix]="${dict[conda_prefix]}/envs/${dict2[env_name]}"
        if [[ -d "${dict2[env_prefix]}" ]]
        then
            if [[ "${dict[force]}" -eq 1 ]]
            then
                koopa_conda_remove_env "${dict2[env_name]}"
            else
                koopa_alert_note "Conda environment '${dict2[env_name]}' \
exists at '${dict2[env_prefix]}'."
                continue
            fi
        fi
        koopa_alert_install_start "${dict2[env_name]}" "${dict2[env_prefix]}"
        "${app[conda]}" create \
            --name="${dict2[env_name]}" \
            --quiet \
            --yes \
            "${dict2[env_string]}"
        koopa_sys_set_permissions --recursive \
            "${dict[conda_prefix]}/pkgs" \
            "${dict2[env_prefix]}"
        koopa_alert_install_success "${dict2[env_name]}" "${dict2[env_prefix]}"
    done
    return 0
}

koopa_conda_deactivate() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [env_name]="$(koopa_conda_env_name)"
        [nounset]="$(koopa_boolean_nounset)"
    )
    if [[ -z "${dict[env_name]}" ]]
    then
        koopa_stop 'conda is not active.'
    fi
    koopa_assert_is_function 'conda'
    [[ "${dict[nounset]}" -eq 1 ]] && set +o nounset
    conda deactivate
    [[ "${dict[nounset]}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_conda_env_latest_version() {
    local app dict str
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [conda]="$(koopa_locate_mamba_or_conda)"
        [tail]="$(koopa_locate_tail)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[conda]}" ]] || return 1
    [[ -x "${app[tail]}" ]] || return 1
    declare -A dict=(
        [env_name]="${1:?}"
    )
    str="$( \
        "${app[conda]}" search --quiet "${dict[env_name]}" \
            | "${app[tail]}" -n 1 \
            | "${app[awk]}" '{print $2}'
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_conda_env_list() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [conda]="$(koopa_locate_mamba_or_conda)"
    )
    [[ -x "${app[conda]}" ]] || return 1
    str="$("${app[conda]}" env list --json --quiet)"
    koopa_print "$str"
    return 0
}

koopa_conda_env_prefix() {
    local app dict
    koopa_assert_has_args_le "$#" 2
    declare -A app=(
        [sed]="$(koopa_locate_sed)"
        [tail]="$(koopa_locate_tail)"
    )
    [[ -x "${app[sed]}" ]] || return 1
    [[ -x "${app[tail]}" ]] || return 1
    declare -A dict=(
        [env_name]="${1:?}"
        [env_list]="${2:-}"
    )
    [[ -n "${dict[env_name]}" ]] || return 1
    if [[ -z "${dict[env_list]}" ]]
    then
        dict[conda_prefix]="$(koopa_conda_prefix)"
        dict[env_prefix]="${dict[conda_prefix]}/envs/${dict[env_name]}"
        if [[ -d "${dict[env_prefix]}" ]]
        then
            koopa_print "${dict[env_prefix]}"
            return 0
        fi
        dict[env_list]="$(koopa_conda_env_list)"
    fi
    dict[env_list2]="$( \
        koopa_grep \
            --pattern="${dict[env_name]}" \
            --string="${dict[env_list]}" \
    )"
    [[ -n "${dict[env_list2]}" ]] || return 1
    dict[env_prefix]="$( \
        koopa_grep \
            --pattern="/${dict[env_name]}(@[.0-9]+)?\"" \
            --regex \
            --string="${dict[env_list]}" \
        | "${app[tail]}" -n 1 \
        | "${app[sed]}" -E 's/^.*"(.+)".*$/\1/' \
    )"
    [[ -d "${dict[env_prefix]}" ]] || return 1
    koopa_print "${dict[env_prefix]}"
    return 0
}

koopa_conda_remove_env() {
    local app dict name
    koopa_assert_has_args "$#"
    declare -A app=(
        [conda]="$(koopa_locate_mamba_or_conda)"
    )
    [[ -x "${app[conda]}" ]] || return 1
    declare -A dict=(
        [nounset]="$(koopa_boolean_nounset)"
    )
    [[ "${dict[nounset]}" -eq 1 ]] && set +o nounset
    for name in "$@"
    do
        dict[prefix]="$(koopa_conda_env_prefix "$name")"
        koopa_assert_is_dir "${dict[prefix]}"
        dict[name]="$(koopa_basename "${dict[prefix]}")"
        koopa_alert_uninstall_start "${dict[name]}" "${dict[prefix]}"
        "${app[conda]}" env remove --name="${dict[name]}" --yes
        [[ -d "${dict[prefix]}" ]] && koopa_rm "${dict[prefix]}"
        koopa_alert_uninstall_success "${dict[name]}" "${dict[prefix]}"
    done
    [[ "${dict[nounset]}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_configure_app_packages() {
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [app]=''
        [link_in_opt]=1
        [name]=''
        [prefix]=''
        [version]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--app='*)
                dict[app]="${1#*=}"
                shift 1
                ;;
            '--app')
                dict[app]="${2:?}"
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
            '--version='*)
                dict[version]="${1#*=}"
                shift 1
                ;;
            '--version')
                dict[version]="${2:?}"
                shift 2
                ;;
            '--link-in-opt')
                dict[link_in_opt]=1
                shift 1
                ;;
            '--no-link-in-opt')
                dict[link_in_opt]=0
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
        koopa_assert_has_args_eq "$#" 1
        dict[app]="${1:?}"
    fi
    koopa_assert_is_set '--name' "${dict[name]}"
    dict[pkg_prefix_fun]="koopa_${dict[name]}_packages_prefix"
    koopa_assert_is_function "${dict[pkg_prefix_fun]}"
    if [[ -z "${dict[prefix]}" ]]
    then
        if [[ -z "${dict[version]}" ]]
        then
            if [[ -z "${dict[app]}" ]]
            then
                dict[locate_app_fun]="koopa_locate_${dict[name]}"
                koopa_assert_is_function "${dict[locate_app_fun]}"
                dict[app]="$("${dict[locate_app_fun]}")"
            fi
            koopa_assert_is_installed "${dict[app]}"
            dict[version]="$(koopa_get_version "${dict[app]}")"
        fi
        dict[prefix]="$("${dict[pkg_prefix_fun]}" "${dict[version]}")"
    fi
    koopa_alert_configure_start "${dict[name]}" "${dict[prefix]}"
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa_sys_mkdir "${dict[prefix]}"
        koopa_sys_set_permissions "$(koopa_dirname "${dict[prefix]}")"
    fi
    if [[ "${dict[link_in_opt]}" -eq 1 ]]
    then
        koopa_link_in_opt "${dict[prefix]}" "${dict[name]}-packages"
    fi
    koopa_alert_configure_success "${dict[name]}" "${dict[prefix]}"
    return 0
}

koopa_configure_chemacs() {
    local dict
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        [source_prefix]="${1:-}"
        [opt_prefix]="$(koopa_opt_prefix)"
        [target_prefix]="${HOME:?}/.emacs.d"
    )
    if [[ -z "${dict[source_prefix]}" ]]
    then
        dict[source_prefix]="${dict[opt_prefix]}/chemacs"
    fi
    koopa_assert_is_dir "${dict[source_prefix]}"
    dict[source_prefix]="$(koopa_realpath "${dict[source_prefix]}")"
    koopa_ln "${dict[source_prefix]}" "${dict[target_prefix]}"
    return 0
}

koopa_configure_chezmoi() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [dotfiles_prefix]="$(koopa_dotfiles_prefix)"
        [xdg_data_home]="$(koopa_xdg_data_home)"
    )
    dict[chezmoi_prefix]="${dict[xdg_data_home]}/chezmoi"
    if [[ -d "${dict[dotfiles_prefix]}" ]]
    then
        koopa_ln "${dict[dotfiles_prefix]}" "${dict[chezmoi_prefix]}"
    fi
    return 0
}

koopa_configure_dotfiles() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
    )
    [[ -x "${app[bash]}" ]] || return 1
    declare -A dict=(
        [name]='dotfiles'
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="$(koopa_dotfiles_prefix)"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[script]="${dict[prefix]}/install"
    koopa_assert_is_file "${dict[script]}"
    koopa_add_config_link "${dict[prefix]}" "${dict[name]}"
    koopa_add_to_path_start "$(koopa_dirname "${app[bash]}")"
    "${app[bash]}" "${dict[script]}"
    return 0
}

koopa_configure_julia() {
    koopa_configure_app_packages \
        --name='julia' \
        "$@"
}

koopa_configure_r() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    [[ -x "${app[r]}" ]] || return 1
    declare -A dict=(
        [name]='r'
        [system]=0
    )
    if ! koopa_is_koopa_app "${app[r]}"
    then
        koopa_assert_is_admin
        dict[system]=1
    fi
    dict[r_prefix]="$(koopa_r_prefix "${app[r]}")"
    dict[site_library]="${dict[r_prefix]}/site-library"
    koopa_alert_configure_start "${dict[name]}" "${dict[r_prefix]}"
    koopa_assert_is_dir "${dict[r_prefix]}"
    koopa_r_link_files_in_etc "${app[r]}"
    koopa_r_configure_environ "${app[r]}"
    case "${dict[system]}" in
        '0')
            koopa_r_link_site_library "${app[r]}"
            ;;
        '1')
            dict[group]="$(koopa_admin_group)"
            dict[user]="$(koopa_user)"
            koopa_mkdir --sudo "${dict[site_library]}"
            koopa_chmod --sudo '0775' "${dict[site_library]}"
            koopa_chown --sudo --recursive \
                "${dict[user]}:${dict[group]}" \
                "${dict[site_library]}"
            koopa_r_configure_ldpaths "${app[r]}"
            koopa_r_configure_makevars "${app[r]}"
            koopa_r_javareconf "${app[r]}"
            koopa_r_rebuild_docs "${app[r]}"
            ;;
    esac
    koopa_sys_set_permissions --recursive "${dict[site_library]}"
    koopa_alert_configure_success "${dict[name]}" "${dict[r_prefix]}"
    return 0
}

koopa_configure_system() {
    koopa_stop '[FIXME] Temporarily disabled.'
    local dict prefixes
    koopa_assert_has_no_envs
    declare -A dict=(
        [delete_cache]=0
        [delete_skel]=1
        [docker]="$(
            if koopa_is_docker
            then
                koopa_print 1
            else
                koopa_print 0
            fi
        )"
        [install_aspera_connect]=0
        [install_autoconf]=0
        [install_automake]=0
        [install_aws_cli]=0
        [install_azure_cli]=0
        [install_base_system_args]=''
        [install_bash]=0
        [install_binutils]=0
        [install_cmake]=0
        [install_conda]=0
        [install_conda_envs]=0
        [install_coreutils]=0
        [install_curl]=0
        [install_curl]=0
        [install_docker]=0
        [install_docker_credential_pass]=0
        [install_dotfiles]=0
        [install_emacs]=0
        [install_findutils]=0
        [install_fish]=0
        [install_fzf]=0
        [install_gawk]=0
        [install_gcc]=0
        [install_git]=0
        [install_gnupg]=0
        [install_go]=0
        [install_google_cloud_sdk]=0
        [install_grep]=0
        [install_gsl]=0
        [install_hdf5]=0
        [install_homebrew]=0
        [install_homebrew_bundle]=0
        [install_htop]=0
        [install_julia]=0
        [install_libevent]=0
        [install_libtool]=0
        [install_llvm]=0
        [install_lmod]=0
        [install_lmod]=0
        [install_lua]=0
        [install_luarocks]=0
        [install_make]=0
        [install_ncurses]=0
        [install_neofetch]=0
        [install_neovim]=0
        [install_openjdk]=0
        [install_openssh]=0
        [install_parallel]=0
        [install_password_store]=0
        [install_patch]=0
        [install_perl]=0
        [install_perl_packages]=0
        [install_pkg_config]=0
        [install_python]=0
        [install_python_packages]=0
        [install_r]=0
        [install_r_packages]=0
        [install_rstudio_server]=0
        [install_rsync]=0
        [install_ruby]=0
        [install_ruby_packages]=0
        [install_rust]=0
        [install_rust_packages]=0
        [install_sed]=0
        [install_shellcheck]=0
        [install_shiny_server]=0
        [install_shunit2]=0
        [install_sqlite]=0
        [install_subversion]=0
        [install_taglib]=0
        [install_texinfo]=0
        [install_tmux]=0
        [install_udunits]=0
        [install_vim]=0
        [install_wget]=0
        [install_zsh]=0
        [mode]='default'
        [passwordless_sudo]=0
        [python_version]="$(koopa_variable 'python')"
        [r_version]="$(koopa_variable 'r')"
        [ssh_key]=1
        [which_conda]='conda'
    )
    while (("$#"))
    do
        case "$1" in
            '--mode='*)
                dict[mode]="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict[mode]="${2:?}"
                shift 2
                ;;
            '--python-version='*)
                dict[python_version]="${1#*=}"
                shift 1
                ;;
            '--python-version')
                dict[python_version]="${2:?}"
                shift 2
                ;;
            '--r-version='*)
                dict[r_version]="${1#*=}"
                shift 1
                ;;
            '--r-version')
                dict[r_version]="${2:?}"
                shift 2
                ;;
            '--all' | \
            '--full')
                dict[mode]='full'
                shift 1
                ;;
            '--base-image')
                dict[mode]='base-image'
                shift 1
                ;;
            '--bioconductor')
                dict[mode]='bioconductor'
                shift 1
                ;;
            '--default' | \
            '--recommended')
                dict[mode]='default'
                shift 1
                ;;
            '--minimal')
                dict[mode]='minimal'
                shift 1
                ;;
            '--verbose')
                set -o xtrace
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    case "${dict[mode]}" in
        'default' | \
        'minimal')
            ;;
        'base-image')
            dict[install_base_system_args]='--base-image'
            ;;
        'bioconductor')
            dict[install_dotfiles]=1
            dict[install_openjdk]=1
            ;;
        'full')
            dict[install_aspera_connect]=1
            dict[install_autoconf]=1
            dict[install_automake]=1
            dict[install_azure_cli]=1
            dict[install_base_system_args]='--full'
            dict[install_bash]=1
            dict[install_binutils]=1
            dict[install_cmake]=1
            dict[install_conda_envs]=1
            dict[install_coreutils]=1
            dict[install_curl]=1
            dict[install_curl]=1
            dict[install_docker]=1
            dict[install_docker_credential_pass]=1
            dict[install_dotfiles]=1
            dict[install_emacs]=1
            dict[install_findutils]=1
            dict[install_fish]=1
            dict[install_fzf]=1
            dict[install_gawk]=1
            dict[install_git]=1
            dict[install_gnupg]=1
            dict[install_go]=1
            dict[install_google_cloud_sdk]=1
            dict[install_grep]=1
            dict[install_gsl]=1
            dict[install_hdf5]=1
            dict[install_homebrew]=1
            dict[install_homebrew_bundle]=1
            dict[install_julia]=1
            dict[install_libevent]=1
            dict[install_libtool]=1
            dict[install_llvm]=1
            dict[install_lmod]=1
            dict[install_lua]=1
            dict[install_luarocks]=1
            dict[install_make]=1
            dict[install_ncurses]=1
            dict[install_neofetch]=1
            dict[install_neovim]=1
            dict[install_openssh]=1
            dict[install_parallel]=1
            dict[install_password_store]=1
            dict[install_patch]=1
            dict[install_perl]=1
            dict[install_perl_packages]=1
            dict[install_pkg_config]=1
            dict[install_python_packages]=1
            dict[install_r_packages]=1
            dict[install_rstudio_server]=1
            dict[install_rsync]=1
            dict[install_ruby]=1
            dict[install_ruby_packages]=1
            dict[install_rust]=1
            dict[install_rust_packages]=1
            dict[install_sed]=1
            dict[install_shiny_server]=1
            dict[install_sqlite]=1
            dict[install_subversion]=1
            dict[install_taglib]=1
            dict[install_texinfo]=1
            dict[install_udunits]=1
            dict[install_wget]=1
            dict[install_zsh]=1
            dict[passwordless_sudo]=1
            dict[which_conda]='anaconda'
            ;;
        'recommended')
            dict[install_aws_cli]=1
            dict[install_conda]=1
            dict[install_dotfiles]=1
            dict[install_homebrew]=1
            dict[install_htop]=1
            dict[install_openjdk]=1
            dict[install_python]=1
            dict[install_r]=1
            dict[install_shellcheck]=1
            dict[install_shunit2]=1
            dict[install_tmux]=1
            dict[install_vim]=1
            ;;
        *)
            koopa_stop 'Invalid mode.'
            ;;
    esac
    if [[ "${dict[docker]}" -eq 1 ]]
    then
        dict[delete_cache]=1
        dict[ssh_key]=0
    fi
    if koopa_is_fedora
    then
        dict[install_python]=0
    fi
    koopa_h1 'Configuring system.'
    export FORCE_UNSAFE_CONFIGURE=1
    export KOOPA_FORCE=1
    export PYTHONDONTWRITEBYTECODE=1
    if [[ "${dict[passwordless_sudo]}" -eq 1 ]]
    then
        koopa_enable_passwordless_sudo
        koopa_linux_fix_sudo_setrlimit_error
    fi
    if [[ "${dict[delete_skel]}" -eq 1 ]]
    then
        koopa_rm --sudo '/etc/skel'
    fi
    if [[ "${dict[mode]}" == 'minimal' ]]
    then
        koopa_alert_success 'Minimal configuration was successful.'
        return 0
    fi
    koopa_alert 'Installing base system.'
    koopa_linux_update_etc_profile_d
    koopa install base-system "${dict[install_base_system_args]}"
    koopa_assert_is_installed \
        'autoconf' \
        'bc' \
        'bzip2' \
        'g++' \
        'gcc' \
        'gzip' \
        'make' \
        'man' \
        'msgfmt' \
        'tar' \
        'unzip' \
        'xz'
    koopa_assert_is_file '/usr/bin/gcc' '/usr/bin/g++'
    koopa_linux_update_ldconfig

    [[ "${dict[install_dotfiles]}" -eq 1 ]] && \
        koopa install 'dotfiles'
    [[ "${dict[install_homebrew]}" -eq 1 ]] && \
        koopa install 'homebrew'
    [[ "${dict[install_homebrew_bundle]}" -eq 1 ]] && \
        koopa install 'homebrew-bundle'
    [[ "${dict[install_llvm]}" -eq 1 ]] && \
        koopa install 'llvm'
    [[ "${dict[install_openjdk]}" -eq 1 ]] && \
        koopa install 'openjdk'
    [[ "${dict[install_python]}" -eq 1 ]] && \
        koopa install 'python' --version="${dict[python_version]}"
    [[ "${dict[install_conda]}" -eq 1 ]] && \
        koopa install "${dict[which_conda]}"
    [[ "${dict[install_gcc]}" -eq 1 ]] && \
        koopa install 'gcc'
    [[ "${dict[install_curl]}" -eq 1 ]] && \
        koopa install 'curl'
    [[ "${dict[install_wget]}" -eq 1 ]] && \
        koopa install 'wget'
    [[ "${dict[install_cmake]}" -eq 1 ]] && \
        koopa install 'cmake'
    [[ "${dict[install_make]}" -eq 1 ]] && \
        koopa install 'make'
    [[ "${dict[install_autoconf]}" -eq 1 ]] && \
        koopa install 'autoconf'
    [[ "${dict[install_automake]}" -eq 1 ]] && \
        koopa install 'automake'
    [[ "${dict[install_libtool]}" -eq 1 ]] && \
        koopa install 'libtool'
    [[ "${dict[install_texinfo]}" -eq 1 ]] && \
        koopa install 'texinfo'
    [[ "${dict[install_binutils]}" -eq 1 ]] && \
        koopa install 'binutils'
    [[ "${dict[install_coreutils]}" -eq 1 ]] && \
        koopa install 'coreutils'
    [[ "${dict[install_findutils]}" -eq 1 ]] && \
        koopa install 'findutils'
    [[ "${dict[install_patch]}" -eq 1 ]] && \
        koopa install 'patch'
    [[ "${dict[install_pkg_config]}" -eq 1 ]] && \
        koopa install 'pkg-config'
    [[ "${dict[install_ncurses]}" -eq 1 ]] && \
        koopa install 'ncurses'
    [[ "${dict[install_gnupg]}" -eq 1 ]] && \
        koopa install 'gnupg'
    [[ "${dict[install_grep]}" -eq 1 ]] && \
        koopa install 'grep'
    [[ "${dict[install_gawk]}" -eq 1 ]] && \
        koopa install 'gawk'
    [[ "${dict[install_parallel]}" -eq 1 ]] && \
        koopa install 'parallel'
    [[ "${dict[install_rsync]}" -eq 1 ]] && \
        koopa install 'rsync'
    [[ "${dict[install_sed]}" -eq 1 ]] && \
        koopa install 'sed'
    [[ "${dict[install_libevent]}" -eq 1 ]] && \
        koopa install 'libevent'
    [[ "${dict[install_taglib]}" -eq 1 ]] && \
        koopa install 'taglib'
    [[ "${dict[install_zsh]}" -eq 1 ]] && \
        koopa install 'zsh'
    [[ "${dict[install_bash]}" -eq 1 ]] && \
        koopa install 'bash'
    [[ "${dict[install_fish]}" -eq 1 ]] && \
        koopa install 'fish'
    [[ "${dict[install_git]}" -eq 1 ]] && \
        koopa install 'git'
    [[ "${dict[install_openssh]}" -eq 1 ]] && \
        koopa install 'openssh'
    [[ "${dict[install_perl]}" -eq 1 ]] && \
        koopa install 'perl'
    [[ "${dict[install_sqlite]}" -eq 1 ]] && \
        koopa install 'sqlite'
    [[ "${dict[install_hdf5]}" -eq 1 ]] && \
        koopa install 'hdf5'
    [[ "${dict[install_gsl]}" -eq 1 ]] && \
        koopa install 'gsl'
    [[ "${dict[install_udunits]}" -eq 1 ]] && \
        koopa install 'udunits'
    [[ "${dict[install_subversion]}" -eq 1 ]] && \
        koopa install 'subversion'
    [[ "${dict[install_go]}" -eq 1 ]] && \
        koopa install 'go'
    [[ "${dict[install_ruby]}" -eq 1 ]] && \
        koopa install 'ruby'
    [[ "${dict[install_rust]}" -eq 1 ]] && \
        koopa install 'rust'
    [[ "${dict[install_neofetch]}" -eq 1 ]] && \
        koopa install 'neofetch'
    [[ "${dict[install_fzf]}" -eq 1 ]] && \
        koopa install 'fzf'
    [[ "${dict[install_tmux]}" -eq 1 ]] && \
        koopa install 'tmux'
    [[ "${dict[install_vim]}" -eq 1 ]] && \
        koopa install 'vim'
    [[ "${dict[install_shellcheck]}" -eq 1 ]] && \
        koopa install 'shellcheck'
    [[ "${dict[install_shunit2]}" -eq 1 ]] && \
        koopa install 'shunit2'
    [[ "${dict[install_aws_cli]}" -eq 1 ]] && \
        koopa install 'aws-cli'
    [[ "${dict[install_azure_cli]}" -eq 1 ]] && \
        koopa install 'azure-cli'
    [[ "${dict[install_docker]}" -eq 1 ]] && \
        koopa install 'docker'
    [[ "${dict[install_google_cloud_sdk]}" -eq 1 ]] && \
        koopa install 'google-cloud-sdk'
    [[ "${dict[install_password_store]}" -eq 1 ]] && \
        koopa install 'password-store'
    [[ "${dict[install_docker_credential_pass]}" -eq 1 ]] && \
        koopa install 'docker-credential-pass'
    [[ "${dict[install_neovim]}" -eq 1 ]] && \
        koopa install 'neovim'
    [[ "${dict[install_emacs]}" -eq 1 ]] && \
        koopa install 'emacs'
    [[ "${dict[install_julia]}" -eq 1 ]] && \
        koopa install 'julia'
    [[ "${dict[install_lua]}" -eq 1 ]] && \
        koopa install 'lua'
    [[ "${dict[install_luarocks]}" -eq 1 ]] && \
        koopa install 'luarocks'
    [[ "${dict[install_lmod]}" -eq 1 ]] && \
        koopa install 'lmod'
    [[ "${dict[install_htop]}" -eq 1 ]] && \
        koopa install 'htop'
    if [[ "${dict[install_r]}" -eq 1 ]]
    then
        if [[ "${dict[r_version]}" == 'devel' ]]
        then
            koopa install 'r-devel'
        else
            if koopa_is_debian
            then
                koopa install 'r-binary' --version="${dict[r_version]}"
            elif koopa_is_fedora
            then
                koopa_assert_is_installed 'R'
                koopa_configure_r
            else
                koopa install 'r' --version="${dict[r_version]}"
            fi
        fi
    fi
    [[ "${dict[install_rstudio_server]}" -eq 1 ]] && \
        koopa install 'rstudio-server'
    [[  "${dict[install_shiny_server]}" -eq 1 ]] && \
        koopa install 'shiny-server'
    [[ "${dict[install_lmod]}" -eq 1 ]] && \
        koopa_configure_lmod
    koopa_linux_update_ldconfig
    if [[ "${dict[install_python_packages]}" -eq 1 ]]
    then
        koopa install 'black'
        koopa install 'bpytop'
        koopa install 'flake8'
        koopa install 'glances'
        koopa install 'meson'
        koopa install 'ninja'
        koopa install 'pyflakes'
        koopa install 'pylint'
        koopa install 'pytest'
        koopa install 'ranger-fm'
    fi
    if [[ "${dict[install_r_packages]}" -eq 1 ]]
    then
        koopa install 'r-packages'
    fi
    if [[ "${dict[install_perl_packages]}" -eq 1 ]]
    then
        koopa install 'perl-packages'
    fi
    if [[ "${dict[install_ruby_packages]}" -eq 1 ]]
    then
        koopa install 'ruby-packages'
    fi
    if [[ "${dict[install_rust_packages]}" -eq 1 ]]
    then
        koopa install 'bat'
        koopa install 'broot'
        koopa install 'du-dust'
        koopa install 'exa'
        koopa install 'fd-find'
        koopa install 'hyperfine'
        koopa install 'mcfly'
        koopa install 'procs'
        koopa install 'ripgrep'
        koopa install 'starship'
        koopa install 'tokei'
        koopa install 'xsv'
        koopa install 'zoxide'
    fi
    [[ "${dict[install_aspera_connect]}" -eq 1 ]] && \
        koopa install 'aspera-connect'
    [[ "${dict[install_conda_envs]}" -eq 1 ]] && \
        koopa app conda create-bioinfo-envs
    [[ "${dict[ssh_key]}" -eq 1 ]] && \
        koopa_ssh_generate_key
    koopa_sys_set_permissions --recursive "${prefixes[@]}"
    koopa_delete_broken_symlinks "${prefixes[@]}"
    koopa_fix_zsh_permissions
    if [[ "${dict[delete_cache]}" -eq 1 ]]
    then
        koopa_linux_delete_cache
    fi
    koopa_alert_success 'System configuration was successful.'
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
        [cut]="$(koopa_locate_cut)"
        [paste]="$(koopa_locate_paste)"
        [sed]="$(koopa_locate_sed)"
        [tr]="$(koopa_locate_tr)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[paste]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    [[ -x "${app[tr]}" ]] || return 1
    declare -A dict=(
        [source_dir]=''
        [target_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--source-dir='*)
                dict[source_dir]="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict[source_dir]="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--source-dir' "${dict[source_dir]}" \
        '--target-dir' "${dict[target_dir]}"
    koopa_assert_is_dir "${dict[source_dir]}"
    dict[source_dir]="$(koopa_realpath "${dict[source_dir]}")"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.fastq' \
            --prefix="${dict[source_dir]}" \
            --sort \
            --type='f' \
    )"
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa_stop "No FASTQ files detected in '${dict[source_dir]}'."
    fi
    dict[target_dir]="$(koopa_init_dir "${dict[target_dir]}")"
    for fastq_file in "${fastq_files[@]}"
    do
        local fasta_file
        fasta_file="${fastq_file%.fastq}.fasta"
        "${app[paste]}" - - - - < "$fastq_file" \
            | "${app[cut]}" -f '1,2' \
            | "${app[sed]}" 's/^@/>/' \
            | "${app[tr]}" '\t' '\n' > "$fasta_file"
    done
    return 0
}

koopa_convert_line_endings_from_crlf_to_lf() {
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    [[ -x "${app[perl]}" ]] || return 1
    for file in "$@"
    do
        "${app[perl]}" -pe 's/\r$//g' < "$file" > "${file}.tmp"
        koopa_mv "${file}.tmp" "$file"
    done
    return 0
}

koopa_convert_line_endings_from_lf_to_crlf() {
    local app file
    koopa_assert_has_ars "$#"
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    [[ -x "${app[perl]}" ]] || return 1
    for file in "$@"
    do
        "${app[perl]}" -pe 's/(?<!\r)\n/\r\n/g' < "$file" > "${file}.tmp"
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
        [convmv]="$(koopa_locate_convmv)"
    )
    [[ -x "${app[convmv]}" ]] || return 1
    koopa_assert_is_file "$@"
    "${app[convmv]}" \
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
        [cp]="$(koopa_locate_cp)"
        [mkdir]='koopa_mkdir'
        [rm]='koopa_rm'
    )
    [[ -x "${app[cp]}" ]] || return 1
    declare -A dict=(
        [sudo]=0
        [symlink]=0
        [target_dir]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--target-directory='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            '--sudo' | \
            '-S')
                dict[sudo]=1
                shift 1
                ;;
            '--symbolic-link' | \
            '--symlink' | \
            '-s')
                dict[symlink]=1
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
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        [[ -x "${app[sudo]}" ]] || return 1
        cp=("${app[sudo]}" "${app[cp]}")
        mkdir=("${app[mkdir]}" '--sudo')
        rm=("${app[rm]}" '--sudo')
    else
        cp=("${app[cp]}")
        mkdir=("${app[mkdir]}")
        rm=("${app[rm]}")
    fi
    cp_args=('-af')
    [[ "${dict[symlink]}" -eq 1 ]] && cp_args+=('-s')
    cp_args+=("$@")
    if [[ -n "${dict[target_dir]}" ]]
    then
        koopa_assert_is_existing "$@"
        dict[target_dir]="$(koopa_strip_trailing_slash "${dict[target_dir]}")"
        if [[ ! -d "${dict[target_dir]}" ]]
        then
            "${mkdir[@]}" "${dict[target_dir]}"
        fi
        cp_args+=("${dict[target_dir]}")
    else
        koopa_assert_has_args_eq "$#" 2
        dict[source_file]="${1:?}"
        koopa_assert_is_existing "${dict[source_file]}"
        dict[target_file]="${2:?}"
        if [[ -e "${dict[target_file]}" ]]
        then
            "${rm[@]}" "${dict[target_file]}"
        fi
        dict[target_parent]="$(koopa_dirname "${dict[target_file]}")"
        if [[ ! -d "${dict[target_parent]}" ]]
        then
            "${mkdir[@]}" "${dict[target_parent]}"
        fi
    fi
    "${cp[@]}" "${cp_args[@]}"
    return 0
}

koopa_cpu_count() {
    local app num
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [nproc]="$(koopa_locate_nproc --allow-missing)"
    )
    if koopa_is_installed "${app[nproc]}"
    then
        num="$("${app[nproc]}")"
    elif koopa_is_macos
    then
        app[sysctl]="$(koopa_macos_locate_sysctl)"
        [[ -x "${app[sysctl]}" ]] || return 1
        num="$("${app[sysctl]}" -n 'hw.ncpu')"
    elif koopa_is_linux
    then
        app[getconf]="$(koopa_linux_locate_getconf)"
        [[ -x "${app[getconf]}" ]] || return 1
        num="$("${app[getconf]}" '_NPROCESSORS_ONLN')"
    else
        num=1
    fi
    koopa_print "$num"
    return 0
}

koopa_current_bcbio_nextgen_version() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    str="$( \
        koopa_parse_url "https://raw.githubusercontent.com/bcbio/\
bcbio-nextgen/master/requirements-conda.txt" \
            | koopa_grep --pattern='bcbio-nextgen=' \
            | "${app[cut]}" -d '=' -f '2' \
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
        [cut]="$(koopa_locate_cut)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    str="$( \
        koopa_parse_url 'ftp://ftp.ensembl.org/pub/current_README' \
        | "${app[sed]}" -n '3p' \
        | "${app[cut]}" -d ' ' -f '3' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_current_flybase_version() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [tail]="$(koopa_locate_tail)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[tail]}" ]] || return 1
    str="$( \
        koopa_parse_url --list-only "ftp://ftp.flybase.net/releases/" \
        | koopa_grep --pattern='^FB[0-9]{4}_[0-9]{2}$' --regex \
        | "${app[tail]}" -n 1 \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_current_gencode_version() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [curl]="$(koopa_locate_curl)"
        [cut]="$(koopa_locate_cut)"
        [grep]="$(koopa_locate_grep)"
        [head]="$(koopa_locate_head)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[curl]}" ]] || return 1
    [[ -x "${app[grep]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    declare -A dict=(
        [organism]="${1:-}"
    )
    [[ -z "${dict[organism]}" ]] && dict[organism]='Homo sapiens'
    case "${dict[organism]}" in
        'Homo sapiens' | \
        'human')
            dict[short_name]='human'
            dict[pattern]='Release [0-9]+'
            ;;
        'Mus musculus' | \
        'mouse')
            dict[short_name]='mouse'
            dict[pattern]='Release M[0-9]+'
            ;;
        *)
            koopa_stop "Unsupported organism: '${dict[organism]}'."
            ;;
    esac
    dict[base_url]='https://www.gencodegenes.org'
    dict[url]="${dict[base_url]}/${dict[short_name]}/"
    dict[str]="$( \
        koopa_parse_url "${dict[url]}" \
        | koopa_grep \
            --only-matching \
            --pattern="${dict[pattern]}" \
            --regex \
        | "${app[head]}" -n 1 \
        | "${app[cut]}" -d ' ' -f '2' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
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
        [cut]="$(koopa_locate_cut)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    url="ftp://ftp.wormbase.org/pub/wormbase/\
releases/current-production-release"
    str="$( \
        koopa_parse_url --list-only "${url}/" \
            | koopa_grep \
                --only-matching \
                --pattern='letter.WS[0-9]+' \
                --regex \
            | "${app[cut]}" -d '.' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_datetime() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [date]="$(koopa_locate_date)"
    )
    [[ -x "${app[date]}" ]] || return 1
    str="$("${app[date]}" '+%Y%m%d-%H%M%S')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_decompress() {
    local cmd cmd_args dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [compress_ext_pattern]="$(koopa_compress_ext_pattern)"
        [stdout]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--stdout')
                dict[stdout]=1
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
    dict[source_file]="${1:?}"
    dict[target_file]="${2:-}"
    koopa_assert_is_file "${dict[source_file]}"
    case "${dict[stdout]}" in
        '0')
            if [[ -z "${dict[target_file]}" ]]
            then
                dict[target_file]="$( \
                    koopa_sub \
                        --pattern="${dict[compress_ext_pattern]}" \
                        --replacement='' \
                        "${dict[source_file]}" \
                )"
            fi
            if [[ "${dict[source_file]}" == "${dict[target_file]}" ]]
            then
                return 0
            fi
            ;;
        '1')
            [[ -z "${dict[target_file]}" ]] || return 1
            ;;
    esac
    case "${dict[source_file]}" in
        *'.bz2' | *'.gz' | *'.xz')
            case "${dict[source_file]}" in
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
                "${dict[source_file]}"
            )
            case "${dict[stdout]}" in
                '0')
                    "$cmd" "${cmd_args[@]}" > "${dict[target_file]}"
                    ;;
                '1')
                    "$cmd" "${cmd_args[@]}" || true
                    ;;
            esac
            ;;
        *)
            case "${dict[stdout]}" in
                '0')
                    koopa_cp "${dict[source_file]}" "${dict[target_file]}"
                    ;;
                '1')
                    cmd="$(koopa_locate_cat)"
                    [[ -x "$cmd" ]] || return 1
                    "$cmd" "${dict[source_file]}" || true
                    ;;
            esac
            ;;
    esac
    if [[ "${dict[stdout]}" -eq 0 ]]
    then
        koopa_assert_is_file "${dict[target_file]}"
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
        [config]=0
        [xdg_config_home]="$(koopa_xdg_config_home)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--config')
                dict[config]=1
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
        if [[ "${dict[config]}" -eq 1 ]]
        then
            filepath="${dict[xdg_config_home]}/${name}"
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
        [prefix]="${1:?}"
        [subdir_name]="${2:?}"
    )
    readarray -t matches <<< "$( \
        koopa_find \
            --pattern="${dict[subdir_name]}" \
            --prefix="${dict[prefix]}" \
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
        [vim]="$(koopa_locate_vim)"
    )
    [[ -x "${app[vim]}" ]] || return 1
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app[vim]}" \
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
        [df]="$(koopa_locate_df)"
    )
    [[ -x "${app[df]}" ]] || return 1
    "${app[df]}" \
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
    local file
    koopa_assert_is_admin
    file='/etc/sudoers.d/sudo'
    if [[ -f "$file" ]]
    then
        koopa_alert "Removing sudo permission file at '${file}'."
        koopa_rm --sudo "$file"
    fi
    koopa_alert_success 'Passwordless sudo is disabled.'
    return 0
}

koopa_disk_gb_free() {
    local app disk str
    koopa_assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa_assert_is_readable "$disk"
    declare -A app=(
        [df]="$(koopa_locate_df)"
        [head]="$(koopa_locate_head)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[df]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    str="$( \
        "${app[df]}" --block-size='G' "$disk" \
            | "${app[head]}" -n 2 \
            | "${app[sed]}" -n '2p' \
            | koopa_grep \
                --only-matching \
                --pattern='(\b[.0-9]+G\b)' \
                --regex \
            | "${app[head]}" -n 3 \
            | "${app[sed]}" -n '3p' \
            | "${app[sed]}" 's/G$//' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_disk_gb_total() {
    local app disk str
    koopa_assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa_assert_is_readable "$disk"
    declare -A app=(
        [df]="$(koopa_locate_df)"
        [head]="$(koopa_locate_head)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[df]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    str="$( \
        "${app[df]}" --block-size='G' "$disk" \
            | "${app[head]}" -n 2 \
            | "${app[sed]}" -n '2p' \
            | koopa_grep \
                --only-matching \
                --pattern='(\b[.0-9]+G\b)' \
                --regex \
            | "${app[head]}" -n 1 \
            | "${app[sed]}" 's/G$//' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_disk_gb_used() {
    local app disk str
    koopa_assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa_assert_is_readable "$disk"
    declare -A app=(
        [df]="$(koopa_locate_df)"
        [head]="$(koopa_locate_head)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[df]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    str="$( \
        "${app[df]}" --block-size='G' "$disk" \
            | "${app[head]}" -n 2 \
            | "${app[sed]}" -n '2p' \
            | koopa_grep \
                --only-matching \
                --pattern='(\b[.0-9]+G\b)' \
                --regex \
            | "${app[head]}" -n 2 \
            | "${app[sed]}" -n '2p' \
            | "${app[sed]}" 's/G$//' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
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
    local app disk str
    koopa_assert_has_args_eq "$#" 1
    disk="${1:?}"
    koopa_assert_is_readable "$disk"
    declare -A app=(
        [df]="$(koopa_locate_df)"
        [head]="$(koopa_locate_head)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[df]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    str="$( \
        "${app[df]}" "$disk" \
            | "${app[head]}" -n 2 \
            | "${app[sed]}" -n '2p' \
            | koopa_grep \
                --only-matching \
                --pattern='([.0-9]+%)' \
                --regex \
            | "${app[head]}" -n 1 \
            | "${app[sed]}" 's/%$//' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
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
        [basename]="$(koopa_locate_basename)"
        [docker]="$(koopa_locate_docker)"
        [xargs]="$(koopa_locate_xargs)"
    )
    [[ -x "${app[basename]}" ]] || return 1
    [[ -x "${app[docker]}" ]] || return 1
    [[ -x "${app[xargs]}" ]] || return 1
    declare -A dict=(
        [days]=7
        [docker_dir]="$(koopa_docker_prefix)"
        [force]=0
        [prune]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--days='*)
                dict[days]="${1#*=}"
                shift 1
                ;;
            '--days')
                dict[days]="${2:?}"
                shift 2
                ;;
            '--docker-dir='*)
                dict[docker_dir]="${1#*=}"
                shift 1
                ;;
            '--docker-dir')
                dict[docker_dir]="${2:?}"
                shift 2
                ;;
            '--force')
                dict[force]=1
                shift 1
                ;;
            '--prune')
                dict[prune]=1
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
    build_args=("--days=${dict[days]}")
    if [[ "${dict[force]}" -eq 1 ]]
    then
        build_args+=('--force')
    fi
    if [[ "$#" -gt 0 ]]
    then
        repos=("$@")
    else
        repos=("${dict[docker_dir]}/acidgenomics")
    fi
    koopa_assert_is_dir "${repos[@]}"
    if [[ "${dict[prune]}" -eq 1 ]]
    then
        koopa_docker_prune_all_images
    fi
    "${app[docker]}" login
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
                | "${app[xargs]}" -0 -n 1 "${app[basename]}" \
            )"
        fi
        koopa_assert_is_array_non_empty "${images[@]:-}"
        koopa_dl \
            "${#images[@]} images" \
            "$(koopa_to_string "${images[@]}")"
        for image in "${images[@]}"
        do
            image="${repo_name}/${image}"
            if [[ "${dict[force]}" -eq 0 ]]
            then
                if koopa_docker_is_build_recent \
                    --days="${dict[days]}" \
                    "$image"
                then
                    koopa_alert_note "'${image}' was built recently. Skipping."
                    continue
                fi
            fi
            koopa_docker_build_all_tags "${build_args[@]}" "$image"
        done
    done
    [[ "${dict[prune]}" -eq 1 ]] && koopa_docker_prune_all_images
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
        [cut]="$(koopa_locate_cut)"
        [date]="$(koopa_locate_date)"
        [docker]="$(koopa_locate_docker)"
        [sort]="$(koopa_locate_sort)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[date]}" ]] || return 1
    [[ -x "${app[docker]}" ]] || return 1
    [[ -x "${app[sort]}" ]] || return 1
    declare -A dict=(
        [docker_dir]="$(koopa_docker_prefix)"
        [delete]=0
        [memory]=''
        [push]=1
        [server]='docker.io'
        [tag]='latest'
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--docker-dir='*)
                dict[docker_dir]="${1#*=}"
                shift 1
                ;;
            '--docker-dir')
                dict[docker_dir]="${2:?}"
                shift 2
                ;;
            '--memory='*)
                dict[memory]="${1#*=}"
                shift 1
                ;;
            '--memory')
                dict[memory]="${2:?}"
                shift 2
                ;;
            '--server='*)
                dict[server]="${1#*=}"
                shift 1
                ;;
            '--server')
                dict[server]="${2:?}"
                shift 2
                ;;
            '--tag='*)
                dict[tag]="${1#*=}"
                shift 1
                ;;
            '--tag')
                dict[tag]="${2:?}"
                shift 2
                ;;
            '--delete')
                dict[delete]=1
                shift 1
                ;;
            '--no-delete')
                dict[delete]=0
                shift 1
                ;;
            '--no-push')
                dict[push]=0
                shift 1
                ;;
            '--push')
                dict[push]=1
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
        dict2[image]="$image"
        build_args=()
        platforms=()
        tags=()
        if ! koopa_str_detect_fixed \
            --string="${dict2[image]}" \
            --pattern='/'
        then
            dict2[image]="acidgenomics/${dict2[image]}"
        fi
        if koopa_str_detect_fixed \
            --string="${dict2[image]}" \
            --pattern=':'
        then
            dict2[tag]="$( \
                koopa_print "${dict2[image]}" \
                | "${app[cut]}" -d ':' -f '2' \
            )"
            dict2[image]="$( \
                koopa_print "${dict2[image]}" \
                | "${app[cut]}" -d ':' -f '1' \
            )"
        else
            dict2[tag]="${dict[tag]}"
        fi
        dict2[source_image]="${dict[docker_dir]}/${dict2[image]}/${dict2[tag]}"
        koopa_assert_is_dir "${dict2[source_image]}"
        dict2[tags_file]="${dict2[source_image]}/tags.txt"
        if [[ -f "${dict2[tags_file]}" ]]
        then
            readarray -t tags < "${dict2[tags_file]}"
        fi
        if [[ -L "${dict2[source_image]}" ]]
        then
            tags+=("${dict2[tag]}")
            dict2[source_image]="$(koopa_realpath "${dict2[source_image]}")"
            dict2[tag]="$(koopa_basename "${dict2[source_image]}")"
        fi
        tags+=(
            "${dict2[tag]}"
            "${dict2[tag]}-$(${app[date]} '+%Y%m%d')"
        )
        readarray -t tags <<< "$( \
            koopa_print "${tags[@]}" \
            | "${app[sort]}" -u \
        )"
        for tag in "${tags[@]}"
        do
            build_args+=("--tag=${dict2[image]}:${tag}")
        done
        platforms=('linux/amd64')
        dict2[platforms_file]="${dict2[source_image]}/platforms.txt"
        if [[ -f "${dict2[platforms_file]}" ]]
        then
            readarray -t platforms < "${dict2[platforms_file]}"
        fi
        dict2[platforms_string]="$(koopa_paste --sep=',' "${platforms[@]}")"
        build_args+=("--platform=${dict2[platforms_string]}")
        if [[ -n "${dict[memory]}" ]]
        then
            build_args+=(
                "--memory=${dict[memory]}"
                "--memory-swap=${dict[memory]}"
            )
        fi
        build_args+=(
            '--no-cache'
            '--progress=auto'
            '--pull'
        )
        if [[ "${dict[push]}" -eq 1 ]]
        then
            build_args+=('--push')
        fi
        build_args+=("${dict2[source_image]}")
        if [[ "${dict[delete]}" -eq 1 ]]
        then
            koopa_alert "Pruning images '${dict2[image]}:${dict2[tag]}'."
            readarray -t image_ids <<< "$( \
                "${app[docker]}" image ls \
                    --filter reference="${dict2[image]}:${dict2[tag]}" \
                    --quiet \
            )"
            if koopa_is_array_non_empty "${image_ids[@]:-}"
            then
                "${app[docker]}" image rm --force "${image_ids[@]}"
            fi
        fi
        koopa_alert "Building '${dict2[source_image]}' Docker image."
        koopa_dl 'Build args' "${build_args[*]}"
        "${app[docker]}" login "${dict[server]}" >/dev/null || return 1
        dict2[build_name]="$(koopa_basename "${dict2[image]}")"
        "${app[docker]}" buildx rm \
            "${dict2[build_name]}" \
            &>/dev/null \
            || true
        "${app[docker]}" buildx create \
            --name="${dict2[build_name]}" \
            --use \
            >/dev/null
        "${app[docker]}" buildx build "${build_args[@]}" || return 1
        "${app[docker]}" buildx rm "${dict2[build_name]}"
        "${app[docker]}" image ls \
            --filter \
            reference="${dict2[image]}:${dict2[tag]}"
        koopa_alert_success "Build of '${dict2[source_image]}' was successful."
    done
    return 0
}

koopa_docker_ghcr_login() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    [[ -x "${app[docker]}" ]] || return 1
    declare -A dict=(
        [pat]="${GHCR_PAT:?}"
        [server]='ghcr.io'
        [user]="${GHCR_USER:?}"
    )
    koopa_print "${dict[pat]}" \
        | "${app[docker]}" login \
            "${dict[server]}" \
            -u "${dict[user]}" \
            --password-stdin
    return 0
}

koopa_docker_ghcr_push() {
    local app dict
    koopa_assert_has_args_eq "$#" 3
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    [[ -x "${app[docker]}" ]] || return 1
    declare -A dict=(
        [image_name]="${2:?}"
        [owner]="${1:?}"
        [server]='ghcr.io'
        [version]="${3:?}"
    )
    dict[url]="${dict[server]}/${dict[owner]}/\
${dict[image_name]}:${dict[version]}"
    koopa_docker_ghcr_login
    "${app[docker]}" push "${dict[url]}"
    return 0
}

koopa_docker_is_build_recent() {
    local app dict image pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [date]="$(koopa_locate_date)"
        [docker]="$(koopa_locate_docker)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[date]}" ]] || return 1
    [[ -x "${app[docker]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    declare -A dict=(
        [days]=7
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--days='*)
                dict[days]="${1#*=}"
                shift 1
                ;;
            '--days')
                dict[days]="${2:?}"
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
    dict[seconds]="$((dict[days] * 86400))"
    for image in "$@"
    do
        local dict2
        declare -A dict2=(
            [current]="$("${app[date]}" -u '+%s')"
            [image]="$image"
        )
        "${app[docker]}" pull "${dict2[image]}" >/dev/null
        dict2[json]="$( \
            "${app[docker]}" inspect \
                --format='{{json .Created}}' \
                "${dict2[image]}" \
        )"
        dict2[created]="$( \
            koopa_grep \
                --only-matching \
                --pattern='[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}' \
                --regex \
                --string="${dict2[json]}" \
            | "${app[sed]}" 's/T/ /' \
            | "${app[sed]}" 's/\$/ UTC/'
        )"
        dict2[created]="$( \
            "${app[date]}" --utc --date="${dict2[created]}" '+%s' \
        )"
        dict2[diff]=$((dict2[current] - dict2[created]))
        [[ "${dict2[diff]}" -le "${dict[seconds]}" ]] && continue
        return 1
    done
    return 0
}

koopa_docker_prune_all_images() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    [[ -x "${app[docker]}" ]] || return 1
    koopa_alert 'Pruning Docker images.'
    "${app[docker]}" system prune --all --force || true
    "${app[docker]}" images
    koopa_alert 'Pruning Docker buildx.'
    "${app[docker]}" buildx prune --all --force || true
    "${app[docker]}" buildx ls
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
        [docker]="$(koopa_locate_docker)"
    )
    [[ -x "${app[docker]}" ]] || return 1
    koopa_alert 'Pruning Docker images older than 3 months.'
    "${app[docker]}" image prune \
        --all \
        --filter 'until=2160h' \
        --force \
        || true
    "${app[docker]}" image prune --force || true
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
        [docker]="$(koopa_locate_docker)"
        [sed]="$(koopa_locate_sed)"
        [sort]="$(koopa_locate_sort)"
        [tr]="$(koopa_locate_tr)"
    )
    [[ -x "${app[docker]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    [[ -x "${app[sort]}" ]] || return 1
    [[ -x "${app[tr]}" ]] || return 1
    declare -A dict=(
        [server]='docker.io'
    )
    for pattern in "$@"
    do
        local dict2 image images
        declare -A dict2=(
            [pattern]="$pattern"
        )
        koopa_assert_is_matching_regex \
            --string="${dict2[pattern]}" \
            --pattern='^.+/.+$'
        dict2[json]="$( \
            "${app[docker]}" inspect \
                --format="{{json .RepoTags}}" \
                "${dict2[pattern]}" \
        )"
        readarray -t images <<< "$( \
            koopa_print "${dict2[json]}" \
                | "${app[tr]}" ',' '\n' \
                | "${app[sed]}" 's/^\[//' \
                | "${app[sed]}" 's/\]$//' \
                | "${app[sed]}" 's/^\"//g' \
                | "${app[sed]}" 's/\"$//g' \
                | "${app[sort]}" \
        )"
        if koopa_is_array_empty "${images[@]:-}"
        then
            koopa_stop "Failed to match any images with '${dict2[pattern]}'."
        fi
        for image in "${images[@]}"
        do
            koopa_alert "Pushing '${image}' to '${dict[server]}'."
            "${app[docker]}" push "${dict[server]}/${image}"
        done
    done
    return 0
}

koopa_docker_remove() {
    local app pattern
    koopa_assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [docker]="$(koopa_locate_docker)"
        [xargs]="$(koopa_locate_xargs)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[docker]}" ]] || return 1
    [[ -x "${app[xargs]}" ]] || return 1
    for pattern in "$@"
    do
        "${app[docker]}" images \
            | koopa_grep --pattern="$pattern" \
            | "${app[awk]}" '{print $3}' \
            | "${app[xargs]}" "${app[docker]}" rmi --force
    done
    return 0
}

koopa_docker_run() {
    local app dict pos run_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    [[ -x "${app[docker]}" ]] || return 1
    declare -A dict=(
        [arm]=0
        [bash]=0
        [bind]=0
        [workdir]='/mnt/work'
        [x86]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--arm')
                dict[arm]=1
                shift 1
                ;;
            '--bash')
                dict[bash]=1
                shift 1
                ;;
            '--bind')
                dict[bind]=1
                shift 1
                ;;
            '--x86')
                dict[x86]=1
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
    dict[image]="${1:?}"
    "${app[docker]}" pull "${dict[image]}"
    run_args=(
        '--interactive'
        '--tty'
    )
    if [[ "${dict[bind]}" -eq 1 ]]
    then
        if [[ "${HOME:?}" == "${PWD:?}" ]]
        then
            koopa_stop "Do not set '--bind' when running at HOME."
        fi
        run_args+=(
            "--volume=${PWD:?}:${dict[workdir]}"
            "--workdir=${dict[workdir]}"
        )
    fi
    if [[ "${dict[arm]}" -eq 1 ]]
    then
        run_args+=('--platform=linux/arm64')
    elif [[ "${dict[x86]}" -eq 1 ]]
    then
        run_args+=('--platform=linux/amd64')
    fi
    run_args+=("${dict[image]}")
    if [[ "${dict[bash]}" -eq 1 ]]
    then
        run_args+=('bash' '-il')
    fi
    "${app[docker]}" run "${run_args[@]}"
    return 0
}

koopa_docker_tag() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    [[ -x "${app[docker]}" ]] || return 1
    declare -A dict=(
        [dest_tag]="${3:-}"
        [image]="${1:?}"
        [server]='docker.io'
        [source_tag]="${2:?}"
    )
    [[ -z "${dict[dest_tag]}" ]] && dict[dest_tag]='latest'
    if ! koopa_str_detect_fixed \
        --string="${dict[image]}" \
        --pattern='/'
    then
        dict[image]="acidgenomics/${dict[image]}"
    fi
    if [[ "${dict[source_tag]}" == "${dict[dest_tag]}" ]]
    then
        koopa_alert_info "Source tag identical to destination \
('${dict[source_tag]}')."
        return 0
    fi
    koopa_alert "Tagging '${dict[image]}:${dict[source_tag]}' \
as '${dict[dest_tag]}'."
    "${app[docker]}" login "${dict[server]}"
    "${app[docker]}" pull "${dict[server]}/${dict[image]}:${dict[source_tag]}"
    "${app[docker]}" tag \
        "${dict[image]}:${dict[source_tag]}" \
        "${dict[image]}:${dict[dest_tag]}"
    "${app[docker]}" push "${dict[server]}/${dict[image]}:${dict[dest_tag]}"
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
        [head]="$(koopa_locate_head)"
    )
    [[ -x "${app[head]}" ]] || return 1
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
            | "${app[head]}" -n 1 \
        )"
        koopa_download "https://cran.r-project.org/src/contrib/${file}"
    done
    return 0
}

koopa_download_ensembl_genome() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadEnsemblGenome' "$@"
}

koopa_download_gencode_genome() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadGencodeGenome' "$@"
}

koopa_download_github_latest() {
    local api_url app repo tag tarball_url
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [tr]="$(koopa_locate_tr)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[tr]}" ]] || return 1
    for repo in "$@"
    do
        api_url="https://api.github.com/repos/${repo}/releases/latest"
        tarball_url="$( \
            koopa_parse_url "$api_url" \
            | koopa_grep --pattern='tarball_url' \
            | "${app[cut]}" -d ':' -f '2,3' \
            | "${app[tr]}" --delete ' ,"' \
        )"
        tag="$(koopa_basename "$tarball_url")"
        koopa_download "$tarball_url" "${tag}.tar.gz"
    done
    return 0
}

koopa_download_refseq_genome() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadRefseqGenome' "$@"
}

koopa_download_ucsc_genome() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadUCSCGenome' "$@"
}

koopa_download() {
    local app dict download_args pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [decompress]=0
        [extract]=0
        [engine]='curl'
        [file]="${2:-}"
        [url]="${1:?}"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--engine='*)
                dict[engine]="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict[engine]="${2:?}"
                shift 2
                ;;
            '--decompress')
                dict[decompress]=1
                shift 1
                ;;
            '--extract')
                dict[extract]=1
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
    declare -A app=(
        [download]="$("koopa_locate_${dict[engine]}")"
    )
    [[ -x "${app[download]}" ]] || return 1
    if [[ -z "${dict[file]}" ]]
    then
        dict[file]="$(koopa_basename "${dict[url]}")"
        if koopa_str_detect_fixed --string="${dict[file]}" --pattern='%'
        then
            dict[file]="$( \
                koopa_print "${dict[file]}" \
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
        --string="${dict[file]}" \
        --pattern='/'
    then
        dict[file]="${PWD:?}/${dict[file]}"
    fi
    download_args=()
    case "${dict[engine]}" in
        'curl')
            download_args+=(
                '--disable' # Ignore '~/.curlrc'. Must come first.
                '--create-dirs'
                '--fail'
                '--location'
                '--output' "${dict[file]}"
                '--retry' 5
                '--show-error'
            )
            ;;
        'wget')
            download_args+=(
                "--output-document=${dict[file]}"
                '--no-verbose'
            )
            ;;
    esac
    download_args+=("${dict[url]}")
    koopa_alert "Downloading '${dict[url]}' to '${dict[file]}'."
    "${app[download]}" "${download_args[@]}"
    if [[ "${dict[decompress]}" -eq 1 ]]
    then
        koopa_decompress "${dict[file]}"
    elif [[ "${dict[extract]}" -eq 1 ]]
    then
        koopa_extract "${dict[file]}"
    fi
    return 0
}

koopa_enable_passwordless_sudo() {
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A dict=(
        [file]='/etc/sudoers.d/sudo'
        [group]="$(koopa_admin_group)"
    )
    dict[string]="%${dict[group]} ALL=(ALL) NOPASSWD: ALL"
    if [[ -f "${dict[file]}" ]] && \
        koopa_file_detect_fixed \
            --file="${dict[file]}" \
            --pattern="${dict[group]}" \
            --sudo
    then
        koopa_alert_success "Passwordless sudo for '${dict[group]}' group \
already enabled at '${dict[file]}'."
        return 0
    fi
    koopa_alert "Modifying '${dict[file]}' to include '${dict[group]}'."
    koopa_sudo_append_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
    koopa_chmod --sudo '0440' "${dict[file]}"
    koopa_alert_success "Passwordless sudo enabled for '${dict[group]}' \
at '${file}'."
    return 0
}

koopa_enable_shell_for_all_users() {
    local app apps dict
    koopa_assert_has_args "$#"
    koopa_is_admin || return 0
    declare -A dict=(
        [etc_file]='/etc/shells'
        [user]="$(koopa_user)"
    )
    apps=("$@")
    for app in "${apps[@]}"
    do
        if ! koopa_file_detect_fixed \
            --file="${dict[etc_file]}" \
            --pattern="$app"
        then
            koopa_alert "Updating '${dict[etc_file]}' to include '${app}'."
            koopa_sudo_append_string \
                --file="${dict[etc_file]}" \
                --string="$app"
        else
            koopa_alert_note "'$app' already defined in '${dict[etc_file]}'."
        fi
    done
    if [[ "$#" -eq 1 ]]
    then
        koopa_alert_info "Run 'chsh -s ${apps[0]} ${dict[user]}' to change \
the default shell."
    fi
    return 0
}

koopa_ensure_newline_at_end_of_file() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [tail]="$(koopa_locate_tail)"
    )
    [[ -x "${app[tail]}" ]] || return 1
    declare -A dict=(
        [file]="${1:?}"
    )
    [[ -n "$("${app[tail]}" --bytes=1 "${dict[file]}")" ]] || return 0
    printf '\n' >> "${dict[file]}"
    return 0
}

koopa_entab() {
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        [vim]="$(koopa_locate_vim)"
    )
    [[ -x "${app[vim]}" ]] || return 1
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app[vim]}" \
            -c 'set noexpandtab tabstop=4 shiftwidth=4' \
            -c ':%retab!' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
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
    declare -A app=(
        [head]="$(koopa_locate_head)"
    )
    [[ -x "${app[head]}" ]] || return 1
    declare -A dict=(
        [pattern]="$(koopa_version_pattern)"
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
                --pattern="${dict[pattern]}" \
                --regex \
                --string="$arg" \
            | "${app[head]}" -n 1 \
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
    dict[orig_path]="${PATH:-}"
    for file in "$@"
    do
        koopa_assert_is_file "$file"
        file="$(koopa_realpath "$file")"
        koopa_alert "Extracting '${file}'."
        case "$file" in
            *'.tar.bz2' | \
            *'.tar.gz' | \
            *'.tar.xz')
                app[cmd]="$(koopa_locate_tar)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-x' # '--extract'.
                )
                case "$file" in
                    *'.bz2')
                        app[cmd2]="$(koopa_locate_bzip2)"
                        [[ -x "${app[cmd2]}" ]] || return 1
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app[cmd2]}")"
                        cmd_args+=('-j') # '--bzip2'.
                        ;;
                    *'.gz')
                        app[cmd2]="$(koopa_locate_gzip)"
                        [[ -x "${app[cmd2]}" ]] || return 1
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app[cmd2]}")"
                        cmd_args+=('-z') # '--gzip'.
                        ;;
                    *'.xz')
                        app[cmd2]="$(koopa_locate_xz)"
                        [[ -x "${app[cmd2]}" ]] || return 1
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app[cmd2]}")"
                        cmd_args+=('-J') # '--xz'.
                        ;;
                esac
                ;;
            *'.bz2')
                app[cmd]="$(koopa_locate_bunzip2)"
                cmd_args=("$file")
                ;;
            *'.gz')
                app[cmd]="$(koopa_locate_gzip)"
                cmd_args=(
                    '-d' # '--decompress'.
                    "$file"
                )
                ;;
            *'.tar')
                app[cmd]="$(koopa_locate_tar)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-x' # '--extract'.
                )
                ;;
            *'.tbz2')
                app[cmd]="$(koopa_locate_tar)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-j' # '--bzip2'.
                    '-x' # '--extract'.
                )
                ;;
            *'.tgz')
                app[cmd]="$(koopa_locate_tar)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-x' # '--extract'.
                    '-z' # '--gzip'.
                )
                ;;
            *'.xz')
                app[cmd]="$(koopa_locate_xz)"
                cmd_args=(
                    '-d' # '--decompress'.
                    "$file"
                    )
                ;;
            *'.zip')
                app[cmd]="$(koopa_locate_unzip)"
                cmd_args=(
                    '-qq'
                    "$file"
                )
                ;;
            *'.Z')
                app[cmd]="$(koopa_locate_uncompress)"
                cmd_args=("$file")
                ;;
            *'.7z')
                app[cmd]="$(koopa_locate_7z)"
                cmd_args=(
                    '-x'
                    "$file"
                )
                ;;
            *)
                koopa_stop "Unsupported extension: '${file}'."
                ;;
        esac
        [[ -x "${app[cmd]}" ]] || return 1
        "${app[cmd]}" "${cmd_args[@]}"
    done
    export PATH="${dict[orig_path]}"
    return 0
}

koopa_fasta_generate_chromosomes_file() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [grep]="$(koopa_locate_grep)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[grep]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    declare -A dict=(
        [genome_fasta_file]=''
        [output_file]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict[genome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict[genome_fasta_file]="${2:?}"
                shift 2
                ;;
            '--output-file='*)
                dict[output_file]="${1#*=}"
                shift 1
                ;;
            '--output-file')
                dict[output_file]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict[genome_fasta_file]}" \
        '--output-file' "${dict[output_file]}"
    koopa_assert_is_not_file "${dict[output_file]}"
    koopa_assert_is_file "${dict[genome_fasta_file]}"
    koopa_alert "Generating '${dict[output_file]}' from \
'${dict[genome_fasta_file]}'."
    "${app[grep]}" '^>' \
        <(koopa_decompress --stdout "${dict[genome_fasta_file]}") \
        | "${app[cut]}" -d ' ' -f '1' \
        > "${dict[output_file]}"
    "${app[sed]}" \
        -i.bak \
        's/>//g' \
        "${dict[output_file]}"
    koopa_assert_is_file "${dict[output_file]}"
    return 0
}

koopa_fasta_generate_decoy_transcriptome_file() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
    )
    [[ -x "${app[cat]}" ]] || return 1
    declare -A dict=(
        [genome_fasta_file]=''
        [output_file]='' # 'gentrome.fa.gz'
        [transcriptome_fasta_file]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict[genome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict[genome_fasta_file]="${2:?}"
                shift 2
                ;;
            '--output-file='*)
                dict[output_file]="${1#*=}"
                shift 1
                ;;
            '--output-file')
                dict[output_file]="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict[transcriptome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict[transcriptome_fasta_file]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict[genome_fasta_file]}" \
        '--output-file' "${dict[output_file]}" \
        '--transcriptome-fasta-file' "${dict[transcriptome_fasta_file]}"
    koopa_assert_is_not_file "${dict[output_file]}"
    koopa_assert_is_file \
        "${dict[genome_fasta_file]}" \
        "${dict[transcriptome_fasta_file]}"
    dict[genome_fasta_file]="$(koopa_realpath "${dict[genome_fasta_file]}")"
    dict[transcriptome_fasta_file]="$( \
        koopa_realpath "${dict[transcriptome_fasta_file]}" \
    )"
    koopa_assert_is_matching_regex \
        --pattern='\.gz$' \
        --string="${dict[genome_fasta_file]}"
    koopa_assert_is_matching_regex \
        --pattern='\.gz$' \
        --string="${dict[transcriptome_fasta_file]}"
    koopa_assert_is_matching_regex \
        --pattern='\.gz$' \
        --string="${dict[output_file]}"
    koopa_alert "Generating decoy-aware transcriptome \
at '${dict[output_file]}'."
    koopa_dl \
        'Genome FASTA file' "${dict[genome_fasta_file]}" \
        'Transcriptome FASTA file' "${dict[transcriptome_fasta_file]}"
    "${app[cat]}" \
        "${dict[transcriptome_fasta_file]}" \
        "${dict[genome_fasta_file]}" \
        > "${dict[output_file]}"
    koopa_assert_is_file "${dict[output_file]}"
    return 0
}

koopa_fastq_detect_quality_score() {
    local app file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [head]="$(koopa_locate_head)"
        [od]="$(koopa_locate_od)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[od]}" ]] || return 1
    for file in "$@"
    do
        local str
        str="$( \
            "${app[head]}" -n 1000 \
                <(koopa_decompress --stdout "$file") \
            | "${app[awk]}" '{if(NR%4==0) printf("%s",$0);}' \
            | "${app[od]}" \
                --address-radix='n' \
                --format='u1' \
            | "${app[awk]}" 'BEGIN{min=100;max=0;} \
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
        [cat]="$(koopa_locate_cat)"
    )
    [[ -x "${app[cat]}" ]] || return 1
    declare -A dict=(
        [prefix]='lanepool'
        [source_dir]="${PWD:?}"
        [target_dir]="${PWD:?}"
    )
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--source-dir='*)
                dict[source_dir]="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict[source_dir]="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict[source_dir]}"
    dict[source_dir]="$(koopa_realpath "${dict[source_dir]}")"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*_L001_*.fastq*' \
            --prefix="${dict[source_dir]}" \
            --sort \
            --type='f' \
    )"
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa_stop "No lane-split FASTQ files in '${dict[source_dir]}'."
    fi
    dict[target_dir]="$(koopa_init_dir "${dict[target_dir]}")"
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
        i="${dict[target_dir]}/${dict[prefix]}_${i}"
        out+=("$i")
    done
    for i in "${!out[@]}"
    do
        "${app[cat]}" \
            "${dict[source_dir]}/${head[i]}_L00"[1-9]"_${tail[i]}" \
            > "${out[i]}"
    done
    return 0
}

koopa_fastq_number_of_reads() {
    local app file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [wc]="$(koopa_locate_wc)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[wc]}" ]] || return 1
    for file in "$@"
    do
        local num
        num="$( \
            "${app[wc]}" -l \
                <(koopa_decompress --stdout "$file") \
            | "${app[awk]}" '{print $1/4}' \
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
        [wc]="$(koopa_locate_wc)"
    )
    [[ -x "${app[wc]}" ]] || return 1
    declare -A dict=(
        [prefix]="${1:?}"
    )
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    dict[out]="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --type='f' \
            --prefix="${dict[prefix]}" \
        | "${app[wc]}" -l \
    )"
    [[ -n "${dict[out]}" ]] || return 1
    koopa_print "${dict[out]}"
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
        [cut]="$(koopa_locate_cut)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    for file in "$@"
    do
        if koopa_has_file_ext "$file"
        then
            x="$( \
                koopa_print "$file" \
                | "${app[cut]}" -d '.' -f '2-' \
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
    local app dict flags pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    [[ -x "${app[perl]}" ]] || return 1
    declare -A dict=(
        [multiline]=0
        [pattern]=''
        [regex]=0
        [replacement]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            '--replacement='*)
                dict[replacement]="${1#*=}"
                shift 1
                ;;
            '--replacement')
                dict[replacement]="${2:-}"
                shift 2
                ;;
            '--fixed')
                dict[regex]=0
                shift 1
                ;;
            '--multiline')
                dict[multiline]=1
                shift 1
                ;;
            '--regex')
                dict[regex]=1
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
    koopa_assert_is_set '--pattern' "${dict[pattern]}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    if [[ "${dict[regex]}" -eq 1 ]]
    then
        dict[expr]="s/${dict[pattern]}/${dict[replacement]}/g"
    else
        dict[expr]=" \
            \$pattern = quotemeta '${dict[pattern]}'; \
            \$replacement = '${dict[replacement]}'; \
            s/\$pattern/\$replacement/g; \
        "
    fi
    flags=('-i' '-p')
    [[ "${dict[multiline]}" -eq 1 ]] && flags+=('-0')
    "${app[perl]}" "${flags[@]}" -e "${dict[expr]}" "$@"
    return 0
}

koopa_find_app_version() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [sort]="$(koopa_locate_sort)"
        [tail]="$(koopa_locate_tail)"
    )
    [[ -x "${app[sort]}" ]] || return 1
    [[ -x "${app[tail]}" ]] || return 1
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [name]="${1:?}"
    )
    dict[prefix]="${dict[app_prefix]}/${dict[name]}"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[hit]="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[prefix]}" \
            --type='d' \
        | "${app[sort]}" \
        | "${app[tail]}" -n 1 \
    )"
    [[ -d "${dict[hit]}" ]] || return 1
    dict[hit_bn]="$(koopa_basename "${dict[hit]}")"
    koopa_print "${dict[hit_bn]}"
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
        [awk]="$(koopa_locate_awk)"
        [basename]="$(koopa_locate_basename)"
        [xargs]="$(koopa_locate_xargs)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[basename]}" ]] || return 1
    [[ -x "${app[xargs]}" ]] || return 1
    declare -A dict=(
        [type]="${1:?}"
        [header]="${2:?}"
    )
    dict[str]="$( \
        koopa_find \
            --max-depth=1 \
            --pattern='.*' \
            --prefix="${HOME:?}" \
            --print0 \
            --sort \
            --type="${dict[type]}" \
        | "${app[xargs]}" -0 -n 1 "${app[basename]}" \
        | "${app[awk]}" '{print "    -",$0}' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_h2 "${dict[header]}:"
    koopa_print "${dict[str]}"
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
        [pcregrep]="$(koopa_locate_pcregrep)"
    )
    [[ -x "${app[pcregrep]}" ]] || return 1
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
        str="$("${app[pcregrep]}" -LMr '\n$' "${files[@]}")"
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
        [du]="$(koopa_locate_du)"
        [sort]="$(koopa_locate_sort)"
        [tail]="$(koopa_locate_tail)"
    )
    [[ -x "${app[du]}" ]] || return 1
    [[ -x "${app[sort]}" ]] || return 1
    [[ -x "${app[tail]}" ]] || return 1
    for prefix in "$@"
    do
        local str
        prefix="$(koopa_realpath "$prefix")"
        str="$( \
            "${app[du]}" \
                --max-depth=10 \
                --threshold=100000000 \
                "${prefix}"/* \
                2>/dev/null \
            | "${app[sort]}" --numeric-sort \
            | "${app[tail]}" -n 50 \
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
    declare -A app=(
        [head]="$(koopa_locate_head)"
    )
    [[ -x "${app[head]}" ]] || return 1
    for prefix in "$@"
    do
        str="$( \
            koopa_find \
                --min-depth=1 \
                --prefix="$prefix" \
                --size='+100000000c' \
                --sort \
                --type='f' \
            | "${app[head]}" -n 50 \
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
        [brew_prefix]="$(koopa_homebrew_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
    )
    find_args=(
        '--min-depth' 1
        '--prefix' "${dict[make_prefix]}"
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
    if [[ "${dict[brew_prefix]}" == "${dict[make_prefix]}" ]]
    then
        find_args+=(
            '--exclude' 'Caskroom/**'
            '--exclude' 'Cellar/**'
            '--exclude' 'Homebrew/**'
            '--exclude' 'var/homebrew/**'
        )
    fi
    dict[out]="$(koopa_find "${find_args[@]}")"
    koopa_print "${dict[out]}"
    return 0
}

koopa_find_symlinks() {
    local dict hits symlink symlinks
    koopa_assert_has_args "$#"
    declare -A dict=(
        [source_prefix]=''
        [target_prefix]=''
        [verbose]=0
    )
    hits=()
    while (("$#"))
    do
        case "$1" in
            '--source-prefix='*)
                dict[source_prefix]="${1#*=}"
                shift 1
                ;;
            '--source-prefix')
                dict[source_prefix]="${2:?}"
                shift 2
                ;;
            '--target-prefix='*)
                dict[target_prefix]="${1#*=}"
                shift 1
                ;;
            '--target-prefix')
                dict[target_prefix]="${2:?}"
                shift 2
                ;;
            '--verbose')
                dict[verbose]=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--source-prefix' "${dict[source_prefix]}" \
        '--target-prefix' "${dict[target_prefix]}"
    koopa_assert_is_dir "${dict[source_prefix]}" "${dict[target_prefix]}"
    dict[source_prefix]="$(koopa_realpath "${dict[source_prefix]}")"
    dict[target_prefix]="$(koopa_realpath "${dict[target_prefix]}")"
    readarray -t symlinks <<< "$(
        koopa_find \
            --prefix="${dict[target_prefix]}" \
            --sort \
            --type='l' \
    )"
    for symlink in "${symlinks[@]}"
    do
        local symlink_real
        symlink_real="$(koopa_realpath "$symlink")"
        if koopa_str_detect_regex \
            --pattern="^${dict[source_prefix]}/" \
            --string="$symlink_real"
        then
            if [[ "${dict[verbose]}" -eq 1 ]]
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
        [shell]="$(koopa_shell_name)"
    )
    case "${dict[shell]}" in
        'bash')
            dict[file]="${HOME}/.bashrc"
            ;;
        'zsh')
            dict[file]="${HOME}/.zshrc"
            ;;
        *)
            dict[file]="${HOME}/.profile"
            ;;
    esac
    [[ -n "${dict[file]}" ]] || return 1
    koopa_print "${dict[file]}"
    return 0
}

koopa_find() {
    local app dict exclude_arg exclude_arr find find_args results sorted_results
    declare -A app
    declare -A dict=(
        [days_modified_gt]=''
        [days_modified_lt]=''
        [empty]=0
        [engine]="${KOOPA_FIND_ENGINE:-}"
        [exclude]=0
        [max_depth]=''
        [min_depth]=1
        [pattern]=''
        [print0]=0
        [size]=''
        [sort]=0
        [sudo]=0
        [type]=''
        [verbose]=0
    )
    exclude_arr=()
    while (("$#"))
    do
        case "$1" in
            '--days-modified-before='*)
                dict[days_modified_gt]="${1#*=}"
                shift 1
                ;;
            '--days-modified-before')
                dict[days_modified_gt]="${2:?}"
                shift 2
                ;;
            '--days-modified-within='*)
                dict[days_modified_lt]="${1#*=}"
                shift 1
                ;;
            '--days-modified-within')
                dict[days_modified_lt]="${2:?}"
                shift 2
                ;;
            '--engine='*)
                dict[engine]="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict[engine]="${2:?}"
                shift 2
                ;;
            '--exclude='*)
                dict[exclude]=1
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                dict[exclude]=1
                exclude_arr+=("${2:?}")
                shift 2
                ;;
            '--max-depth='*)
                dict[max_depth]="${1#*=}"
                shift 1
                ;;
            '--max-depth')
                dict[max_depth]="${2:?}"
                shift 2
                ;;
            '--min-depth='*)
                dict[min_depth]="${1#*=}"
                shift 1
                ;;
            '--min-depth')
                dict[min_depth]="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
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
            '--size='*)
                dict[size]="${1#*=}"
                shift 1
                ;;
            '--size')
                dict[size]="${2:?}"
                shift 2
                ;;
            '--type='*)
                dict[type]="${1#*=}"
                shift 1
                ;;
            '--type')
                dict[type]="${2:?}"
                shift 2
                ;;
            '--empty')
                dict[empty]=1
                shift 1
                ;;
            '--print0')
                dict[print0]=1
                shift 1
                ;;
            '--sort')
                dict[sort]=1
                shift 1
                ;;
            '--sudo')
                dict[sudo]=1
                shift 1
                ;;
            '--verbose')
                dict[verbose]=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    if [[ -z "${dict[engine]}" ]]
    then
        app[find]="$(koopa_locate_fd --allow-missing)"
        [[ ! -x "${app[find]}" ]] && app[find]="$(koopa_locate_find)"
        dict[engine]="$(koopa_basename "${app[find]}")"
    else
        app[find]="$(koopa_locate_"${dict[engine]}")"
    fi
    [[ -x "${app[find]}" ]] || return 1
    find=()
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        [[ -x "${app[sudo]}" ]] || return 1
        find+=("${app[sudo]}")
    fi
    find+=("${app[find]}")
    case "${dict[engine]}" in
        'fd')
            find_args=(
                '--absolute-path'
                '--base-directory' "${dict[prefix]}"
                '--case-sensitive'
                '--glob'
                '--hidden'
                '--no-follow'
                '--no-ignore'
                '--one-file-system'
            )
            if [[ -n "${dict[min_depth]}" ]]
            then
                find_args+=('--min-depth' "${dict[min_depth]}")
            fi
            if [[ -n "${dict[max_depth]}" ]]
            then
                find_args+=('--max-depth' "${dict[max_depth]}")
            fi
            if [[ -n "${dict[type]}" ]]
            then
                case "${dict[type]}" in
                    'd')
                        dict[type]='directory'
                        ;;
                    'f')
                        dict[type]='file'
                        ;;
                    'l')
                        dict[type]='symlink'
                        ;;
                    *)
                        koopa_stop 'Invalid type argument for Rust fd.'
                        ;;
                esac
                find_args+=('--type' "${dict[type]}")
            fi
            if [[ "${dict[empty]}" -eq 1 ]]
            then
                find_args+=('--type' 'empty')
            fi
            if [[ -n "${dict[days_modified_gt]}" ]]
            then
                find_args+=(
                    '--changed-before'
                    "${dict[days_modified_gt]}d"
                )
            fi
            if [[ -n "${dict[days_modified_lt]}" ]]
            then
                find_args+=(
                    '--changed-within'
                    "${dict[days_modified_lt]}d"
                )
            fi
            if [[ "${dict[exclude]}" -eq 1 ]]
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    find_args+=('--exclude' "$exclude_arg")
                done
            fi
            if [[ -n "${dict[size]}" ]]
            then
                dict[size]="$( \
                    koopa_sub \
                        --pattern='c$' \
                        --replacement='b' \
                        "${dict[size]}" \
                )"
                find_args+=('--size' "${dict[size]}")
            fi
            if [[ "${dict[print0]}" -eq 1 ]]
            then
                find_args+=('--print0')
            fi
            if [[ -n "${dict[pattern]}" ]]
            then
                find_args+=("${dict[pattern]}")
            fi
            ;;
        'find')
            find_args=(
                "${dict[prefix]}"
                '-xdev'
            )
            if [[ -n "${dict[min_depth]}" ]]
            then
                find_args+=('-mindepth' "${dict[min_depth]}")
            fi
            if [[ -n "${dict[max_depth]}" ]]
            then
                find_args+=('-maxdepth' "${dict[max_depth]}")
            fi
            if [[ -n "${dict[pattern]}" ]]
            then
                if koopa_str_detect_fixed \
                    --pattern="{" \
                    --string="${dict[pattern]}"
                then
                    readarray -O "${#find_args[@]}" -t find_args <<< "$( \
                        local globs1 globs2 globs3 str
                        readarray -d ',' -t globs1 <<< "$( \
                            koopa_gsub \
                                --pattern='[{}]' \
                                --replacement='' \
                                "${dict[pattern]}" \
                        )"
                        globs2=()
                        for i in "${!globs1[@]}"
                        do
                            globs2+=(
                                "-name ${globs1[i]}"
                            )
                        done
                        str="( $(koopa_paste --sep=' -o ' "${globs2[@]}") )"
                        readarray -d ' ' -t globs3 <<< "$(
                            koopa_print "$str"
                        )"
                        koopa_print "${globs3[@]}"
                    )"
                else
                    find_args+=('-name' "${dict[pattern]}")
                fi
            fi
            if [[ -n "${dict[type]}" ]]
            then
                case "${dict[type]}" in
                    'broken-symlink')
                        find_args+=('-xtype' 'l')
                        ;;
                    'd' | \
                    'f' | \
                    'l')
                        find_args+=('-type' "${dict[type]}")
                        ;;
                    *)
                        koopa_stop 'Invalid file type argument.'
                        ;;
                esac
            fi
            if [[ -n "${dict[days_modified_gt]}" ]]
            then
                find_args+=('-mtime' "+${dict[days_modified_gt]}")
            fi
            if [[ -n "${dict[days_modified_lt]}" ]]
            then
                find_args+=('-mtime' "-${dict[days_modified_lt]}")
            fi
            if [[ "${dict[exclude]}" -eq 1 ]]
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    exclude_arg="$( \
                        koopa_sub \
                            --pattern='^' \
                            --replacement="${dict[prefix]}/" \
                            "$exclude_arg" \
                    )"
                    find_args+=('-not' '-path' "$exclude_arg")
                done
            fi
            if [[ "${dict[empty]}" -eq 1 ]]
            then
                find_args+=('-empty')
            fi
            if [[ -n "${dict[size]}" ]]
            then
                find_args+=('-size' "${dict[size]}")
            fi
            if [[ "${dict[print0]}" -eq 1 ]]
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
    if [[ "${dict[verbose]}" -eq 1 ]]
    then
        koopa_warn "Find command: ${find[*]} ${find_args[*]}"
    fi
    if [[ "${dict[sort]}" -eq 1 ]]
    then
        app[sort]="$(koopa_locate_sort)"
        [[ -x "${app[sort]}" ]] || return 1
    fi
    if [[ "${dict[print0]}" -eq 1 ]]
    then
        readarray -t -d '' results < <( \
            "${find[@]}" "${find_args[@]}" 2>/dev/null \
        )
        koopa_is_array_non_empty "${results[@]:-}" || return 1
        if [[ "${dict[sort]}" -eq 1 ]]
        then
            readarray -t -d '' sorted_results < <( \
                printf '%s\0' "${results[@]}" | "${app[sort]}" -z \
            )
            results=("${sorted_results[@]}")
        fi
        printf '%s\0' "${results[@]}"
    else
        readarray -t results <<< "$( \
            "${find[@]}" "${find_args[@]}" 2>/dev/null \
        )"
        koopa_is_array_non_empty "${results[@]:-}" || return 1
        if [[ "${dict[sort]}" -eq 1 ]]
        then
            readarray -t sorted_results <<< "$( \
                koopa_print "${results[@]}" | "${app[sort]}" \
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
        [app_prefix]="$(koopa_app_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    if koopa_is_shared_install
    then
        dict[stat_user]="$( \
            koopa_stat_user "${dict[koopa_prefix]}/lang/shell/zsh" \
        )"
        if [[ "${dict[stat_user]}" != 'root' ]]
        then
            koopa_chown --sudo 'root' \
                "${dict[koopa_prefix]}/lang/shell/zsh" \
                "${dict[koopa_prefix]}/lang/shell/zsh/functions"
            koopa_chmod --sudo 'g-w' \
                "${dict[koopa_prefix]}/lang/shell/zsh" \
                "${dict[koopa_prefix]}/lang/shell/zsh/functions"
        fi
    else
        koopa_chmod 'g-w' \
            "${dict[koopa_prefix]}/lang/shell/zsh" \
            "${dict[koopa_prefix]}/lang/shell/zsh/functions"
    fi
    if [[ -d "${dict[app_prefix]}/zsh" ]]
    then
        koopa_chmod 'g-w' \
            "${dict[app_prefix]}/zsh/"*'/share/zsh' \
            "${dict[app_prefix]}/zsh/"*'/share/zsh/'* \
            "${dict[app_prefix]}/zsh/"*'/share/zsh/'*'/functions'
    fi
    return 0
}

koopa_ftp_mirror() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [wget]="$(koopa_locate_wget)"
    )
    [[ -x "${app[wget]}" ]] || return 1
    declare -A dict=(
        [dir]=''
        [host]=''
        [user]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--dir='*)
                dict[dir]="${1#*=}"
                shift 1
                ;;
            '--dir')
                dict[dir]="${2:?}"
                shift 2
                ;;
            '--host='*)
                dict[host]="${1#*=}"
                shift 1
                ;;
            '--host')
                dict[host]="${2:?}"
                shift 2
                ;;
            '--user='*)
                dict[user]="${1#*=}"
                shift 1
                ;;
            '--user')
                dict[user]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--host' "${dict[host]}" \
        '--user' "${dict[user]}"
    if [[ -n "${dict[dir]}" ]]
    then
        dict[dir]="${dict[host]}/${dict[dir]}"
    else
        dict[dir]="${dict[host]}"
    fi
    "${app[wget]}" \
        --ask-password \
        --mirror \
        "ftp://${dict[user]}@${dict[dir]}/"*
    return 0
}

koopa_gcrypt_url() {
    koopa_assert_has_no_args "$#"
    koopa_variable 'gcrypt-url'
    return 0
}

koopa_get_version_from_pkg_config() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [pkg_config]="$(koopa_locate_pkg_config)"
    )
    [[ -x "${app[pkg_config]}" ]] || return 1
    declare -A dict=(
        [opt_name]=''
        [opt_prefix]="$(koopa_opt_prefix)"
        [pc_name]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--opt-name='*)
                dict[opt_name]="${1#*=}"
                shift 1
                ;;
            '--opt-name')
                dict[opt_name]="${2:?}"
                shift 2
                ;;
            '--pc-name='*)
                dict[pc_name]="${1#*=}"
                shift 1
                ;;
            '--pc-name')
                dict[pc_name]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--opt-name' "${dict[opt_name]}" \
        '--pc-name' "${dict[pc_name]}"
    dict[pc_file]="${dict[opt_prefix]}/${dict[opt_name]}/lib/\
pkgconfig/${dict[pc_name]}.pc"
    koopa_assert_is_file "${dict[pc_file]}"
    dict[str]="$("${app[pkg_config]}" --modversion "${dict[pc_file]}")"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

koopa_get_version() {
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [app_name]=''
        [opt_name]=''
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--app-name='*)
                dict[app_name]="${1#*=}"
                shift 1
                ;;
            '--app-name')
                dict[app_name]="${2:?}"
                shift 2
                ;;
            '--opt-name='*)
                dict[opt_name]="${1#*=}"
                shift 1
                ;;
            '--opt-name')
                dict[opt_name]="${2:?}"
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
    if [[ "$#" -gt 0 ]]
    then
        koopa_assert_has_args_eq "$#" 1
        dict[cmd]="${1:?}"
    else
        koopa_assert_is_set \
            '--app-name' "${dict[app_name]}" \
            '--opt-name' "${dict[opt_name]}"
        dict[cmd]="${dict[opt_prefix]}/${dict[opt_name]}/bin/${dict[app_name]}"
    fi
    dict[bn]="$(koopa_basename "${dict[cmd]}")"
    dict[bn_snake]="$(koopa_snake_case_simple "${dict[bn]}")"
    dict[version_arg]="$(__koopa_get_version_arg "${dict[bn]}")"
    dict[version_fun]="koopa_${dict[bn_snake]}_version"
    if koopa_is_function "${dict[version_fun]}"
    then
        if [[ -x "${dict[cmd]}" ]] && \
            [[ ! -d "${dict[cmd]}" ]] && \
            koopa_is_installed "${dict[cmd]}"
        then
            dict[str]="$("${dict[version_fun]}" "${dict[cmd]}")"
        else
            dict[str]="$("${dict[version_fun]}")"
        fi
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
        return 0
    fi
    [[ -x "${dict[cmd]}" ]] || return 1
    [[ ! -d "${dict[cmd]}" ]] || return 1
    koopa_is_installed "${dict[cmd]}" || return 1
    dict[cmd]="$(koopa_realpath "${dict[cmd]}")"
    dict[str]="$("${dict[cmd]}" "${dict[version_arg]}" 2>&1 || true)"
    [[ -n "${dict[str]}" ]] || return 1
    dict[str]="$(koopa_extract_version "${dict[str]}")"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

koopa_git_checkout_recursive() {
    local app dict dirs pos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
    declare -A dict=(
        [branch]=''
        [origin]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--branch='*)
                dict[branch]="${1#*=}"
                shift 1
                ;;
            '--branch')
                dict[branch]="${2:?}"
                shift 2
                ;;
            '--origin='*)
                dict[origin]="${1#*=}"
                shift 1
                ;;
            '--origin')
                dict[origin]="${2:?}"
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
                dict2[branch]="${dict[branch]}"
                dict2[default_branch]="$(koopa_git_default_branch)"
                if [[ -z "${dict2[branch]}" ]]
                then
                    dict2[branch]="${dict2[default_branch]}"
                fi
                if [[ -n "${dict[origin]}" ]]
                then
                    "${app[git]}" fetch --all
                    if [[ "${dict2[branch]}" != "${dict2[default_branch]}" ]]
                    then
                        "${app[git]}" checkout "${dict2[default_branch]}"
                        "${app[git]}" branch -D "${dict2[branch]}" || true
                    fi
                    "${app[git]}" checkout \
                        -B "${dict2[branch]}" \
                        "${dict[origin]}"
                else
                    "${app[git]}" checkout "${dict2[branch]}"
                fi
                "${app[git]}" branch -vv
            done
        done
    )
    return 0
}

koopa_git_clone() {
    local app clone_args dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
    declare -A dict=(
        [branch]=''
        [commit]=''
        [prefix]=''
        [tag]=''
        [url]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--branch='*)
                dict[branch]="${1#*=}"
                shift 1
                ;;
            '--branch')
                dict[branch]="${2:?}"
                shift 2
                ;;
            '--commit='*)
                dict[commit]="${1#*=}"
                shift 1
                ;;
            '--commit')
                dict[commit]="${2:?}"
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
            '--tag='*)
                dict[tag]="${1#*=}"
                shift 1
                ;;
            '--tag')
                dict[tag]="${2:?}"
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
    koopa_assert_is_set \
        '--prefix' "${dict[prefix]}" \
        '--url' "${dict[url]}"
    if [[ -d "${dict[prefix]}" ]]
    then
        koopa_rm "${dict[prefix]}"
    fi
    if koopa_str_detect_fixed \
        --string="${dict[url]}" \
        --pattern='git@github.com'
    then
        koopa_assert_is_github_ssh_enabled
    elif koopa_str_detect_fixed \
        --string="${dict[url]}" \
        --pattern='git@gitlab.com'
    then
        koopa_assert_is_gitlab_ssh_enabled
    fi
    clone_args=(
        '--quiet'
    )
    if [[ -n "${dict[branch]}" ]]
    then
        clone_args+=(
            '--depth=1'
            '--single-branch'
            "--branch=${dict[branch]}"
        )
    else
        clone_args+=(
            '--filter=blob:none'
        )
    fi
    clone_args+=("${dict[url]}" "${dict[prefix]}")
    "${app[git]}" clone "${clone_args[@]}"
    if [[ -n "${dict[commit]}" ]]
    then
        (
            koopa_cd "${dict[prefix]}"
            "${app[git]}" checkout --quiet "${dict[commit]}"
        )
    elif [[ -n "${dict[tag]}" ]]
    then
        (
            koopa_cd "${dict[prefix]}"
            "${app[git]}" fetch --quiet --tags
            "${app[git]}" checkout --quiet "tags/${dict[tag]}"
        )
    fi
    return 0
}

koopa_git_default_branch() {
    local app dict repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[git]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    declare -A dict=(
        [remote]='origin'
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
                "${app[git]}" remote show "${dict[remote]}" \
                    | koopa_grep --pattern='HEAD branch' \
                    | "${app[sed]}" 's/.*: //' \
            )"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}

koopa_git_last_commit_local() {
    local app dict repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
    declare -A dict=(
        [ref]='HEAD'
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
            x="$("${app[git]}" rev-parse "${dict[ref]}" 2>/dev/null || true)"
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
        [awk]="$(koopa_locate_awk)"
        [git]="$(koopa_locate_git)"
        [head]="$(koopa_locate_head)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[git]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    declare -A dict=(
        [ref]='HEAD'
    )
    for url in "$@"
    do
        local x
        x="$( \
            "${app[git]}" ls-remote --quiet "$url" "${dict[ref]}" \
            | "${app[head]}" -n 1 \
            | "${app[awk]}" '{ print $1 }' \
        )"
        [[ -n "$x" ]] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_git_latest_tag() {
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
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
            rev="$("${app[git]}" rev-list --tags --max-count=1)"
            tag="$("${app[git]}" describe --tags "$rev")"
            [[ -n "$tag" ]] || return 1
            koopa_print "$tag"
        done
    )
    return 0
}

koopa_git_pull_recursive() {
    local app dirs
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
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
                "${app[git]}" fetch --all
                "${app[git]}" pull --all
                "${app[git]}" status
            done
        done
    )
    return 0
}

koopa_git_pull() {
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
    repos=("$@")
    koopa_assert_is_dir "${repos[@]}"
    (
        for repo in "${repos[@]}"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Pulling repo at '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            "${app[git]}" fetch --all --quiet
            "${app[git]}" pull --all --no-rebase --recurse-submodules
        done
    )
    return 0
}

koopa_git_push_recursive() {
    local app dirs
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
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
                "${app[git]}" push
            done
        done
    )
    return 0
}

koopa_git_push_submodules() {
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            koopa_cd "$repo"
            "${app[git]}" submodule update --remote --merge
            "${app[git]}" commit -m 'Update submodules.'
            "${app[git]}" push
        done
    )
    return 0
}

koopa_git_remote_url() {
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
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
            x="$("${app[git]}" config --get 'remote.origin.url' || true)"
            [[ -n "$x" ]] || return 1
            koopa_print "$x"
        done
    )
    return 0
}

koopa_git_rename_master_to_main() {
    local app dict repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
    declare -A dict=(
        [origin]='origin'
        [old_branch]='master'
        [new_branch]='main'
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
            "${app[git]}" switch "${dict[old_branch]}"
            "${app[git]}" branch --move \
                "${dict[old_branch]}" \
                "${dict[new_branch]}"
            "${app[git]}" switch "${dict[new_branch]}"
            "${app[git]}" fetch --all --prune "${dict[origin]}"
            "${app[git]}" branch --unset-upstream
            "${app[git]}" branch \
                --set-upstream-to="${dict[origin]}/${dict[new_branch]}" \
                "${dict[new_branch]}"
            "${app[git]}" push --set-upstream \
                "${dict[origin]}" \
                "${dict[new_branch]}"
            "${app[git]}" push \
                "${dict[origin]}" \
                --delete "${dict[old_branch]}" \
                || true
            "${app[git]}" remote set-head "${dict[origin]}" --auto
        done
    )
    return 0
}

koopa_git_reset_fork_to_upstream() {
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
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
                [branch]="$(koopa_git_default_branch)"
                [origin]='origin'
                [upstream]='upstream'
            )
            "${app[git]}" checkout "${dict[branch]}"
            "${app[git]}" fetch "${dict[upstream]}"
            "${app[git]}" reset --hard "${dict[upstream]}/${dict[branch]}"
            "${app[git]}" push "${dict[origin]}" "${dict[branch]}" --force
        done
    )
    return 0
}

koopa_git_reset() {
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
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
            "${app[git]}" clean -dffx
            if [[ -s '.gitmodules' ]]
            then
                koopa_git_submodule_init
                "${app[git]}" submodule --quiet foreach --recursive \
                    "${app[git]}" clean -dffx
                "${app[git]}" reset --hard --quiet
                "${app[git]}" submodule --quiet foreach --recursive \
                    "${app[git]}" reset --hard --quiet
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
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
    for module in "$@"
    do
        "${app[git]}" submodule deinit -f "$module"
        koopa_rm ".git/modules/${module}"
        "${app[git]}" rm -f "$module"
        "${app[git]}" add '.gitmodules'
        "${app[git]}" commit -m "Removed submodule '${module}'."
    done
    return 0
}

koopa_git_rm_untracked() {
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
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
            "${app[git]}" clean -dfx
        done
    )
    return 0
}

koopa_git_set_remote_url() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    koopa_assert_is_git_repo
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
    declare -A dict=(
        [url]="${1:?}"
        [origin]='origin'
    )
    "${app[git]}" remote set-url "${dict[origin]}" "${dict[url]}"
    return 0
}

koopa_git_status_recursive() {
    local app dirs
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
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
                "${app[git]}" status
            done
        done
    )
    return 0
}

koopa_git_submodule_init() {
    local app repos
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[git]}" ]] || return 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            local dict lines string
            declare -A dict=(
                [module_file]='.gitmodules'
            )
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Initializing submodules in '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            koopa_assert_is_nonzero_file "${dict[module_file]}"
            "${app[git]}" submodule init
            readarray -t lines <<< "$(
                "${app[git]}" config \
                    --file "${dict[module_file]}" \
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
                dict2[target_key]="$( \
                    koopa_print "$string" \
                    | "${app[awk]}" '{ print $1 }' \
                )"
                dict2[target]="$( \
                    koopa_print "$string" \
                    | "${app[awk]}" '{ print $2 }' \
                )"
                dict2[url_key]="${dict2[target_key]//\.path/.url}"
                dict2[url]="$( \
                    "${app[git]}" config \
                        --file "${dict[module_file]}" \
                        --get "${dict2[url_key]}" \
                )"
                koopa_dl "${dict2[target]}" "${dict2[url]}"
                if [[ ! -d "${dict2[target]}" ]]
                then
                    "${app[git]}" submodule add --force \
                        "${dict2[url]}" "${dict2[target]}" > /dev/null
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
        [cut]="$(koopa_locate_cut)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    for repo in "$@"
    do
        local dict
        declare -A dict
        dict[repo]="$repo"
        dict[url]="https://api.github.com/repos/${dict[repo]}/releases/latest"
        dict[str]="$( \
            koopa_parse_url "${dict[url]}" \
                | koopa_grep --pattern='"tag_name":' \
                | "${app[cut]}" -d '"' -f '4' \
                | "${app[sed]}" 's/^v//' \
        )"
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
    done
    return 0
}

koopa_gnu_mirror_url() {
    koopa_assert_has_no_args "$#"
    koopa_variable 'gnu-mirror-url'
    return 0
}

koopa_gpg_download_key_from_keyserver() {
    local app cp dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [gpg]="$(koopa_locate_gpg)"
    )
    [[ -x "${app[gpg]}" ]] || return 1
    declare -A dict=(
        [sudo]=0
        [tmp_dir]="$(koopa_tmp_dir)"
    )
    dict[tmp_file]="${dict[tmp_dir]}/export.gpg"
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict[file]="${1#*=}"
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                shift 2
                ;;
            '--key='*)
                dict[key]="${1#*=}"
                shift 1
                ;;
            '--key')
                dict[key]="${2:?}"
                shift 2
                ;;
            '--keyserver='*)
                dict[keyserver]="${1#*=}"
                shift 1
                ;;
            '--keyserver')
                dict[keyserver]="${2:?}"
                shift 2
                ;;
            '--sudo')
                dict[sudo]=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ -f "${dict[file]}" ]] && return 0
    koopa_alert "Exporting GPG key '${dict[key]}' at '${dict[file]}'."
    cp=('koopa_cp')
    [[ "${dict[sudo]}" -eq 1 ]] && cp+=('--sudo')
    "${app[gpg]}" \
        --homedir "${dict[tmp_dir]}" \
        --quiet \
        --keyserver "${dict[keyserver]}" \
        --recv-keys "${dict[key]}"
    "${app[gpg]}" \
        --homedir "${dict[tmp_dir]}" \
        --list-public-keys "${dict[key]}"
    "${app[gpg]}" \
        --homedir "${dict[tmp_dir]}" \
        --export \
        --quiet \
        --output "${dict[tmp_file]}" \
        "${dict[key]}"
    koopa_assert_is_file "${dict[tmp_file]}"
    "${cp[@]}" "${dict[tmp_file]}" "${dict[file]}"
    koopa_rm "${dict[tmp_dir]}"
    koopa_assert_is_file "${dict[file]}"
    return 0
}

koopa_gpg_prompt() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [gpg]="$(koopa_locate_gpg)"
    )
    [[ -x "${app[gpg]}" ]] || return 1
    printf '' | "${app[gpg]}" -s
    return 0
}

koopa_gpg_reload() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [gpg_connect_agent]="$(koopa_locate_gpg_connect_agent)"
    )
    [[ -x "${app[gpg_connect_agent]}" ]] || return 1
    "${app[gpg_connect_agent]}" reloadagent '/bye'
    return 0
}

koopa_gpg_restart() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [gpgconf]="$(koopa_locate_gpgconf)"
    )
    [[ -x "${app[gpgconf]}" ]] || return 1
    "${app[gpgconf]}" --kill 'gpg-agent'
    return 0
}

koopa_grep() {
    local app dict grep_args grep_cmd
    koopa_assert_has_args "$#"
    declare -A app
    declare -A dict=(
        [boolean]=0
        [engine]="${KOOPA_GREP_ENGINE:-}"
        [file]=''
        [invert_match]=0
        [only_matching]=0
        [mode]='fixed' # or 'regex'.
        [pattern]=''
        [stdin]=1
        [string]=''
        [sudo]=0
    )
    while (("$#"))
    do
        case "$1" in
            '--engine='*)
                dict[engine]="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict[engine]="${2:?}"
                shift 2
                ;;
            '--file='*)
                dict[file]="${1#*=}"
                dict[stdin]=0
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                dict[stdin]=0
                shift 2
                ;;
            '--mode='*)
                dict[mode]="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict[mode]="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict[string]="${1#*=}"
                dict[stdin]=0
                shift 1
                ;;
            '--string')
                dict[string]="${2:-}"
                dict[stdin]=0
                shift 2
                ;;
            '--boolean' | \
            '--quiet')
                dict[boolean]=1
                shift 1
                ;;
            '--regex' | \
            '--extended-regexp')
                dict[mode]='regex'
                shift 1
                ;;
            '--fixed' | \
            '--fixed-strings')
                dict[mode]='fixed'
                shift 1
                ;;
            '--invert-match')
                dict[invert_match]=1
                shift 1
                ;;
            '--only-matching')
                dict[only_matching]=1
                shift 1
                ;;
            '--sudo')
                dict[sudo]=1
                shift 1
                ;;
            '-')
                dict[stdin]=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict[pattern]}"
    if [[ -z "${dict[engine]}" ]]
    then
        app[grep]="$(koopa_locate_rg --allow-missing)"
        [[ ! -x "${app[grep]}" ]] && app[grep]="$(koopa_locate_grep)"
        dict[engine]="$(koopa_basename "${app[grep]}")"
    else
        app[grep]="$(koopa_locate_"${dict[engine]}")"
    fi
    [[ -x "${app[grep]}" ]] || return 1
    if [[ "${dict[stdin]}" -eq 1 ]]
    then
        dict[string]="$(</dev/stdin)"
    fi
    if [[ -n "${dict[file]}" ]] && [[ -n "${dict[string]}" ]]
    then
        koopa_stop "Use '--file' or '--string', but not both."
    fi
    grep_cmd=("${app[grep]}")
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        grep_cmd=('sudo' "${grep_cmd[@]}")
    fi
    grep_args=()
    case "${dict[engine]}" in
        'grep')
            case "${dict[mode]}" in
                'fixed')
                    grep_args+=('-F')
                    ;;
                'regex')
                    grep_args+=('-E')
                    ;;
            esac
            [[ "${dict[invert_match]}" -eq 1 ]] && \
                grep_args+=('-v')  # --invert-match
            [[ "${dict[only_matching]}" -eq 1 ]] && \
                grep_args+=('-o')  # --only-matching
            [[ "${dict[boolean]}" -eq 1 ]] && \
                grep_args+=('-q')  # --quiet
            ;;
        'rg')
            grep_args+=(
                '--case-sensitive'
            )
            if [[ -n "${dict[file]}" ]]
            then
                grep_args+=(
                    '--no-config'
                    '--no-ignore'
                    '--one-file-system'
                )
            fi
            case "${dict[mode]}" in
                'fixed')
                    grep_args+=('--fixed-strings')
                    ;;
                'regex')
                    grep_args+=('--engine' 'default')
                    ;;
            esac
            [[ "${dict[invert_match]}" -eq 1 ]] && \
                grep_args+=('--invert-match')
            [[ "${dict[only_matching]}" -eq 1 ]] && \
                grep_args+=('--only-matching')
            [[ "${dict[boolean]}" -eq 1 ]] && \
                grep_args+=('--quiet')
            ;;
        *)
            koopa_stop 'Invalid grep engine.'
            ;;
    esac
    grep_args+=("${dict[pattern]}")
    if [[ -n "${dict[file]}" ]]
    then
        koopa_assert_is_file "${dict[file]}"
        koopa_assert_is_readable "${dict[file]}"
        grep_args+=("${dict[file]}")
        if [[ "${dict[boolean]}" -eq 1 ]]
        then
            "${grep_cmd[@]}" "${grep_args[@]}" >/dev/null
        else
            "${grep_cmd[@]}" "${grep_args[@]}"
        fi
    else
        if [[ "${dict[boolean]}" -eq 1 ]]
        then
            koopa_print "${dict[string]}" \
                | "${grep_cmd[@]}" "${grep_args[@]}" >/dev/null
        else
            koopa_print "${dict[string]}" \
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

koopa_harfbuzz_version() {
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config \
        --opt-name='harfbuzz' \
        --pc-name='harfbuzz'
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
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app[sudo]}" ]] || return 1
    "${app[sudo]}" -n true 2>/dev/null && return 0
    return 1
}

koopa_hdf5_version() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [h5cc]="$(koopa_locate_h5cc)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[h5cc]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    str="$( \
        "${app[h5cc]}" -showconfig \
            | koopa_grep --pattern='HDF5 Version:' \
            | "${app[sed]}" -E 's/^(.+): //' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_header() {
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        [lang]="$(koopa_lowercase "${1:?}")"
        [prefix]="$(koopa_koopa_prefix)/lang"
    )
    case "${dict[lang]}" in
        'bash' | \
        'posix' | \
        'zsh')
            dict[prefix]="${dict[prefix]}/shell"
            dict[ext]='sh'
            ;;
        'r')
            dict[ext]='R'
            ;;
        *)
            koopa_invalid_arg "${dict[lang]}"
            ;;
    esac
    dict[file]="${dict[prefix]}/${dict[lang]}/include/header.${dict[ext]}"
    koopa_assert_is_file "${dict[file]}"
    koopa_print "${dict[file]}"
    return 0
}

koopa_help_2() {
    local dict
    declare -A dict
    dict[script_file]="$(koopa_realpath "$0")"
    dict[script_name]="$(koopa_basename "${dict[script_file]}")"
    dict[man_prefix]="$( \
        koopa_parent_dir --num=2 "${dict[script_file]}" \
    )"
    dict[man_file]="${dict[man_prefix]}/man/\
man1/${dict[script_name]}.1"
    koopa_help "${dict[man_file]}"
}

koopa_help() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [head]="$(koopa_locate_head)"
        [man]="$(koopa_locate_man)"
    )
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[man]}" ]] || return 1
    declare -A dict=(
        [man_file]="${1:?}"
    )
    [[ -f "${dict[man_file]}" ]] || return 1
    "${app[head]}" -n 10 "${dict[man_file]}" \
        | koopa_str_detect_fixed --pattern='.TH ' \
        || return 1
    "${app[man]}" "${dict[man_file]}"
    exit 0
}

koopa_hisat2_align_paired_end_per_sample() {
    local align_args app dict
    declare -A app=(
        [hisat2]="$(koopa_locate_hisat2)"
    )
    [[ -x "${app[hisat2]}" ]] || return 1
    declare -A dict=(
        [fastq_r1_file]=''
        [fastq_r1_tail]=''
        [fastq_r2_file]=''
        [fastq_r2_tail]=''
        [index_dir]=''
        [lib_type]='A'
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
    )
    align_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict[fastq_r1_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict[fastq_r1_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict[fastq_r2_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict[fastq_r2_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict[fastq_r1_file]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-file' "${dict[fastq_r2_file]}" \
        '--fastq-r2-tail' "${dict[fastq_r2_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "HISAT2 align requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    koopa_assert_is_file "${dict[fastq_r1_file]}" "${dict[fastq_r2_file]}"
    dict[fastq_r1_file]="$(koopa_realpath "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="$(koopa_basename "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[fastq_r1_tail]}/}"
    dict[fastq_r2_file]="$(koopa_realpath "${dict[fastq_r2_file]}")"
    dict[fastq_r2_bn]="$(koopa_basename "${dict[fastq_r2_file]}")"
    dict[fastq_r2_bn]="${dict[fastq_r2_bn]/${dict[fastq_r2_tail]}/}"
    koopa_assert_are_identical "${dict[fastq_r1_bn]}" "${dict[fastq_r2_bn]}"
    dict[id]="${dict[fastq_r1_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' in '${dict[output_dir]}'."
    dict[hisat2_idx]="${dict[index_dir]}/index"
    dict[sam_file]="${dict[output_dir]}/${dict[id]}.sam"
    align_args+=(
        '-1' "${dict[fastq_r1_file]}"
        '-2' "${dict[fastq_r2_file]}"
        '-S' "${dict[sam_file]}"
        '-q'
        '-x' "${dict[hisat2_idx]}"
        '--new-summary'
        '--threads' "${dict[threads]}"
    )
    dict[lib_type]="$(koopa_hisat2_fastq_library_type "${dict[lib_type]}")"
    if [[ -n "${dict[lib_type]}" ]]
    then
        align_args+=('--rna-strandedness' "${dict[lib_type]}")
    fi
    dict[quality_flag]="$( \
        koopa_hisat2_fastq_quality_format "${dict[fastq_r1_file]}" \
    )"
    if [[ -n "${dict[quality_flag]}" ]]
    then
        align_args+=("${dict[quality_flag]}")
    fi
    koopa_dl 'Align args' "${align_args[*]}"
    "${app[star]}" "${align_args[@]}"
    return 0
}

koopa_hisat2_align_paired_end() {
    local dict fastq_r1_files fastq_r1_file fastq_r2_file
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_r1_tail]=''
        [fastq_r2_tail]=''
        [index_dir]=''
        [lib_type]='A'
        [mode]='paired-end'
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-tail' "${dict[fastq_r1_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running HISAT2 aligner.'
    koopa_dl \
        'Mode' "${dict[mode]}" \
        'Index dir' "${dict[index_dir]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ R1 tail' "${dict[fastq_r1_tail]}" \
        'FASTQ R2 tail' "${dict[fastq_r2_tail]}" \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_r1_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_r1_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        fastq_r2_file="${fastq_r1_file/\
${dict[fastq_r1_tail]}/${dict[fastq_r2_tail]}}"
        koopa_hisat2_align_paired_end_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict[fastq_r1_tail]}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict[fastq_r2_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'HISAT2 alignment was successful.'
    return 0
}

koopa_hisat2_align_single_end_per_sample() {
    local align_args app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [hisat2]="$(koopa_locate_hisat2)"
    )
    [[ -x "${app[hisat2]}" ]] || return 1
    declare -A dict=(
        [fastq_file]=''
        [fastq_tail]=''
        [index_dir]=''
        [lib_type]='A'
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
    )
    align_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-file='*)
                dict[fastq_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict[fastq_file]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict[fastq_file]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "HISAT2 align requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    koopa_assert_is_file "${dict[fastq_file]}"
    dict[fastq_file]="$(koopa_realpath "${dict[fastq_file]}")"
    dict[fastq_bn]="$(koopa_basename "${dict[fastq_file]}")"
    dict[fastq_bn]="${dict[fastq_bn]/${dict[tail]}/}"
    dict[id]="${dict[fastq_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' in '${dict[output_dir]}'."
    dict[hisat2_idx]="${dict[index_dir]}/index"
    dict[sam_file]="${dict[output_dir]}/${dict[id]}.sam"
    align_args+=(
        '-S' "${dict[sam_file]}"
        '-U' "${dict[fastq_file]}"
        '-q'
        '-x' "${dict[hisat2_idx]}"
        '--new-summary'
        '--threads' "${dict[threads]}"
    )
    dict[lib_type]="$(koopa_hisat2_fastq_library_type "${dict[lib_type]}")"
    if [[ -n "${dict[lib_type]}" ]]
    then
        align_args+=('--rna-strandedness' "${dict[lib_type]}")
    fi
    dict[quality_flag]="$( \
        koopa_hisat2_fastq_quality_format "${dict[fastq_r1_file]}" \
    )"
    if [[ -n "${dict[quality_flag]}" ]]
    then
        align_args+=("${dict[quality_flag]}")
    fi
    koopa_dl 'Align args' "${align_args[*]}"
    "${app[star]}" "${align_args[@]}"
    return 0
}

koopa_hisat2_align_single_end() {
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_tail]=''
        [index_dir]=''
        [lib_type]='A'
        [mode]='single-end'
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running HISAT2 aligner.'
    koopa_dl \
        'Mode' "${dict[mode]}" \
        'Index dir' "${dict[index_dir]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ tail' "${dict[fastq_tail]}" \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_tail]}'."
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
            --fastq-tail="${dict[fastq_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}"
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
        [fastq_file]="${1:?}"
    )
    koopa_assert_is_file "${dict[fastq_file]}"
    dict[format]="$(koopa_fastq_detect_quality_format "${dict[fastq_file]}")"
    case "${dict[format]}" in
        'Phread+33')
            dict[flag]='--phred33'
            ;;
        'Phread+64')
            dict[flag]='--phred64'
            ;;
        *)
            return 0
            ;;
    esac
    koopa_print "${dict[flag]}"
    return 0
}

koopa_hisat2_index() {
    local app dict index_args
    declare -A app=(
        [hisat2_build]="$(koopa_locate_hisat2_build)"
    )
    [[ -x "${app[hisat2_build]}" ]] || return 1
    declare -A dict=(
        [genome_fasta_file]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=200
        [output_dir]=''
        [seed]=42
        [threads]="$(koopa_cpu_count)"
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict[genome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict[genome_fasta_file]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict[genome_fasta_file]}" \
        '--output-dir' "${dict[output_dir]}"
    dict[ht2_base]="${dict[output_dir]}/index"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "'hisat2-build' requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_file "${dict[genome_fasta_file]}"
    koopa_assert_is_matching_regex \
        --pattern='\.fa\.gz$' \
        --string="${dict[genome_fasta_file]}"
    koopa_assert_is_not_dir "${dict[output_dir]}"
    koopa_alert "Generating HISAT2 index at '${dict[output_dir]}'."
    index_args+=(
        '--seed' "${dict[seed]}"
        '-f'
        '-p' "${dict[threads]}"
        "${dict[genome_fasta_file]}"
        "${dict[ht2_base]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app[hisat2_build]}" "${index_args[@]}"
    koopa_alert_success "HISAT2 index created at '${dict[output_dir]}'."
    return 0
}

koopa_icu4c_version() {
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config \
        --opt-name='icu4c' \
        --pc-name='icu-uc'
}

koopa_imagemagick_version() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [magick_core_config]="$(koopa_locate_magick_core_config)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[magick_core_config]}" ]] || return 1
    str="$( \
        "${app[magick_core_config]}" --version \
            | "${app[cut]}" -d ' ' -f 1 \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
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
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict[sudo]=1
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
    dict[dir]="${1:?}"
    if koopa_str_detect_regex \
        --string="${dict[dir]}" \
        --pattern='^~'
    then
        dict[dir]="$( \
            koopa_sub \
                --pattern='^~' \
                --replacement="${HOME:?}" \
                "${dict[dir]}" \
        )"
    fi
    mkdir=('koopa_mkdir')
    [[ "${dict[sudo]}" -eq 1 ]] && mkdir+=('--sudo')
    if [[ ! -d "${dict[dir]}" ]]
    then
        "${mkdir[@]}" "${dict[dir]}"
    fi
    dict[realdir]="$(koopa_realpath "${dict[dir]}")"
    koopa_print "${dict[realdir]}"
    return 0
}

koopa_insert_at_line_number() {
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    [[ -x "${app[perl]}" ]] || return 1
    declare -A dict=(
        [file]=''
        [line_number]=''
        [string]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict[file]="${1#*=}"
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                shift 2
                ;;
            '--line-number='*)
                dict[line_number]="${1#*=}"
                shift 1
                ;;
            '--line-number')
                dict[line_number]="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict[string]="${1#*=}"
                shift 1
                ;;
            '--string')
                dict[string]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--file' "${dict[file]}" \
        '--line-number' "${dict[line_number]}" \
        '--string' "${dict[string]}"
    koopa_assert_is_file "${dict[file]}"
    dict[perl_cmd]="print '${dict[string]}' if \$. == ${dict[line_number]}"
    "${app[perl]}" -i -l -p -e "${dict[perl_cmd]}" "${dict[file]}"
    return 0
}

koopa_install_ack() {
    koopa_install_app \
        --installer='perl-package' \
        --link-in-bin='ack' \
        --name='ack' \
        "$@"
}

koopa_install_all_apps() {
    local pkgs
    koopa_assert_has_no_args "$#"
    pkgs=(
        'openssl1'
        'openssl3'
        'pcre'
        'pcre2'
        'ack'
        'anaconda'
        'apr'
        'apr-util'
        'armadillo'
        'aspell'
        'autoconf'
        'automake'
        'aws-cli'
        'azure-cli'
        'bash'
        'bash-language-server'
        'bashcov'
        'bat'
        'bc'
        'binutils'
        'bison'
        'black'
        'boost'
        'bpytop'
        'broot'
        'bzip2'
        'cairo'
        'chemacs'
        'chezmoi'
        'cmake'
        'colorls'
        'conda'
        'coreutils'
        'cpufetch'
        'curl'
        'delta'
        'difftastic'
        'dotfiles'
        'du-dust'
        'emacs'
        'ensembl-perl-api'
        'exa'
        'exiftool'
        'fd-find'
        'ffmpeg'
        'ffq'
        'findutils'
        'fish'
        'flac'
        'flake8'
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
        'gettext'
        'gget'
        'git'
        'glances'
        'glib'
        'gmp'
        'gnupg'
        'gnutls'
        'go'
        'google-cloud-sdk'
        'gperf'
        'graphviz'
        'grep'
        'groff'
        'gsl'
        'gtop'
        'gzip'
        'hadolint'
        'harfbuzz'
        'haskell-stack'
        'hdf5'
        'htop'
        'hyperfine'
        'icu4c'
        'imagemagick'
        'ipython'
        'isort'
        'jpeg'
        'jq'
        'julia'
        'kallisto'
        'lame'
        'lapack'
        'latch'
        'less'
        'lesspipe'
        'libedit'
        'libevent'
        'libffi'
        'libgeotiff'
        'libgit2'
        'libidn'
        'libjpeg-turbo'
        'libpipeline'
        'libpng'
        'libssh2'
        'libtasn1'
        'libtiff'
        'libtool'
        'libunistring'
        'libuv'
        'libxml2'
        'libzip'
        'lua'
        'luarocks'
        'lz4'
        'lzo'
        'm4'
        'make'
        'man-db'
        'mcfly'
        'mdcat'
        'meson'
        'mpc'
        'mpfr'
        'ncurses'
        'neofetch'
        'neovim'
        'nettle'
        'nim'
        'ninja'
        'node'
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
        'pyflakes'
        'pygments'
        'pylint'
        'pytaglib'
        'pytest'
        'python'
        'r'
        'ranger-fm'
        'readline'
        'rename'
        'ripgrep'
        'ronn'
        'rsync'
        'ruby'
        'rust'
        'salmon'
        'scons'
        'sed'
        'serf'
        'shellcheck'
        'shunit2'
        'snakemake'
        'sox'
        'sqlite'
        'starship'
        'stow'
        'subversion'
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
        'utf8proc'
        'vim'
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
        'yt-dlp'
        'zellij'
        'zoxide'
        'zsh'
        'zstd'
    )
    if koopa_is_linux
    then
        pkgs+=(
            'apptainer'
            'aspera-connect'
            'docker-credential-pass'
            'lmod'
        )
    fi
    koopa_cli_install --binary "${pkgs[@]}"
    pkgs=(
        'r-packages'
    )
    koopa_cli_install "${pkgs[@]}"
    koopa_configure_dotfiles
    return 0
}

koopa_install_anaconda() {
    koopa_install_app \
        --name='anaconda' \
        "$@"
}

koopa_install_app_from_binary_package() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [tar]="$(koopa_locate_tar)"
    )
    [[ -x "${app[tar]}" ]] || return 1
    declare -A dict=(
        [arch]="$(koopa_arch2)" # e.g. 'amd64'.
        [binary_prefix]='/opt/koopa'
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [os_string]="$(koopa_os_string)"
        [url_stem]="$(koopa_koopa_url)/app"
    )
    if [[ "${dict[koopa_prefix]}" != "${dict[binary_prefix]}" ]]
    then
        koopa_stop "Binary package installation not supported for koopa \
install located at '${dict[koopa_prefix]}'. Koopa must be installed at \
default '${dict[binary_prefix]}' location."
    fi
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local dict2
        declare -A dict2
        dict2[prefix]="$(koopa_realpath "$prefix")"
        dict2[name]="$( \
            koopa_print "${dict2[prefix]}" \
                | koopa_dirname \
                | koopa_basename \
        )"
        dict2[version]="$(koopa_basename "$prefix")"
        dict2[tar_file]="${dict2[name]}-${dict2[version]}.tar.gz"
        dict2[tar_url]="${dict[url_stem]}/${dict[os_string]}/${dict[arch]}/\
${dict2[name]}/${dict2[version]}.tar.gz"
        if ! koopa_is_url_active "${dict2[tar_url]}"
        then
            koopa_stop "No package at '${dict2[tar_url]}'."
        fi
        koopa_download "${dict2[tar_url]}" "${dict2[tar_file]}"
        "${app[tar]}" -Pxzf "${dict2[tar_file]}"
        koopa_touch "${prefix}/.koopa-binary"
    done
    return 0
}

koopa_install_app_internal() {
    koopa_install_app \
        --no-link-in-opt \
        --no-prefix-check \
        --quiet \
        "$@"
}

koopa_install_app() {
    local app bin_arr bool build_opt_arr clean_path_arr dict i opt_arr pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A app=(
        [tee]="$(koopa_locate_tee)"
    )
    [[ -x "${app[tee]}" ]] || return 1
    declare -A bool=(
        [auto_prefix]=0
        [binary]=0
        [link_in_bin]=0
        [link_in_make]=0
        [link_in_opt]=1
        [prefix_check]=1
        [push]=0
        [quiet]=0
        [reinstall]=0
        [update_ldconfig]=0
        [verbose]=0
        [version_is_git_commit]=0
    )
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [installer_bn]=''
        [installer_fun]='main'
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
        [mode]='shared'
        [name]=''
        [platform]='common'
        [prefix]=''
        [tmp_dir]="$(koopa_tmp_dir)"
        [version]=''
        [version_key]=''
    )
    bin_arr=()
    build_opt_arr=()
    clean_path_arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    opt_arr=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--activate-build-opt='*)
                build_opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--activate-build-opt')
                build_opt_arr+=("${2:?}")
                shift 2
                ;;
            '--activate-opt='*)
                opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--activate-opt')
                opt_arr+=("${2:?}")
                shift 2
                ;;
            '--installer='*)
                dict[installer_bn]="${1#*=}"
                shift 1
                ;;
            '--installer')
                dict[installer_bn]="${2:?}"
                shift 2
                ;;
            '--link-in-bin='*)
                bin_arr+=("${1#*=}")
                shift 1
                ;;
            '--link-in-bin')
                bin_arr+=("${2:?}")
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
            '--platform='*)
                dict[platform]="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict[platform]="${2:?}"
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
            '--version='*)
                dict[version]="${1#*=}"
                shift 1
                ;;
            '--version')
                dict[version]="${2:?}"
                shift 2
                ;;
            '--version-key='*)
                dict[version_key]="${1#*=}"
                shift 1
                ;;
            '--version-key')
                dict[version_key]="${2:?}"
                shift 2
                ;;
            '--binary')
                bool[binary]=1
                shift 1
                ;;
            '--push')
                bool[push]=1
                shift 1
                ;;
            '--reinstall')
                bool[reinstall]=1
                shift 1
                ;;
            '--verbose')
                bool[verbose]=1
                shift 1
                ;;
            '--link-in-make')
                bool[link_in_make]=1
                shift 1
                ;;
            '--no-link-in-opt')
                bool[link_in_opt]=0
                shift 1
                ;;
            '--no-prefix-check')
                bool[prefix_check]=0
                shift 1
                ;;
            '--quiet')
                bool[quiet]=1
                shift 1
                ;;
            '--system')
                dict[mode]='system'
                shift 1
                ;;
            '--user')
                dict[mode]='user'
                shift 1
                ;;
            '--version-is-git-commit')
                bool[version_is_git_commit]=1
                shift 1
                ;;
            '-D')
            pos+=("${2:?}")
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
    koopa_assert_is_set '--name' "${dict[name]}"
    [[ "${bool[verbose]}" -eq 1 ]] && set -o xtrace
    [[ -z "${dict[version_key]}" ]] && dict[version_key]="${dict[name]}"
    dict[current_version]="$(\
        koopa_variable "${dict[version_key]}" 2>/dev/null || true \
    )"
    [[ -z "${dict[version]}" ]] && dict[version]="${dict[current_version]}"
    if [[ "${dict[version]}" != "${dict[current_version]}" ]]
    then
        bool[link_in_bin]=0
        bool[link_in_make]=0
        bool[link_in_opt]=0
    fi
    case "${dict[mode]}" in
        'shared')
            if [[ -z "${dict[prefix]}" ]]
            then
                bool[auto_prefix]=1
                dict[version2]="${dict[version]}"
                if [[ "${bool[version_is_git_commit]}" -eq 1 ]]
                then
                    dict[version2]="${dict[version2]:0:8}"
                fi
                dict[prefix]="${dict[app_prefix]}/${dict[name]}/\
${dict[version2]}"
            fi
            ;;
        'system')
            koopa_assert_is_admin
            bool[link_in_make]=0
            bool[link_in_opt]=0
            koopa_is_linux && bool[update_ldconfig]=1
            ;;
        'user')
            bool[link_in_make]=0
            bool[link_in_opt]=0
            ;;
    esac
    koopa_is_array_non_empty "${bin_arr[@]:-}" && bool[link_in_bin]=1
    [[ -d "${dict[prefix]}" ]] && \
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    [[ -z "${dict[installer_bn]}" ]] && dict[installer_bn]="${dict[name]}"
    dict[installer_file]="${dict[installers_prefix]}/${dict[platform]}/\
${dict[mode]}/install-${dict[installer_bn]}.sh"
    koopa_assert_is_file "${dict[installer_file]}"
    source "${dict[installer_file]}"
    koopa_assert_is_function "${dict[installer_fun]}"
    if [[ -n "${dict[prefix]}" ]] && [[ "${bool[prefix_check]}" -eq 1 ]]
    then
        if [[ -d "${dict[prefix]}" ]]
        then
            if [[ "${bool[reinstall]}" -eq 1 ]]
            then
                if [[ "${bool[quiet]}" -eq 0 ]]
                then
                    koopa_alert_uninstall_start \
                        "${dict[name]}" "${dict[prefix]}"
                fi
                case "${dict[mode]}" in
                    'system')
                        koopa_rm --sudo "${dict[prefix]}"
                        ;;
                    *)
                        koopa_rm "${dict[prefix]}"
                        ;;
                esac
            fi
            if [[ -d "${dict[prefix]}" ]]
            then
                if [[ "${bool[quiet]}" -eq 0 ]]
                then
                    koopa_alert_is_installed \
                        "${dict[name]}" "${dict[prefix]}"
                fi
                return 0
            fi
        fi
        case "${dict[mode]}" in
            'system')
                dict[prefix]="$(koopa_init_dir --sudo "${dict[prefix]}")"
                ;;
            *)
                dict[prefix]="$(koopa_init_dir "${dict[prefix]}")"
                ;;
        esac
    fi
    if [[ "${bool[binary]}" -eq 0 ]] && \
        [[ -d "${dict[prefix]}" ]] && \
        [[ "${dict[mode]}" != 'system' ]]
    then
        dict[log_file]="${dict[prefix]}/.koopa-install.log"
    else
        dict[log_file]="$(koopa_tmp_log_file)"
    fi
    if [[ "${bool[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_install_start "${dict[name]}" "${dict[prefix]}"
        else
            koopa_alert_install_start "${dict[name]}"
        fi
    fi
    (
        koopa_cd "${dict[tmp_dir]}"
        if [[ "${bool[binary]}" -eq 1 ]]
        then
            [[ -n "${dict[prefix]}" ]] || return 1
            koopa_install_app_from_binary_package "${dict[prefix]}"
            return 0
        fi
        PATH="$(koopa_paste --sep=':' "${clean_path_arr[@]}")"
        export PATH
        if koopa_is_linux && \
            [[ -x '/usr/bin/pkg-config' ]]
        then
            koopa_add_to_pkg_config_path_2 \
                '/usr/bin/pkg-config'
        fi
        if koopa_is_array_non_empty "${build_opt_arr[@]:-}"
        then
            koopa_activate_build_opt_prefix "${build_opt_arr[@]}"
        fi
        if koopa_is_array_non_empty "${opt_arr[@]:-}"
        then
            koopa_activate_opt_prefix "${opt_arr[@]}"
        fi
        if [[ "${bool[update_ldconfig]}" -eq 1 ]]
        then
            koopa_linux_update_ldconfig
        fi
        export INSTALL_NAME="${dict[name]}"
        export INSTALL_PREFIX="${dict[prefix]}"
        export INSTALL_VERSION="${dict[version]}"
        [[ "${bool[verbose]}" -eq 1 ]] && declare -x
        "${dict[installer_fun]}" "$@"
        [[ "${bool[verbose]}" -eq 1 ]] && declare -x
        return 0
    ) 2>&1 | "${app[tee]}" "${dict[log_file]}"
    koopa_rm "${dict[tmp_dir]}"
    case "${dict[mode]}" in
        'shared')
            if [[ "${bool[auto_prefix]}" -eq 1 ]]
            then
                koopa_sys_set_permissions "$(koopa_dirname "${dict[prefix]}")"
            fi
            koopa_sys_set_permissions --recursive "${dict[prefix]}"
            ;;
        'user')
            koopa_sys_set_permissions --recursive --user "${dict[prefix]}"
            ;;
    esac
    if [[ "${bool[link_in_opt]}" -eq 1 ]]
    then
        koopa_link_in_opt "${dict[prefix]}" "${dict[name]}"
    fi
    if [[ "${bool[link_in_bin]}" -eq 1 ]]
    then
        for i in "${!bin_arr[@]}"
        do
            koopa_link_in_bin \
                "${dict[prefix]}/bin/${bin_arr[i]}" \
                "$(koopa_basename "${bin_arr[i]}")"
        done
    fi
    if [[ "${bool[link_in_make]}" -eq 1 ]]
    then
        koopa_link_in_make --prefix="${dict[prefix]}"
    fi
    if [[ "${bool[update_ldconfig]}" -eq 1 ]]
    then
        koopa_linux_update_ldconfig
    fi
    if [[ "${bool[push]}" -eq 1 ]]
    then
        [[ "${dict[mode]}" == 'shared' ]] || return 1
        koopa_assert_is_set \
            '--name' "${dict[name]}" \
            '--prefix' "${dict[prefix]}"
        koopa_push_app_build "${dict[name]}"
    fi
    if [[ "${bool[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_install_success "${dict[name]}" "${dict[prefix]}"
        else
            koopa_alert_install_success "${dict[name]}"
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
        --link-in-bin='aspell' \
        --name='aspell' \
        "$@"
}

koopa_install_autoconf() {
    koopa_install_app \
        --activate-opt='m4' \
        --installer='gnu-app' \
        --name='autoconf' \
        "$@"
}

koopa_install_automake() {
    koopa_install_app \
        --activate-opt='autoconf' \
        --installer='gnu-app' \
        --name='automake' \
        "$@"
}

koopa_install_azure_cli() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='az' \
        --name='azure-cli' \
        "$@"
}

koopa_install_bash_language_server() {
    koopa_install_app \
        --installer='node-package' \
        --link-in-bin='bash-language-server' \
        --name='bash-language-server' \
        "$@"
}

koopa_install_bash() {
    koopa_install_app \
        --link-in-bin='bash' \
        --name='bash' \
        "$@"
}

koopa_install_bashcov() {
    koopa_install_app \
        --installer='ruby-package' \
        --link-in-bin='bashcov' \
        --name='bashcov' \
        "$@"
}

koopa_install_bat() {
    koopa_install_app \
        --link-in-bin='bat' \
        --name='bat' \
        --installer='rust-package' \
        "$@"
}

koopa_install_bc() {
    koopa_install_app \
        --activate-build-opt='texinfo' \
        --installer='gnu-app' \
        --link-in-bin='bc' \
        --name='bc' \
        "$@"
}

koopa_install_bedtools() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='bedtools' \
        --name='bedtools' \
        "$@"
}

koopa_install_binutils() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='binutils' \
        "$@"
}

koopa_install_bison() {
    koopa_install_app \
        --activate-opt='m4' \
        --installer='gnu-app' \
        --name='bison' \
        -D '--enable-relocatable' \
        "$@"
}

koopa_install_black() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='black' \
        --name='black' \
        "$@"
}

koopa_install_boost() {
    koopa_install_app \
        --name='boost' \
        "$@"
}

koopa_install_bpytop() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bpytop' \
        --name='bpytop' \
        "$@"
}

koopa_install_broot() {
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='broot' \
        --name='broot' \
        "$@"
}

koopa_install_bzip2() {
    koopa_install_app \
        --name='bzip2' \
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

koopa_install_chemacs() {
    koopa_install_app \
        --name='chemacs' \
        --version-is-git-commit \
        "$@"
}

koopa_install_chezmoi() {
    koopa_install_app \
        --link-in-bin='chezmoi' \
        --name='chezmoi' \
        "$@"
}

koopa_install_cmake() {
    koopa_install_app \
        --link-in-bin='cmake' \
        --name='cmake' \
        "$@"
}

koopa_install_colorls() {
    koopa_install_app \
        --installer='ruby-package' \
        --link-in-bin='colorls' \
        --name='colorls' \
        "$@"
}

koopa_install_conda() {
    koopa_install_app \
        --link-in-bin='conda' \
        --name='conda' \
        "$@"
}

koopa_install_coreutils() {
    local install_args
    install_args=(
        '--activate-build-opt=gperf'
        '--activate-opt=gmp'
        '--installer=gnu-app'
        '--name=coreutils'
        '--link-in-bin=['
        '--link-in-bin=b2sum'
        '--link-in-bin=base32'
        '--link-in-bin=base64'
        '--link-in-bin=basename'
        '--link-in-bin=basenc'
        '--link-in-bin=cat'
        '--link-in-bin=chcon'
        '--link-in-bin=chgrp'
        '--link-in-bin=chmod'
        '--link-in-bin=chown'
        '--link-in-bin=chroot'
        '--link-in-bin=cksum'
        '--link-in-bin=comm'
        '--link-in-bin=cp'
        '--link-in-bin=csplit'
        '--link-in-bin=cut'
        '--link-in-bin=date'
        '--link-in-bin=dd'
        '--link-in-bin=df'
        '--link-in-bin=dir'
        '--link-in-bin=dircolors'
        '--link-in-bin=dirname'
        '--link-in-bin=du'
        '--link-in-bin=echo'
        '--link-in-bin=env'
        '--link-in-bin=expand'
        '--link-in-bin=expr'
        '--link-in-bin=factor'
        '--link-in-bin=false'
        '--link-in-bin=fmt'
        '--link-in-bin=fold'
        '--link-in-bin=groups'
        '--link-in-bin=head'
        '--link-in-bin=hostid'
        '--link-in-bin=id'
        '--link-in-bin=install'
        '--link-in-bin=join'
        '--link-in-bin=kill'
        '--link-in-bin=link'
        '--link-in-bin=ln'
        '--link-in-bin=logname'
        '--link-in-bin=ls'
        '--link-in-bin=md5sum'
        '--link-in-bin=mkdir'
        '--link-in-bin=mkfifo'
        '--link-in-bin=mknod'
        '--link-in-bin=mktemp'
        '--link-in-bin=mv'
        '--link-in-bin=nice'
        '--link-in-bin=nl'
        '--link-in-bin=nohup'
        '--link-in-bin=nproc'
        '--link-in-bin=numfmt'
        '--link-in-bin=od'
        '--link-in-bin=paste'
        '--link-in-bin=pathchk'
        '--link-in-bin=pinky'
        '--link-in-bin=pr'
        '--link-in-bin=printenv'
        '--link-in-bin=printf'
        '--link-in-bin=ptx'
        '--link-in-bin=pwd'
        '--link-in-bin=readlink'
        '--link-in-bin=realpath'
        '--link-in-bin=rm'
        '--link-in-bin=rmdir'
        '--link-in-bin=runcon'
        '--link-in-bin=seq'
        '--link-in-bin=sha1sum'
        '--link-in-bin=sha224sum'
        '--link-in-bin=sha256sum'
        '--link-in-bin=sha384sum'
        '--link-in-bin=sha512sum'
        '--link-in-bin=shred'
        '--link-in-bin=shuf'
        '--link-in-bin=sleep'
        '--link-in-bin=sort'
        '--link-in-bin=split'
        '--link-in-bin=stat'
        '--link-in-bin=stty'
        '--link-in-bin=sum'
        '--link-in-bin=sync'
        '--link-in-bin=tac'
        '--link-in-bin=tail'
        '--link-in-bin=tee'
        '--link-in-bin=test'
        '--link-in-bin=timeout'
        '--link-in-bin=touch'
        '--link-in-bin=tr'
        '--link-in-bin=true'
        '--link-in-bin=truncate'
        '--link-in-bin=tsort'
        '--link-in-bin=tty'
        '--link-in-bin=uname'
        '--link-in-bin=unexpand'
        '--link-in-bin=uniq'
        '--link-in-bin=unlink'
        '--link-in-bin=uptime'
        '--link-in-bin=users'
        '--link-in-bin=vdir'
        '--link-in-bin=wc'
        '--link-in-bin=who'
        '--link-in-bin=whoami'
        '--link-in-bin=yes'
        -D '--with-gmp'
        -D '--without-selinux'
    )
    if koopa_is_linux
    then
        install_args+=('--activate-opt=attr')
    fi
    koopa_install_app "${install_args[@]}" "$@"
}

koopa_install_cpufetch() {
    koopa_install_app \
        --link-in-bin='cpufetch' \
        --name='cpufetch' \
        "$@"
}

koopa_install_curl() {
    koopa_install_app \
        --link-in-bin='curl' \
        --link-in-bin='curl-config' \
        --name='curl' \
        "$@"
}

koopa_install_delta() {
    koopa_install_app \
        --link-in-bin='delta' \
        --name='delta' \
        --installer='rust-package' \
        "$@"
}

koopa_install_difftastic() {
    koopa_install_app \
        --link-in-bin='difft' \
        --name='difftastic' \
        --installer='rust-package' \
        "$@"
}

koopa_install_dog() {
    koopa_install_app \
        --link-in-bin='dog' \
        --name='dog' \
        --installer='rust-package' \
        "$@"
}

koopa_install_dotfiles() {
    koopa_install_app \
        --name='dotfiles' \
        --version-is-git-commit \
        "$@"
}

koopa_install_du_dust() {
    koopa_install_app \
        --link-in-bin='dust' \
        --name='du-dust' \
        --installer='rust-package' \
        "$@"
}

koopa_install_emacs() {
    local install_args
    install_args=(
        '--activate-opt=gmp'
        '--activate-opt=ncurses'
        '--activate-opt=libtasn1'
        '--activate-opt=libunistring'
        '--activate-opt=libxml2'
        '--activate-opt=nettle'
        '--activate-opt=texinfo'
        '--activate-opt=gnutls'
        '--installer=gnu-app'
        '--name=emacs'
        '-D' '--with-modules'
        '-D' '--without-dbus'
        '-D' '--without-imagemagick'
        '-D' '--without-ns'
        '-D' '--without-selinux'
        '-D' '--without-x'
    )
    if ! koopa_is_macos
    then
        install_args+=('--link-in-bin=emacs')
    fi
    koopa_install_app "${install_args[@]}" "$@"
}

koopa_install_ensembl_perl_api() {
    koopa_install_app \
        --name='ensembl-perl-api' \
        "$@"
}

koopa_install_entrez_direct() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='efetch' \
        --link-in-bin='esearch' \
        --name='entrez-direct' \
        "$@"
}

koopa_install_exa() {
    koopa_install_app \
        --link-in-bin='exa' \
        --name='exa' \
        --installer='rust-package' \
        "$@"
}

koopa_install_exiftool() {
    koopa_install_app \
        --installer='perl-package' \
        --link-in-bin='exiftool' \
        --name='exiftool' \
        "$@"
}

koopa_install_expat() {
    koopa_install_app \
        --name='expat' \
        "$@"
}

koopa_install_fd_find() {
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='fd' \
        --name='fd-find' \
        "$@"
}

koopa_install_ffmpeg() {
    koopa_install_app \
        --link-in-bin='ffmpeg' \
        --link-in-bin='ffprobe' \
        --name='ffmpeg' \
        "$@"
}

koopa_install_ffq() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='ffq' \
        --name='ffq' \
        "$@"
}

koopa_install_findutils() {
    local install_args
    install_args=(
        '--installer=gnu-app'
        '--link-in-bin=find'
        '--link-in-bin=locate'
        '--link-in-bin=updatedb'
        '--link-in-bin=xargs'
        '--name=findutils'
    )
    if koopa_is_macos
    then
        export CFLAGS='-D__nonnull\(params\)='
    fi
    koopa_install_app "${install_args[@]}" "$@"
}

koopa_install_fish() {
    koopa_install_app \
        --link-in-bin='fish' \
        --name='fish' \
        "$@"
}

koopa_install_flac() {
    koopa_install_app \
        --link-in-bin='flac' \
        --name='flac' \
        "$@"
}

koopa_install_flake8() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='flake8' \
        --name='flake8' \
        "$@"
}

koopa_install_fltk() {
    koopa_install_app \
        --name='fltk' \
        "$@"
}

koopa_install_fontconfig() {
    koopa_install_app \
        --name='fontconfig' \
        "$@"
}

koopa_install_freetype() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='freetype' \
        -D '--enable-freetype-config' \
        -D '--enable-shared=yes' \
        -D '--enable-static=yes' \
        -D '--without-harfbuzz' \
        "$@"
}

koopa_install_fribidi() {
    koopa_install_app \
        --name='fribidi' \
        "$@"
}

koopa_install_fzf() {
    koopa_install_app \
        --link-in-bin='fzf' \
        --name='fzf' \
        "$@"
}

koopa_install_gawk() {
    koopa_install_app \
        --installer='gnu-app' \
        --activate-opt='gettext' \
        --activate-opt='mpfr' \
        --activate-opt='readline' \
        --link-in-bin='awk' \
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
        --link-in-bin='gdal-config' \
        --name='gdal' \
        "$@"
}

koopa_install_gdbm() {
    koopa_install_app \
        --installer='gnu-app' \
        --activate-opt='readline' \
        --name='gdbm' \
        "$@"
}

koopa_install_geos() {
    koopa_install_app \
        --link-in-bin='geos-config' \
        --name='geos' \
        "$@"
}

koopa_install_gettext() {
    local install_args
    install_args=(
        '--installer=gnu-app'
        '--name=gettext'
    )
    if ! koopa_is_macos
    then
        install_args+=(
            '--activate-opt=ncurses'
            '--activate-opt=libxml2'
        )
    fi
    koopa_install_app "${install_args[@]}" "$@"
}

koopa_install_gget() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='gget' \
        --name='gget' \
        "$@"
}

koopa_install_ghostscript() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='gs' \
        --name='ghostscript' \
        "$@"
}

koopa_install_git() {
    local install_args
    install_args=(
        '--link-in-bin=git'
        '--name=git'
    )
    if koopa_is_macos
    then
        install_args+=(
            '--link-in-bin=git-credential-osxkeychain'
        )
    fi
    koopa_install_app "${install_args[@]}" "$@"
}

koopa_install_glances() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='glances' \
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
        --activate-opt='gmp' \
        --activate-opt='libtasn1' \
        --activate-opt='libunistring' \
        --activate-opt='nettle' \
        --installer='gnupg-gcrypt' \
        --name='gnutls' \
        -D '--without-p11-kit' \
        "$@"
}

koopa_install_go() {
    koopa_install_app \
        --link-in-bin='go' \
        --name='go' \
        "$@"
}

koopa_install_google_cloud_sdk() {
    koopa_install_app \
        --link-in-bin='gcloud' \
        --name='google-cloud-sdk' \
        "$@"
}

koopa_install_gperf() {
    koopa_install_app \
        --installer='gnu-app' \
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
        --activate-opt='pcre' \
        --installer='gnu-app' \
        --link-in-bin='egrep' \
        --link-in-bin='fgrep' \
        --link-in-bin='grep' \
        --name='grep' \
        "$@"
}

koopa_install_groff() {
    koopa_install_app \
        --activate-opt='texinfo' \
        --installer='gnu-app' \
        --link-in-bin='groff' \
        --name='groff' \
        "$@"
}

koopa_install_gsl() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='gsl' \
        "$@"
}

koopa_install_gtop() {
    koopa_install_app \
        --installer='node-package' \
        --link-in-bin='gtop' \
        --name='gtop' \
        "$@"
}

koopa_install_gzip() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='gzip' \
        "$@"
}

koopa_install_hadolint() {
    koopa_install_app \
        --link-in-bin='hadolint' \
        --name='hadolint' \
        "$@"
}

koopa_install_harfbuzz() {
    koopa_install_app \
        --name='harfbuzz' \
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

koopa_install_htop() {
    koopa_install_app \
        --link-in-bin='htop' \
        --name='htop' \
        "$@"
}

koopa_install_hyperfine() {
    koopa_install_app \
        --link-in-bin='hyperfine' \
        --name='hyperfine' \
        --installer='rust-package' \
        "$@"
}

koopa_install_icu4c() {
    koopa_install_app \
        --name='icu4c' \
        "$@"
}

koopa_install_imagemagick() {
    koopa_install_app \
        --link-in-bin='magick' \
        --name='imagemagick' \
        "$@"
}

koopa_install_ipython() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='ipython' \
        --name='ipython' \
        "$@"
}

koopa_install_isort() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='isort' \
        --name='isort' \
        "$@"
}

koopa_install_jpeg() {
    koopa_install_app \
        --name='jpeg' \
        "$@"
}

koopa_install_jq() {
    koopa_install_app \
        --link-in-bin='jq' \
        --name='jq' \
        "$@"
}

koopa_install_julia_packages() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [julia]="$(koopa_locate_julia)"
    )
    [[ -x "${app[julia]}" ]] || return 1
    declare -A dict=(
        [script_prefix]="$(koopa_julia_script_prefix)"
    )
    dict[script]="${dict[script_prefix]}/install-packages.jl"
    koopa_assert_is_file "${dict[script]}"
    koopa_configure_julia "${app[julia]}"
    koopa_activate_julia
    "${app[julia]}" "${dict[script]}"
    return 0
}

koopa_install_julia() {
    koopa_install_app \
        --link-in-bin='julia' \
        --name='julia' \
        "$@"
}

koopa_install_kallisto() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='kallisto' \
        --name='kallisto' \
        "$@"
}

koopa_install_koopa() {
    local bool dict
    koopa_assert_is_installed 'cp' 'curl' 'find' 'git' 'grep' 'mkdir' \
        'mktemp' 'mv' 'readlink' 'rm' 'sed' 'tar' 'unzip'
    declare -A bool=(
        [add_to_user_profile]=0
        [interactive]=1
        [passwordless_sudo]=0
        [shared]=0
        [test]=0
    )
    declare -A dict=(
        [config_prefix]="$(koopa_config_prefix)"
        [prefix]=''
        [source_prefix]="$(koopa_koopa_prefix)"
        [user_profile]="$(koopa_find_user_profile)"
        [xdg_data_home]="$(koopa_xdg_data_home)"
    )
    dict[koopa_prefix_system]='/opt/koopa'
    dict[koopa_prefix_user]="${dict[xdg_data_home]}/koopa"
    koopa_is_admin && bool[shared]=1
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--add-to-user-profile')
                bool[add_to_user_profile]=1
                shift 1
                ;;
            '--no-add-to-user-profile')
                bool[add_to_user_profile]=0
                shift 1
                ;;
            '--interactive')
                bool[interactive]=1
                shift 1
                ;;
            '--non-interactive')
                bool[interactive]=0
                shift 1
                ;;
            '--passwordless-sudo')
                bool[passwordless_sudo]=1
                shift 1
                ;;
            '--no-passwordless-sudo')
                bool[passwordless_sudo]=0
                shift 1
                ;;
            '--shared')
                bool[shared]=1
                shift 1
                ;;
            '--no-shared')
                bool[shared]=0
                shift 1
                ;;
            '--test' | \
            '--verbose')
                bool[test]=1
                shift 1
                ;;
            '--no-test' | \
            '--no-verbose')
                bool[test]=0
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${bool[interactive]}" -eq 1 ]]
    then
        if koopa_is_admin && [[ -z "${dict[prefix]}" ]]
        then
            bool[shared]="$( \
                koopa_read_yn \
                    'Install for all users' \
                    "${bool[shared]}" \
            )"
        fi
        if [[ -z "${dict[prefix]}" ]]
        then
            if [[ "${bool[shared]}" -eq 1 ]]
            then
                dict[prefix]="${dict[koopa_prefix_system]}"
            else
                dict[prefix]="${dict[koopa_prefix_user]}"
            fi
        fi
        dict[koopa_prefix]="$( \
            koopa_read \
                'Install prefix' \
                "${dict[prefix]}" \
        )"
        if koopa_str_detect_regex \
            --string="${dict[prefix]}" \
            --pattern="^${HOME:?}"
        then
            bool[shared]=0
        else
            bool[shared]=1
        fi
        if [[ "${bool[shared]}" -eq 1 ]]
        then
            bool[passwordless_sudo]="$( \
                koopa_read_yn \
                    'Enable passwordless sudo' \
                    "${bool[passwordless_sudo]}" \
            )"
        fi
        if ! koopa_is_defined_in_user_profile && \
            [[ ! -L "${dict[user_profile]}" ]]
        then
            koopa_alert_note 'Koopa activation missing in user profile.'
            bool[add_to_user_profile]="$( \
                koopa_read_yn \
                    "Modify '${dict[user_profile]}'" \
                    "${bool[add_to_user_profile]}" \
            )"
        fi
    else
        if [[ -z "${dict[prefix]}" ]]
        then
            if [[ "${bool[shared]}" -eq 1 ]]
            then
                dict[prefix]="${dict[koopa_prefix_system]}"
            else
                dict[prefix]="${dict[koopa_prefix_user]}"
            fi
        fi
    fi
    koopa_assert_is_not_dir "${dict[prefix]}"
    koopa_rm "${dict[config_prefix]}"
    if [[ "${bool[shared]}" -eq 1 ]]
    then
        koopa_alert_info 'Shared installation detected.'
        koopa_alert_note 'Admin (sudo) permissions are required.'
        koopa_assert_is_admin
        koopa_rm --sudo "${dict[prefix]}"
        koopa_cp --sudo "${dict[source_prefix]}" "${dict[prefix]}"
        koopa_sys_set_permissions --recursive "${dict[prefix]}"
        koopa_add_make_prefix_link "${dict[prefix]}"
    else
        koopa_cp "${dict[source_prefix]}" "${dict[prefix]}"
    fi
    export KOOPA_PREFIX="${dict[prefix]}"
    if [[ "${bool[shared]}" -eq 1 ]]
    then
        if [[ "${bool[passwordless_sudo]}" -eq 1 ]]
        then
            koopa_enable_passwordless_sudo
        fi
        koopa_is_linux && koopa_linux_update_etc_profile_d
    fi
    if [[ "${bool[add_to_user_profile]}" -eq 1 ]]
    then
        koopa_add_to_user_profile
    fi
    koopa_fix_zsh_permissions
    koopa_add_config_link "${dict[prefix]}/activate" 'activate'
    return 0
}

koopa_install_lame() {
    koopa_install_app \
        --link-in-bin='lame' \
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
        --installer='python-venv' \
        --link-in-bin='latch' \
        --name='latch' \
        "$@"
}

koopa_install_less() {
    koopa_install_app \
        --activate-opt='ncurses' \
        --activate-opt='pcre2' \
        --installer='gnu-app' \
        --link-in-bin='less' \
        --name='less' \
        "$@"
}

koopa_install_lesspipe() {
    koopa_install_app \
        --link-in-bin='lesspipe.sh' \
        --name='lesspipe' \
        "$@"
}

koopa_install_libedit() {
    koopa_install_app \
        --name='libedit' \
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

koopa_install_libidn() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='libidn' \
        "$@"
}

koopa_install_libjpeg_turbo() {
    koopa_install_app \
        --name='libjpeg-turbo' \
        "$@"
}

koopa_install_libpipeline() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='libpipeline' \
        "$@"
}

koopa_install_libpng() {
    koopa_install_app \
        --link-in-bin='libpng-config' \
        --link-in-bin='libpng16-config' \
        --name='libpng' \
        "$@"
}

koopa_install_libssh2() {
    koopa_install_app \
        --name='libssh2' \
        "$@"
}

koopa_install_libtasn1() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='libtasn1' \
        "$@"
}

koopa_install_libtiff() {
    koopa_install_app \
        --name='libtiff' \
        "$@"
}

koopa_install_libtool() {
    koopa_install_app \
        --activate-opt='m4' \
        --installer='gnu-app' \
        --link-in-bin='libtool' \
        --link-in-bin='libtoolize' \
        --name='libtool' \
        "$@"
    (
        koopa_cd "$(koopa_bin_prefix)"
        koopa_ln 'libtool' 'glibtool'
        koopa_ln 'libtoolize' 'glibtoolize'
    )
}

koopa_install_libunistring() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='libunistring' \
        "$@"
}

koopa_install_libuv() {
    koopa_install_app \
        --name='libuv' \
        "$@"
}

koopa_install_libxml2() {
    koopa_install_app \
        --link-in-bin='xml2-config' \
        --name='libxml2' \
        "$@"
}

koopa_install_libzip() {
    koopa_install_app \
        --name='libzip' \
        "$@"
}

koopa_install_lua() {
    koopa_install_app \
        --name='lua' \
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
        --installer='gnu-app' \
        --name='m4' \
        "$@"
}

koopa_install_make() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='make' \
        --name='make' \
        "$@"
}

koopa_install_mamba() {
    koopa_install_app \
        --link-in-bin='mamba' \
        --name='mamba' \
        --no-prefix-check \
        "$@"
}

koopa_install_man_db() {
    koopa_install_app \
        --link-in-bin='man' \
        --name='man-db' \
        "$@"
}

koopa_install_mcfly() {
    koopa_install_app \
        --link-in-bin='mcfly' \
        --name='mcfly' \
        --installer='rust-package' \
        "$@"
}

koopa_install_mdcat() {
    koopa_install_app \
        --link-in-bin='mdcat' \
        --name='mdcat' \
        --installer='rust-package' \
        "$@"
}

koopa_install_meson() {
    koopa_install_app \
        --installer='python-venv' \
        --name='meson' \
        "$@"
}

koopa_install_mpc() {
    local dict
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    dict[gmp]="$(koopa_realpath "${dict[opt_prefix]}/gmp")"
    dict[mpfr]="$(koopa_realpath "${dict[opt_prefix]}/mpfr")"
    koopa_install_app \
        --activate-opt='gmp' \
        --activate-opt='mpfr' \
        --installer='gnu-app' \
        --name='mpc' \
        -D "--with-gmp=${dict[gmp]}" \
        -D "--with-mpfr=${dict[mpfr]}" \
        "$@"
}

koopa_install_mpfr() {
    koopa_install_app \
        --activate-opt='gmp' \
        --installer='gnu-app' \
        --name='mpfr' \
        "$@"
}

koopa_install_ncurses() {
    koopa_install_app \
        --link-in-bin='captoinfo' \
        --link-in-bin='clear' \
        --link-in-bin='infocmp' \
        --link-in-bin='infotocap' \
        --link-in-bin='reset' \
        --link-in-bin='tabs' \
        --link-in-bin='tic' \
        --link-in-bin='toe' \
        --link-in-bin='tput' \
        --link-in-bin='tset' \
        --name='ncurses' \
        "$@"
}

koopa_install_neofetch() {
    koopa_install_app \
        --link-in-bin='neofetch' \
        --name='neofetch' \
        "$@"
}

koopa_install_neovim() {
    koopa_install_app \
        --link-in-bin='nvim' \
        --name='neovim' \
        "$@"
}

koopa_install_nettle() {
    koopa_install_app \
        --activate-opt='gmp' \
        --activate-opt='m4' \
        --installer='gnu-app' \
        --name='nettle' \
        -D '--disable-dependency-tracking' \
        -D '--enable-mini-gmp' \
        -D '--enable-shared' \
        "$@"
}

koopa_install_nim() {
    koopa_install_app \
        --link-in-bin='nim' \
        --name='nim' \
        "$@"
}

koopa_install_ninja() {
    koopa_install_app \
        --installer='python-venv' \
        --name='ninja' \
        "$@"
}

koopa_install_node_binary() {
    koopa_install_app \
        --installer='node-binary' \
        --link-in-bin='node' \
        --link-in-bin='npm' \
        --name='node' \
        "$@"
}

koopa_install_node() {
    koopa_install_app \
        --link-in-bin='node' \
        --link-in-bin='npm' \
        --name='node' \
        "$@"
}

koopa_install_oniguruma() {
    koopa_install_app \
        --name='oniguruma' \
        "$@"
}

koopa_install_openblas() {
    koopa_install_app \
        --name='openblas' \
        "$@"
}

koopa_install_openjdk() {
    koopa_install_app \
        --link-in-bin='jar' \
        --link-in-bin='java' \
        --link-in-bin='javac' \
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
        --link-in-bin='pandoc' \
        --name='pandoc' \
        "$@"
}

koopa_install_parallel() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='parallel' \
        --name='parallel' \
        "$@"
}

koopa_install_password_store() {
    koopa_install_app \
        --link-in-bin='pass' \
        --name='password-store' \
        "$@"
}

koopa_install_patch() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='patch' \
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
        --link-in-bin='perl' \
        --name='perl' \
        "$@"
}

koopa_install_pipx() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='pipx' \
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
        --link-in-bin='pkg-config' \
        --name='pkg-config' \
        "$@"
}

koopa_install_poetry() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='poetry' \
        --name='poetry' \
        "$@"
}

koopa_install_prettier() {
    koopa_install_app \
        --installer='node-package' \
        --link-in-bin='prettier' \
        --name='prettier' \
        "$@"
}

koopa_install_procs() {
    koopa_install_app \
        --link-in-bin='procs' \
        --name='procs' \
        --installer='rust-package' \
        "$@"
}

koopa_install_proj() {
    koopa_install_app \
        --name='proj' \
        "$@"
}

koopa_install_pyenv() {
    koopa_install_app \
        --link-in-bin='pyenv' \
        --name='pyenv' \
        "$@"
}

koopa_install_pyflakes() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='pyflakes' \
        --name='pyflakes' \
        "$@"
}

koopa_install_pygments() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='pygmentize' \
        --name='pygments' \
        "$@"
}

koopa_install_pylint() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='pylint' \
        --name='pylint' \
        "$@"
}

koopa_install_pytaglib() {
    koopa_install_app \
        --link-in-bin='pyprinttags' \
        --activate-opt='taglib' \
        --installer='python-venv' \
        --name='pytaglib' \
        "$@"
}

koopa_install_pytest() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='pytest' \
        --name='pytest' \
        "$@"
}

koopa_install_python() {
    koopa_install_app \
        --link-in-bin='python3' \
        --name='python' \
        "$@"
}

koopa_install_r_devel() {
    koopa_install_app \
        --installer='r' \
        --name='r-devel' \
        "$@"
}

koopa_install_r_koopa() {
    koopa_assert_has_no_args "$#"
    koopa_r_koopa 'header'
    return 0
}

koopa_install_r_packages() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [r]="$(koopa_locate_r)"
        [rscript]="$(koopa_locate_rscript)"
    )
    [[ -x "${app[r]}" ]] || return 1
    [[ -x "${app[rscript]}" ]] || return 1
    koopa_configure_r "${app[r]}"
    declare -A dict=(
        [bioc_version]="$(koopa_variable 'bioconductor')"
    )
    "${app[rscript]}" -e " \
        isInstalled <- function(pkgs) { ; \
            basename(pkgs) %in% rownames(utils::installed.packages()); \
        } ; \
        if (isFALSE(isInstalled('AcidDevTools'))) { ; \
            install.packages(pkgs = 'BiocManager'); \
            BiocManager::install(version = '${dict[bioc_version]}'); \
            install.packages(pkgs = 'AcidDevTools'); \
        } ; \
        AcidDevTools::installRecommendedPackages(); \
    "
    return 0
}

koopa_install_r() {
    local install_args
    install_args=('--name=r')
    if koopa_is_linux && [[ ! -x '/usr/bin/R' ]]
    then
        install_args+=(
            '--link-in-bin=R'
            '--link-in-bin=Rscript'
        )
    fi
    koopa_install_app "${install_args[@]}" "$@"
}

koopa_install_ranger_fm() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='ranger' \
        --name='ranger-fm' \
        "$@"
}

koopa_install_rbenv() {
    koopa_install_app \
        --link-in-bin='rbenv' \
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
        --installer='perl-package' \
        --link-in-bin='rename' \
        --name='rename' \
        "$@"
}

koopa_install_ripgrep() {
    koopa_install_app \
        --activate-opt='pcre2' \
        --installer='rust-package' \
        --link-in-bin='rg' \
        --name='ripgrep' \
        "$@"
}

koopa_install_rmate() {
    koopa_install_app \
        --link-in-bin='rmate' \
        --name='rmate' \
        "$@"
}

koopa_install_ronn() {
    koopa_install_app \
        --installer='ruby-package' \
        --link-in-bin='ronn' \
        --name='ronn' \
        "$@"
}

koopa_install_rsync() {
    koopa_install_app \
        --link-in-bin='rsync' \
        --name='rsync' \
        "$@"
}

koopa_install_ruby() {
    koopa_install_app \
        --link-in-bin='bundle' \
        --link-in-bin='bundler' \
        --link-in-bin='gem' \
        --link-in-bin='ruby' \
        --name='ruby' \
        "$@"
}

koopa_install_rust() {
    koopa_install_app \
        --name='rust' \
        "$@"
}

koopa_install_salmon() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='salmon' \
        --name='salmon' \
        "$@"
}

koopa_install_samtools() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='samtools' \
        --name='samtools' \
        "$@"
}

koopa_install_scons() {
    koopa_install_app \
        --installer='python-venv' \
        --name='scons' \
        "$@"
}

koopa_install_sed() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='sed' \
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
        --link-in-bin='shellcheck' \
        --name='shellcheck' \
        "$@"
}

koopa_install_shunit2() {
    koopa_install_app \
        --link-in-bin='shunit2' \
        --name='shunit2' \
        "$@"
}

koopa_install_snakemake() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='snakemake' \
        --name='snakemake' \
        "$@"
}

koopa_install_sox() {
    koopa_install_app \
        --link-in-bin='sox' \
        --name='sox' \
        "$@"
}

koopa_install_sqlite() {
    koopa_install_app \
        --link-in-bin='sqlite3' \
        --name='sqlite' \
        "$@"
}

koopa_install_sra_tools() {
    koopa_install_app \
        --link-in-bin='fasterq-dump' \
        --link-in-bin='vdb-config' \
        --name='sra-tools' \
        "$@"
}

koopa_install_star() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='STAR' \
        --name='star' \
        "$@"
}

koopa_install_starship() {
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='starship' \
        --name='starship' \
        "$@"
}

koopa_install_stow() {
    koopa_install_app \
        --activate-opt='perl' \
        --installer='gnu-app' \
        --link-in-bin='stow' \
        --name='stow' \
        "$@"
}

koopa_install_subversion() {
    koopa_install_app \
        --link-in-bin='svn' \
        --name='subversion' \
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

koopa_install_taglib() {
    koopa_install_app \
        --name='taglib' \
        "$@"
}

koopa_install_tar() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='tar' \
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
        --installer='rust-package' \
        --link-in-bin='tldr' \
        --name='tealdeer' \
        "$@"
}

koopa_install_texinfo() {
    local install_args
    install_args=(
        '--installer=gnu-app'
        '--link-in-bin=pdftexi2dvi'
        '--link-in-bin=pod2texi'
        '--link-in-bin=texi2any'
        '--link-in-bin=texi2dvi'
        '--link-in-bin=texi2pdf'
        '--link-in-bin=texindex'
        '--name=texinfo'
        -D '--disable-dependency-tracking'
        -D '--disable-install-warnings'
    )
    if ! koopa_is_macos
    then
        install_args+=(
            '--activate-opt=gettext'
            '--activate-opt=ncurses'
            '--activate-opt=perl'
        )
    fi
    koopa_install_app "${install_args[@]}" "$@"
}

koopa_install_tmux() {
    koopa_install_app \
        --link-in-bin='tmux' \
        --name='tmux' \
        "$@"
}

koopa_install_tokei() {
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='tokei' \
        --name='tokei' \
        "$@"
}

koopa_install_tree() {
    koopa_install_app \
        --link-in-bin='tree' \
        --name='tree' \
        "$@"
}

koopa_install_tuc() {
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='tuc' \
        --name='tuc' \
        "$@"
}

koopa_install_udunits() {
    koopa_install_app \
        --link-in-bin='udunits2' \
        --name='udunits' \
        "$@"
}

koopa_install_units() {
    koopa_install_app \
        --activate-opt='readline' \
        --installer='gnu-app' \
        --link-in-bin='units' \
        --name='units' \
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
        --link-in-bin='vim' \
        --link-in-bin='vimdiff' \
        --name='vim' \
        "$@"
}

koopa_install_wget() {
    local dict
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    dict[ssl]="$(koopa_realpath "${dict[opt_prefix]}/openssl3")"
    koopa_install_app \
        --activate-build-opt='autoconf' \
        --activate-build-opt='automake' \
        --activate-opt='gettext' \
        --activate-opt='libidn' \
        --activate-opt='libtasn1' \
        --activate-opt='nettle' \
        --activate-opt='openssl3' \
        --activate-opt='pcre2' \
        --activate-opt='gnutls' \
        --installer='gnu-app' \
        --name='wget' \
        --link-in-bin='wget' \
        --name='wget' \
        -D '--disable-debug' \
        -D '--with-ssl=openssl' \
        -D "--with-libssl-prefix=${dict[ssl]}" \
        -D '--without-included-regex' \
        -D '--without-libpsl' \
        "$@"
}

koopa_install_which() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='which' \
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
        --installer='rust-package' \
        --link-in-bin='xsv' \
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
        --link-in-bin='xz' \
        --name='xz' \
        "$@"
}

koopa_install_yt_dlp() {
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='yt-dlp' \
        --name='yt-dlp' \
        "$@"
}

koopa_install_zellij() {
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='zellij' \
        --name='zellij' \
        "$@"
}

koopa_install_zlib() {
    koopa_install_app \
        --name='zlib' \
        "$@"
}

koopa_install_zoxide() {
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='zoxide' \
        --name='zoxide' \
        "$@"
}

koopa_install_zsh() {
    koopa_install_app \
        --link-in-bin='zsh' \
        --name='zsh' \
        "$@"
    koopa_fix_zsh_permissions
    return 0
}

koopa_install_zstd() {
    koopa_install_app \
        --name='zstd' \
        "$@"
}

koopa_installers_prefix() {
    koopa_print "$(koopa_koopa_prefix)/lang/shell/bash/include/installers"
    return 0
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
        [type]='public'
    )
    while (("$#"))
    do
        case "$1" in
            '--local')
                dict[type]='local'
                shift 1
                ;;
            '--public')
                dict[type]='public'
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    case "${dict[type]}" in
        'local')
            koopa_local_ip_address
            ;;
        'public')
            koopa_public_ip_address
            ;;
    esac
    return 0
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
    declare -A app=(
        [groups]="$(koopa_locate_groups)"
    )
    [[ -x "${app[groups]}" ]] || return 1
    declare -A dict=(
        [groups]="$("${app[groups]}")"
        [pattern]='\b(admin|root|sudo|wheel)\b'
    )
    [[ -n "${dict[groups]}" ]] || return 1
    koopa_str_detect_regex \
        --string="${dict[groups]}" \
        --pattern="${dict[pattern]}" \
        && return 0
    return 1
}

koopa_is_anaconda() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [conda]="${1:-}"
    )
    [[ -z "${app[conda]}" ]] && app[conda]="$(koopa_locate_conda)"
    [[ -x "${app[conda]}" ]] || return 1
    declare -A dict=(
        [prefix]="$(koopa_parent_dir --num=2 "${app[conda]}")"
    )
    [[ -x "${dict[prefix]}/bin/anaconda" ]] || return 1
    return 0
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

koopa_is_defined_in_user_profile() {
    local file
    koopa_assert_has_no_args "$#"
    file="$(koopa_find_user_profile)"
    koopa_file_detect_fixed --file="$file" --pattern='koopa'
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

koopa_is_file_system_case_sensitive() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [find]="$(koopa_locate_find)"
        [wc]="$(koopa_locate_wc)"
    )
    [[ -x "${app[find]}" ]] || return 1
    [[ -x "${app[wc]}" ]] || return 1
    declare -A dict=(
        [prefix]="${PWD:?}"
        [tmp_stem]='.koopa.tmp.'
    )
    dict[file1]="${dict[tmp_stem]}checkcase"
    dict[file2]="${dict[tmp_stem]}checkCase"
    koopa_touch "${dict[file1]}" "${dict[file2]}"
    dict[count]="$( \
        "${app[find]}" \
            "${dict[prefix]}" \
            -maxdepth 1 \
            -mindepth 1 \
            -name "${dict[file1]}" \
        | "${app[wc]}" -l \
    )"
    koopa_rm "${dict[tmp_stem]}"*
    [[ "${dict[count]}" -eq 2 ]]
}

koopa_is_file_type() {
    local dict file pos
    declare -A dict=(
        [ext]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--ext='*)
                dict[ext]="${1#*=}"
                shift 1
                ;;
            '--ext')
                dict[ext]="${2:?}"
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
    koopa_assert_is_set '--ext' "${dict[ext]}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        [[ -f "$file" ]] || return 1
        koopa_str_detect_regex \
            --string="$file" \
            --pattern="\.${dict[ext]}$" \
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

koopa_is_powerful_machine() {
    local cores
    koopa_assert_has_no_args "$#"
    cores="$(koopa_cpu_count)"
    [[ "$cores" -ge 7 ]] && return 0
    return 1
}

koopa_is_r_package_installed() {
    local app dict pkg
    koopa_assert_has_args "$#"
    declare -A app=(
        [r]="$(koopa_locate_r)"
    )
    [[ -x "${app[r]}" ]] || return 1
    declare -A dict
    dict[prefix]="$(koopa_r_packages_prefix "${app[r]}")"
    for pkg in "$@"
    do
        [[ -d "${dict[prefix]}/${pkg}" ]] || return 1
    done
    return 0
}

koopa_is_recent() {
    local app dict file
    koopa_assert_has_args "$#"
    declare -A app=(
        [find]="$(koopa_locate_find)"
    )
    [[ -x "${app[find]}" ]] || return 1
    declare -A dict=(
        [days]=14
    )
    for file in "$@"
    do
        local exists
        [[ -e "$file" ]] || return 1
        exists="$( \
            "${app[find]}" "$file" \
                -mindepth 0 \
                -maxdepth 0 \
                -mtime "-${dict[days]}" \
            2>/dev/null \
        )"
        [[ -n "$exists" ]] || return 1
    done
    return 0
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

koopa_is_url_active() {
    local app url
    koopa_assert_has_args "$#"
    declare -A app=(
        [curl]="$(koopa_locate_curl)"
    )
    [[ -x "${app[curl]}" ]] || return 1
    declare -A dict=(
        [url_pattern]='://'
    )
    for url in "$@"
    do
        koopa_str_detect_fixed \
            --pattern="${dict[url_pattern]}" \
            --string="$url" \
            || return 1
        "${app[curl]}" \
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
        [nounset]="$(koopa_boolean_nounset)"
    )
    [[ "${dict[nounset]}" -eq 1 ]] && set +o nounset
    for var
    do
        local x value
        x="$(declare -p "$var" 2>/dev/null || true)"
        [[ -n "${x:-}" ]] || return 1
        value="${!var}"
        [[ -n "${value:-}" ]] || return 1
    done
    [[ "${dict[nounset]}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_is_xcode_clt_installed() {
    koopa_assert_has_no_args "$#"
    koopa_is_macos || return 1
    [[ -d '/Library/Developer/CommandLineTools/usr/bin' ]] || return 1
    return 0
}

koopa_java_prefix() {
    local prefix
    if [[ -n "${JAVA_HOME:-}" ]]
    then
        koopa_print "$JAVA_HOME"
        return 0
    fi
    if [[ -d "$(koopa_openjdk_prefix)" ]]
    then
        koopa_print "$(koopa_openjdk_prefix)"
        return 0
    fi
    if [[ -x '/usr/libexec/java_home' ]]
    then
        prefix="$('/usr/libexec/java_home' || true)"
        [ -n "$prefix" ] || return 1
        koopa_print "$prefix"
        return 0
    fi
    if [[ -d "$(koopa_homebrew_opt_prefix)/openjdk" ]]
    then
        koopa_print "$(koopa_homebrew_opt_prefix)/openjdk"
        return 0
    fi
    return 1
}

koopa_jekyll_deploy_to_aws() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
        [bundle]="$(koopa_locate_bundle)"
    )
    [[ -x "${app[aws]}" ]] || return 1
    [[ -x "${app[bundle]}" ]] || return 1
    declare -A dict=(
        [bucket_prefix]=''
        [distribution_id]=''
        [local_prefix]='_site'
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    while (("$#"))
    do
        case "$1" in
            '--bucket='*)
                dict[bucket_prefix]="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict[bucket_prefix]="${2:?}"
                shift 2
                ;;
            '--distribution-id='*)
                dict[distribution_id]="${1#*=}"
                shift 1
                ;;
            '--distribution-id')
                dict[distribution_id]="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bucket' "${dict[bucket_prefix]:-}" \
        '--distribution-id' "${dict[distribution_id]:-}" \
        '--profile' "${dict[profile]:-}"
    dict[bucket_prefix]="$( \
        koopa_strip_trailing_slash "${dict[bucket_prefix]}" \
    )"
    dict[local_prefix]="$( \
        koopa_strip_trailing_slash "${dict[local_prefix]}" \
    )"
    koopa_assert_is_file 'Gemfile'
    [[ -f 'Gemfile.lock' ]] && koopa_rm 'Gemfile.lock'
    "${app[bundle]}" install
    "${app[bundle]}" exec jekyll build
    koopa_aws_s3_sync --profile="${dict[profile]}" \
        "${dict[local_prefix]}/" \
        "${dict[bucket_prefix]}/"
    koopa_alert "Invalidating CloudFront cache at '${dict[distribution_id]}'."
    "${app[aws]}" --profile="${dict[profile]}" \
        cloudfront create-invalidation \
            --distribution-id="${dict[distribution_id]}" \
            --paths='/*' \
            >/dev/null
    [[ -f 'Gemfile.lock' ]] && koopa_rm 'Gemfile.lock'
    return 0
}

koopa_jekyll_serve() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [bundle]="$(koopa_locate_bundle)"
    )
    [[ -x "${app[bundle]}" ]] || return 1
    declare -A dict=(
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="${PWD:?}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    koopa_alert "Serving Jekyll website in '${dict[prefix]}'."
    (
        koopa_cd "${dict[prefix]}"
        koopa_assert_is_file 'Gemfile'
        if [[ -f 'Gemfile.lock' ]]
        then
            "${app[bundle]}" update --bundler
        fi
        "${app[bundle]}" install
        "${app[bundle]}" exec jekyll serve
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
        [kallisto]="$(koopa_locate_kallisto)"
    )
    [[ -x "${app[kallisto]}" ]] || return 1
    declare -A dict=(
        [kmer_size]=31
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [transcriptome_fasta_file]=''
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict[transcriptome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict[transcriptome_fasta_file]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--output-dir' "${dict[output_dir]}" \
        '--transcriptome-fasta-file' "${dict[transcriptome_fasta_file]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "kallisto index requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_file "${dict[transcriptome_fasta_file]}"
    dict[transcriptome_fasta_file]="$( \
        koopa_realpath "${dict[transcriptome_fasta_file]}" \
    )"
    koopa_assert_is_matching_regex \
        --pattern='\.fa(sta)?' \
        --string="${dict[transcriptome_fasta_file]}"
    koopa_assert_is_not_dir "${dict[output_dir]}"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    dict[index_file]="${dict[output_dir]}/kallisto.idx"
    koopa_alert "Generating kallisto index at '${dict[output_dir]}'."
    index_args+=(
        "--index=${dict[index_file]}"
        "--kmer-size=${dict[kmer_size]}"
        '--make-unique'
        "${dict[transcriptome_fasta_file]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app[kallisto]}" index "${index_args[@]}"
    koopa_alert_success "kallisto index created at '${dict[output_dir]}'."
    return 0
}

koopa_kallisto_quant_paired_end_per_sample() {
    local app dict quant_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [kallisto]="$(koopa_locate_kallisto)"
    )
    [[ -x "${app[kallisto]}" ]] || return 1
    declare -A dict=(
        [bootstraps]=30
        [fastq_r1_file]=''
        [fastq_r1_tail]=''
        [fastq_r2_file]=''
        [fastq_r2_tail]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [threads]="$(koopa_cpu_count)"
    )
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict[fastq_r1_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict[fastq_r1_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict[fastq_r2_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict[fastq_r2_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict[fastq_r1_file]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-file' "${dict[fastq_r2_file]}" \
        '--fastq-r2-tail' "${dict[fastq_r2_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "kallisto quant requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[index_file]="${dict[index_dir]}/kallisto.idx"
    koopa_assert_is_file \
        "${dict[fastq_r1_file]}" \
        "${dict[fastq_r2_file]}" \
        "${dict[index_file]}"
    dict[fastq_r1_file]="$(koopa_realpath "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="$(koopa_basename "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[fastq_r1_tail]}/}"
    dict[fastq_r2_file]="$(koopa_realpath "${dict[fastq_r2_file]}")"
    dict[fastq_r2_bn]="$(koopa_basename "${dict[fastq_r2_file]}")"
    dict[fastq_r2_bn]="${dict[fastq_r2_bn]/${dict[fastq_r2_tail]}/}"
    koopa_assert_are_identical "${dict[fastq_r1_bn]}" "${dict[fastq_r2_bn]}"
    dict[id]="${dict[fastq_r1_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' into '${dict[output_dir]}'."
    quant_args+=(
        "--bootstrap-samples=${dict[bootstraps]}"
        "--index=${dict[index_file]}"
        "--output-dir=${dict[output_dir]}"
        "--threads=${dict[threads]}"
        '--bias'
        '--verbose'
    )
    dict[lib_type]="$(koopa_kallisto_fastq_library_type "${dict[lib_type]}")"
    if [[ -n "${dict[lib_type]}" ]]
    then
        quant_args+=("${dict[lib_type]}")
    fi
    quant_args+=("${dict[fastq_r1_file]}" "${dict[fastq_r2_file]}")
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app[kallisto]}" quant "${quant_args[@]}"
    return 0
}

koopa_kallisto_quant_paired_end() {
    local dict fastq_r1_files fastq_r1_file fastq_r2_file
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_r1_tail]=''
        [fastq_r2_tail]=''
        [index_dir]=''
        [lib_type]='A'
        [mode]='paired-end'
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-tail' "${dict[fastq_r1_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running kallisto quant.'
    koopa_dl \
        'Mode' "${dict[mode]}" \
        'Index dir' "${dict[index_dir]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ R1 tail' "${dict[fastq_r1_tail]}" \
        'FASTQ R2 tail' "${dict[fastq_r2_tail]}" \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_r1_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type 'f' \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_r1_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        fastq_r2_file="${fastq_r1_file/\
${dict[fastq_r1_tail]}/${dict[fastq_r2_tail]}}"
        koopa_kallisto_quant_paired_end_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict[fastq_r1_tail]}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict[fastq_r2_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'kallisto quant was successful.'
    return 0
}

koopa_kallisto_quant_single_end_per_sample() {
    local app dict quant_args
    declare -A app=(
        [kallisto]="$(koopa_locate_kallisto)"
    )
    [[ -x "${app[kallisto]}" ]] || return 1
    declare -A dict=(
        [bootstraps]=30
        [fastq_file]=''
        [fastq_tail]=''
        [fragment_length]=200
        [index_dir]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [sd]=25
    )
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-file='*)
                dict[fastq_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict[fastq_file]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
                shift 2
                ;;
            '--fragment-length='*)
                dict[fragment_length]="${1#*=}"
                shift 1
                ;;
            '--fragment-length')
                dict[fragment_length]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict[fastq_file]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--fragment-length' "${dict[fragment_length]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "kallisto quant requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[index_file]="${dict[index_dir]}/kallisto.idx"
    koopa_assert_is_file "${dict[fastq_file]}" "${dict[index_file]}"
    dict[fastq_file]="$(koopa_realpath "${dict[fastq_file]}")"
    dict[fastq_bn]="$(koopa_basename "${dict[fastq_file]}")"
    dict[fastq_bn]="${dict[fastq_bn]/${dict[fastq_tail]}/}"
    dict[id]="${dict[fastq_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' into '${dict[output_dir]}'."
    quant_args+=(
        "--bootstrap-samples=${dict[bootstraps]}"
        "--fragment-length=${dict[fragment_length]}"
        "--index=${dict[index_file]}"
        "--output-dir=${dict[output_dir]}"
        "--sd=${dict[sd]}"
        '--single'
        "--threads=${dict[threads]}"
        '--verbose'
    )
    quant_args+=("$fastq_file")
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app[kallisto]}" quant "${quant_args[@]}"
    return 0
}

koopa_kallisto_quant_single_end() {
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_tail]=''
        [index_dir]=''
        [mode]='single-end'
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq-tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running kallisto quant.'
    koopa_dl \
        'Mode' "${dict[mode]}" \
        'Index dir' "${dict[index_dir]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ tail' "${dict[fastq_tail]}" \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_tail]}'."
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
            --fastq-tail="${dict[fastq_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --output-dir="${dict[output_dir]}"
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

koopa_koopa_date() {
    koopa_assert_has_no_args "$#"
    koopa_variable 'koopa-date'
    return 0
}

koopa_koopa_github_url() {
    koopa_assert_has_no_args "$#"
    koopa_variable 'koopa-github-url'
    return 0
}

koopa_koopa_installers_url() {
    koopa_assert_has_no_args "$#"
    koopa_print "$(koopa_koopa_url)/installers"
}

koopa_local_ip_address() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [head]="$(koopa_locate_head)"
        [tail]="$(koopa_locate_tail)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[tail]}" ]] || return 1
    if koopa_is_macos
    then
        app[ifconfig]="$(koopa_macos_locate_ifconfig)"
        [[ -x "${app[ifconfig]}" ]] || return 1
        str="$( \
            "${app[ifconfig]}" \
            | koopa_grep --pattern='inet ' \
            | koopa_grep --pattern='broadcast' \
            | "${app[awk]}" '{print $2}' \
            | "${app[tail]}" -n 1 \
        )"
    else
        app[hostname]="$(koopa_locate_hostname)"
        [[ -x "${app[hostname]}" ]] || return 1
        str="$( \
            "${app[hostname]}" -I \
            | "${app[awk]}" '{print $1}' \
            | "${app[head]}" -n 1 \
        )"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_koopa_url() {
    koopa_assert_has_no_args "$#"
    koopa_variable 'koopa-url'
    return 0
}

koopa_koopa_version() {
    koopa_assert_has_no_args "$#"
    koopa_variable 'koopa-version'
    return 0
}

koopa_lesspipe_version() {
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
        [lesspipe]="${1:-}"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -z "${app[lesspipe]}" ]] && app[lesspipe]="$(koopa_locate_lesspipe)"
    [[ -x "${app[cat]}" ]] || return 1
    [[ -x "${app[lesspipe]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    str="$( \
        "${app[cat]}" "${app[lesspipe]}" \
            | "${app[sed]}" -n '2p' \
            | koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_line_count() {
    local app file str
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [wc]="$(koopa_locate_wc)"
        [xargs]="$(koopa_locate_xargs)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[wc]}" ]] || return 1
    [[ -x "${app[xargs]}" ]] || return 1
    for file in "$@"
    do
        str="$( \
            "${app[wc]}" --lines "$file" \
                | "${app[xargs]}" \
                | "${app[cut]}" -d ' ' -f '1' \
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
        [dotfiles_config_link]="$(koopa_dotfiles_config_link)"
        [dotfiles_prefix]="$(koopa_dotfiles_prefix)"
        [dotfiles_private_prefix]="$(koopa_dotfiles_private_prefix)"
        [into_xdg_config_home]=0
        [overwrite]=0
        [private]=0
        [xdg_config_home]="$(koopa_xdg_config_home)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--into-xdg-config-home')
                dict[into_xdg_config_home]=1
                shift 1
                ;;
            '--overwrite')
                dict[overwrite]=1
                shift 1
                ;;
            '--private')
                dict[private]=1
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
    dict[source_subdir]="${1:?}"
    dict[symlink_basename]="${2:-}"
    if [[ -z "${dict[symlink_basename]}" ]]
    then
        dict[symlink_basename]="$(koopa_basename "${dict[source_subdir]}")"
    fi
    if [[ "${dict[private]}" -eq 1 ]]
    then
        dict[source_prefix]="${dict[dotfiles_private_prefix]}"
    else
        dict[source_prefix]="${dict[dotfiles_config_link]}"
        if [[ ! -L "${dict[source_prefix]}" ]]
        then
            koopa_ln "${dict[dotfiles_prefix]}" "${dict[source_prefix]}"
        fi
    fi
    dict[source_path]="${dict[source_prefix]}/${dict[source_subdir]}"
    koopa_assert_is_existing "${dict[source_path]}"
    if [[ "${dict[into_xdg_config_home]}" -eq 1 ]]
    then
        dict[symlink_prefix]="${dict[xdg_config_home]}"
    else
        dict[symlink_prefix]="${HOME:?}"
        dict[symlink_basename]=".${dict[symlink_basename]}"
    fi
    dict[symlink_path]="${dict[symlink_prefix]}/${dict[symlink_basename]}"
    if [[ "${dict[overwrite]}" -eq 1 ]] ||
        { [[ -L "${dict[symlink_path]}" ]] && \
            [[ ! -e "${dict[symlink_path]}" ]]; }
    then
        koopa_rm "${dict[symlink_path]}"
    fi
    if [[ -e "${dict[symlink_path]}" ]] && \
        [[ ! -L "${dict[symlink_path]}" ]]
    then
        koopa_alert_note "Exists and not symlink: '${dict[symlink_path]}'."
        return 0
    fi
    koopa_alert "Linking dotfile from '${dict[source_path]}' \
to '${dict[symlink_path]}'."
    dict[symlink_dirname]="$(koopa_dirname "${dict[symlink_path]}")"
    if [[ "${dict[symlink_dirname]}" != "${HOME:?}" ]]
    then
        koopa_mkdir "${dict[symlink_dirname]}"
    fi
    koopa_ln "${dict[source_path]}" "${dict[symlink_path]}"
    return 0
}

koopa_link_in_bin() {
    __koopa_link_in_dir --prefix="$(koopa_bin_prefix)" "$@"
}

koopa_link_in_make() {
    local cp_args dict exclude_arr files_arr find_args i include_arr
    koopa_assert_has_args "$#"
    declare -A dict=(
        [app_prefix]=''
        [make_prefix]="$(koopa_make_prefix)"
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
                dict[app_prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[app_prefix]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--prefix' "${dict[app_prefix]}"
    koopa_assert_is_dir "${dict[app_prefix]}" "${dict[make_prefix]}"
    dict[app_prefix]="$(koopa_realpath "${dict[app_prefix]}")"
    if koopa_is_array_non_empty "${include_arr[@]:-}"
    then
        for i in "${!include_arr[@]}"
        do
            files_arr[i]="${dict[app_prefix]}/${include_arr[i]}"
        done
    else
        find_args=(
            '--max-depth=1'
            '--min-depth=1'
            "--prefix=${dict[app_prefix]}"
            '--sort'
            '--type=d'
        )
        if koopa_is_array_non_empty "${exclude_arr[@]:-}"
        then
            for i in "${!exclude_arr[@]}"
            do
                find_args+=("--exclude=${exclude_arr[i]}")
            done
        fi
        readarray -t files_arr <<< "$(koopa_find "${find_args[@]}")"
    fi
    if koopa_is_array_empty "${files_arr[@]:-}"
    then
        koopa_stop "No files from '${dict[app_prefix]}' to link \
into '${dict[make_prefix]}'."
    fi
    koopa_assert_is_existing "${files_arr[@]}"
    koopa_alert "Linking '${dict[app_prefix]}' in '${dict[make_prefix]}'."
    koopa_sys_set_permissions --recursive "${dict[app_prefix]}"
    koopa_delete_broken_symlinks "${dict[app_prefix]}"
    cp_args=('--symbolic-link')
    koopa_is_shared_install && cp_args+=('--sudo')
    cp_args+=(
        "--target-directory=${dict[make_prefix]}"
        "${files_arr[@]}"
    )
    koopa_cp "${cp_args[@]}"
    return 0
}

koopa_link_in_opt() {
    __koopa_link_in_dir --prefix="$(koopa_opt_prefix)" "$@"
}

koopa_link_in_sbin() {
    __koopa_link_in_dir --prefix="$(koopa_sbin_prefix)" "$@"
}

koopa_list_app_versions() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="$(koopa_app_prefix)"
    )
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa_alert_note "No apps are installed in '${dict[prefix]}'."
        return 0
    fi
    dict[str]="$( \
        koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict[prefix]}" \
            --sort \
            --type='d' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
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
        [awk]="$(koopa_locate_awk)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    declare -A dict
    readarray -t all_arr <<< "$( \
        __koopa_list_path_priority "$@" \
    )"
    koopa_is_array_non_empty "${all_arr[@]:-}" || return 1
    readarray -t unique_arr <<< "$( \
        koopa_print "${all_arr[@]}" \
            | "${app[awk]}" '!a[$0]++' \
    )"
    koopa_is_array_non_empty "${unique_arr[@]:-}" || return 1
    dict[n_all]="${#all_arr[@]}"
    dict[n_unique]="${#unique_arr[@]}"
    dict[n_dupes]="$((dict[n_all] - dict[n_unique]))"
    if [[ "${dict[n_dupes]}" -gt 0 ]]
    then
        koopa_alert_note "$(koopa_ngettext \
            --num="${dict[n_dupes]}" \
            --msg1='duplicate' \
            --msg2='duplicates' \
            --suffix=' detected.' \
        )"
    fi
    koopa_print "${all_arr[@]}"
    return 0
}

koopa_list_programs() {
    koopa_assert_has_no_args "$#"
    koopa_r_koopa --vanilla 'cliListPrograms'
    return 0
}

koopa_lmod_prefix() {
    koopa_print "$(koopa_opt_prefix)/lmod"
}

koopa_lmod_version() {
    local str
    koopa_assert_has_no_args "$#"
    str="${LMOD_VERSION:-}"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_ln() {
    local app dict ln ln_args mkdir pos rm
    declare -A app=(
        [ln]="$(koopa_locate_ln)"
        [mkdir]='koopa_mkdir'
        [rm]='koopa_rm'
    )
    [[ -x "${app[ln]}" ]] || return 1
    declare -A dict=(
        [sudo]=0
        [target_dir]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--target-directory='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            '--sudo' | \
            '-S')
                dict[sudo]=1
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
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        [[ -x "${app[sudo]}" ]] || return 1
        ln=("${app[sudo]}" "${app[ln]}")
        mkdir=("${app[mkdir]}" '--sudo')
        rm=("${app[rm]}" '--sudo')
    else
        ln=("${app[ln]}")
        mkdir=("${app[mkdir]}")
        rm=("${app[rm]}")
    fi
    ln_args=('-fns')
    ln_args+=("$@")
    if [[ -n "${dict[target_dir]}" ]]
    then
        koopa_assert_is_existing "$@"
        dict[target_dir]="$(koopa_strip_trailing_slash "${dict[target_dir]}")"
        if [[ ! -d "${dict[target_dir]}" ]]
        then
            "${mkdir[@]}" "${dict[target_dir]}"
        fi
        ln_args+=("${dict[target_dir]}")
    else
        koopa_assert_has_args_eq "$#" 2
        dict[source_file]="${1:?}"
        koopa_assert_is_existing "${dict[source_file]}"
        dict[target_file]="${2:?}"
        if [[ -e "${dict[target_file]}" ]]
        then
            "${rm[@]}" "${dict[target_file]}"
        fi
        dict[target_parent]="$(koopa_dirname "${dict[target_file]}")"
        if [[ ! -d "${dict[target_parent]}" ]]
        then
            "${mkdir[@]}" "${dict[target_parent]}"
        fi
    fi
    "${ln[@]}" "${ln_args[@]}"
    return 0
}

koopa_locate_7z() {
    koopa_locate_app \
        --app-name='7z' \
        --opt-name='p7zip'
}

koopa_locate_anaconda() {
    koopa_locate_app \
        --app-name='conda' \
        --opt-name='anaconda'
}

koopa_locate_app() {
    local dict pos
    declare -A dict=(
        [allow_in_path]=0
        [allow_missing]=0
        [app_name]=''
        [bin_prefix]="$(koopa_bin_prefix)"
        [opt_name]=''
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--app-name='*)
                dict[app_name]="${1#*=}"
                shift 1
                ;;
            '--app-name')
                dict[app_name]="${2:?}"
                shift 2
                ;;
            '--opt-name='*)
                dict[opt_name]="${1#*=}"
                shift 1
                ;;
            '--opt-name')
                dict[opt_name]="${2:?}"
                shift 2
                ;;
            '--allow-in-path')
                dict[allow_in_path]=1
                shift 1
                ;;
            '--allow-missing')
                dict[allow_missing]=1
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
        koopa_assert_has_args_eq "$#" 1
        if [[ -n "${dict[app_name]}" ]] || \
            [[ "${dict[allow_in_path]}" -eq 1 ]]
        then
            koopa_stop "Need to rework locator for '${1:?}'."
        fi
        dict[app]="${1:?}"
        if [[ -x "${dict[app]}" ]] && koopa_is_installed "${dict[app]}"
        then
            koopa_print "${dict[app]}"
            return 0
        fi
        koopa_stop "Failed to locate '${dict[app]}'."
    fi
    dict[app]="${dict[bin_prefix]}/${dict[app_name]}"
    if [[ -x "${dict[app]}" ]]
    then
        koopa_print "${dict[app]}"
        return 0
    fi
    if [[ -n "${dict[opt_name]}" ]]
    then
        dict[app]="${dict[opt_prefix]}/${dict[opt_name]}/bin/${dict[app_name]}"
        if [[ -x "${dict[app]}" ]]
        then
            koopa_print "${dict[app]}"
            return 0
        elif [[ ! -x "${dict[app]}" ]] && \
            [[ "${dict[allow_in_path]}" -eq 0 ]] && \
            [[ "${dict[allow_missing]}" -eq 0 ]]
        then
            koopa_stop "Need to install '${dict[opt_name]}' for '${dict[app]}'."
        fi
    fi
    if [[ "${dict[allow_in_path]}" -eq 1 ]]
    then
        dict[app]="$(koopa_which "${dict[app_name]}" || true)"
    fi
    if { \
        [[ -n "${dict[app]}" ]] && \
        [[ -x "${dict[app]}" ]] && \
        [[ ! -d "${dict[app]}" ]] && \
        koopa_is_installed "${dict[app]}"; \
    }
    then
        koopa_print "${dict[app]}"
        return 0
    fi
    [[ "${dict[allow_missing]}" -eq 1 ]] && return 0
    koopa_stop "Failed to locate '${dict[app_name]}'."
}

koopa_locate_ascp() {
    koopa_locate_app \
        --app-name='ascp' \
        --opt-name='aspera-connect'
}

koopa_locate_aspell() {
    koopa_locate_app \
        --app-name='aspell' \
        --opt-name='aspell'
}

koopa_locate_autoreconf() {
    koopa_locate_app \
        --app-name='autoreconf' \
        --opt-name='autoconf'
}

koopa_locate_awk() {
    koopa_locate_app \
        --app-name='awk' \
        --opt-name='gawk'
}

koopa_locate_aws() {
    koopa_locate_app \
        --app-name='aws' \
        --opt-name='aws-cli'
}

koopa_locate_basename() {
    koopa_locate_app \
        --app-name='basename' \
        --opt-name='coreutils'
}

koopa_locate_bash() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='bash' \
        --opt-name='bash'
}

koopa_locate_bc() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='bc' \
        --opt-name='bc'
}

koopa_locate_bedtools() {
    koopa_locate_app \
        --app-name='bedtools' \
        --opt-name='bedtools'
}

koopa_locate_bpytop() {
    koopa_locate_app \
        --app-name='bpytop' \
        --opt-name='python-packages'
}

koopa_locate_brew() {
    koopa_locate_app \
        "$(koopa_homebrew_prefix)/Homebrew/bin/brew" \
        "$@"
}

koopa_locate_bundle() {
    koopa_locate_app \
        --app-name='bundle' \
        --opt-name='ruby-packages'
}

koopa_locate_bzip2() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='bzip2' \
        --opt-name='bzip2'
}

koopa_locate_cargo() {
    koopa_locate_app \
        --app-name='cargo' \
        --opt-name='rust'
}

koopa_locate_cat() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='cat' \
        --opt-name='coreutils'
}

koopa_locate_chezmoi() {
    koopa_locate_app \
        --app-name='chezmoi' \
        --opt-name='chezmoi'
}

koopa_locate_chgrp() {
    koopa_locate_app '/usr/bin/chgrp'
}

koopa_locate_chmod() {
    koopa_locate_app '/bin/chmod'
}

koopa_locate_chown() {
    local os_id str
    os_id="$(koopa_os_id)"
    case "$os_id" in
        'macos')
            str='/usr/sbin/chown'
            ;;
        *)
            str='/bin/chown'
            ;;
    esac
    koopa_locate_app "$str"
}

koopa_locate_cmake() {
    koopa_locate_app \
        --app-name='cmake' \
        --opt-name='cmake'
}

koopa_locate_conda_app() {
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [app_name]=''
        [conda_prefix]="$(koopa_conda_prefix)"
        [env_name]=''
        [env_version]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--app-name='*)
                dict[app_name]="${1#*=}"
                shift 1
                ;;
            '--app-name')
                dict[app_name]="${2:?}"
                shift 2
                ;;
            '--conda-prefix='*)
                dict[conda_prefix]="${1#*=}"
                shift 1
                ;;
            '--conda-prefix')
                dict[conda_prefix]="${2:?}"
                shift 2
                ;;
            '--env-name='*)
                dict[env_name]="${1#*=}"
                shift 1
                ;;
            '--env-name')
                dict[env_name]="${2:?}"
                shift 2
                ;;
            '--env-version='*)
                dict[env_version]="${1#*=}"
                shift 1
                ;;
            '--env-version')
                dict[env_version]="${2:?}"
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
    koopa_assert_has_args_le "$#" 1
    if [[ -z "${dict[app_name]}" ]]
    then
        koopa_assert_has_args_eq "$#" 1
        dict[app_name]="${1:?}"
    fi
    if [[ -z "${dict[env_name]}" ]]
    then
        dict[env_name]="${dict[app_name]}"
    fi
    if [[ -z "${dict[env_version]}" ]]
    then
        dict[env_version]="$(koopa_variable "conda-${dict[env_name]}")"
    fi
    koopa_assert_is_set \
        '--app-name' "${dict[app_name]}" \
        '--conda-prefix' "${dict[conda_prefix]}" \
        '--env-name' "${dict[env_name]}" \
        '--env-version' "${dict[env_version]}"
    dict[app_path]="${dict[conda_prefix]}/envs/\
${dict[env_name]}@${dict[env_version]}/bin/${dict[app_name]}"
    koopa_assert_is_executable "${dict[app_path]}"
    koopa_print "${dict[app_path]}"
    return 0
}

koopa_locate_conda() {
    koopa_locate_app \
        --app-name='conda' \
        --opt-name='conda' \
        "$@"
}

koopa_locate_convmv() {
    koopa_locate_app 'convmv'
}

koopa_locate_cp() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='cp' \
        --opt-name='coreutils'
}

koopa_locate_cpan() {
    koopa_locate_app \
        --app-name='cpan' \
        --opt-name='perl'
}

koopa_locate_curl() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='curl' \
        --opt-name='curl'
}

koopa_locate_cut() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='cut' \
        --opt-name='coreutils'
}

koopa_locate_date() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='date' \
        --opt-name='coreutils'
}

koopa_locate_df() {
    koopa_locate_app \
        --app-name='df' \
        --opt-name='coreutils'
}

koopa_locate_dig() {
    koopa_locate_app \
        --app-name='dig' \
        --opt-name='bind' \
        "$@"
}

koopa_locate_dirname() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='dirname' \
        --opt-name='coreutils'
}

koopa_locate_docker() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='docker'
}

koopa_locate_doom() {
    koopa_locate_app "$(koopa_doom_emacs_prefix)/bin/doom"
}

koopa_locate_du() {
    koopa_locate_app \
        --app-name='du' \
        --opt-name='coreutils'
}

koopa_locate_echo() {
    koopa_locate_app \
        --app-name='echo' \
        --opt-name='coreutils'
}

koopa_locate_efetch() {
    koopa_locate_app \
        --app-name='efetch' \
        --opt-name='entrez-direct'
}

koopa_locate_emacs() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='emacs'
}

koopa_locate_esearch() {
    koopa_locate_app \
        --app-name='esearch' \
        --opt-name='entrez-direct'
}

koopa_locate_exiftool() {
    koopa_locate_app \
        --app-name='exiftool' \
        --opt-name='exiftool'
}

koopa_locate_fasterq_dump() {
    koopa_locate_app \
        --app-name='fasterq-dump' \
        --opt-name='sra-tools'
}

koopa_locate_fd() {
    koopa_locate_app \
        --app-name='fd' \
        --opt-name='fd-find' \
        "$@"
}

koopa_locate_ffmpeg() {
    koopa_locate_app \
        --app-name='ffmpeg' \
        --opt-name='ffmpeg'
}

koopa_locate_find() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='find' \
        --opt-name='findutils'
}

koopa_locate_fish() {
    koopa_locate_app \
        --app-name='fish' \
        --opt-name='fish'
}

koopa_locate_gcc() {
    local dict
    declare -A dict=(
        [name]='gcc'
    )
    dict[version]="$(koopa_variable "${dict[name]}")"
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    koopa_locate_app \
        --allow-in-path \
        --app-name="${dict[name]}-${dict[maj_ver]}" \
        --opt-name="${dict[name]}@${dict[maj_ver]}"
}

koopa_locate_gcloud() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='gcloud'
}

koopa_locate_gdal_config() {
    koopa_locate_app \
        --app-name='gdal-config' \
        --opt-name='gdal'
}

koopa_locate_gem() {
    koopa_locate_app \
        --app-name='gem' \
        --opt-name='ruby'
}

koopa_locate_geos_config() {
    koopa_locate_app \
        --app-name='geos-config' \
        --opt-name='geos'
}

koopa_locate_git() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='git' \
        --opt-name='git'
}

koopa_locate_go() {
    koopa_locate_app \
        --app-name='go' \
        --opt-name='go'
}

koopa_locate_gpg_agent() {
    koopa_locate_app \
        --app-name='gpg-agent' \
        --opt-name='gnupg'
}

koopa_locate_gpg_connect_agent() {
    koopa_locate_app \
        --app-name='gpg-connect-agent' \
        --opt-name='gnupg'
}

koopa_locate_gpg() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='gpg' \
        --opt-name='gnupg'
}

koopa_locate_gpgconf() {
    koopa_locate_app \
        --app-name='gpgconf' \
        --opt-name='gnupg'
}

koopa_locate_grep() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='grep' \
        --opt-name='grep' \
        "$@"
}

koopa_locate_groups() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='groups' \
        --opt-name='coreutils'
}

koopa_locate_gs() {
    koopa_locate_app \
        --app-name='gs' \
        --opt-name='ghostscript'
}

koopa_locate_gsl_config() {
    koopa_locate_app \
        --app-name='gsl-config' \
        --opt-name='gsl'
}

koopa_locate_gzip() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='gzip' \
        --opt-name='gzip'
}

koopa_locate_h5cc() {
    koopa_locate_app \
        --app-name='h5cc' \
        --opt-name='hdf5'
}

koopa_locate_head() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='head' \
        --opt-name='coreutils'
}

koopa_locate_hostname() {
    koopa_locate_app '/bin/hostname'
}

koopa_locate_icu_config() {
    koopa_locate_app \
        --app-name='icu-config' \
        --opt-name='icu4c'
}

koopa_locate_id() {
    koopa_locate_app \
        --app-name='id' \
        --opt-name='coreutils'
}

koopa_locate_java() {
    koopa_locate_app "$(koopa_java_prefix)/bin/java"
}

koopa_locate_jq() {
    koopa_locate_app \
        --app-name='jq' \
        --opt-name='jq'
}

koopa_locate_julia() {
    koopa_locate_app \
        --app-name='julia' \
        --opt-name='julia'
}

koopa_locate_kallisto() {
    koopa_locate_app \
        --app-name='kallisto' \
        --opt-name='kallisto'
}

koopa_locate_ldd() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='ldd'
}

koopa_locate_less() {
    koopa_locate_app \
        --app-name='less' \
        --opt-name='less'
}

koopa_locate_lesspipe() {
    koopa_locate_app \
        --app-name='lesspipe.sh' \
        --opt-name='lesspipe'
}

koopa_locate_libtoolize() {
    koopa_locate_app \
        --app-name='libtoolize' \
        --opt-name='libtool'
}

koopa_locate_ln() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='ln' \
        --opt-name='coreutils'
}

koopa_locate_locale() {
    koopa_locate_app '/usr/bin/locale'
}

koopa_locate_localedef() {
    if koopa_is_alpine
    then
        koopa_alpine_locate_localedef
    else
        koopa_locate_app '/usr/bin/localedef'
    fi
}

koopa_locate_ls() {
    koopa_locate_app \
        --app-name='ls' \
        --opt-name='coreutils'
}

koopa_locate_lua() {
    koopa_locate_app \
        --app-name='lua' \
        --opt-name='lua'
}

koopa_locate_luarocks() {
    koopa_locate_app \
        --app-name='luarocks' \
        --opt-name='luarocks'
}

koopa_locate_magick_core_config() {
    koopa_locate_app \
        --app-name='MagickCore-config' \
        --opt-name='imagemagick'
}

koopa_locate_make() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='make' \
        --opt-name='make'
}

koopa_locate_mamba_or_conda() {
    local str
    str="$(koopa_locate_mamba --allow-missing)"
    if [[ -x "$str" ]]
    then
        koopa_print "$str"
        return 0
    fi
    koopa_locate_conda --allow-missing
}

koopa_locate_mamba() {
    koopa_locate_app \
        --app-name='mamba' \
        --opt-name='conda' \
        "$@"
}

koopa_locate_man() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='man' \
        --opt-name='man-db'
}

koopa_locate_md5sum() {
    koopa_locate_app \
        --app-name='md5sum' \
        --opt-name='coreutils'
}

koopa_locate_meson() {
    koopa_locate_app \
        --app-name='meson' \
        --opt-name='meson'
}

koopa_locate_mkdir() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='mkdir' \
        --opt-name='coreutils'
}

koopa_locate_mktemp() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='mktemp' \
        --opt-name='coreutils'
}

koopa_locate_mv() {
    if koopa_is_macos
    then
        koopa_locate_app '/bin/mv'
    else
        koopa_locate_app \
            --allow-in-path \
            --app-name='mv' \
            --opt-name='coreutils'
    fi
}

koopa_locate_neofetch() {
    koopa_locate_app \
        --app-name='neofetch' \
        --opt-name='neofetch'
}

koopa_locate_newgrp() {
    koopa_locate_app '/usr/bin/newgrp'
}

koopa_locate_nim() {
    koopa_locate_app \
        --app-name='nim' \
        --opt-name='nim'
}

koopa_locate_nimble() {
    koopa_locate_app \
        --app-name='nimble' \
        --opt-name='nim'
}

koopa_locate_ninja() {
    koopa_locate_app \
        --app-name='ninja' \
        --opt-name='ninja'
}

koopa_locate_node() {
    koopa_locate_app \
        --app-name='node' \
        --opt-name='node'
}

koopa_locate_npm() {
    koopa_locate_app \
        --app-name='npm' \
        --opt-name='node'
}

koopa_locate_nproc() {
    koopa_locate_app \
        --app-name='nproc' \
        --opt-name='coreutils' \
        "$@"
}

koopa_locate_od() {
    koopa_locate_app \
        --app-name='od' \
        --opt-name='coreutils'
}

koopa_locate_openssl() {
    koopa_locate_app \
        --app-name='openssl' \
        --opt-name='openssl3'
}

koopa_locate_parallel() {
    koopa_locate_app \
        --app-name='parallel' \
        --opt-name='coreutils'
}

koopa_locate_passwd() {
    koopa_locate_app '/usr/bin/passwd'
}

koopa_locate_paste() {
    koopa_locate_app \
        --app-name='paste' \
        --opt-name='coreutils'
}

koopa_locate_patch() {
    koopa_locate_app \
        --app-name='patch' \
        --opt-name='patch'
}

koopa_locate_pcre2_config() {
    koopa_locate_app \
        --app-name='pcre2-config' \
        --opt-name='pcre2'
}

koopa_locate_pcregrep() {
    koopa_locate_app \
        --app-name='pcre2grep' \
        --opt-name='pcre2'
}

koopa_locate_perl() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='perl' \
        --opt-name='perl'
}

koopa_locate_pkg_config() {
    koopa_locate_app \
        --app-name='pkg-config' \
        --opt-name='pkg-config' \
        "$@"
}

koopa_locate_prefetch() {
    koopa_locate_app \
        --app-name='prefetch' \
        --opt-name='sratoolkit'
}

koopa_locate_proj() {
    koopa_locate_app \
        --app-name='proj' \
        --opt-name='proj'
}

koopa_locate_pyenv() {
    koopa_locate_app \
        --app-name='pyenv' \
        --opt-name='pyenv'
}

koopa_locate_python() {
    local dict
    declare -A dict=(
        [name]='python'
    )
    dict[version]="$(koopa_variable "${dict[name]}")"
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    dict[python]="${dict[name]}${dict[maj_ver]}"
    koopa_locate_app \
        --app-name="${dict[python]}" \
        --opt-name='python'
}

koopa_locate_r() {
    koopa_locate_app \
        --app-name='R' \
        --opt-name='r'
}

koopa_locate_rbenv() {
    koopa_locate_app 'rbenv'
}

koopa_locate_readlink() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='readlink' \
        --opt-name='coreutils'
}

koopa_locate_realpath() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='realpath' \
        --opt-name='coreutils'
}

koopa_locate_rename() {
    koopa_locate_app \
        --app-name='rename' \
        --opt-name='rename'
}

koopa_locate_rg() {
    koopa_locate_app \
        --app-name='rg' \
        --opt-name='ripgrep' \
        "$@"
}

koopa_locate_rm() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='rm' \
        --opt-name='coreutils'
}

koopa_locate_rscript() {
    local app
    declare -A app=(
        [r]="$(koopa_locate_r)"
    )
    [[ -x "${app[r]}" ]] || return 1
    app[rscript]="${app[r]}script"
    koopa_locate_app "${app[rscript]}"
}

koopa_locate_rsync() {
    koopa_locate_app \
        --app-name='rsync' \
        --opt-name='rsync'
}

koopa_locate_ruby() {
    koopa_locate_app \
        --app-name='ruby' \
        --opt-name='ruby'
}

koopa_locate_rustc() {
    koopa_locate_app \
        --app-name='rustc' \
        --opt-name='rust'
}

koopa_locate_salmon() {
    koopa_locate_app \
        --app-name='salmon' \
        --opt-name='salmon'
}

koopa_locate_samtools() {
    koopa_locate_app \
        --app-name='samtools' \
        --opt-name='samtools'
}

koopa_locate_scons() {
    koopa_locate_app \
        --app-name='scons' \
        --opt-name='scons'
}

koopa_locate_scp() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='scp' \
        --opt-name='openssh'
}

koopa_locate_sed() {
    koopa_locate_app \
        --app-name='sed' \
        --opt-name='sed'
}

koopa_locate_shellcheck() {
    koopa_locate_app \
        --app-name='shellcheck' \
        --opt-name='shellcheck'
}

koopa_locate_shunit2() {
    koopa_locate_app \
        --app-name='shunit2' \
        --opt-name='shunit2'
}

koopa_locate_sort() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='sort' \
        --opt-name='coreutils'
}

koopa_locate_sox() {
    koopa_locate_app \
        --app-name='sox' \
        --opt-name='sox'
}

koopa_locate_sqlplus() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='sqlplus'
}

koopa_locate_ssh_add() {
    if koopa_is_macos
    then
        koopa_locate_app '/usr/bin/ssh-add'
    else
        koopa_locate_app \
            --app-name='ssh-add' \
            --opt-name='openssh'
    fi
}

koopa_locate_ssh_keygen() {
    koopa_locate_app \
        --app-name='ssh-keygen' \
        --opt-name='openssh'
}

koopa_locate_ssh() {
    koopa_locate_app \
        --app-name='ssh' \
        --opt-name='openssh'
}

koopa_locate_sshfs() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='sshfs'
}

koopa_locate_stack() {
    koopa_locate_app \
        --app-name='stack' \
        --opt-name='haskell-stack'
}

koopa_locate_star() {
    koopa_locate_app \
        --app-name='STAR' \
        --opt-name='star'
}

koopa_locate_stat() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='stat' \
        --opt-name='coreutils'
}

koopa_locate_sudo() {
    koopa_locate_app '/usr/bin/sudo'
}

koopa_locate_svn() {
    koopa_locate_app \
        --app-name='svn' \
        --opt-name='subversion'
}

koopa_locate_tac() {
    koopa_locate_app \
        --app-name='tac' \
        --opt-name='coreutils'
}

koopa_locate_tail() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='tail' \
        --opt-name='coreutils'
}

koopa_locate_tar() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='tar' \
        --opt-name='tar'
}

koopa_locate_tee() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='tee' \
        --opt-name='coreutils'
}

koopa_locate_tex() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='tex'
}

koopa_locate_tlmgr() {
    if koopa_is_macos
    then
        koopa_locate_app '/Library/TeX/texbin/tlmgr'
    else
        koopa_locate_app \
            --allow-in-path \
            --app-name='tlmgr'
    fi
}

koopa_locate_touch() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='touch' \
        --opt-name='coreutils'
}

koopa_locate_tr() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='tr' \
        --opt-name='coreutils'
}

koopa_locate_uname() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='uname' \
        --opt-name='coreutils'
}

koopa_locate_uncompress() {
    koopa_locate_app \
        --app-name='uncompress' \
        --opt-name='gzip'
}

koopa_locate_uniq() {
    koopa_locate_app \
        --app-name='uniq' \
        --opt-name='coreutils'
}

koopa_locate_unzip() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='unzip'
}

koopa_locate_vim() {
    koopa_locate_app \
        --app-name='vim' \
        --opt-name='vim'
}

koopa_locate_wc() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='wc' \
        --opt-name='coreutils'
}

koopa_locate_wget() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='wget' \
        --opt-name='wget'
}

koopa_locate_whoami() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='whoami' \
        --opt-name='coreutils'
}

koopa_locate_xargs() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='xargs' \
        --opt-name='findutils'
}

koopa_locate_xz() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='xz' \
        --opt-name='xz'
}

koopa_locate_yes() {
    koopa_locate_app \
        --allow-in-path \
        --app-name='yes' \
        --opt-name='coreutils'
}

koopa_locate_yt_dlp() {
    koopa_locate_app \
        --app-name='yt-dlp' \
        --opt-name='yt-dlp'
}

koopa_locate_zcat() {
    koopa_locate_app \
        --app-name='zcat' \
        --opt-name='gzip'
}

koopa_lowercase() {
    local app str
    declare -A app=(
        [tr]="$(koopa_locate_tr)"
    )
    [[ -x "${app[tr]}" ]] || return 1
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
            | "${app[tr]}" '[:upper:]' '[:lower:]'
    done
    return 0
}

koopa_make_build_string() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [arch]="$(koopa_arch)"
    )
    if koopa_is_linux
    then
        dict[os_type]='linux-gnu'
    else
        dict[os_type]="$(koopa_os_type)"
    fi
    koopa_print "${dict[arch]}-${dict[os_type]}"
    return 0
}

koopa_man_prefix() {
    koopa_print "$(koopa_koopa_prefix)/man"
    return 0
}

koopa_man_version() {
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [grep]="$(koopa_locate_grep)"
        [man]="${1:-}"
    )
    [[ -z "${app[man]}" ]] && app[man]="$(koopa_locate_man)"
    [[ -x "${app[grep]}" ]] || return 1
    [[ -x "${app[man]}" ]] || return 1
    str="$( \
        "${app[grep]}" \
            --extended-regexp \
            --only-matching \
            --text \
            'lib/man-db/libmandb-[.0-9]+\.dylib' \
            "${app[man]}" \
    )"
    [[ -n "$str" ]] || return 1
    koopa_extract_version "$str"
    return 0
}

koopa_md5sum_check_to_new_md5_file() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [md5sum]="$(koopa_locate_md5sum)"
        [tee]="$(koopa_locate_tee)"
    )
    [[ -x "${app[md5sum]}" ]] || return 1
    [[ -x "${app[tee]}" ]] || return 1
    declare -A dict=(
        [datetime]="$(koopa_datetime)"
    )
    dict[log_file]="md5sum-${dict[datetime]}.md5"
    koopa_assert_is_not_file "${dict[log_file]}"
    koopa_assert_is_file "$@"
    "${app[md5sum]}" "$@" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

koopa_mem_gb() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [awk]='awk'
    )
    declare -A dict
    if koopa_is_macos
    then
        app[sysctl]="$(koopa_macos_locate_sysctl)"
        dict[mem]="$("${app[sysctl]}" -n 'hw.memsize')"
        dict[denom]=1073741824  # 1024^3; bytes
    elif koopa_is_linux
    then
        dict[meminfo]='/proc/meminfo'
        koopa_assert_is_file "${dict[meminfo]}"
        dict[mem]="$("${app[awk]}" '/MemTotal/ {print $2}' "${dict[meminfo]}")"
        dict[denom]=1048576  # 1024^2; KB
    else
        koopa_stop 'Unsupported system.'
    fi
    dict[str]="$( \
        "${app[awk]}" \
            -v denom="${dict[denom]}" \
            -v mem="${dict[mem]}" \
            'BEGIN{ printf "%.0f\n", mem / denom }' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

koopa_merge_pdf() {
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        [gs]="$(koopa_locate_gs)"
    )
    [[ -x "${app[gs]}" ]] || return 1
    koopa_assert_is_file "$@"
    "${app[gs]}" \
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
    declare -A app=(
        [mkdir]="$(koopa_locate_mkdir)"
    )
    [[ -x "${app[mkdir]}" ]] || return 1
    declare -A dict=(
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict[sudo]=1
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
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        [[ -x "${app[sudo]}" ]] || return 1
        mkdir=("${app[sudo]}" "${app[mkdir]}")
    else
        mkdir=("${app[mkdir]}")
    fi
    "${mkdir[@]}" "${mkdir_args[@]}" "$@"
    return 0
}

koopa_mktemp() {
    local app dict mktemp_args str
    declare -A app=(
        [mktemp]="$(koopa_locate_mktemp)"
    )
    [[ -x "${app[mktemp]}" ]] || return 1
    declare -A dict=(
        [date_id]="$(koopa_datetime)"
        [user_id]="$(koopa_user_id)"
    )
    dict[template]="koopa-${dict[user_id]}-${dict[date_id]}-XXXXXXXXXX"
    mktemp_args=(
        "$@"
        '-t' "${dict[template]}"
    )
    str="$("${app[mktemp]}" "${mktemp_args[@]}")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_move_files_in_batch() {
    local app dict files
    koopa_assert_has_args_eq "$#" 3
    declare -A app=(
        [head]="$(koopa_locate_head)"
    )
    [[ -x "${app[head]}" ]] || return 1
    declare -A dict=(
        [num]=''
        [source_dir]=''
        [target_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--num='*)
                dict[num]="${1#*=}"
                shift 1
                ;;
            '--num')
                dict[num]="${2:?}"
                shift 2
                ;;
            '--source-dir='*)
                dict[source_dir]="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict[source_dir]="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--num' "${dict[num]}" \
        '--source-dir' "${dict[source_dir]}" \
        '--target-dir' "${dict[target_dir]}"
    koopa_assert_is_dir "${dict[target_dir]}"
    dict[target_dir]="$(koopa_init_dir "${dict[target_dir]}")"
    readarray -t files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[source_dir]}" \
            --sort \
            --type='f' \
        | "${app[head]}" -n "${dict[num]}" \
    )"
    koopa_is_array_non_empty "${files[@]:-}" || return 1
    koopa_mv --target-directory="${dict[target_dir]}" "${files[@]}"
    return 0
}

koopa_move_files_up_1_level() {
    local dict files
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="${PWD:?}"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    readarray -t files <<< "$( \
        koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict[prefix]}" \
            --type='f' \
    )"
    koopa_is_array_non_empty "${files[@]:-}" || return 1
    koopa_mv --target-directory="${dict[prefix]}" "${files[@]}"
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
            [file]="$file"
        )
        if [[ "${dict[file]}" =~ $grep_string ]]
        then
            dict[year]="${BASH_REMATCH[1]}"
            dict[month]="${BASH_REMATCH[3]}"
            dict[day]="${BASH_REMATCH[5]}"
            dict[subdir]="${dict[year]}/${dict[month]}/${dict[day]}"
            koopa_mv --target-directory="${dict[subdir]}" "${dict[file]}"
        else
            koopa_stop "Does not contain date: '${dict[file]}'."
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
        [mkdir]='koopa_mkdir'
        [mv]="$(koopa_locate_mv)"
        [rm]='koopa_rm'
    )
    [[ -x "${app[mv]}" ]] || return 1
    declare -A dict=(
        [sudo]=0
        [target_dir]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--target-directory='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            '--sudo' | \
            '-S')
                dict[sudo]=1
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
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        mkdir=("${app[mkdir]}" '--sudo')
        mv=("${app[sudo]}" "${app[mv]}")
        rm=("${app[rm]}" '--sudo')
    else
        mkdir=("${app[mkdir]}")
        mv=("${app[mv]}")
        rm=("${app[rm]}")
    fi
    mv_args=('-f')
    mv_args+=("$@")
    if [[ -n "${dict[target_dir]}" ]]
    then
        koopa_assert_is_existing "$@"
        dict[target_dir]="$(koopa_strip_trailing_slash "${dict[target_dir]}")"
        if [[ ! -d "${dict[target_dir]}" ]]
        then
            "${mkdir[@]}" "${dict[target_dir]}"
        fi
        mv_args+=("${dict[target_dir]}")
    else
        koopa_assert_has_args_eq "$#" 2
        dict[source_file]="$(koopa_strip_trailing_slash "${1:?}")"
        koopa_assert_is_existing "${dict[source_file]}"
        dict[target_file]="$(koopa_strip_trailing_slash "${2:?}")"
        if [[ -e "${dict[target_file]}" ]]
        then
            "${rm[@]}" "${dict[target_file]}"
        fi
        dict[target_parent]="$(koopa_dirname "${dict[target_file]}")"
        if [[ ! -d "${dict[target_parent]}" ]]
        then
            "${mkdir[@]}" "${dict[target_parent]}"
        fi
    fi
    "${mv[@]}" "${mv_args[@]}"
    return 0
}

koopa_nfiletypes() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [sed]="$(koopa_locate_sed)"
        [sort]="$(koopa_locate_sort)"
        [uniq]="$(koopa_locate_uniq)"
    )
    [[ -x "${app[sed]}" ]] || return 1
    [[ -x "${app[sort]}" ]] || return 1
    [[ -x "${app[uniq]}" ]] || return 1
    declare -A dict=(
        [prefix]="${1:?}"
    )
    koopa_assert_is_dir "${dict[prefix]}"
    dict[out]="$( \
        koopa_find \
            --exclude='.*' \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.*' \
            --prefix="${dict[prefix]}" \
            --type='f' \
        | "${app[sed]}" 's/.*\.//' \
        | "${app[sort]}" \
        | "${app[uniq]}" --count \
        | "${app[sort]}" --numeric-sort \
        | "${app[sed]}" 's/^ *//g' \
        | "${app[sed]}" 's/ /\t/g' \
    )"
    [[ -n "${dict[out]}" ]] || return 1
    koopa_print "${dict[out]}"
    return 0
}

koopa_ngettext() {
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [middle]=' '
        [msg1]=''
        [msg2]=''
        [num]=''
        [prefix]=''
        [str]=''
        [suffix]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--middle='*)
                dict[middle]="${1#*=}"
                shift 1
                ;;
            '--middle')
                dict[middle]="${2:?}"
                shift 2
                ;;
            '--msg1='*)
                dict[msg1]="${1#*=}"
                shift 1
                ;;
            '--msg1')
                dict[msg1]="${2:?}"
                shift 2
                ;;
            '--msg2='*)
                dict[msg2]="${1#*=}"
                shift 1
                ;;
            '--msg2')
                dict[msg2]="${2:?}"
                shift 2
                ;;
            '--num='*)
                dict[num]="${1#*=}"
                shift 1
                ;;
            '--num')
                dict[num]="${2:?}"
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
            '--suffix='*)
                dict[suffix]="${1#*=}"
                shift 1
                ;;
            '--suffix')
                dict[suffix]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--middle' "${dict[middle]}"  \
        '--msg1' "${dict[msg1]}"  \
        '--msg2' "${dict[msg2]}"  \
        '--num' "${dict[num]}"
    case "${dict[num]}" in
        '1')
            dict[msg]="${dict[msg1]}"
            ;;
        *)
            dict[msg]="${dict[msg2]}"
            ;;
    esac
    dict[str]="${dict[prefix]}${dict[num]}${dict[middle]}\
${dict[msg]}${dict[suffix]}"
    koopa_print "${dict[str]}"
    return 0
}

koopa_node_package_version() {
    local app pkg
    koopa_assert_has_args "$#"
    declare -A app=(
        [jq]="$(koopa_locate_jq)"
        [npm]="$(koopa_locate_npm)"
    )
    [[ -x "${app[jq]}" ]] || return 1
    [[ -x "${app[npm]}" ]] || return 1
    for pkg in "$@"
    do
        local dict
        declare -A dict
        dict[pkg]="$pkg"
        dict[str]="$( \
            "${app[npm]}" --global --json list "${dict[pkg]}" \
            | "${app[jq]}" \
                --raw-output \
                ".dependencies.${dict[pkg]}.version" \
        )"
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
    done
    return 0
}

koopa_openjdk_version() {
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [java]="${1:-}"
    )
    [[ -z "${app[java]}" ]] && app[java]="$(koopa_locate_java)"
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[java]}" ]] || return 1
    str="$( \
        "${app[java]}" --version \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_opt_version() {
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        [name]="${1:?}"
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    dict[symlink]="${dict[opt_prefix]}/${dict[name]}"
    koopa_assert_is_symlink "${dict[symlink]}"
    dict[realpath]="$(koopa_realpath "${dict[symlink]}")"
    dict[version]="$(koopa_basename "${dict[realpath]}")"
    koopa_print "${dict[version]}"
    return 0
}

koopa_oracle_instantclient_version() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [sqlplus]="$(koopa_locate_sqlplus)"
    )
    [[ -x "${app[sqlplus]}" ]] || return 1
    str="$( \
        "${app[sqlplus]}" -v \
            | koopa_grep --pattern='^Version' --regex \
            | koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_os_type() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [tr]="$(koopa_locate_tr)"
        [uname]="$(koopa_locate_uname)"
    )
    [[ -x "${app[tr]}" ]] || return 1
    [[ -x "${app[uname]}" ]] || return 1
    str="$( \
        "${app[uname]}" -s \
        | "${app[tr]}" '[:upper:]' '[:lower:]' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_os_version() {
    local str
    koopa_assert_has_no_args "$#"
    if koopa_is_linux
    then
        str="$(koopa_linux_os_version)"
    elif koopa_is_macos
    then
        str="$(koopa_macos_os_version)"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_pager() {
    local app args
    koopa_assert_has_args "$#"
    declare -A app=(
        [less]="$(koopa_locate_less)"
    )
    [[ -x "${app[less]}" ]] || return 1
    args=("$@")
    koopa_assert_is_file "${args[-1]}"
    "${app[less]}" -R "${args[@]}"
    return 0
}

koopa_parallel_version() {
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [parallel]="${1:-}"
    )
    [[ -z "${app[parallel]}" ]] && app[parallel]="$(koopa_locate_parallel)"
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[parallel]}" ]] || return 1
    str="$( \
        "${app[parallel]}" --version \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '3' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_parent_dir() {
    local app dict file parent pos
    declare -A app=(
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[sed]}" ]] || return 1
    declare -A dict=(
        [cd_tail]=''
        [n]=1
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--num='*)
                dict[n]="${1#*=}"
                shift 1
                ;;
            '--num' | \
            '-n')
                dict[n]="${2:?}"
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
    [[ "${dict[n]}" -ge 1 ]] || dict[n]=1
    if [[ "${dict[n]}" -ge 2 ]]
    then
        dict[n]="$((dict[n]-1))"
        dict[cd_tail]="$( \
            printf "%${dict[n]}s" \
            | "${app[sed]}" 's| |/..|g' \
        )"
    fi
    for file in "$@"
    do
        [[ -e "$file" ]] || return 1
        parent="$(koopa_dirname "$file")"
        parent="${parent}${dict[cd_tail]}"
        parent="$(koopa_cd "$parent" && pwd -P)"
        koopa_print "$parent"
    done
    return 0
}

koopa_parse_url() {
    local app curl_args pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [curl]="$(koopa_locate_curl)"
    )
    [[ -x "${app[curl]}" ]] || return 1
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
    "${app[curl]}" "${curl_args[@]}"
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

koopa_perl_file_rename_version() {
    koopa_assert_has_no_args "$#"
    koopa_perl_package_version 'File::Rename'
}

koopa_perl_package_version() {
    local app pkg
    koopa_assert_has_args "$#"
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    [[ -x "${app[perl]}" ]] || return 1
    for pkg in "$@"
    do
        local dict
        declare -A dict
        dict[pkg]="$pkg"
        dict[str]="$( \
            "${app[perl]}" \
                -M"${dict[pkg]}" \
                -e "print \$${dict[pkg]}::VERSION .\"\n\";" \
        )"
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
    done
    return 0
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

koopa_prune_apps() {
    if koopa_is_macos
    then
        koopa_alert_note 'App pruning not yet supported on macOS.'
        return 0
    fi
    koopa_r_koopa 'cliPruneApps' "$@"
    return 0
}

koopa_public_ip_address() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [dig]="$(koopa_locate_dig --allow-missing)"
    )
    if koopa_is_installed "${app[dig]}"
    then
        str="$( \
            "${app[dig]}" +short \
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
    local app dict names
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [basename]="$(koopa_locate_basename)"
        [grep]="$(koopa_locate_grep)"
        [xargs]="$(koopa_locate_xargs)"
    )
    [[ -x "${app[basename]}" ]] || return 1
    [[ -x "${app[grep]}" ]] || return 1
    [[ -x "${app[xargs]}" ]] || return 1
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    readarray -t names <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[opt_prefix]}" \
            --print0 \
            --sort \
            --type='l' \
        | "${app[xargs]}" -0 -n 1 "${app[basename]}" \
        | "${app[grep]}" -Ev '^.+-packages$' \
    )"
    koopa_assert_is_array_non_empty "${names[@]:-}"
    koopa_push_app_build "${names[@]}"
    return 0
}

koopa_push_app_build() {
    local app dict name
    koopa_assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
        [tar]="$(koopa_locate_tar)"
    )
    [[ -x "${app[aws]}" ]] || return 1
    [[ -x "${app[tar]}" ]] || return 1
    declare -A dict=(
        [arch]="$(koopa_arch2)" # e.g. 'amd64'.
        [opt_prefix]="$(koopa_opt_prefix)"
        [os_string]="$(koopa_os_string)"
        [s3_prefix]='s3://koopa.acidgenomics.com/app'
        [s3_profile]='acidgenomics'
        [tmp_dir]="$(koopa_tmp_dir)"
    )
    for name in "$@"
    do
        local dict2
        declare -A dict2
        dict2[name]="$name"
        dict2[prefix]="$(koopa_realpath "${dict[opt_prefix]}/${dict2[name]}")"
        koopa_assert_is_dir "${dict2[prefix]}"
        dict2[version]="$(koopa_basename "${dict2[prefix]}")"
        dict2[local_tar]="${dict[tmp_dir]}/\
${dict2[name]}/${dict2[version]}.tar.gz"
        dict2[remote_tar]="${dict[s3_prefix]}/${dict[os_string]}/${dict[arch]}/\
${dict2[name]}/${dict2[version]}.tar.gz"
        koopa_alert "Pushing '${dict2[prefix]}' to '${dict2[remote_tar]}'."
        koopa_mkdir "${dict[tmp_dir]}/${dict2[name]}"
        "${app[tar]}" -Pczf "${dict2[local_tar]}" "${dict2[prefix]}/"
        "${app[aws]}" --profile="${dict[s3_profile]}" \
            s3 cp "${dict2[local_tar]}" "${dict2[remote_tar]}"
    done
    koopa_rm "${dict[tmp_dir]}"
    return 0
}

koopa_python_activate_venv() {
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        [active_env]="${VIRTUAL_ENV:-}"
        [name]="${1:?}"
        [nounset]="$(koopa_boolean_nounset)"
        [prefix]="$(koopa_python_virtualenvs_prefix)"
    )
    dict[script]="${dict[prefix]}/${dict[name]}/bin/activate"
    koopa_assert_is_readable "${dict[script]}"
    if [[ -n "${dict[active_env]}" ]]
    then
        koopa_python_deactivate_venv "${dict[active_env]}"
    fi
    [[ "${dict[nounset]}" -eq 1 ]] && set +o nounset
    source "${dict[script]}"
    [[ "${dict[nounset]}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_python_create_venv() {
    local app dict pkgs pos venv_args
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A app=(
        [python]="$(koopa_locate_python)"
    )
    [[ -x "${app[python]}" ]] || return 1
    declare -A dict=(
        [name]=''
        [pip]=1
        [prefix]=''
        [system_site_packages]=1
    )
    pos=()
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
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--python='*)
                app[python]="${1#*=}"
                shift 1
                ;;
            '--python')
                app[python]="${2:?}"
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
    koopa_assert_is_set --python "${app[python]}"
    koopa_assert_is_installed "${app[python]}"
    dict[py_version]="$(koopa_get_version "${app[python]}")"
    dict[py_maj_min_ver]="$(koopa_major_minor_version "${dict[py_version]}")"
    if [[ -z "${dict[prefix]}" ]]
    then
        koopa_assert_is_set --name "${dict[name]}"
        dict[venv_prefix]="$(koopa_python_virtualenvs_prefix)"
        dict[prefix]="${dict[venv_prefix]}/${dict[name]}"
        dict[app_bn]="$(koopa_basename "${dict[venv_prefix]}")"
        dict[app_prefix]="$(koopa_app_prefix)/${dict[app_bn]}/\
${dict[py_maj_min_ver]}"
        if [[ ! -d "${dict[app_prefix]}" ]]
        then
            koopa_alert "Configuring venv prefix at '${dict[app_prefix]}'."
            koopa_sys_mkdir "${dict[app_prefix]}"
            koopa_sys_set_permissions "$(koopa_dirname "${dict[app_prefix]}")"
        fi
        koopa_link_in_opt "${dict[app_prefix]}" "${dict[app_bn]}"
    fi
    [[ -d "${dict[prefix]}" ]] && koopa_rm "${dict[prefix]}"
    koopa_assert_is_not_dir "${dict[prefix]}"
    koopa_sys_mkdir "${dict[prefix]}"
    unset -v PYTHONPATH
    venv_args=()
    if [[ "${dict[pip]}" -eq 0 ]]
    then
        venv_args+=('--without-pip')
    fi
    if [[ "${dict[system_site_packages]}" -eq 1 ]]
    then
        venv_args+=('--system-site-packages')
    fi
    venv_args+=("${dict[prefix]}")
    "${app[python]}" -m venv "${venv_args[@]}"
    app[venv_python]="${dict[prefix]}/bin/python${dict[py_maj_min_ver]}"
    koopa_assert_is_installed "${app[venv_python]}"
    if [[ "${dict[pip]}" -eq 1 ]]
    then
        koopa_python_pip_install \
            --python="${app[venv_python]}" \
            'pip==22.1.2' \
            'setuptools==63.1.0' \
            'wheel==0.37.1'
    fi
    if koopa_is_array_non_empty "${pkgs[@]:-}"
    then
        koopa_python_pip_install --python="${app[venv_python]}" "${pkgs[@]}"
    fi
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    return 0
}

koopa_python_deactivate_venv() {
    local dict
    declare -A dict=(
        [prefix]="${VIRTUAL_ENV:-}"
    )
    if [[ -z "${dict[prefix]}" ]]
    then
        koopa_stop 'Python virtual environment is not active.'
    fi
    koopa_remove_from_path "${dict[prefix]}/bin"
    unset -v VIRTUAL_ENV
    return 0
}

koopa_python_get_pkg_versions() {
    local i pkg pkgs pkg_lower version
    koopa_assert_has_args "$#"
    pkgs=("$@")
    for i in "${!pkgs[@]}"
    do
        pkg="${pkgs[$i]}"
        pkg_lower="$(koopa_lowercase "$pkg")"
        version="$(koopa_variable "python-${pkg_lower}")"
        pkgs[$i]="${pkg}==${version}"
    done
    koopa_print "${pkgs[@]}"
    return 0
}

koopa_python_pip_install() {
    local app dict dl_args pkgs pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [python]="$(koopa_locate_python)"
    )
    [[ -x "${app[python]}" ]] || return 1
    declare -A dict=(
        [prefix]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--python='*)
                app[python]="${1#*=}"
                shift 1
                ;;
            '--python')
                app[python]="${2:?}"
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
        '--disable-pip-version-check'
        '--ignore-installed'
        '--no-warn-script-location'
    )
    dl_args=(
        'Python' "${app[python]}"
        'Packages' "$(koopa_to_string "${pkgs[*]}")"
    )
    if [[ -n "${dict[prefix]}" ]]
    then
        install_args+=(
            "--target=${dict[prefix]}"
            '--upgrade'
        )
        dl_args+=('Target' "${dict[prefix]}")
    fi
    koopa_dl "${dl_args[@]}"
    export PIP_REQUIRE_VIRTUALENV='false'
    "${app[python]}" -m pip --isolated \
        install "${install_args[@]}" "${pkgs[@]}"
    return 0
}

koopa_python_system_packages_prefix() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [python]="${1:-}"
    )
    [[ -z "${app[python]}" ]] && app[python]="$(koopa_locate_python)"
    [[ -x "${app[python]}" ]] || return 1
    declare -A dict
    dict[prefix]="$( \
        "${app[python]}" -c 'import site; print(site.getsitepackages()[0])' \
    )"
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_print "${dict[prefix]}"
    return 0
}

koopa_r_configure_environ() {
    local app dict i key keys lines path_arr pkgconfig_arr
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
        [r]="${1:?}"
        [sort]="$(koopa_locate_sort)"
    )
    [[ -x "${app[cat]}" ]] || return 1
    [[ -x "${app[r]}" ]] || return 1
    [[ -x "${app[sort]}" ]] || return 1
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [opt_prefix]="$(koopa_opt_prefix)"
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
        [system]=0
        [tmp_file]="$(koopa_tmp_file)"
    )
    dict[file]="${dict[r_prefix]}/etc/Renviron.site"
    ! koopa_is_koopa_app "${app[r]}" && dict[system]=1
    koopa_alert "Configuring '${dict[file]}'."
    lines=()
    lines+=(
        "R_LIBS_SITE=\${R_HOME}/site-library"
        "R_LIBS_USER=\${R_LIBS_SITE}"
    )
    path_arr=()
    if koopa_is_macos
    then
        path_arr+=('/Applications/RStudio.app/Contents/MacOS/pandoc')
    fi
    path_arr+=(
        "${dict[koopa_prefix]}/bin"
        '/usr/bin'
        '/bin'
    )
    if koopa_is_macos
    then
        path_arr+=('/Library/TeX/texbin')
    fi
    declare -A pkgconfig_arr
    keys=(
        'fontconfig'
        'freetype'
        'fribidi'
        'gdal'
        'geos'
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
        'openblas'
        'openssl3'
        'pcre2'
        'proj'
        'readline'
        'xz'
        'zlib'
        'zstd'
    )
    for key in "${keys[@]}"
    do
        pkgconfig_arr[$key]="$(koopa_realpath "${dict[opt_prefix]}/${key}")"
    done
    for i in "${!pkgconfig_arr[@]}"
    do
        pkgconfig_arr[$i]="${pkgconfig_arr[$i]}/lib"
    done
    if koopa_is_linux
    then
        pkgconfig_arr[harfbuzz]="${pkgconfig_arr[harfbuzz]}64"
    fi
    for i in "${!pkgconfig_arr[@]}"
    do
        pkgconfig_arr[$i]="${pkgconfig_arr[$i]}/pkgconfig"
    done
    lines+=(
        "PAGER=\${PAGER:-less}"
        "PATH=$(printf '%s:' "${path_arr[@]}")"
        "PKG_CONFIG_PATH=$(printf '%s:' "${pkgconfig_arr[@]}")"
        "R_PAPERSIZE_USER=\${R_PAPERSIZE}"
        "TZ=\${TZ:-America/New_York}"
        'R_PAPERSIZE=letter'
    )
    if koopa_is_linux
    then
        lines+=(
            'R_BROWSER=xdg-open'
            'R_PRINTCMD=lpr'
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
    dict[conda]="$(koopa_realpath "${dict[opt_prefix]}/conda")"
    lines+=(
        "RETICULATE_MINICONDA_PATH=${dict[conda]}"
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
    dict[udunits2]="$(koopa_realpath "${dict[opt_prefix]}/udunits")"
    lines+=(
        "UDUNITS2_INCLUDE=${dict[udunits2]}/include"
        "UDUNITS2_LIBS=${dict[udunits2]}/lib"
    )
    if koopa_is_fedora_like
    then
        dict[oracle_ver]="$(koopa_variable 'oracle-instant-client')"
        dict[oracle_ver]="$(koopa_major_minor_version "${dict[oracle_ver]}")"
        lines+=(
            "OCI_VERSION=${dict[oracle_ver]}"
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
    dict[string]="$(koopa_print "${lines[@]}" | "${app[sort]}")"
    case "${dict[system]}" in
        '0')
            koopa_rm "${dict[file]}"
            koopa_write_string \
                --file="${dict[file]}" \
                --string="${dict[string]}"
            ;;
        '1')
            koopa_rm --sudo "${dict[file]}"
            koopa_sudo_write_string \
                --file="${dict[file]}" \
                --string="${dict[string]}"
            ;;
    esac
    return 0
}

koopa_r_configure_ldpaths() {
    local app dict key keys ld_lib_arr ld_lib_opt_arr lines
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [r]="${1:?}"
    )
    [[ -x "${app[r]}" ]] || return 1
    koopa_is_koopa_app "${app[r]}" && return 0
    koopa_is_linux || return 0
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [opt_prefix]="$(koopa_opt_prefix)"
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
    )
    dict[file]="${dict[r_prefix]}/etc/ldpaths"
    dict[java_home]="$(koopa_realpath "${dict[opt_prefix]}/openjdk")"
    koopa_alert "Configuring '${dict[file]}'."
    lines=()
    lines+=(
        ": \${JAVA_HOME=${dict[java_home]}}"
        ": \${R_JAVA_LD_LIBRARY_PATH=\${JAVA_HOME}/libexec/lib/server}"
    )
    declare -A ld_lib_opt_arr
    keys=(
        'fontconfig'
        'freetype'
        'gdal'
        'geos'
        'imagemagick'
        'libgit2'
        'proj'
    )
    for key in "${keys[@]}"
    do
        ld_lib_opt_arr[$key]="$( \
            koopa_realpath "${dict[opt_prefix]}/${key}/lib" \
        )"
    done
    ld_lib_arr=(
        "/usr/lib/${dict[arch]}-linux-gnu"
        "\${R_HOME}/lib"
        "${ld_lib_opt_arr[@]}"
        "\${R_JAVA_LD_LIBRARY_PATH}"
    )
    lines+=(
        "LD_LIBRARY_PATH=$(printf '%s:' "${ld_lib_arr[@]}")"
        'export LD_LIBRARY_PATH'
    )
    dict[string]="$(koopa_print "${lines[@]}")"
    koopa_sudo_write_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
    return 0
}

koopa_r_configure_makevars() {
    local app dict flibs i libs
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [dirname]="$(koopa_locate_dirname)"
        [r]="${1:?}"
        [sort]="$(koopa_locate_sort)"
        [xargs]="$(koopa_locate_xargs)"
    )
    [[ -x "${app[dirname]}" ]] || return 1
    [[ -x "${app[r]}" ]] || return 1
    [[ -x "${app[sort]}" ]] || return 1
    [[ -x "${app[xargs]}" ]] || return 1
    koopa_is_koopa_app "${app[r]}" && return 0
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [opt_prefix]="$(koopa_opt_prefix)"
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
    )
    dict[file]="${dict[r_prefix]}/etc/Makevars.site"
    koopa_alert "Configuring '${dict[file]}'."
    if koopa_is_linux
    then
        dict[freetype]="$(koopa_realpath "${dict[opt_prefix]}/freetype")"
        read -r -d '' "dict[string]" << END || true
CPPFLAGS += -I${dict[freetype]}/include/freetype2
END
    elif koopa_is_macos
    then
        dict[gcc_prefix]="$(koopa_realpath "${dict[opt_prefix]}/gcc")"
        app[fc]="${dict[gcc_prefix]}/bin/gfortran"
        readarray -t libs <<< "$( \
            koopa_find \
                --prefix="${dict[gcc_prefix]}" \
                --pattern='*.a' \
                --type 'f' \
            | "${app[xargs]}" -I '{}' "${app[dirname]}" '{}' \
            | "${app[sort]}" --unique \
        )"
        koopa_assert_is_array_non_empty "${libs[@]:-}"
        flibs=()
        for i in "${!libs[@]}"
        do
            flibs+=("-L${libs[i]}")
        done
        flibs+=('-lgfortran')
        case "${dict[arch]}" in
            'x86_64')
                flibs+=('-lquadmath')
                ;;
        esac
        flibs+=('-lm')
        dict[flibs]="${flibs[*]}"
        read -r -d '' "dict[string]" << END || true
FC = ${app[fc]}
FLIBS = ${dict[flibs]}
END
    fi
    koopa_sudo_write_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
    return 0
}

koopa_r_javareconf() {
    local app dict java_args r_cmd
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [r]="${1:?}"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app[r]}" ]] || return 1
    [[ -x "${app[sudo]}" ]] || return 1
    declare -A dict=(
        [java_home]="$(koopa_java_prefix)"
    )
    if [[ ! -d "${dict[java_home]}" ]]
    then
        koopa_alert_note 'Skipping R Java configuration.'
        return 0
    fi
    dict[java_home]="$(koopa_realpath "${dict[java_home]}")"
    dict[jar]="${dict[java_home]}/bin/jar"
    dict[java]="${dict[java_home]}/bin/java"
    dict[javac]="${dict[java_home]}/bin/javac"
    koopa_alert 'Updating R Java configuration.'
    koopa_dl \
        'JAR' "${dict[jar]}" \
        'JAVA' "${dict[java]}" \
        'JAVAC' "${dict[javac]}" \
        'JAVA_HOME' "${dict[java_home]}" \
        'R' "${app[r]}"
    if koopa_is_koopa_app "${app[r]}"
    then
        r_cmd=("${app[r]}")
    else
        koopa_assert_is_admin
        r_cmd=("${app[sudo]}" "${app[r]}")
    fi
    java_args=(
        "JAR=${dict[jar]}"
        "JAVA=${dict[java]}"
        "JAVAC=${dict[javac]}"
        'JAVAH='
        "JAVA_HOME=${dict[java_home]}"
    )
    "${r_cmd[@]}" --vanilla CMD javareconf "${java_args[@]}"
    return 0
}

koopa_r_koopa() {
    local app code header_file fun pos rscript_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [rscript]="$(koopa_locate_rscript)"
    )
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
    "${app[rscript]}" "${rscript_args[@]}" -e "${code[*]}" "${pos[@]@Q}"
    return 0
}

koopa_r_library_prefix() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    [[ -x "${app[r]}" ]] || return 1
    app[rscript]="${app[r]}script"
    [[ -x "${app[rscript]}" ]] || return 1
    declare -A dict
    dict[prefix]="$( \
        "${app[rscript]}" -e 'cat(normalizePath(.libPaths()[[1L]]))' \
    )"
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_print "${dict[prefix]}"
    return 0
}

koopa_r_link_files_in_etc() {
    local app dict file files
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [r]="${1:?}"
    )
    koopa_assert_is_installed "${app[r]}"
    declare -A dict=(
        [distro_prefix]="$(koopa_distro_prefix)"
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
        [sudo]=0
        [version]="$(koopa_r_version "${app[r]}")"
    )
    koopa_assert_is_dir "${dict[r_prefix]}"
    if [[ "${dict[version]}" != 'devel' ]]
    then
        dict[version]="$(koopa_major_minor_version "${dict[version]}")"
    fi
    dict[r_etc_source]="${dict[distro_prefix]}/etc/R/${dict[version]}"
    koopa_assert_is_dir "${dict[r_etc_source]}"
    if koopa_is_linux && \
        ! koopa_is_koopa_app "${app[r]}" && \
        [[ -d '/etc/R' ]]
    then
        dict[r_etc_target]='/etc/R'
        dict[sudo]=1
    else
        dict[r_etc_target]="${dict[r_prefix]}/etc"
    fi
    files=(
        'Renviron.site'
        'Rprofile.site'
        'repositories'
    )
    for file in "${files[@]}"
    do
        [[ -f "${dict[r_etc_source]}/${file}" ]] || continue
        if [[ "${dict[sudo]}" -eq 1 ]]
        then
            koopa_ln --sudo \
                "${dict[r_etc_source]}/${file}" \
                "${dict[r_etc_target]}/${file}"
        else
            koopa_sys_ln \
                "${dict[r_etc_source]}/${file}" \
                "${dict[r_etc_target]}/${file}"
        fi
    done
    return 0
}

koopa_r_link_site_library() {
    local app conf_args dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [r]="${1:?}"
    )
    [[ -x "${app[r]}" ]] || return 1
    declare -A dict=(
        [lib_source]="$(koopa_r_packages_prefix "${app[r]}")"
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
        [version]="$(koopa_r_version "${app[r]}")"
    )
    koopa_assert_is_dir "${dict[r_prefix]}"
    dict[lib_target]="${dict[r_prefix]}/site-library"
    koopa_alert "Linking '${dict[lib_target]}' to '${dict[lib_source]}'."
    koopa_sys_mkdir "${dict[lib_source]}"
    if koopa_is_koopa_app "${app[r]}"
    then
        koopa_sys_ln "${dict[lib_source]}" "${dict[lib_target]}"
    else
        koopa_ln --sudo "${dict[lib_source]}" "${dict[lib_target]}"
    fi
    conf_args=(
        '--name=r'
        "--prefix=${dict[lib_source]}"
    )
    if [[ "${dict[version]}" == 'devel' ]]
    then
        conf_args+=('--no-link-in-opt')
    fi
    koopa_configure_app_packages "${conf_args[@]}"
    if koopa_is_fedora && [[ -d '/usr/lib64/R' ]]
    then
        koopa_alert_note "Fixing configuration at '/usr/lib64/R'."
        koopa_mkdir --sudo '/usr/lib64/R/site-library'
        koopa_ln --sudo \
            '/usr/lib64/R/site-library' \
            '/usr/local/lib/R/site-library'
    fi
    return 0
}

koopa_r_package_version() {
    local app str vec
    koopa_assert_has_args "$#"
    declare -A app=(
        [rscript]="$(koopa_locate_rscript)"
    )
    [[ -x "${app[rscript]}" ]] || return 1
    pkgs=("$@")
    koopa_is_r_package_installed "${pkgs[@]}" || return 1
    vec="$(koopa_r_paste_to_vector "${pkgs[@]}")"
    str="$( \
        "${app[rscript]}" -e " \
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
    app[r]="${1:?}"
    declare -A dict
    dict[app_prefix]="$(koopa_app_prefix)"
    dict[name]='r-packages'
    dict[version]="$(koopa_r_version "${app[r]}")"
    if [[ "${dict[version]}" != 'devel' ]]
    then
        dict[version]="$(koopa_major_minor_version "${dict[version]}")"
    fi
    dict[str]="${dict[app_prefix]}/${dict[name]}/${dict[version]}"
    koopa_print "${dict[str]}"
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
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    [[ -x "${app[r]}" ]] || return 1
    app[rscript]="${app[r]}script"
    [[ -x "${app[rscript]}" ]] || return 1
    declare -A dict
    dict[prefix]="$( \
        "${app[rscript]}" \
            --vanilla \
            -e 'cat(normalizePath(Sys.getenv("R_HOME")))' \
        2>/dev/null \
    )"
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_print "${dict[prefix]}"
    return 0
}

koopa_r_rebuild_docs() {
    local app doc_dir html_dir pkg_index rscript_args
    declare -A app=(
        [r]="${1:?}"
    )
    koopa_assert_is_installed "${app[r]}"
    app[rscript]="${app[r]}script"
    koopa_assert_is_installed "${app[rscript]}"
    koopa_is_koopa_app "${app[rscript]}" || return 0
    declare -A dict
    koopa_alert 'Updating HTML package index.'
    rscript_args=('--vanilla')
    dict[doc_dir]="$( \
        "${app[rscript]}" "${rscript_args[@]}" -e 'cat(R.home("doc"))' \
    )"
    dict[html_dir]="${dict[doc_dir]}/html"
    dict[pkg_index]="${dict[html_dir]}/packages.html"
    dict[r_css]="${dict[html_dir]}/R.css"
    if [[ ! -d "${dict[html_dir]}" ]]
    then
        koopa_mkdir "${dict[html_dir]}"
    fi
    if [[ ! -f "${dict[pkg_index]}" ]]
    then
        koopa_touch "${dict[pkg_index]}"
    fi
    if [[ ! -f "${dict[r_css]}" ]]
    then
        koopa_touch "${dict[r_css]}"
    fi
    koopa_sys_set_permissions "${dict[pkg_index]}"
    "${app[rscript]}" "${rscript_args[@]}" -e 'utils::make.packages.html()'
    return 0
}

koopa_r_shiny_run_app() {
    local app dict
    declare -A app=(
        [r]="$(koopa_locate_r)"
    )
    [[ -x "${app[r]}" ]] || return 1
    declare -A dict=(
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="${PWD:?}"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    "${app[r]}" \
        --no-restore \
        --no-save \
        --quiet \
        -e "shiny::runApp('${dict[prefix]}')"
    return 0
}

koopa_r_system_library_prefix() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    [[ -x "${app[r]}" ]] || return 1
    app[rscript]="${app[r]}script"
    [[ -x "${app[rscript]}" ]] || return 1
    declare -A dict
    dict[prefix]="$( \
        "${app[rscript]}" \
            --vanilla \
            -e 'cat(normalizePath(tail(.libPaths(), n = 1L)))' \
    )"
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_print "${dict[prefix]}"
    return 0
}

koopa_r_version() {
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [head]="$(koopa_locate_head)"
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[r]}" ]] || return 1
    str="$( \
        "${app[r]}" --version 2>/dev/null \
        | "${app[head]}" -n 1 \
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
        [input]="${2:?}"
        [no]="$(koopa_print_red 'no')"
        [no_default]="$(koopa_print_red_bold 'NO')"
        [prompt]="${1:?}"
        [yes]="$(koopa_print_green 'yes')"
        [yes_default]="$(koopa_print_green_bold 'YES')"
    )
    case "${dict[input]}" in
        '0')
            dict[yn]="${dict[yes]}/${dict[no_default]}"
            ;;
        '1')
            dict[yn]="${dict[yes_default]}/${dict[no]}"
            ;;
        *)
            koopa_stop "Invalid choice: requires '0' or '1'."
            ;;
    esac
    koopa_print "${dict[prompt]}? [${dict[yn]}]: "
    return 0
}

koopa_read_yn() {
    local dict read_args
    koopa_assert_has_args_eq "$#" 2
    declare -A dict
    dict[prompt]="$(koopa_read_prompt_yn "$@")"
    dict[default]="$(koopa_int_to_yn "${2:?}")"
    read_args=(
        -e
        -i "${dict[default]}"
        -p "${dict[prompt]}"
        -r
    )
    read "${read_args[@]}" "dict[choice]"
    [[ -z "${dict[choice]}" ]] && dict[choice]="${dict[default]}"
    case "${dict[choice]}" in
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
            dict[int]=1
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
            dict[int]=0
            ;;
        *)
            koopa_stop "Invalid 'yes/no' choice: '${dict[choice]}'."
            ;;
    esac
    koopa_print "${dict[int]}"
    return 0
}

koopa_read() {
    local dict read_args
    koopa_assert_has_args_eq "$#" 2
    declare -A dict
    dict[default]="${2:?}"
    dict[prompt]="${1:?} [${dict[default]}]: "
    read_args=(
        -e
        -i "${dict[default]}"
        -p "${dict[prompt]}"
        -r
    )
    read "${read_args[@]}" "dict[choice]"
    [[ -z "${dict[choice]}" ]] && dict[choice]="${dict[default]}"
    koopa_print "${dict[choice]}"
    return 0
}

koopa_reinstall_app() {
    koopa_assert_has_args "$#"
    koopa_koopa install "$@" --reinstall
}

koopa_relink() {
    local app dict ln pos rm sudo
    declare -A app=(
        [ln]='koopa_ln'
        [rm]='koopa_rm'
    )
    declare -A dict=(
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict[sudo]=1
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
    ln=("${app[ln]}")
    rm=("${app[rm]}")
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        ln+=('--sudo')
        rm+=('--sudo')
    fi
    dict[source_file]="${1:?}"
    dict[dest_file]="${2:?}"
    [[ -e "${dict[source_file]}" ]] || return 0
    [[ -L "${dict[dest_file]}" ]] && return 0
    "${rm[@]}" "${dict[dest_file]}"
    "${ln[@]}" "${dict[source_file]}" "${dict[dest_file]}"
    return 0
}

koopa_reload_shell() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [shell]="$(koopa_locate_shell)"
    )
    [[ -x "${app[shell]}" ]] || return 1
    exec "${app[shell]}" -il
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
        [rename]="$(koopa_locate_rename)"
        [xargs]="$(koopa_locate_xargs)"
    )
    [[ -x "${app[rename]}" ]] || return 1
    [[ -x "${app[xargs]}" ]] || return 1
    declare -A dict=(
        [pattern]='y/A-Z/a-z/'
        [recursive]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--recursive')
                dict[recursive]=1
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
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        koopa_assert_has_args_le "$#" 1
        dict[prefix]="${1:-.}"
        koopa_assert_is_dir "${dict[prefix]}"
        koopa_find \
            --exclude='.*' \
            --min-depth=1 \
            --pattern='*[A-Z]*' \
            --prefix="${dict[prefix]}" \
            --print0 \
            --sort \
            --type='f' \
        | "${app[xargs]}" -0 -I {} \
            "${app[rename]}" \
                --force \
                --verbose \
                "${dict[pattern]}" \
                {}
        koopa_find \
            --exclude='.*' \
            --min-depth=1 \
            --pattern='*[A-Z]*' \
            --prefix="${dict[prefix]}" \
            --print0 \
            --type='d' \
        | "${app[xargs]}" -0 -I {} \
            "${app[rename]}" \
                --force \
                --verbose \
                "${dict[pattern]}" \
                {}
    else
        "${app[rename]}" \
            --force \
            --verbose \
            "${dict[pattern]}" \
            "$@"
    fi
    return 0
}

koopa_reset_permissions() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [chmod]="$(koopa_locate_chmod)"
        [xargs]="$(koopa_locate_xargs)"
    )
    [[ -x "${app[chmod]}" ]] || return 1
    [[ -x "${app[xargs]}" ]] || return 1
    declare -A dict=(
        [group]="$(koopa_group)"
        [prefix]="${1:?}"
        [user]="$(koopa_user)"
    )
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    koopa_chown --recursive "${dict[user]}:${dict[group]}" "${dict[prefix]}"
    koopa_find \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='d' \
    | "${app[xargs]}" -0 -I {} \
        "${app[chmod]}" 'u=rwx,g=rwx,o=rx' {}
    koopa_find \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='f' \
    | "${app[xargs]}" -0 -I {} \
        "${app[chmod]}" 'u=rw,g=rw,o=r' {}
    koopa_find \
        --pattern='*.sh' \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='f' \
    | "${app[xargs]}" -0 -I {} \
        "${app[chmod]}" 'u=rwx,g=rwx,o=rx' {}
    return 0
}

koopa_rg_sort() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [rg]="$(koopa_locate_rg)"
    )
    [[ -x "${app[rg]}" ]] || return 1
    declare -A dict=(
        [pattern]="${1:?}"
    )
    dict[str]="$( \
        "${app[rg]}" \
            --pretty \
            --sort 'path' \
            "${dict[pattern]}" \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

koopa_rg_unique() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [rg]="$(koopa_locate_rg)"
        [sort]="$(koopa_locate_sort)"
    )
    [[ -x "${app[rg]}" ]] || return 1
    [[ -x "${app[sort]}" ]] || return 1
    declare -A dict=(
        [pattern]="${1:?}"
    )
    dict[str]="$( \
        "${app[rg]}" \
            --no-filename \
            --no-line-number \
            --only-matching \
            --sort 'none' \
            "${dict[pattern]}" \
        | "${app[sort]}" --unique \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

koopa_rm() {
    local app dict pos rm rm_args
    declare -A app=(
        [rm]="$(koopa_locate_rm)"
    )
    [[ -x "${app[rm]}" ]] || return 1
    declare -A dict=(
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict[sudo]=1
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
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        [[ -x "${app[sudo]}" ]] || return 1
        rm+=("${app[sudo]}" "${app[rm]}")
    else
        rm=("${app[rm]}")
    fi
    "${rm[@]}" "${rm_args[@]}" "$@"
    return 0
}

koopa_rnaeditingindexer() {
    local app dict run_args
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    [[ -x "${app[docker]}" ]] || return 1
    declare -A dict=(
        [bam_suffix]='.Aligned.sortedByCoord.out.bam'
        [docker_image]='acidgenomics/rnaeditingindexer'
        [example]=0
        [genome]='hg38'
        [local_bam_dir]='bam'
        [local_output_dir]='rnaedit'
        [mnt_bam_dir]='/mnt/bam'
        [mnt_output_dir]='/mnt/output'
    )
    while (("$#"))
    do
        case "$1" in
            '--bam-dir='*)
                dict[local_bam_dir]="${1#*=}"
                shift 1
                ;;
            '--bam-dir')
                dict[local_bam_dir]="${2:?}"
                shift 2
                ;;
            '--genome='*)
                dict[genome]="${1#*=}"
                shift 1
                ;;
            '--genome')
                dict[genome]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[local_output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[local_output_dir]="${2:?}"
                shift 2
                ;;
            '--example')
                dict[example]=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    run_args=()
    if [[ "${dict[example]}" -eq 1 ]]
    then
        dict[bam_suffix]="_sampled_with_0.1.Aligned.sortedByCoord.out.\
bam.AluChr1Only.bam"
        dict[local_bam_dir]=''
        dict[mnt_bam_dir]='/bin/AEI/RNAEditingIndexer/TestResources/BAMs'
    else
        koopa_assert_is_dir "${dict[local_bam_dir]}"
        dict[local_bam_dir]="$(koopa_realpath "${dict[local_bam_dir]}")"
        koopa_rm "${dict[local_output_dir]}"
        dict[local_output_dir]="$(koopa_init_dir "${dict[local_output_dir]}")"
        run_args+=(
            -v "${dict[local_bam_dir]}:${dict[mnt_bam_dir]}:ro"
            -v "${dict[local_output_dir]}:${dict[mnt_output_dir]}:rw"
        )
    fi
    run_args+=("${dict[docker_image]}")
    "${app[docker]}" run "${run_args[@]}" \
        RNAEditingIndex \
            --genome "${dict[genome]}" \
            --keep_cmpileup \
            --verbose \
            -d "${dict[mnt_bam_dir]}" \
            -f "${dict[bam_suffix]}" \
            -l "${dict[mnt_output_dir]}/logs" \
            -o "${dict[mnt_output_dir]}/cmpileups" \
            -os "${dict[mnt_output_dir]}/summary"
    return 0
}

koopa_roff() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [ronn]="$(koopa_locate_ronn)"
    )
    [[ -x "${app[ronn]}" ]] || return 1
    declare -A app=(
        [man_prefix]="$(koopa_man_prefix)"
    )
    (
        koopa_cd "${dict[man_prefix]}"
        "${app[ronn]}" --roff ./*'.ronn'
        koopa_mv --target-directory='man1' ./*'.1'
    )
    return 0
}

koopa_rsync_ignore() {
    local dict rsync_args
    koopa_assert_has_args "$#"
    declare -A dict=(
        [ignore_local]='.gitignore'
        [ignore_global]="${HOME}/.gitignore"
    )
    rsync_args=(
        '--archive'
        '--exclude=.*'
    )
    if [[ -f "${dict[ignore_local]}" ]]
    then
        rsync_args+=(
            "--filter=dir-merge,- ${dict[ignore_local]}"
        )
    fi
    if [[ -f "${dict[ignore_global]}" ]]
    then
        rsync_args+=("--filter=dir-merge,- ${dict[ignore_global]}")
    fi
    koopa_rsync "${rsync_args[@]}" "$@"
    return 0
}

koopa_rsync() {
    local app dict rsync_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [rsync]="$(koopa_locate_rsync)"
    )
    [[ -x "${app[rsync]}" ]] || return 1
    declare -A dict=(
        [source_dir]=''
        [target_dir]=''
    )
    rsync_args=(
        '--human-readable'
        '--one-file-system'
        '--progress'
        '--protect-args'
        '--recursive'
        '--stats'
        '--verbose'
    )
    if koopa_is_macos
    then
        rsync_args+=(
            '--iconv=utf-8,utf-8-mac'
        )
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
                dict[source_dir]="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict[source_dir]="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            '--archive' | \
            '--delete' | \
            '--delete-before' | \
            '--dry-run')
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
        '--source-dir' "${dict[source_dir]}" \
        '--target-dir' "${dict[target_dir]}"
    if [[ -d "${dict[source_dir]}" ]]
    then
        dict[source_dir]="$(koopa_realpath "${dict[source_dir]}")"
    fi
    if [[ -d "${dict[target_dir]}" ]]
    then
        dict[target_dir]="$(koopa_realpath "${dict[target_dir]}")"
    fi
    dict[source_dir]="$(koopa_strip_trailing_slash "${dict[source_dir]}")"
    dict[target_dir]="$(koopa_strip_trailing_slash "${dict[target_dir]}")"
    rsync_args+=("${dict[source_dir]}/" "${dict[target_dir]}/")
    "${app[rsync]}" "${rsync_args[@]}"
    return 0
}

koopa_ruby_api_version() {
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [ruby]="${1:-}"
    )
    [[ -z "${app[ruby]}" ]] && app[ruby]="$(koopa_locate_ruby)"
    [[ -x "${app[ruby]}" ]] || return 1
    str="$("${app[ruby]}" -e 'print Gem.ruby_api_version')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
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
        [head]="$(koopa_locate_head)"
        [jq]="$(koopa_locate_jq)"
        [salmon]="$(koopa_locate_salmon)"
    )
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[jq]}" ]] || return 1
    [[ -x "${app[salmon]}" ]] || return 1
    declare -A dict=(
        [fastq_r1_file]=''
        [fastq_r2_file]=''
        [index_dir]=''
        [lib_type]='A'
        [n]='400000'
        [threads]="$(koopa_cpu_count)"
        [tmp_dir]="$(koopa_tmp_dir)"
    )
    dict[output_dir]="${dict[tmp_dir]}/quant"
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict[fastq_r1_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict[fastq_r1_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict[fastq_r2_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict[fastq_r2_file]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict[fastq_r1_file]}" \
        '--index-dir' "${dict[index_dir]}"
    koopa_assert_is_file "${dict[fastq_r1_file]}"
    koopa_assert_is_dir "${dict[index_dir]}"
    quant_args=(
        "--index=${dict[index_dir]}"
        "--libType=${dict[lib_type]}"
        '--no-version-check'
        "--output=${dict[output_dir]}"
        '--quiet'
        '--skipQuant'
        "--threads=${dict[threads]}"
    )
    if [[ -n "${dict[fastq_r2_file]}" ]]
    then
        koopa_assert_is_file "${dict[fastq_r2_file]}"
        dict[mates1]="${dict[tmp_dir]}/mates1.fastq"
        dict[mates2]="${dict[tmp_dir]}/mates2.fastq"
        koopa_decompress --stdout "${dict[fastq_r1_file]}" \
            | "${app[head]}" -n "${dict[n]}" \
            > "${dict[mates1]}"
        koopa_decompress --stdout "${dict[fastq_r2_file]}" \
            | "${app[head]}" -n "${dict[n]}" \
            > "${dict[mates2]}"
        quant_args+=(
            "--mates1=${dict[mates1]}"
            "--mates2=${dict[mates2]}"
        )
    else
        dict[unmated_reads]="${dict[tmp_dir]}/reads.fastq"
        koopa_decompress --stdout "${dict[fastq_r1_file]}" \
            | "${app[head]}" -n "${dict[n]}" \
            > "${dict[unmated_reads]}"
        quant_args+=(
            "--unmatedReads=${dict[unmated_reads]}"
        )
    fi
    "${app[salmon]}" quant "${quant_args[@]}" &>/dev/null
    dict[json_file]="${dict[output_dir]}/lib_format_counts.json"
    koopa_assert_is_file "${dict[json_file]}"
    dict[lib_type]="$( \
        "${app[jq]}" --raw-output '.expected_format' "${dict[json_file]}" \
    )"
    koopa_print "${dict[lib_type]}"
    koopa_rm "${dict[tmp_dir]}"
    return 0
}

koopa_salmon_index() {
    local app dict index_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa_locate_salmon)"
    )
    [[ -x "${app[salmon]}" ]] || return 1
    declare -A dict=(
        [decoys]=1
        [fasta_pattern]='\.fa(sta)?'
        [gencode]=0
        [genome_fasta_file]=''
        [kmer_length]=31
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
        [transcriptome_fasta_file]=''
        [type]='puff'
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict[genome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict[genome_fasta_file]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict[transcriptome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict[transcriptome_fasta_file]="${2:?}"
                shift 2
                ;;
            '--decoys')
                dict[decoys]=1
                shift 1
                ;;
            '--gencode')
                dict[gencode]=1
                shift 1
                ;;
            '--no-decoys')
                dict[decoys]=0
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--output-dir' "${dict[output_dir]}" \
        '--transcriptome-fasta-file' "${dict[transcriptome_fasta_file]}"
    [[ "${dict[decoys]}" -eq 1 ]] && dict[mem_gb_cutoff]=30
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "salmon index requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_file "${dict[transcriptome_fasta_file]}"
    dict[transcriptome_fasta_file]="$( \
        koopa_realpath "${dict[transcriptome_fasta_file]}" \
    )"
    koopa_assert_is_matching_regex \
        --pattern="${dict[fasta_pattern]}" \
        --string="${dict[transcriptome_fasta_file]}"
    koopa_assert_is_not_dir "${dict[output_dir]}"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Generating salmon index at '${dict[output_dir]}'."
    if [[ "${dict[gencode]}" -eq 0 ]] && \
        koopa_str_detect_regex \
            --string="$(koopa_basename "${dict[transcriptome_fasta_file]}")" \
            --pattern='^gencode\.'
    then
        dict[gencode]=1
    fi
    if [[ "${dict[gencode]}" -eq 1 ]]
    then
        koopa_alert_info 'Indexing against GENCODE reference genome.'
        index_args+=('--gencode')
    fi
    if [[ "${dict[decoys]}" -eq 1 ]]
    then
        koopa_alert 'Preparing decoy-aware reference transcriptome.'
        koopa_assert_is_set \
            '--genome-fasta-file' "${dict[genome_fasta_file]}"
        koopa_assert_is_file "${dict[genome_fasta_file]}"
        dict[genome_fasta_file]="$(koopa_realpath "${dict[genome_fasta_file]}")"
        koopa_assert_is_matching_regex \
            --pattern="${dict[fasta_pattern]}" \
            --string="${dict[genome_fasta_file]}"
        koopa_assert_is_matching_regex \
            --pattern="${dict[fasta_pattern]}" \
            --string="${dict[transcriptome_fasta_file]}"
        dict[tmp_dir]="$(koopa_tmp_dir)"
        dict[decoys_file]="${dict[tmp_dir]}/decoys.txt"
        dict[gentrome_fasta_file]="${dict[tmp_dir]}/gentrome.fa.gz"
        koopa_fasta_generate_chromosomes_file \
            --genome-fasta-file="${dict[genome_fasta_file]}" \
            --output-file="${dict[decoys_file]}"
        koopa_assert_is_file "${dict[decoys_file]}"
        koopa_fasta_generate_decoy_transcriptome_file \
            --genome-fasta-file="${dict[genome_fasta_file]}" \
            --output-file="${dict[gentrome_fasta_file]}" \
            --transcriptome-fasta-file="${dict[transcriptome_fasta_file]}"
        koopa_assert_is_file "${dict[gentrome_fasta_file]}"
        index_args+=(
            "--decoys=${dict[decoys_file]}"
            "--transcripts=${dict[gentrome_fasta_file]}"
        )
    else
        index_args+=(
            "--transcripts=${dict[transcriptome_fasta_file]}"
        )
    fi
    index_args+=(
        "--index=${dict[output_dir]}"
        "--kmerLen=${dict[kmer_length]}"
        '--no-version-check'
        "--threads=${dict[threads]}"
        "--type=${dict[type]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app[salmon]}" index "${index_args[@]}"
    koopa_alert_success "salmon index created at '${dict[output_dir]}'."
    return 0
}

koopa_salmon_quant_paired_end_per_sample() {
    local app dict quant_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa_locate_salmon)"
    )
    [[ -x "${app[salmon]}" ]] || return 1
    declare -A dict=(
        [bootstraps]=30
        [fastq_r1_file]=''
        [fastq_r1_tail]=''
        [fastq_r2_file]=''
        [fastq_r2_tail]=''
        [index_dir]=''
        [lib_type]='A'
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
    )
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict[fastq_r1_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict[fastq_r1_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict[fastq_r2_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict[fastq_r2_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict[fastq_r1_file]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-file' "${dict[fastq_r2_file]}" \
        '--fastq-r2-tail' "${dict[fastq_r2_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "salmon quant requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    koopa_assert_is_file "${dict[fastq_r1_file]}" "${dict[fastq_r2_file]}"
    dict[fastq_r1_file]="$(koopa_realpath "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="$(koopa_basename "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[fastq_r1_tail]}/}"
    dict[fastq_r2_file]="$(koopa_realpath "${dict[fastq_r2_file]}")"
    dict[fastq_r2_bn]="$(koopa_basename "${dict[fastq_r2_file]}")"
    dict[fastq_r2_bn]="${dict[fastq_r2_bn]/${dict[fastq_r2_tail]}/}"
    koopa_assert_are_identical "${dict[fastq_r1_bn]}" "${dict[fastq_r2_bn]}"
    dict[id]="${dict[fastq_r1_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' in '${dict[output_dir]}'."
    quant_args+=(
        '--gcBias' # Recommended for DESeq2.
        "--index=${dict[index_dir]}"
        "--libType=${dict[lib_type]}"
        "--mates1=${dict[fastq_r1_file]}"
        "--mates2=${dict[fastq_r2_file]}"
        '--no-version-check'
        "--numBootstraps=${dict[bootstraps]}"
        "--output=${dict[output_dir]}"
        '--seqBias'
        "--threads=${dict[threads]}"
        '--useVBOpt'
    )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app[salmon]}" quant "${quant_args[@]}"
    return 0
}

koopa_salmon_quant_paired_end() {
    local dict fastq_r1_files fastq_r1_file fastq_r2_file
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_r1_tail]=''
        [fastq_r2_tail]=''
        [index_dir]=''
        [lib_type]='A'
        [mode]='paired-end'
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-tail' "${dict[fastq_r1_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running salmon quant.'
    koopa_dl \
        'Mode' "${dict[mode]}" \
        'Index dir' "${dict[index_dir]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ R1 tail' "${dict[fastq_r1_tail]}" \
        'FASTQ R2 tail' "${dict[fastq_r2_tail]}" \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_r1_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_r1_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        fastq_r2_file="${fastq_r1_file/\
${dict[fastq_r1_tail]}/${dict[fastq_r2_tail]}}"
        koopa_salmon_quant_paired_end_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict[fastq_r1_tail]}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict[fastq_r2_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'salmon quant was successful.'
    return 0
}

koopa_salmon_quant_single_end_per_sample() {
    local app dict quant_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa_locate_salmon)"
    )
    [[ -x "${app[salmon]}" ]] || return 1
    declare -A dict=(
        [bootstraps]=30
        [fastq_file]=''
        [fastq_tail]=''
        [index_dir]=''
        [lib_type]='A'
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
    )
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-file='*)
                dict[fastq_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict[fastq_file]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict[fastq_file]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "salmon quant requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    koopa_assert_is_file "${dict[fastq_file]}"
    dict[fastq_file]="$(koopa_realpath "${dict[fastq_file]}")"
    dict[fastq_bn]="$(koopa_basename "${dict[fastq_file]}")"
    dict[fastq_bn]="${dict[fastq_bn]/${dict[tail]}/}"
    dict[id]="${dict[fastq_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' in '${dict[output_dir]}'."
    quant_args+=(
        "--index=${dict[index_dir]}"
        "--libType=${dict[lib_type]}"
        "--numBootstraps=${dict[bootstraps]}"
        '--no-version-check'
        "--output=${dict[output_dir]}"
        '--seqBias'
        "--threads=${dict[threads]}"
        "--unmatedReads=${dict[fastq]}"
        '--useVBOpt'
    )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app[salmon]}" quant "${quant_args[@]}"
    return 0
}

koopa_salmon_quant_single_end() {
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_tail]=''
        [index_dir]=''
        [lib_type]='A'
        [mode]='single-end'
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running salmon quant.'
    koopa_dl \
        'Mode' "${dict[mode]}" \
        'Index dir' "${dict[index_dir]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ tail' "${dict[fastq_tail]}" \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_tail]}'."
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
            --fastq-tail="${dict[fastq_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'salmon quant was successful.'
    return 0
}

koopa_sambamba_filter_duplicates() {
    koopa_assert_has_args "$#"
    koopa_sambamba_filter --filter='not duplicate' "$@"
    return 0
}

koopa_sambamba_filter_multimappers() {
    koopa_assert_has_args "$#"
    koopa_sambamba_filter --filter='[XS] == null' "$@"
    return 0
}

koopa_sambamba_filter_unmapped() {
    koopa_assert_has_args "$#"
    koopa_sambamba_filter --filter='not unmapped' "$@"
    return 0
}

koopa_sambamba_filter() {
    local filter input_bam input_bam_bn output_bam output_bam_bn threads
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'sambamba'
    while (("$#"))
    do
        case "$1" in
            '--filter='*)
                filter="${1#*=}"
                shift 1
                ;;
            '--filter')
                filter="${2:?}"
                shift 2
                ;;
            '--input-bam='*)
                input_bam="${1#*=}"
                shift 1
                ;;
            '--input-bam')
                input_bam="${2:?}"
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
        '--filter' "$filter" \
        '--intput-bam' "$input_bam" \
        '--output-bam' "$output_bam"
    koopa_assert_are_not_identical "$input_bam" "$output_bam"
    input_bam_bn="$(koopa_basename "$input_bam")"
    output_bam_bn="$(koopa_basename "$output_bam")"
    if [[ -f "$output_bam" ]]
    then
        koopa_alert_note "Skipping '${output_bam_bn}'."
        return 0
    fi
    koopa_h2 "Filtering '${input_bam_bn}' to '${output_bam_bn}'."
    koopa_assert_is_file "$input_bam"
    koopa_dl 'Filter' "$filter"
    threads="$(koopa_cpu_count)"
    koopa_dl 'Threads' "$threads"
    sambamba view \
        --filter="$filter" \
        --format='bam' \
        --nthreads="$threads" \
        --output-filename="$output_bam" \
        --show-progress \
        --with-header \
        "$input_bam"
    return 0
}

koopa_sambamba_index() {
    local bam_file threads
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'samtools'
    threads="$(koopa_cpu_count)"
    koopa_dl 'Threads' "$threads"
    for bam_file in "$@"
    do
        koopa_alert "Indexing '${bam_file}'."
        koopa_assert_is_file "$bam_file"
        sambamba index \
            --nthreads="$threads" \
            --show-progress \
            "$bam_file"
    done
    return 0
}

koopa_sambamba_sort() {
    local sorted_bam sorted_bam_bn threads unsorted_bam unsorted_bam_bn
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'sambamba'
    unsorted_bam="${1:?}"
    sorted_bam="${unsorted_bam%.bam}.sorted.bam"
    unsorted_bam_bn="$(koopa_basename "$unsorted_bam")"
    sorted_bam_bn="$(koopa_basename "$sorted_bam")"
    if [[ -f "$sorted_bam" ]]
    then
        koopa_alert_note "Skipping '${sorted_bam_bn}'."
        return 0
    fi
    koopa_h2 "Sorting '${unsorted_bam_bn}' to '${sorted_bam_bn}'."
    koopa_assert_is_file "$unsorted_bam"
    threads="$(koopa_cpu_count)"
    koopa_dl 'Threads' "${threads}"
    sambamba sort \
        --memory-limit='2GB' \
        --nthreads="$threads" \
        --out="$sorted_bam" \
        --show-progress \
        "$unsorted_bam"
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
    "${app[samtools]}" view \
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
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    declare -A dict
    dict[file]="$( \
        caller \
        | "${app[head]}" -n 1 \
        | "${app[cut]}" -d ' ' -f '2' \
    )"
    dict[bn]="$(koopa_basename "${dict[file]}")"
    [[ -n "${dict[bn]}" ]] || return 0
    koopa_print "${dict[bn]}"
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
        [vim]="$(koopa_locate_vim)"
    )
    [[ -x "${app[vim]}" ]] || return 1
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app[vim]}" \
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
        [aspell]="$(koopa_locate_aspell)"
        [tail]="$(koopa_locate_tail)"
    )
    [[ -x "${app[aspell]}" ]] || return 1
    [[ -x "${app[tail]}" ]] || return 1
    koopa_print "$@" \
        | "${app[aspell]}" pipe \
        | "${app[tail]}" -n '+2'
    return 0
}

koopa_sra_download_accession_list() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [efetch]="$(koopa_locate_efetch)"
        [esearch]="$(koopa_locate_esearch)"
        [sed]="$(koopa_locate_sed)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[efetch]}" ]] || return 1
    [[ -x "${app[esearch]}" ]] || return 1
    [[ -x "${app[sed]}" ]] || return 1
    declare -A dict=(
        [acc_file]=''
        [srp_id]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict[acc_file]+=("${1#*=}")
                shift 1
                ;;
            '--file')
                dict[acc_file]+=("${2:?}")
                shift 2
                ;;
            '--srp-id='*)
                dict[srp_id]="${1#*=}"
                shift 1
                ;;
            '--srp-id')
                dict[srp_id]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--srp-id' "${dict[srp_id]}"
    if [[ -z "${dict[acc_file]}" ]]
    then
        dict[acc_file]="$(koopa_lowercase "${dict[srp_id]}")-\
accession-list.txt"
    fi
    koopa_alert "Downloading SRA accession list for '${dict[srp_id]}' \
to '${dict[acc_file]}'."
    "${app[esearch]}" -db 'sra' -query "${dict[srp_id]}" \
        | "${app[efetch]}" -format 'runinfo' \
        | "${app[sed]}" '1d' \
        | "${app[cut]}" -d ',' -f '1' \
        > "${dict[acc_file]}"
    return 0
}

koopa_sra_download_run_info_table() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [efetch]="$(koopa_locate_efetch)"
        [esearch]="$(koopa_locate_esearch)"
    )
    [[ -x "${app[efetch]}" ]] || return 1
    [[ -x "${app[esearch]}" ]] || return 1
    declare -A dict=(
        [run_info_file]=''
        [srp_id]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict[run_info_file]+=("${1#*=}")
                shift 1
                ;;
            '--file')
                dict[run_info_file]+=("${2:?}")
                shift 2
                ;;
            '--srp-id='*)
                dict[srp_id]="${1#*=}"
                shift 1
                ;;
            '--srp-id')
                dict[srp_id]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--srp-id' "${dict[srp_id]}"
    if [[ -z "${dict[run_info_file]}" ]]
    then
        dict[run_info_file]="$(koopa_lowercase "${dict[srp_id]}")-\
run-info-table.csv"
    fi
    koopa_alert "Downloading SRA run info table for '${dict[srp_id]}' \
to '${dict[run_info_file]}'."
    "${app[esearch]}" -db 'sra' -query "${dict[srp_id]}" \
        | "${app[efetch]}" -format 'runinfo' \
        > "${dict[run_info_file]}"
    return 0
}

koopa_sra_fastq_dump() {
    local app dict sra_file sra_files
    declare -A app=(
        [fasterq_dump]="$(koopa_locate_fasterq_dump)"
        [gzip]="$(koopa_locate_gzip)"
        [parallel]="$(koopa_locate_parallel)"
    )
    [[ -x "${app[fasterq_dump]}" ]] || return 1
    [[ -x "${app[gzip]}" ]] || return 1
    [[ -x "${app[parallel]}" ]] || return 1
    declare -A dict=(
        [acc_file]=''
        [compress]=1
        [fastq_dir]='fastq'
        [prefetch_dir]='sra'
        [threads]="$(koopa_cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            '--accession-file='*)
                dict[acc_file]="${1#*=}"
                shift 1
                ;;
            '--accession-file')
                dict[acc_file]="${2:?}"
                shift 2
                ;;
            '--fastq-directory='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-directory')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--prefetch-directory='*)
                dict[prefetch_dir]="${1#*=}"
                shift 1
                ;;
            '--prefetch-directory')
                dict[prefetch_dir]="${2:?}"
                shift 2
                ;;
            '--compress')
                dict[compress]=1
                shift 1
                ;;
            '--no-compress')
                dict[compress]=0
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set \
        '--accession-file' "${dict[acc_file]}" \
        '--fastq-directory' "${dict[fastq_dir]}" \
        '--prefetch-directory' "${dict[prefetch_dir]}"
    koopa_assert_is_file "${dict[acc_file]}"
    if [[ ! -d "${dict[prefetch_dir]}" ]]
    then
        koopa_sra_prefetch_parallel \
            --accession-file="${acc_file}" \
            --output-directory="${dict[prefetch_dir]}"
    fi
    koopa_assert_is_dir "${dict[prefetch_dir]}"
    koopa_alert "Extracting FASTQ to '${dict[fastq_dir]}'."
    readarray -t sra_files <<< "$(
        koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --pattern='*.sra' \
            --prefix="${dict[prefetch_dir]}" \
            --sort \
            --type='f' \
    )"
    koopa_assert_is_array_non_empty "${sra_files[@]:-}"
    for sra_file in "${sra_files[@]}"
    do
        local id
        id="$(koopa_basename_sans_ext "$sra_file")"
        if [[ ! -f "${dict[fastq_dir]}/${id}.fastq" ]] && \
            [[ ! -f "${dict[fastq_dir]}/${id}_1.fastq" ]] && \
            [[ ! -f "${dict[fastq_dir]}/${id}.fastq.gz" ]] && \
            [[ ! -f "${dict[fastq_dir]}/${id}_1.fastq.gz" ]]
        then
            koopa_alert "Extracting FASTQ in '${sra_file}'."
            "${app[fasterq_dump]}" \
                --details \
                --force \
                --outdir "${dict[fastq_dir]}" \
                --print-read-nr \
                --progress \
                --skip-technical \
                --split-3 \
                --strict \
                --threads "${dict[threads]}" \
                --verbose \
                "$sra_file"
        fi
    done
    if [[ "${dict[compress]}" -eq 1 ]]
    then
        koopa_alert 'Compressing FASTQ files.'
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.fastq' \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
        | "${app[parallel]}" \
            --bar \
            --eta \
            --jobs "${dict[threads]}" \
            --progress \
            --will-cite \
            "${app[gzip]} --force --verbose {}"
    fi
    return 0
}

koopa_sra_prefetch() {
    local app cmd dict
    declare -A app=(
        [parallel]="$(koopa_locate_parallel)"
        [prefetch]="$(koopa_locate_prefetch)"
    )
    [[ -x "${app[parallel]}" ]] || return 1
    [[ -x "${app[prefetch]}" ]] || return 1
    declare -A dict=(
        [acc_file]=''
        [jobs]="$(koopa_cpu_count)"
        [output_dir]='sra'
    )
    while (("$#"))
    do
        case "$1" in
            '--accession-file='*)
                dict[acc_file]="${1#*=}"
                shift 1
                ;;
            '--accession-file')
                dict[acc_file]="${2:?}"
                shift 2
                ;;
            '--output-directory='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-directory')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set \
        '--accession-file' "${dict[acc_file]}" \
        '--output-directory' "${dict[output_dir]}"
    koopa_assert_is_file "${dict[acc_file]}"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Prefetching SRA files to '${dict[output_dir]}'."
    cmd=(
        "${app[prefetch]}"
        '--force' 'no'
        '--output-directory' "${dict[output_dir]}"
        '--progress'
        '--resume' 'yes'
        '--type' 'sra'
        '--verbose'
        '--verify' 'yes'
        '{}'
    )
    "${app[parallel]}" \
        --arg-file "${dict[acc_file]}" \
        --bar \
        --eta \
        --jobs "${dict[jobs]}" \
        --progress \
        --will-cite \
        "${cmd[*]}"
    return 0
}

koopa_ssh_generate_key() {
    local app dict ssh_args
    declare -A app=(
        [ssh_keygen]="$(koopa_locate_ssh_keygen)"
    )
    [[ -x "${app[ssh_keygen]}" ]] || return 1
    declare -A dict=(
        [hostname]="$(koopa_hostname)"
        [key_name]='id_rsa' # or 'id_ed25519'.
        [prefix]="${HOME:?}/.ssh"
        [user]="$(koopa_user)"
    )
    while (("$#"))
    do
        case "$1" in
            '--key-name='*)
                dict[key_name]="${1#*=}"
                shift 1
                ;;
            '--key-name')
                dict[key_name]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    file="${dict[prefix]}/${dict[key_name]}"
    if [[ -f "${dict[file]}" ]]
    then
        koopa_alert_note "SSH key exists at '${dict[file]}'."
        return 0
    fi
    koopa_alert "Generating SSH key at '${dict[file]}'."
    ssh_args=(
        '-C' "${dict[user]}@${dict[hostname]}"
        '-N' ''
        '-f' "${dict[file]}"
        '-q'
    )
    case "${dict[key_name]}" in
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
            koopa_stop "Unsupported key: '${dict[key_name]}'."
            ;;
    esac
    koopa_dl \
        'ssh-keygen' "${app[ssh_keygen]}" \
        'args' "${ssh_args[*]}"
    "${app[ssh_keygen]}" "${ssh_args[@]}"
    koopa_alert_success "Generated SSH key at '${dict[file]}'."
    return 0
}

koopa_ssh_key_info() {
    local app dict keyfile
    declare -A app=(
        [ssh_keygen]="$(koopa_locate_ssh_keygen)"
        [uniq]="$(koopa_locate_uniq)"
    )
    [[ -x "${app[ssh_keygen]}" ]] || return 1
    [[ -x "${app[uniq]}" ]] || return 1
    declare -A dict=(
        [prefix]="${HOME:?}/.ssh"
        [stem]='id_'
    )
    for keyfile in "${dict[prefix]}/${dict[stem]}"*
    do
        "${app[ssh_keygen]}" -l -f "$keyfile"
    done | "${app[uniq]}"
    return 0
}

koopa_star_align_paired_end_per_sample() {
    local align_args app dict
    declare -A app=(
        [star]="$(koopa_locate_star)"
    )
    [[ -x "${app[star]}" ]] || return 1
    declare -A dict=(
        [fastq_r1_file]=''
        [fastq_r1_tail]=''
        [fastq_r2_file]=''
        [fastq_r2_tail]=''
        [index_dir]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
    )
    align_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-r1-file='*)
                dict[fastq_r1_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict[fastq_r1_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict[fastq_r2_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict[fastq_r2_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict[fastq_r1_file]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-file' "${dict[fastq_r2_file]}" \
        '--fastq-r2-tail' "${dict[fastq_r2_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "STAR 'alignReads' mode requires ${dict[mem_gb_cutoff]} \
GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    koopa_assert_is_file "${dict[fastq_r1_file]}" "${dict[fastq_r2_file]}"
    dict[fastq_r1_file]="$(koopa_realpath "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="$(koopa_basename "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[fastq_r1_tail]}/}"
    dict[fastq_r2_file]="$(koopa_realpath "${dict[fastq_r2_file]}")"
    dict[fastq_r2_bn]="$(koopa_basename "${dict[fastq_r2_file]}")"
    dict[fastq_r2_bn]="${dict[fastq_r2_bn]/${dict[fastq_r2_tail]}/}"
    koopa_assert_are_identical "${dict[fastq_r1_bn]}" "${dict[fastq_r2_bn]}"
    dict[id]="${dict[fastq_r1_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' in '${dict[output_dir]}'."
    align_args+=(
        '--genomeDir' "${dict[index_dir]}"
        '--outFileNamePrefix' "${dict[output_dir]}/"
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--runMode' 'alignReads'
        '--runThreadN' "${dict[threads]}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app[star]}" "${align_args[@]}" \
        --readFilesIn \
            <(koopa_decompress --stdout "${dict[fastq_r1_file]}") \
            <(koopa_decompress --stdout "${dict[fastq_r2_file]}")
    return 0
}

koopa_star_align_paired_end() {
    local dict fastq_r1_files fastq_r1_file fastq_r2_file
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_r1_tail]=''
        [fastq_r2_tail]=''
        [index_dir]=''
        [mode]='paired-end'
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-tail' "${dict[fastq_r1_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running STAR aligner.'
    koopa_dl \
        'Mode' "${dict[mode]}" \
        'Index dir' "${dict[index_dir]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ R1 tail' "${dict[fastq_r1_tail]}" \
        'FASTQ R2 tail' "${dict[fastq_r2_tail]}" \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_r1_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_r1_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        fastq_r2_file="${fastq_r1_file/\
${dict[fastq_r1_tail]}/${dict[fastq_r2_tail]}}"
        koopa_star_align_paired_end_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict[fastq_r1_tail]}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict[fastq_r2_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'STAR alignment was successful.'
    return 0
}

koopa_star_align_single_end_per_sample() {
    local align_args app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [star]="$(koopa_locate_star)"
    )
    [[ -x "${app[star]}" ]] || return 1
    declare -A dict=(
        [fastq_file]=''
        [fastq_tail]=''
        [index_dir]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
    )
    align_args=()
    while (("$#"))
    do
        case "$1" in
            '--fastq-file='*)
                dict[fastq_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict[fastq_file]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict[fastq_file]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "STAR 'alignReads' mode requires ${dict[mem_gb_cutoff]} \
GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    koopa_assert_is_file "${dict[fastq_file]}"
    dict[fastq_file]="$(koopa_realpath "${dict[fastq_file]}")"
    dict[fastq_bn]="$(koopa_basename "${dict[fastq_file]}")"
    dict[fastq_bn]="${dict[fastq_bn]/${dict[tail]}/}"
    dict[id]="${dict[fastq_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' in '${dict[output_dir]}'."
    align_args+=(
        '--genomeDir' "${dict[index_dir]}"
        '--outFileNamePrefix' "${dict[output_dir]}/"
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--runMode' 'alignReads'
        '--runThreadN' "${dict[threads]}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app[star]}" "${align_args[@]}" \
        --readFilesIn \
            <(koopa_decompress --stdout "${dict[fastq_file]}")
    return 0
}

koopa_star_align_single_end() {
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_tail]=''
        [index_dir]=''
        [mode]='single-end'
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running STAR aligner.'
    koopa_dl \
        'Mode' "${dict[mode]}" \
        'Index dir' "${dict[index_dir]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ tail' "${dict[fastq_tail]}" \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_tail]}'."
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
            --fastq-tail="${dict[fastq_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'STAR alignment was successful.'
    return 0
}

koopa_star_index() {
    local app dict index_args
    declare -A app=(
        [star]="$(koopa_locate_star)"
    )
    [[ -x "${app[star]}" ]] || return 1
    declare -A dict=(
        [genome_fasta_file]=''
        [gtf_file]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=62
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
        [tmp_dir]="$(koopa_tmp_dir)"
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            '--genome-fasta-file='*)
                dict[genome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict[genome_fasta_file]="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict[gtf_file]="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict[gtf_file]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict[genome_fasta_file]}" \
        '--gtf-file' "${dict[gtf_file]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "STAR 'genomeGenerate' mode requires ${dict[mem_gb_cutoff]} \
GB of RAM."
    fi
    koopa_assert_is_file \
        "${dict[genome_fasta_file]}" \
        "${dict[gtf_file]}"
    koopa_assert_is_not_dir "${dict[output_dir]}"
    koopa_alert "Generating STAR index at '${dict[output_dir]}'."
    index_args+=(
        '--genomeDir' "${dict[output_dir]}/"
        '--runMode' 'genomeGenerate'
        '--runThreadN' "${dict[threads]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    (
        koopa_cd "${dict[tmp_dir]}"
        "${app[star]}" "${index_args[@]}" \
            --genomeFastaFiles \
                <(koopa_decompress --stdout "${dict[genome_fasta_file]}") \
            --sjdbGTFfile \
                <(koopa_decompress --stdout "${dict[gtf_file]}")
    )
    koopa_rm "${dict[tmp_dir]}"
    koopa_alert_success "STAR index created at '${dict[output_dir]}'."
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
        [date]="$(koopa_locate_date)"
    )
    [[ -x "${app[date]}" ]] || return 1
    declare -A dict=(
        [format]="${1:?}"
    )
    shift 1
    readarray -t timestamps <<< "$(koopa_stat '%Y' "$@")"
    for timestamp in "${timestamps[@]}"
    do
        x="$("${app[date]}" -d "@${timestamp}" +"${dict[format]}")"
        [[ -n "$x" ]] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_stat_user() {
    koopa_stat '%U' "$@"
}

koopa_stat() {
    local app dict
    koopa_assert_has_args_ge "$#" 2
    declare -A app=(
        [stat]="$(koopa_locate_stat)"
    )
    [[ -x "${app[stat]}" ]] || return 1
    declare -A dict=(
        [format]="${1:?}"
    )
    shift 1
    dict[out]="$("${app[stat]}" --format="${dict[format]}" "$@")"
    [[ -n "${dict[out]}" ]] || return 1
    koopa_print "${dict[out]}"
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
        [pattern]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
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
    koopa_assert_is_set '--pattern' "${dict[pattern]}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    for str in "$@"
    do
        printf '%s\n' "${str##"${dict[pattern]}"}"
    done
    return 0
}

koopa_strip_right() {
    local dict pos str
    declare -A dict=(
        [pattern]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
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
    koopa_assert_is_set '--pattern' "${dict[pattern]}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    for str in "$@"
    do
        printf '%s\n' "${str%%"${dict[pattern]}"}"
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
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    [[ -x "${app[perl]}" ]] || return 1
    declare -A dict=(
        [global]=0
        [pattern]=''
        [perl_tail]=''
        [regex]=0
        [replacement]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            '--replacement='*)
                dict[replacement]="${1#*=}"
                shift 1
                ;;
            '--replacement')
                dict[replacement]="${2:-}"
                shift 2
                ;;
            '--fixed')
                dict[regex]=0
                shift 1
                ;;
            '--global')
                dict[global]=1
                shift 1
                ;;
            '--regex')
                dict[regex]=1
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
    koopa_assert_is_set '--pattern' "${dict[pattern]}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    [[ "${dict[global]}" -eq 1 ]] && dict[perl_tail]='g'
    if [[ "${dict[regex]}" -eq 1 ]]
    then
        dict[expr]="s/${dict[pattern]}/${dict[replacement]}/${dict[perl_tail]}"
    else
        dict[expr]=" \
            \$pattern = quotemeta '${dict[pattern]}'; \
            \$replacement = '${dict[replacement]}'; \
            s/\$pattern/\$replacement/${dict[perl_tail]}; \
        "
    fi
    printf '%s' "$@" | \
        LANG=C "${app[perl]}" -p -e "${dict[expr]}"
    return 0
}

koopa_sudo_append_string() {
    local app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tee]="$(koopa_locate_tee)"
    )
    [[ -x "${app[sudo]}" ]] || return 1
    [[ -x "${app[tee]}" ]] || return 1
    declare -A dict=(
        [file]=''
        [string]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict[file]="${1#*=}"
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict[string]="${1#*=}"
                shift 1
                ;;
            '--string')
                dict[string]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--file' "${dict[file]}" \
        '--string' "${dict[string]}"
    if [[ ! -f "${dict[file]}" ]]
    then
        koopa_mkdir --sudo "$(koopa_dirname "${dict[file]}")"
        koopa_touch --sudo "${dict[file]}"
    fi
    koopa_print "${dict[string]}" \
        | "${app[sudo]}" "${app[tee]}" -a "${dict[file]}" >/dev/null
    return 0
}

koopa_sudo_write_string() {
    local app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tee]="$(koopa_locate_tee)"
    )
    [[ -x "${app[sudo]}" ]] || return 1
    [[ -x "${app[tee]}" ]] || return 1
    declare -A dict=(
        [file]=''
        [string]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict[file]="${1#*=}"
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict[string]="${1#*=}"
                shift 1
                ;;
            '--string')
                dict[string]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--file' "${dict[file]}" \
        '--string' "${dict[string]}"
    dict[parent_dir]="$(koopa_dirname "${dict[file]}")"
    if [[ ! -d "${dict[parent_dir]}" ]]
    then
        koopa_mkdir --sudo "${dict[parent_dir]}"
    fi
    koopa_print "${dict[string]}" \
        | "${app[sudo]}" "${app[tee]}" "${dict[file]}" >/dev/null
    return 0
}

koopa_switch_to_develop() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    [[ -x "${app[git]}" ]] || return 1
    declare -A dict=(
        [branch]='develop'
        [origin]='origin'
        [prefix]="$(koopa_koopa_prefix)"
    )
    koopa_alert "Switching koopa at '${dict[prefix]}' to '${dict[branch]}'."
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    (
        koopa_cd "${dict[prefix]}"
        "${app[git]}" remote set-branches \
            --add "${dict[origin]}" "${dict[branch]}"
        "${app[git]}" fetch "${dict[origin]}"
        "${app[git]}" checkout --track "${dict[origin]}/${dict[branch]}"
    )
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
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
        [source]="${1:?}"
        [target]="${2:?}"
    )
    koopa_rm "${dict[target]}"
    koopa_ln "${dict[source]}" "${dict[target]}"
    koopa_sys_set_permissions --no-dereference "${dict[target]}"
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
        [dereference]=1
        [recursive]=0
        [shared]=1
    )
    chmod_args=()
    chown_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--dereference' | \
            '-H')
                dict[dereference]=1
                shift 1
                ;;
            '--no-dereference' | \
            '-h')
                dict[dereference]=0
                shift 1
                ;;
            '--recursive' | \
            '-R' | \
            '-r')
                dict[recursive]=1
                shift 1
                ;;
            '--user' | \
            '-u')
                dict[shared]=0
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
    case "${dict[shared]}" in
        '0')
            dict[group]="$(koopa_group)"
            dict[user]="$(koopa_user)"
            ;;
        '1')
            dict[group]="$(koopa_sys_group)"
            dict[user]="$(koopa_sys_user)"
            ;;
    esac
    chown_args+=('--no-dereference')
    if [[ "${dict[recursive]}" -eq 1 ]]
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
    chown_args+=("${dict[user]}:${dict[group]}")
    for arg in "$@"
    do
        if [[ "${dict[dereference]}" -eq 1 ]] && [[ -L "$arg" ]]
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
        [bash]="$(koopa_locate_bash)"
        [cat]="$(koopa_locate_cat)"
    )
    [[ -x "${app[bash]}" ]] || return 1
    [[ -x "${app[cat]}" ]] || return 1
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [arch]="$(koopa_arch)"
        [arch2]="$(koopa_arch2)"
        [ascii_turtle_file]="$(koopa_include_prefix)/ascii-turtle.txt"
        [bash_version]="$(koopa_get_version "${app[bash]}")"
        [config_prefix]="$(koopa_config_prefix)"
        [koopa_date]="$(koopa_koopa_date)"
        [koopa_github_url]="$(koopa_koopa_github_url)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [koopa_url]="$(koopa_koopa_url)"
        [koopa_version]="$(koopa_koopa_version)"
        [make_prefix]="$(koopa_make_prefix)"
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    info=(
        "koopa ${dict[koopa_version]} (${dict[koopa_date]})"
        "URL: ${dict[koopa_url]}"
        "GitHub URL: ${dict[koopa_github_url]}"
    )
    if koopa_is_git_repo_top_level "${dict[koopa_prefix]}"
    then
        dict[remote]="$(koopa_git_remote_url "${dict[koopa_prefix]}")"
        dict[commit]="$(koopa_git_last_commit_local "${dict[koopa_prefix]}")"
        info+=(
            "Git Remote: ${dict[remote]}"
            "Git Commit: ${dict[commit]}"
        )
    fi
    info+=(
        ''
        'Configuration'
        '-------------'
        "Koopa Prefix: ${dict[koopa_prefix]}"
        "App Prefix: ${dict[app_prefix]}"
        "Opt Prefix: ${dict[opt_prefix]}"
        "Config Prefix: ${dict[config_prefix]}"
        "Make Prefix: ${dict[make_prefix]}"
    )
    if koopa_is_macos
    then
        app[sw_vers]="$(koopa_macos_locate_sw_vers)"
        dict[os]="$( \
            printf '%s %s (%s)\n' \
                "$("${app[sw_vers]}" -productName)" \
                "$("${app[sw_vers]}" -productVersion)" \
                "$("${app[sw_vers]}" -buildVersion)" \
        )"
    else
        app[uname]="$(koopa_locate_uname)"
        [[ -x "${app[uname]}" ]] || return 1
        dict[os]="$("${app[uname]}" --all)"
    fi
    info+=(
        ''
        'System information'
        '------------------'
        "OS: ${dict[os]}"
        "Architecture: ${dict[arch]} / ${dict[arch2]}"
        "Bash: ${dict[bash_version]}"
    )
    if koopa_is_installed 'neofetch'
    then
        app[neofetch]="$(koopa_locate_neofetch)"
        [[ -x "${app[neofetch]}" ]] || return 1
        readarray -t nf_info <<< "$("${app[neofetch]}" --stdout)"
        info+=(
            ''
            'Neofetch'
            '--------'
            "${nf_info[@]:2}"
        )
    fi
    "${app[cat]}" "${dict[ascii_turtle_file]}"
    koopa_info_box "${info[@]}"
    return 0
}

koopa_tar_multiple_dirs() {
    local app dict dir dirs pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [tar]="$(koopa_locate_tar)"
    )
    [[ -x "${app[tar]}" ]] || return 1
    declare -A dict=(
        [delete]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--delete')
                dict[delete]=1
                shift 1
                ;;
            '--no-delete' | \
            '--keep')
                dict[delete]=0
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
            "${app[tar]}" -czf "${bn}.tar.gz" "${bn}/"
            [[ "${dict[delete]}" -eq 1 ]] && koopa_rm "$dir"
        done
    )
    return 0
}

koopa_test_find_files_by_ext() {
    local all_files dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [ext]="${1:?}"
    )
    dict[pattern]="\.${dict[ext]}$"
    readarray -t all_files <<< "$(koopa_test_find_files)"
    dict[files]="$( \
        koopa_print "${all_files[@]}" \
        | koopa_grep \
            --pattern="${dict[pattern]}" \
            --regex \
        || true \
    )"
    if [[ -z "${dict[files]}" ]]
    then
        koopa_stop "Failed to find test files with extension '${dict[ext]}'."
    fi
    koopa_print "${dict[files]}"
    return 0
}

koopa_test_find_files_by_shebang() {
    local all_files app dict file shebang_files
    koopa_assert_has_args "$#"
    declare -A app=(
        [head]="$(koopa_locate_head)"
        [tr]="$(koopa_locate_tr)"
    )
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[tr]}" ]] || return 1
    declare -A dict=(
        [pattern]="${1:?}"
    )
    readarray -t all_files <<< "$(koopa_test_find_files)"
    shebang_files=()
    for file in "${all_files[@]}"
    do
        local shebang
        [[ -s "$file" ]] || continue
        shebang="$( \
            "${app[tr]}" --delete '\0' < "$file" \
                | "${app[head]}" -n 1 \
        )"
        [[ -n "$shebang" ]] || continue
        if koopa_str_detect_regex \
            --string="$shebang" \
            --pattern="${dict[pattern]}"
        then
            shebang_files+=("$file")
        fi
    done
    koopa_print "${shebang_files[@]}"
    return 0
}

koopa_test_find_files() {
    local dict files
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="$(koopa_koopa_prefix)"
    )
    readarray -t files <<< "$( \
        koopa_find \
            --exclude='**/etc/R/**' \
            --exclude='*.1' \
            --exclude='*.md' \
            --exclude='*.ronn' \
            --exclude='*.swp' \
            --exclude='.*' \
            --exclude='.git/**' \
            --exclude='app/**' \
            --exclude='coverage/**' \
            --exclude='etc/R/**' \
            --exclude='opt/**' \
            --exclude='tests/**' \
            --exclude='todo.org' \
            --prefix="${dict[prefix]}" \
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
    declare -A app=(
        [grep]="$(koopa_locate_grep)"
    )
    [[ -x "${app[grep]}" ]] || return 1
    declare -A dict=(
        [ignore]=''
        [name]=''
        [pattern]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--ignore='*)
                dict[ignore]="${1#*=}"
                shift 1
                ;;
            '--ignore' | \
            '-i')
                dict[ignore]="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name' | \
            '-n')
                dict[name]="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern' | \
            '-p')
                dict[pattern]="${2:?}"
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
        '--name' "${dict[name]}" \
        '--pattern' "${dict[pattern]}"
    failures=()
    for file in "$@"
    do
        local x
        if [[ -n "${dict[ignore]}" ]]
        then
            if "${app[grep]}" -Pq \
                --binary-files='without-match' \
                "^# koopa nolint=${dict[ignore]}$" \
                "$file"
            then
                continue
            fi
        fi
        x="$(
            "${app[grep]}" -HPn \
                --binary-files='without-match' \
                "${dict[pattern]}" \
                "$file" \
            || true \
        )"
        [[ -n "$x" ]] && failures+=("$x")
    done
    if [[ "${#failures[@]}" -gt 0 ]]
    then
        koopa_status_fail "${dict[name]} [${#failures[@]}]"
        printf '%s\n' "${failures[@]}"
        return 1
    fi
    koopa_status_ok "${dict[name]} [${#}]"
    return 0
}

koopa_test_true_color() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    "${app[awk]}" 'BEGIN{
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
        ./check-bin-man-consistency
    )
    return 0
}

koopa_tests_prefix() {
    koopa_print "$(koopa_koopa_prefix)/tests"
    return 0
}

koopa_tex_version() {
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [tex]="${1:-}"
    )
    [[ -z "${app[tex]}" ]] && app[tex]="$(koopa_locate_tex)"
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[tex]}" ]] || return 1
    str="$( \
        "${app[tex]}" --version \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d '(' -f '2' \
            | "${app[cut]}" -d ')' -f '1' \
            | "${app[cut]}" -d ' ' -f '3' \
            | "${app[cut]}" -d '/' -f '1' \
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
        [mkdir]='koopa_mkdir'
        [touch]="$(koopa_locate_touch)"
    )
    [[ -x "${app[touch]}" ]] || return 1
    declare -A dict=(
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--sudo' | \
            '-S')
                dict[sudo]=1
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
    mkdir=("${app[mkdir]}")
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        mkdir+=('--sudo')
        touch=("${app[sudo]}" "${app[touch]}")
    else
        touch=("${app[touch]}")
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
        --unlink-in-bin='ack' \
        "$@"
}

koopa_uninstall_anaconda() {
    koopa_uninstall_app \
        --name='anaconda' \
        "$@"
}

koopa_uninstall_app() {
    local bin_arr dict
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
        [mode]='shared'
        [name]=''
        [opt_prefix]="$(koopa_opt_prefix)"
        [platform]='common'
        [prefix]=''
        [quiet]=0
        [uninstaller_bn]=''
        [uninstaller_fun]='main'
        [unlink_in_bin]=0
        [unlink_in_make]=0
        [unlink_in_opt]=1
        [verbose]=0
    )
    bin_arr=()
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
            '--platform='*)
                dict[platform]="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict[platform]="${2:?}"
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
            '--uninstaller='*)
                dict[uninstaller_bn]="${1#*=}"
                shift 1
                ;;
            '--uninstaller')
                dict[uninstaller_bn]="${2:?}"
                shift 2
                ;;
            '--unlink-in-bin='*)
                bin_arr+=("${1#*=}")
                shift 1
                ;;
            '--unlink-in-bin')
                bin_arr+=("${2:?}")
                shift 2
                ;;
            '--no-unlink-in-opt')
                dict[unlink_in_opt]=0
                shift 1
                ;;
            '--quiet')
                dict[quiet]=1
                shift 1
                ;;
            '--system')
                dict[mode]='system'
                shift 1
                ;;
            '--unlink-in-make')
                dict[unlink_in_make]=1
                shift 1
                ;;
            '--user')
                dict[mode]='user'
                shift 1
                ;;
            '--verbose')
                dict[verbose]=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--name' "${dict[name]}"
    [[ "${dict[verbose]}" -eq 1 ]] && set -o xtrace
    case "${dict[mode]}" in
        'shared')
            dict[unlink_in_opt]=1
            if [[ -z "${dict[prefix]}" ]]
            then
                dict[prefix]="${dict[app_prefix]}/${dict[name]}"
            fi
            ;;
        'system')
            koopa_assert_is_admin
            dict[unlink_in_opt]=0
            ;;
        'user')
            dict[unlink_in_opt]=0
            ;;
    esac
    koopa_is_array_non_empty "${bin_arr[@]:-}" && dict[unlink_in_bin]=1
    if [[ -n "${dict[prefix]}" ]]
    then
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa_alert_is_not_installed "${dict[name]}" "${dict[prefix]}"
            return 1
        fi
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    fi
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_uninstall_start "${dict[name]}" "${dict[prefix]}"
        else
            koopa_alert_uninstall_start "${dict[name]}"
        fi
    fi
    [[ -z "${dict[uninstaller_bn]}" ]] && dict[uninstaller_bn]="${dict[name]}"
    dict[uninstaller_file]="${dict[installers_prefix]}/${dict[platform]}/\
${dict[mode]}/uninstall-${dict[uninstaller_bn]}.sh"
    if [[ -f "${dict[uninstaller_file]}" ]]
    then
        dict[tmp_dir]="$(koopa_tmp_dir)"
        (
            koopa_cd "${dict[tmp_dir]}"
            source "${dict[uninstaller_file]}"
            koopa_assert_is_function "${dict[uninstaller_fun]}"
            "${dict[uninstaller_fun]}"
        )
        koopa_rm "${dict[tmp_dir]}"
    fi
    if [[ -d "${dict[prefix]}" ]]
    then
        case "${dict[mode]}" in
            'system')
                koopa_rm --sudo "${dict[prefix]}"
                ;;
            *)
                koopa_rm "${dict[prefix]}"
                ;;
        esac
    fi
    if [[ "${dict[unlink_in_bin]}" -eq 1 ]]
    then
        koopa_unlink_in_bin "${bin_arr[@]}"
    fi
    if [[ "${dict[unlink_in_opt]}" -eq 1 ]]
    then
        koopa_unlink_in_opt "${dict[name]}"
    fi
    if [[ "${dict[unlink_in_make]}" -eq 1 ]]
    then
        koopa_unlink_in_make "${dict[prefix]}"
    fi
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_uninstall_success \
                "${dict[name]}" "${dict[prefix]}"
        else
            koopa_alert_uninstall_success "${dict[name]}"
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
        --unlink-in-bin='aspell' \
        "$@"
}

koopa_uninstall_autoconf() {
    koopa_uninstall_app \
        --name='autoconf' \
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
        --unlink-in-bin='aws' \
        "$@"
}

koopa_uninstall_azure_cli() {
    koopa_uninstall_app \
        --name='azure-cli' \
        --unlink-in-bin='az' \
        "$@"
}

koopa_uninstall_bash_language_server() {
    koopa_uninstall_app \
        --name='bash-language-server' \
        --unlink-in-bin='bash-language-server' \
        "$@"
}

koopa_uninstall_bash() {
    koopa_uninstall_app \
        --name='bash' \
        --unlink-in-bin='bash' \
        "$@"
}

koopa_uninstall_bashcov() {
    koopa_uninstall_app \
        --name='bashcov' \
        --unlink-in-bin='bashcov' \
        "$@"
}

koopa_uninstall_bat() {
    koopa_uninstall_app \
        --name='bat' \
        --unlink-in-bin='bat' \
        "$@"
}

koopa_uninstall_bc() {
    koopa_uninstall_app \
        --name='bc' \
        --unlink-in-bin='bc' \
        "$@"
}

koopa_uninstall_bedtools() {
    koopa_uninstall_app \
        --name='bedtools' \
        --unlink-in-bin='bedtools' \
        "$@"
}

koopa_uninstall_binutils() {
    koopa_uninstall_app \
        --name='binutils' \
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
        --unlink-in-bin='black' \
        "$@"
}

koopa_uninstall_boost() {
    koopa_uninstall_app \
        --name='boost' \
        "$@"
}

koopa_uninstall_bpytop() {
    koopa_uninstall_app \
        --name='bpytop' \
        --unlink-in-bin='bpytop' \
        "$@"
}

koopa_uninstall_broot() {
    koopa_uninstall_app \
        --name='broot' \
        --unlink-in-bin='broot' \
        "$@"
}

koopa_uninstall_bzip2() {
    koopa_uninstall_app \
        --name='bzip2' \
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

koopa_uninstall_chemacs() {
    koopa_uninstall_app \
        --name='chemacs' \
        "$@"
}

koopa_uninstall_chezmoi() {
    koopa_uninstall_app \
        --name='chezmoi' \
        --unlink-in-bin='chezmoi' \
        "$@"
}

koopa_uninstall_cmake() {
    koopa_uninstall_app \
        --name='cmake' \
        --unlink-in-bin='cmake' \
        "$@"
}

koopa_uninstall_colorls() {
    koopa_uninstall_app \
        --name='colorls' \
        --unlink-in-bin='colorls' \
        "$@"
}

koopa_uninstall_conda() {
    koopa_uninstall_app \
        --name='conda' \
        --unlink-in-bin='conda' \
        "$@"
}

koopa_uninstall_coreutils() {
    local uninstall_args
    uninstall_args=(
        '--name=coreutils'
        '--unlink-in-bin=['
        '--unlink-in-bin=b2sum'
        '--unlink-in-bin=base32'
        '--unlink-in-bin=base64'
        '--unlink-in-bin=basename'
        '--unlink-in-bin=basenc'
        '--unlink-in-bin=cat'
        '--unlink-in-bin=chcon'
        '--unlink-in-bin=chgrp'
        '--unlink-in-bin=chmod'
        '--unlink-in-bin=chown'
        '--unlink-in-bin=chroot'
        '--unlink-in-bin=cksum'
        '--unlink-in-bin=comm'
        '--unlink-in-bin=cp'
        '--unlink-in-bin=csplit'
        '--unlink-in-bin=cut'
        '--unlink-in-bin=date'
        '--unlink-in-bin=dd'
        '--unlink-in-bin=df'
        '--unlink-in-bin=dir'
        '--unlink-in-bin=dircolors'
        '--unlink-in-bin=dirname'
        '--unlink-in-bin=du'
        '--unlink-in-bin=echo'
        '--unlink-in-bin=env'
        '--unlink-in-bin=expand'
        '--unlink-in-bin=expr'
        '--unlink-in-bin=factor'
        '--unlink-in-bin=false'
        '--unlink-in-bin=fmt'
        '--unlink-in-bin=fold'
        '--unlink-in-bin=groups'
        '--unlink-in-bin=head'
        '--unlink-in-bin=hostid'
        '--unlink-in-bin=id'
        '--unlink-in-bin=install'
        '--unlink-in-bin=join'
        '--unlink-in-bin=kill'
        '--unlink-in-bin=link'
        '--unlink-in-bin=ln'
        '--unlink-in-bin=logname'
        '--unlink-in-bin=ls'
        '--unlink-in-bin=md5sum'
        '--unlink-in-bin=mkdir'
        '--unlink-in-bin=mkfifo'
        '--unlink-in-bin=mknod'
        '--unlink-in-bin=mktemp'
        '--unlink-in-bin=mv'
        '--unlink-in-bin=nice'
        '--unlink-in-bin=nl'
        '--unlink-in-bin=nohup'
        '--unlink-in-bin=nproc'
        '--unlink-in-bin=numfmt'
        '--unlink-in-bin=od'
        '--unlink-in-bin=paste'
        '--unlink-in-bin=pathchk'
        '--unlink-in-bin=pinky'
        '--unlink-in-bin=pr'
        '--unlink-in-bin=printenv'
        '--unlink-in-bin=printf'
        '--unlink-in-bin=ptx'
        '--unlink-in-bin=pwd'
        '--unlink-in-bin=readlink'
        '--unlink-in-bin=realpath'
        '--unlink-in-bin=rm'
        '--unlink-in-bin=rmdir'
        '--unlink-in-bin=runcon'
        '--unlink-in-bin=seq'
        '--unlink-in-bin=sha1sum'
        '--unlink-in-bin=sha224sum'
        '--unlink-in-bin=sha256sum'
        '--unlink-in-bin=sha384sum'
        '--unlink-in-bin=sha512sum'
        '--unlink-in-bin=shred'
        '--unlink-in-bin=shuf'
        '--unlink-in-bin=sleep'
        '--unlink-in-bin=sort'
        '--unlink-in-bin=split'
        '--unlink-in-bin=stat'
        '--unlink-in-bin=stty'
        '--unlink-in-bin=sum'
        '--unlink-in-bin=sync'
        '--unlink-in-bin=tac'
        '--unlink-in-bin=tail'
        '--unlink-in-bin=tee'
        '--unlink-in-bin=test'
        '--unlink-in-bin=timeout'
        '--unlink-in-bin=touch'
        '--unlink-in-bin=tr'
        '--unlink-in-bin=true'
        '--unlink-in-bin=truncate'
        '--unlink-in-bin=tsort'
        '--unlink-in-bin=tty'
        '--unlink-in-bin=uname'
        '--unlink-in-bin=unexpand'
        '--unlink-in-bin=uniq'
        '--unlink-in-bin=unlink'
        '--unlink-in-bin=uptime'
        '--unlink-in-bin=users'
        '--unlink-in-bin=vdir'
        '--unlink-in-bin=wc'
        '--unlink-in-bin=who'
        '--unlink-in-bin=whoami'
        '--unlink-in-bin=yes'
    )
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}

koopa_uninstall_cpufetch() {
    koopa_uninstall_app \
        --name='cpufetch' \
        --unlink-in-bin='cpufetch' \
        "$@"
}

koopa_uninstall_curl() {
    koopa_uninstall_app \
        --name='curl' \
        --unlink-in-bin='curl' \
        --unlink-in-bin='curl-config' \
        "$@"
}

koopa_uninstall_delta() {
    koopa_uninstall_app \
        --name='delta' \
        --unlink-in-bin='delta' \
        "$@"
}

koopa_uninstall_difftastic() {
    koopa_uninstall_app \
        --name='difftastic' \
        --unlink-in-bin='difft' \
        "$@"
}

koopa_uninstall_dog() {
    koopa_uninstall_app \
        --name='dog' \
        --unlink-in-bin='dog' \
        "$@"
}

koopa_uninstall_dotfiles() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
    )
    [[ -x "${app[bash]}" ]] || return 1
    declare -A dict=(
        [name]='dotfiles'
        [prefix]="$(koopa_dotfiles_prefix)"
    )
    dict[script]="${dict[prefix]}/uninstall"
    koopa_assert_is_file "${dict[script]}"
    "${app[bash]}" "${dict[script]}"
    koopa_uninstall_app \
        --name="${dict[name]}" \
        --prefix="${dict[prefix]}" \
        "$@"
    return 0
}

koopa_uninstall_du_dust() {
    koopa_uninstall_app \
        --name='du-dust' \
        --unlink-in-bin='dust' \
        "$@"
}

koopa_uninstall_emacs() {
    local uninstall_args
    uninstall_args=(
        '--name=emacs'
    )
    if ! koopa_is_macos
    then
        uninstall_args+=('--unlink-in-bin=emacs')
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}

koopa_uninstall_ensembl_perl_api() {
    koopa_uninstall_app \
        --name='ensembl-perl-api' \
        "$@"
}

koopa_uninstall_entrez_direct() {
    koopa_install_app \
        --name='entrez-direct' \
        --unlink-in-bin='efetch' \
        --unlink-in-bin='esearch' \
        "$@"
}

koopa_uninstall_exa() {
    koopa_uninstall_app \
        --name='exa' \
        --unlink-in-bin='exa' \
        "$@"
}

koopa_uninstall_exiftool() {
    koopa_uninstall_app \
        --name='exiftool' \
        --unlink-in-bin='exiftool' \
        "$@"
}

koopa_uninstall_expat() {
    koopa_uninstall_app \
        --name='expat' \
        "$@"
}

koopa_uninstall_fd_find() {
    koopa_uninstall_app \
        --unlink-in-bin='fd' \
        --name='fd-find' \
        "$@"
}

koopa_uninstall_ffmpeg() {
    koopa_uninstall_app \
        --name='ffmpeg' \
        --unlink-in-bin='ffmpeg' \
        --unlink-in-bin='ffprobe' \
        "$@"
}

koopa_uninstall_ffq() {
    koopa_uninstall_app \
        --name='ffq' \
        "$@"
}

koopa_uninstall_findutils() {
    local uninstall_args
    uninstall_args=(
        '--name=findutils'
        '--unlink-in-bin=find'
        '--unlink-in-bin=locate'
        '--unlink-in-bin=updatedb'
        '--unlink-in-bin=xargs'
    )
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}

koopa_uninstall_fish() {
    koopa_uninstall_app \
        --name='fish' \
        --unlink-in-bin='fish' \
        "$@"
}

koopa_uninstall_flac() {
    koopa_uninstall_app \
        --name='flac' \
        --unlink-in-bin='flac' \
        "$@"
}

koopa_uninstall_flake8() {
    koopa_uninstall_app \
        --name='flake8' \
        --unlink-in-bin='flake8' \
        "$@"
}

koopa_uninstall_fltk() {
    koopa_uninstall_app \
        --name='fltk' \
        "$@"
}

koopa_uninstall_fontconfig() {
    koopa_uninstall_app \
        --name='fontconfig' \
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
        --unlink-in-bin='fzf' \
        "$@"
}

koopa_uninstall_gawk() {
    koopa_uninstall_app \
        --name='gawk' \
        --unlink-in-bin='awk' \
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
        --unlink-in-bin='gdal-config' \
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
        --unlink-in-bin='geos-config' \
        "$@"
}

koopa_uninstall_gettext() {
    koopa_uninstall_app \
        --name='gettext' \
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
        --unlink-in-bin='gs' \
        "$@"
}

koopa_uninstall_git() {
    local uninstall_args
    uninstall_args=(
        '--name=git'
        '--unlink-in-bin=git'
    )
    if koopa_is_macos
    then
        uninstall_args+=(
            '--unlink-in-bin=git-credential-osxkeychain'
        )
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}

koopa_uninstall_glances() {
    koopa_uninstall_app \
        --name='glances' \
        --unlink-in-bin='glances' \
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
        --unlink-in-bin='go' \
        "$@"
}

koopa_uninstall_google_cloud_sdk() {
    koopa_uninstall_app \
        --name='google-cloud-sdk' \
        --unlink-in-bin='gcloud' \
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
        --unlink-in-bin='egrep' \
        --unlink-in-bin='fgrep' \
        --unlink-in-bin='grep' \
        "$@"
}

koopa_uninstall_groff() {
    koopa_uninstall_app \
        --name='groff' \
        --unlink-in-bin='groff' \
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
        --unlink-in-bin='gtop' \
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
        --unlink-in-bin='hadolint' \
        "$@"
}

koopa_uninstall_harfbuzz() {
    koopa_uninstall_app \
        --name='harfbuzz' \
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

koopa_uninstall_htop() {
    koopa_uninstall_app \
        --name='htop' \
        --unlink-in-bin='htop' \
        "$@"
}

koopa_uninstall_hyperfine() {
    koopa_uninstall_app \
        --name='hyperfine' \
        --unlink-in-bin='hyperfine' \
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
        --link-in-bin='magick' \
        "$@"
}

koopa_uninstall_ipython() {
    koopa_uninstall_app \
        --name='ipython' \
        --unlink-in-bin='ipython' \
        "$@"
}

koopa_uninstall_isort() {
    koopa_uninstall_app \
        --name='isort' \
        --unlink-in-bin='isort' \
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
        --unlink-in-bin='jq' \
        "$@"
}

koopa_uninstall_julia_packages() {
    koopa_uninstall_app \
        --name='julia-packages' \
        "$@"
}

koopa_uninstall_julia() {
    koopa_uninstall_app \
        --name='julia' \
        --unlink-in-bin='julia' \
        "$@"
}

koopa_uninstall_kallisto() {
    koopa_uninstall_app \
        --name='kallisto' \
        --unlink-in-bin='kallisto' \
        "$@"
}

koopa_uninstall_koopa() {
    local dict
    declare -A dict=(
        [config_prefix]="$(koopa_config_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    if koopa_is_linux && koopa_is_shared_install
    then
        koopa_rm --sudo '/etc/profile.d/zzz-koopa.sh'
    fi
    koopa_uninstall_dotfiles
    koopa_rm \
        "${dict[config_prefix]}" \
        "${dict[koopa_prefix]}"
    return 0
}

koopa_uninstall_lame() {
    koopa_uninstall_app \
        --name='lame' \
        --unlink-in-bin='lame' \
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
        --unlink-in-bin='latch' \
        "$@"
}

koopa_uninstall_less() {
    koopa_uninstall_app \
        --name='autoconf' \
        --unlink-in-bin='less' \
        "$@"
}

koopa_uninstall_lesspipe() {
    koopa_uninstall_app \
        --name='lesspipe' \
        --unlink-in-bin='lesspipe.sh' \
        "$@"
}

koopa_uninstall_libedit() {
    koopa_uninstall_app \
        --name='libedit' \
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

koopa_uninstall_libpipeline() {
    koopa_uninstall_app \
        --name='libpipeline' \
        "$@"
}

koopa_uninstall_libpng() {
    koopa_uninstall_app \
        --name='libpng' \
        --unlink-in-bin='libpng-config' \
        --unlink-in-bin='libpng16-config' \
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

koopa_uninstall_libtiff() {
    koopa_uninstall_app \
        --name='libtiff' \
        "$@"
}

koopa_uninstall_libtool() {
    koopa_uninstall_app \
        --name='libtool' \
        --unlink-in-bin='glibtool' \
        --unlink-in-bin='glibtoolize' \
        --unlink-in-bin='libtool' \
        --unlink-in-bin='libtoolize' \
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

koopa_uninstall_libxml2() {
    koopa_uninstall_app \
        --name='libxml2' \
        --unlink-in-bin='xml2-config' \
        "$@"
}

koopa_uninstall_libzip() {
    koopa_uninstall_app \
        --name='libzip' \
        "$@"
}

koopa_uninstall_lua() {
    koopa_uninstall_app \
        --name='lua' \
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
        --unlink-in-bin='make' \
        "$@"
}

koopa_uninstall_man_db() {
    koopa_uninstall_app \
        --name='man-db' \
        --unlink-in-bin='man' \
        "$@"
}

koopa_uninstall_mcfly() {
    koopa_uninstall_app \
        --name='mcfly' \
        --unlink-in-bin='mcfly' \
        "$@"
}

koopa_uninstall_mdcat() {
    koopa_uninstall_app \
        --name='mdcat' \
        --unlink-in-bin='mdcat' \
        "$@"
}

koopa_uninstall_meson() {
    koopa_uninstall_app \
        --name='meson' \
        "$@"
}

koopa_uninstall_mpc() {
    koopa_uninstall_app \
        --name='mpc' \
        "$@"
}

koopa_uninstall_mpfr() {
    koopa_uninstall_app \
        --name='mpfr' \
        "$@"
}

koopa_uninstall_ncurses() {
    koopa_uninstall_app \
        --name='ncurses' \
        --unlink-in-bin='captoinfo' \
        --unlink-in-bin='clear' \
        --unlink-in-bin='infocmp' \
        --unlink-in-bin='infotocap' \
        --unlink-in-bin='reset' \
        --unlink-in-bin='tabs' \
        --unlink-in-bin='tic' \
        --unlink-in-bin='toe' \
        --unlink-in-bin='tput' \
        --unlink-in-bin='tset' \
        "$@"
}

koopa_uninstall_neofetch() {
    koopa_uninstall_app \
        --name='neofetch' \
        --unlink-in-bin='neofetch' \
        "$@"
}

koopa_uninstall_neovim() {
    koopa_uninstall_app \
        --name='neovim' \
        --unlink-in-bin='nvim' \
        "$@"
}

koopa_uninstall_nettle() {
    koopa_uninstall_app \
        --name='nettle' \
        "$@"
}

koopa_uninstall_nim() {
    koopa_uninstall_app \
        --name='nim' \
        --unlink-in-bin='nim' \
        "$@"
}

koopa_uninstall_ninja() {
    koopa_uninstall_app \
        --name='ninja' \
        "$@"
}

koopa_uninstall_node_binary() {
    koopa_uninstall_app \
        --name='node' \
        --unlink-in-bin='node' \
        --unlink-in-bin='npm' \
        "$@"
}

koopa_uninstall_node() {
    koopa_uninstall_app \
        --name='node' \
        --unlink-in-bin='node' \
        --unlink-in-bin='npm' \
        "$@"
}

koopa_uninstall_oniguruma() {
    koopa_uninstall_app \
        --name='oniguruma' \
        "$@"
}

koopa_uninstall_openblas() {
    koopa_uninstall_app \
        --name='openblas' \
        "$@"
}

koopa_uninstall_openjdk() {
    local uninstall_args
    uninstall_args=(
        '--name=openjdk'
        '--unlink-in-bin=jar'
        '--unlink-in-bin=java'
        '--unlink-in-bin=javac'
    )
    if koopa_is_linux
    then
        uninstall_args+=('--platform=linux')
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
    return 0
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
        --unlink-in-bin='pandoc' \
        "$@"
}

koopa_uninstall_parallel() {
    koopa_uninstall_app \
        --name='parallel' \
        --unlink-in-bin='parallel' \
        "$@"
}

koopa_uninstall_password_store() {
    koopa_uninstall_app \
        --name='password-store' \
        --unlink-in-bin='pass' \
        "$@"
}

koopa_uninstall_patch() {
    koopa_uninstall_app \
        --name='patch' \
        --unlink-in-bin='patch' \
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
        --unlink-in-bin='perl' \
        "$@"
}

koopa_uninstall_pipx() {
    koopa_uninstall_app \
        --name='pipx' \
        --unlink-in-bin='pipx' \
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
        --unlink-in-bin='pkg-config' \
        "$@"
}

koopa_uninstall_poetry() {
    koopa_uninstall_app \
        --name='poetry' \
        --unlink-in-bin='poetry' \
        "$@"
}

koopa_uninstall_prettier() {
    koopa_uninstall_app \
        --name='prettier' \
        --unlink-in-bin='prettier' \
        "$@"
}

koopa_uninstall_procs() {
    koopa_uninstall_app \
        --name='procs' \
        --unlink-in-bin='procs' \
        "$@"
}

koopa_uninstall_proj() {
    koopa_uninstall_app \
        --name='proj' \
        "$@"
}

koopa_uninstall_pyenv() {
    koopa_uninstall_app \
        --name='pyenv' \
        --unlink-in-bin='pyenv' \
        "$@"
}

koopa_uninstall_pyflakes() {
    koopa_uninstall_app \
        --name='pyflakes' \
        --unlink-in-bin='pyflakes' \
        "$@"
}

koopa_uninstall_pygments() {
    koopa_uninstall_app \
        --name='pygments' \
        --unlink-in-bin='pygmentize' \
        "$@"
}

koopa_uninstall_pylint() {
    koopa_uninstall_app \
        --name='pylint' \
        --unlink-in-bin='pylint' \
        "$@"
}

koopa_uninstall_pytaglib() {
    koopa_uninstall_app \
        --name='pyprinttags' \
        --unlink-in-bin
        "$@"
}

koopa_uninstall_pytest() {
    koopa_uninstall_app \
        --name='pytest' \
        --unlink-in-bin='pytest' \
        "$@"
}

koopa_uninstall_python() {
    koopa_uninstall_app \
        --name='python' \
        --unlink-in-bin='python3' \
        "$@"
}

koopa_uninstall_r_devel() {
    koopa_uninstall_app \
        --name='r-devel' \
        --unlink-in-bin='R-devel' \
        "$@"
}

koopa_uninstall_r_packages() {
    koopa_uninstall_app \
        --name='r-packages' \
        "$@"
}

koopa_uninstall_r() {
    local uninstall_args
    uninstall_args=('--name=r')
    if koopa_is_linux && [[ ! -x '/usr/bin/R' ]]
    then
        uninstall_args+=(
            '--unlink-in-bin=R'
            '--unlink-in-bin=Rscript'
        )
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
    koopa_uninstall_r_packages
    return 0
}

koopa_uninstall_ranger_fm() {
    koopa_uninstall_app \
        --name='ranger-fm' \
        --unlink-in-bin='ranger' \
        "$@"
}

koopa_uninstall_rbenv() {
    koopa_uninstall_app \
        --name='rbenv' \
        --unlink-in-bin='rbenv' \
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
        --unlink-in-bin='rename' \
        "$@"
}

koopa_uninstall_ripgrep() {
    koopa_uninstall_app \
        --unlink-in-bin='rg' \
        --name='ripgrep' \
        "$@"
}

koopa_uninstall_rmate() {
    koopa_uninstall_app \
        --name='rmate' \
        --unlink-in-bin='rmate' \
        "$@"
}

koopa_uninstall_ronn() {
    koopa_uninstall_app \
        --name='ronn' \
        --unlink-in-bin='ronn' \
        "$@"
}

koopa_uninstall_rsync() {
    koopa_uninstall_app \
        --name='rsync' \
        --unlink-in-bin='rsync' \
        "$@"
}

koopa_uninstall_ruby() {
    koopa_uninstall_app \
        --name='ruby' \
        --unlink-in-bin='bundle' \
        --unlink-in-bin='bundler' \
        --unlink-in-bin='gem' \
        --unlink-in-bin='ruby' \
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
        --unlink-in-bin='salmon' \
        "$@"
}

koopa_uninstall_samtools() {
    koopa_uninstall_app \
        --name='samtools' \
        --unlink-in-bin='samtools' \
        "$@"
}

koopa_uninstall_scons() {
    koopa_uninstall_app \
        --name='scons' \
        "$@"
}

koopa_uninstall_sed() {
    koopa_uninstall_app \
        --name='sed' \
        --unlink-in-bin='sed' \
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
        --unlink-in-bin='shellcheck' \
        "$@"
}

koopa_uninstall_shunit2() {
    koopa_uninstall_app \
        --name='shunit2' \
        --unlink-in-bin='shunit2' \
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
        --unlink-in-bin='sox' \
        "$@"
}

koopa_uninstall_sqlite() {
    koopa_uninstall_app \
        --name='sqlite' \
        --unlink-in-bin='sqlite3' \
        "$@"
}

koopa_uninstall_sra_tools() {
    koopa_uninstall_app \
        --name='sra-tools' \
        --unlink-in-bin='fasterq-dump' \
        --unlink-in-bin='vdb-config' \
        "$@"
}

koopa_uninstall_star() {
    koopa_uninstall_app \
        --name='star' \
        --unlink-in-bin='STAR' \
        "$@"
}

koopa_uninstall_starship() {
    koopa_uninstall_app \
        --unlink-in-bin='starship' \
        --name='starship' \
        "$@"
}

koopa_uninstall_stow() {
    koopa_uninstall_app \
        --name='stow' \
        --unlink-in-bin='stow' \
        "$@"
}

koopa_uninstall_subversion() {
    koopa_uninstall_app \
        --name='subversion' \
        --unlink-in-bin='svn' \
        "$@"
}

koopa_uninstall_system_homebrew() {
    koopa_uninstall_app \
        --name='homebrew' \
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
        --unlink-in-bin='tar' \
        "$@"
}

koopa_uninstall_tcl_tk() {
    koopa_uninstall_app \
        --name='tcl-tk' \
        "$@"
}

koopa_uninstall_tealdeer() {
    koopa_uninstall_app \
        --unlink-in-bin='tldr' \
        --name='tealdeer' \
        "$@"
}

koopa_uninstall_texinfo() {
    koopa_uninstall_app \
        --name='texinfo' \
        --unlink-in-bin='pdftexi2dvi' \
        --unlink-in-bin='pod2texi' \
        --unlink-in-bin='texi2any' \
        --unlink-in-bin='texi2dvi' \
        --unlink-in-bin='texi2pdf' \
        --unlink-in-bin='texindex' \
        "$@"
}

koopa_uninstall_tmux() {
    koopa_uninstall_app \
        --name='tmux' \
        --unlink-in-bin='tmux' \
        "$@"
}

koopa_uninstall_tokei() {
    koopa_uninstall_app \
        --unlink-in-bin='tokei' \
        --name='tokei' \
        "$@"
}

koopa_uninstall_tree() {
    koopa_uninstall_app \
        --name='tree' \
        --unlink-in-bin='tree' \
        "$@"
}

koopa_uninstall_tuc() {
    koopa_uninstall_app \
        --unlink-in-bin='tuc' \
        --name='tuc' \
        "$@"
}

koopa_uninstall_udunits() {
    koopa_uninstall_app \
        --name='udunits' \
        --unlink-in-bin='udunits2' \
        "$@"
}

koopa_uninstall_units() {
    koopa_uninstall_app \
        --name='units' \
        --unlink-in-bin='units' \
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
        --unlink-in-bin='vim' \
        --unlink-in-bin='vimdiff' \
        "$@"
}

koopa_uninstall_wget() {
    koopa_uninstall_app \
        --name='wget' \
        --unlink-in-bin='wget' \
        "$@"
}

koopa_uninstall_which() {
    koopa_uninstall_app \
        --name='which' \
        --unlink-in-bin='which' \
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
        --unlink-in-bin='xsv' \
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
        --unlink-in-bin='xz' \
        "$@"
}

koopa_uninstall_yt_dlp() {
    koopa_uninstall_app \
        --name='yt-dlp' \
        --unlink-in-bin='yt-dlp' \
        "$@"
}

koopa_uninstall_zellij() {
    koopa_uninstall_app \
        --unlink-in-bin='zellij' \
        --name='zellij' \
        "$@"
}

koopa_uninstall_zlib() {
    koopa_uninstall_app \
        --name='zlib' \
        "$@"
}

koopa_uninstall_zoxide() {
    koopa_uninstall_app \
        --unlink-in-bin='zoxide' \
        --name='zoxide' \
        "$@"
}

koopa_uninstall_zsh() {
    koopa_uninstall_app \
        --name='zsh' \
        --unlink-in-bin='zsh' \
        "$@"
}

koopa_uninstall_zstd() {
    koopa_uninstall_app \
        --name='zstd' \
        "$@"
}

koopa_unlink_in_bin() {
    __koopa_unlink_in_dir --prefix="$(koopa_bin_prefix)" "$@"
}

koopa_unlink_in_make() {
    local app_prefix dict files
    koopa_assert_has_args "$#"
    declare -A dict=(
        [app_prefix]=''
        [make_prefix]="$(koopa_make_prefix)"
    )
    koopa_assert_is_dir "${dict[make_prefix]}"
    for app_prefix in "$@"
    do
        dict[app_prefix]="$app_prefix"
        koopa_assert_is_dir "${dict[app_prefix]}"
        dict[app_prefix]="$(koopa_realpath "${dict[app_prefix]}")"
        readarray -t files <<< "$( \
            koopa_find_symlinks \
                --source-prefix="${dict[app_prefix]}" \
                --target-prefix="${dict[make_prefix]}" \
                --verbose \
        )"
        if koopa_is_array_empty "${files[@]:-}"
        then
            koopa_stop "No files from '${dict[app_prefix]}' detected."
        fi
        koopa_alert "$(koopa_ngettext \
            --prefix='Unlinking ' \
            --num="${#files[@]}" \
            --msg1='file' \
            --msg2='files' \
            --suffix=" from '${dict[app_prefix]}' in '${dict[make_prefix]}'." \
        )"
        for file in "${files[@]}"
        do
            koopa_rm "$file"
        done
    done
    return 0
}

koopa_unlink_in_opt() {
    __koopa_unlink_in_dir --prefix="$(koopa_opt_prefix)" "$@"
}

koopa_unlink_in_sbin() {
    __koopa_unlink_in_dir --prefix="$(koopa_sbin_prefix)" "$@"
}

koopa_update_app() {
    local clean_path_arr dict opt_arr
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A dict=(
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [mode]='shared'
        [name]=''
        [opt_prefix]="$(koopa_opt_prefix)"
        [platform]='common'
        [prefix]=''
        [quiet]=0
        [set_permissions]=1
        [tmp_dir]="$(koopa_tmp_dir)"
        [update_ldconfig]=0
        [updater_bn]=''
        [updater_fun]='main'
        [verbose]=0
        [version]=''
    )
    clean_path_arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    opt_arr=()
    while (("$#"))
    do
        case "$1" in
            '--activate-opt='*)
                opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--activate-opt')
                opt_arr+=("${2:?}")
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
            '--platform='*)
                dict[platform]="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict[platform]="${2:?}"
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
            '--updater='*)
                dict[updater_bn]="${1#*=}"
                shift 1
                ;;
            '--updater')
                dict[updater_bn]="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict[version]="${1#*=}"
                shift 1
                ;;
            '--version')
                dict[version]="${2:?}"
                shift 2
                ;;
            '--no-set-permissions')
                dict[set_permissions]=0
                shift 1
                ;;
            '--quiet')
                dict[quiet]=1
                shift 1
                ;;
            '--system')
                dict[mode]='system'
                shift 1
                ;;
            '--user')
                dict[mode]='user'
                shift 1
                ;;
            '--verbose')
                dict[verbose]=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--name' "${dict[name]}"
    [[ "${dict[verbose]}" -eq 1 ]] && set -o xtrace
    case "${dict[mode]}" in
        'shared')
            if [[ -z "${dict[prefix]}" ]]
            then
                dict[prefix]="${dict[opt_prefix]}/${dict[name]}"
            fi
            ;;
        'system')
            koopa_assert_is_admin
            koopa_is_linux && dict[update_ldconfig]=1
            ;;
    esac
    if [[ -n "${dict[prefix]}" ]]
    then
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa_alert_is_not_installed "${dict[name]}" "${dict[prefix]}"
            return 1
        fi
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    fi
    [[ -z "${dict[updater_bn]}" ]] && dict[updater_bn]="${dict[name]}"
    dict[updater_file]="${dict[installers_prefix]}/${dict[platform]}/\
${dict[mode]}/update-${dict[updater_bn]}.sh"
    koopa_assert_is_file "${dict[updater_file]}"
    source "${dict[updater_file]}"
    koopa_assert_is_function "${dict[updater_fun]}"
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_update_start "${dict[name]}" "${dict[prefix]}"
        else
            koopa_alert_update_start "${dict[name]}"
        fi
    fi
    (
        koopa_cd "${dict[tmp_dir]}"
        unset -v \
            CFLAGS \
            CPPFLAGS \
            LDFLAGS \
            LDLIBS \
            LD_LIBRARY_PATH \
            PKG_CONFIG_PATH
        PATH="$(koopa_paste --sep=':' "${clean_path_arr[@]}")"
        export PATH
        if koopa_is_linux && \
            [[ -x '/usr/bin/pkg-config' ]]
        then
            koopa_add_to_pkg_config_path_2 \
                '/usr/bin/pkg-config'
        fi
        if koopa_is_array_non_empty "${opt_arr[@]:-}"
        then
            koopa_activate_opt_prefix "${opt_arr[@]}"
        fi
        if [[ "${dict[update_ldconfig]}" -eq 1 ]]
        then
            koopa_linux_update_ldconfig
        fi
        export UPDATE_PREFIX="${dict[prefix]}"
        "${dict[updater_fun]}"
    )
    koopa_rm "${dict[tmp_dir]}"
    if [[ -d "${dict[prefix]}" ]] && \
        [[ "${dict[set_permissions]}" -eq 1 ]]
    then
        case "${dict[mode]}" in
            'shared')
                koopa_sys_set_permissions \
                    --recursive "${dict[prefix]}"
                ;;
        esac
    fi
    if [[ "${dict[update_ldconfig]}" -eq 1 ]]
    then
        koopa_linux_update_ldconfig
    fi
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_update_success "${dict[name]}" "${dict[prefix]}"
        else
            koopa_alert_update_success "${dict[name]}"
        fi
    fi
    return 0
}

koopa_update_koopa() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="$(koopa_koopa_prefix)"
        [user]="$(koopa_user)"
    )
    if ! koopa_is_git_repo_top_level "${dict[prefix]}"
    then
        koopa_alert_note "Pinned release detected at '${dict[prefix]}'."
        return 1
    fi
    if koopa_is_shared_install
    then
        koopa_chown --recursive --sudo "${dict[user]}" "${dict[prefix]}"
    fi
    koopa_git_pull "${dict[prefix]}"
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    koopa_fix_zsh_permissions
    return 0
}

koopa_update_r_packages() {
    koopa_update_app \
        --name='r-packages' \
        "$@"
}

koopa_update_system_homebrew() {
    koopa_update_app \
        --name='homebrew' \
        --prefix="$(koopa_homebrew_prefix)" \
        --system \
        "$@"
}

koopa_update_system_tex_packages() {
    koopa_update_app \
        --name='tex-packages' \
        --system \
        "$@"
}

koopa_update_user_doom_emacs() {
    koopa_update_app \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}

koopa_update_user_prelude_emacs() {
    koopa_update_app \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        --user \
        "$@"
}

koopa_update_user_spacemacs() {
    koopa_update_app \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        --user \
        "$@"
}

koopa_update_user_spacevim() {
    koopa_update_app \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --user \
        "$@"
}

koopa_variable() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    declare -A dict=(
        [key]="${1:?}"
        [include_prefix]="$(koopa_include_prefix)"
    )
    dict[file]="${dict[include_prefix]}/variables.txt"
    koopa_assert_is_file "${dict[file]}"
    dict[str]="$( \
        koopa_grep \
            --file="${dict[file]}" \
            --only-matching \
            --pattern="^${dict[key]}=\"[^\"]+\"" \
            --regex \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    dict[str]="$( \
        koopa_print "${dict[str]}" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d '"' -f '2' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

koopa_variables() {
    koopa_assert_has_no_args "$#"
    "${EDITOR:?}" "$(koopa_include_prefix)/variables.txt"
    return 0
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
        [tail]="$(koopa_locate_tail)"
    )
    [[ -x "${app[tail]}" ]] || return 1
    declare -A dict=(
        [tmp_dir]="${TMPDIR:-/tmp}"
        [user_id]="$(koopa_user_id)"
    )
    dict[log_file]="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="koopa-${dict[user_id]}-*" \
            --prefix="${dict[tmp_dir]}" \
            --sort \
            --type='f' \
        | "${app[tail]}" -n 1 \
    )"
    if [[ ! -f "${dict[log_file]}" ]]
    then
        koopa_stop "No koopa log file detected in '${dict[tmp_dir]}'."
    fi
    koopa_alert "Viewing '${dict[log_file]}'."
    koopa_pager +G "${dict[log_file]}"
    return 0
}

koopa_vim_version() {
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [vim]="${1:-}"
    )
    [[ -z "${app[vim]}" ]] && app[vim]="$(koopa_locate_vim)"
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[vim]}" ]] || return 1
    declare -A dict=(
        [str]="$("${app[vim]}" --version 2>/dev/null)"
    )
    dict[maj_min]="$( \
        koopa_print "${dict[str]}" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '5' \
    )"
    dict[out]="${dict[maj_min]}"
    if koopa_str_detect_fixed \
        --string="${dict[str]}" \
        --pattern='Included patches:'
    then
        dict[patch]="$( \
            koopa_print "${dict[str]}" \
                | koopa_grep --pattern='Included patches:' \
                | "${app[cut]}" -d '-' -f '2' \
                | "${app[cut]}" -d ',' -f '1' \
        )"
        dict[out]="${dict[out]}.${dict[patch]}"
    fi
    koopa_print "${dict[out]}"
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
        [wget]="$(koopa_locate_wget)"
    )
    [[ -x "${app[wget]}" ]] || return 1
    declare -A dict=(
        [datetime]="$(koopa_datetime)"
        [password]=''
        [url]=''
        [user]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--password='*)
                dict[password]="${1#*=}"
                shift 1
                ;;
            '--password')
                dict[password]="${2:?}"
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
            '--user='*)
                dict[user]="${1#*=}"
                shift 1
                ;;
            '--user')
                dict[user]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--password' "${dict[password]}" \
        '--url' "${dict[url]}" \
        '--user' "${dict[user]}"
    dict[log_file]="wget-${dict[datetime]}.log"
    dict[password]="${dict[password]@Q}"
    wget_args=(
        "--output-file=${dict[log_file]}"
        "--password=${dict[password]}"
        "--user=${dict[user]}"
        '--continue'
        '--debug'
        '--no-parent'
        '--recursive'
        "${dict[url]}"/*
    )
    "${app[wget]}" "${wget_args[@]}"
    return 0
}

koopa_which_function() {
    local dict
    koopa_assert_has_args_eq "$#" 1
    [[ -z "${1:-}" ]] && return 1
    declare -A dict=(
        [input_key]="${1:?}"
    )
    if koopa_is_function "${dict[input_key]}"
    then
        koopa_print "${dict[input_key]}"
        return 0
    fi
    dict[key]="${dict[input_key]//-/_}"
    dict[os_id]="$(koopa_os_id)"
    if koopa_is_function "koopa_${dict[os_id]}_${dict[key]}"
    then
        dict[fun]="koopa_${dict[os_id]}_${dict[key]}"
    elif koopa_is_rhel_like && \
        koopa_is_function "koopa_rhel_${dict[key]}"
    then
        dict[fun]="koopa_rhel_${dict[key]}"
    elif koopa_is_debian_like && \
        koopa_is_function "koopa_debian_${dict[key]}"
    then
        dict[fun]="koopa_debian_${dict[key]}"
    elif koopa_is_fedora_like && \
        koopa_is_function "koopa_fedora_${dict[key]}"
    then
        dict[fun]="koopa_fedora_${dict[key]}"
    elif koopa_is_linux && \
        koopa_is_function "koopa_linux_${dict[key]}"
    then
        dict[fun]="koopa_linux_${dict[key]}"
    else
        dict[fun]="koopa_${dict[key]}"
    fi
    koopa_is_function "${dict[fun]}" || return 1
    koopa_print "${dict[fun]}"
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
        [file]=''
        [string]=''
    )
    while (("$#"))
    do
        case "$1" in
            '--file='*)
                dict[file]="${1#*=}"
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict[string]="${1#*=}"
                shift 1
                ;;
            '--string')
                dict[string]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--file' "${dict[file]}" \
        '--string' "${dict[string]}"
    dict[parent_dir]="$(koopa_dirname "${dict[file]}")"
    if [[ ! -d "${dict[parent_dir]}" ]]
    then
        koopa_mkdir "${dict[parent_dir]}"
    fi
    koopa_print "${dict[string]}" > "${dict[file]}"
    return 0
}

koopa_xcode_clt_version() {
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_is_xcode_clt_installed || return 1
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [pkgutil]="$(koopa_macos_locate_pkgutil)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[pkgutil]}" ]] || return 1
    declare -A dict=(
        [pkg]='com.apple.pkg.CLTools_Executables'
    )
    "${app[pkgutil]}" --pkgs="${dict[pkg]}" >/dev/null || return 1
    dict[str]="$( \
        "${app[pkgutil]}" --pkg-info="${dict[pkg]}" \
            | "${app[awk]}" '/version:/ {print $2}' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}
