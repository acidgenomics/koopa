#!/usr/bin/env bash
# shellcheck disable=all

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

koopa_activate_conda() {
    _koopa_activate_conda "$@"
}

koopa_activate_ensembl_perl_api() {
    local dict
    declare -A dict
    dict['prefix']="$(koopa_app_prefix 'ensembl-perl-api')"
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
            koopa_add_to_path_string_start "$PKG_CONFIG_PATH" "$str" \
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

koopa_add_config_link() {
    _koopa_add_config_link "$@"
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

koopa_add_to_path_start() {
    _koopa_add_to_path_start "$@"
}

koopa_add_to_path_string_start() {
    _koopa_add_to_path_string_start "$@"
}

koopa_add_to_pkg_config_path() {
    local dir
    koopa_assert_has_args "$#"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        PKG_CONFIG_PATH="$( \
            koopa_add_to_path_string_start "$PKG_CONFIG_PATH" "$dir" \
        )"
    done
    export PKG_CONFIG_PATH
    return 0
}

koopa_add_to_user_profile() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict
    dict['file']="$(koopa_find_user_profile)"
    koopa_alert "Adding koopa activation to '${dict['file']}'."
    read -r -d '' "dict[string]" << END || true
_koopa_activate_user_profile() {
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

_koopa_activate_user_profile
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
    koopa_alert_process_start 'Configuring' "$@"
}

koopa_alert_configure_success() {
    koopa_alert_process_success 'Configuration' "$@"
}

koopa_alert_info() {
    koopa_msg 'cyan' 'default' 'ℹ︎' "$@"
    return 0
}

koopa_alert_install_start() {
    koopa_alert_process_start 'Installing' "$@"
}

koopa_alert_install_success() {
    koopa_alert_process_success 'Installation' "$@"
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
    koopa_msg 'yellow' 'default' '**' "$@"
}

koopa_alert_process_start() {
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

koopa_alert_process_success() {
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

koopa_alert_restart() {
    koopa_alert_note 'Restart the shell.'
}

koopa_alert_success() {
    koopa_msg 'green-bold' 'green' '✓' "$@"
}

koopa_alert_uninstall_start() {
    koopa_alert_process_start 'Uninstalling' "$@"
}

koopa_alert_uninstall_success() {
    koopa_alert_process_success 'Uninstallation' "$@"
}

koopa_alert_update_start() {
    koopa_alert_process_start 'Updating' "$@"
}

koopa_alert_update_success() {
    koopa_alert_process_success 'Update' "$@"
}

koopa_alert() {
    koopa_msg 'default' 'default' '→' "$@"
    return 0
}

koopa_ansi_escape() {
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

koopa_arch() {
    _koopa_arch "$@"
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
    koopa_assert_has_args "$#"
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
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa_is_git_repo "$arg"
        then
            koopa_stop "Not a Git repo: '${arg}'."
        fi
    done
    return 0
}

koopa_assert_is_github_ssh_enabled() {
    koopa_assert_has_no_args "$#"
    if ! koopa_is_github_ssh_enabled
    then
        koopa_stop 'GitHub SSH access is not configured correctly.'
    fi
    return 0
}

koopa_assert_is_gitlab_ssh_enabled() {
    koopa_assert_has_no_args "$#"
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
    koopa_assert_has_no_args "$#"
    if ! koopa_is_macos
    then
        koopa_stop 'macOS is required.'
    fi
    return 0
}

koopa_assert_is_matching_fixed() {
    local dict
    koopa_assert_has_args "$#"
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
    local dict
    koopa_assert_has_args "$#"
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
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if koopa_is_installed "$arg"
        then
            local where
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

koopa_assert_is_owner() {
    local dict
    koopa_assert_has_no_args "$#"
    if ! koopa_is_owner
    then
        declare -A dict=(
            ['prefix']="$(koopa_koopa_prefix)"
            ['user']="$(koopa_user)"
        )
        koopa_stop "Koopa installation at '${dict['prefix']}' is not \
owned by '${dict['user']}'."
    fi
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
    declare -A app
    app['aws']="$(koopa_locate_aws)"
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['file']="$(koopa_tmp_file)"
        ['profile']="${AWS_PROFILE:-default}"
        ['url']="${BATCH_FILE_URL:?}"
    )
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
    local -A app
    app['aws']="$(koopa_locate_aws)"
    [[ -x "${app['aws']}" ]] || return 1
    local -A dict=(
        ['account_id']="${AWS_BATCH_ACCOUNT_ID:-}"
        ['profile']="${AWS_PROFILE:-default}"
        ['queue']="${AWS_BATCH_QUEUE:-}"
        ['region']="${AWS_BATCH_REGION:-}"
    )
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
        '--account-id or AWS_BATCH_ACCOUNT_ID' "${dict['account_id']}" \
        '--queue or AWS_BATCH_QUEUE' "${dict['queue']}" \
        '--region or AWS_BATCH_REGION' "${dict['region']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}"
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
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app dict
    if koopa_is_ubuntu_like
    then
        app['ec2metadata']='/usr/bin/ec2metadata'
    else
        app['ec2metadata']='/usr/bin/ec2-metadata'
    fi
    [[ -x "${app['ec2metadata']}" ]] || return 1
    dict['string']="$("${app['ec2metadata']}" --instance-id)"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}

koopa_aws_ec2_suspend() {
    local app dict
    declare -A app
    app['aws']="$(koopa_locate_aws)"
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['id']="$(koopa_aws_ec2_instance_id)"
        ['profile']="${AWS_PROFILE:-default}"
    )
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
    koopa_assert_is_set '--profile or AWS_PROFILE' "${dict['profile']}"
    koopa_alert "Suspending EC2 instance '${dict['id']}'."
    "${app['aws']}" --profile="${dict['profile']}" \
        ec2 stop-instances --instance-id "${dict['id']}" \
        >/dev/null
    return 0
}


koopa_aws_ec2_terminate() {
    local app dict
    declare -A app
    app['aws']="$(koopa_locate_aws)"
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['id']="$(koopa_aws_ec2_instance_id)"
        ['profile']="${AWS_PROFILE:-default}"
    )
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
    koopa_assert_is_set '--profile or AWS_PROFILE' "${dict['profile']}"
    "${app['aws']}" --profile="${dict['profile']}" \
        ec2 terminate-instances --instance-id "${dict['id']}" \
        >/dev/null
    return 0
}

koopa_aws_s3_cp_regex() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app
    app['aws']="$(koopa_locate_aws)"
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['bucket_pattern']='^s3://.+/$'
        ['pattern']=''
        ['profile']="${AWS_PROFILE:-default}"
        ['source_prefix']=''
        ['target_prefix']=''
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
        ['profile']="${AWS_PROFILE:-default}"
        ['recursive']=0
    )
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
        ['profile']="${AWS_PROFILE:-default}"
        ['recursive']=0
        ['type']=''
    )
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
    declare -A app
    app['aws']="$(koopa_locate_aws)"
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['prefix']=''
        ['profile']="${AWS_PROFILE:-default}"
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
        '--profile or AWS_PROFILE' "${dict['profile']}"
        '--prefix' "${dict['prefix']}"
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
    declare -A app
    app['aws']="$(koopa_locate_aws)"
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['profile']="${AWS_PROFILE:-default}"
    )
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

