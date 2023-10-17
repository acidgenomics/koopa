#!/usr/bin/env bash
# shellcheck disable=all

koopa_acid_emoji() {
    koopa_print '🧪'
}

koopa_activate_app() {
    local -A app dict
    local -a pos
    local app_name
    koopa_assert_has_args "$#"
    app['pkg_config']="$(koopa_locate_pkg_config --allow-missing)"
    dict['build_only']=0
    dict['opt_prefix']="$(koopa_opt_prefix)"
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
    CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH:-}"
    CPPFLAGS="${CPPFLAGS:-}"
    LDFLAGS="${LDFLAGS:-}"
    LDLIBS="${LDLIBS:-}"
    LIBRARY_PATH="${LIBRARY_PATH:-}"
    PATH="${PATH:-}"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for app_name in "$@"
    do
        local -A dict2
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
            local -a pc_files
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
            if [[ -n "${dict2['cflags']}" ]]
            then
                CPPFLAGS="${CPPFLAGS} ${dict2['cflags']}"
            fi
            if [[ -n "${dict2['ldflags']}" ]]
            then
                LDFLAGS="${LDFLAGS} ${dict2['ldflags']}"
            fi
            if [[ -n "${dict2['ldlibs']}" ]]
            then
                LDLIBS="${LDLIBS} ${dict2['ldlibs']}"
            fi
        else
            if [[ -d "${dict2['prefix']}/include" ]]
            then
                CPPFLAGS="${CPPFLAGS} -I${dict2['prefix']}/include"
            fi
            if [[ -d "${dict2['prefix']}/lib" ]]
            then
                LDFLAGS="${LDFLAGS} -L${dict2['prefix']}/lib"
            fi
            if [[ -d "${dict2['prefix']}/lib64" ]]
            then
                LDFLAGS="${LDFLAGS} -L${dict2['prefix']}/lib64"
            fi
        fi
        if [[ -d "${dict2['prefix']}/lib" ]]
        then
            LIBRARY_PATH="$( \
                koopa_add_to_path_string_start  \
                    "$LIBRARY_PATH" \
                    "${dict2['prefix']}/lib" \
            )"
        fi
        if [[ -d "${dict2['prefix']}/lib64" ]]
        then
            LIBRARY_PATH="$( \
                koopa_add_to_path_string_start  \
                    "$LIBRARY_PATH" \
                    "${dict2['prefix']}/lib64" \
            )"
        fi
        koopa_add_rpath_to_ldflags \
            "${dict2['prefix']}/lib" \
            "${dict2['prefix']}/lib64"
        if [[ -d "${dict2['prefix']}/lib/cmake" ]]
        then
            CMAKE_PREFIX_PATH="${dict2['prefix']};${CMAKE_PREFIX_PATH}"
        fi
    done
    if [[ -n "$LIBRARY_PATH" ]]
    then
        if [[ -d '/usr/lib64' ]]
        then
            LIBRARY_PATH="$( \
                koopa_add_to_path_string_end \
                    "$LIBRARY_PATH" \
                    '/usr/lib64' \
            )"
        fi
        if [[ -d '/usr/lib' ]]
        then
            LIBRARY_PATH="$( \
                koopa_add_to_path_string_end \
                    "$LIBRARY_PATH" \
                    '/usr/lib' \
            )"
        fi
    fi
    if [[ -n "$CMAKE_PREFIX_PATH" ]]
    then
        CMAKE_PREFIX_PATH="$( \
            koopa_str_unique_by_semicolon "$CMAKE_PREFIX_PATH" \
        )"
        export CMAKE_PREFIX_PATH
    else
        unset -v CMAKE_PREFIX_PATH
    fi
    if [[ -n "$CPPFLAGS" ]]
    then
        CPPFLAGS="$(koopa_str_unique_by_space "$CPPFLAGS")"
        export CPPFLAGS
    else
        unset -v CPPFLAGS
    fi
    if [[ -n "$LDFLAGS" ]]
    then
        LDFLAGS="$(koopa_str_unique_by_space "$LDFLAGS")"
        export LDFLAGS
    else
        unset -v LDFLAGS
    fi
    if [[ -n "$LDLIBS" ]]
    then
        LDLIBS="$(koopa_str_unique_by_space "$LDLIBS")"
        export LDLIBS
    else
        unset -v LDLIBS
    fi
    if [[ -n "$LIBRARY_PATH" ]]
    then
        LIBRARY_PATH="$(koopa_str_unique_by_colon "$LIBRARY_PATH")"
        export LIBRARY_PATH
    else
        unset -v LIBRARY_PATH
    fi
    if [[ -n "$PATH" ]]
    then
        PATH="$(koopa_str_unique_by_colon "$PATH")"
        export PATH
    else
        unset -v PATH
    fi
    if [[ -n "$PKG_CONFIG_PATH" ]]
    then
        PKG_CONFIG_PATH="$(koopa_str_unique_by_colon "$PKG_CONFIG_PATH")"
        export PKG_CONFIG_PATH
    else
        unset -v PKG_CONFIG_PATH
    fi
    return 0
}

koopa_activate_ca_certificates() {
    _koopa_activate_ca_certificates "$@"
}

koopa_activate_conda() {
    _koopa_activate_conda "$@"
}

koopa_activate_ensembl_perl_api() {
    local -A dict
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
    local app
    koopa_assert_has_args "$#"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for app in "$@"
    do
        local str
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
    local name
    koopa_assert_has_args "$#"
    [[ -z "${CONDA_PREFIX:-}" ]] || return 1
    for name in "$@"
    do
        local bin_dir
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
    local -A dict
    koopa_assert_has_args_le "$#" 1
    koopa_assert_is_admin
    dict['koopa_prefix']="${1:-}"
    dict['make_prefix']='/usr/local'
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
    local -A dict
    local subdir
    koopa_assert_has_args "$#"
    koopa_assert_has_monorepo
    dict['prefix']="$(koopa_monorepo_prefix)"
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
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        koopa_append_ldflags "-Wl,-rpath,${dir}"
    done
    return 0
}

koopa_add_to_path_end() {
    _koopa_add_to_path_end "$@"
}

koopa_add_to_path_start() {
    _koopa_add_to_path_start "$@"
}

koopa_add_to_path_string_end() {
    _koopa_add_to_path_string_end "$@"
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
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['file']="$(koopa_find_user_profile)"
    koopa_alert "Adding koopa activation to '${dict['file']}'."
    read -r -d '' "dict[string]" << END || true
__koopa_activate_user_profile() {
    __kvar_xdg_config_home="\${XDG_CONFIG_HOME:-}"
    if [ -z "\$__kvar_xdg_config_home" ]
    then
        __kvar_xdg_config_home="\${HOME:?}/.config"
    fi
    __kvar_script="\${__kvar_xdg_config_home}/koopa/activate"
    if [ -r "\$__kvar_script" ]
    then
        . "\$__kvar_script"
    fi
    unset -v __kvar_script __kvar_xdg_config_home
    return 0
}

__koopa_activate_user_profile
END
    koopa_append_string \
        --file="${dict['file']}" \
        --string="\n${dict['string']}"
    return 0
}

koopa_admin_group_name() {
    local group
    koopa_assert_has_no_args "$#"
    if koopa_is_root
    then
        group='root'
    elif koopa_is_alpine
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

koopa_alert_is_not_installed() {
    local -A dict
    dict['name']="${1:?}"
    dict['prefix']="${2:-}"
    dict['string']="'${dict['name']}' not installed"
    if [[ -n "${dict['prefix']}" ]]
    then
        dict['string']="${dict['string']} at '${dict['prefix']}'"
    fi
    dict['string']="${dict['string']}."
    koopa_alert_note "${dict['string']}"
    return 0
}

koopa_alert_note() {
    koopa_msg 'yellow' 'default' '**' "$@"
}

koopa_alert_process_start() {
    local -A dict
    dict['word']="${1:?}"
    shift 1
    koopa_assert_has_args_le "$#" 3
    dict['name']="${1:?}"
    dict['version']=''
    dict['prefix']=''
    if [[ "$#" -eq 2 ]]
    then
        dict['prefix']="${2:-}"
    elif [[ "$#" -eq 3 ]]
    then
        dict['version']="${2:-}"
        dict['prefix']="${3:-}"
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
    local -A dict
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

koopa_app_dependencies() {
    local app_name cmd
    koopa_assert_has_args_eq "$#" 1
    koopa_assert_is_installed 'python3'
    app_name="${1:?}"
    cmd="$(koopa_koopa_prefix)/lang/python/app-dependencies.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$app_name"
    return 0
}

koopa_app_json_bin() {
    local app_name
    koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        koopa_app_json \
            --app-name="$app_name" \
            --key='bin'
    done
}

koopa_app_json_man1() {
    local app_name
    koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        koopa_app_json \
            --app-name="$app_name" \
            --key='man1'
    done
}

koopa_app_json_version() {
    local app_name
    koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        koopa_app_json \
            --app-name="$app_name" \
            --key='version'
    done
}

koopa_app_json() {
    local cmd
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'python3'
    cmd="$(koopa_koopa_prefix)/lang/python/app-json.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$@"
    return 0
}

koopa_app_prefix() {
    local -A dict
    local -a pos
    dict['allow_missing']=0
    dict['app_prefix']="$(koopa_koopa_prefix)/app"
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
        local -A dict2
        dict2['app_name']="$app_name"
        dict2['version']="$( \
            koopa_app_json_version "${dict2['app_name']}" \
            2>/dev/null \
            || true \
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
        if [[ ! -d "${dict2['prefix']}" ]] && \
            [[ "${dict['allow_missing']}" -eq 1 ]]
        then
            continue
        fi
        koopa_assert_is_dir "${dict2['prefix']}"
        dict2['prefix']="$(koopa_realpath "${dict2['prefix']}")"
        koopa_print "${dict2['prefix']}"
    done
    return 0
}

koopa_app_reverse_dependencies() {
    local app_name cmd
    koopa_assert_has_args_eq "$#" 1
    koopa_assert_is_installed 'python3'
    app_name="${1:?}"
    cmd="$(koopa_koopa_prefix)/lang/python/app-reverse-dependencies.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$app_name"
    return 0
}

koopa_app_version() {
    local -A dict
    koopa_assert_has_args_eq "$#" 1
    dict['name']="${1:?}"
    dict['opt_prefix']="$(koopa_opt_prefix)"
    dict['symlink']="${dict['opt_prefix']}/${dict['name']}"
    koopa_assert_is_symlink "${dict['symlink']}"
    dict['realpath']="$(koopa_realpath "${dict['symlink']}")"
    dict['version']="$(koopa_basename "${dict['realpath']}")"
    koopa_print "${dict['version']}"
    return 0
}

koopa_append_cppflags() {
    local str
    koopa_assert_has_args "$#"
    CPPFLAGS="${CPPFLAGS:-}"
    for str in "$@"
    do
        CPPFLAGS="${CPPFLAGS} ${str}"
    done
    export CPPFLAGS
    return 0
}

koopa_append_ldflags() {
    local str
    koopa_assert_has_args "$#"
    LDFLAGS="${LDFLAGS:-}"
    for str in "$@"
    do
        LDFLAGS="${LDFLAGS} ${str}"
    done
    export LDFLAGS
    return 0
}

koopa_append_string() {
    local -A dict
    koopa_assert_has_args "$#"
    dict['file']=''
    dict['string']=''
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

koopa_apply_debian_patch_set() {
    local -A app dict
    local -a patch_series
    app['patch']="$(koopa_locate_patch)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']=''
    dict['patch_version']=''
    dict['target']=''
    dict['version']=''
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
            '--patch-version='*)
                dict['patch_version']="${1#*=}"
                shift 1
                ;;
            '--patch-version')
                dict['patch_version']="${2:?}"
                shift 2
                ;;
            '--target='*)
                dict['target']="${1#*=}"
                shift 1
                ;;
            '--target')
                dict['target']="${2:?}"
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
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--patch-version' "${dict['patch_version']}" \
        '--target' "${dict['target']}" \
        '--version' "${dict['version']}"
    koopa_assert_is_dir "${dict['target']}"
    dict['url']="https://deb.debian.org/debian/pool/main/${dict['name']:0:1}/\
${dict['name']}/${dict['name']}_${dict['version']}-${dict['patch_version']}.\
debian.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'debian'
    koopa_assert_is_file 'debian/patches/series'
    readarray -t patch_series < 'debian/patches/series'
    (
        local patch
        koopa_cd "${dict['target']}"
        for patch in "${patch_series[@]}"
        do
            local input
            input="$(koopa_realpath "../debian/patches/${patch}")"
            koopa_alert "Applying patch from '${input}'."
            "${app['patch']}" \
                --input="$input" \
                --strip=1 \
                --verbose
        done
    )
    return 0
}

koopa_apply_ubuntu_patch_set() {
    local -A app dict
    local -a patch_series
    app['patch']="$(koopa_locate_patch)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']=''
    dict['patch_version']=''
    dict['target']=''
    dict['version']=''
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
            '--patch-version='*)
                dict['patch_version']="${1#*=}"
                shift 1
                ;;
            '--patch-version')
                dict['patch_version']="${2:?}"
                shift 2
                ;;
            '--target='*)
                dict['target']="${1#*=}"
                shift 1
                ;;
            '--target')
                dict['target']="${2:?}"
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
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--patch-version' "${dict['patch_version']}" \
        '--target' "${dict['target']}" \
        '--version' "${dict['version']}"
    koopa_assert_is_dir "${dict['target']}"
    dict['url']="http://archive.ubuntu.com/ubuntu/pool/main/\
${dict['name']:0:1}/${dict['name']}/${dict['name']}_${dict['version']}-\
${dict['patch_version']}ubuntu1.debian.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'debian'
    koopa_assert_is_file 'debian/patches/series'
    readarray -t patch_series < 'debian/patches/series'
    (
        local patch
        koopa_cd "${dict['target']}"
        for patch in "${patch_series[@]}"
        do
            local input
            input="$(koopa_realpath .."/debian/patches/${patch}")"
            koopa_alert "Applying patch from '${input}'."
            "${app['patch']}" \
                --input="$input" \
                --strip=1 \
                --verbose
        done
    )
    return 0
}

koopa_arch() {
    _koopa_arch "$@"
}

koopa_arch2() {
    local str
    koopa_assert_has_no_args "$#"
    str="$(koopa_arch)"
    case "$str" in
        'aarch64')
            str='arm64'
            ;;
        'x86_64')
            str='amd64'
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

koopa_assert_can_install_binary() {
    koopa_assert_has_no_args "$#"
    if ! koopa_can_install_binary
    then
        koopa_stop 'No binary file access.'
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

koopa_assert_has_private_access() {
    koopa_assert_has_no_args "$#"
    if ! koopa_has_private_access
    then
        koopa_stop 'User does not have access to koopa private S3 bucket.'
    fi
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
        if [[ -z "$arg" ]]
        then
            koopa_stop 'Missing executable.'
        fi
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

koopa_assert_is_install_subshell() {
    koopa_assert_has_no_args "$#"
    if ! koopa_is_install_subshell
    then
        koopa_stop 'Unsupported command.'
    fi
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

koopa_assert_is_interactive() {
    koopa_assert_has_no_args "$#"
    if ! koopa_is_interactive
    then
        koopa_stop 'Shell is not interactive.'
    fi
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
    local -A dict
    koopa_assert_has_args "$#"
    dict['pattern']=''
    dict['string']=''
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
    local -A dict
    koopa_assert_has_args "$#"
    dict['pattern']=''
    dict['string']=''
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
    local -A dict
    koopa_assert_has_no_args "$#"
    if ! koopa_is_owner
    then
        dict['prefix']="$(koopa_koopa_prefix)"
        dict['user']="$(koopa_user_name)"
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
    local -A dict
    local -a pos
    local file
    koopa_assert_has_args "$#"
    dict['dryrun']=0
    dict['padwidth']=2
    dict['prefix']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--pad-width='* | \
            '--padwidth='*)
                dict['padwidth']="${1#*=}"
                shift 1
                ;;
            '--pad-width' | \
            '--padwidth')
                dict['padwidth']="${2:?}"
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
            '--dry-run' | \
            '--dryrun')
                dict['dryrun']=1
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
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        local -A dict2
        dict2['source']="$file"
        dict2['bn']="$(koopa_basename "${dict2['source']}")"
        dict2['dn']="$(koopa_dirname "${dict2['source']}")"
        if [[ "${dict2['bn']}" =~ ^([0-9]+)(.*)$ ]]
        then
            dict2['num']="${BASH_REMATCH[1]}"
            dict2['num']="$(printf "%.${dict['padwidth']}d" "${dict2['num']}")"
            dict2['stem']="${BASH_REMATCH[2]}"
            dict2['bn2']="${dict['prefix']}${dict2['num']}${dict2['stem']}"
            dict2['target']="${dict2['dn']}/${dict2['bn2']}"
            koopa_alert "Renaming '${dict2['source']}' to '${dict2['target']}'."
            [[ "${dict['dryrun']}" -eq 1 ]] && continue
            koopa_mv "${dict2['source']}" "${dict2['target']}"
        else
            koopa_alert_note "Skipping '${dict2['source']}'."
        fi
    done
    return 0
}

koopa_aws_batch_fetch_and_run() {
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_set 'BATCH_FILE_URL' "${BATCH_FILE_URL:-}"
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['file']="$(koopa_tmp_file)"
    dict['profile']="${AWS_PROFILE:-default}"
    dict['url']="${BATCH_FILE_URL:?}"
    case "${dict['url']}" in
        'ftp://'* | \
        'http://'*)
            koopa_download "${dict['url']}" "${dict['file']}"
            ;;
        's3://'*)
            "${app['aws']}" s3 cp \
                --profile "${dict['profile']}" \
                "${dict['url']}" "${dict['file']}"
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
    local -A app dict
    local -a job_queue_array status_array
    local status
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['account_id']="${AWS_BATCH_ACCOUNT_ID:-}"
    dict['profile']="${AWS_PROFILE:-default}"
    dict['queue']="${AWS_BATCH_QUEUE:-}"
    dict['region']="${AWS_BATCH_REGION:-}"
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
        "${app['aws']}" batch list-jobs \
            --job-queue "${dict['job_queue']}" \
            --job-status "$status" \
            --no-cli-pager \
            --output 'text' \
            --profile "${dict['profile']}"
    done
    return 0
}

koopa_aws_codecommit_list_repositories() {
    local -A app dict
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_PROFILE:-default}"
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
    dict['string']="$( \
        "${app['aws']}" codecommit list-repositories \
            --no-cli-pager \
            --output 'json' \
            --profile "${dict['profile']}" \
        | "${app['jq']}" --raw-output '.repositories[].repositoryName' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}

koopa_aws_ec2_instance_id() {
    local -A app dict
    koopa_assert_has_no_args "$#"
    if koopa_is_ubuntu_like
    then
        app['ec2metadata']='/usr/bin/ec2metadata'
    else
        app['ec2metadata']='/usr/bin/ec2-metadata'
    fi
    koopa_assert_is_executable "${app[@]}"
    dict['string']="$("${app['ec2metadata']}" --instance-id)"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}

koopa_aws_ec2_list_running_instances() {
    local -A app bool dict
    local -a filters
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    bool['name']=0
    dict['profile']="${AWS_PROFILE:-default}"
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
            '--with-name')
                bool['name']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--profile or AWS_PROFILE' "${dict['profile']}"
    if [[ "${bool['name']}" -eq 1 ]]
    then
        dict['query']="Reservations[*].Instances[*][Tags[?Key=='Name'].Value[],\
InstanceId,NetworkInterfaces[0].PrivateIpAddresses[0].PrivateIpAddress]"
        filters+=('Name=tag-key,Values=Name')
    else
        dict['query']='Reservations[*].Instances[*].[InstanceId]'
    fi
    filters+=('Name=instance-state-name,Values=running')
    dict['out']="$( \
        "${app['aws']}" ec2 describe-instances \
            --filters "${filters[@]}" \
            --no-cli-pager \
            --output 'text' \
            --profile "${dict['profile']}" \
            --query "${dict['query']}" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}

koopa_aws_ec2_map_instance_ids_to_names() {
    local -A app dict
    local -a ids names out
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_PROFILE:-default}"
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
    dict['json']="$( \
        "${app['aws']}" ec2 describe-instances \
            --no-cli-pager \
            --output 'json' \
            --profile "${dict['profile']}" \
    )"
    readarray -t ids <<< "$( \
        koopa_print "${dict['json']}" \
        | "${app['jq']}" --raw-output \
            '.Reservations[] | "\(.Instances[].InstanceId)"' \
    )"
    koopa_assert_is_array_non_empty "${ids[@]}"
    readarray -t names <<< "$( \
        koopa_print "${dict['json']}" \
        | "${app['jq']}" --raw-output \
            '.Reservations[] | "\(.Instances[].Tags[0].Value)"' \
    )"
    koopa_assert_is_array_non_empty "${names[@]}"
    for i in "${!ids[@]}"
    do
        out+=("${ids[$i]} : ${names[$i]}")
    done
    koopa_print "${out[@]}"
    return 0
}

koopa_aws_ec2_stop() {
    local -A app dict
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['id']="$(koopa_aws_ec2_instance_id)"
    [[ -n "${dict['id']}" ]] || return 1
    dict['profile']="${AWS_PROFILE:-default}"
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
    koopa_alert "Stopping EC2 instance '${dict['id']}'."
    "${app['aws']}" ec2 stop-instances \
        --instance-id "${dict['id']}" \
        --no-cli-pager \
        --output 'text' \
        --profile "${dict['profile']}"
    return 0
}

koopa_aws_ec2_terminate() {
    local -A app dict
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['id']="$(koopa_aws_ec2_instance_id)"
    [[ -n "${dict['id']}" ]] || return 1
    dict['profile']="${AWS_PROFILE:-default}"
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
    "${app['aws']}" ec2 terminate-instances \
        --instance-id "${dict['id']}" \
        --no-cli-pager \
        --output 'text' \
        --profile "${dict['profile']}"
    return 0
}

koopa_aws_ecr_login_private() {
    local -A app dict
    app['aws']="$(koopa_locate_aws)"
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    dict['account_id']="${AWS_ECR_ACCOUNT_ID:-}"
    dict['profile']="${AWS_ECR_PROFILE:-}"
    dict['region']="${AWS_ECR_REGION:-}"
    dict['repo_url']="${dict['account_id']}.dkr.ecr.${dict['region']}.\
amazonaws.com"
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
        '--account-id or AWS_ECR_ACCOUNT_ID' "${dict['account_id']}" \
        '--profile or AWS_ECR_PROFILE' "${dict['profile']}" \
        '--region or AWS_ECR_REGION' "${dict['region']}"
    koopa_alert "Logging into '${dict['repo_url']}'."
    "${app['docker']}" logout "${dict['repo_url']}" >/dev/null || true
    "${app['aws']}" ecr get-login-password \
        --profile "${dict['profile']}" \
        --region "${dict['region']}" \
    | "${app['docker']}" login \
        --password-stdin \
        --username 'AWS' \
        "${dict['repo_url']}" \
        >/dev/null \
    || return 1
    return 0
}

koopa_aws_ecr_login_public() {
    local -A app dict
    app['aws']="$(koopa_locate_aws)"
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_ECR_PROFILE:-}"
    dict['region']="${AWS_ECR_REGION:-}"
    dict['repo_url']='public.ecr.aws'
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
        '--profile or AWS_ECR_PROFILE' "${dict['profile']}" \
        '--region or AWS_ECR_REGION' "${dict['region']}"
    koopa_alert "Logging into '${dict['repo_url']}'."
    "${app['docker']}" logout "${dict['repo_url']}" >/dev/null || true
    "${app['aws']}" ecr-public get-login-password \
        --profile "${dict['profile']}" \
        --region "${dict['region']}" \
    | "${app['docker']}" login \
        --password-stdin \
        --username 'AWS' \
        "${dict['repo_url']}" \
        >/dev/null \
    || return 1
    return 0
}

koopa_aws_s3_cp_regex() {
    local -A app dict
    koopa_assert_has_args "$#"
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['bucket_pattern']='^s3://.+/$'
    dict['pattern']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['source_prefix']=''
    dict['target_prefix']=''
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
    "${app['aws']}" s3 cp \
        --exclude '*' \
        --follow-symlinks \
        --include "${dict['pattern']}" \
        --profile "${dict['profile']}" \
        --recursive \
        "${dict['source_prefix']}" \
        "${dict['target_prefix']}"
    return 0
}

koopa_aws_s3_delete_versioned_glacier_objects() {
    local -A app bool dict
    local -a keys version_ids
    local i
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    koopa_assert_is_executable "${app[@]}"
    bool['dryrun']=0
    dict['bucket']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['region']="${AWS_REGION:-us-east-1}"
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
            '--dry-run' | \
            '--dryrun')
                bool['dryrun']=1
                shift 1
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
    if [[ "${bool['dryrun']}" -eq 1 ]]
    then
        koopa_alert_info 'Dry run mode enabled.'
    fi
    koopa_alert "Fetching versioned Glacier objects in '${dict['bucket']}'."
    dict['json']="$( \
        "${app['aws']}" s3api list-object-versions \
            --bucket "${dict['bucket']}" \
            --no-cli-pager \
            --output 'json' \
            --profile "${dict['profile']}" \
            --query "Versions[?StorageClass=='GLACIER']" \
            --region "${dict['region']}" \
    )"
    if [[ -z "${dict['json']}" ]] || [[ "${dict['json']}" == '[]' ]]
    then
        koopa_alert_note "No versioned Glacier objects in '${dict['bucket']}'."
        return 0
    fi
    readarray -t keys <<< "$( \
        koopa_print "${dict['json']}" \
            | "${app['jq']}" --raw-output '.[].Key' \
    )"
    readarray -t version_ids <<< "$( \
        koopa_print "${dict['json']}" \
            | "${app['jq']}" --raw-output '.[].VersionId' \
    )"
    koopa_alert_info "$(koopa_ngettext \
        --num="${#keys[@]}" \
        --msg1='object' \
        --msg2='objects' \
        --suffix=' detected.' \
    )"
    for i in "${!keys[@]}"
    do
        local -A dict2
        dict2['key']="${keys[$i]}"
        dict2['version_id']="${version_ids[$i]}"
        koopa_alert "Deleting 's3://${dict['bucket']}/${dict2['key']}' \
(${dict2['version_id']})."
        [[ "${bool['dryrun']}" -eq 1 ]] && continue
        "${app['aws']}" s3api delete-object \
            --bucket "${dict['bucket']}" \
            --key "${dict2['key']}" \
            --no-cli-pager \
            --output 'text' \
            --profile "${dict['profile']}" \
            --region "${dict['region']}" \
            --version-id "${dict2['version_id']}"
    done
    return 0
}

koopa_aws_s3_dot_clean() {
    local -A app bool dict
    local -a keys
    local key
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    koopa_assert_is_executable "${app[@]}"
    bool['dryrun']=0
    dict['bucket']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['region']="${AWS_REGION:-us-east-1}"
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
            '--dry-run' | \
            '--dryrun')
                bool['dryrun']=1
                shift 1
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
    if [[ "${bool['dryrun']}" -eq 1 ]]
    then
        koopa_alert_info 'Dry run mode enabled.'
    fi
    koopa_alert "Fetching objects in '${dict['bucket']}'."
    dict['json']="$( \
        "${app['aws']}" s3api list-objects \
            --bucket "${dict['bucket']}" \
            --no-cli-pager \
            --output 'json' \
            --profile "${dict['profile']}" \
            --query "Contents[?contains(Key,'/.')].Key" \
            --region "${dict['region']}" \
    )"
    if [[ -z "${dict['json']}" ]] || [[ "${dict['json']}" == '[]' ]]
    then
        koopa_alert_note "No dot files in '${dict['bucket']}'."
        return 0
    fi
    readarray -t keys <<< "$( \
        koopa_print "${dict['json']}" \
            | "${app['jq']}" --raw-output '.[]' \
    )"
    koopa_alert_info "$(koopa_ngettext \
        --num="${#keys[@]}" \
        --msg1='object' \
        --msg2='objects' \
        --suffix=' detected.' \
    )"
    for key in "${keys[@]}"
    do
        local s3uri
        s3uri="s3://${dict['bucket']}/${key}"
        koopa_alert "Deleting '${s3uri}'."
        [[ "${bool['dryrun']}" -eq 1 ]] && continue
        "${app['aws']}" s3 rm \
            --profile "${dict['profile']}" \
            --region "${dict['region']}" \
            "$s3uri"
    done
    return 0
}

koopa_aws_s3_find() {
    local -A dict
    local -a exclude_arr include_arr ls_args
    local pattern str
    koopa_assert_has_args "$#"
    dict['exclude']=0
    dict['include']=0
    dict['prefix']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['recursive']=0
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
    local -A app dict
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk)"
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    app['sort']="$(koopa_locate_sort)"
    koopa_assert_is_executable "${app[@]}"
    dict['bucket']=''
    dict['num']='20'
    dict['profile']="${AWS_PROFILE:-default}"
    dict['region']="${AWS_REGION:-us-east-1}"
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
        "${app['aws']}" s3api list-object-versions \
            --bucket "${dict['bucket']}" \
            --output 'json' \
            --profile "${dict['profile']}" \
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
    local -A app dict
    local -a ls_args
    local str
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk)"
    app['aws']="$(koopa_locate_aws)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['recursive']=0
    dict['type']=''
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
        "${app['aws']}" s3 ls \
            --profile "${dict['profile']}" \
            "${ls_args[@]}" \
            "${dict['prefix']}" \
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
    local -A app dict
    local -a files
    local file prefix
    koopa_assert_has_args "$#"
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']=''
    dict['profile']="${AWS_PROFILE:-default}"
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
        local -A dict2
        dict2['bn']="$(koopa_basename "$file")"
        dict2['dn1']="$(koopa_dirname "$file")"
        dict2['dn2']="$(koopa_dirname "${dict2['dn1']}")"
        dict2['target']="${dict2['dn2']}/${dict2['bn']}"
        "${app['aws']}" s3 mv \
            --profile "${dict['profile']}" \
            --recursive \
            "${dict2['file']}" \
            "${dict2['target']}"
    done
    return 0
}

koopa_aws_s3_sync() {
    local -A app dict
    local -a exclude_args exclude_patterns pos sync_args
    local pattern
    koopa_assert_has_args "$#"
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_PROFILE:-default}"
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
    "${app['aws']}" s3 sync \
        --profile "${dict['profile']}" \
        "${exclude_args[@]}" \
        "${sync_args[@]}"
    return 0
}

koopa_basename_sans_ext_2() {
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local str
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
    local file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        local str
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
        local -a pos
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

koopa_bash_prefix() {
    koopa_print "$(koopa_koopa_prefix)/lang/bash"
    return 0
}

koopa_bin_prefix() {
    _koopa_bin_prefix "$@"
}

koopa_bioconda_autobump_recipe() {
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['git']="$(koopa_locate_git --allow-system)"
    app['vim']="$(koopa_locate_vim --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['recipe']="${1:?}"
    dict['repo']="${HOME:?}/git/github/bioconda/bioconda-recipes"
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
    local -A app dict
    koopa_assert_has_args "$#"
    app['bowtie2']="$(koopa_locate_bowtie2)"
    app['tee']="$(koopa_locate_tee)"
    koopa_assert_is_executable "${app[@]}"
    dict['fastq_r1_file']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_file']=''
    dict['fastq_r2_tail']=''
    dict['index_dir']=''
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
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
    local -A dict
    local -a fastq_r1_files
    local fastq_r1_file
    dict['fastq_dir']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_tail']=''
    dict['index_dir']=''
    dict['output_dir']=''
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
    local -A app dict
    local -a index_args
    koopa_assert_has_args "$#"
    app['bowtie2_build']="$(koopa_locate_bowtie2_build)"
    app['tee']="$(koopa_locate_tee)"
    koopa_assert_is_executable "${app[@]}"
    dict['genome_fasta_file']=''
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
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

koopa_brew_doctor() {
    local -A app
    local -a all_checks disabled_checks enabled_checks
    app['brew']="$(koopa_locate_brew)"
    app['sort']="$(koopa_locate_sort --allow-system)"
    app['tr']="$(koopa_locate_tr --allow-system)"
    app['uniq']="$(koopa_locate_uniq --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    disabled_checks=(
        'check_for_stray_dylibs'
        'check_for_stray_headers'
        'check_for_stray_las'
        'check_for_stray_pcs'
        'check_for_stray_static_libs'
        'check_user_path_1'
        'check_user_path_2'
        'check_user_path_3'
    )
    readarray -t all_checks <<< "$("${app['brew']}" doctor --list-checks)"
    readarray -t enabled_checks <<< "$( \
        koopa_print "${all_checks[@]}" "${disabled_checks[@]}" \
            | "${app['tr']}" ' ' '\n' \
            | "${app['sort']}" \
            | "${app['uniq']}" -u \
    )"
    koopa_assert_is_array_non_empty "${enabled_checks[@]}"
    "${app['brew']}" config || true
    "${app['brew']}" doctor "${enabled_checks[@]}" || true
    return 0
}

koopa_brew_dump_brewfile() {
    local -A app
    local today
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    today="$(koopa_today)"
    "${app['brew']}" bundle dump \
        --file="brewfile-${today}" \
        --force
    return 0
}

koopa_brew_outdated() {
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    str="$("${app['brew']}" outdated --quiet)"
    koopa_print "$str"
    return 0
}

koopa_brew_reset_core_repo() {
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['repo']='homebrew/core'
    dict['prefix']="$("${app['brew']}" --repo "${dict['repo']}")"
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_alert "Resetting git repo at '${dict['prefix']}'."
    (
        local -A dict2
        koopa_cd "${dict['prefix']}"
        dict2['branch']="$(koopa_git_default_branch "${PWD:?}")"
        dict2['origin']='origin'
        "${app['git']}" checkout -q "${dict2['branch']}"
        "${app['git']}" branch -q \
            "${dict2['branch']}" \
            -u "${dict2['origin']}/${dict2['branch']}"
        "${app['git']}" reset -q --hard \
            "${dict2['origin']}/${dict2['branch']}"
    )
    return 0
}

koopa_brew_reset_permissions() {
    local -A bool dict
    local -a dirs
    local dir
    koopa_assert_has_no_args "$#"
    koopa_is_linux && return 0
    bool['reset']=0
    dict['group_name']="$(koopa_admin_group_name)"
    dict['prefix']="$(koopa_homebrew_prefix)"
    dict['user_id']="$(koopa_user_id)"
    dict['user_name']="$(koopa_user_name)"
    koopa_alert 'Checking permissions.'
    koopa_assert_is_dir "${dict['prefix']}/Cellar"
    dict['stat_user_id']="$(koopa_stat_user_id "${dict['prefix']}/Cellar")"
    if [[ "${dict['stat_user_id']}" != "${dict['user_id']}" ]]
    then
        koopa_stop "Homebrew is not owned by current user \
('${dict['user_name']}')."
    fi
    dirs=(
        "${dict['prefix']}/bin"
        "${dict['prefix']}/etc"
        "${dict['prefix']}/etc/bash_completion.d"
        "${dict['prefix']}/include"
        "${dict['prefix']}/lib"
        "${dict['prefix']}/lib/pkgconfig"
        "${dict['prefix']}/sbin"
        "${dict['prefix']}/share"
        "${dict['prefix']}/share/doc"
        "${dict['prefix']}/share/info"
        "${dict['prefix']}/share/locale"
        "${dict['prefix']}/share/man"
        "${dict['prefix']}/share/man/man1"
        "${dict['prefix']}/share/man/man3"
        "${dict['prefix']}/share/man/man5"
        "${dict['prefix']}/share/zsh"
        "${dict['prefix']}/share/zsh/site-functions"
        "${dict['prefix']}/var/homebrew/linked"
        "${dict['prefix']}/var/homebrew/locks"
    )
    for dir in "${dirs[@]}"
    do
        [[ "${bool['reset']}" -eq 1 ]] && continue
        [[ -d "$dir" ]] || continue
        [[ "$(koopa_stat_user_id "$dir")" == "${dict['user_id']}" ]] \
            && continue
        bool['reset']=1
    done
    bool['reset']=0 && return 0
    koopa_alert "Resetting ownership of files in \
'${dict['prefix']}' to '${dict['user_name']}:${dict['group_name']}'."
    koopa_chown \
        --no-dereference \
        --recursive \
        --sudo \
        "${dict['user_name']}:${dict['group_name']}" \
        "${dict['prefix']}/"*
    return 0
}

koopa_brew_uninstall_all_brews() {
    local -A app
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    app['wc']="$(koopa_locate_wc)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app
    local -a brews
    local brew
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    koopa_alert 'Checking brews.'
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
    local -A app
    local brew
    koopa_assert_has_args "$#"
    app['brew']="$(koopa_locate_brew)"
    app['jq']="$(koopa_locate_jq)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app
    local prefix
    koopa_assert_has_args "$#"
    app['grep']="$(koopa_locate_grep --allow-system)"
    app['perl']="$(koopa_locate_perl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for prefix in "$@"
    do
        local -A dict
        local -a files header
        local file
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
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['lang_prefix']="${dict['koopa_prefix']}/lang"
    dict['bash_functions']="${dict['lang_prefix']}/bash/functions"
    dict['sh_functions']="${dict['lang_prefix']}/sh/functions"
    koopa_assert_is_dir \
        "${dict['koopa_prefix']}" \
        "${dict['lang_prefix']}" \
        "${dict['bash_functions']}" \
        "${dict['sh_functions']}"
    koopa_cache_functions_dir \
        "${dict['bash_functions']}/activate" \
        "${dict['bash_functions']}/common" \
        "${dict['bash_functions']}/os/linux/alpine" \
        "${dict['bash_functions']}/os/linux/arch" \
        "${dict['bash_functions']}/os/linux/common" \
        "${dict['bash_functions']}/os/linux/debian" \
        "${dict['bash_functions']}/os/linux/fedora" \
        "${dict['bash_functions']}/os/linux/opensuse" \
        "${dict['bash_functions']}/os/linux/rhel" \
        "${dict['bash_functions']}/os/macos" \
        "${dict['sh_functions']}"
    return 0
}

koopa_camel_case() {
    local -a out
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    readarray -t out <<< "$( \
        koopa_gsub \
            --pattern='([ -_])([a-z])' \
            --regex \
            --replacement='\U\2' \
            "$@" \
    )"
    koopa_is_array_non_empty "${out[@]}" || return 1
    koopa_print "${out[@]}"
    return 0
}

koopa_can_install_binary() {
    local -A dict
    dict['credentials']="${HOME:?}/.aws/credentials"
    [[ -f "${dict['credentials']}" ]] || return 1
    koopa_file_detect_fixed \
        --file="${dict['credentials']}" \
        --pattern='acidgenomics' \
        || return 1
    return 0
}

koopa_can_push_binary() {
    [[ -n "${AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" ]] || return 1
    koopa_can_install_binary || return 1
    return 0
}

koopa_capitalize() {
    local -A app
    local str
    app['tr']="$(koopa_locate_tr --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
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

koopa_check_disk() {
    local -A dict
    koopa_assert_has_args "$#"
    dict['limit']=90
    dict['used']="$(koopa_disk_pct_used "$@")"
    if [[ "${dict['used']}" -gt "${dict['limit']}" ]]
    then
        koopa_warn "Disk usage is ${dict['used']}%."
        return 1
    fi
    return 0
}

koopa_check_exports() {
    local -a vars
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

koopa_check_mount() {
    local -A app dict
    koopa_assert_has_args "$#"
    app['wc']="$(koopa_locate_wc --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${1:?}"
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
    local -A app dict
    local -a tool_args
    koopa_assert_has_args "$#"
    dict['file']=''
    dict['name']=''
    dict['prefix']=''
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
    koopa_assert_is_executable "${app[@]}"
    tool_args+=("${dict['file']}")
    "${app['tool']}" "${tool_args[@]}"
    return 0
}

koopa_check_system() {
    koopa_assert_has_no_args "$#"
    koopa_check_exports
    koopa_check_disk '/'
    koopa_r_koopa 'cliCheckSystem'
    koopa_alert_success 'System passed all checks.'
    return 0
}

koopa_chgrp() {
    local -A app dict
    local -a chgrp pos
    app['chgrp']="$(koopa_locate_chgrp)"
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
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        chgrp=('koopa_sudo' "${app['chgrp']}")
    else
        chgrp=("${app['chgrp']}")
    fi
    koopa_assert_is_executable "${app[@]}"
    "${chgrp[@]}" "$@"
    return 0
}

koopa_chmod() {
    local -A app dict
    local -a chmod pos
    app['chmod']="$(koopa_locate_chmod)"
    dict['recursive']=0
    dict['sudo']=0
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
        chmod=('koopa_sudo' "${app['chmod']}")
    else
        chmod=("${app['chmod']}")
    fi
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        chmod+=('-R')
    fi
    koopa_assert_is_executable "${app[@]}"
    "${chmod[@]}" "$@"
    return 0
}

koopa_chown() {
    local -A app dict
    local -a chown pos
    app['chown']="$(koopa_locate_chown)"
    dict['dereference']=1
    dict['recursive']=0
    dict['sudo']=0
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
        chown=('koopa_sudo' "${app['chown']}")
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
    koopa_assert_is_executable "${app[@]}"
    "${chown[@]}" "$@"
    return 0
}

koopa_cli_app() {
    local -A dict
    dict['key']=''
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
                        'list-running-instances' | \
                        'map-instance-ids-to-names' | \
                        'stop')
                            dict['key']="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        'suspend')
                            koopa_defunct 'ec2 stop'
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                'ecr')
                    case "${3:-}" in
                        'login-public' | \
                        'login-private')
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
                        'dot-clean' | \
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
                'build-all-tags' | \
                'prune-all-images' | \
                'prune-old-images' | \
                'remove' | \
                'run')
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
        'kallisto')
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
        'r')
            case "${2:-}" in
                'bioconda-check' | \
                'check')
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
        'salmon')
            case "${2:-}" in
                'index')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
                'quant')
                    case "${3:-}" in
                        'bam' | \
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
    local -a flags pos
    local app stem
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--verbose')
                flags+=("$1")
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
        local -A dict
        dict['key']="${stem}-${app}"
        dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
        if ! koopa_is_function "${dict['fun']}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        if koopa_is_array_non_empty "${flags[@]:-}"
        then
            "${dict['fun']}" "${flags[@]:-}"
        else
            "${dict['fun']}"
        fi
    done
    return 0
}

