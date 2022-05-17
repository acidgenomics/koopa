#!/usr/bin/env bash

koopa_install_koopa() {
    # """
    # Install koopa.
    # @note Updated 2022-05-12.
    # """
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
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--add-to-user-profile')
                bool[add_to_user_profile]=0
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
            # Other ------------------------------------------------------------
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
            dict[add_to_user_profile]="$( \
                koopa_read_yn \
                    "Modify '${dict[user_profile]}'" \
                    "${dict[add_to_user_profile]}" \
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