koopa_bin_prefix() {
    _koopa_bin_prefix "$@"
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

koopa_boolean_nounset() {
    _koopa_boolean_nounset "$@"
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
        branch="$(koopa_git_default_branch "${PWD:?}")"
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
                'python@3.11' | \
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
                'pull' | \
                'push-submodules' | \
                'rename-master-to-main' | \
                'reset' | \
                'reset-fork-to-upstream' | \
                'rm-submodule' | \
                'rm-untracked')
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
        'variables' | \
        'zsh-compaudit-set-permissions')
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
        ['env_name']="${CONDA_DEFAULT_ENV:-}"
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

koopa_config_prefix() {
    _koopa_config_prefix "$@"
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

koopa_cpu_count() {
    _koopa_cpu_count "$@"
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
        koopa_parse_url 'ftp://ftp.ensembl.org/pub/README' \
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

koopa_default_shell_name() {
    _koopa_default_shell_name "$@"
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
        koopa_msg 'default-bold' 'default' "${1:?}:" "${2:-}"
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

koopa_docker_prefix() {
    koopa_print "$(koopa_config_prefix)/docker"
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

koopa_doom_emacs_prefix() {
    _koopa_doom_emacs_prefix "$@"
}

koopa_dotfiles_config_link() {
    koopa_assert_has_no_args "$#"
    koopa_print "$(koopa_config_prefix)/dotfiles"
    return 0
}

koopa_dotfiles_prefix() {
    _koopa_dotfiles_prefix "$@"
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

koopa_emacs_prefix() {
    _koopa_emacs_prefix "$@"
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

koopa_fasta_has_alt_contigs() {
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        ['compress_ext_pattern']="$(koopa_compress_ext_pattern)"
        ['file']="${1:?}"
        ['is_tmp_file']=0
        ['status']=1
    )
    koopa_assert_is_file "${dict['file']}"
    if koopa_str_detect_regex \
        --string="${dict['file']}" \
        --pattern="${dict['compress_ext_pattern']}"
    then
        dict['is_tmp_file']=1
        dict['tmp_file']="$(koopa_tmp_file)"
        koopa_decompress "${dict['file']}" "${dict['tmp_file']}"
    else
        dict['tmp_file']="${dict['file']}"
    fi
    if koopa_file_detect_fixed \
        --file="${dict['tmp_file']}" \
        --pattern=' ALT_' \
    || koopa_file_detect_fixed \
        --file="${dict['tmp_file']}" \
        --pattern=' alternate locus group ' \
    || koopa_file_detect_fixed \
        --file="${dict['tmp_file']}" \
        --pattern=' rl:alt-scaffold '
    then
        dict['status']=0
    fi
    [[ "${dict['is_tmp_file']}" -eq 1 ]] && koopa_rm "${dict['tmp_file']}"
    return "${dict['status']}"
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
    koopa_file_detect --mode='fixed' "$@"
}

koopa_file_detect_regex() {
    koopa_file_detect --mode='regex' "$@"
}

koopa_file_detect() {
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

koopa_get_version_arg() {
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
        dict['version_arg']="$(koopa_get_version_arg "${dict['bn']}")"
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

koopa_git_branch() {
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut --allow-system)"
        ['git']="$(koopa_locate_git --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local dict2
            koopa_cd "$repo"
            declare -A dict2
            dict2['branch']="$( \
                "${app['git']}" branch --show-current \
                2>/dev/null \
            )"
            if [[ -z "${dict2['branch']}" ]]
            then
                dict2['branch']="$( \
                    "${app['git']}" branch 2>/dev/null \
                    | "${app['head']}" -n 1 \
                    | "${app['cut']}" -c '3-' \
                )"
            fi
            [[ -n "${dict2['branch']}" ]] || return 0
            koopa_print "${dict2['branch']}"
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
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        ['date']="$(koopa_locate_date --allow-system)"
        ['git']="$(koopa_locate_git --allow-system)"
        ['xargs']="$(koopa_locate_xargs --allow-system)"
    )
    [[ -x "${app['date']}" ]] || return 1
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local string
            koopa_cd "$repo"
            string="$( \
                "${app['git']}" log -1 --format='%at' \
                | "${app['xargs']}" -I '{}' \
                "${app['date']}" -d '@{}' '+%Y-%m-%d' \
                2>/dev/null \
                || true \
            )"
            [[ -n "$string" ]] || return 1
            koopa_print "$string"
        done
    )
    return 0
}

koopa_git_default_branch() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
        ['sed']="$(koopa_locate_sed --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict
    dict['remote']='origin'
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local string
            koopa_cd "$repo"
            string="$( \
                "${app['git']}" remote show "${dict['remote']}" \
                | koopa_grep --pattern='HEAD branch' \
                | "${app['sed']}" 's/.*: //' \
            )"
            [[ -n "$string" ]] || return 1
            koopa_print "$string"
        done
    )
    return 0
}

koopa_git_last_commit_local() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app dict
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    dict['ref']='HEAD'
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local string
            koopa_cd "$repo"
            string="$( \
                "${app['git']}" rev-parse "${dict['ref']}" \
                2>/dev/null \
                || true \
            )"
            [[ -n "$string" ]] || return 1
            koopa_print "$string"
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
    declare -A dict
    dict['ref']='HEAD'
    for url in "$@"
    do
        local string
        string="$( \
            "${app['git']}" ls-remote --quiet "$url" "${dict['ref']}" \
            | "${app['head']}" -n 1 \
            | "${app['awk']}" '{ print $1 }' \
        )"
        [[ -n "$string" ]] || return 1
        koopa_print "$string"
    done
    return 0
}

koopa_git_latest_tag() {
    local app
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local rev tag
            koopa_cd "$repo"
            rev="$("${app['git']}" rev-list --tags --max-count=1)"
            tag="$("${app['git']}" describe --tags "$rev")"
            [[ -n "$tag" ]] || return 1
            koopa_print "$tag"
        done
    )
    return 0
}