koopa_cli_install() {
    local -A dict
    local -a flags pos
    local app
    koopa_assert_has_args "$#"
    dict['stem']='install'
    case "${1:-}" in
        'all')
            shift 1
            case "${1:-}" in
                'default' | 'supported')
                    dict['fun']="koopa_install_all_${1:?}"
                    koopa_assert_is_function "${dict['fun']}"
                    shift 1
                    "${dict['fun']}" "$@"
                    return 0
                    ;;
                *)
                    koopa_stop 'Unsupported mode.'
                    ;;
                esac
            ;;
        'koopa')
            shift 1
            koopa_install_koopa "$@"
            return 0
            ;;
        'private' | 'system' | 'user')
            dict['stem']="${dict['stem']}-${1:?}"
            shift 1
            ;;
        'app' | 'shared-apps')
            koopa_stop 'Unsupported command.'
            ;;
        '--all')
            koopa_defunct 'koopa install all default'
            ;;
    esac
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--binary' | \
            '--bootstrap' | \
            '--push' | \
            '--reinstall' | \
            '--verbose')
                flags+=("$1")
                shift 1
                ;;
            '-'*)
                if [[ "${bool['allow_custom_args']}" -eq 1 ]]
                then
                    bool['custom_args_enabled']=1
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
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        local -A dict2
        dict2['app']="$app"
        dict2['key']="${dict['stem']}-${dict2['app']}"
        dict2['fun']="$(koopa_which_function "${dict2['key']}" || true)"
        if ! koopa_is_function "${dict2['fun']}"
        then
            koopa_stop "Unsupported app: '${dict2['app']}'."
        fi
        if koopa_is_array_non_empty "${flags[@]:-}"
        then
            "${dict2['fun']}" "${flags[@]}"
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
    local -A dict
    local -a pos
    koopa_assert_has_args "$#"
    dict['mode']='default'
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--all')
                koopa_invalid_arg "$1"
                ;;
            '--all-revdeps')
                dict['mode']='all-revdeps'
                shift 1
                ;;
            '--only-revdeps')
                dict['mode']='only-revdeps'
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    case "${dict['mode']}" in
        'all-revdeps' | \
        'all-reverse-dependencies')
            koopa_reinstall_all_revdeps "$@"
            ;;
        'default')
            koopa_cli_install --reinstall "$@"
            ;;
        'only-revdeps' | \
        'only-reverse-dependencies')
            koopa_reinstall_only_revdeps "$@"
            ;;
    esac
    return 0
}

koopa_cli_system() {
    local -A dict
    dict['key']=''
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
    local -a flags pos
    local app stem
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--verbose')
                flags+=("$1")
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
    else
        set -- 'koopa'
    fi
    stem='uninstall'
    case "$1" in
        'private' | \
        'system' | \
        'user')
            stem="${stem}-${1}"
            shift 1
            ;;
    esac
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        local -A dict
        dict['key']="${stem}-${app}"
        dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
        if ! koopa_is_function "${dict['fun']}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        if koopa_is_array_non_empty "${flags[@]:-}"
        then
            "${dict['fun']}" "${flags[@]:-}"
        else
            "${dict['fun']}"
        fi
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
        local -A dict
        dict['key']="${stem}-${app}"
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
    local -A dict
    koopa_assert_has_args "$#"
    dict['nested']=0
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
    local -A dict
    local -a rsync_args
    koopa_assert_has_args_eq "$#" 2
    koopa_assert_has_no_flags "$@"
    dict['source_dir']="${1:?}"
    dict['target_dir']="${2:?}"
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

koopa_cmake_build() {
    local -A app dict
    local -a build_deps cmake_args cmake_std_args pos
    koopa_assert_has_args "$#"
    build_deps=('cmake')
    app['cmake']="$(koopa_locate_cmake)"
    koopa_assert_is_executable "${app[@]}"
    dict['bin_dir']=''
    dict['generator']='Unix Makefiles'
    dict['include_dir']=''
    dict['jobs']="$(koopa_cpu_count)"
    dict['lib_dir']=''
    dict['prefix']=''
    dict['source_dir']="$(koopa_realpath "${PWD:?}")"
    dict['build_dir']="$( \
        koopa_init_dir "${dict['source_dir']}-cmake-$(koopa_random_string)" \
    )"
    cmake_std_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--bin-dir='*)
                dict['bin_dir']="${1#*=}"
                shift 1
                ;;
            '--bin-dir')
                dict['bin_dir']="${2:?}"
                shift 2
                ;;
            '--include-dir='*)
                dict['include_dir']="${1#*=}"
                shift 1
                ;;
            '--include-dir')
                dict['include_dir']="${2:?}"
                shift 2
                ;;
            '--jobs='*)
                dict['jobs']="${1#*=}"
                shift 1
                ;;
            '--jobs')
                dict['jobs']="${2:?}"
                shift 2
                ;;
            '--lib-dir='*)
                dict['lib_dir']="${1#*=}"
                shift 1
                ;;
            '--lib-dir')
                dict['lib_dir']="${2:?}"
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
            '--ninja')
                dict['generator']='Ninja'
                shift 1
                ;;
            '-D'*)
                pos+=("$1")
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_set '--prefix' "${dict['prefix']}"
    cmake_std_args+=("--prefix=${dict['prefix']}")
    [[ -n "${dict['bin_dir']}" ]] && \
        cmake_std_args+=("--bin-dir=${dict['bin_dir']}")
    [[ -n "${dict['include_dir']}" ]] && \
        cmake_std_args+=("--include-dir=${dict['include_dir']}")
    [[ -n "${dict['lib_dir']}" ]] && \
        cmake_std_args+=("--lib-dir=${dict['lib_dir']}")
    readarray -t cmake_args <<< "$(koopa_cmake_std_args "${cmake_std_args[@]}")"
    [[ "$#" -gt 0 ]] && cmake_args+=("$@")
    case "${dict['generator']}" in
        'Ninja')
            build_deps+=('ninja')
            ;;
        'Unix Makefiles')
            build_deps+=('make')
            ;;
        *)
            koopa_stop 'Unsupported generator.'
            ;;
    esac
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_print_env
    koopa_dl \
        'CMake args' "${cmake_args[*]}" \
        'build dir' "${dict['build_dir']}" \
        'source dir' "${dict['source_dir']}"
    "${app['cmake']}" -LH \
        '-B' "${dict['build_dir']}" \
        '-G' "${dict['generator']}" \
        '-S' "${dict['source_dir']}" \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build "${dict['build_dir']}" \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" \
        --install "${dict['build_dir']}" \
        --prefix "${dict['prefix']}"
    koopa_rm "${dict['build_dir']}"
    return 0
}

koopa_cmake_std_args() {
    local -A dict
    local -a args
    koopa_assert_has_args "$#"
    dict['bin_dir']=''
    dict['include_dir']=''
    dict['lib_dir']=''
    dict['prefix']=''
    dict['rpath']=''
    while (("$#"))
    do
        case "$1" in
            '--bin-dir='*)
                dict['bin_dir']="${1#*=}"
                shift 1
                ;;
            '--bin-dir')
                dict['bin_dir']="${2:?}"
                shift 2
                ;;
            '--include-dir='*)
                dict['include_dir']="${1#*=}"
                shift 1
                ;;
            '--include-dir')
                dict['include_dir']="${2:?}"
                shift 2
                ;;
            '--lib-dir='*)
                dict['lib_dir']="${1#*=}"
                shift 1
                ;;
            '--lib-dir')
                dict['lib_dir']="${2:?}"
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
            '--rpath='*)
                dict['rpath']="${1#*=}"
                shift 1
                ;;
            '--rpath')
                dict['rpath']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--prefix' "${dict['prefix']}"
    [[ -z "${dict['bin_dir']}" ]] && \
        dict['bin_dir']="${dict['prefix']}/bin"
    [[ -z "${dict['include_dir']}" ]] && \
        dict['include_dir']="${dict['prefix']}/include"
    [[ -z "${dict['lib_dir']}" ]] && \
        dict['lib_dir']="${dict['prefix']}/lib"
    [[ -z "${dict['rpath']}" ]] && \
        dict['rpath']="${dict['prefix']}/lib"
    args=(
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CXXFLAGS:-} ${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-} ${CPPFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_BINDIR=${dict['bin_dir']}"
        "-DCMAKE_INSTALL_INCLUDEDIR=${dict['include_dir']}"
        "-DCMAKE_INSTALL_LIBDIR=${dict['lib_dir']}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['rpath']}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
    )
    if koopa_is_macos
    then
        dict['sdk_prefix']="$(koopa_macos_sdk_prefix)"
        koopa_assert_is_dir "${dict['sdk_prefix']}"
        dict['sdk_prefix']="$(koopa_realpath "${dict['sdk_prefix']}")"
        args+=(
            '-DCMAKE_MACOSX_RPATH=ON'
            "-DCMAKE_OSX_SYSROOT=${dict['sdk_prefix']}"
        )
    fi
    koopa_print "${args[@]}"
    return 0
}

koopa_compress_ext_pattern() {
    local -a formats
    local str
    koopa_assert_has_no_args "$#"
    formats=('7z' 'br' 'bz2' 'gz' 'lz' 'lz4' 'lzma' 'xz' 'z' 'zip' 'zst')
    str="$(koopa_paste --sep='|' "${formats[@]}")"
    str="\.(${str})\$"
    koopa_print "$str"
    return 0
}

koopa_conda_activate_env() { # {{{1
    local -A bool dict
    koopa_assert_has_args_eq "$#" 1
    if koopa_is_conda_env_active
    then
        koopa_stop 'Conda environment is already active.'
    fi
    bool['nounset']="$(koopa_boolean_nounset)"
    dict['env']="${1:?}"
    [[ "${bool['nounset']}" -eq 1 ]] && set +u
    koopa_activate_conda
    conda activate "${dict['env']}"
    [[ "${bool['nounset']}" -eq 1 ]] && set -u
    return 0
}

koopa_conda_bin() {
    local cmd file
    koopa_assert_has_args_eq "$#" 1
    file="${1:?}"
    koopa_assert_is_file "$file"
    cmd="$(koopa_koopa_prefix)/lang/python/conda-bin.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$file"
    return 0
}

koopa_conda_create_env() {
    local -A app dict
    local -a pos
    local string
    koopa_assert_has_args "$#"
    app['conda']="$(koopa_locate_conda)"
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['env_prefix']="$(koopa_conda_env_prefix)"
    dict['force']=0
    dict['latest']=0
    dict['prefix']=''
    dict['yaml_file']=''
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
        local -A dict2
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
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['env_name']="${CONDA_DEFAULT_ENV:-}"
    dict['nounset']="$(koopa_boolean_nounset)"
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
    local -A app dict
    local str
    koopa_assert_has_args_eq "$#" 1
    app['awk']="$(koopa_locate_awk)"
    app['conda']="$(koopa_locate_conda)"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    dict['env_name']="${1:?}"
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
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['conda']="$(koopa_locate_conda)"
    koopa_assert_is_executable "${app[@]}"
    str="$("${app['conda']}" env list --json --quiet)"
    koopa_print "$str"
    return 0
}

koopa_conda_env_prefix() {
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['conda']="$(koopa_locate_conda)"
    app['python']="$(koopa_locate_conda_python)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    app['tail']="$(koopa_locate_tail --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['env_name']="${1:-}"
    dict['env_prefix']="$( \
        "${app['conda']}" info --json \
        | "${app['python']}" -c \
            "import json,sys;print(json.load(sys.stdin)['envs_dirs'][0])" \
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
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['conda']="$(koopa_locate_conda)"
    app['python']="$(koopa_locate_conda_python)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$( \
        "${app['conda']}" info --json \
        | "${app['python']}" -c \
            "import json,sys;print(json.load(sys.stdin)['pkgs_dirs'][0])" \
    )"
    [[ -n "${dict['prefix']}" ]] || return 1
    koopa_print "${dict['prefix']}"
    return 0
}

koopa_conda_remove_env() {
    local -A app dict
    local name
    koopa_assert_has_args "$#"
    app['conda']="$(koopa_locate_conda)"
    koopa_assert_is_executable "${app[@]}"
    dict['nounset']="$(koopa_boolean_nounset)"
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

koopa_configure_app() {
    local -A bool dict
    local -a pos
    bool['verbose']=0
    dict['config_fun']='main'
    dict['mode']='shared'
    dict['name']=''
    dict['platform']='common'
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
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
                shift 2
                ;;
            '--verbose')
                bool['verbose']=1
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
            '-*')
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_set '--name' "${dict['name']}"
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        export KOOPA_VERBOSE=1
        set -o xtrace
    fi
    case "${dict['mode']}" in
        'shared')
            koopa_assert_is_owner
            ;;
        'system')
            koopa_assert_is_owner
            koopa_assert_is_admin
            ;;
    esac
    dict['config_file']="$(koopa_bash_prefix)/include/configure/\
${dict['platform']}/${dict['mode']}/${dict['name']}.sh"
    koopa_assert_is_file "${dict['config_file']}"
    dict['tmp_dir']="$(koopa_tmp_dir)"
    (
        case "${dict['mode']}" in
            'system')
                koopa_add_to_path_end '/usr/sbin' '/sbin'
                ;;
        esac
        koopa_cd "${dict['tmp_dir']}"
        source "${dict['config_file']}"
        koopa_assert_is_function "${dict['config_fun']}"
        "${dict['config_fun']}" "$@"
    )
    koopa_rm "${dict['tmp_dir']}"
    return 0
}

koopa_configure_r() {
    koopa_configure_app \
        --name='r' \
        "$@"
}

koopa_configure_system_r() {
    local -A app
    app['r']="$(koopa_locate_system_r)"
    koopa_assert_is_executable "${app[@]}"
    koopa_configure_r "${app['r']}"
    return 0
}

koopa_configure_user_dotfiles() {
    koopa_configure_app \
        --name='dotfiles' \
        --user \
        "$@"
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
    local -A app dict
    local -a fastq_files
    local fastq_file
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['paste']="$(koopa_locate_paste)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    app['tr']="$(koopa_locate_tr)"
    koopa_assert_is_executable "${app[@]}"
    dict['source_dir']=''
    dict['target_dir']=''
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
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['perl']="$(koopa_locate_perl)"
    koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        "${app['perl']}" -pe 's/\r$//g' < "$file" > "${file}.tmp"
        koopa_mv "${file}.tmp" "$file"
    done
    return 0
}

koopa_convert_line_endings_from_lf_to_crlf() {
    local -A app
    local file
    koopa_assert_has_ars "$#"
    app['perl']="$(koopa_locate_perl)"
    koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        "${app['perl']}" -pe 's/(?<!\r)\n/\r\n/g' < "$file" > "${file}.tmp"
        koopa_mv "${file}.tmp" "$file"
    done
    return 0
}

koopa_convert_sam_to_bam() {
    local -A bool dict
    local -a pos sam_files
    local sam_file
    bool['keep_sam']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--keep-sam')
                bool['keep_sam']=1
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
    dict['prefix']="${1:?}"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    readarray -t sam_files <<< "$( \
        koopa_find \
            --max-depth=3 \
            --min-depth=1 \
            --pattern='*.sam' \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='f' \
    )"
    if ! koopa_is_array_non_empty "${sam_files[@]:-}"
    then
        koopa_stop "No SAM files detected in '${dict['prefix']}'."
    fi
    koopa_alert "Converting SAM files in '${dict['prefix']}' to BAM format."
    if [[ "${bool['keep_sam']}" -eq 1 ]]
    then
        koopa_alert_note 'SAM files will be preserved.'
    else
        koopa_alert_note 'SAM files will be deleted.'
    fi
    for sam_file in "${sam_files[@]}"
    do
        local bam_file
        bam_file="${sam_file%.sam}.bam"
        koopa_samtools_convert_sam_to_bam \
            --input-sam="$sam_file" \
            --output-bam="$bam_file"
        if [[ "${bool['keep_sam']}" -eq 0 ]]
        then
            koopa_rm "$sam_file"
        fi
    done
    return 0
}

koopa_convert_utf8_nfd_to_nfc() {
    local -A app
    koopa_assert_has_args "$#"
    app['convmv']="$(koopa_locate_convmv)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    local -a cp cp_args mkdir pos rm
    app['cp']="$(koopa_locate_cp --allow-system)"
    dict['sudo']=0
    dict['symlink']=0
    dict['target_dir']=''
    dict['verbose']=0
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
            '--quiet' | \
            '-q')
                dict['verbose']=0
                shift 1
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
            '--verbose' | \
            '-v')
                dict['verbose']=1
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
        cp=('koopa_sudo' "${app['cp']}")
        mkdir=('koopa_mkdir' '--sudo')
        rm=('koopa_rm' '--sudo')
    else
        cp=("${app['cp']}")
        mkdir=('koopa_mkdir')
        rm=('koopa_rm')
    fi
    cp_args=(
        '-f'
        '-r'
    )
    [[ "${dict['symlink']}" -eq 1 ]] && cp_args+=('-s')
    [[ "${dict['verbose']}" -eq 1 ]] && cp_args+=('-v')
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
    koopa_assert_is_executable "${app[@]}"
    "${cp[@]}" "${cp_args[@]}"
    return 0
}

koopa_cpu_count() {
    _koopa_cpu_count "$@"
}

koopa_current_bcbio_nextgen_version() {
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['tail']="$(koopa_locate_tail --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['curl']="$(koopa_locate_curl --allow-system)"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['grep']="$(koopa_locate_grep --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['organism']="${1:-}"
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
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['url']="ftp://ftp.wormbase.org/pub/wormbase/\
releases/current-production-release"
    dict['string']="$( \
        koopa_parse_url --list-only "${dict['url']}/" \
            | koopa_grep \
                --only-matching \
                --pattern='letter.WS[0-9]+' \
                --regex \
            | "${app['cut']}" -d '.' -f '2' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}

koopa_datetime() {
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['date']="$(koopa_locate_date --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    str="$("${app['date']}" '+%Y%m%d-%H%M%S')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_decompress() {
    local -A app bool dict
    local -a cmd_args pos
    koopa_assert_has_args "$#"
    bool['passthrough']=0
    bool['stdout']=0
    dict['compress_ext_pattern']="$(koopa_compress_ext_pattern)"
    while (("$#"))
    do
        case "$1" in
            '--stdout')
                bool['stdout']=1
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
    dict['source_file']="$(koopa_realpath "${dict['source_file']}")"
    dict['match']="$(koopa_basename "${dict['source_file']}" | koopa_lowercase)"
    case "${dict['match']}" in
        *'.z')
            koopa_stop "Use 'uncompress' directly on '.Z' files."
            ;;
        *'.7z' | \
        *'.a' | \
        *'.tar' | \
        *'.tar.'* | \
        *'.tbz2' | \
        *'.tgz' | \
        *'.zip')
            koopa_stop \
                "Unsupported archive file: '${dict['source_file']}'." \
                "Use 'koopa_extract' instead of 'koopa_decompress'."
            ;;
        *'.br' | \
        *'.bz2' | \
        *'.gz' | \
        *'.lz' | \
        *'.lz4' | \
        *'.lzma' | \
        *'.xz' | \
        *'.zstd')
            bool['passthrough']=0
            ;;
        *)
            bool['passthrough']=1
            ;;
    esac
    if [[ "${bool['stdout']}" -eq 1 ]]
    then
        if [[ -n "${dict['target_file']}" ]]
        then
            koopa_stop 'Target file is not supported for --stdout mode.'
        fi
    else
        if [[ -z "${dict['target_file']}" ]]
        then
            dict['target_file']="$( \
                koopa_sub \
                    --pattern="${dict['compress_ext_pattern']}" \
                    --regex \
                    --replacement='' \
                    "${dict['source_file']}" \
            )"
        fi
        if [[ "${dict['source_file']}" == "${dict['target_file']}" ]]
        then
            return 0
        fi
    fi
    if [[ "${bool['passthrough']}" -eq 1 ]]
    then
        if [[ "${bool['stdout']}" -eq 1 ]]
        then
            app['cat']="$(koopa_locate_cat --allow-system)"
            koopa_assert_is_executable "${app['cat']}"
            "${app['cat']}" "${dict['source_file']}" || true
        else
            koopa_alert "Passthrough mode. Copying '${dict['source_file']}' to \
'${dict['target_file']}'."
            koopa_cp "${dict['source_file']}" "${dict['target_file']}"
        fi
        return 0
    fi
    case "${dict['match']}" in
        *'.br' | \
        *'.bz2' | \
        *'.gz' | \
        *'.lz' | \
        *'.lz4' | \
        *'.lzma' | \
        *'.xz' | \
        *'.zstd')
            case "${dict['match']}" in
                *'.br')
                    app['cmd']="$(koopa_locate_brotli --allow-system)"
                    ;;
                *'.bz2')
                    app['cmd']="$( \
                        koopa_locate_pbzip2 --allow-missing --allow-system \
                    )"
                    if [[ -x "${app['cmd']}" ]]
                    then
                        cmd_args+=("-p$(koopa_cpu_count)")
                    else
                        app['cmd']="$(koopa_locate_bzip2 --allow-system)"
                    fi
                    ;;
                *'.gz')
                    app['cmd']="$( \
                        koopa_locate_pigz --allow-missing --allow-system \
                    )"
                    if [[ -x "${app['cmd']}" ]]
                    then
                        cmd_args+=('-p' "$(koopa_cpu_count)")
                    else
                        app['cmd']="$(koopa_locate_gzip --allow-system)"
                    fi
                    ;;
                *'.lz')
                    app['cmd']="$(koopa_locate_lzip --allow-system)"
                    ;;
                *'.lz4')
                    app['cmd']="$(koopa_locate_lz4 --allow-system)"
                    ;;
                *'.lzma')
                    app['cmd']="$(koopa_locate_lzma --allow-system)"
                    ;;
                *'.xz')
                    app['cmd']="$(koopa_locate_xz --allow-system)"
                    ;;
                *'.zstd')
                    app['cmd']="$(koopa_locate_zstd --allow-system)"
                    ;;
            esac
            cmd_args+=(
                '-c'
                '-d'
                '-f'
                '-k'
                "${dict['source_file']}"
            )
            ;;
    esac
    koopa_assert_is_executable "${app['cmd']}"
    if [[ "${bool['stdout']}" -eq 1 ]]
    then
        "${app['cmd']}" "${cmd_args[@]}" || true
    else
        koopa_alert "Decompressing '${dict['source_file']}' to \
'${dict['target_file']}'."
        "${app['cmd']}" "${cmd_args[@]}" > "${dict['target_file']}"
    fi
    koopa_assert_is_file "${dict['source_file']}"
    if [[ -n "${dict['target_file']}" ]]
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
    local prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local -a files
        local file
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
    local -A dict
    local -a pos
    local name
    koopa_assert_has_args "$#"
    dict['config']=0
    dict['xdg_config_home']="$(koopa_xdg_config_home)"
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
    local prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        while [[ -d "$prefix" ]] && \
            [[ -n "$(koopa_find_empty_dirs "$prefix")" ]]
        do
            local -a dirs
            local dir
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
    local -A dict
    local -a matches
    koopa_assert_has_args_eq "$#" 2
    dict['prefix']="${1:?}"
    dict['subdir_name']="${2:?}"
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
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['vim']="$(koopa_locate_vim)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app
    app['df']="$(koopa_locate_df)"
    koopa_assert_is_executable "${app[@]}"
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
        local -a pos
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
    local -A dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    dict['group']="$(koopa_admin_group_name)"
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
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['df']="$(koopa_locate_df --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['disk']="${1:?}"
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
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['df']="$(koopa_locate_df --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['df']="$(koopa_locate_df --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['df']="$(koopa_locate_df --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['df']="$(koopa_locate_df --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
        koopa_msg 'default' 'default' "${1:?}:" "${2:-}"
        shift 2
    done
    return 0
}

koopa_docker_build_all_tags() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDockerBuildAllTags' "$@"
    return 0
}

koopa_docker_build() {
    local -A app dict
    local -a build_args image_ids platforms tags
    local tag
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut)"
    app['date']="$(koopa_locate_date)"
    app['docker']="$(koopa_locate_docker)"
    app['sort']="$(koopa_locate_sort)"
    koopa_assert_is_executable "${app[@]}"
    dict['default_tag']='latest'
    dict['delete']=1
    dict['local_dir']=''
    dict['memory']=''
    dict['push']=1
    dict['remote_url']=''
    while (("$#"))
    do
        case "$1" in
            '--local='*)
                dict['local_dir']="${1#*=}"
                shift 1
                ;;
            '--local')
                dict['local_dir']="${2:?}"
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
            '--remote='*)
                dict['remote_url']="${1#*=}"
                shift 1
                ;;
            '--remote')
                dict['remote_url']="${2:?}"
                shift 2
                ;;
            '--no-push')
                dict['push']=0
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--local' "${dict['local_dir']}" \
        '--remote' "${dict['remote_url']}"
    koopa_assert_is_dir "${dict['local_dir']}"
    koopa_assert_is_file "${dict['local_dir']}/Dockerfile"
    build_args=()
    platforms=()
    tags=()
    if ! koopa_str_detect_fixed \
        --string="${dict['remote_url']}" \
        --pattern=':'
    then
        dict['remote_url']="${dict['remote_url']}:${dict['default_tag']}"
    fi
    koopa_assert_is_matching_regex \
        --pattern='^(.+)/(.+)/(.+):(.+)$' \
        --string="${dict['remote_url']}"
    dict['remote_str']="$( \
        koopa_sub \
            --fixed \
            --pattern=':' \
            --replacement='/' \
            "${dict['remote_url']}"
    )"
    dict['server']="$( \
        koopa_print "${dict['remote_str']}" \
        | "${app['cut']}" -d '/' -f '1' \
    )"
    dict['image_name']="$( \
        koopa_print "${dict['remote_str']}" \
        | "${app['cut']}" -d '/' -f '1-3' \
    )"
    dict['tag']="$( \
        koopa_print "${dict['remote_str']}" \
        | "${app['cut']}" -d '/' -f '4' \
    )"
    if [[ "${dict['push']}" -eq 1 ]]
    then
        case "${dict['server']}" in
            *'.dkr.ecr.'*'.amazonaws.com')
                koopa_aws_ecr_login_private
                ;;
            'public.ecr.aws')
                koopa_aws_ecr_login_public
                ;;
            *)
                koopa_alert "Logging into '${dict['server']}'."
                "${app['docker']}" logout "${dict['server']}" \
                    >/dev/null || true
                "${app['docker']}" login "${dict['server']}" \
                    >/dev/null || return 1
                ;;
        esac
    fi
    dict['tags_file']="${dict['local_dir']}/tags.txt"
    if [[ -f "${dict['tags_file']}" ]]
    then
        readarray -t tags < "${dict['tags_file']}"
    fi
    if [[ -L "${dict['local_dir']}" ]]
    then
        tags+=("${dict['tag']}")
        dict['local_dir']="$(koopa_realpath "${dict['local_dir']}")"
        dict['tag']="$(koopa_basename "${dict['local_dir']}")"
    fi
    tags+=(
        "${dict['tag']}"
        "${dict['tag']}-$(${app['date']} '+%Y%m%d')"
    )
    readarray -t tags <<< "$( \
        koopa_print "${tags[@]}" \
        | "${app['sort']}" -u \
    )"
    for tag in "${tags[@]}"
    do
        build_args+=("--tag=${dict['image_name']}:${tag}")
    done
    platforms=('linux/amd64')
    dict['platforms_file']="${dict['local_dir']}/platforms.txt"
    if [[ -f "${dict['platforms_file']}" ]]
    then
        readarray -t platforms < "${dict['platforms_file']}"
    fi
    dict['platforms_string']="$(koopa_paste --sep=',' "${platforms[@]}")"
    build_args+=("--platform=${dict['platforms_string']}")
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
    build_args+=("${dict['local_dir']}")
    if [[ "${dict['delete']}" -eq 1 ]]
    then
        koopa_alert "Pruning images '${dict['remote_url']}'."
        readarray -t image_ids <<< "$( \
            "${app['docker']}" image ls \
                --filter reference="${dict['remote_url']}" \
                --quiet \
        )"
        if koopa_is_array_non_empty "${image_ids[@]:-}"
        then
            "${app['docker']}" image rm --force "${image_ids[@]}"
        fi
    fi
    koopa_alert "Building '${dict['remote_url']}' Docker image."
    koopa_dl 'Build args' "${build_args[*]}"
    dict['build_name']="$(koopa_basename "${dict['image_name']}")"
    "${app['docker']}" buildx rm \
        "${dict['build_name']}" \
        &>/dev/null \
        || true
    "${app['docker']}" buildx create \
        --name="${dict['build_name']}" \
        --use \
        >/dev/null
    "${app['docker']}" buildx build "${build_args[@]}"
    "${app['docker']}" buildx rm "${dict['build_name']}"
    "${app['docker']}" image ls \
        --filter \
        reference="${dict['remote_url']}"
    if [[ "${dict['push']}" -eq 1 ]]
    then
        "${app['docker']}" logout "${dict['server']}" \
            >/dev/null || true
    fi
    koopa_alert_success "Build of '${dict['remote_url']}' was successful."
    return 0
}

koopa_docker_ghcr_login() {
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    dict['pat']="${GHCR_PAT:?}"
    dict['server']='ghcr.io'
    dict['user']="${GHCR_USER:?}"
    koopa_print "${dict['pat']}" \
        | "${app['docker']}" login \
            "${dict['server']}" \
            -u "${dict['user']}" \
            --password-stdin
    return 0
}

koopa_docker_ghcr_push() {
    local -A app dict
    koopa_assert_has_args_eq "$#" 3
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    dict['image_name']="${2:?}"
    dict['owner']="${1:?}"
    dict['server']='ghcr.io'
    dict['version']="${3:?}"
    dict['url']="${dict['server']}/${dict['owner']}/\
${dict['image_name']}:${dict['version']}"
    koopa_docker_ghcr_login
    "${app['docker']}" push "${dict['url']}"
    return 0
}

koopa_docker_is_build_recent() {
    local -A app dict
    local -a pos
    local image
    koopa_assert_has_args "$#"
    app['date']="$(koopa_locate_date)"
    app['docker']="$(koopa_locate_docker)"
    app['sed']="$(koopa_locate_sed)"
    koopa_assert_is_executable "${app[@]}"
    dict['days']=7
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
        local -A dict2
        dict['current']="$("${app['date']}" -u '+%s')"
        dict['image']="$image"
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
    local -A app
    koopa_assert_has_no_args "$#"
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    koopa_alert 'Pruning Docker buildx.'
    "${app['docker']}" buildx prune --all --force --verbose || true
    koopa_alert 'Pruning Docker images.'
    "${app['docker']}" system prune --all --force || true
    "${app['docker']}" images
    return 0
}

koopa_docker_prune_old_images() {
    local -A app
    koopa_assert_has_no_args "$#"
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    koopa_alert 'Pruning Docker images older than 3 months.'
    "${app['docker']}" image prune \
        --all \
        --filter 'until=2160h' \
        --force \
        || true
    "${app['docker']}" image prune --force || true
    return 0
}

koopa_docker_remove() {
    local -A app
    local pattern
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk)"
    app['docker']="$(koopa_locate_docker)"
    app['xargs']="$(koopa_locate_xargs)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    local -a pos run_args
    koopa_assert_has_args "$#"
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    dict['arm']=0
    dict['bash']=0
    dict['bind']=0
    dict['workdir']='/mnt/work'
    dict['x86']=0
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
    case "${dict['image']}" in
        *'.dkr.ecr.'*'.amazonaws.com/'*)
            koopa_aws_ecr_login_private
            ;;
        'public.ecr.aws/'*)
            if [[ -n "${AWS_ECR_PROFILE:-}" ]]
            then
                koopa_aws_ecr_login_public
            fi
            ;;
    esac
    "${app['docker']}" pull "${dict['image']}"
    run_args=('--interactive' '--tty')
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

