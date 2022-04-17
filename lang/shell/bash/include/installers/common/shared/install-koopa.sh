#!/usr/bin/env bash

# FIXME Need to rework this installer and check inside Docker.

main() { # {{{1
    # """
    # Install koopa.
    # @note Updated 2022-04-17.
    # """
    local dict
    declare -A dict=(
        [dotfiles]=0
        [interactive]=1
        [koopa_prefix]=''
        [modify_user_profile]=0
        [name_fancy]='koopa'
        [passwordless]=0
        [prefix]="$( \
            cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && \
            pwd -P \
        )"
        [shared]=0
        [test]=0
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict[koopa_prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[koopa_prefix]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--dotfiles')
                dict[dotfiles]=1
                shift 1
                ;;
            '--help' | \
            '-h')
                usage
                ;;
            '--interactive')
                dict[interactive]=1
                shift 1
                ;;
            '--no-dotfiles')
                dict[dotfiles]=0
                shift 1
                ;;
            '--no-passwordless-sudo')
                dict[passwordless]=0
                shift 1
                ;;
            '--no-profile')
                dict[modify_user_profile]=0
                shift 1
                ;;
            '--no-shared')
                dict[shared]=0
                shift 1
                ;;
            '--no-test' | \
            '--no-verbose')
                dict[test]=0
                shift 1
                ;;
            '--non-interactive')
                dict[interactive]=0
                shift 1
                ;;
            '--passwordless-sudo')
                dict[passwordless]=1
                shift 1
                ;;
            '--profile')
                dict[modify_user_profile]=1
                shift 1
                ;;
            '--shared')
                dict[shared]=1
                shift 1
                ;;
            '--test' | \
            '--verbose')
                dict[test]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    # Pre-flight checks {{{2
    # ==========================================================================
    unset KOOPA_PREFIX
    KOOPA_FORCE=1
    KOOPA_TEST="${dict[test]}"
    export KOOPA_FORCE KOOPA_TEST
    # shellcheck source=/dev/null
    koopa_assert_is_installed 'cp' 'curl' 'find' 'git' 'grep' 'mkdir' \
        'mktemp' 'mv' 'readlink' 'rm' 'sed' 'tar' 'unzip'
    # Configuration {{{2
    # ==========================================================================
    dict[config_prefix]="$(koopa_config_prefix)"
    dict[user_profile]="$(koopa_find_user_profile)"
    dict[xdg_data_home]="${XDG_DATA_HOME:-${HOME:?}/.local/share}"
    dict[koopa_prefix_user]="${dict[xdg_data_home]}/koopa"
    dict[koopa_prefix_system]='/opt/koopa'
    koopa_is_admin && dict[shared]=1
    if [[ "${dict[interactive]}" -eq 1 ]]
    then
        # Install for all users? {{{3
        # ----------------------------------------------------------------------
        if koopa_is_admin && \
            [[ -z "${dict[koopa_prefix]}" ]]
        then
            dict[shared]="$( \
                koopa_read_yn \
                    'Install for all users' \
                    "${dict[shared]}" \
            )"
        fi
        # Install prefix {{{3
        # ----------------------------------------------------------------------
        if [[ -z "${dict[koopa_prefix]}" ]]
        then
            if [[ "${dict[shared]}" -eq 1 ]]
            then
                dict[koopa_prefix]="${dict[koopa_prefix_system]}"
            else
                dict[koopa_prefix]="${dict[koopa_prefix_user]}"
            fi
        fi
        dict[koopa_prefix]="$( \
            koopa_read \
                'Install prefix' \
                "${dict[koopa_prefix]}" \
        )"
        if koopa_str_detect_regex \
            --string="${dict[koopa_prefix]}" \
            --pattern="^${HOME:?}"
        then
            dict[shared]=0
        else
            dict[shared]=1
        fi
        # Enable passwordless sudo? {{{3
        # ----------------------------------------------------------------------
        if [[ "${dict[shared]}" -eq 1 ]]
        then
            dict[passwordless]="$( \
                koopa_read_yn \
                    'Enable passwordless sudo' \
                    "${dict[passwordless]}" \
            )"
        fi
        # Install dotfiles? {{{3
        # ----------------------------------------------------------------------
        if [[ -e "${dict[user_profile]}" ]]
        then
            koopa_alert_note \
                "User profile exists: '${dict[user_profile]}'." \
                'This will be overwritten if dotfiles are linked.'
        fi
        dict[dotfiles]="$( \
            koopa_read_yn \
                'Install and link dotfiles' \
                "${dict[dotfiles]}" \
        )"
        # Modify user profile? {{{3
        # ----------------------------------------------------------------------
        if [[ "${dict[dotfiles]}" -eq 0 ]] && \
            ! koopa_is_defined_in_user_profile && \
            [[ ! -L "${dict[user_profile]}" ]]
        then
            koopa_alert_note 'Koopa activation missing in user profile.'
            dict[modify_user_profile]="$( \
                koopa_read_yn \
                    "Modify '${dict[user_profile]}'" \
                    "${dict[modify_user_profile]}" \
            )"
        fi
    else
        if [[ -z "${dict[koopa_prefix]}" ]]
        then
            if [[ "${dict[shared]}" -eq 1 ]]
            then
                dict[koopa_prefix]="${dict[koopa_prefix_system]}"
            else
                dict[koopa_prefix]="${dict[koopa_prefix_user]}"
            fi
        fi
    fi
    # Perform installation {{{2
    # ==========================================================================
    # Ensure existing user configuration gets removed.
    koopa_rm "${dict[config_prefix]}"
    # Copy files from temporary directory {{{3
    # --------------------------------------------------------------------------
    # Alternatively, can consider using rsync here instead of cp.
    koopa_alert_install_start "${dict[name_fancy]}" "${dict[koopa_prefix]}"
    if [[ "${dict[shared]}" -eq 1 ]]
    then
        koopa_alert_info 'Shared installation detected.'
        koopa_alert_note 'Admin (sudo) permissions are required.'
        koopa_assert_is_admin
        if [[ "${dict[koopa_prefix]}" != "${dict[prefix]}" ]]
        then
            koopa_rm --sudo "${dict[koopa_prefix]}"
            koopa_cp --sudo "${dict[prefix]}" "${dict[koopa_prefix]}"
        fi
        koopa_sys_set_permissions --recursive "${dict[koopa_prefix]}"
        koopa_add_make_prefix_link "${dict[koopa_prefix]}"
    else
        if [[ "${dict[koopa_prefix]}" != "${dict[prefix]}" ]]
        then
            koopa_cp "${dict[prefix]}" "${dict[koopa_prefix]}"
        fi
    fi
    # Activate koopa {{{2
    # ==========================================================================
    koopa_alert "Activating ${dict[name_fancy]} at '${dict[koopa_prefix]}'."
    set +o nounset
    # shellcheck source=/dev/null
    . "${dict[koopa_prefix]}/activate" || return 1
    set -o nounset
    # Check that 'KOOPA_PREFIX' is set correctly by activation script.
    if [[ "${dict[koopa_prefix]}" != "${KOOPA_PREFIX:-}" ]]
    then
        >&2 cat << END