koopa_git_pull() {
    local app repos
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    repos=("$@")
    koopa_assert_is_git_repo "${repos[@]}"
    (
        for repo in "${repos[@]}"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Pulling Git repo at '${repo}'."
            koopa_cd "$repo"
            "${app['git']}" fetch --all --quiet
            "${app['git']}" pull --all --no-rebase --recurse-submodules
        done
    )
    return 0
}

koopa_git_push_submodules() {
    local app
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
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
    local app
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local string
            koopa_cd "$repo"
            string="$( \
                "${app['git']}" config --get 'remote.origin.url' \
                || true \
            )"
            [[ -n "$string" ]] || return 1
            koopa_print "$string"
        done
    )
    return 0
}

koopa_git_rename_master_to_main() {
    local app dict
    koopa_assert_has_args "$#"
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    declare -A dict=(
        ['origin']='origin'
        ['old_branch']='master'
        ['new_branch']='main'
    )
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            koopa_cd "$repo"
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

koopa_git_repo_has_unstaged_changes() {
    local app dict
    declare -A app dict
    app['git']="$(koopa_locate_git)"
    [[ -x "${app['git']}" ]] || return 1
    "${app['git']}" update-index --refresh &>/dev/null
    dict['string']="$("${app['git']}" diff-index 'HEAD' -- 2>/dev/null)"
    [[ -n "${dict['string']}" ]]
}


koopa_git_repo_needs_pull_or_push() {
    local app prefix
    koopa_assert_has_args "$#"
    declare -A app
    app['git']="$(koopa_locate_git)"
    [[ -x "${app['git']}" ]] || return 1
    (
        for prefix in "$@"
        do
            local dict
            declare -A dict
            dict['prefix']="$prefix"
            koopa_cd "${dict['prefix']}"
            dict['rev1']="$("${app['git']}" rev-parse 'HEAD' 2>/dev/null)"
            dict['rev2']="$("${app['git']}" rev-parse '@{u}' 2>/dev/null)"
            [[ "${dict['rev1']}" != "${dict['rev2']}" ]] && return 0
        done
        return 1
    )
}

koopa_git_reset_fork_to_upstream() {
    local app
    koopa_assert_has_args "$#"
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local dict
            koopa_cd "$repo"
            declare -A dict=(
                ['branch']="$(koopa_git_default_branch "${PWD:?}")"
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
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_git_repo "${repos[@]}"
    (
        local repo
        for repo in "${repos[@]}"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Resetting Git repo at '${repo}'."
            koopa_cd "$repo"
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
    koopa_assert_has_args_eq "$#" 2
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    declare -A dict=(
        ['origin']='origin'
        ['prefix']="${1:?}"
        ['url']="${2:?}"
    )
    koopa_assert_is_git_repo "${dict['prefix']}"
    (
        koopa_cd "${dict['prefix']}"
        "${app['git']}" remote set-url "${dict['origin']}" "${dict['url']}"
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

koopa_group() {
    _koopa_group "$@"
}

koopa_gsub() {
    koopa_sub --global "$@"
}

koopa_h() {
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
    koopa_msg 'magenta' 'default' "${dict['emoji']} ${dict['prefix']}" "$@"
    return 0
}

koopa_h1() {
    koopa_h 1 "$@"
}

koopa_h2() {
    koopa_h 2 "$@"
}

koopa_h3() {
    koopa_h 3 "$@"
}

koopa_h4() {
    koopa_h 4 "$@"
}

koopa_h5() {
    koopa_h 5 "$@"
}

koopa_h6() {
    koopa_h 6 "$@"
}

koopa_h7() {
    koopa_h 7 "$@"
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

koopa_has_private_acccess() {
    local file
    file="${HOME}/.aws/credentials"
    [[ -f "$file" ]] || return 1
    koopa_file_detect_fixed \
        --file="$file" \
        --pattern='[acidgenomics]'
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

koopa_homebrew_prefix() {
    _koopa_homebrew_prefix "$@"
}

koopa_hostname() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app dict
    app['uname']="$(koopa_locate_uname)"
    [[ -x "${app['uname']}" ]] || return 1
    dict['string']="$("${app['uname']}" -n)"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
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
        'lz4'
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
        'gh'
        'git-lfs'
        'miller'
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
        'yapf'
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
        'ack'
        'exiftool'
        'rename'
        'bash-language-server'
        'gtop'
        'prettier'
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
                'fqtk'
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
                'openbb'
                'picard'
                'rsem'
                'salmon'
                'sambamba'
                'samtools'
                'snakefmt'
                'snakemake'
                'star'
                'star-fusion'
                'subread'
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
        'lz4'
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
        'gh'
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
        'lzo'
        'make'
        'man-db'
        'markdownlint-cli'
        'mcfly'
        'mdcat'
        'meson'
        'miller'
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
        'yapf'
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
                'autodock'
                'autodock-vina'
                'bamtools'
                'bedtools'
                'bioawk'
                'bowtie2'
                'bustools'
                'deeptools'
                'fastqc'
                'ffq'
                'fgbio'
                'fq'
                'fqtk'
                'gatk'
                'gffutils'
                'gget'
                'hisat2'
                'htseq'
                'kallisto'
                'minimap2'
                'multiqc'
                'nanopolish'
                'nextflow'
                'openbb'
                'picard'
                'rsem'
                'salmon'
                'sambamba'
                'samtools'
                'scalene'
                'snakefmt'
                'snakemake'
                'sra-tools'
                'star'
                'star-fusion'
                'subread'
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
    koopa_assert_is_owner
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

koopa_install_fqtk() {
    koopa_install_app \
        --name='fqtk' \
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

koopa_install_gh() {
    koopa_install_app \
        --name='gh' \
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
    koopa_zsh_compaudit_set_permissions
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