koopa_doom_emacs_prefix() {
    _koopa_doom_emacs_prefix "$@"
}

koopa_dot_clean() {
    local -A app dict
    local -a basenames cruft files
    local i
    koopa_assert_has_args_eq "$#" 1
    dict['prefix']="${1:?}"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    if koopa_is_macos
    then
        app['dot_clean']="$(koopa_macos_locate_dot_clean)"
        koopa_assert_is_executable "${app['dot_clean']}"
        "${app['dot_clean']}" "${dict['prefix']}"
    fi
    readarray -t files <<< "$( \
        koopa_find \
            --hidden \
            --pattern='.*' \
            --prefix="${dict['prefix']}" \
    )"
    if koopa_is_array_empty "${files[@]}"
    then
        return 0
    fi
    cruft=()
    readarray -t basenames <<< "$(koopa_basename "${files[@]}")"
    for i in "${!files[@]}"
    do
        local basename file
        file="${files[$i]}"
        [[ -e "$file" ]] || continue
        basename="${basenames[$i]}"
        case "$basename" in
            '.AppleDouble' | \
            '.DS_Store' | \
            '.Rhistory' | \
            '.lacie' | \
            '._'*)
                koopa_rm --verbose "$file"
                ;;
            *)
                cruft+=("$file")
                ;;
        esac
    done
    if koopa_is_array_non_empty "${cruft[@]}"
    then
        koopa_alert_note "Dot files remaining in '${dict['prefix']}'."
        koopa_print "${cruft[@]}"
        return 1
    fi
    return 0
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
    local -A app
    local name
    koopa_assert_has_args "$#"
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for name in "$@"
    do
        local file pattern url
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
    local -A app
    local repo
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['tr']="$(koopa_locate_tr --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for repo in "$@"
    do
        local api_url tag tarball_url
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
    local -A app bool dict
    local -a curl_args pos
    koopa_assert_has_args "$#"
    app['curl']="$(koopa_locate_curl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['decompress']=0
    bool['extract']=0
    bool['progress']=1
    dict['user_agent']="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; \
rv:109.0) Gecko/20100101 Firefox/111.0"
    pos=()
    while (("$#"))
    do
        case "$1" in
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
    dict['url']="${1:?}"
    dict['file']="${2:-}"
    if [[ -z "${dict['file']}" ]]
    then
        dict['file']="$(koopa_basename "${dict['url']}")"
        if ! koopa_str_detect_fixed --string="${dict['file']}" --pattern='.'
        then
            dict['head']="$( \
                "${app['curl']}" \
                    --disable \
                    --head \
                    --silent \
                    "${dict['url']}" \
            )"
            if koopa_str_detect_fixed \
                --string="${dict['head']}" \
                --pattern='X-Filename: '
            then
                app['cut']="$(koopa_locate_cut --allow-system)"
                koopa_assert_is_executable "${app['cut']}"
                dict['file']="$( \
                    koopa_grep \
                        --string="${dict['head']}" \
                        --pattern='X-Filename: ' \
                    | "${app['cut']}" -d ' ' -f 2 \
                    | koopa_sub \
                        --pattern='\r$' \
                        --regex \
                        --replacement='' \
                    | koopa_basename \
                )"
            fi
        fi
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
    if ! koopa_str_detect_fixed --string="${dict['file']}" --pattern='/'
    then
        dict['file']="${PWD:?}/${dict['file']}"
    fi
    curl_args+=(
        '--disable' # Ignore '~/.curlrc'. Must come first.
        '--create-dirs'
        '--fail'
        '--location'
        '--output' "${dict['file']}"
        '--retry' 5
        '--show-error'
    )
    case "${dict['url']}" in
        *'sourceforge.net/'*)
            ;;
        *)
            curl_args+=('--user-agent' "${dict['user_agent']}")
            ;;
    esac
    if [[ "${bool['progress']}" -eq 0 ]]
    then
        curl_args+=('--silent')
    fi
    curl_args+=("${dict['url']}")
    koopa_alert "Downloading '${dict['url']}' to '${dict['file']}'."
    "${app['curl']}" "${curl_args[@]}"
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
    local -A dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    dict['group']="$(koopa_admin_group_name)"
    dict['file']="/etc/sudoers.d/koopa-${dict['group']}"
    if [[ -e "${dict['file']}" ]]
    then
        koopa_alert_success "Passwordless sudo for '${dict['group']}' group \
already enabled at '${dict['file']}'."
        return 0
    fi
    koopa_alert "Modifying '${dict['file']}' to include '${dict['group']}'."
    dict['string']="%${dict['group']} ALL=(ALL:ALL) NOPASSWD:ALL"
    koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    koopa_chmod --sudo '0440' "${dict['file']}"
    koopa_alert_success "Passwordless sudo enabled for '${dict['group']}' \
at '${dict['file']}'."
    return 0
}

koopa_enable_shell_for_all_users() {
    local -A dict
    local -a apps
    local app
    koopa_assert_has_args "$#"
    koopa_is_admin || return 0
    dict['etc_file']='/etc/shells'
    dict['user']="$(koopa_user_name)"
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
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    dict['file']="${1:?}"
    [[ -n "$("${app['tail']}" --bytes=1 "${dict['file']}")" ]] || return 0
    printf '\n' >> "${dict['file']}"
    return 0
}

koopa_entab() {
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['vim']="$(koopa_locate_vim)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app
    local file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    app['perl']="$(koopa_locate_perl)"
    koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        koopa_alert "Setting EOL as LF in '${file}'."
        "${app['perl']}" -pi -e 's/\r\n/\n/g' "$file"
        "${app['perl']}" -pi -e 's/\r/\n/g' "$file"
    done
}

koopa_exec_dir() {
    local prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local file
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
    local -A app dict
    local -a args
    local arg
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['pattern']="$(koopa_version_pattern)"
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
    local -A app bool dict
    local -a cmd_args contents
    koopa_assert_has_args_le "$#" 2
    bool['decompress_only']=0
    bool['gnu_tar']=0
    dict['file']="${1:?}"
    dict['target_dir']="${2:-}"
    koopa_assert_is_file "${dict['file']}"
    dict['bn']="$(koopa_basename_sans_ext "${dict['file']}")"
    case "${dict['bn']}" in
        *'.tar')
            dict['bn']="$(koopa_basename_sans_ext "${dict['bn']}")"
            ;;
    esac
    dict['file']="$(koopa_realpath "${dict['file']}")"
    dict['match']="$(koopa_basename "${dict['file']}" | koopa_lowercase)"
    case "${dict['match']}" in
        *'.tar.bz2' | \
        *'.tar.gz' | \
        *'.tar.lz' | \
        *'.tar.xz')
            bool['decompress_only']=0
            ;;
        *'.br' | \
        *'.bz2' | \
        *'.gz' | \
        *'.lz' | \
        *'.lz4' | \
        *'.lzma' | \
        *'.xz' | \
        *'.z' | \
        *'.zst')
            bool['decompress_only']=1
            ;;
    esac
    if [[ "${bool['decompress_only']}" -eq 1 ]]
    then
        cmd_args+=("${dict['file']}")
        if [[ -n "${dict['target_dir']}" ]]
        then
            dict['target_dir']="$(koopa_init_dir "${dict['target_dir']}")"
            dict['target_file']="${dict['target_dir']}/${dict['bn']}"
            cmd_args+=("${dict['target_file']}")
        fi
        koopa_decompress "${cmd_args[@]}"
        return 0
    fi
    if [[ -z "${dict['target_dir']}" ]]
    then
        dict['target_dir']="$(koopa_parent_dir "${dict['file']}")/${dict['bn']}"
    fi
    dict['target_dir']="$(koopa_init_dir "${dict['target_dir']}")"
    koopa_alert "Extracting '${dict['file']}' to '${dict['target_dir']}'."
    dict['tmpdir']="$( \
        koopa_init_dir "$(koopa_parent_dir "${dict['file']}")/\
.koopa-extract-$(koopa_random_string)" \
    )"
    dict['tmpfile']="${dict['tmpdir']}/$(koopa_basename "${dict['file']}")"
    koopa_ln "${dict['file']}" "${dict['tmpfile']}"
    case "${dict['match']}" in
        *'.tar' | \
        *'.tar.'* | \
        *'.tbz2' | \
        *'.tgz')
            local -a tar_cmd_args
            app['tar']="$(koopa_locate_tar --allow-system)"
            koopa_assert_is_executable "${app['tar']}"
            if koopa_is_gnu "${app['tar']}"
            then
                bool['gnu_tar']=1
            else
                bool['gnu_tar']=0
            fi
            if koopa_is_root && [[ "${bool['gnu_tar']}" -eq 1 ]]
            then
                tar_cmd_args+=('--no-same-owner' '--no-same-permissions')
            fi
            tar_cmd_args+=(
                '-f' "${dict['tmpfile']}"
                '-x'
            )
            ;;
    esac
    case "${dict['match']}" in
        *'.tar.bz2' | \
        *'.tar.gz' | \
        *'.tar.lz' | \
        *'.tar.xz' | \
        *'.tbz2' | \
        *'.tgz')
            app['cmd']="${app['tar']}"
            app['cmd2']=''
            cmd_args+=("${tar_cmd_args[@]}")
            if [[ "${bool['gnu_tar']}" -eq 1 ]]
            then
                case "${dict['tmpfile']}" in
                    *'.bz2' | *'.tbz2')
                        app['cmd2']="$( \
                            koopa_locate_pbzip2 --allow-missing --allow-system \
                        )"
                        if [[ ! -x "${app['cmd2']}" ]]
                        then
                            app['cmd2']="$(koopa_locate_bzip2 --allow-system)"
                        fi
                        ;;
                    *'.gz' | *'.tgz')
                        app['cmd2']="$( \
                            koopa_locate_pigz --allow-missing --allow-system \
                        )"
                        if [[ ! -x "${app['cmd2']}" ]]
                        then
                            app['cmd2']="$(koopa_locate_gzip --allow-system)"
                        fi
                        ;;
                    *'.lz')
                        app['cmd2']="$(koopa_locate_lzip --allow-system)"
                        ;;
                    *'.xz')
                        app['cmd2']="$(koopa_locate_xz --allow-system)"
                        ;;
                esac
                cmd_args+=('--use-compress-program' "${app['cmd2']}")
            else
                case "${dict['tmpfile']}" in
                    *'.bz2' | *'.tbz2')
                        app['cmd2']="$(koopa_locate_bzip2 --allow-system)"
                        cmd_args+=('-j')
                        ;;
                    *'.gz' | *'.tgz')
                        app['cmd2']="$(koopa_locate_gzip --allow-system)"
                        cmd_args+=('-z')
                        ;;
                    *'.xz')
                        app['cmd2']="$(koopa_locate_xz --allow-system)"
                        cmd_args+=('-J')
                        ;;
                    *)
                        koopa_stop 'Unsupported file.'
                        ;;
                esac
            fi
            koopa_assert_is_executable "${app['cmd2']}"
            ;;
        *'.tar')
            app['cmd']="${app['tar']}"
            cmd_args+=("${tar_cmd_args[@]}")
            ;;
        *'.7z')
            app['cmd']="$(koopa_locate_7z --allow-system)"
            cmd_args+=('-x' "${dict['tmpfile']}")
            ;;
        *'.zip')
            app['cmd']="$(koopa_locate_unzip --allow-system)"
            cmd_args+=('-qq' "${dict['tmpfile']}")
            ;;
        *)
            koopa_stop "Unsupported file: '${dict['file']}'."
            ;;
    esac
    koopa_assert_is_executable "${app['cmd']}"
    (
        koopa_cd "${dict['tmpdir']}"
        if [[ "${bool['gnu_tar']}" -eq 0 ]] && [[ -x "${app['cmd2']:-}" ]]
        then
            koopa_add_to_path_start "$(koopa_dirname "${app['cmd2']}")"
        fi
        "${app['cmd']}" "${cmd_args[@]}" # 2>/dev/null
    )
    koopa_rm "${dict['tmpfile']}"
    readarray -t contents <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['tmpdir']}" \
    )"
    if koopa_is_array_empty "${contents[@]}"
    then
        koopa_stop "Empty archive file: '${dict['file']}'."
    fi
    (
        shopt -s dotglob
        if [[ "${#contents[@]}" -eq 1 ]] && [[ -d "${contents[0]}" ]]
        then
            koopa_mv \
                --target-directory="${dict['target_dir']}" \
                "${dict['tmpdir']}"/*/*
        else
            koopa_mv \
                --target-directory="${dict['target_dir']}" \
                "${dict['tmpdir']}"/*
        fi
    )
    koopa_rm "${dict['tmpdir']}"
    return 0
}

koopa_fasta_generate_chromosomes_file() {
    local -A app dict
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['grep']="$(koopa_locate_grep)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['genome_fasta_file']=''
    dict['output_file']=''
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
    local -A app dict
    koopa_assert_has_args "$#"
    app['cat']="$(koopa_locate_cat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['genome_fasta_file']=''
    dict['output_file']=''
    dict['transcriptome_fasta_file']=''
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
    local -A dict
    koopa_assert_has_args_eq "$#" 1
    dict['compress_ext_pattern']="$(koopa_compress_ext_pattern)"
    dict['file']="${1:?}"
    dict['is_tmp_file']=0
    dict['status']=1
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
    local -A app
    local file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['od']="$(koopa_locate_od --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    local -a bns fastq_files head out tail
    local bn file i
    app['cat']="$(koopa_locate_cat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['pattern']='*_L001_*.fastq*'
    dict['prefix']='lanepool'
    dict['source_dir']=''
    dict['target_dir']=''
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
    koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--source-dir' "${dict['source_dir']}" \
        '--target-dir' "${dict['target_dir']}"
    koopa_assert_is_dir "${dict['source_dir']}"
    dict['source_dir']="$(koopa_realpath "${dict['source_dir']}")"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="${dict['pattern']}" \
            --prefix="${dict['source_dir']}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]}"
    then
        koopa_stop "No lane-split FASTQ files matching pattern \
'${dict['pattern']}' in '${dict['source_dir']}'."
    fi
    dict['target_dir']="$(koopa_init_dir "${dict['target_dir']}")"
    for file in "${fastq_files[@]}"
    do
        bns+=("$(koopa_basename "$file")")
    done
    for bn in "${bns[@]}"
    do
        head+=("${bn//_L001_*/}")
        tail+=("${bn//*_L001_/}")
        out+=("${dict['target_dir']}/${dict['prefix']}_${bn//_L001/}")
    done
    for i in "${!fastq_files[@]}"
    do
        "${app['cat']}" \
            "${dict['source_dir']}/${head[$i]}_L"*"_${tail[$i]}" \
            > "${out[$i]}"
    done
    return 0
}

koopa_fastq_number_of_reads() {
    local -A app
    local file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    app['awk']="$(koopa_locate_awk)"
    app['wc']="$(koopa_locate_wc)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['wc']="$(koopa_locate_wc --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${1:?}"
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
    local -A dict
    local -a grep_args
    koopa_assert_has_args "$#"
    dict['file']=''
    dict['mode']=''
    dict['pattern']=''
    dict['stdin']=1
    dict['sudo']=0
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
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local str
        if koopa_has_file_ext "$file"
        then
            str="$( \
                koopa_print "$file" \
                | "${app['cut']}" -d '.' -f '2-' \
            )"
        else
            str=''
        fi
        koopa_print "$str"
    done
    return 0
}

koopa_file_ext() {
    local file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        local x
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
    local -A app dict
    local -a flags perl_cmd pos
    koopa_assert_has_args "$#"
    app['perl']="$(koopa_locate_perl --allow-system)"
    dict['multiline']=0
    dict['pattern']=''
    dict['regex']=0
    dict['replacement']=''
    dict['sudo']=0
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
        perl_cmd+=('koopa_sudo' "${app['perl']}")
    else
        perl_cmd=("${app['perl']}")
    fi
    koopa_assert_is_executable "${app[@]}"
    "${perl_cmd[@]}" "${flags[@]}" -e "${dict['expr']}" "$@"
    return 0
}

koopa_find_app_version() {
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['sort']="$(koopa_locate_sort)"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['name']="${1:?}"
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
    local prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local str
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
    local -A app dict
    koopa_assert_has_args_eq "$#" 2
    app['awk']="$(koopa_locate_awk)"
    app['basename']="$(koopa_locate_basename)"
    app['xargs']="$(koopa_locate_xargs)"
    koopa_assert_is_executable "${app[@]}"
    dict['type']="${1:?}"
    dict['header']="${2:?}"
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
    local -A app
    local prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    app['pcregrep']="$(koopa_locate_pcregrep)"
    koopa_assert_is_executable "${app[@]}"
    for prefix in "$@"
    do
        local -a files
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
    local -A app
    local prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    app['du']="$(koopa_locate_du)"
    app['sort']="$(koopa_locate_sort)"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app
    local prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for prefix in "$@"
    do
        local str
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

koopa_find_symlinks() {
    local -A dict
    local -a hits symlinks
    local symlink
    koopa_assert_has_args "$#"
    dict['source_prefix']=''
    dict['target_prefix']=''
    dict['verbose']=0
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
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['shell']="$(koopa_default_shell_name)"
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
    local -A app bool dict
    local -a exclude_arr find find_args results sorted_results
    local exclude_arg
    bool['empty']=0
    bool['exclude']=0
    bool['hidden']=0
    bool['print0']=0
    bool['sort']=0
    bool['sudo']=0
    bool['verbose']=0
    dict['days_modified_gt']=''
    dict['days_modified_lt']=''
    dict['engine']="${KOOPA_FIND_ENGINE:-}"
    dict['max_depth']=''
    dict['min_depth']=1
    dict['pattern']=''
    dict['size']=''
    dict['type']=''
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
                bool['exclude']=1
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                bool['exclude']=1
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
                bool['empty']=1
                shift 1
                ;;
            '--hidden')
                bool['hidden']=1
                shift 1
                ;;
            '--no-hidden')
                bool['hidden']=0
                shift 1
                ;;
            '--print0')
                bool['print0']=1
                shift 1
                ;;
            '--sort')
                bool['sort']=1
                shift 1
                ;;
            '--sudo')
                bool['sudo']=1
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
            fi
            ;;
        'fd')
            app['find']="$(koopa_locate_fd)"
            ;;
        'find')
            app['find']="$(koopa_locate_find --allow-system)"
            ;;
        *)
            koopa_stop 'Invalid find engine.'
            ;;
    esac
    find=()
    if [[ "${bool['sudo']}" -eq 1 ]]
    then
        find+=('koopa_sudo')
    fi
    find+=("${app['find']}")
    case "${dict['engine']}" in
        'fd')
            find_args=(
                '--absolute-path'
                '--base-directory' "${dict['prefix']}"
                '--case-sensitive'
                '--glob'
                '--no-follow'
                '--no-ignore'
                '--one-file-system'
            )
            if [[ "${bool['hidden']}" -eq 1 ]]
            then
                find_args+=('--hidden')
            else
                find_args+=('--no-hidden')
            fi
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
            if [[ "${bool['empty']}" -eq 1 ]]
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
            if [[ "${bool['exclude']}" -eq 1 ]]
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
            if [[ "${bool['print0']}" -eq 1 ]]
            then
                find_args+=('--print0')
            fi
            if [[ -n "${dict['pattern']}" ]]
            then
                find_args+=("${dict['pattern']}")
            fi
            ;;
        'find')
            find_args=("${dict['prefix']}" '-xdev')
            if [[ -n "${dict['min_depth']}" ]]
            then
                find_args+=('-mindepth' "${dict['min_depth']}")
            fi
            if [[ -n "${dict['max_depth']}" ]]
            then
                find_args+=('-maxdepth' "${dict['max_depth']}")
            fi
            if [[ "${bool['hidden']}" -eq 0 ]]
            then
                find_args+=('-not' '-name' '.*')
            fi
            if [[ -n "${dict['pattern']}" ]]
            then
                if koopa_str_detect_fixed \
                    --pattern="{" \
                    --string="${dict['pattern']}"
                then
                    readarray -O "${#find_args[@]}" -t find_args <<< "$( \
                        local -a globs1 globs2 globs3
                        local str
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
            if [[ "${bool['exclude']}" -eq 1 ]]
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
            if [[ "${bool['empty']}" -eq 1 ]]
            then
                find_args+=('-empty')
            fi
            if [[ -n "${dict['size']}" ]]
            then
                find_args+=('-size' "${dict['size']}")
            fi
            if [[ "${bool['print0']}" -eq 1 ]]
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
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        >&2 koopa_dl 'Find' "${find[*]} ${find_args[*]}"
    fi
    if [[ "${bool['sort']}" -eq 1 ]]
    then
        app['sort']="$(koopa_locate_sort --allow-system)"
    fi
    koopa_assert_is_executable "${app[@]}"
    if [[ "${bool['print0']}" -eq 1 ]]
    then
        readarray -t -d '' results < <( \
            "${find[@]}" "${find_args[@]}" 2>/dev/null \
        )
        koopa_is_array_non_empty "${results[@]:-}" || return 1
        if [[ "${bool['sort']}" -eq 1 ]]
        then
            readarray -t sorted_results <<< "$( \
                koopa_print "${results[@]}" | "${app['sort']}" \
            )"
            results=("${sorted_results[@]}")
        fi
        if [[ "${dict['engine']}" = 'fd' ]]
        then
            readarray -t results <<< "$( \
                koopa_strip_trailing_slash "${results[@]}" \
            )"
        fi
        printf '%s\0' "${results[@]}"
    else
        readarray -t results <<< "$( \
            "${find[@]}" "${find_args[@]}" 2>/dev/null \
        )"
        koopa_is_array_non_empty "${results[@]:-}" || return 1
        if [[ "${bool['sort']}" -eq 1 ]]
        then
            readarray -t sorted_results <<< "$( \
                koopa_print "${results[@]}" | "${app['sort']}" \
            )"
            results=("${sorted_results[@]}")
        fi
        if [[ "${dict['engine']}" = 'fd' ]]
        then
            readarray -t results <<< "$( \
                koopa_strip_trailing_slash "${results[@]}" \
            )"
        fi
        koopa_print "${results[@]}"
    fi
    return 0
}

koopa_ftp_mirror() {
    local -A app dict
    koopa_assert_has_args "$#"
    app['wget']="$(koopa_locate_wget)"
    koopa_assert_is_executable "${app[@]}"
    dict['dir']=''
    dict['host']=''
    dict['user']=''
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
        local -A dict
        dict['cmd']="$cmd"
        dict['bn']="$(koopa_basename "${dict['cmd']}")"
        dict['bn_snake']="$(koopa_snake_case "${dict['bn']}")"
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

koopa_git_branch() {
    local -A app
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['git']="$(koopa_locate_git --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local -A dict2
            koopa_cd "$repo"
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
    local -A app dict
    local -a clone_args
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['branch']=''
    dict['commit']=''
    dict['prefix']=''
    dict['tag']=''
    dict['url']=''
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
    local -A app
    koopa_assert_has_args "$#"
    app['date']="$(koopa_locate_date --allow-system)"
    app['git']="$(koopa_locate_git --allow-system)"
    app['xargs']="$(koopa_locate_xargs --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    local url
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['git']="$(koopa_locate_git --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
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
    local -A app
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['origin']='origin'
    dict['old_branch']='master'
    dict['new_branch']='main'
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
    local -A app dict
    app['git']="$(koopa_locate_git)"
    koopa_assert_is_executable "${app[@]}"
    "${app['git']}" update-index --refresh &>/dev/null
    dict['string']="$("${app['git']}" diff-index 'HEAD' -- 2>/dev/null)"
    [[ -n "${dict['string']}" ]]
}

koopa_git_repo_needs_pull_or_push() {
    local -A app
    local prefix
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git)"
    koopa_assert_is_executable "${app[@]}"
    (
        for prefix in "$@"
        do
            local -A dict
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
    local -A app
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local -A dict
            koopa_cd "$repo"
            dict['branch']="$(koopa_git_default_branch "${PWD:?}")"
            dict['origin']='origin'
            dict['upstream']='upstream'
            "${app['git']}" checkout "${dict['branch']}"
            "${app['git']}" fetch "${dict['upstream']}"
            "${app['git']}" reset --hard "${dict['upstream']}/${dict['branch']}"
            "${app['git']}" push "${dict['origin']}" "${dict['branch']}" --force
        done
    )
    return 0
}

koopa_git_reset() {
    local -A app
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Resetting Git repo at '${repo}'."
            koopa_cd "$repo"
            "${app['git']}" clean -dffx
            if [[ -s '.gitmodules' ]]
            then
                koopa_git_submodule_init "$repo"
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
    local -A app
    local module
    koopa_assert_has_args "$#"
    koopa_assert_is_git_repo
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
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
    local -A app dict
    koopa_assert_has_args_eq "$#" 2
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['origin']='origin'
    dict['prefix']="${1:?}"
    dict['url']="${2:?}"
    koopa_assert_is_git_repo "${dict['prefix']}"
    (
        koopa_cd "${dict['prefix']}"
        "${app['git']}" remote set-url "${dict['origin']}" "${dict['url']}"
    )
    return 0
}

koopa_git_submodule_init() {
    local -A app
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_git_repo "$@"
    (
        local repo
        for repo in "$@"
        do
            local -A dict
            local -a lines
            local string
            dict['module_file']='.gitmodules'
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
                local -A dict2
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
    local -A app
    local repo
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for repo in "$@"
    do
        local -A dict
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
    local server
    koopa_assert_has_no_args "$#"
    server='https://ftpmirror.gnu.org'
    koopa_print "$server"
    return 0
}

koopa_gpg_download_key_from_keyserver() {
    local -A app dict
    local -a cp
    koopa_assert_has_args "$#"
    app['gpg']="$(koopa_locate_gpg --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['sudo']=0
    dict['tmp_dir']="$(koopa_tmp_dir)"
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
    local -A app
    koopa_assert_has_no_args "$#"
    app['gpg']="$(koopa_locate_gpg --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    printf '' | "${app['gpg']}" -s
    return 0
}

koopa_gpg_reload() {
    local -A app
    koopa_assert_has_no_args "$#"
    app['gpg_connect_agent']="$(koopa_locate_gpg_connect_agent)"
    koopa_assert_is_executable "${app[@]}"
    "${app['gpg_connect_agent']}" reloadagent '/bye'
    return 0
}

koopa_gpg_restart() {
    local -A app
    koopa_assert_has_no_args "$#"
    app['gpgconf']="$(koopa_locate_gpgconf)"
    koopa_assert_is_executable "${app[@]}"
    "${app['gpgconf']}" --kill 'gpg-agent'
    return 0
}

koopa_grep() {
    local -A app dict
    local -a grep_args grep_cmd
    koopa_assert_has_args "$#"
    dict['boolean']=0
    dict['engine']="${KOOPA_GREP_ENGINE:-}"
    dict['file']=''
    dict['invert_match']=0
    dict['only_matching']=0
    dict['mode']='fixed' # or 'regex'.
    dict['pattern']=''
    dict['stdin']=1
    dict['string']=''
    dict['sudo']=0
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
            fi
            ;;
        'grep')
            app['grep']="$(koopa_locate_grep --allow-system)"
            ;;
        'rg')
            app['grep']="$(koopa_locate_ripgrep)"
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
        grep_cmd=('koopa_sudo' "${grep_cmd[@]}")
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
            grep_args+=('--no-config' '--case-sensitive')
            if [[ -n "${dict['file']}" ]]
            then
                grep_args+=('--no-ignore' '--one-file-system')
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
    koopa_assert_is_executable "${app[@]}"
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

koopa_group_name() {
    _koopa_group_name "$@"
}

koopa_gsub() {
    koopa_sub --global "$@"
}

koopa_h() {
    local -A dict
    koopa_assert_has_args_ge "$#" 2
    dict['emoji']="$(koopa_acid_emoji)"
    dict['level']="${1:?}"
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
    local -A dict
    koopa_assert_has_args_le "$#" 1
    [[ "${KOOPA_BUILDER:-0}" -eq 1 ]] && return 0
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
    local -A app
    koopa_assert_has_no_args "$#"
    app['sudo']="$(koopa_locate_sudo --allow-missing)"
    [[ -x "${app['sudo']}" ]] || return 1
    koopa_is_root && return 0
    "${app['sudo']}" -n true 2>/dev/null && return 0
    return 1
}

koopa_has_private_access() {
    local file
    file="${HOME}/.aws/credentials"
    [[ -f "$file" ]] || return 1
    koopa_file_detect_fixed \
        --file="$file" \
        --pattern='[acidgenomics]'
}

koopa_header() {
    local -A dict
    koopa_assert_has_args_eq "$#" 1
    dict['lang']="$(koopa_lowercase "${1:?}")"
    case "${dict['lang']}" in
        'posix')
            dict['lang']='sh'
            ;;
    esac
    dict['prefix']="$(koopa_koopa_prefix)/lang/${dict['lang']}"
    case "${dict['lang']}" in
        'bash' | \
        'sh' | \
        'zsh')
            dict['ext']='sh'
            ;;
        'r')
            dict['ext']='R'
            ;;
        *)
            koopa_invalid_arg "${dict['lang']}"
            ;;
    esac
    dict['file']="${dict['prefix']}/include/header.${dict['ext']}"
    koopa_assert_is_file "${dict['file']}"
    koopa_print "${dict['file']}"
    return 0
}

koopa_help_2() {
    local -A dict
    dict['script_file']="$(koopa_realpath "$0")"
    dict['script_name']="$(koopa_basename "${dict['script_file']}")"
    dict['man_prefix']="$( \
        koopa_parent_dir --num=2 "${dict['script_file']}" \
    )"
    dict['man_file']="${dict['man_prefix']}/share/man/\
man1/${dict['script_name']}.1"
    koopa_assert_is_file "${dict['man_file']}"
    koopa_help "${dict['man_file']}"
}

koopa_help() {
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    dict['man_file']="${1:?}"
    [[ -f "${dict['man_file']}" ]] || return 1
    app['head']="$(koopa_locate_head --allow-system)"
    app['man']="$(koopa_locate_man --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    "${app['head']}" -n 10 "${dict['man_file']}" \
        | koopa_str_detect_fixed --pattern='.TH ' \
        || return 1
    "${app['man']}" "${dict['man_file']}"
    exit 0
}

