#!/usr/bin/env bash

# TODO For user-specific install, ensure we symlink .bash_profile to .bashrc
# if the file doesn't exist.

koopa_install_koopa() {
    # """
    # Install koopa.
    # @note Updated 2024-12-03.
    # """
    local -A bool dict
    bool['add_to_user_profile']=1
    bool['bootstrap']=0
    bool['interactive']=1
    bool['passwordless_sudo']=0
    bool['shared']=0
    bool['verbose']=0
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
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
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
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        set -x
        koopa_print_env
    fi
    if [[ -d "${KOOPA_BOOTSTRAP_PREFIX:-}" ]]
    then
        bool['bootstrap']=1
        koopa_add_to_path_start "${KOOPA_BOOTSTRAP_PREFIX}/bin"
    fi
    koopa_assert_is_installed \
        'cp' 'curl' 'cut' 'find' 'git' 'grep' 'mkdir' 'mktemp' 'mv' 'perl' \
        'python3' 'readlink' 'rm' 'sed' 'tar' 'tr' 'unzip'
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
        dict['prefix']="$( \
            koopa_read \
                'Install prefix' \
                "${dict['prefix']}" \
        )"
        if koopa_str_detect_regex \
            --string="${dict['prefix']}" \
            --pattern="^${HOME:?}"
        then
            bool['shared']=0
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
        dict['user_id']="$(koopa_user_id)"
        dict['group_id']="$(koopa_group_id)"
        koopa_cp --sudo "${dict['source_prefix']}" "${dict['prefix']}"
        koopa_chown \
            --dereference \
            --recursive \
            --sudo \
            "${dict['user_id']}:${dict['group_id']}" \
            "${dict['prefix']}"
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
            koopa_linux_update_profile_d
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
        koopa_cli_install --bootstrap \
            'bash' \
            'coreutils' \
            'python3.12'
    fi
    return 0
}