ERROR: Installer failed to set 'KOOPA_PREFIX' correctly.
    Expected: '${dict[koopa_prefix]}'
    Actual: '${KOOPA_PREFIX:-}'
    PWD: '${PWD:-}'
    BASH_SOURCE: '${BASH_SOURCE[0]}'
END
        return 1
    fi
    # Check that activation puts koopa into 'PATH', as expected.
    if ! koopa_is_installed koopa
    then
        >&2 cat << END
ERROR: Installer failed to set 'PATH' correctly.
    KOOPA_PREFIX: '${KOOPA_PREFIX:-}'
    PATH: '${PATH:-}'
END
        return 1
    fi
    # Additional optional configuration {{{3
    # --------------------------------------------------------------------------
    if [[ "${dict[passwordless]}" -eq 1 ]]
    then
        koopa_enable_passwordless_sudo
    fi
    if [[ "${dict[dotfiles]}" -eq 1 ]]
    then
        koopa_install_dotfiles
    fi
    if [[ "${dict[modify_user_profile]}" -eq 1 ]]
    then
        koopa_add_to_user_profile
    fi
    # Final cleanup {{{3
    # --------------------------------------------------------------------------
    if [[ "${dict[shared]}" -eq 1 ]] && koopa_is_linux
    then
        koopa_linux_update_etc_profile_d
    fi
    koopa_fix_zsh_permissions
    koopa_alert_install_success "${dict[name_fancy]}" "${dict[koopa_prefix]}"
    koopa_alert_restart
    return 0
}

main "$@"