koopa_hisat2_align_paired_end_per_sample() {
    local -A app dict
    local -a align_args
    app['hisat2']="$(koopa_locate_hisat2)"
    koopa_assert_is_executable "${app[@]}"
    dict['fastq_r1_file']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_file']=''
    dict['fastq_r2_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
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
    local -A dict
    local -a fastq_r1_files
    local fastq_r1_file
    koopa_assert_has_args "$#"
    dict['fastq_dir']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mode']='paired-end'
    dict['output_dir']=''
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
    local -A app dict
    local -a align_args
    koopa_assert_has_args "$#"
    app['hisat2']="$(koopa_locate_hisat2)"
    koopa_assert_is_executable "${app[@]}"
    dict['fastq_file']=''
    dict['fastq_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
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
    local -A dict
    local -a fastq_files
    local fastq_file
    koopa_assert_has_args "$#"
    dict['fastq_dir']=''
    dict['fastq_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mode']='single-end'
    dict['output_dir']=''
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
    local -A dict
    koopa_assert_has_args_eq "$#" 1
    dict['fastq_file']="${1:?}"
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
    local -A app dict
    local -a index_args
    app['hisat2_build']="$(koopa_locate_hisat2_build)"
    koopa_assert_is_executable "${app[@]}"
    dict['genome_fasta_file']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=200
    dict['output_dir']=''
    dict['seed']=42
    dict['threads']="$(koopa_cpu_count)"
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
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['uname']="$(koopa_locate_uname)"
    koopa_assert_is_executable "${app[@]}"
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
    local -a array
    local barpad i
    koopa_assert_has_args "$#"
    array=("$@")
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
    local -A dict
    local -a mkdir pos
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
    local -A app dict
    app['perl']="$(koopa_locate_perl)"
    koopa_assert_is_executable "${app[@]}"
    dict['file']=''
    dict['line_number']=''
    dict['string']=''
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
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='agat' \
        "$@"
}

koopa_install_all_default() {
    koopa_install_shared_apps "$@"
    return 0
}

koopa_install_all_supported() {
    koopa_install_shared_apps --all-supported "$@"
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

koopa_install_apache_arrow() {
    koopa_install_app \
        --name='apache-arrow' \
        "$@"
}

koopa_install_apache_spark() {
    koopa_install_app \
        --name='apache-spark' \
        "$@"
}

koopa_install_app_from_binary_package() {
    local -A app dict
    koopa_assert_has_args "$#"
    app['aws']="$(koopa_locate_aws --allow-system)"
    app['tar']="$(koopa_locate_tar --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch2)" # e.g. 'amd64'.
    dict['aws_profile']="${AWS_PROFILE:-acidgenomics}"
    dict['binary_prefix']='/opt/koopa'
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['os_string']="$(koopa_os_string)"
    dict['s3_bucket']="s3://private.koopa.acidgenomics.com/binaries"
    dict['tmp_dir']="$(koopa_tmp_dir)"
    if [[ "${dict['koopa_prefix']}" != "${dict['binary_prefix']}" ]]
    then
        koopa_stop "Binary package installation not supported for koopa \
install located at '${dict['koopa_prefix']}'. Koopa must be installed at \
default '${dict['binary_prefix']}' location."
    fi
    koopa_assert_is_dir "$@"
    (
        local prefix
        koopa_cd "${dict['tmp_dir']}"
        for prefix in "$@"
        do
            local -A dict2
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
            "${app['aws']}" s3 cp \
                --only-show-errors \
                --profile "${dict['aws_profile']}" \
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
    local -A dict
    local -a pos
    koopa_assert_is_install_subshell
    dict['installer_bn']=''
    dict['installer_fun']='main'
    dict['mode']='shared'
    dict['name']="${KOOPA_INSTALL_NAME:-}"
    dict['platform']='common'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:-}"
    dict['tmp_dir']="$(koopa_tmp_dir)"
    dict['version']="${KOOPA_INSTALL_VERSION:-}"
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
    dict['installer_file']="$(koopa_bash_prefix)/include/install/\
${dict['platform']}/${dict['mode']}/${dict['installer_bn']}.sh"
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
    local -A app bool dict
    local -a bash_vars bin_arr env_vars man1_arr path_arr pos
    local i
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    koopa_assert_is_installed 'python3'
    bool['auto_prefix']=0
    bool['binary']=0
    bool['bootstrap']=0
    bool['copy_log_files']=0
    bool['deps']=1
    bool['isolate']=1
    bool['link_in_bin']=''
    bool['link_in_man1']=''
    bool['link_in_opt']=''
    bool['prefix_check']=1
    bool['private']=0
    bool['push']=0
    bool['quiet']=0
    bool['reinstall']=0
    bool['update_ldconfig']=0
    bool['verbose']=0
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['cpu_count']="$(koopa_cpu_count)"
    dict['installer']=''
    dict['mode']='shared'
    dict['name']=''
    dict['platform']='common'
    dict['prefix']=''
    dict['version']=''
    dict['version_key']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--cpu='*)
                dict['cpu_count']="${1#*=}"
                shift 1
                ;;
            '--cpu')
                dict['cpu_count']="${2:?}"
                shift 2
                ;;
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
            '--bootstrap')
                bool['bootstrap']=1
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
            '--no-dependencies')
                bool['deps']=0
                shift 1
                ;;
            '--private')
                bool['private']=1
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
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        export KOOPA_VERBOSE=1
        set -o xtrace
    fi
    [[ "${dict['mode']}" != 'shared' ]] && bool['deps']=0
    [[ -z "${dict['version_key']}" ]] && dict['version_key']="${dict['name']}"
    dict['current_version']="$(\
        koopa_app_json_version "${dict['version_key']}" 2>/dev/null || true \
    )"
    [[ -z "${dict['version']}" ]] && \
        dict['version']="${dict['current_version']}"
    case "${dict['mode']}" in
        'shared')
            koopa_assert_is_owner
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
            koopa_assert_is_owner
            koopa_assert_is_admin
            bool['isolate']=0
            bool['link_in_bin']=0
            bool['link_in_man1']=0
            bool['link_in_opt']=0
            bool['prefix_check']=0
            koopa_is_linux && bool['update_ldconfig']=1
            ;;
        'user')
            bool['link_in_bin']=0
            bool['link_in_man1']=0
            bool['link_in_opt']=0
            ;;
    esac
    if [[ "${bool['binary']}" -eq 1 ]] || \
        [[ "${bool['private']}" -eq 1 ]] || \
        [[ "${bool['push']}" -eq 1 ]]
    then
        koopa_assert_has_private_access
    fi
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
            [[ -d "${dict['prefix']}" ]] && return 0
        fi
    fi
    if [[ "${bool['deps']}" -eq 1 ]]
    then
        local dep deps
        readarray -t deps <<< "$(koopa_app_dependencies "${dict['name']}")"
        if koopa_is_array_non_empty "${deps[@]:-}"
        then
            koopa_dl \
                "${dict['name']} dependencies" \
                "$(koopa_to_string "${deps[@]}")"
            for dep in "${deps[@]}"
            do
                local -a dep_install_args
                if [[ -d "$(koopa_app_prefix --allow-missing "$dep")" ]]
                then
                    continue
                fi
                dep_install_args=()
                if [[ "${bool['binary']}" -eq 1 ]]
                then
                    dep_install_args+=('--binary')
                fi
                if [[ "${bool['bootstrap']}" -eq 1 ]]
                then
                    dep_install_args+=('--bootstrap')
                fi
                if [[ "${bool['push']}" -eq 1 ]]
                then
                    dep_install_args+=('--push')
                fi
                if [[ "${bool['verbose']}" -eq 1 ]]
                then
                    dep_install_args+=('--verbose')
                fi
                dep_install_args+=("$dep")
                koopa_cli_install "${dep_install_args[@]}"
            done
        fi
    fi
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        koopa_alert_install_start "${dict['name']}" "${dict['prefix']}"
    fi
    if [[ -n "${dict['prefix']}" ]] && [[ ! -d "${dict['prefix']}" ]]
    then
        case "${dict['mode']}" in
            'system')
                dict['prefix']="$(koopa_init_dir --sudo "${dict['prefix']}")"
                ;;
            *)
                dict['prefix']="$(koopa_init_dir "${dict['prefix']}")"
                ;;
        esac
    fi
    if [[ "${bool['binary']}" -eq 1 ]]
    then
        [[ "${dict['mode']}" == 'shared' ]] || return 1
        [[ -n "${dict['prefix']}" ]] || return 1
        koopa_install_app_from_binary_package "${dict['prefix']}"
    elif [[ "${bool['isolate']}" -eq 0 ]]
    then
        export KOOPA_INSTALL_APP_SUBSHELL=1
        koopa_install_app_subshell \
            --installer="${dict['installer']}" \
            --mode="${dict['mode']}" \
            --name="${dict['name']}" \
            --platform="${dict['platform']}" \
            --prefix="${dict['prefix']}" \
            --version="${dict['version']}" \
            "$@"
        unset -v KOOPA_INSTALL_APP_SUBSHELL
    else
        if [[ "${bool['bootstrap']}" -eq 1 ]]
        then
            app['bash']="${KOOPA_BOOTSTRAP_PREFIX:?}/bin/bash"
        else
            app['bash']="$(koopa_locate_bash --allow-missing)"
            if [[ ! -x "${app['bash']}" ]]
            then
                if koopa_is_macos
                then
                    app['bash']='/usr/local/bin/bash'
                else
                    app['bash']="$(koopa_locate_bash --allow-system)"
                fi
            fi
        fi
        app['env']="$(koopa_locate_env --allow-system)"
        app['tee']="$(koopa_locate_tee --allow-system)"
        koopa_assert_is_executable "${app[@]}"
        path_arr+=('/usr/bin' '/usr/sbin' '/bin' '/sbin')
        env_vars=(
            "HOME=${HOME:?}"
            'KOOPA_ACTIVATE=0'
            "KOOPA_CPU_COUNT=${dict['cpu_count']}"
            'KOOPA_INSTALL_APP_SUBSHELL=1'
            "KOOPA_VERBOSE=${bool['verbose']}"
            'LANG=C'
            'LC_ALL=C'
            "PATH=$(koopa_paste --sep=':' "${path_arr[@]}")"
            "TMPDIR=${TMPDIR:-/tmp}"
        )
        if [[ "${dict['mode']}" == 'shared' ]]
        then
            PKG_CONFIG_PATH=''
            app['pkg_config']="$( \
                koopa_locate_pkg_config --allow-missing --only-system \
            )"
            if [[ -x "${app['pkg_config']}" ]]
            then
                koopa_activate_pkg_config "${app['pkg_config']}"
            fi
            PKG_CONFIG_PATH="$( \
                koopa_gsub \
                    --regex \
                    --pattern='/usr/local[^\:]+:' \
                    --replacement='' \
                    "$PKG_CONFIG_PATH"
            )"
            env_vars+=("PKG_CONFIG_PATH=${PKG_CONFIG_PATH}")
            unset -v PKG_CONFIG_PATH
            if [[ -d "${dict['prefix']}" ]] && \
                [[ "${dict['mode']}" != 'system' ]]
            then
                bool['copy_log_files']=1
            fi
        fi
        dict['header_file']="$(koopa_bash_prefix)/include/header.sh"
        dict['stderr_file']="$(koopa_tmp_log_file)"
        dict['stdout_file']="$(koopa_tmp_log_file)"
        koopa_assert_is_file \
            "${dict['header_file']}" \
            "${dict['stderr_file']}" \
            "${dict['stdout_file']}"
        bash_vars=(
            '--noprofile'
            '--norc'
            '-o' 'errexit'
            '-o' 'errtrace'
            '-o' 'nounset'
            '-o' 'pipefail'
        )
        if [[ "${bool['verbose']}" -eq 1 ]]
        then
            bash_vars+=('-o' 'verbose')
        fi
        "${app['env']}" -i \
            "${env_vars[@]}" \
            "${app['bash']}" \
                "${bash_vars[@]}" \
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
        if [[ "${bool['copy_log_files']}" -eq 1 ]] && \
            [[ -d "${dict['prefix']}" ]]
        then
            koopa_cp \
                "${dict['stdout_file']}" \
                "${dict['prefix']}/.koopa-install-stdout.log"
            koopa_cp \
                "${dict['stderr_file']}" \
                "${dict['prefix']}/.koopa-install-stderr.log"
        fi
        koopa_rm \
            "${dict['stderr_file']}" \
            "${dict['stdout_file']}"
    fi
    case "${dict['mode']}" in
        'shared')
            if [[ "${bool['auto_prefix']}" -eq 1 ]]
            then
                koopa_sys_set_permissions "$(koopa_dirname "${dict['prefix']}")"
            fi
            koopa_sys_set_permissions --recursive "${dict['prefix']}"
            if [[ "${bool['link_in_opt']}" -eq 1 ]]
            then
                koopa_link_in_opt \
                    --name="${dict['name']}" \
                    --source="${dict['prefix']}"
            fi
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
                        local -A dict2
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
                        local -A dict2
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
            [[ "${bool['update_ldconfig']}" -eq 1 ]] && \
                koopa_linux_update_ldconfig
            ;;
        'user')
            [[ -d "${dict['prefix']}" ]] && \
                koopa_sys_set_permissions --recursive --user "${dict['prefix']}"
            ;;
    esac
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        koopa_alert_install_success "${dict['name']}" "${dict['prefix']}"
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
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='autodock-adfr' \
        "$@"
}

koopa_install_autodock_vina() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='autodock-vina' \
        "$@"
}

koopa_install_autodock() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='autodock' \
        "$@"
}

koopa_install_autoflake() {
    koopa_install_app \
        --installer='python-package' \
        --name='autoflake' \
        "$@"
}

koopa_install_automake() {
    koopa_install_app \
        --name='automake' \
        "$@"
}

koopa_install_aws_cli() {
    koopa_install_app \
        --name='aws-cli' \
        "$@"
}

koopa_install_azure_cli() {
    koopa_install_app \
        --name='azure-cli' \
        "$@"
}

koopa_install_bamtools() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='bamtools' \
        "$@"
}

koopa_install_bandwhich() {
    koopa_install_app \
        --installer='rust-package' \
        --name='bandwhich' \
        "$@"
}

koopa_install_bash_language_server() {
    koopa_install_app \
        --installer='node-package' \
        --name='bash-language-server' \
        "$@"
}

koopa_install_bash() {
    koopa_install_app \
        --name='bash' \
        "$@"
    return 0
}

koopa_install_bashcov() {
    koopa_install_app \
        --installer='ruby-package' \
        --name='bashcov' \
        "$@"
}

koopa_install_bat() {
    koopa_install_app \
        --installer='rust-package' \
        --name='bat' \
        "$@"
}

koopa_install_bc() {
    koopa_install_app \
        --name='bc' \
        "$@"
}

koopa_install_bedtools() {
    if koopa_is_macos && koopa_is_aarch64
    then
        koopa_install_app \
            --name='bedtools' \
            "$@"
    else
        koopa_install_app \
            --installer='conda-package' \
            --name='bedtools' \
            "$@"
    fi
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
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='bioawk' \
        "$@"
}

koopa_install_bioconda_utils() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
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

koopa_install_blast() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='blast' \
        "$@"
}

koopa_install_boost() {
    koopa_install_app \
        --name='boost' \
        "$@"
}

koopa_install_bottom() {
    koopa_install_app \
        --installer='rust-package' \
        --name='bottom' \
        "$@"
}

koopa_install_bowtie2() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='bowtie2' \
        "$@"
}

koopa_install_bpytop() {
    koopa_install_app \
        --installer='python-package' \
        --name='bpytop' \
        "$@"
}

koopa_install_broot() {
    koopa_install_app \
        --installer='rust-package' \
        --name='broot' \
        "$@"
}

koopa_install_brotli() {
    koopa_install_app \
        --name='brotli' \
        "$@"
}

koopa_install_bustools() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='bustools' \
        "$@"
}

koopa_install_byobu() {
    koopa_install_app \
        --name='byobu' \
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

koopa_install_cereal() {
    koopa_install_app \
        --name='cereal' \
        "$@"
}

koopa_install_cheat() {
    koopa_install_app \
        --name='cheat' \
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
        --installer='ruby-package' \
        --name='colorls' \
        "$@"
}

koopa_install_conda_package() {
    local -A dict
    local -a bin_names create_args pos
    local bin_name
    koopa_assert_is_install_subshell
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['yaml_file']=''
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
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
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['name']}" \
        '--version' "${dict['name']}"
    create_args=()
    dict['conda_cache_prefix']="$(koopa_init_dir 'conda')"
    export CONDA_PKGS_DIRS="${dict['conda_cache_prefix']}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    create_args+=("--prefix=${dict['libexec']}")
    if [[ -n "${dict['yaml_file']}" ]]
    then
        create_args+=("--file=${dict['yaml_file']}")
    else
        create_args+=("${dict['name']}==${dict['version']}")
    fi
    koopa_conda_create_env "${create_args[@]}"
    dict['json_pattern']="${dict['name']}-${dict['version']}-*.json"
    case "${dict['name']}" in
        'snakemake')
            dict['json_pattern']="${dict['name']}-minimal-*.json"
            ;;
    esac
    dict['json_file']="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="${dict['json_pattern']}" \
            --prefix="${dict['libexec']}/conda-meta" \
            --type='f' \
    )"
    koopa_assert_is_file "${dict['json_file']}"
    readarray -t bin_names <<< "$(koopa_conda_bin "${dict['json_file']}")"
    if koopa_is_array_non_empty "${bin_names[@]:-}"
    then
        for bin_name in "${bin_names[@]}"
        do
            local -A dict2
            dict2['name']="$bin_name"
            dict2['bin_source']="${dict['libexec']}/bin/${dict2['name']}"
            dict2['bin_target']="${dict['prefix']}/bin/${dict2['name']}"
            dict2['man1_source']="${dict['libexec']}/share/man/\
man1/${dict2['name']}.1"
            dict2['man1_target']="${dict['prefix']}/share/man/\
man1/${dict2['name']}.1"
            koopa_assert_is_file "${dict2['bin_source']}"
            koopa_ln "${dict2['bin_source']}" "${dict2['bin_target']}"
            if [[ -f "${dict2['man1_source']}" ]]
            then
                koopa_ln "${dict2['man1_source']}" "${dict2['man1_target']}"
            fi
        done
    fi
    return 0
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

koopa_install_dash() {
    koopa_install_app \
        --name='dash' \
        "$@"
    return 0
}

koopa_install_deeptools() {
    koopa_install_app \
        --installer='conda-package' \
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
        --installer='rust-package' \
        --name='difftastic' \
        "$@"
}

koopa_install_docker_credential_helpers() {
    koopa_install_app \
        --name='docker-credential-helpers' \
        "$@"
}

koopa_install_dotfiles() {
    koopa_install_app \
        --name='dotfiles' \
        "$@"
}

koopa_install_du_dust() {
    koopa_install_app \
        --installer='rust-package' \
        --name='du-dust' \
        "$@"
}

koopa_install_ed() {
    koopa_install_app \
        --name='ed' \
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
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='entrez-direct' \
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

koopa_install_eza() {
    koopa_install_app \
        --installer='rust-package' \
        --name='eza' \
        "$@"
}

koopa_install_fastqc() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='fastqc' \
        "$@"
}

koopa_install_fd_find() {
    koopa_install_app \
        --installer='rust-package' \
        --name='fd-find' \
        "$@"
}

koopa_install_ffmpeg() {
    koopa_install_app \
        --name='ffmpeg' \
        "$@"
}

koopa_install_ffq() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='ffq' \
        "$@"
}

koopa_install_fgbio() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
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
    return 0
}

koopa_install_flac() {
    koopa_install_app \
        --name='flac' \
        "$@"
}

koopa_install_flake8() {
    koopa_install_app \
        --installer='python-package' \
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
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
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
    koopa_assert_is_not_aarch64
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
    if koopa_is_macos && koopa_is_x86_64
    then
        koopa_stop 'Unsupported platform.'
    fi
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
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='gffutils' \
        "$@"
}

koopa_install_gget() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
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

koopa_install_gitui() {
    koopa_install_app \
        --installer='rust-package' \
        --name='gitui' \
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

koopa_install_gnu_app() {
    local -A dict
    local -a conf_args
    koopa_assert_is_install_subshell
    dict['compress_ext']='gz'
    dict['jobs']="$(koopa_cpu_count)"
    dict['mirror']="$(koopa_gnu_mirror_url)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['parent_name']=''
    dict['pkg_name']=''
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=()
    while (("$#"))
    do
        case "$1" in
            '--compress-ext='*)
                dict['compress_ext']="${1#*=}"
                shift 1
                ;;
            '--compress-ext')
                dict['compress_ext']="${2:?}"
                shift 2
                ;;
            '--jobs='*)
                dict['jobs']="${1#*=}"
                shift 1
                ;;
            '--jobs')
                dict['jobs']="${2:?}"
                shift 2
                ;;
            '--mirror='*)
                dict['mirror']="${1#*=}"
                shift 1
                ;;
            '--mirror')
                dict['mirror']="${2:?}"
                shift 2
                ;;
            '--package-name='*)
                dict['pkg_name']="${1#*=}"
                shift 1
                ;;
            '--package-name')
                dict['pkg_name']="${2:?}"
                shift 2
                ;;
            '--parent-name='*)
                dict['parent_name']="${1#*=}"
                shift 1
                ;;
            '--parent-name')
                dict['parent_name']="${2:?}"
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
            '--non-gnu-mirror')
                dict['mirror']='https://mirrors.sarata.com/non-gnu'
                shift 1
                ;;
            '-D')
                conf_args+=("${2:?}")
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ -z "${dict['parent_name']}" ]] && dict['parent_name']="${dict['name']}"
    [[ -z "${dict['pkg_name']}" ]] && dict['pkg_name']="${dict['name']}"
    koopa_assert_is_set \
        '--mirror' "${dict['mirror']}" \
        '--name' "${dict['name']}" \
        '--package-name' "${dict['pkg_name']}" \
        '--parent-name' "${dict['parent_name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    conf_args+=("--prefix=${dict['prefix']}")
    export FORCE_UNSAFE_CONFIGURE=1
    dict['url']="${dict['mirror']}/${dict['parent_name']}/\
${dict['pkg_name']}-${dict['version']}.tar.${dict['compress_ext']}"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
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

koopa_install_go_package() {
    local -A app dict
    local -a build_args
    koopa_assert_is_install_subshell
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    koopa_assert_is_executable "${app[@]}"
    dict['bin_name']=''
    dict['build_cmd']=''
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['ldflags']=''
    dict['mod']=''
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['tags']=''
    dict['url']=''
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    while (("$#"))
    do
        case "$1" in
            '--bin-name='*)
                dict['bin_name']="${1#*=}"
                shift 1
                ;;
            '--bin-name')
                dict['bin_name']="${2:?}"
                shift 2
                ;;
            '--build-cmd='*)
                dict['build_cmd']="${1#*=}"
                shift 1
                ;;
            '--build-cmd')
                dict['build_cmd']="${2:?}"
                shift 2
                ;;
            '--ldflags='*)
                dict['ldflags']="${1#*=}"
                shift 1
                ;;
            '--ldflags')
                dict['ldflags']="${2:?}"
                shift 2
                ;;
            '--mod='*)
                dict['mod']="${1#*=}"
                shift 1
                ;;
            '--mod')
                dict['mod']="${2:?}"
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
            '--tags='*)
                dict['tags']="${1#*=}"
                shift 1
                ;;
            '--tags')
                dict['tags']="${2:?}"
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
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
        '--url' "${dict['url']}" \
        '--version' "${dict['version']}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    [[ -z "${dict['bin_name']}" ]] && dict['bin_name']="${dict['name']}"
    if [[ -n "${dict['ldflags']}" ]]
    then
        build_args+=('-ldflags' "${dict['ldflags']}")
    fi
    if [[ -n "${dict['mod']}" ]]
    then
        build_args+=('-mod' "${dict['mod']}")
    fi
    if [[ -n "${dict['tags']}" ]]
    then
        build_args+=('-tags' "${dict['tags']}")
    fi
    build_args+=('-o' "${dict['prefix']}/bin/${dict['bin_name']}")
    if [[ -n "${dict['build_cmd']}" ]]
    then
        build_args+=("${dict['build_cmd']}")
    fi
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    koopa_dl 'go build args' "${build_args[*]}"
    "${app['go']}" build "${build_args[@]}"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
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
        --name='grep' \
        "$@"
}

koopa_install_grex() {
    koopa_install_app \
        --installer='rust-package' \
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
        --installer='node-package' \
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
    koopa_assert_is_not_aarch64
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

koopa_install_haskell_package() {
    local -A app dict
    local -a build_deps conf_args deps extra_pkgs install_args
    local dep
    koopa_assert_is_install_subshell
    build_deps=('git' 'pkg-config')
    koopa_activate_app --build-only "${build_deps[@]}"
    app['cabal']="$(koopa_locate_cabal)"
    app['ghcup']="$(koopa_locate_ghcup)"
    koopa_assert_is_executable "${app[@]}"
    dict['cabal_dir']="$(koopa_init_dir 'cabal')"
    dict['ghc_version']='9.4.7'
    dict['ghcup_prefix']="$(koopa_init_dir 'ghcup')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['cabal_store_dir']="$(\
        koopa_init_dir "${dict['prefix']}/libexec/cabal/store" \
    )"
    deps=()
    extra_pkgs=()
    while (("$#"))
    do
        case "$1" in
            '--dependency='*)
                deps+=("${1#*=}")
                shift 1
                ;;
            '--dependency')
                deps+=("${2:?}")
                shift 2
                ;;
            '--extra-package='*)
                extra_pkgs+=("${1#*=}")
                shift 1
                ;;
            '--extra-package')
                extra_pkgs+=("${2:?}")
                shift 2
                ;;
            '--ghc-version='*)
                dict['ghc_version']="${1#*=}"
                shift 1
                ;;
            '--ghc-version')
                dict['ghc_version']="${2:?}"
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--ghc-version' "${dict['ghc_version']}" \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    dict['ghc_prefix']="$(koopa_init_dir "ghc-${dict['ghc_version']}")"
    export CABAL_DIR="${dict['cabal_dir']}"
    export GHCUP_INSTALL_BASE_PREFIX="${dict['ghcup_prefix']}"
    koopa_print_env
    "${app['ghcup']}" install \
        'ghc' "${dict['ghc_version']}" \
            --isolate "${dict['ghc_prefix']}"
    koopa_assert_is_dir "${dict['ghc_prefix']}/bin"
    koopa_add_to_path_start "${dict['ghc_prefix']}/bin"
    koopa_init_dir "${dict['prefix']}/bin"
    "${app['cabal']}" update
    dict['cabal_config_file']="${dict['cabal_dir']}/config"
    koopa_assert_is_file "${dict['cabal_config_file']}"
    conf_args+=("store-dir: ${dict['cabal_store_dir']}")
    if koopa_is_array_non_empty "${deps[@]}"
    then
        for dep in "${deps[@]}"
        do
            local -A dict2
            dict2['prefix']="$(koopa_app_prefix "$dep")"
            koopa_assert_is_dir \
                "${dict2['prefix']}" \
                "${dict2['prefix']}/include" \
                "${dict2['prefix']}/lib"
            conf_args+=(
                "extra-include-dirs: ${dict2['prefix']}/include"
                "extra-lib-dirs: ${dict2['prefix']}/lib"
            )
        done
    fi
    dict['cabal_config_string']="$(koopa_print "${conf_args[@]}")"
    koopa_append_string \
        --file="${dict['cabal_config_file']}" \
        --string="${dict['cabal_config_string']}"
    install_args+=(
        '--install-method=copy'
        "--installdir=${dict['prefix']}/bin"
        "--jobs=${dict['jobs']}"
        '--verbose'
        "${dict['name']}-${dict['version']}"
    )
    if koopa_is_array_non_empty "${extra_pkgs[@]}"
    then
        install_args+=("${extra_pkgs[@]}")
    fi
    "${app['cabal']}" install "${install_args[@]}"
    return 0
}

koopa_install_haskell_stack() {
    koopa_assert_is_not_aarch64
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
        --installer='rust-package' \
        --name='hexyl' \
        "$@"
}

koopa_install_hisat2() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='hisat2' \
        "$@"
}

koopa_install_htop() {
    koopa_install_app \
        --name='htop' \
        "$@"
}

koopa_install_htseq() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='htseq' \
        "$@"
}

koopa_install_htslib() {
    koopa_install_app \
        --name='htslib' \
        "$@"
}

koopa_install_httpie() {
    koopa_install_app \
        --installer='python-package' \
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
        --installer='python-package' \
        --name='ipython' \
        "$@"
}

koopa_install_isl() {
    koopa_install_app \
        --name='isl' \
        "$@"
}

koopa_install_isort() {
    koopa_install_app \
        --installer='python-package' \
        --name='isort' \
        "$@"
}

koopa_install_jemalloc() {
    koopa_install_app \
        --name='jemalloc' \
        "$@"
}

koopa_install_jless() {
    koopa_install_app \
        --name='jless' \
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
        --installer='python-package' \
        --name='jupyterlab' \
        "$@"
}

koopa_install_kallisto() {
    koopa_install_app \
        --name='kallisto' \
        "$@"
}

koopa_install_koopa() {
    local -A bool dict
    koopa_assert_is_installed \
        'cp' 'curl' 'cut' 'find' 'git' 'grep' 'mkdir' 'mktemp' 'mv' 'perl' \
        'python3' 'readlink' 'rm' 'sed' 'tar' 'tr' 'unzip'
    bool['add_to_user_profile']=1
    bool['bootstrap']=0
    bool['interactive']=1
    bool['passwordless_sudo']=0
    bool['shared']=0
    dict['config_prefix']="$(koopa_config_prefix)"
    dict['prefix']=''
    dict['source_prefix']="$(koopa_koopa_prefix)"
    dict['user_profile']="$(koopa_find_user_profile)"
    dict['xdg_data_home']="$(koopa_xdg_data_home)"
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
            '--bootstrap')
                bool['bootstrap']=1
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
    [[ -d "${KOOPA_BOOTSTRAP_PREFIX:-}" ]] && bool['bootstrap']=1
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
        koopa_sys_set_permissions --recursive --sudo "${dict['prefix']}"
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
    if [[ "${bool['bootstrap']}" -eq 1 ]]
    then
        koopa_cli_install --bootstrap 'bash'
    fi
    return 0
}

koopa_install_krb5() {
    koopa_install_app \
        --name='krb5' \
        "$@"
}

koopa_install_ksh93() {
    koopa_install_app \
        --name='ksh93' \
        "$@"
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

koopa_install_ldc() {
    koopa_install_app \
        --name='ldc' \
        "$@"
}

koopa_install_ldns() {
    koopa_install_app \
        --name='ldns' \
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

koopa_install_libaec() {
    koopa_install_app \
        --name='libaec' \
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

koopa_install_libcbor() {
    koopa_install_app \
        --name='libcbor' \
        "$@"
}

koopa_install_libconfig() {
    koopa_install_app \
        --name='libconfig' \
        "$@"
}

koopa_install_libdeflate() {
    koopa_install_app \
        --name='libdeflate' \
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

koopa_install_libfido2() {
    koopa_install_app \
        --name='libfido2' \
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

koopa_install_libxcrypt() {
    koopa_install_app \
        --name='libxcrypt' \
        "$@"
}

koopa_install_libxml2() {
    koopa_install_app \
        --name='libxml2' \
        "$@"
}

koopa_install_libxslt() {
    koopa_install_app \
        --name='libxslt' \
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

koopa_install_luigi() {
    koopa_install_app \
        --name='luigi' \
        "$@"
}

koopa_install_lz4() {
    koopa_install_app \
        --name='lz4' \
        "$@"
}

koopa_install_lzip() {
    koopa_install_app \
        --name='lzip' \
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
        --installer='node-package' \
        --name='markdownlint-cli' \
        "$@"
}

koopa_install_mcfly() {
    koopa_install_app \
        --installer='rust-package' \
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
        --installer='python-package' \
        --name='meson' \
        "$@"
}

koopa_install_miller() {
    koopa_install_app \
        --name='miller' \
        "$@"
}

koopa_install_minimap2() {
    koopa_install_app \
        --name='minimap2' \
        "$@"
}

koopa_install_misopy() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='misopy' \
        "$@"
}

koopa_install_mold() {
    koopa_install_app \
        --name='mold' \
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
        --installer='python-package' \
        --name='multiqc' \
        "$@"
}

koopa_install_mutagen() {
    koopa_install_app \
        --name='mutagen' \
        "$@"
}

koopa_install_mypy() {
    koopa_install_app \
        --installer='python-package' \
        --name='mypy' \
        "$@"
}

koopa_install_nano() {
    koopa_install_app \
        --name='nano' \
        "$@"
}

koopa_install_nanopolish() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='nanopolish' \
        "$@"
}

koopa_install_ncbi_sra_tools() {
    koopa_install_app \
        --name='ncbi-sra-tools' \
        "$@"
}

koopa_install_ncbi_vdb() {
    koopa_install_app \
        --name='ncbi-vdb' \
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

koopa_install_node_package() {
    local -A app dict
    local -a extra_pkgs install_args
    koopa_assert_is_install_subshell
    koopa_activate_app --build-only 'node'
    app['node']="$(koopa_locate_node --realpath)"
    app['npm']="$(koopa_locate_npm)"
    koopa_assert_is_executable "${app[@]}"
    dict['cache_prefix']="$(koopa_tmp_dir)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    extra_pkgs=()
    while (("$#"))
    do
        case "$1" in
            '--extra-package='*)
                extra_pkgs+=("${1#*=}")
                shift 1
                ;;
            '--extra-packages')
                extra_pkgs+=("${2:?}")
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
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
        '--version' "${dict['version']}"
    export NPM_CONFIG_PREFIX="${dict['prefix']}"
    export NPM_CONFIG_UPDATE_NOTIFIER=false
    koopa_is_root && install_args+=('--unsafe-perm')
    install_args+=(
        '--build-from-source'
        "--cache=${dict['cache_prefix']}"
        '--global'
        '--loglevel=silly' # -ddd
        '--no-audit'
        '--no-fund'
        "${dict['name']}@${dict['version']}"
    )
    if koopa_is_array_non_empty "${extra_pkgs[@]}"
    then
        install_args+=("${extra_pkgs[@]}")
    fi
    koopa_dl 'npm install args' "${install_args[*]}"
    "${app['npm']}" install "${install_args[@]}" 2>&1
    koopa_rm "${dict['cache_prefix']}"
    return 0
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
}

koopa_install_oniguruma() {
    koopa_install_app \
        --name='oniguruma' \
        "$@"
}

koopa_install_ont_dorado() {
    koopa_install_app \
        --name='ont-dorado' \
        "$@"
}

koopa_install_ont_vbz_compression() {
    koopa_install_app \
        --name='ont-vbz-compression' \
        "$@"
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

koopa_install_openjpeg() {
    koopa_install_app \
        --name='openjpeg' \
        "$@"
}

koopa_install_openldap() {
    koopa_install_app \
        --name='openldap' \
        "$@"
}

koopa_install_openssh() {
    koopa_install_app \
        --name='openssh' \
        "$@"
}

koopa_install_openssl3() {
    koopa_install_app \
        --name='openssl3' \
        "$@"
}

koopa_install_p7zip() {
    koopa_install_app \
        --name='p7zip' \
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

koopa_install_pbzip2() {
    koopa_install_app \
        --name='pbzip2' \
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

koopa_install_perl_package() {
    local -A app dict
    local -a bin_files deps
    local bin_file
    koopa_assert_is_install_subshell
    koopa_activate_app --build-only 'perl'
    koopa_activate_ca_certificates
    app['bash']="$(koopa_locate_bash)"
    app['bzip2']="$(koopa_locate_bzip2)"
    app['cpan']="$(koopa_locate_cpan)"
    app['gpg']="$(koopa_locate_gpg)"
    app['gzip']="$(koopa_locate_gzip)"
    app['less']="$(koopa_locate_less)"
    app['make']="$(koopa_locate_make)"
    app['patch']="$(koopa_locate_patch)"
    app['perl']="$(koopa_locate_perl)"
    app['tar']="$(koopa_locate_tar)"
    app['unzip']="$(koopa_locate_unzip)"
    app['wget']="$(koopa_locate_wget)"
    koopa_assert_is_executable "${app[@]}"
    dict['cpan_path']=''
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:-}"
    dict['tmp_cpan']="$(koopa_init_dir 'cpan')"
    dict['version']="${KOOPA_INSTALL_VERSION:-}"
    deps=()
    while (("$#"))
    do
        case "$1" in
            '--cpan-path='*)
                dict['cpan_path']="${1#*=}"
                shift 1
                ;;
            '--cpan-path')
                dict['cpan_path']="${2:?}"
                shift 2
                ;;
            '--dependency='*)
                deps+=("${1#*=}")
                shift 1
                ;;
            '--dependency')
                deps+=("${2:?}")
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
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--cpan-path' "${dict['cpan_path']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    dict['cpan_config_file']="${dict['tmp_cpan']}/CPAN/MyConfig.pm"
    read -r -d '' "dict[cpan_config_string]" << END || true
\$CPAN::Config = {
  'allow_installing_module_downgrades' => q[no],
  'allow_installing_outdated_dists' => q[yes],
  'applypatch' => q[],
  'auto_commit' => q[0],
  'build_cache' => q[100],
  'build_dir' => q[${dict['tmp_cpan']}/build],
  'build_dir_reuse' => q[0],
  'build_requires_install_policy' => q[yes],
  'bzip2' => q[${app['bzip2']}],
  'cache_metadata' => q[0],
  'check_sigs' => q[0],
  'cleanup_after_install' => q[1],
  'colorize_output' => q[0],
  'commandnumber_in_prompt' => q[1],
  'connect_to_internet_ok' => q[1],
  'cpan_home' => q[${dict['tmp_cpan']}],
  'ftp_passive' => q[1],
  'ftp_proxy' => q[],
  'getcwd' => q[cwd],
  'gpg' => q[${app['gpg']}],
  'gzip' => q[${app['gzip']}],
  'halt_on_failure' => q[1],
  'histfile' => q[${dict['tmp_cpan']}/histfile],
  'histsize' => q[100],
  'http_proxy' => q[],
  'inactivity_timeout' => q[0],
  'index_expire' => q[1],
  'inhibit_startup_message' => q[1],
  'keep_source_where' => q[${dict['tmp_cpan']}/sources],
  'load_module_verbosity' => q[v],
  'make' => q[${app['make']}],
  'make_arg' => q[-j${dict['jobs']}],
  'make_install_arg' => q[-j${dict['jobs']}],
  'make_install_make_command' => q[${app['make']}],
  'makepl_arg' => q[INSTALL_BASE=${dict['prefix']}],
  'mbuild_arg' => q[],
  'mbuild_install_arg' => q[],
  'mbuild_install_build_command' => q[./Build],
  'mbuildpl_arg' => q[--install_base ${dict['prefix']}],
  'no_proxy' => q[],
  'pager' => q[${app['less']} -R],
  'patch' => q[${app['patch']}],
  'perl5lib_verbosity' => q[v],
  'prefer_external_tar' => q[1],
  'prefer_installer' => q[MB],
  'prefs_dir' => q[${dict['tmp_cpan']}/prefs],
  'prerequisites_policy' => q[follow],
  'pushy_https' => q[1],
  'recommends_policy' => q[1],
  'scan_cache' => q[never],
  'shell' => q[${app['bash']}],
  'show_unparsable_versions' => q[0],
  'show_upload_date' => q[0],
  'show_zero_versions' => q[0],
  'suggests_policy' => q[0],
  'tar' => q[${app['tar']}],
  'tar_verbosity' => q[vv],
  'term_is_latin' => q[1],
  'term_ornaments' => q[1],
  'test_report' => q[0],
  'trust_test_report_history' => q[0],
  'unzip' => q[${app['unzip']}],
  'urllist' => [q[http://www.cpan.org/]],
  'use_prompt_default' => q[1],
  'use_sqlite' => q[0],
  'version_timeout' => q[15],
  'wget' => q[${app['wget']}],
  'yaml_load_code' => q[0],
  'yaml_module' => q[YAML],
};
1;
__END__
END
    koopa_write_string \
        --file="${dict['cpan_config_file']}" \
        --string="${dict['cpan_config_string']}"
    dict['perl_ver']="$(koopa_get_version "${app['perl']}")"
    dict['perl_maj_ver']="$(koopa_major_version "${dict['perl_ver']}")"
    dict['lib_prefix']="${dict['prefix']}/lib/perl${dict['perl_maj_ver']}"
    export PERL5LIB="${dict['lib_prefix']}"
    koopa_print_env
    if koopa_is_array_non_empty "${deps[@]}"
    then
        "${app['cpan']}" \
            -j "${dict['cpan_config_file']}" \
            "${deps[@]}"
    fi
    "${app['cpan']}" \
        -j "${dict['cpan_config_file']}" \
        "${dict['cpan_path']}-${dict['version']}.tar.gz"
    koopa_assert_is_dir "${dict['lib_prefix']}"
    dict['lib_string']="use lib \"${dict['lib_prefix']}\";"
    readarray -t bin_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['prefix']}/bin" \
            --type='f' \
    )"
    koopa_assert_is_array_non_empty "${bin_files[@]:-}"
    koopa_assert_is_file "${bin_files[@]}"
    for bin_file in "${bin_files[@]}"
    do
        koopa_insert_at_line_number \
            --file="$bin_file" \
            --line-number=2 \
            --string="${dict['lib_string']}"
    done
    return 0
}

koopa_install_perl() {
    koopa_install_app \
        --name='perl' \
        "$@"
}

koopa_install_picard() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='picard' \
        "$@"
}

koopa_install_pigz() {
    koopa_install_app \
        --name='pigz' \
        "$@"
}

koopa_install_pinentry() {
    koopa_install_app \
        --name='pinentry' \
        "$@"
}

koopa_install_pipx() {
    koopa_install_app \
        --installer='python-package' \
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
        --installer='python-package' \
        --name='poetry' \
        "$@"
}

koopa_install_prettier() {
    koopa_install_app \
        --name='prettier' \
        "$@"
}

koopa_install_private_ont_guppy() {
    koopa_install_app \
        --name='ont-guppy' \
        --private \
        "$@"
    koopa_alert_note "Installation requires agreement to terms of service at: \
'https://nanoporetech.com/support/nanopore-sequencing-data-analysis'."
    return 0
}

koopa_install_procs() {
    koopa_install_app \
        --installer='rust-package' \
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
        --installer='python-package' \
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
        --installer='python-package' \
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
        --installer='python-package' \
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
        --installer='python-package' \
        --name='pytest' \
        "$@"
}

koopa_install_python_package() {
    local -A app bool dict
    local -a bin_names extra_pkgs man1_names venv_args
    local bin_name man1_name
    koopa_assert_is_install_subshell
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['binary']=1
    dict['locate_python']='koopa_locate_python312'
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['pip_name']=''
    dict['pkg_name']=''
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['py_maj_ver']=''
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    extra_pkgs=()
    while (("$#"))
    do
        case "$1" in
            '--extra-package='*)
                extra_pkgs+=("${1#*=}")
                shift 1
                ;;
            '--extra-packages')
                extra_pkgs+=("${2:?}")
                shift 2
                ;;
            '--package-name='*)
                dict['pkg_name']="${1#*=}"
                shift 1
                ;;
            '--package-name')
                dict['pkg_name']="${2:?}"
                shift 2
                ;;
            '--pip-name='*)
                dict['pip_name']="${1#*=}"
                shift 1
                ;;
            '--pip-name')
                dict['pip_name']="${2:?}"
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
            '--python-version='*)
                dict['py_maj_ver']="${1#*=}"
                shift 1
                ;;
            '--python-version')
                dict['py_maj_ver']="${2:?}"
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
            '--no-binary')
                bool['binary']=0
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ -z "${dict['pkg_name']}" ]] && dict['pkg_name']="${dict['name']}"
    [[ -z "${dict['pip_name']}" ]] && dict['pip_name']="${dict['pkg_name']}"
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--package-name' "${dict['pkg_name']}" \
        '--pip-name' "${dict['pip_name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    if [[ -n "${dict['py_maj_ver']}" ]]
    then
        dict['py_maj_ver_2']="$( \
            koopa_gsub \
                --fixed \
                --pattern='.'  \
                --replacement='' \
                "${dict['py_maj_ver']}" \
        )"
        dict['locate_python']="koopa_locate_python${dict['py_maj_ver_2']}"
    fi
    koopa_assert_is_function "${dict['locate_python']}"
    app['python']="$("${dict['locate_python']}" --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['libexec']="${dict['prefix']}/libexec"
    dict['py_version']="$(koopa_get_version "${app['python']}")"
    dict['py_maj_min_ver']="$( \
        koopa_major_minor_version "${dict['py_version']}" \
    )"
    venv_args=(
        "--prefix=${dict['libexec']}"
        "--python=${app['python']}"
    )
    if [[ "${bool['binary']}" -eq 0 ]]
    then
        venv_args+=('--no-binary')
    fi
    venv_args+=("${dict['pip_name']}==${dict['version']}")
    if koopa_is_array_non_empty "${extra_pkgs[@]}"
    then
        venv_args+=("${extra_pkgs[@]}")
    fi
    koopa_print_env
    koopa_python_create_venv "${venv_args[@]}"
    dict['record_file']="${dict['libexec']}/lib/\
python${dict['py_maj_min_ver']}/site-packages/\
${dict['pkg_name']}-${dict['version']}.dist-info/RECORD"
    koopa_assert_is_file "${dict['record_file']}"
    readarray -t bin_names <<< "$( \
        koopa_grep \
            --file="${dict['record_file']}" \
            --pattern='^\.\./\.\./\.\./bin/[^/]+,' \
            --regex \
        | "${app['cut']}" -d ',' -f '1' \
        | "${app['cut']}" -d '/' -f '5' \
    )"
    readarray -t man1_names <<< "$( \
        koopa_grep \
            --file="${dict['record_file']}" \
            --pattern='^\.\./\.\./\.\./share/man/man1/[^/]+,' \
            --regex \
        | "${app['cut']}" -d ',' -f '1' \
        | "${app['cut']}" -d '/' -f '7' \
    )"
    koopa_assert_is_array_non_empty "${bin_names[@]:-}"
    for bin_name in "${bin_names[@]}"
    do
        koopa_ln \
            "${dict['libexec']}/bin/${bin_name}" \
            "${dict['prefix']}/bin/${bin_name}"
    done
    if koopa_is_array_non_empty "${man1_names[@]:-}"
    then
        for man1_name in "${man1_names[@]}"
        do
            koopa_ln \
                "${dict['libexec']}/share/man/man1/${man1_name}" \
                "${dict['prefix']}/share/man/man1/${man1_name}"
        done
    fi
    return 0
}

koopa_install_python311() {
    koopa_install_app \
        --installer='python' \
        --name='python3.11' \
        "$@"
}

koopa_install_python312() {
    local -A dict
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['bin_prefix']="$(koopa_bin_prefix)"
    dict['man1_prefix']="$(koopa_man1_prefix)"
    dict['opt_prefix']="$(koopa_opt_prefix)"
    koopa_install_app \
        --installer='python' \
        --name='python3.12' \
        "$@"
    (
        koopa_cd "${dict['bin_prefix']}"
        koopa_ln 'python3.12' 'python3'
        koopa_ln 'python3.12' 'python'
        koopa_cd "${dict['man1_prefix']}"
        koopa_ln 'python3.12.1' 'python3.1'
        koopa_ln 'python3.12.1' 'python.1'
    )
    koopa_rm \
        "${dict['app_prefix']}/python" \
        "${dict['opt_prefix']}/python"
    return 0
}

koopa_install_quarto() {
    koopa_install_app \
        --name='quarto' \
        "$@"
}

koopa_install_r_devel() {
    koopa_install_app \
        --name='r-devel' \
        "$@"
}

koopa_install_r() {
    koopa_install_app \
        --name='r' \
        "$@"
}

koopa_install_radian() {
    koopa_install_app \
        --installer='python-package' \
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

koopa_install_rclone() {
    koopa_install_app \
        --name='rclone' \
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
        --installer='ruby-package' \
        --name='rmate' \
        "$@"
}

koopa_install_ronn_ng() {
    koopa_install_app \
        --installer='ruby-package' \
        --name='ronn-ng' \
        "$@"
}

koopa_install_ronn() {
    koopa_install_app \
        --installer='ruby-package' \
        --name='ronn' \
        "$@"
}

koopa_install_rsem() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='rsem' \
        "$@"
}

koopa_install_rsync() {
    koopa_install_app \
        --name='rsync' \
        "$@"
}

koopa_install_ruby_package() {
    local -A app dict
    koopa_assert_is_install_subshell
    app['bundle']="$(koopa_locate_bundle)"
    app['ruby']="$(koopa_locate_ruby --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['gemfile']='Gemfile'
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
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
        '--version' "${dict['version']}"
    read -r -d '' "dict[gemfile_string]" << END || true
source "https://rubygems.org"
gem "${dict['name']}", "${dict['version']}"
END
    dict['libexec']="${dict['prefix']}/libexec"
    koopa_mkdir "${dict['libexec']}"
    koopa_print_env
    (
        koopa_cd "${dict['libexec']}"
        koopa_write_string \
            --file="${dict['gemfile']}" \
            --string="${dict['gemfile_string']}"
        "${app['bundle']}" install \
            --gemfile="${dict['gemfile']}" \
            --jobs="${dict['jobs']}" \
            --retry=3 \
            --standalone
        "${app['bundle']}" binstubs \
            "${dict['name']}" \
            --path="${dict['prefix']}/bin" \
            --shebang="${app['ruby']}" \
            --standalone
    )
    return 0
}

koopa_install_ruby() {
    koopa_install_app \
        --name='ruby' \
        "$@"
}

koopa_install_ruff_lsp() {
    koopa_install_app \
        --name='ruff-lsp' \
        "$@"
}

koopa_install_ruff() {
    koopa_install_app \
        --installer='python-package' \
        --name='ruff' \
        "$@"
}

koopa_install_rust_package() {
    local -A app bool dict
    local -a install_args pos
    koopa_assert_is_install_subshell
    koopa_activate_app --build-only 'rust'
    app['cargo']="$(koopa_locate_cargo)"
    koopa_assert_is_executable "${app[@]}"
    bool['openssl']=0
    dict['cargo_home']="$(koopa_init_dir 'cargo')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:-}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:-}"
    dict['version']="${KOOPA_INSTALL_VERSION:-}"
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            '--features='* | \
            '--git='* | \
            '--tag='*)
                pos+=("${1%%=*}" "${1#*=}")
                shift 1
                ;;
            '--features' | \
            '--git' | \
            '--tag')
                pos+=("$1" "$2")
                shift 2
                ;;
            '--with-openssl')
                bool['openssl']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_dir "${dict['cargo_home']}"
    export CARGO_HOME="${dict['cargo_home']}"
    export RUST_BACKTRACE='full' # or '1'.
    if [[ "${bool['openssl']}" -eq 1 ]]
    then
        koopa_activate_app 'openssl3'
        dict['openssl']="$(koopa_app_prefix 'openssl3')"
        export OPENSSL_DIR="${dict['openssl']}"
    fi
    if [[ -n "${LDFLAGS:-}" ]]
    then
        local -a ldflags rustflags
        local ldflag
        rustflags=()
        IFS=' ' read -r -a ldflags <<< "${LDFLAGS:?}"
        for ldflag in "${ldflags[@]}"
        do
            rustflags+=('-C' "link-arg=${ldflag}")
        done
        export RUSTFLAGS="${rustflags[*]}"
    fi
    install_args=(
        '--config' 'net.git-fetch-with-cli=true'
        '--config' 'net.retry=5'
        '--jobs' "${dict['jobs']}"
        '--locked'
        '--root' "${dict['prefix']}"
        '--verbose'
        '--version' "${dict['version']}"
    )
    [[ "$#" -gt 0 ]] && install_args+=("$@")
    install_args+=("${dict['name']}")
    koopa_print_env
    koopa_dl 'cargo install args' "${install_args[*]}"
    "${app['cargo']}" install "${install_args[@]}"
    return 0
}

koopa_install_rust() {
    koopa_install_app \
        --name='rust' \
        "$@"
}

koopa_install_salmon() {
    if koopa_is_macos && koopa_is_aarch64
    then
        koopa_install_app \
            --name='salmon' \
            "$@"
    else
        koopa_install_app \
            --installer='conda-package' \
            --name='salmon' \
            "$@"
    fi
}

koopa_install_sambamba() {
    if koopa_is_macos && koopa_is_aarch64
    then
        koopa_install_app \
            --name='sambamba' \
            "$@"
    else
        koopa_install_app \
            --installer='conda-package' \
            --name='sambamba' \
            "$@"
    fi
}

koopa_install_samtools() {
    if koopa_is_macos && koopa_is_aarch64
    then
        koopa_install_app \
            --name='samtools' \
            "$@"
    else
        koopa_install_app \
            --installer='conda-package' \
            --name='samtools' \
            "$@"
    fi
}

koopa_install_scalene() {
    koopa_install_app \
        --installer='python-package' \
        --name='scalene' \
        "$@"
}

koopa_install_scons() {
    koopa_install_app \
        --name='scons' \
        "$@"
}

koopa_install_screen() {
    koopa_install_app \
        --name='screen' \
        "$@"
}

koopa_install_sd() {
    koopa_install_app \
        --installer='rust-package' \
        --name='sd' \
        "$@"
}

koopa_install_sed() {
    koopa_install_app \
        --name='sed' \
        "$@"
}

koopa_install_seqkit() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='seqkit' \
        "$@"
}

koopa_install_serf() {
    koopa_install_app \
        --name='serf' \
        "$@"
}

koopa_install_shared_apps() {
    local -A app bool dict
    local -a app_names push_apps
    local app_name
    koopa_assert_is_owner
    bool['all_supported']=0
    bool['aws_bootstrap']=0
    bool['binary']=0
    bool['push']=0
    bool['update']=0
    bool['verbose']=0
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=6
    while (("$#"))
    do
        case "$1" in
            '--binary')
                bool['binary']=1
                shift 1
                ;;
            '--push')
                bool['push']=1
                shift 1
                ;;
            '--update')
                bool['update']=1
                shift 1
                ;;
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            '--all-supported')
                bool['all_supported']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${bool['binary']}" -eq 1 ]]
    then
        koopa_assert_can_install_binary
        if [[ "${bool['push']}" -eq 1 ]]
        then
            koopa_stop 'Pushing binary apps is not supported.'
        fi
        app['aws']="$(koopa_locate_aws --allow-missing --allow-system)"
        [[ ! -x "${app['aws']}" ]] && bool['aws_bootstrap']=1
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "${dict['mem_gb_cutoff']} GB of RAM is required."
    fi
    if [[ "${bool['update']}" -eq 1 ]]
    then
        koopa_update_koopa
    fi
    if [[ "${bool['aws_bootstrap']}" -eq 1 ]]
    then
        koopa_install_aws_cli --no-dependencies
    fi
    if [[ "${bool['all_supported']}" -eq 1 ]]
    then
        readarray -t app_names <<< "$(koopa_shared_apps --mode='all-supported')"
    else
        readarray -t app_names <<< "$(koopa_shared_apps)"
    fi
    for app_name in "${app_names[@]}"
    do
        local -a install_args
        local prefix
        prefix="$(koopa_app_prefix --allow-missing "$app_name")"
        [[ -d "$prefix" ]] && continue
        [[ "${bool['binary']}" -eq 1 ]] && install_args+=('--binary')
        [[ "${bool['verbose']}" -eq 1 ]] && install_args+=('--verbose')
        install_args+=("$app_name")
        koopa_cli_install "${install_args[@]}"
        push_apps+=("$app_name")
    done
    if [[ "${bool['push']}" -eq 1 ]] && \
        koopa_is_array_non_empty "${push_apps[@]:-}"
    then
        for app_name in "${push_apps[@]}"
        do
            koopa_push_app_build "$app_name"
        done
    fi
    if [[ "${bool['aws_bootstrap']}" -eq 1 ]]
    then
        koopa_cli_install --reinstall 'aws-cli'
    fi
    return 0
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
        --installer='python-package' \
        --name='snakefmt' \
        "$@"
}

koopa_install_snakemake() {
    koopa_install_app \
        --installer='python-package' \
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

koopa_install_staden_io_lib() {
    koopa_install_app \
        --name='staden-io-lib' \
        "$@"
}

koopa_install_star_fusion() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='star-fusion' \
        "$@"
}

koopa_install_star() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
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

koopa_install_subread() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='subread' \
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

koopa_install_system_bootstrap() {
    koopa_install_app \
        --name='bootstrap' \
        --system \
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
        --name='tar' \
        "$@"
}

koopa_install_tbb() {
    koopa_install_app \
        --name='tbb' \
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
        --name='tealdeer' \
        "$@"
}

koopa_install_temurin() {
    koopa_install_app \
        --name='temurin' \
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
        --installer='rust-package' \
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

koopa_install_tryceratops() {
    koopa_install_app \
        --installer='python-package' \
        --name='tryceratops' \
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

koopa_install_umis() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='umis' \
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
        --installer='python-package' \
        --name='visidata' \
        "$@"
}

koopa_install_vulture() {
    koopa_install_app \
        --installer='python-package' \
        --name='vulture' \
        "$@"
}

koopa_install_walk() {
    koopa_install_app \
        --name='walk' \
        "$@"
}

koopa_install_wget() {
    koopa_install_app \
        --name='wget' \
        "$@"
}

koopa_install_wget2() {
    koopa_install_app \
        --name='wget2' \
        "$@"
}

koopa_install_which() {
    koopa_install_app \
        --name='which' \
        "$@"
}

koopa_install_woff2() {
    koopa_install_app \
        --name='woff2' \
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

koopa_install_yapf() {
    koopa_install_app \
        --installer='python-package' \
        --name='yapf' \
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
        --installer='rust-package' \
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

koopa_install_zopfli() {
    koopa_install_app \
        --name='zopfli' \
        "$@"
}

koopa_install_zoxide() {
    koopa_install_app \
        --installer='rust-package' \
        --name='zoxide' \
        "$@"
}

koopa_install_zsh() {
    local -A dict
    koopa_install_app --name='zsh' "$@"
    dict['zsh']="$(koopa_app_prefix 'zsh')"
    koopa_chmod --recursive 'g-w' "${dict['zsh']}/share/zsh"
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
    local -A dict
    dict['type']='public'
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

koopa_ip_info() {
    local -A app dict
    app['curl']="$(koopa_locate_curl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['server']='ipinfo.io'
    dict['json']="$( \
        "${app['curl']}" \
            --disable \
            --silent \
            "${dict['server']}" \
    )"
    [[ -n "${dict['json']}" ]] || return 1
    koopa_print "${dict['json']}"
    return 0
}

koopa_is_aarch64() {
    case "$(koopa_arch)" in
        'aarch64' | 'arm64')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

koopa_is_admin() {
    local -A app dict
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
    app['groups']="$(koopa_locate_groups --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['groups']="$("${app['groups']}")"
    dict['pattern']='\b(admin|root|sudo|wheel)\b'
    [[ -n "${dict['groups']}" ]] || return 1
    koopa_str_detect_regex \
        --string="${dict['groups']}" \
        --pattern="${dict['pattern']}" \
        && return 0
    return 1
}

koopa_is_alias() {
    _koopa_is_alias "$@"
}

koopa_is_alpine() {
    _koopa_is_alpine "$@"
}

koopa_is_arch() {
    _koopa_is_arch "$@"
}

koopa_is_array_empty() {
    ! koopa_is_array_non_empty "$@"
}

koopa_is_array_non_empty() {
    local -a arr
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
    _koopa_is_debian_like "$@"
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
    _koopa_is_fedora_like "$@"
}

koopa_is_file_system_case_sensitive() {
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['find']="$(koopa_locate_find)"
    app['wc']="$(koopa_locate_wc)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${PWD:?}"
    dict['tmp_stem']='.koopa.tmp.'
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
    local -A dict
    local -a pos
    local file
    dict['ext']=''
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

koopa_is_git_repo_clean() {
    local prefix
    koopa_assert_has_args "$#"
    for prefix in "$@"
    do
        koopa_is_git_repo "$prefix" || return 1
        koopa_git_repo_has_unstaged_changes "$prefix" && return 1
        koopa_git_repo_needs_pull_or_push "$prefix" && return 1
    done
    return 0
}

koopa_is_git_repo_top_level() {
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        [[ -d "$arg" ]] || return 1
        [[ -e "${arg}/.git" ]] || return 1
    done
    return 0
}

koopa_is_git_repo() {
    local -A app
    local repo
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    (
        for repo in "$@"
        do
            [[ -d "$repo" ]] || return 1
            koopa_is_git_repo_top_level "$repo" || return 1
            koopa_cd "$repo"
            "${app['git']}" rev-parse --git-dir >/dev/null 2>&1 || return 1
        done
        return 0
    )
}

koopa_is_github_ssh_enabled() {
    koopa_assert_has_no_args "$#"
    koopa_is_ssh_enabled 'git@github.com' 'successfully authenticated'
}

koopa_is_gitlab_ssh_enabled() {
    koopa_assert_has_no_args "$#"
    koopa_is_ssh_enabled 'git@gitlab.com' 'Welcome to GitLab'
}

koopa_is_gnu() {
    local cmd
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        local str
        koopa_is_installed "$cmd" || return 1
        str="$("$cmd" --version 2>&1 || true)"
        koopa_str_detect_fixed --pattern='GNU' --string="$str" || return 1
    done
    return 0
}

koopa_is_install_subshell() {
    [[ "${KOOPA_INSTALL_APP_SUBSHELL:-0}" -eq 1 ]]
}

koopa_is_installed() {
    _koopa_is_installed "$@"
}

koopa_is_interactive() {
    _koopa_is_interactive "$@"
}

koopa_is_koopa_app() {
    local app_prefix str
    koopa_assert_has_args "$#"
    app_prefix="$(koopa_app_prefix)"
    [[ -d "$app_prefix" ]] || return 1
    for str in "$@"
    do
        [[ -e "$str" ]] || return 1
        str="$(koopa_realpath "$str")"
        koopa_str_detect_regex \
            --string="$str" \
            --pattern="^${app_prefix}" \
            || return 1
    done
    return 0
}

koopa_is_linux() {
    _koopa_is_linux "$@"
}

koopa_is_macos() {
    _koopa_is_macos "$@"
}

koopa_is_opensuse() {
    _koopa_is_opensuse "$@"
}

koopa_is_owner() {
    local -A dict
    dict['prefix']="$(koopa_koopa_prefix)"
    dict['owner_id']="$(koopa_stat_user_id "${dict['prefix']}")"
    dict['user_id']="$(koopa_user_id)"
    [[ "${dict['user_id']}" == "${dict['owner_id']}" ]]
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
    local -A app dict
    local pkg
    koopa_assert_has_args "$#"
    app['r']="$(koopa_locate_r)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$(koopa_r_packages_prefix "${app['r']}")"
    for pkg in "$@"
    do
        [[ -d "${dict['prefix']}/${pkg}" ]] || return 1
    done
    return 0
}

koopa_is_recent() {
    local -A app dict
    local file
    koopa_assert_has_args "$#"
    app['find']="$(koopa_locate_find)"
    koopa_assert_is_executable "${app[@]}"
    dict['days']=14
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
    _koopa_is_rhel_like "$@"
}

koopa_is_root() {
    _koopa_is_root "$@"
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

koopa_is_ssh_enabled() {
    local -A app dict
    koopa_assert_has_args_eq "$#" 2
    app['ssh']="$(koopa_locate_ssh --allow-missing --allow-system)"
    [[ -x "${app['ssh']}" ]] || return 1
    dict['url']="${1:?}"
    dict['pattern']="${2:?}"
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
    _koopa_is_ubuntu_like "$@"
}

koopa_is_url_active() {
    local -A app dict
    local url
    koopa_assert_has_args "$#"
    app['curl']="$(koopa_locate_curl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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

koopa_is_user_install() {
    koopa_str_detect_fixed \
       --pattern="${HOME:?}" \
       --string="$(koopa_koopa_prefix)"
}

koopa_is_variable_defined() {
    local -A dict
    local var
    koopa_assert_has_args "$#"
    dict['nounset']="$(koopa_boolean_nounset)"
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    for var in "$@"
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

koopa_is_x86_64() {
    case "$(koopa_arch)" in
        'x86_64')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

koopa_jekyll_deploy_to_aws() {
    local -A app dict
    koopa_assert_has_args "$#"
    app['aws']="$(koopa_locate_aws)"
    app['bundle']="$(koopa_locate_bundle)"
    koopa_assert_is_executable "${app[@]}"
    dict['bucket_prefix']=''
    dict['bundle_prefix']="$(koopa_xdg_data_home)/gem"
    dict['distribution_id']=''
    dict['local_prefix']="${PWD:?}"
    dict['profile']="${AWS_PROFILE:-default}"
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
            '--local-prefix='*)
                dict['local_prefix']="${1#*=}"
                shift 1
                ;;
            '--local-prefix')
                dict['local_prefix']="${2:?}"
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
    koopa_assert_is_dir "${dict['local_prefix']}"
    dict['local_prefix']="$( \
        koopa_realpath "${dict['local_prefix']}" \
    )"
    dict['bucket_prefix']="$( \
        koopa_strip_trailing_slash "${dict['bucket_prefix']}" \
    )"
    koopa_alert "Deploying '${dict['local_prefix']}' \
to '${dict['bucket_prefix']}'."
    (
        koopa_cd "${dict['local_prefix']}"
        koopa_assert_is_file 'Gemfile'
        koopa_dl 'Bundle prefix' "${dict['bundle_prefix']}"
        "${app['bundle']}" config set --local path "${dict['bundle_prefix']}"
        [[ -f 'Gemfile.lock' ]] && koopa_rm 'Gemfile.lock'
        "${app['bundle']}" install
        "${app['bundle']}" exec jekyll build
        koopa_rm 'Gemfile.lock'
    )
    koopa_aws_s3_sync --profile="${dict['profile']}" \
        "${dict['local_prefix']}/_site/" \
        "${dict['bucket_prefix']}/"
    koopa_alert "Invalidating CloudFront cache at '${dict['distribution_id']}'."
    "${app['aws']}" cloudfront create-invalidation \
        --distribution-id "${dict['distribution_id']}" \
        --no-cli-pager \
        --output 'text' \
        --paths '/*' \
        --profile "${dict['profile']}"
    return 0
}

koopa_jekyll_serve() {
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['bundle']="$(koopa_locate_bundle)"
    koopa_assert_is_executable "${app[@]}"
    dict['bundle_prefix']="$(koopa_xdg_data_home)/gem"
    dict['prefix']="${1:-}"
    [[ -z "${dict['prefix']}" ]] && dict['prefix']="${PWD:?}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    koopa_alert "Serving Jekyll website in '${dict['prefix']}'."
    (
        koopa_cd "${dict['prefix']}"
        koopa_assert_is_file 'Gemfile'
        "${app['bundle']}" config set --local path "${dict['bundle_prefix']}"
        [[ -f 'Gemfile.lock' ]] && koopa_rm 'Gemfile.lock'
        "${app['bundle']}" install
        "${app['bundle']}" exec jekyll serve
        koopa_rm 'Gemfile.lock'
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
    local -A app dict
    local -a index_args
    koopa_assert_has_args "$#"
    app['kallisto']="$(koopa_locate_kallisto)"
    koopa_assert_is_executable "${app[@]}"
    dict['fasta_pattern']='\.(fa|fasta|fna)'
    dict['kmer_size']=31
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    dict['transcriptome_fasta_file']=''
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
        --pattern="${dict['fasta_pattern']}" \
        --string="${dict['transcriptome_fasta_file']}"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    dict['index_file']="${dict['output_dir']}/kallisto.idx"
    koopa_alert "Generating kallisto index at '${dict['output_dir']}'."
    index_args+=(
        "--index=${dict['index_file']}"
        "--kmer-size=${dict['kmer_size']}"
        '--make-unique'
        "--threads=${dict['threads']}"
        "${dict['transcriptome_fasta_file']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app['kallisto']}" index "${index_args[@]}"
    koopa_alert_success "kallisto index created at '${dict['output_dir']}'."
    return 0
}

koopa_kallisto_quant_paired_end_per_sample() {
    local -A app dict
    local -a quant_args
    koopa_assert_has_args "$#"
    app['kallisto']="$(koopa_locate_kallisto)"
    koopa_assert_is_executable "${app[@]}"
    dict['bootstraps']=30
    dict['fastq_r1_file']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_file']=''
    dict['fastq_r2_tail']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['threads']="$(koopa_cpu_count)"
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
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="${dict['fastq_r1_bn']/${dict['fastq_r1_tail']}/}"
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
    dict['fastq_r1_file']="$(koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r2_file']="$(koopa_realpath "${dict['fastq_r2_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' into '${dict['output_dir']}'."
    quant_args+=(
        '--bias'
        "--bootstrap-samples=${dict['bootstraps']}"
        "--index=${dict['index_file']}"
        "--output-dir=${dict['output_dir']}"
        "--threads=${dict['threads']}"
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
    local -A dict
    local -a fastq_r1_files
    local fastq_r1_file
    koopa_assert_has_args "$#"
    dict['fastq_dir']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mode']='paired-end'
    dict['output_dir']=''
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
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    koopa_assert_is_file "${fastq_r1_files[@]}"
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
    local -A app dict
    local -a quant_args
    app['kallisto']="$(koopa_locate_kallisto)"
    koopa_assert_is_executable "${app[@]}"
    dict['bootstraps']=30
    dict['fastq_file']=''
    dict['fastq_tail']=''
    dict['fragment_length']=200
    dict['index_dir']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['sd']=25
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
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
    dict['fastq_bn']="${dict['fastq_bn']/${dict['fastq_tail']}/}"
    dict['id']="${dict['fastq_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
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
    local -A dict
    local -a fastq_files
    local fastq_file
    koopa_assert_has_args "$#"
    dict['fastq_dir']=''
    dict['fastq_tail']=''
    dict['index_dir']=''
    dict['mode']='single-end'
    dict['output_dir']=''
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
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_tail']}'."
    fi
    koopa_assert_is_file "${fastq_files[@]}"
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

koopa_kebab_case() {
    local -a out
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    readarray -t out <<< "$( \
        koopa_gsub \
            --pattern='[^-A-Za-z0-9]' \
            --regex \
            --replacement='-' \
            "$@" \
        | koopa_lowercase \
    )"
    koopa_is_array_non_empty "${out[@]}" || return 1
    koopa_print "${out[@]}"
    return 0
}

koopa_local_ip_address() {
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['tail']="$(koopa_locate_tail --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    if koopa_is_macos
    then
        app['ifconfig']="$(koopa_macos_locate_ifconfig)"
        koopa_assert_is_executable "${app['ifconfig']}"
        str="$( \
            "${app['ifconfig']}" \
            | koopa_grep --pattern='inet ' \
            | koopa_grep --pattern='broadcast' \
            | "${app['awk']}" '{print $2}' \
            | "${app['tail']}" -n 1 \
        )"
    else
        app['hostname']="$(koopa_locate_hostname)"
        koopa_assert_is_executable "${app['hostname']}"
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

koopa_koopa_prefix() {
    _koopa_koopa_prefix "$@"
}

koopa_koopa_url() {
    koopa_assert_has_no_args "$#"
    koopa_print 'https://koopa.acidgenomics.com'
    return 0
}

koopa_koopa_version() {
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['cat']="$(koopa_locate_cat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['version_file']="${dict['koopa_prefix']}/VERSION"
    koopa_assert_is_file "${dict['version_file']}"
    dict['version']="$("${app['cat']}" "${dict['version_file']}")"
    koopa_print "${dict['version']}"
    return 0
}

koopa_line_count() {
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['wc']="$(koopa_locate_wc)"
    app['xargs']="$(koopa_locate_xargs)"
    koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local str
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

koopa_link_in_bin() {
    koopa_link_in_dir --prefix="$(koopa_bin_prefix)" "$@"
}

koopa_link_in_dir() {
    local -A dict
    koopa_assert_has_args "$#"
    dict['name']=''
    dict['prefix']=''
    dict['source']=''
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

koopa_link_in_man1() {
    koopa_link_in_dir --prefix="$(koopa_man_prefix)/man1" "$@"
}

koopa_link_in_opt() {
    koopa_link_in_dir --prefix="$(koopa_opt_prefix)" "$@"
}

koopa_list_app_versions() {
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['prefix']="$(koopa_app_prefix)"
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

koopa_list_path_priority_unique() {
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['awk']="$(koopa_locate_awk)"
    app['tac']="$(koopa_locate_tac)"
    koopa_assert_is_executable "${app[@]}"
    dict['string']="${1:-$PATH}"
    dict['string']="$( \
        koopa_print "${dict['string']//:/$'\n'}" \
        | "${app['tac']}" \
        | "${app['awk']}" '!a[$0]++' \
        | "${app['tac']}" \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}

koopa_list_path_priority() {
    local -A app dict
    local -a all_arr unique_arr
    koopa_assert_has_args_le "$#" 1
    app['awk']="$(koopa_locate_awk)"
    koopa_assert_is_executable "${app[@]}"
    dict['string']="${1:-$PATH}"
    readarray -t all_arr <<< "$( \
        koopa_print "${dict['string']//:/$'\n'}" \
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

koopa_ln() {
    local -A app dict
    local -a ln ln_args mkdir pos rm
    app['ln']="$(koopa_locate_ln --allow-system)"
    dict['sudo']=0
    dict['target_dir']=''
    dict['verbose']=0
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
            '--quiet' | \
            '-q')
                dict['verbose']=0
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                dict['verbose']=1
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
        ln=('koopa_sudo' "${app['ln']}")
        mkdir=('koopa_mkdir' '--sudo')
        rm=('koopa_rm' '--sudo')
    else
        ln=("${app['ln']}")
        mkdir=('koopa_mkdir')
        rm=('koopa_rm')
    fi
    ln_args=('-f' '-n' '-s')
    [[ "${dict['verbose']}" -eq 1 ]] && ln_args+=('-v')
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
    koopa_assert_is_executable "${app[@]}"
    "${ln[@]}" "${ln_args[@]}"
    return 0
}

koopa_local_data_prefix() {
    _koopa_local_data_prefix "$@"
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
    local -A bool dict
    local -a pos
    bool['allow_koopa_bin']=1
    bool['allow_missing']=0
    bool['allow_system']=0
    bool['only_system']=0
    bool['realpath']=0
    dict['app']=''
    dict['app_name']=''
    dict['bin_name']=''
    dict['bin_prefix']="$(koopa_bin_prefix)"
    dict['opt_prefix']="$(koopa_opt_prefix)"
    dict['system_bin_name']=''
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
            '--only-system')
                bool['only_system']=1
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
    if [[ "${bool['only_system']}" -eq 1 ]]
    then
        bool['allow_koopa_bin']=0
        bool['allow_system']=1
    fi
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
    if [[ "${bool['only_system']}" -eq 0 ]]
    then
        dict['app']="${dict['opt_prefix']}/${dict['app_name']}/\
bin/${dict['bin_name']}"
    fi
    if [[ ! -x "${dict['app']}" ]] && [[ "${bool['allow_system']}" -eq 1 ]]
    then
        [[ -z "${dict['system_bin_name']}" ]] && \
            dict['system_bin_name']="${dict['bin_name']}"
        if [[ -x "/usr/local/bin/${dict['system_bin_name']}" ]]
        then
            dict['app']="/usr/local/bin/${dict['system_bin_name']}"
        elif [[ -x "/usr/bin/${dict['system_bin_name']}" ]]
        then
            dict['app']="/usr/bin/${dict['system_bin_name']}"
        elif [[ -x "/bin/${dict['system_bin_name']}" ]]
        then
            dict['app']="/bin/${dict['system_bin_name']}"
        elif [[ -x "/usr/sbin/${dict['system_bin_name']}" ]]
        then
            dict['app']="/usr/sbin/${dict['system_bin_name']}"
        elif [[ -x "/sbin/${dict['system_bin_name']}" ]]
        then
            dict['app']="/sbin/${dict['system_bin_name']}"
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
    if [[ "${bool['allow_system']}" -eq 1 ]]
    then
        koopa_stop \
            "Failed to locate '${dict['system_bin_name']}'."
    else
        koopa_stop \
            "Failed to locate '${dict['bin_name']}'." \
            "Run 'koopa install ${dict['app_name']}' to resolve."
    fi
}

koopa_locate_ar() {
    koopa_locate_app \
        --app-name='binutils' \
        --bin-name='ar' \
        "$@"
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
        --system-bin-name='basename' \
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

koopa_locate_brew() {
    koopa_locate_app \
        "$(koopa_homebrew_prefix)/bin/brew" \
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

koopa_locate_cc() {
    local str
    if koopa_is_macos
    then
        str='/usr/bin/clang'
    else
        str='/usr/bin/gcc'
    fi
    koopa_locate_app "$str"
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
    local -a args
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

koopa_locate_compress() {
    koopa_locate_app \
        '/usr/bin/compress' \
        "$@"
}

koopa_locate_conda_python() {
    koopa_locate_app \
        --app-name='conda' \
        --bin-name='python' \
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

koopa_locate_corepack() {
    koopa_locate_app \
        --app-name='node' \
        --bin-name='corepack' \
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

koopa_locate_cxx() {
    local str
    if koopa_is_macos
    then
        str='/usr/bin/clang++'
    else
        str='/usr/bin/g++'
    fi
    koopa_locate_app "$str"
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
        --system-bin-name='dirname' \
        "$@"
}

koopa_locate_docker() {
    local -a args
    args=()
    if koopa_is_macos
    then
        if [[ -x "${HOME:?}/.docker/bin/docker" ]]
        then
            args+=("${HOME:?}/.docker/bin/docker")
        else
            args+=('/usr/local/bin/docker')
        fi
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
        --system-bin-name='du' \
        "$@"
}

koopa_locate_echo() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gecho' \
        --system-bin-name='echo' \
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

koopa_locate_gunzip() {
    koopa_locate_app \
        --app-name='gzip' \
        --bin-name='gunzip' \
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
        --system-bin-name='id' \
        "$@"
}

koopa_locate_jar() {
    koopa_locate_app \
        --app-name='temurin' \
        --bin-name='jar' \
        "$@"
}

koopa_locate_java() {
    koopa_locate_app \
        --app-name='temurin' \
        --bin-name='java' \
        "$@"
}

koopa_locate_javac() {
    koopa_locate_app \
        --app-name='temurin' \
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

koopa_locate_ld() {
    koopa_locate_app \
        '/usr/bin/ld' \
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
        --system-bin-name='ls' \
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

koopa_locate_lz4() {
    koopa_locate_app \
        --app-name='lz4' \
        --bin-name='lz4' \
        "$@"
}

koopa_locate_lzip() {
    koopa_locate_app \
        --app-name='lzip' \
        --bin-name='lzip' \
        "$@"
}

koopa_locate_lzma() {
    koopa_locate_app \
        --app-name='xz' \
        --bin-name='lzma' \
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
    local system_bin_name
    if koopa_is_macos
    then
        system_bin_name='md5'
    else
        system_bin_name='md5sum'
    fi
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmd5sum' \
        --system-bin-name="$system_bin_name" \
        "$@"
}

koopa_locate_meson() {
    koopa_locate_app \
        --app-name='meson' \
        --bin-name='meson' \
        "$@"
}

koopa_locate_minimap2() {
    koopa_locate_app \
        --app-name='minimap2' \
        --bin-name='minimap2' \
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

koopa_locate_msgfmt() {
    koopa_locate_app \
        --app-name='gettext' \
        --bin-name='msgfmt' \
        "$@"
}

koopa_locate_msgmerge() {
    koopa_locate_app \
        --app-name='gettext' \
        --bin-name='msgmerge' \
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
        --system-bin-name='nproc' \
        "$@"
}

koopa_locate_numfmt() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gnumfmt' \
        --system-bin-name='numfmt' \
        "$@"
}

koopa_locate_od() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='god' \
        --system-bin-name='od' \
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
        --system-bin-name='parallel' \
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
        --system-bin-name='paste' \
        "$@"
}

koopa_locate_patch() {
    koopa_locate_app \
        --app-name='patch' \
        --bin-name='patch' \
        "$@"
}

koopa_locate_pbzip2() {
    koopa_locate_app \
        --app-name='pbzip2' \
        --bin-name='pbzip2' \
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

koopa_locate_pigz() {
    koopa_locate_app \
        --app-name='pigz' \
        --bin-name='pigz' \
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

koopa_locate_python311() {
    koopa_locate_app \
        --app-name='python3.11' \
        --bin-name='python3.11' \
        "$@"
}

koopa_locate_python312() {
    koopa_locate_app \
        --app-name='python3.12' \
        --bin-name='python3.12' \
        "$@"
}

koopa_locate_r() {
    koopa_locate_app \
        --app-name='r' \
        --bin-name='R' \
        "$@"
}

koopa_locate_ranlib() {
    koopa_locate_app \
        --app-name='binutils' \
        --bin-name='ranlib' \
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
        --system-bin-name='readlink' \
        "$@"
}

koopa_locate_realpath() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='grealpath' \
        --system-bin-name='realpath' \
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
    local -a args
    if koopa_is_macos
    then
        args+=('/usr/bin/scp')
    else
        args+=(
            '--app-name=openssh'
            '--bin-name=scp'
        )
    fi
    koopa_locate_app "${args[@]}" "$@"
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
    koopa_locate_app \
        --app-name='openssh' \
        --bin-name='ssh-add' \
        "$@"
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

koopa_locate_strip() {
    koopa_locate_app \
        '/usr/bin/strip' \
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

koopa_locate_system_rscript() {
    local cmd
    if koopa_is_macos
    then
        cmd='/Library/Frameworks/R.framework/Resources/bin/Rscript'
    else
        cmd='/usr/bin/Rscript'
    fi
    koopa_locate_app "$cmd"
}

koopa_locate_tac() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtac' \
        --system-bin-name='tac' \
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
    local -a args
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
    local -a args
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
        '/usr/bin/uncompress' \
        "$@"
}

koopa_locate_uniq() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='guniq' \
        --system-bin-name='uniq' \
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
        --system-bin-name='wc' \
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
        --system-bin-name='whoami' \
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
        --system-bin-name='yes' \
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

koopa_locate_zstd() {
    koopa_locate_app \
        --app-name='zstd' \
        --bin-name='zstd' \
        "$@"
}

koopa_log_file() {
    local -A dict
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
    local -A app
    local str
    app['tr']="$(koopa_locate_tr --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
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

koopa_major_minor_patch_version() {
    _koopa_major_minor_patch_version "$@"
}

koopa_major_minor_version() {
    _koopa_major_minor_version "$@"
}

koopa_major_version() {
    _koopa_major_version "$@"
}

koopa_make_build_string() {
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['arch']="$(koopa_arch)"
    if koopa_is_linux
    then
        dict['os_type']='linux-gnu'
    else
        dict['os_type']="$(koopa_os_type)"
    fi
    koopa_print "${dict['arch']}-${dict['os_type']}"
    return 0
}

koopa_make_build() {
    local -A app dict
    local -a conf_args pos targets
    local target
    koopa_assert_has_args "$#"
    if [[ "${KOOPA_INSTALL_NAME:?}" == 'make' ]]
    then
        app['make']="$(koopa_locate_make --only-system)"
    else
        koopa_activate_app --build-only 'make'
        app['make']="$(koopa_locate_make)"
    fi
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            '--jobs='*)
                dict['jobs']="${1#*=}"
                shift 1
                ;;
            '--jobs')
                dict['jobs']="${2:?}"
                shift 2
                ;;
            '--target='*)
                targets+=("${1#*=}")
                shift 1
                ;;
            '--target')
                targets+=("${2:?}")
                shift 2
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_is_array_empty "${targets[@]}" && targets+=('install')
    conf_args+=("$@")
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    koopa_assert_is_executable './configure'
    ./configure --help || true
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    for target in "${targets[@]}"
    do
        "${app['make']}" "$target"
    done
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
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['md5sum']="$(koopa_locate_md5sum)"
    app['sh']="$(koopa_locate_sh)"
    app['xargs']="$(koopa_locate_xargs)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
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
    local -A app dict
    koopa_assert_has_args "$#"
    app['md5sum']="$(koopa_locate_md5sum)"
    app['tee']="$(koopa_locate_tee)"
    koopa_assert_is_executable "${app[@]}"
    dict['datetime']="$(koopa_datetime)"
    dict['log_file']="md5sum-${dict['datetime']}.md5"
    koopa_assert_is_not_file "${dict['log_file']}"
    koopa_assert_is_file "$@"
    "${app['md5sum']}" "$@" 2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}

koopa_mem_gb() {
    local -A app dict
    koopa_assert_has_no_args "$#"
    dict['str']="${KOOPA_MEM_GB:-}"
    if [[ -n "${dict['str']}" ]]
    then
        koopa_print "${dict['str']}"
        return 0
    fi
    app['awk']="$(koopa_locate_awk --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    if koopa_is_macos
    then
        app['sysctl']="$(koopa_macos_locate_sysctl)"
        koopa_assert_is_executable "${app['sysctl']}"
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
    local -A app
    koopa_assert_has_args "$#"
    app['gs']="$(koopa_locate_gs)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    local -a mkdir mkdir_args pos
    app['mkdir']="$(koopa_locate_mkdir --allow-system)"
    dict['sudo']=0
    dict['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--quiet' | \
            '-q')
                dict['verbose']=0
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                dict['verbose']=1
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
    [[ "${dict['verbose']}" -eq 1 ]] && mkdir_args+=('-v')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        mkdir=('koopa_sudo' "${app['mkdir']}")
    else
        mkdir=("${app['mkdir']}")
    fi
    koopa_assert_is_executable "${app[@]}"
    "${mkdir[@]}" "${mkdir_args[@]}" "$@"
    return 0
}

koopa_mktemp() {
    local -A app dict
    app['mktemp']="$(koopa_locate_mktemp --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['str']="$("${app['mktemp']}" "$@")"
    [[ -e "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_monorepo_prefix() {
    koopa_print "${HOME:?}/monorepo"
    return 0
}

koopa_move_files_in_batch() {
    local -A app dict
    local files
    koopa_assert_has_args_eq "$#" 3
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['num']=''
    dict['source_dir']=''
    dict['target_dir']=''
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
    local -A dict
    local -a files
    koopa_assert_has_args_le "$#" 1
    dict['prefix']="${1:-}"
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
    local -a grep_array
    local file grep_string
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
        local -A dict
        dict['file']="$file"
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
        subdir="$(koopa_stat_modified --format='%Y/%m/%d' "$file")"
        koopa_mv --target-directory="$subdir" "$file"
    done
    return 0
}

koopa_msg() {
    local -A dict
    local string
    dict['c1']="$(koopa_ansi_escape "${1:?}")"
    dict['c2']="$(koopa_ansi_escape "${2:?}")"
    dict['nc']="$(koopa_ansi_escape 'nocolor')"
    dict['prefix']="${3:?}"
    shift 3
    for string in "$@"
    do
        koopa_print "${dict['c1']}${dict['prefix']}${dict['nc']} \
${dict['c2']}${string}${dict['nc']}"
    done
    return 0
}

koopa_mv() {
    local -A app dict
    local -a mkdir mv mv_args pos rm
    app['mv']="$(koopa_locate_mv --allow-system)"
    koopa_is_macos && app['mv']='/bin/mv'
    koopa_assert_is_executable "${app[@]}"
    dict['sudo']=0
    dict['target_dir']=''
    dict['verbose']=0
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
            '--quiet' | \
            '-q')
                dict['verbose']=0
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                dict['verbose']=1
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
        mkdir=('koopa_mkdir' '--sudo')
        mv=('koopa_sudo' "${app['mv']}")
        rm=('koopa_rm' '--sudo')
    else
        mkdir=('koopa_mkdir')
        mv=("${app['mv']}")
        rm=('koopa_rm')
    fi
    mv_args=('-f')
    [[ "${dict['verbose']}" -eq 1 ]] && mv_args+=('-v')
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
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['sed']="$(koopa_locate_sed --allow-system)"
    app['sort']="$(koopa_locate_sort)"
    app['uniq']="$(koopa_locate_uniq)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${1:?}"
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
    local -A dict
    koopa_assert_has_args "$#"
    dict['middle']=' '
    dict['msg1']=''
    dict['msg2']=''
    dict['num']=''
    dict['prefix']=''
    dict['str']=''
    dict['suffix']=''
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

koopa_opt_prefix() {
    _koopa_opt_prefix "$@"
}

koopa_os_id() {
    _koopa_os_id "$@"
}

koopa_os_string() {
    _koopa_os_string "$@"
}

koopa_os_type() {
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['tr']="$(koopa_locate_tr --allow-system)"
    app['uname']="$(koopa_locate_uname --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['uname']}" -s \
        | "${app['tr']}" '[:upper:]' '[:lower:]' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_pager() {
    local -A app
    local -a args
    koopa_assert_has_args "$#"
    app['less']="$(koopa_locate_less --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    args=("$@")
    koopa_assert_is_file "${args[-1]}"
    "${app['less']}" -R "${args[@]}"
    return 0
}

koopa_parent_dir() {
    local -A app dict
    local -a pos
    local file
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['cd_tail']=''
    dict['n']=1
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
        local parent
        [[ -e "$file" ]] || return 1
        parent="$(koopa_dirname "$file")"
        parent="${parent}${dict['cd_tail']}"
        parent="$(koopa_cd "$parent" && pwd -P)"
        koopa_print "$parent"
    done
    return 0
}

koopa_parse_url() {
    local -A app
    local -a curl_args pos
    koopa_assert_has_args "$#"
    app['curl']="$(koopa_locate_curl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    curl_args=(
        '--disable'
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
    local -a pos
    local IFS sep str
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

koopa_patch_prefix() {
    koopa_print "$(koopa_koopa_prefix)/lang/bash/include/patch"
    return 0
}

koopa_prelude_emacs_prefix() {
    _koopa_prelude_emacs_prefix "$@"
}

koopa_prelude_emacs() {
    _koopa_prelude_emacs "$@"
}

koopa_print_ansi() {
    local color nocolor str
    color="$(koopa_ansi_escape "${1:?}")"
    nocolor="$(koopa_ansi_escape 'nocolor')"
    shift 1
    for str in "$@"
    do
        printf '%s%b%s\n' "$color" "$str" "$nocolor"
    done
    return 0
}

koopa_print_black_bold() {
    koopa_print_ansi 'black-bold' "$@"
    return 0
}

koopa_print_black() {
    koopa_print_ansi 'black' "$@"
    return 0
}

koopa_print_blue_bold() {
    koopa_print_ansi 'blue-bold' "$@"
    return 0
}

koopa_print_blue() {
    koopa_print_ansi 'blue' "$@"
    return 0
}

koopa_print_cyan_bold() {
    koopa_print_ansi 'cyan-bold' "$@"
    return 0
}

koopa_print_cyan() {
    koopa_print_ansi 'cyan' "$@"
    return 0
}

koopa_print_default_bold() {
    koopa_print_ansi 'default-bold' "$@"
    return 0
}

koopa_print_default() {
    koopa_print_ansi 'default' "$@"
    return 0
}

koopa_print_env() {
    export -p
    return 0
}

koopa_print_green_bold() {
    koopa_print_ansi 'green-bold' "$@"
    return 0
}

koopa_print_green() {
    koopa_print_ansi 'green' "$@"
    return 0
}

koopa_print_magenta_bold() {
    koopa_print_ansi 'magenta-bold' "$@"
    return 0
}

koopa_print_magenta() {
    koopa_print_ansi 'magenta' "$@"
    return 0
}

koopa_print_red_bold() {
    koopa_print_ansi 'red-bold' "$@"
    return 0
}

koopa_print_red() {
    koopa_print_ansi 'red' "$@"
    return 0
}

koopa_print_white_bold() {
    koopa_print_ansi 'white-bold' "$@"
    return 0
}

koopa_print_white() {
    koopa_print_ansi 'white' "$@"
    return 0
}

koopa_print_yellow_bold() {
    koopa_print_ansi 'yellow-bold' "$@"
    return 0
}

koopa_print_yellow() {
    koopa_print_ansi 'yellow' "$@"
    return 0
}

koopa_print() {
    _koopa_print "$@"
}

koopa_private_installers_s3_uri() {
    koopa_assert_has_no_args "$#"
    koopa_print 's3://private.koopa.acidgenomics.com/installers'
}

koopa_progress_bar() {
    local -A app dict
    koopa_assert_has_args_eq "$#" 2
    [[ "${COLUMNS:?}" -lt 40 ]] && return 0
    app['bc']="$(koopa_locate_bc)"
    app['echo']="$(koopa_locate_echo)"
    app['tr']="$(koopa_locate_tr)"
    koopa_assert_is_executable "${app[@]}"
    dict['bar_char_done']='#'
    dict['bar_char_todo']='-'
    dict['bar_pct_scale']=1
    dict['bar_size']="$((COLUMNS-20))"
    dict['current']="${1:?}"
    dict['total']="${2:?}"
    dict['percent']="$( \
        "${app['bc']}" <<< \
            "scale=${dict['bar_pct_scale']}; \
            100 * ${dict['current']} / ${dict['total']}" \
    )"
    dict['percent_str']="$( \
        printf "%0.${dict['bar_pct_scale']}f" "${dict['percent']}"
    )"
    dict['done']="$( \
        "${app['bc']}" <<< \
            "scale=0; \
            ${dict['bar_size']} * ${dict['percent']} / 100" \
    )"
    dict['todo']="$( \
        "${app['bc']}" <<< \
            "scale=0; ${dict['bar_size']} - ${dict['done']}" \
    )"
    dict['done_sub_bar']=$( \
        printf "%${dict['done']}s" | \
        "${app['tr']}" ' ' "${dict['bar_char_done']}" \
    )
    dict['todo_sub_bar']=$( \
        printf "%${dict['todo']}s" \
        | "${app['tr']}" ' ' "${dict['bar_char_todo']}" \
    )
    >&2 "${app['echo']}" -en "\r\
Progress \
[${dict['done_sub_bar']}${dict['todo_sub_bar']}] \
${dict['percent_str']}% "
    if [[ "${dict['total']}" -eq "${dict['current']}" ]]
    then
        printf '\n'
        koopa_alert_success 'DONE!'
    fi
    return 0
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
    local -A app
    local str
    koopa_assert_has_no_args "$#"
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
    local -A dict
    local -a app_names
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
    local -A app dict
    local name
    koopa_assert_has_args "$#"
    koopa_can_push_binary || return 1
    app['aws']="$(koopa_locate_aws)"
    app['tar']="$(koopa_locate_tar)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch2)" # e.g. 'amd64'.
    dict['opt_prefix']="$(koopa_opt_prefix)"
    dict['os_string']="$(koopa_os_string)"
    dict['profile']='acidgenomics'
    dict['s3_bucket']='s3://private.koopa.acidgenomics.com/binaries'
    dict['tmp_dir']="$(koopa_tmp_dir)"
    for name in "$@"
    do
        local -A dict2
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
        "${app['aws']}" s3 cp \
            --profile "${dict['profile']}" \
            "${dict2['local_tar']}" "${dict2['remote_tar']}"
    done
    koopa_rm "${dict['tmp_dir']}"
    return 0
}

koopa_python_activate_venv() {
    local -A dict
    koopa_assert_has_args_eq "$#" 1
    dict['active_env']="${VIRTUAL_ENV:-}"
    dict['name']="${1:?}"
    dict['nounset']="$(koopa_boolean_nounset)"
    dict['prefix']="$(koopa_python_virtualenvs_prefix)"
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
    local -A app bool dict
    local -a pip_args pkgs pos venv_args
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    app['python']=''
    bool['binary']=1
    bool['pip']=1
    bool['system_site_packages']=1
    dict['name']=''
    dict['prefix']=''
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
            '--no-binary')
                bool['binary']=0
                shift 1
                ;;
            '--without-pip')
                bool['pip']=0
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
    pkgs=("$@")
    [[ -z "${app['python']}" ]] && \
        app['python']="$(koopa_locate_python312 --realpath)"
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
    if [[ "${bool['pip']}" -eq 0 ]]
    then
        venv_args+=('--without-pip')
    fi
    if [[ "${bool['system_site_packages']}" -eq 1 ]]
    then
        venv_args+=('--system-site-packages')
    fi
    venv_args+=("${dict['prefix']}")
    "${app['python']}" -m venv "${venv_args[@]}"
    app['venv_python']="${dict['prefix']}/bin/python${dict['py_maj_min_ver']}"
    koopa_assert_is_installed "${app['venv_python']}"
    if [[ "${bool['pip']}" -eq 1 ]]
    then
        dict['pip_version']='23.2.1'
        dict['setuptools_version']='68.2.2'
        dict['wheel_version']='0.41.2'
        pip_args=(
            "--python=${app['venv_python']}"
            "pip==${dict['pip_version']}"
            "setuptools==${dict['setuptools_version']}"
            "wheel==${dict['wheel_version']}"
        )
        koopa_python_pip_install "${pip_args[@]}"
    fi
    if koopa_is_array_non_empty "${pkgs[@]:-}"
    then
        pip_args=("--python=${app['venv_python']}")
        if [[ "${bool['binary']}" -eq 0 ]]
        then
            pip_args+=('--no-binary=:all:')
        fi
        pip_args+=("${pkgs[@]}")
        koopa_python_pip_install "${pip_args[@]}"
    fi
    koopa_sys_set_permissions --recursive "${dict['prefix']}"
    return 0
}

koopa_python_deactivate_venv() {
    local -A dict
    dict['prefix']="${VIRTUAL_ENV:-}"
    if [[ -z "${dict['prefix']}" ]]
    then
        koopa_stop 'Python virtual environment is not active.'
    fi
    koopa_remove_from_path_string "${dict['prefix']}/bin"
    unset -v VIRTUAL_ENV
    return 0
}

koopa_python_pip_install() {
    local -A app dict
    local -a dl_args pos
    koopa_assert_has_args "$#"
    dict['prefix']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--no-binary='*)
                pos=("$1")
                shift 1
                ;;
            '--no-binary')
                pos=("$1" "${2:?}")
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
    [[ -z "${app['python']}" ]] && \
        app['python']="$(koopa_locate_python312 --realpath)"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_executable "${app[@]}"
    install_args=(
        '--default-timeout=300'
        '--disable-pip-version-check'
        '--ignore-installed'
        '--no-cache-dir'
        '--no-warn-script-location'
        '--progress-bar=on'
    )
    if [[ -n "${dict['prefix']}" ]]
    then
        install_args+=(
            "--target=${dict['prefix']}"
            '--upgrade'
        )
        dl_args+=('Target' "${dict['prefix']}")
    fi
    install_args+=("$@")
    dl_args=(
        'python' "${app['python']}"
        'pip install args' "${install_args[*]}"
    )
    koopa_dl "${dl_args[@]}"
    export PIP_REQUIRE_VIRTUALENV='false'
    "${app['python']}" -m pip --isolated install "${install_args[@]}"
    return 0
}

koopa_python_system_packages_prefix() {
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['python']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$( \
        "${app['python']}" -c 'import site; print(site.getsitepackages()[0])' \
    )"
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_print "${dict['prefix']}"
    return 0
}

koopa_python_virtualenvs_prefix() {
    koopa_print "${HOME}/.virtualenvs"
    return 0
}

koopa_r_bioconda_check() {
    local -A dict
    koopa_assert_has_args "$#"
    dict['tmp_dir']="$(koopa_tmp_dir)"
    dict['conda_cache_prefix']="$(koopa_init_dir "${dict['tmp_dir']}/conda")"
    export CONDA_PKGS_DIRS="${dict['conda_cache_prefix']}"
    for pkg in "$@"
    do
        local -A dict2
        dict2['pkg']="$pkg"
        dict2['pkg2']="r-$(koopa_lowercase "${dict2['pkg']}")"
        dict2['tmp_dir']="$( \
            koopa_init_dir "${dict['tmp_dir']}/${dict2['pkg2']}" \
        )"
        dict2['tarball']="https://github.com/acidgenomics/\
r-${dict2['pkg2']}/archive/refs/heads/develop.tar.gz"
        dict2['conda_prefix']="$(koopa_init_dir "${dict2['tmp_dir']}/conda")"
        dict2['tarball']="https://github.com/acidgenomics/${dict2['pkg2']}/\
archive/refs/heads/develop.tar.gz"
        dict2['rscript']="${dict2['tmp_dir']}/check.R"
        read -r -d '' "dict2[rscript_string]" << END || true
pkgbuild::check_build_tools(debug = TRUE)
install.packages(
    pkgs = c("AcidDevTools", "AcidTest"),
    repos = c(
        "https://r.acidgenomics.com",
        BiocManager::repositories()
    ),
    dependencies = FALSE
)
AcidDevTools::check("src")
END
        koopa_write_string \
            --file="${dict2['rscript']}" \
            --string="${dict2['rscript_string']}"
        koopa_alert "Checking '${dict2['pkg']}' in '${dict2['tmp_dir']}'."
        (
            local -A app2
            local -a conda_deps
            koopa_cd "${dict2['tmp_dir']}"
            conda_deps=(
                'r-biocmanager'
                'r-desc'
                'r-goalie'
                'r-knitr'
                'r-rcmdcheck'
                'r-rmarkdown'
                'r-testthat'
                'r-urlchecker'
                "${dict2['pkg2']}"
            )
            koopa_conda_create_env \
                --prefix="${dict2['conda_prefix']}" \
                "${conda_deps[@]}"
            app2['rscript']="${dict2['conda_prefix']}/bin/Rscript"
            koopa_assert_is_executable "${app2[@]}"
            koopa_download "${dict2['tarball']}"
            koopa_extract "$(koopa_basename "${dict2['tarball']}")" 'src'
            koopa_conda_activate_env "${dict2['conda_prefix']}"
            "${app2['rscript']}" "${dict2['rscript']}"
            koopa_conda_deactivate
        )
    done
    koopa_rm "${dict['tmp_dir']}"
    return 0
}

koopa_r_check() {
    local -A app
    local -A dict
    local pkg
    koopa_assert_has_args "$#"
    app['rscript']="$(koopa_locate_rscript --only-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['tmp_dir']="$(koopa_tmp_dir)"
    for pkg in "$@"
    do
        local -A dict2
        dict2['pkg']="$pkg"
        dict2['pkg2']="r-$(koopa_lowercase "${dict2['pkg']}")"
        dict2['tmp_dir']="$( \
            koopa_init_dir "${dict['tmp_dir']}/${dict2['pkg2']}" \
        )"
        dict2['tmp_lib']="$(koopa_init_dir "${dict2['tmp_dir']}/lib")"
        dict2['tarball']="https://github.com/acidgenomics/\
${dict2['pkg2']}/archive/refs/heads/develop.tar.gz"
        dict2['rscript']="${dict2['tmp_dir']}/check.R"
        read -r -d '' "dict2[rscript_string]" << END || true
.libPaths(new = "${dict2['tmp_lib']}", include.site = FALSE)
message("repos")
print(getOption("repos"))
message(".libPaths")
print(.libPaths())
message("Installing AcidDevTools.")
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}
if (!requireNamespace("AcidDevTools", quietly = TRUE)) {
    install.packages(
        pkgs = c(
            "AcidDevTools",
            "desc",
            "goalie",
            "rcmdcheck",
            "testthat",
            "urlchecker"
        ),
        repos = c(
            "https://r.acidgenomics.com",
            BiocManager::repositories()
        ),
        dependencies = NA
    )
}
message("Installing ${dict2['pkg']}.")
install.packages(
    pkgs = "${dict2['pkg']}",
    repos = c(
        "https://r.acidgenomics.com",
        BiocManager::repositories()
    ),
    dependencies = TRUE
)
AcidDevTools::check("src")
END
        koopa_write_string \
            --file="${dict2['rscript']}" \
            --string="${dict2['rscript_string']}"
        koopa_alert "Checking '${dict2['pkg']}' in '${dict2['tmp_dir']}'."
        (
            koopa_cd "${dict2['tmp_dir']}"
            koopa_download "${dict2['tarball']}"
            koopa_extract "$(koopa_basename "${dict2['tarball']}")" 'src'
            "${app['rscript']}" "${dict2['rscript']}"
        )
    done
    koopa_rm "${dict['tmp_dir']}"
    return 0
}

koopa_r_configure_environ() {
    local -A app app_pc_path_arr bool conf_dict dict
    local -a keys lines path_arr pc_path_arr
    local i key
    lines=()
    path_arr=()
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    app['sort']="$(koopa_locate_sort --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    bool['use_apps']=1
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    if [[ "${bool['system']}" -eq 1 ]] && koopa_is_linux
    then
        bool['use_apps']=0
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        app['bzip2']="$(koopa_locate_bzip2)"
        app['cat']="$(koopa_locate_cat)"
        app['gzip']="$(koopa_locate_gzip)"
        app['less']="$(koopa_locate_less)"
        app['ln']="$(koopa_locate_ln)"
        app['make']="$(koopa_locate_make)"
        app['pkg_config']="$(koopa_locate_pkg_config)"
        app['sed']="$(koopa_locate_sed --allow-system)"
        app['strip']="$(koopa_locate_strip)"
        app['tar']="$(koopa_locate_tar)"
        app['texi2dvi']="$(koopa_locate_texi2dvi)"
        app['unzip']="$(koopa_locate_unzip)"
        app['vim']="$(koopa_locate_vim)"
        app['zip']="$(koopa_locate_zip)"
        koopa_assert_is_executable "${app[@]}"
        app['lpr']="$(koopa_locate_lpr --allow-missing --only-system)"
        app['open']="$(koopa_locate_open --allow-missing --only-system)"
        dict['udunits2']="$(koopa_app_prefix 'udunits')"
    fi
    dict['bin_prefix']="$(koopa_bin_prefix)"
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    koopa_assert_is_dir "${dict['r_prefix']}"
    lines+=(
        'R_BATCHSAVE=--no-save --no-restore'
        "R_LIBS_SITE=\${R_HOME}/site-library"
        "R_LIBS_USER=\${R_LIBS_SITE}"
        'R_PAPERSIZE=letter'
        "R_PAPERSIZE_USER=\${R_PAPERSIZE}"
        "TZ=\${TZ:-America/New_York}"
    )
    if koopa_is_linux
    then
        path_arr+=(
            '/usr/lib/rstudio-server/bin/quarto/bin'
            '/usr/lib/rstudio-server/bin/quarto/bin/tools'
            '/usr/lib/rstudio-server/bin/postback'
        )
    elif koopa_is_macos
    then
        path_arr+=(
            '/Applications/RStudio.app/Contents/Resources/app/quarto/bin'
            '/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools'
            '/Applications/RStudio.app/Contents/Resources/app/bin/postback'
        )
    fi
    if [[ "${bool['system']}" -eq 0 ]] || koopa_is_macos
    then
        path_arr+=("${dict['bin_prefix']}")
    fi
    path_arr+=('/usr/bin' '/bin')
    if koopa_is_macos
    then
        path_arr+=(
            '/Library/TeX/texbin'
            '/usr/local/MacGPG2/bin'
            '/opt/X11/bin'
        )
    fi
    conf_dict['path']="$(printf '%s:' "${path_arr[@]}")"
    lines+=("PATH=${conf_dict['path']}")
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        keys=(
            'cairo'
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
            'libffi'
            'libgit2'
            'libjpeg-turbo'
            'libpng'
            'libssh2'
            'libtiff'
            'libxml2'
            'openssl3'
            'pcre'
            'pcre2'
            'pixman'
            'proj'
            'readline'
            'sqlite'
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
            'xorg-xorgproto'
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
            case "$i" in
                'xorg-xorgproto')
                    app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/share/pkgconfig"
                    ;;
                *)
                    app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/lib/pkgconfig"
                    ;;
            esac
        done
        koopa_assert_is_dir "${app_pc_path_arr[@]}"
        pc_path_arr=()
        pc_path_arr+=("${app_pc_path_arr[@]}")
        if [[ "${bool['system']}" -eq 1 ]]
        then
            local -a sys_pc_path_arr
            readarray -t sys_pc_path_arr <<< "$( \
                "${app['pkg_config']}" --variable 'pc_path' 'pkg-config' \
            )"
            pc_path_arr+=("${sys_pc_path_arr[@]}")
        fi
        conf_dict['pkg_config_path']="$(printf '%s:' "${pc_path_arr[@]}")"
        lines+=(
            "EDITOR=${app['vim']}"
            "LN_S=${app['ln']} -s"
            "MAKE=${app['make']}"
            "PAGER=${app['less']}"
            "PKG_CONFIG_PATH=${conf_dict['pkg_config_path']}"
            "R_BROWSER=${app['open']}"
            "R_BZIPCMD=${app['bzip2']}"
            "R_GZIPCMD=${app['gzip']}"
            "R_PDFVIEWER=${app['open']}"
            "R_PRINTCMD=${app['lpr']}"
            "R_STRIP_SHARED_LIB=${app['strip']} -x"
            "R_STRIP_STATIC_LIB=${app['strip']} -S"
            "R_TEXI2DVICMD=${app['texi2dvi']}"
            "R_UNZIPCMD=${app['unzip']}"
            "R_ZIPCMD=${app['zip']}"
            "SED=${app['sed']}"
            "TAR=${app['tar']}"
        )
    fi
    if koopa_is_macos
    then
        lines+=('R_MAX_NUM_DLLS=153')
    fi
    lines+=('R_DATATABLE_NUM_PROCS_PERCENT=100')
    lines+=('RCMDCHECK_ERROR_ON=error')
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
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        lines+=(
            "UDUNITS2_INCLUDE=${dict['udunits2']}/include"
            "UDUNITS2_LIBS=${dict['udunits2']}/lib"
        )
    fi
    lines+=("VROOM_CONNECTION_SIZE=524288")
    if koopa_is_fedora_like
    then
        dict['oracle_ver']="$( \
            koopa_app_json_version 'oracle-instant-client' \
        )"
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
    dict['file']="${dict['r_prefix']}/etc/Renviron.site"
    if [[ -L "${dict['file']}" ]]
    then
        dict['realfile']="$(koopa_realpath "${dict['file']}")"
        if [[ "${dict['realfile']}" == '/etc/R/Renviron.site' ]]
        then
            dict['file']="${dict['realfile']}"
        fi
    fi
    koopa_alert_info "Modifying '${dict['file']}'."
    dict['string']="$(koopa_print "${lines[@]}" | "${app['sort']}")"
    if [[ "${bool['system']}" -eq 1 ]]
    then
        koopa_rm --sudo "${dict['file']}"
        koopa_sudo_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
    else
        koopa_rm "${dict['file']}"
        koopa_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
    fi
    return 0
}

koopa_r_configure_java() {
    local -A app bool conf_dict dict
    local -a java_args r_cmd
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    bool['use_apps']=1
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    if [[ "${bool['system']}" -eq 1 ]] && koopa_is_linux
    then
        bool['use_apps']=0
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        dict['java_home']="$(koopa_app_prefix 'temurin')"
    else
        if koopa_is_linux
        then
            dict['java_home']='/usr/lib/jvm/default-java'
        elif koopa_is_macos
        then
            dict['java_home']="$(/usr/libexec/java_home)"
        fi
    fi
    koopa_assert_is_dir "${dict['java_home']}"
    app['jar']="${dict['java_home']}/bin/jar"
    app['java']="${dict['java_home']}/bin/java"
    app['javac']="${dict['java_home']}/bin/javac"
    koopa_assert_is_executable "${app[@]}"
    koopa_alert_info "Using Java SDK at '${dict['java_home']}'."
    conf_dict['java_home']="${dict['java_home']}"
    conf_dict['jar']="${app['jar']}"
    conf_dict['java']="${app['java']}"
    conf_dict['javac']="${app['javac']}"
    conf_dict['javah']=''
    java_args=(
        "JAR=${conf_dict['jar']}"
        "JAVA=${conf_dict['java']}"
        "JAVAC=${conf_dict['javac']}"
        "JAVAH=${conf_dict['javah']}"
        "JAVA_HOME=${conf_dict['java_home']}"
    )
    if [[ "${bool['system']}" -eq 1 ]]
    then
        r_cmd=('koopa_sudo' "${app['r']}")
    else
        r_cmd=("${app['r']}")
    fi
    koopa_assert_is_executable "${app[@]}"
    "${r_cmd[@]}" --vanilla CMD javareconf "${java_args[@]}"
    return 0
}

koopa_r_configure_ldpaths() {
    local -A app bool dict ld_lib_app_arr
    local -a keys ld_lib_arr lines
    local key
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    bool['use_apps']=1
    bool['use_local']=0
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    if [[ "${bool['system']}" -eq 1 ]] && koopa_is_linux
    then
        bool['use_apps']=0
    fi
    dict['arch']="$(koopa_arch)"
    if koopa_is_macos
    then
        case "${dict['arch']}" in
            'aarch64')
                dict['arch']='arm64'
                ;;
        esac
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        dict['java_home']="$(koopa_app_prefix 'temurin')"
    else
        if koopa_is_linux
        then
            dict['java_home']='/usr/lib/jvm/default-java'
        elif koopa_is_macos
        then
            dict['java_home']="$(/usr/libexec/java_home)"
        fi
    fi
    koopa_assert_is_dir "${dict['java_home']}"
    lines=()
    lines+=(": \${JAVA_HOME=${dict['java_home']}}")
    if koopa_is_macos
    then
        lines+=(": \${R_JAVA_LD_LIBRARY_PATH=\${JAVA_HOME}/\
libexec/Contents/Home/lib/server}")
    else
        lines+=(": \${R_JAVA_LD_LIBRARY_PATH=\${JAVA_HOME}/\
libexec/lib/server}")
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        keys=(
            'bzip2'
            'cairo'
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
            'libffi'
            'libgit2'
            'libiconv'
            'libjpeg-turbo'
            'libpng'
            'libssh2'
            'libtiff'
            'libxml2'
            'openssl3'
            'pcre'
            'pcre2'
            'pixman'
            'proj'
            'readline'
            'sqlite'
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
            'xz'
            'zlib'
            'zstd'
        )
        if koopa_is_macos || [[ "${bool['system']}" -eq 0 ]]
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
    fi
    ld_lib_arr=()
    ld_lib_arr+=("\${R_HOME}/lib")
    if [[ "${bool['use_local']}" -eq 1 ]] && [[ -d '/usr/local/lib' ]]
    then
        ld_lib_arr+=('/usr/local/lib')
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        ld_lib_arr+=("${ld_lib_app_arr[@]}")
    fi
    if koopa_is_linux
    then
        dict['sys_libdir']="/usr/lib/${dict['arch']}-linux-gnu"
        koopa_assert_is_dir "${dict['sys_libdir']}" '/usr/lib' '/lib'
        ld_lib_arr+=("${dict['sys_libdir']}" '/usr/lib' '/lib')
    fi
    ld_lib_arr+=("\${R_JAVA_LD_LIBRARY_PATH}")
    dict['library_path']="$(printf '%s:' "${ld_lib_arr[@]}")"
    lines+=(
        "R_LD_LIBRARY_PATH=\"${dict['library_path']}\""
    )
    if koopa_is_linux
    then
        lines+=(
            "LD_LIBRARY_PATH=\"\${R_LD_LIBRARY_PATH}\""
            'export LD_LIBRARY_PATH'
        )
    elif koopa_is_macos
    then
        lines+=(
            "DYLD_FALLBACK_LIBRARY_PATH=\"\${R_LD_LIBRARY_PATH}\""
            'export DYLD_FALLBACK_LIBRARY_PATH'
        )
    fi
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    koopa_assert_is_dir "${dict['r_prefix']}"
    dict['file']="${dict['r_prefix']}/etc/ldpaths"
    dict['file_bak']="${dict['file']}.bak"
    koopa_assert_is_file "${dict['file']}"
    dict['string']="$(koopa_print "${lines[@]}")"
    koopa_alert_info "Modifying '${dict['file']}'."
    if [[ "${bool['system']}" -eq 1 ]]
    then
        if [[ ! -f "${dict['file_bak']}" ]]
        then
            koopa_cp --sudo "${dict['file']}" "${dict['file_bak']}"
        fi
        koopa_rm --sudo "${dict['file']}"
        koopa_sudo_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
    else
        if [[ ! -f "${dict['file_bak']}" ]]
        then
            koopa_cp "${dict['file']}" "${dict['file_bak']}"
        fi
        koopa_rm "${dict['file']}"
        koopa_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
    fi
    return 0
}

koopa_r_configure_makevars() {
    local -A app app_pc_path_arr bool conf_dict dict
    local -a cppflags keys ldflags lines pkg_config
    local i key
    koopa_assert_has_args_eq "$#" 1
    lines=()
    app['r']="${1:?}"
    app['sort']="$(koopa_locate_sort --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    bool['use_apps']=1
    bool['use_openmp']=0
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    if [[ "${bool['system']}" -eq 1 ]]
    then
        if koopa_is_linux
        then
            bool['use_apps']=0
        elif koopa_is_macos
        then
            bool['use_openmp']=1
        fi
    fi
    if koopa_is_macos && [[ "${bool['use_openmp']}" -eq 1 ]]
    then
        koopa_assert_is_file '/usr/local/include/omp.h'
        conf_dict['shlib_openmp_cflags']='-Xclang -fopenmp'
        lines+=("SHLIB_OPENMP_CFLAGS = ${conf_dict['shlib_openmp_cflags']}")
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        app['ar']="$(koopa_locate_ar --only-system)"
        app['awk']="$(koopa_locate_awk)"
        app['bash']="$(koopa_locate_bash)"
        app['cc']="$(koopa_locate_cc --only-system)"
        app['cxx']="$(koopa_locate_cxx --only-system)"
        app['echo']="$(koopa_locate_echo)"
        if koopa_is_macos
        then
            app['gfortran']='/opt/gfortran/bin/gfortran'
        else
            app['gfortran']="$(koopa_locate_gfortran --only-system)"
        fi
        app['make']="$(koopa_locate_make)"
        app['pkg_config']="$(koopa_locate_pkg_config)"
        app['ranlib']="$(koopa_locate_ranlib --only-system)"
        app['sed']="$(koopa_locate_sed)"
        app['strip']="$(koopa_locate_strip)"
        app['tar']="$(koopa_locate_tar)"
        app['yacc']="$(koopa_locate_yacc)"
        koopa_assert_is_executable "${app[@]}"
        dict['bzip2']="$(koopa_app_prefix 'bzip2')"
        dict['gettext']="$(koopa_app_prefix 'gettext')"
        dict['hdf5']="$(koopa_app_prefix 'hdf5')"
        dict['libjpeg']="$(koopa_app_prefix 'libjpeg-turbo')"
        dict['libpng']="$(koopa_app_prefix 'libpng')"
        dict['openssl3']="$(koopa_app_prefix 'openssl3')"
        koopa_add_to_pkg_config_path \
            "${dict['libjpeg']}/lib/pkgconfig" \
            "${dict['libpng']}/lib/pkgconfig"
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        if koopa_is_linux
        then
            keys=(
                'cairo'
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
                'libffi'
                'libgit2'
                'libjpeg-turbo'
                'libpng'
                'libssh2'
                'libtiff'
                'libxml2'
                'openssl3'
                'pcre'
                'pcre2'
                'pixman'
                'proj'
                'readline'
                'sqlite'
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
                'xorg-xorgproto'
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
                case "$i" in
                    'xorg-xorgproto')
                        app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/\
share/pkgconfig"
                        ;;
                    *)
                        app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/\
lib/pkgconfig"
                        ;;
                esac
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
            "-I${dict['openssl3']}/include"
        )
        ldflags+=(
            "-L${dict['bzip2']}/lib"
            "-L${dict['hdf5']}/lib"
            "-L${dict['libjpeg']}/lib"
            "-L${dict['libpng']}/lib"
            "-L${dict['openssl3']}/lib"
        )
        if koopa_is_macos
        then
            dict['clt_maj_ver']="$(koopa_macos_xcode_clt_major_version)"
            cppflags+=("-I${dict['gettext']}/include")
            ldflags+=("-L${dict['gettext']}/lib")
            if [[ "${dict['clt_maj_ver']}" -ge 15 ]]
            then
                ldflags+=('-Wl,-ld_classic')
            fi
            if [[ "${bool['use_openmp']}" -eq 1 ]]
            then
                ldflags+=('-lomp')
            fi
        fi
        conf_dict['ar']="${app['ar']}"
        conf_dict['awk']="${app['awk']}"
        conf_dict['cc']="${app['cc']}"
        conf_dict['cflags']="-Wall -g -O2 \$(LTO)"
        conf_dict['cppflags']="${cppflags[*]}"
        conf_dict['cxx']="${app['cxx']} -std=gnu++14"
        conf_dict['echo']="${app['echo']}"
        conf_dict['f77']="${app['gfortran']}"
        conf_dict['fc']="${app['gfortran']}"
        conf_dict['fflags']="-Wall -g -O2 \$(LTO_FC)"
        conf_dict['flibs']="$(koopa_r_gfortran_libs)"
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
        if [[ "${bool['system']}" -eq 1 ]]
        then
            conf_dict['op']='='
        else
            conf_dict['op']='+='
        fi
        lines+=(
            "AR = ${conf_dict['ar']}"
            "AWK = ${conf_dict['awk']}"
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
    fi
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['file']="${dict['r_prefix']}/etc/Makevars.site"
    if koopa_is_linux && \
        [[ "${bool['system']}" -eq 1 ]] && \
        [[ -f "${dict['file']}" ]]
    then
        koopa_alert_info "Deleting '${dict['file']}'."
        koopa_rm --sudo "${dict['file']}"
        return 0
    fi
    koopa_is_array_empty "${lines[@]}" && return 0
    dict['string']="$(koopa_print "${lines[@]}" | "${app['sort']}")"
    koopa_alert_info "Modifying '${dict['file']}'."
    if [[ "${bool['system']}" -eq 1 ]]
    then
        koopa_rm --sudo "${dict['file']}"
        koopa_sudo_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
    else
        koopa_rm "${dict['file']}"
        koopa_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
    fi
    unset -v PKG_CONFIG_PATH
    return 0
}

koopa_r_copy_files_into_etc() {
    local -A app bool dict
    local -a files
    local file
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['r_etc_source']="$(koopa_koopa_prefix)/etc/R"
    dict['r_etc_target']="${dict['r_prefix']}/etc"
    koopa_assert_is_dir \
        "${dict['r_etc_source']}" \
        "${dict['r_etc_target']}" \
        "${dict['r_prefix']}"
    files=('Rprofile.site' 'repositories')
    for file in "${files[@]}"
    do
        local -A dict2
        dict2['source']="${dict['r_etc_source']}/${file}"
        dict2['target']="${dict['r_etc_target']}/${file}"
        koopa_assert_is_file "${dict2['source']}"
        if [[ -L "${dict2['target']}" ]]
        then
            dict2['realtarget']="$(koopa_realpath "${dict2['target']}")"
            if [[ "${dict2['realtarget']}" == "/etc/R/${file}" ]]
            then
                dict2['target']="${dict2['realtarget']}"
            fi
        fi
        koopa_alert "Modifying '${dict2['target']}'."
        if [[ "${bool['system']}" -eq 1 ]]
        then
            koopa_cp --sudo "${dict2['source']}" "${dict2['target']}"
        else
            koopa_cp "${dict2['source']}" "${dict2['target']}"
        fi
    done
    return 0
}

koopa_r_gfortran_libs() {
    local -A app dict
    local -a flibs libs libs2
    local lib
    koopa_assert_has_no_args "$#"
    dict['arch']="$(koopa_arch)"
    if koopa_is_linux
    then
        app['gfortran']="$(koopa_locate_gfortran --only-system)"
        koopa_assert_is_executable "${app[@]}"
    elif koopa_is_macos
    then
        app['dirname']="$(koopa_locate_dirname --allow-system)"
        app['sort']="$(koopa_locate_sort --allow-system)"
        app['xargs']="$(koopa_locate_xargs --allow-system)"
        koopa_assert_is_executable "${app[@]}"
        case "${dict['arch']}" in
            'arm64')
                dict['arch']='aarch64'
                ;;
        esac
        dict['lib_prefix']='/opt/gfortran/lib'
        koopa_assert_is_dir "${dict['lib_prefix']}"
        readarray -t libs <<< "$( \
            koopa_find \
                --pattern='libgfortran.a' \
                --prefix="${dict['lib_prefix']}" \
                --type='f' \
            | "${app['xargs']}" -I '{}' "${app['dirname']}" '{}' \
            | "${app['sort']}" --unique \
        )"
        koopa_assert_is_array_non_empty "${libs[@]:-}"
        for lib in "${libs[@]}"
        do
            case "$lib" in
                */"${dict['arch']}-"*)
                    libs2+=("$lib")
                    ;;
            esac
        done
        koopa_assert_is_array_non_empty "${libs2[@]:-}"
        libs=("${libs2[@]}")
        libs+=("${dict['lib_prefix']}")
        for lib in "${libs[@]}"
        do
            flibs+=("-L${lib}")
        done
    fi
    flibs+=('-lgfortran')
    if koopa_is_linux
    then
        flibs+=('-lm')
    fi
    case "${dict['arch']}" in
        'x86_64')
            flibs+=('-lquadmath')
            ;;
    esac
    koopa_print "${flibs[*]}"
    return 0
}

koopa_r_install_packages_in_site_library() {
    local -A app dict
    koopa_assert_has_args_ge "$#" 2
    app['r']="${1:?}"
    app['rscript']="${app['r']}script"
    koopa_assert_is_executable "${app[@]}"
    shift 1
    dict['script']="$(koopa_koopa_prefix)/lang/r/\
install-packages-in-site-library.R"
    koopa_assert_is_file "${dict['script']}"
    "${app['rscript']}" "${dict['script']}" "$@"
    return 0
}

koopa_r_koopa() {
    local -A app dict
    local -a code pos rscript_args
    koopa_assert_has_args "$#"
    app['rscript']="$(koopa_locate_rscript)"
    koopa_assert_is_executable "${app[@]}"
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
    dict['fun']="${1:?}"
    shift 1
    dict['header_file']="$(koopa_koopa_prefix)/lang/r/include/header.R"
    koopa_assert_is_file "${dict['header_file']}"
    code=("source('${dict['header_file']}');")
    if [[ "${dict['fun']}" != 'header' ]]
    then
        code+=("koopa::${dict['fun']}();")
    fi
    pos=("$@")
    "${app['rscript']}" "${rscript_args[@]}" -e "${code[*]}" "${pos[@]@Q}"
    return 0
}

koopa_r_library_prefix() {
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    app['rscript']="${app['r']}script"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$( \
        "${app['rscript']}" -e 'cat(normalizePath(.libPaths()[[1L]]))' \
    )"
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_print "${dict['prefix']}"
    return 0
}

koopa_r_migrate_non_base_packages() {
    local -A app
    local -a pkgs
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    readarray -t pkgs <<< "$( \
        koopa_r_system_packages_non_base "${app['r']}"
    )"
    koopa_is_array_non_empty "${pkgs[@]:-}" || return 0
    koopa_alert_info 'Migrating non-base packages to site library.'
    koopa_dl 'Packages' "$(koopa_to_string "${pkgs[@]}")"
    koopa_r_install_packages_in_site_library "${app['r']}" "${pkgs[@]}"
    koopa_r_remove_packages_in_system_library "${app['r']}" "${pkgs[@]}"
    return 0
}

koopa_r_package_version() {
    local -A app
    local str vec
    koopa_assert_has_args "$#"
    app['rscript']="$(koopa_locate_rscript)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    app['rscript']="${app['r']}script"
    koopa_assert_is_executable "${app[@]}"
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

koopa_r_remove_packages_in_system_library() {
    local -A app bool dict
    local -a rscript_cmd
    koopa_assert_has_args_ge "$#" 2
    app['r']="${1:?}"
    app['rscript']="${app['r']}script"
    koopa_assert_is_executable "${app[@]}"
    shift 1
    bool['system']=0
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    dict['script']="$(koopa_koopa_prefix)/lang/r/\
remove-packages-in-system-library.R"
    koopa_assert_is_file "${dict['script']}"
    rscript_cmd=()
    if [[ "${bool['system']}" -eq 1 ]]
    then
        rscript_cmd+=('koopa_sudo')
    fi
    rscript_cmd+=("${app['rscript']}")
    koopa_assert_is_executable "${app[@]}"
    "${rscript_cmd[@]}" "${dict['script']}" "$@"
    return 0
}

koopa_r_shiny_run_app() {
    local -A app dict
    app['r']="$(koopa_locate_r)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${1:-}"
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
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    app['rscript']="${app['r']}script"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$( \
        "${app['rscript']}" \
            --vanilla \
            -e 'cat(normalizePath(tail(.libPaths(), n = 1L)))' \
    )"
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_print "${dict['prefix']}"
    return 0
}

koopa_r_system_packages_non_base() {
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    app['rscript']="${app['r']}script"
    koopa_assert_is_executable "${app[@]}"
    dict['script']="$(koopa_koopa_prefix)/lang/r/system-packages-non-base.R"
    koopa_assert_is_file "${dict['script']}"
    dict['string']="$("${app['rscript']}" --vanilla "${dict['script']}")"
    [[ -n "${dict['string']}" ]] || return 0
    koopa_print "${dict['string']}"
    return 0
}

koopa_r_version() {
    local -A app
    local str
    koopa_assert_has_args_le "$#" 1
    app['head']="$(koopa_locate_head --allow-system)"
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    koopa_assert_is_executable "${app[@]}"
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

koopa_random_string() {
    local -A app dict
    app['head']="$(koopa_locate_head --allow-system)"
    app['md5sum']="$(koopa_locate_md5sum --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['length']=10
    dict['seed']="${RANDOM:?}"
    while (("$#"))
    do
        case "$1" in
            '--length='*)
                dict['length']="${1#*=}"
                shift 1
                ;;
            '--length')
                dict['length']="${2:?}"
                shift 2
                ;;
            '--seed='*)
                dict['seed']="${1#*=}"
                shift 1
                ;;
            '--seed')
                dict['seed']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${dict['length']}" -le 32 ]] || return 1
    dict['str']="$( \
        koopa_print "${dict['seed']}" \
        | "${app['md5sum']}" \
        | "${app['head']}" -c "${dict['length']}" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_read_prompt_yn() {
    local -A dict
    koopa_assert_has_args_eq "$#" 2
    dict['input']="${2:?}"
    dict['no']="$(koopa_print_red 'no')"
    dict['no_default']="$(koopa_print_red_bold 'NO')"
    dict['prompt']="${1:?}"
    dict['yes']="$(koopa_print_green 'yes')"
    dict['yes_default']="$(koopa_print_green_bold 'YES')"
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
    local -A dict
    local -a read_args
    koopa_assert_has_args_eq "$#" 2
    dict['prompt']="$(koopa_read_prompt_yn "$@")"
    dict['default']="$(koopa_int_to_yn "${2:?}")"
    read_args=(
        '-e'
        '-i' "${dict['default']}"
        '-p' "${dict['prompt']}"
        '-r'
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
    local -A dict
    local -a read_args
    koopa_assert_has_args_eq "$#" 2
    dict['default']="${2:?}"
    dict['prompt']="${1:?} [${dict['default']}]: "
    read_args=(
        '-e'
        '-i' "${dict['default']}"
        '-p' "${dict['prompt']}"
        '-r'
    )
    read "${read_args[@]}" "dict[choice]"
    [[ -z "${dict['choice']}" ]] && dict['choice']="${dict['default']}"
    koopa_print "${dict['choice']}"
    return 0
}

koopa_realpath() {
    _koopa_realpath "$@"
}

koopa_reinstall_all_revdeps() {
    local -a flags pos
    local app_name
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
        local -a install_args revdeps
        install_args=()
        if koopa_is_array_non_empty "${flags[@]}"
        then
            install_args+=("${flags[@]}")
        fi
        install_args+=("$app_name")
        readarray -t revdeps <<< "$(koopa_app_reverse_dependencies "$app_name")"
        if koopa_is_array_non_empty "${revdeps[@]}"
        then
            install_args+=("${revdeps[@]}")
            koopa_dl \
                "${app_name} reverse dependencies" \
                "$(koopa_to_string "${revdeps[@]}")"
        else
            koopa_alert_note "'${app_name}' has no reverse dependencies."
        fi
        koopa_cli_reinstall "${install_args[@]}"
    done
    return 0
}

koopa_reinstall_only_revdeps() {
    local -a flags pos
    local app_name
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
        local -a install_args revdeps
        install_args=()
        if koopa_is_array_non_empty "${flags[@]}"
        then
            install_args+=("${flags[@]}")
        fi
        readarray -t revdeps <<< "$(koopa_app_reverse_dependencies "$app_name")"
        if koopa_assert_is_array_non_empty "${revdeps[@]}"
        then
            install_args+=("${revdeps[@]}")
            koopa_dl \
                "${app_name} reverse dependencies" \
                "$(koopa_to_string "${revdeps[@]}")"
        else
            koopa_stop "'${app_name}' has no reverse dependencies."
        fi
        koopa_cli_reinstall "${install_args[@]}"
    done
    return 0
}

koopa_relink() {
    local -A dict
    local -a ln pos rm sudo
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
    koopa_assert_has_args_eq "$#" 2
    ln=('koopa_ln')
    rm=('koopa_rm')
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
    local -A app
    koopa_assert_has_no_args "$#"
    app['shell']="$(koopa_shell_name)"
    koopa_assert_is_executable "${app[@]}"
    exec "${app['shell']}" -il
    return 0
}

koopa_remove_from_path_string() {
    _koopa_remove_from_path_string "$@"
}

koopa_rename_camel_case() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliCamelCase' "$@"
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

koopa_rename_kebab_case() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliKebabCase' "$@"
}

koopa_rename_lowercase() {
    local -A app dict
    local -a pos
    koopa_assert_has_args "$#"
    app['rename']="$(koopa_locate_rename)"
    app['xargs']="$(koopa_locate_xargs)"
    koopa_assert_is_executable "${app[@]}"
    dict['pattern']='y/A-Z/a-z/'
    dict['recursive']=0
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

koopa_rename_snake_case() {
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliSnakeCase' "$@"
}

koopa_reset_permissions() {
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['chmod']="$(koopa_locate_chmod)"
    app['xargs']="$(koopa_locate_xargs)"
    koopa_assert_is_executable "${app[@]}"
    dict['group']="$(koopa_group_name)"
    dict['prefix']="${1:?}"
    dict['user']="$(koopa_user_name)"
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
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['rg']="$(koopa_locate_rg)"
    koopa_assert_is_executable "${app[@]}"
    dict['pattern']="${1:?}"
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
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['rg']="$(koopa_locate_rg)"
    app['sort']="$(koopa_locate_sort)"
    koopa_assert_is_executable "${app[@]}"
    dict['pattern']="${1:?}"
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
    local -A app dict
    local -a pos rm rm_args
    app['rm']="$(koopa_locate_rm --allow-system)"
    dict['sudo']=0
    dict['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--quiet' | \
            '-q')
                dict['verbose']=0
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                dict['verbose']=1
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
    rm_args=('-f' '-r')
    [[ "${dict['verbose']}" -eq 1 ]] && rm_args+=('-v')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        rm+=('koopa_sudo' "${app['rm']}")
    else
        rm=("${app['rm']}")
    fi
    koopa_assert_is_executable "${app[@]}"
    "${rm[@]}" "${rm_args[@]}" "$@"
    return 0
}

koopa_rnaeditingindexer() {
    local -A app dict
    local -a run_args
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    dict['bam_suffix']='.Aligned.sortedByCoord.out.bam'
    dict['docker_image']='public.ecr.aws/acidgenomics/rnaeditingindexer'
    dict['example']=0
    dict['genome']='hg38'
    dict['local_bam_dir']='bam'
    dict['local_output_dir']='rnaedit'
    dict['mnt_bam_dir']='/mnt/bam'
    dict['mnt_output_dir']='/mnt/output'
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
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['ronn']="$(koopa_locate_ronn)"
    koopa_assert_is_executable "${app[@]}"
    dict['man_prefix']="$(koopa_man_prefix)"
    (
        koopa_cd "${dict['man_prefix']}/man1-ronn"
        "${app['ronn']}" --roff ./*'.ronn'
        koopa_mv --target-directory="${dict['man_prefix']}/man1" ./*'.1'
    )
    return 0
}

koopa_rsem_index() {
    local -A app dict
    local -a index_args
    app['rsem_prepare_reference']="$(koopa_locate_rsem_prepare_reference)"
    koopa_assert_is_executable "${app[@]}"
    dict['genome_fasta_file']=''
    dict['gtf_file']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=10
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    dict['tmp_dir']="$(koopa_tmp_dir)"
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
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Generating RSEM index at '${dict['output_dir']}'."
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
        'rsem'
    )
    koopa_dl 'Index args' "${index_args[*]}"
    (
        koopa_cd "${dict['output_dir']}"
        "${app['rsem_prepare_reference']}" "${index_args[@]}"
    )
    koopa_rm "${dict['tmp_dir']}"
    koopa_alert_success "RSEM index created at '${dict['output_dir']}'."
    return 0
}

koopa_rsync_ignore() {
    local -A dict
    local -a rsync_args
    koopa_assert_has_args "$#"
    dict['ignore_local']='.gitignore'
    dict['ignore_global']="${HOME}/.gitignore"
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
    local -A app dict
    local -a rsync_args
    koopa_assert_has_args "$#"
    app['rsync']="$(koopa_locate_rsync)"
    koopa_assert_is_executable "${app[@]}"
    dict['source_dir']=''
    dict['target_dir']=''
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

koopa_ruby_gem_user_install_prefix() {
    local -A app dict
    app['ruby']="$(koopa_locate_ruby)"
    koopa_assert_is_executable "${app[@]}"
    dict['str']="$("${app['ruby']}" -r rubygems -e 'puts Gem.user_dir')"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

koopa_run_if_installed() {
    local arg
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
    local -A app dict
    local -a quant_args
    koopa_assert_has_args "$#"
    app['head']="$(koopa_locate_head --allow-system)"
    app['jq']="$(koopa_locate_jq --allow-system)"
    app['salmon']="$(koopa_locate_salmon)"
    koopa_assert_is_executable "${app[@]}"
    dict['fastq_r1_file']=''
    dict['fastq_r2_file']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['n']='400000'
    dict['threads']="$(koopa_cpu_count)"
    dict['tmp_dir']="$(koopa_tmp_dir)"
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
    local -A app dict
    local -a index_args
    koopa_assert_has_args "$#"
    app['salmon']="$(koopa_locate_salmon)"
    koopa_assert_is_executable "${app[@]}"
    dict['decoys']=1
    dict['fasta_pattern']='\.(fa|fasta|fna)'
    dict['gencode']=0
    dict['genome_fasta_file']=''
    dict['kmer_length']=31
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    dict['transcriptome_fasta_file']=''
    dict['type']='puff'
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

koopa_salmon_quant_bam_per_sample() {
    local -A app dict
    local -a quant_args
    koopa_assert_has_args "$#"
    app['salmon']="$(koopa_locate_salmon)"
    koopa_assert_is_executable "${app[@]}"
    dict['bam_file']=''
    dict['bootstraps']=30
    dict['lib_type']='A'
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    dict['transcriptome_fasta_file']=''
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            '--bam-file='*)
                dict['bam_file']="${1#*=}"
                shift 1
                ;;
            '--bam-file')
                dict['bam_file']="${2:?}"
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
        '--bam-file' "${dict['bam_file']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "salmon quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file \
        "${dict['bam_file']}" \
        "${dict['transcriptome_fasta_file']}"
    dict['transcriptome_fasta_file']="$( \
        koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    dict['id']="$(koopa_basename_sans_ext "${dict['bam_file']}")"
    dict['bam_file']="$(koopa_realpath "${dict['bam_file']}")"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    quant_args+=(
        "--alignments=${dict['bam_file']}"
        "--libType=${dict['lib_type']}"
        '--no-version-check'
        "--numBootstraps=${dict['bootstraps']}"
        "--output=${dict['output_dir']}"
        "--targets=${dict['transcriptome_fasta_file']}"
        "--threads=${dict['threads']}"
    )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['salmon']}" quant "${quant_args[@]}"
    return 0
}

koopa_salmon_quant_bam() {
    local -A dict
    local -a bam_files
    local bam_file
    koopa_assert_has_args "$#"
    dict['bam_dir']=''
    dict['lib_type']='A'
    dict['output_dir']=''
    dict['transcriptome_fasta_file']=''
    while (("$#"))
    do
        case "$1" in
            '--bam-dir='*)
                dict['bam_dir']="${1#*=}"
                shift 1
                ;;
            '--bam-dir')
                dict['bam_dir']="${2:?}"
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
        '--bam-dir' "${dict['bam_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    koopa_assert_is_dir "${dict['bam_dir']}"
    koopa_assert_is_file "${dict['transcriptome_fasta_file']}"
    dict['bam_dir']="$(koopa_realpath "${dict['bam_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    dict['transcriptome_fasta_file']="$( \
        koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    koopa_h1 'Running salmon quant.'
    koopa_dl \
        'Transcriptome FASTA' "${dict['transcriptome_fasta_file']}" \
        'BAM dir' "${dict['bam_dir']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t bam_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*.bam" \
            --prefix="${dict['bam_dir']}" \
            --sort \
    )"
    if koopa_is_array_empty "${bam_files[@]:-}"
    then
        koopa_stop "No BAM files detected in '${dict['bam_dir']}'."
    fi
    koopa_assert_is_file "${bam_files[@]}"
    koopa_alert_info "$(koopa_ngettext \
        --num="${#bam_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for bam_file in "${bam_files[@]}"
    do
        koopa_salmon_quant_bam_per_sample \
            --bam-file="$bam_file" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict['output_dir']}" \
            --transcriptome-fasta-file="${dict['transcriptome_fasta_file']}"
    done
    koopa_alert_success 'salmon quant was successful.'
    return 0
}

koopa_salmon_quant_paired_end_per_sample() {
    local -A app dict
    local -a quant_args
    koopa_assert_has_args "$#"
    app['salmon']="$(koopa_locate_salmon)"
    koopa_assert_is_executable "${app[@]}"
    dict['bootstraps']=30
    dict['fastq_r1_file']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_file']=''
    dict['fastq_r2_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
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
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="${dict['fastq_r1_bn']/${dict['fastq_r1_tail']}/}"
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
    dict['fastq_r1_file']="$(koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r2_file']="$(koopa_realpath "${dict['fastq_r2_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    quant_args+=(
        '--gcBias'
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
    local -A dict
    local -a fastq_r1_files
    local fastq_r1_file
    koopa_assert_has_args "$#"
    dict['fastq_dir']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mode']='paired-end'
    dict['output_dir']=''
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
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    koopa_assert_is_file "${fastq_r1_files[@]}"
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
    local -A app dict
    local -a quant_args
    koopa_assert_has_args "$#"
    app['salmon']="$(koopa_locate_salmon)"
    koopa_assert_is_executable "${app[@]}"
    dict['bootstraps']=30
    dict['fastq_file']=''
    dict['fastq_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
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
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
    dict['fastq_bn']="${dict['fastq_bn']/${dict['tail']}/}"
    dict['id']="${dict['fastq_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
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
    local -A dict
    local -a fastq_files
    local fastq_file
    koopa_assert_has_args "$#"
    dict['fastq_dir']=''
    dict['fastq_tail']=''
    dict['index_dir']=''
    dict['lib_type']='A'
    dict['mode']='single-end'
    dict['output_dir']=''
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
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_tail']}'."
    fi
    koopa_assert_is_file "${fastq_files[@]}"
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
    local -A app dict
    koopa_assert_has_args "$#"
    app['sambamba']="$(koopa_locate_sambamba)"
    koopa_assert_is_executable "${app[@]}"
    dict['filter']=''
    dict['input']=''
    dict['output']=''
    dict['threads']="$(koopa_cpu_count)"
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
    local -A dict
    local -a bam_files
    local bam_file
    koopa_assert_has_args_eq "$#" 1
    dict['pattern']='*.sorted.bam'
    dict['prefix']="${1:?}"
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
        local -A dict2
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
    local -A app dict
    local bam_file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    app['sambamba']="$(koopa_locate_sambamba)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app dict
    koopa_assert_has_args "$#"
    app['sambamba']="$(koopa_locate_sambamba)"
    koopa_assert_is_executable "${app[@]}"
    dict['input']="${1:?}"
    dict['threads']="$(koopa_cpu_count)"
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
    local -A dict
    local -a bam_files
    local bam_file
    koopa_assert_has_args_eq "$#" 1
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
    local -A app
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
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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

koopa_scripts_private_prefix() {
    _koopa_scripts_private_prefix "$@"
}

koopa_shared_apps() {
    local cmd
    koopa_assert_is_installed 'python3'
    cmd="$(koopa_koopa_prefix)/lang/python/shared-apps.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$@"
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

koopa_snake_case() {
    local -a out
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    readarray -t out <<< "$( \
        koopa_gsub \
            --pattern='[^A-Za-z0-9_]' \
            --regex \
            --replacement='_' \
            "$@" \
        | koopa_lowercase \
    )"
    koopa_is_array_non_empty "${out[@]}" || return 1
    koopa_print "${out[@]}"
    return 0
}

koopa_sort_lines() {
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['vim']="$(koopa_locate_vim)"
    koopa_assert_is_executable "${app[@]}"
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

koopa_spacemacs_prefix() {
    _koopa_spacemacs_prefix "$@"
}

koopa_spacevim_prefix() {
    _koopa_spacevim_prefix "$@"
}

koopa_spell() {
    local -A app
    koopa_assert_has_args "$#"
    app['aspell']="$(koopa_locate_aspell)"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    koopa_print "$@" \
        | "${app['aspell']}" pipe \
        | "${app['tail']}" -n '+2'
    return 0
}

koopa_sra_download_accession_list() {
    local -A app dict
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['efetch']="$(koopa_locate_efetch)"
    app['esearch']="$(koopa_locate_esearch)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['acc_file']=''
    dict['srp_id']=''
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
    local -A app dict
    koopa_assert_has_args "$#"
    app['efetch']="$(koopa_locate_efetch)"
    app['esearch']="$(koopa_locate_esearch)"
    koopa_assert_is_executable "${app[@]}"
    dict['run_info_file']=''
    dict['srp_id']=''
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
    local -A app dict
    local -a sra_files
    local sra_file
    app['fasterq_dump']="$(koopa_locate_fasterq_dump)"
    app['gzip']="$(koopa_locate_gzip)"
    app['parallel']="$(koopa_locate_parallel)"
    koopa_assert_is_executable "${app[@]}"
    dict['acc_file']=''
    dict['compress']=1
    dict['fastq_dir']='fastq'
    dict['prefetch_dir']='sra'
    dict['threads']="$(koopa_cpu_count)"
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
    local -A app dict
    local cmd
    app['parallel']="$(koopa_locate_parallel)"
    app['prefetch']="$(koopa_locate_prefetch)"
    koopa_assert_is_executable "${app[@]}"
    dict['acc_file']=''
    dict['jobs']="$(koopa_cpu_count)"
    dict['output_dir']='sra'
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
    local -A app dict
    local -a ssh_args
    app['ssh_keygen']="$(koopa_locate_ssh_keygen --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['hostname']="$(koopa_hostname)"
    dict['key_name']='id_rsa' # or 'id_ed25519'.
    dict['prefix']="${HOME:?}/.ssh"
    dict['user']="$(koopa_user_name)"
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
    local -A app dict
    local keyfile
    app['ssh_keygen']="$(koopa_locate_ssh_keygen --allow-system)"
    app['uniq']="$(koopa_locate_uniq)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${HOME:?}/.ssh"
    dict['stem']='id_'
    for keyfile in "${dict['prefix']}/${dict['stem']}"*
    do
        "${app['ssh_keygen']}" -l -f "$keyfile"
    done | "${app['uniq']}"
    return 0
}

koopa_star_align_paired_end_per_sample() {
    local -A app dict
    local -a align_args
    app['star']="$(koopa_locate_star)"
    koopa_assert_is_executable "${app[@]}"
    dict['aws_profile']=''
    dict['aws_s3_uri']=''
    dict['fastq_r1_file']=''
    dict['fastq_r2_file']=''
    dict['index_dir']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=60
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    align_args=()
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--aws-s3-uri='*)
                dict['aws_s3_uri']="${1#*=}"
                shift 1
                ;;
            '--aws-s3-uri')
                dict['aws_s3_uri']="${2:?}"
                shift 2
                ;;
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
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "STAR 'alignReads' mode requires ${dict['mem_gb_cutoff']} \
GB of RAM."
    fi
    dict['limit_bam_sort_ram']=$(( dict['mem_gb'] * 1000000000 ))
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r2_bn']="$(koopa_basename "${dict['fastq_r2_file']}")"
    koopa_alert "Quantifying '${dict['fastq_r1_bn']}' and \
'${dict['fastq_r2_bn']}' in '${dict['output_dir']}'."
    dict['tmp_fastq_r1_file']="$(koopa_tmp_file)"
    dict['tmp_fastq_r2_file']="$(koopa_tmp_file)"
    koopa_alert "Decompressing '${dict['fastq_r1_file']}' \
to '${dict['tmp_fastq_r1_file']}"
    koopa_decompress "${dict['fastq_r1_file']}" "${dict['tmp_fastq_r1_file']}"
    koopa_alert "Decompressing '${dict['fastq_r2_file']}' \
to '${dict['tmp_fastq_r2_file']}"
    koopa_decompress "${dict['fastq_r2_file']}" "${dict['tmp_fastq_r2_file']}"
    align_args+=(
        '--genomeDir' "${dict['index_dir']}"
        '--limitBAMsortRAM' "${dict['limit_bam_sort_ram']}"
        '--outFileNamePrefix' "${dict['output_dir']}/"
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--quantMode' 'TranscriptomeSAM'
        '--readFilesIn' \
            "${dict['tmp_fastq_r1_file']}" \
            "${dict['tmp_fastq_r2_file']}"
        '--runMode' 'alignReads'
        '--runRNGseed' '0'
        '--runThreadN' "${dict['threads']}"
        '--twopassMode' 'Basic'
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['star']}" "${align_args[@]}"
    koopa_rm \
        "${dict['output_dir']}/_STAR"* \
        "${dict['tmp_fastq_r1_file']}" \
        "${dict['tmp_fastq_r2_file']}"
    if [[ -n "${dict['aws_s3_uri']}" ]]
    then
        app['aws']="$(koopa_locate_aws --allow-system)"
        koopa_assert_is_executable "${app['aws']}"
        koopa_alert "Syncing '${dict['output_dir']}' \
to '${dict['aws_s3_uri']}'."
        "${app['aws']}" s3 sync \
            --profile "${dict['aws_profile']}" \
            "${dict['output_dir']}/" \
            "${dict['aws_s3_uri']}/"
        koopa_rm "${dict['output_dir']}"
        koopa_mkdir "${dict['output_dir']}"
    fi
    return 0
}

koopa_star_align_paired_end() {
    local -A dict
    local -a fastq_r1_files
    local fastq_r1_file
    koopa_assert_has_args "$#"
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['aws_s3_uri']=''
    dict['fastq_dir']=''
    dict['fastq_r1_tail']=''
    dict['fastq_r2_tail']=''
    dict['index_dir']=''
    dict['mode']='paired-end'
    dict['output_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
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
    if koopa_str_detect_fixed \
        --pattern='s3://' \
        --string="${dict['output_dir']}"
    then
        dict['aws_s3_uri']="$( \
            koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="tmp-koopa-$(koopa_random_string)"
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running STAR aligner.'
    koopa_dl \
        'Mode' "${dict['mode']}" \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"

    if [[ -n "${dict['aws_s3_uri']}" ]]
    then
        koopa_dl 'AWS S3 URI' "${dict['aws_s3_uri']}"
    fi
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
        local -A dict2
        dict2['fastq_r1_file']="$fastq_r1_file"
        dict2['fastq_r2_file']="${dict2['fastq_r1_file']/\
${dict['fastq_r1_tail']}/${dict['fastq_r2_tail']}}"
        dict2['sample_id']="$(koopa_basename "${dict2['fastq_r1_file']}")"
        dict2['sample_id']="${dict2['sample_id']/${dict['fastq_r1_tail']}/}"
        dict2['aws_s3_uri']="${dict['aws_s3_uri']}/${dict2['sample_id']}"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        koopa_star_align_paired_end_per_sample \
            --aws-profile="${dict['aws_profile']}" \
            --aws-s3-uri="${dict2['aws_s3_uri']}" \
            --fastq-r1-file="${dict2['fastq_r1_file']}" \
            --fastq-r2-file="${dict2['fastq_r2_file']}" \
            --index-dir="${dict['index_dir']}" \
            --output-dir="${dict2['output_dir']}"
    done
    [[ -n "${dict['aws_s3_uri']}" ]] && koopa_rm "${dict['output_dir']}"
    koopa_alert_success 'STAR alignment was successful.'
    return 0
}

koopa_star_align_single_end_per_sample() {
    local -A app dict
    local -a align_args
    koopa_assert_has_args "$#"
    app['star']="$(koopa_locate_star)"
    koopa_assert_is_executable "${app[@]}"
    dict['fastq_file']=''
    dict['fastq_tail']=''
    dict['index_dir']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=60
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
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
    dict['limit_bam_sort_ram']=$(( dict['mem_gb'] * 1000000000 ))
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
    dict['tmp_fastq_file']="$(koopa_tmp_file)"
    koopa_alert "Decompressing '${dict['fastq_file']}' \
to '${dict['tmp_fastq_file']}"
    koopa_decompress "${dict['fastq_file']}" "${dict['tmp_fastq_file']}"
    align_args+=(
        '--genomeDir' "${dict['index_dir']}"
        '--limitBAMsortRAM' "${dict['limit_bam_sort_ram']}"
        '--outFileNamePrefix' "${dict['output_dir']}/"
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--quantMode' 'TranscriptomeSAM'
        '--readFilesIn' "${dict['tmp_fastq_file']}"
        '--runMode' 'alignReads'
        '--runRNGseed' '0'
        '--runThreadN' "${dict['threads']}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['star']}" "${align_args[@]}"
    koopa_rm \
        "${dict['output_dir']}/_STAR"* \
        "${dict['tmp_fastq_file']}"
    return 0
}

koopa_star_align_single_end() {
    local -A dict
    local -a fastq_files
    local fastq_file 
    koopa_assert_has_args "$#"
    dict['aws_bucket']=''
    dict['aws_profile']="${AWS_PROFILE:-default}"
    dict['fastq_dir']=''
    dict['fastq_tail']=''
    dict['index_dir']=''
    dict['mode']='single-end'
    dict['output_dir']=''
    while (("$#"))
    do
        case "$1" in
            '--aws-bucket='*)
                dict['aws_bucket']="${1#*=}"
                shift 1
                ;;
            '--aws-bucket')
                dict['aws_bucket']="${2:?}"
                shift 2
                ;;
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
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
    if [[ -n "${dict['aws_bucket']}" ]]
    then
        dict['aws_bucket']="$( \
            koopa_strip_trailing_slash "${dict['aws_bucket']}" \
        )"
    fi
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
            --aws-bucket="${dict['aws_bucket']}" \
            --aws-profile="${dict['aws_profile']}" \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict['fastq_tail']}" \
            --index-dir="${dict['index_dir']}" \
            --output-dir="${dict['output_dir']}"
    done
    koopa_alert_success 'STAR alignment was successful.'
    return 0
}

koopa_star_index() {
    local -A app dict
    local -a index_args
    app['star']="$(koopa_locate_star)"
    koopa_assert_is_executable "${app[@]}"
    dict['compress_ext_pattern']="$(koopa_compress_ext_pattern)"
    dict['genome_fasta_file']=''
    dict['gtf_file']=''
    dict['is_tmp_genome_fasta_file']=0
    dict['is_tmp_gtf_file']=0
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=60
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
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
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Generating STAR index at '${dict['output_dir']}'."
    if koopa_str_detect_regex \
        --string="${dict['genome_fasta_file']}" \
        --pattern="${dict['compress_ext_pattern']}"
    then
        dict['is_tmp_genome_fasta_file']=1
        dict['tmp_genome_fasta_file']="$(koopa_tmp_file)"
        koopa_decompress \
            "${dict['genome_fasta_file']}" \
            "${dict['tmp_genome_fasta_file']}"
    else
        dict['tmp_genome_fasta_file']="${dict['genome_fasta_file']}"
    fi
    if koopa_str_detect_regex \
        --string="${dict['gtf_file']}" \
        --pattern="${dict['compress_ext_pattern']}"
    then
        dict['is_tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(koopa_tmp_file)"
        koopa_decompress \
            "${dict['gtf_file']}" \
            "${dict['tmp_gtf_file']}"
    else
        dict['tmp_gtf_file']="${dict['gtf_file']}"
    fi
    if koopa_fasta_has_alt_contigs "${dict['tmp_genome_fasta_file']}"
    then
        koopa_warn "'${dict['genome_fasta_file']}' contains ALT contigs."
    fi
    index_args+=(
        '--genomeDir' "$(koopa_basename "${dict['output_dir']}")"
        '--genomeFastaFiles' "${dict['tmp_genome_fasta_file']}"
        '--runMode' 'genomeGenerate'
        '--runThreadN' "${dict['threads']}"
        '--sjdbGTFfile' "${dict['tmp_gtf_file']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    (
        koopa_cd "$(koopa_dirname "${dict['output_dir']}")"
        koopa_rm "${dict['output_dir']}"
        "${app['star']}" "${index_args[@]}"
        koopa_rm '_STARtmp'
    )
    [[ "${dict['is_tmp_genome_fasta_file']}" -eq 1 ]] && \
        koopa_rm "${dict['tmp_genome_fasta_file']}"
    [[ "${dict['is_tmp_gtf_file']}" -eq 1 ]] && \
        koopa_rm "${dict['tmp_gtf_file']}"
    koopa_alert_success "STAR index created at '${dict['output_dir']}'."
    return 0
}

koopa_stat_access_human() {
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    local -A app dict
    app['stat']="$(koopa_locate_stat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    if koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
        dict['format_string']='%A'
    elif koopa_is_macos
    then
        dict['format_flag']='-f'
        dict['format_string']='%Sp'
    else
        return 1
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}

koopa_stat_access_octal() {
    local -A app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    app['stat']="$(koopa_locate_stat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    if koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
        dict['format_string']='%a'
    elif koopa_is_macos
    then
        dict['format_flag']='-f'
        dict['format_string']='%OLp'
    else
        return 1
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}

koopa_stat_group_id() {
    local -A app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    app['stat']="$(koopa_locate_stat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['format_string']='%g'
    if koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
    elif koopa_is_macos
    then
        dict['format_flag']='-f'
    else
        return 1
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}

koopa_stat_group_name() {
    local -A app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    app['stat']="$(koopa_locate_stat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    if koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
        dict['format_string']='%G'
    elif koopa_is_macos
    then
        dict['format_flag']='-f'
        dict['format_string']='%Sg'
    else
        return 1
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}

koopa_stat_modified() {
    local -A app dict
    local -a pos timestamps
    local timestamp
    koopa_assert_has_args "$#"
    app['date']="$(koopa_locate_date)"
    app['stat']="$(koopa_locate_stat)"
    koopa_assert_is_executable "${app[@]}"
    dict['format']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--format='*)
                dict['format']="${1#*=}"
                shift 1
                ;;
            '--format')
                dict['format']="${2:?}"
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
    koopa_assert_is_set '--format' "${dict['format']}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    readarray -t timestamps <<< "$( \
        "${app['stat']}" --format='%Y' "$@" \
    )"
    for timestamp in "${timestamps[@]}"
    do
        local string
        string="$( \
            "${app['date']}" -d "@${timestamp}" +"${dict['format']}" \
        )"
        [[ -n "$string" ]] || return 1
        koopa_print "$string"
    done
    return 0
}

koopa_stat_user_id() {
    local -A app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    app['stat']="$(koopa_locate_stat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['format_string']='%u'
    if koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
    elif koopa_is_macos
    then
        dict['format_flag']='-f'
    else
        return 1
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}

koopa_stat_user_name() {
    local -A app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    app['stat']="$(koopa_locate_stat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    if koopa_is_gnu "${app['stat']}"
    then
        dict['format_flag']='--format'
        dict['format_string']='%U'
    elif koopa_is_macos
    then
        dict['format_flag']='-f'
        dict['format_string']='%Su'
    else
        return 1
    fi
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}

koopa_status_fail() {
    koopa_status 'FAIL' 'red' "$@" >&2
}

koopa_status_note() {
    koopa_status 'NOTE' 'yellow' "$@"
}

koopa_status_ok() {
    koopa_status 'OK' 'green' "$@"
}

koopa_status() {
    local -A dict
    local string
    koopa_assert_has_args_ge "$#" 3
    dict['label']="$(printf '%10s\n' "${1:?}")"
    dict['color']="$(koopa_ansi_escape "${2:?}")"
    dict['nocolor']="$(koopa_ansi_escape 'nocolor')"
    shift 2
    for string in "$@"
    do
        string="${dict['color']}${dict['label']}${dict['nocolor']} | ${string}"
        koopa_print "$string"
    done
    return 0
}

koopa_stop() {
    koopa_msg 'red-bold' 'red' '!! Error:' "$@" >&2
    exit 1
}

koopa_str_detect_fixed() {
    koopa_str_detect --mode='fixed' "$@"
}

koopa_str_detect_regex() {
    koopa_str_detect --mode='regex' "$@"
}

koopa_str_detect() {
    local -A dict
    local -a grep_args
    koopa_assert_has_args "$#"
    dict['mode']=''
    dict['pattern']=''
    dict['stdin']=1
    dict['string']=''
    dict['sudo']=0
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

koopa_str_unique_by_colon() {
    local -A app
    local str str2
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['tr']="$(koopa_locate_tr --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for str in "$@"
    do
        str2="$( \
            koopa_print "$str" \
                | "${app['tr']}" ':' '\n' \
                | "${app['awk']}" '!x[$0]++' \
                | "${app['tr']}" '\n' ':' \
                | koopa_strip_right --pattern=':' \
        )"
        [[ -n "$str2" ]] || return 1
        koopa_print "$str2"
    done
    return 0
}

koopa_str_unique_by_semicolon() {
    local -A app
    local str str2
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['tr']="$(koopa_locate_tr --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for str in "$@"
    do
        str2="$( \
            koopa_print "$str" \
                | "${app['tr']}" ';' '\n' \
                | "${app['awk']}" '!x[$0]++' \
                | "${app['tr']}" '\n' ';' \
                | koopa_strip_right --pattern=';' \
        )"
        [[ -n "$str2" ]] || return 1
        koopa_print "$str2"
    done
    return 0
}

koopa_str_unique_by_space() {
    local -A app
    local str str2
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['tr']="$(koopa_locate_tr --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for str in "$@"
    do
        str2="$( \
            koopa_print "$str" \
                | "${app['tr']}" ' ' '\n' \
                | "${app['awk']}" '!x[$0]++' \
                | "${app['tr']}" '\n' ' ' \
                | koopa_strip_right --pattern=' ' \
        )"
        [[ -n "$str2" ]] || return 1
        koopa_print "$str2"
    done
    return 0
}

koopa_strip_left() {
    local -A dict
    local -a pos
    local str
    dict['pattern']=''
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
    local -A dict
    local -a pos
    local str
    dict['pattern']=''
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
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    koopa_strip_right --pattern='/' "$@"
    return 0
}

koopa_sub() {
    local -A app bool dict
    local -a out pos
    local str
    app['perl']="$(koopa_locate_perl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['global']=0
    bool['regex']=0
    dict['pattern']=''
    dict['replace']=''
    dict['tail']=''
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
                dict['replace']="${1#*=}"
                shift 1
                ;;
            '--replacement')
                dict['replace']="${2:-}"
                shift 2
                ;;
            '--fixed')
                bool['regex']=0
                shift 1
                ;;
            '--global')
                bool['global']=1
                shift 1
                ;;
            '--regex')
                bool['regex']=1
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
    koopa_assert_is_set '--pattern' "${dict['pattern']}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    [[ "${bool['global']}" -eq 1 ]] && dict['tail']='g'
    if [[ "${bool['regex']}" -eq 1 ]]
    then
        dict['pattern']="${dict['pattern']//\//\\\/}"
        dict['replace']="${dict['replace']//\//\\\/}"
        dict['expr']="s/${dict['pattern']}/${dict['replace']}/${dict['tail']}"
    else
        dict['expr']=" \
            \$pattern = quotemeta '${dict['pattern']}'; \
            \$replacement = '${dict['replace']}'; \
            s/\$pattern/\$replacement/${dict['tail']}; \
        "
    fi
    for str in "$@"
    do
        if [[ -z "$str" ]]
        then
            out+=("$str")
            continue
        fi
        out+=(
            "$( \
                printf '%s' "$str" \
                | LANG=C "${app['perl']}" -p -e "${dict['expr']}" \
            )"
        )
    done
    koopa_print "${out[@]}"
    return 0
}

koopa_sudo_append_string() {
    local -A app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['file']=''
    dict['string']=''
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
        | koopa_sudo "${app['tee']}" -a "${dict['file']}" >/dev/null
    return 0
}

koopa_sudo_trigger() {
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_is_root && return 0
    koopa_has_passwordless_sudo && return 0
    koopa_is_admin || return 1
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app['sudo']}"
    "${app['sudo']}" -v
    return 0
}

koopa_sudo_write_string() {
    local -A app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['file']=''
    dict['string']=''
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
        | koopa_sudo "${app['tee']}" "${dict['file']}" >/dev/null
    return 0
}

koopa_sudo() {
    local -A app
    local -a cmd
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    koopa_assert_has_args "$#"
    if ! koopa_is_root
    then
        koopa_assert_is_admin
        app['sudo']="$(koopa_locate_sudo)"
        koopa_assert_is_executable "${app[@]}"
        cmd+=("${app['sudo']}")
    fi
    cmd+=("$@")
    "${cmd[@]}"
    return 0
}

koopa_switch_to_develop() {
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_owner
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['branch']='develop'
    dict['origin']='origin'
    dict['prefix']="$(koopa_koopa_prefix)"
    dict['remote_url']='git@github.com:acidgenomics/koopa.git'
    dict['user']="$(koopa_user_name)"
    koopa_alert "Switching koopa at '${dict['prefix']}' to '${dict['branch']}'."
    (
        koopa_cd "${dict['prefix']}"
        if [[ "$(koopa_git_branch "${PWD:?}")" == 'develop' ]]
        then
            koopa_alert_note "Already on 'develop' branch."
            return 0
        fi
        if koopa_is_github_ssh_enabled
        then
            "${app['git']}" remote set-url \
                "${dict['origin']}" "${dict['remote_url']}"
        fi
        "${app['git']}" remote set-branches \
            --add "${dict['origin']}" "${dict['branch']}"
        "${app['git']}" fetch "${dict['origin']}"
        "${app['git']}" checkout --track "${dict['origin']}/${dict['branch']}"
    )
    koopa_zsh_compaudit_set_permissions
    return 0
}

koopa_sys_group_name() {
    local group
    koopa_assert_has_no_args "$#"
    if koopa_is_shared_install
    then
        group="$(koopa_admin_group_name)"
    else
        group="$(koopa_group_name)"
    fi
    koopa_print "$group"
    return 0
}

koopa_sys_ln() {
    local -A dict
    koopa_assert_has_args_eq "$#" 2
    dict['source']="${1:?}"
    dict['target']="${2:?}"
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
    local -A bool
    local -a chmod_args chown_args pos
    local arg
    koopa_assert_has_args "$#"
    bool['dereference']=1
    bool['recursive']=0
    bool['shared']=1
    bool['sudo']=0
    chmod_args=()
    chown_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--dereference' | \
            '-H')
                bool['dereference']=1
                shift 1
                ;;
            '--no-dereference' | \
            '-h')
                bool['dereference']=0
                shift 1
                ;;
            '--recursive' | \
            '-R' | \
            '-r')
                bool['recursive']=1
                shift 1
                ;;
            '--sudo' | \
            '-S')
                bool['sudo']=1
                shift 1
                ;;
            '--user' | \
            '-u')
                bool['shared']=0
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
    if [[ "${bool['shared']}" -eq 1 ]]
    then
        bool['group']="$(koopa_sys_group_name)"
        bool['user']="$(koopa_sys_user_name)"
    else
        bool['group']="$(koopa_group_name)"
        bool['user']="$(koopa_user_name)"
    fi
    chown_args+=('--no-dereference')
    if [[ "${bool['recursive']}" -eq 1 ]]
    then
        chmod_args+=('--recursive')
        chown_args+=('--recursive')
    fi
    if [[ "${bool['sudo']}" -eq 1 ]]
    then
        chmod_args+=('--sudo')
        chown_args+=('--sudo')
    fi
    if koopa_is_shared_install
    then
        chmod_args+=('u+rw,g+rw,o+r,o-w')
    else
        chmod_args+=('u+rw,g+r,g-w,o+r,o-w')
    fi
    chown_args+=("${bool['user']}:${bool['group']}")
    for arg in "$@"
    do
        if [[ "${bool['dereference']}" -eq 1 ]] && [[ -L "$arg" ]]
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

koopa_sys_user_name() {
    koopa_assert_has_no_args "$#"
    koopa_print "$(koopa_user_name)"
    return 0
}

koopa_system_info() {
    local -A app dict
    local -a info nf_info
    koopa_assert_has_no_args "$#"
    app['bash']="$(koopa_locate_bash --allow-system)"
    app['cat']="$(koopa_locate_cat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['arch']="$(koopa_arch)"
    dict['arch2']="$(koopa_arch2)"
    dict['bash_version']="$(koopa_get_version "${app['bash']}")"
    dict['config_prefix']="$(koopa_config_prefix)"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['koopa_url']="$(koopa_koopa_url)"
    dict['koopa_version']="$(koopa_koopa_version)"
    dict['opt_prefix']="$(koopa_opt_prefix)"
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
        koopa_assert_is_executable "${app['sw_vers']}"
        dict['os']="$( \
            printf '%s %s (%s)\n' \
                "$("${app['sw_vers']}" -productName)" \
                "$("${app['sw_vers']}" -productVersion)" \
                "$("${app['sw_vers']}" -buildVersion)" \
        )"
    else
        app['uname']="$(koopa_locate_uname --allow-system)"
        koopa_assert_is_executable "${app['uname']}"
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
    app['neofetch']="$(koopa_locate_neofetch --allow-missing)"
    if [[ -x "${app['neofetch']}" ]]
    then
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
    local -A app dict
    local -a dirs pos
    local dir
    koopa_assert_has_args "$#"
    app['tar']="$(koopa_locate_tar --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['delete']=0
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
    local -A dict
    local -a all_files
    koopa_assert_has_args "$#"
    dict['ext']="${1:?}"
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
    local -A app dict
    local -a all_files files
    local file
    koopa_assert_has_args "$#"
    app['head']="$(koopa_locate_head)"
    app['tr']="$(koopa_locate_tr)"
    koopa_assert_is_executable "${app[@]}"
    dict['pattern']="${1:?}"
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
    local -A dict
    local -a files
    koopa_assert_has_no_args "$#"
    dict['prefix']="$(koopa_koopa_prefix)"
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
    local -A app dict
    local -a failures pos
    local file
    koopa_assert_has_args "$#"
    app['grep']="$(koopa_locate_grep)"
    koopa_assert_is_executable "${app[@]}"
    dict['ignore']=''
    dict['name']=''
    dict['pattern']=''
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
    local -A app
    koopa_assert_has_no_args "$#"
    app['awk']="$(koopa_locate_awk)"
    koopa_assert_is_executable "${app[@]}"
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
    local -A app
    local str
    koopa_assert_has_args_le "$#" 1
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['tex']="${1:-}"
    [[ -z "${app['tex']}" ]] && app['tex']="$(koopa_locate_tex)"
    koopa_assert_is_executable "${app[@]}"
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
    koopa_paste --sep=', ' "$@"
    return 0
}

koopa_today() {
    _koopa_today "$@"
}

koopa_touch() {
    local -A app dict
    local -a mkdir pos touch
    koopa_assert_has_args "$#"
    app['touch']="$(koopa_locate_touch --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
    mkdir=('koopa_mkdir')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        mkdir+=('--sudo')
        touch=('koopa_sudo' "${app['touch']}")
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
        local -a pos
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

koopa_uninstall_apache_arrow() {
    koopa_uninstall_app \
        --name='apache-arrow' \
        "$@"
}

koopa_uninstall_apache_spark() {
    koopa_uninstall_app \
        --name='apache-spark' \
        "$@"
}

koopa_uninstall_app() {
    local -A bool dict
    local -a bin_arr man1_arr
    bool['quiet']=0
    bool['unlink_in_bin']=''
    bool['unlink_in_man1']=''
    bool['unlink_in_opt']=''
    bool['verbose']=0
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['mode']='shared'
    dict['name']=''
    dict['opt_prefix']="$(koopa_opt_prefix)"
    dict['platform']='common'
    dict['prefix']=''
    dict['uninstaller_bn']=''
    dict['uninstaller_fun']='main'
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
            '--verbose')
                bool['verbose']=1
                shift 1
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
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--name' "${dict['name']}"
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        export KOOPA_VERBOSE=1
        set -o xtrace
    fi
    case "${dict['mode']}" in
        'shared')
            koopa_assert_is_owner
            [[ -z "${dict['prefix']}" ]] && \
                dict['prefix']="${dict['app_prefix']}/${dict['name']}"
            [[ -z "${bool['unlink_in_bin']}" ]] && bool['unlink_in_bin']=1
            [[ -z "${bool['unlink_in_man1']}" ]] && bool['unlink_in_man1']=1
            [[ -z "${bool['unlink_in_opt']}" ]] && bool['unlink_in_opt']=1
            ;;
        'system')
            koopa_assert_is_owner
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
            return 0
        fi
        dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    fi
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        koopa_alert_uninstall_start "${dict['name']}" "${dict['prefix']}"
    fi
    [[ -z "${dict['uninstaller_bn']}" ]] && \
        dict['uninstaller_bn']="${dict['name']}"
    dict['uninstaller_file']="$(koopa_bash_prefix)/include/uninstall/\
${dict['platform']}/${dict['mode']}/${dict['uninstaller_bn']}.sh"
    if [[ -f "${dict['uninstaller_file']}" ]]
    then
        dict['tmp_dir']="$(koopa_tmp_dir)"
        (
            case "${dict['mode']}" in
                'system')
                    koopa_add_to_path_end '/usr/sbin' '/sbin'
                    ;;
            esac
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
        koopa_alert_uninstall_success "${dict['name']}" "${dict['prefix']}"
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

koopa_uninstall_blast() {
    koopa_uninstall_app \
        --name='blast' \
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

koopa_uninstall_byobu() {
    koopa_uninstall_app \
        --name='byobu' \
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

koopa_uninstall_cereal() {
    koopa_uninstall_app \
        --name='cereal' \
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

koopa_uninstall_dash() {
    koopa_uninstall_app \
        --name='dash' \
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

koopa_uninstall_docker_credential_helpers() {
    koopa_uninstall_app \
        --name='docker-credential-helpers' \
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

koopa_uninstall_ed() {
    koopa_uninstall_app \
        --name='ed' \
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

koopa_uninstall_eza() {
    koopa_uninstall_app \
        --name='eza' \
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

koopa_uninstall_fqtk() {
    koopa_uninstall_app \
        --name='fqtk' \
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

koopa_uninstall_gh() {
    koopa_uninstall_app \
        --name='gh' \
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

koopa_uninstall_gitui() {
    koopa_uninstall_app \
        --name='gitui' \
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

koopa_uninstall_htslib() {
    koopa_uninstall_app \
        --name='htslib' \
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

koopa_uninstall_isl() {
    koopa_uninstall_app \
        --name='isl' \
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

koopa_uninstall_jless() {
    koopa_uninstall_app \
        --name='jless' \
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
    local -A bool dict
    bool['uninstall_koopa']=1
    dict['config_prefix']="$(koopa_config_prefix)"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    if koopa_is_interactive
    then
        bool['uninstall_koopa']="$( \
            koopa_read_yn \
                'Proceed with koopa uninstall' \
                "${bool['uninstall_koopa']}" \
        )"
    fi
    [[ "${bool['uninstall_koopa']}" -eq 0 ]] && return 1
    koopa_rm --verbose "${dict['config_prefix']}"
    if koopa_is_shared_install
    then
        if koopa_is_linux
        then
            koopa_rm --sudo --verbose '/etc/profile.d/zzz-koopa.sh'
        fi
        koopa_rm --sudo --verbose "${dict['koopa_prefix']}"
    else
        koopa_rm --verbose "${dict['koopa_prefix']}"
    fi
    return 0
}

koopa_uninstall_krb5() {
    koopa_uninstall_app \
        --name='krb5' \
        "$@"
}

koopa_uninstall_ksh93() {
    koopa_uninstall_app \
        --name='ksh93' \
        "$@"
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

koopa_uninstall_ldc() {
    koopa_uninstall_app \
        --name='ldc' \
        "$@"
}

koopa_uninstall_ldns() {
    koopa_uninstall_app \
        --name='ldns' \
        "$@"
}

koopa_uninstall_less() {
    koopa_uninstall_app \
        --name='less' \
        "$@"
}

koopa_uninstall_lesspipe() {
    koopa_uninstall_app \
        --name='lesspipe' \
        "$@"
}

koopa_uninstall_libaec() {
    koopa_uninstall_app \
        --name='libaec' \
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

koopa_uninstall_libcbor() {
    koopa_uninstall_app \
        --name='libcbor' \
        "$@"
}

koopa_uninstall_libconfig() {
    koopa_uninstall_app \
        --name='libconfig' \
        "$@"
}

koopa_uninstall_libdeflate() {
    koopa_uninstall_app \
        --name='libdeflate' \
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

koopa_uninstall_libfido2() {
    koopa_uninstall_app \
        --name='libfido2' \
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

koopa_uninstall_libxcrypt() {
    koopa_uninstall_app \
        --name='libxcrypt' \
        "$@"
}

koopa_uninstall_libxml2() {
    koopa_uninstall_app \
        --name='libxml2' \
        "$@"
}

koopa_uninstall_libxslt() {
    koopa_uninstall_app \
        --name='libxslt' \
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

koopa_uninstall_luigi() {
    koopa_uninstall_app \
        --name='luigi' \
        "$@"
}

koopa_uninstall_lz4() {
    koopa_uninstall_app \
        --name='lz4' \
        "$@"
}

koopa_uninstall_lzip() {
    koopa_uninstall_app \
        --name='lzip' \
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

koopa_uninstall_miller() {
    koopa_uninstall_app \
        --name='miller' \
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

koopa_uninstall_mold() {
    koopa_uninstall_app \
        --name='mold' \
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

koopa_uninstall_mutagen() {
    koopa_uninstall_app \
        --name='mutagen' \
        "$@"
}

koopa_uninstall_mypy() {
    koopa_uninstall_app \
        --name='mypy' \
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

koopa_uninstall_ncbi_sra_tools() {
    koopa_uninstall_app \
        --name='ncbi-sra-tools' \
        "$@"
}

koopa_uninstall_ncbi_vdb() {
    koopa_uninstall_app \
        --name='ncbi-vdb' \
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

koopa_uninstall_ont_dorado() {
    koopa_uninstall_app \
        --name='ont-dorado' \
        "$@"
}

koopa_uninstall_ont_vbz_compression() {
    koopa_uninstall_app \
        --name='ont-vbz-compression' \
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

koopa_uninstall_openjpeg() {
    koopa_uninstall_app \
        --name='openjpeg' \
        "$@"
}

koopa_uninstall_openldap() {
    koopa_uninstall_app \
        --name='openldap' \
        "$@"
}

koopa_uninstall_openssh() {
    koopa_uninstall_app \
        --name='openssh' \
        "$@"
}

koopa_uninstall_openssl3() {
    koopa_uninstall_app \
        --name='openssl3' \
        "$@"
}

koopa_uninstall_p7zip() {
    koopa_uninstall_app \
        --name='p7zip' \
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

koopa_uninstall_pbzip2() {
    koopa_uninstall_app \
        --name='pbzip2' \
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

koopa_uninstall_picard() {
    koopa_uninstall_app \
        --name='picard' \
        "$@"
}

koopa_uninstall_pigz() {
    koopa_uninstall_app \
        --name='pigz' \
        "$@"
}

koopa_uninstall_pinentry() {
    koopa_uninstall_app \
        --name='pinentry' \
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

koopa_uninstall_private_ont_guppy() {
    koopa_uninstall_app \
        --name='ont-guppy' \
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
    local -A dict
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['bin_prefix']="$(koopa_bin_prefix)"
    dict['opt_prefix']="$(koopa_opt_prefix)"
    koopa_uninstall_app \
        --name='python3.11' \
        "$@"
    koopa_rm  \
        "${dict['app_prefix']}/python" \
        "${dict['bin_prefix']}/python" \
        "${dict['bin_prefix']}/python3" \
        "${dict['opt_prefix']}/python"
    return 0
}

koopa_uninstall_quarto() {
    koopa_uninstall_app \
        --name='quarto' \
        "$@"
}

koopa_uninstall_r_devel() {
    koopa_uninstall_app \
        --name='r-devel' \
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

koopa_uninstall_rclone() {
    koopa_uninstall_app \
        --name='rclone' \
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

koopa_uninstall_ronn_ng() {
    koopa_uninstall_app \
        --name='ronn-ng' \
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

koopa_uninstall_ruff_lsp() {
    koopa_uninstall_app \
        --name='ruff-lsp' \
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

koopa_uninstall_screen() {
    koopa_uninstall_app \
        --name='screen' \
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

koopa_uninstall_seqkit() {
    koopa_uninstall_app \
        --name='seqkit' \
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

koopa_uninstall_staden_io_lib() {
    koopa_uninstall_app \
        --name='staden-io-lib' \
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

koopa_uninstall_subread() {
    koopa_uninstall_app \
        --name='subread' \
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

koopa_uninstall_system_bootstrap() {
    koopa_uninstall_app \
        --name='bootstrap' \
        --system \
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
        "$@"
}

koopa_uninstall_tbb() {
    koopa_uninstall_app \
        --name='tbb' \
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

koopa_uninstall_temurin() {
    koopa_uninstall_app \
        --name='temurin' \
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

koopa_uninstall_tryceratops() {
    koopa_uninstall_app \
        --name='tryceratops' \
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

koopa_uninstall_umis() {
    koopa_uninstall_app \
        --name='umis' \
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

koopa_uninstall_walk() {
    koopa_uninstall_app \
        --name='walk' \
        "$@"
}

koopa_uninstall_wget() {
    koopa_uninstall_app \
        --name='wget' \
        "$@"
}

koopa_uninstall_wget2() {
    koopa_uninstall_app \
        --name='wget2' \
        "$@"
}

koopa_uninstall_which() {
    koopa_uninstall_app \
        --name='which' \
        "$@"
}

koopa_uninstall_woff2() {
    koopa_uninstall_app \
        --name='woff2' \
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

koopa_uninstall_yapf() {
    koopa_uninstall_app \
        --name='yapf' \
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

koopa_uninstall_zopfli() {
    koopa_uninstall_app \
        --name='zopfli' \
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
    koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(koopa_bin_prefix)" \
        "$@"
}

koopa_unlink_in_dir() {
    local -A dict
    local -a names pos
    local name
    koopa_assert_has_args "$#"
    dict['allow_missing']=0
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

koopa_unlink_in_man1() {
    koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(koopa_man_prefix)/man1" \
        "$@"
}

koopa_unlink_in_opt() {
    koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(koopa_opt_prefix)" \
        "$@"
}

koopa_update_koopa() {
    local -A dict
    local -a prefixes
    local prefix
    koopa_assert_has_no_args "$#"
    koopa_assert_is_owner
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['user_id']="$(koopa_user_id)"
    if ! koopa_is_git_repo_top_level "${dict['koopa_prefix']}"
    then
        koopa_alert_note "Pinned release detected at '${dict['koopa_prefix']}'."
        return 1
    fi
    prefixes=("${dict['koopa_prefix']}/lang/zsh")
    for prefix in "${prefixes[@]}"
    do
        if [[ "$(koopa_stat_user_id "$prefix")" == "${dict['user_id']}" ]]
        then
            continue
        fi
        koopa_alert "Fixing ownership of '${prefix}'."
        koopa_chown --recursive --sudo "${dict['user_id']}" "$prefix"
    done
    koopa_git_pull "${dict['koopa_prefix']}"
    koopa_zsh_compaudit_set_permissions
    return 0
}

koopa_update_private_ont_guppy_installers() {
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_has_private_access
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['base_url']='https://cdn.oxfordnanoportal.com/software/analysis'
    dict['name']='ont-guppy'
    dict['prefix']="$(koopa_tmp_dir)"
    dict['s3_profile']='acidgenomics'
    dict['s3_target']="$(koopa_private_installers_s3_uri)/${dict['name']}"
    dict['version']="$(koopa_app_json_version "${dict['name']}")"
    koopa_mkdir \
        "${dict['prefix']}/linux/amd64" \
        "${dict['prefix']}/linux/arm64" \
        "${dict['prefix']}/macos/amd64"
    koopa_download \
        "${dict['base_url']}/ont-guppy-cpu_${dict['version']}_linux64.tar.gz" \
        "${dict['prefix']}/linux/amd64/${dict['version']}-cpu.tar.gz"
    koopa_download \
        "${dict['base_url']}/ont-guppy_${dict['version']}_linux64.tar.gz" \
        "${dict['prefix']}/linux/amd64/${dict['version']}-gpu.tar.gz"
    koopa_download \
        "${dict['base_url']}/ont-guppy_${dict['version']}_linuxaarch64_\
cuda10.tar.gz" \
        "${dict['prefix']}/linux/arm64/${dict['version']}-gpu.tar.gz"
    koopa_download \
        "${dict['base_url']}/ont-guppy-cpu_${dict['version']}_osx64.zip" \
        "${dict['prefix']}/macos/amd64/${dict['version']}-cpu.zip"
    "${app['aws']}" s3 sync \
        --profile "${dict['s3_profile']}" \
        "${dict['prefix']}/" \
        "${dict['s3_target']}/"
    koopa_rm "${dict['prefix']}"
    return 0
}

koopa_update_system_homebrew() {
    local -A app dict
    local -a taps
    local tap
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_assert_is_owner
    if koopa_is_macos
    then
        koopa_macos_assert_is_xcode_clt_installed
    fi
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$(koopa_homebrew_prefix)"
    dict['user_id']="$(koopa_user_id)"
    koopa_assert_is_dir \
        "${dict['prefix']}" \
        "${dict['prefix']}/bin"
    koopa_alert_update_start 'Homebrew' "${dict['prefix']}"
    koopa_brew_reset_permissions
    koopa_alert 'Updating Homebrew.'
    koopa_add_to_path_start "${dict['prefix']}/bin"
    "${app['brew']}" analytics off
    "${app['brew']}" update
    if koopa_is_macos
    then
        koopa_macos_brew_upgrade_casks
    fi
    koopa_brew_upgrade_brews
    koopa_alert 'Cleaning up.'
    taps=(
        'homebrew/cask'
        'homebrew/cask-drivers'
        'homebrew/core'
    )
    for tap in "${taps[@]}"
    do
        local tap_prefix
        tap_prefix="$("${app['brew']}" --repo "$tap")"
        if [[ -d "$tap_prefix" ]]
        then
            koopa_alert "Untapping '${tap}'."
            "${app['brew']}" untap "$tap"
        fi
    done
    "${app['brew']}" cleanup -s || true
    koopa_rm "$("${app['brew']}" --cache)"
    "${app['brew']}" autoremove || true
    koopa_brew_doctor
    koopa_alert_update_success 'Homebrew' "${dict['prefix']}"
    return 0
}

koopa_update_system_tex_packages() {
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['tlmgr']="$(koopa_locate_tlmgr)"
    koopa_assert_is_executable "${app[@]}"
    (
        koopa_activate_app --build-only 'curl' 'gnupg' 'wget'
        koopa_sudo "${app['tlmgr']}" update --self
        koopa_sudo "${app['tlmgr']}" update --list
        koopa_sudo "${app['tlmgr']}" update --all
    )
    return 0
}

koopa_user_id() {
    _koopa_user_id "$@"
}

koopa_user_name() {
    _koopa_user_name "$@"
}

koopa_validate_json() {
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['python']="$(koopa_locate_python312)"
    dict['file']="${1:?}"
    "${app['python']}" -m 'json.tool' "${dict['file']}" >/dev/null
}

koopa_version_pattern() {
    koopa_assert_has_no_args "$#"
    koopa_print '[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([+a-z])?([0-9]+)?'
    return 0
}

koopa_view_latest_tmp_log_file() {
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    dict['tmp_dir']="${TMPDIR:-/tmp}"
    dict['user_id']="$(koopa_user_id)"
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
    koopa_msg 'magenta-bold' 'magenta' '!!' "$@" >&2
    return 0
}

koopa_wget_recursive() {
    local -A app dict
    local -a wget_args
    koopa_assert_has_args "$#"
    app['wget']="$(koopa_locate_wget)"
    koopa_assert_is_executable "${app[@]}"
    dict['datetime']="$(koopa_datetime)"
    dict['password']=''
    dict['url']=''
    dict['user']=''
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
    local -A dict
    koopa_assert_has_args_eq "$#" 1
    [[ -z "${1:-}" ]] && return 1
    dict['input_key']="${1:?}"
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
    local -A dict
    koopa_assert_has_args "$#"
    dict['file']=''
    dict['string']=''
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

koopa_xdg_config_home() {
    _koopa_xdg_config_home "$@"
}

koopa_xdg_data_home() {
    _koopa_xdg_data_home "$@"
}

koopa_zsh_compaudit_set_permissions() {
    local -A dict
    local -a prefixes
    local prefix
    koopa_assert_has_no_args "$#"
    koopa_assert_is_owner
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['opt_prefix']="$(koopa_opt_prefix)"
    dict['user_id']="$(koopa_user_id)"
    prefixes=(
        "${dict['koopa_prefix']}/lang/zsh"
        "${dict['opt_prefix']}/zsh/share/zsh"
    )
    for prefix in "${prefixes[@]}"
    do
        local access
        [[ -d "$prefix" ]] || continue
        if [[ "$(koopa_stat_user_id "$prefix")" != "${dict['user_id']}" ]]
        then
            koopa_alert "Fixing ownership at '${prefix}'."
            koopa_chown --recursive --sudo "${dict['user_id']}" "$prefix"
        fi
        access="$(koopa_stat_access_octal "$prefix")"
        access="${access: -3}"
        if [[ "$access" != '755' ]]
        then
            koopa_alert "Fixing write access at '${prefix}'."
            koopa_chmod --recursive 'g-w' "$prefix"
        fi
    done
    return 0
}
