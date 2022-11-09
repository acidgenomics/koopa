#!/bin/sh

__koopa_posix_header() {
    # """
    # POSIX shell header.
    # @note Updated 2022-11-09.
    # """
    [ "$#" -eq 0 ] || return 1
    if [ -z "${KOOPA_PREFIX:-}" ]
    then
        printf '%s\n' "ERROR: Required 'KOOPA_PREFIX' is unset." >&2
        return 1
    fi
    if [ -f "${KOOPA_PREFIX}/lang/shell/posix/functions.sh" ]
    then
        # shellcheck source=/dev/null
        . "${KOOPA_PREFIX}/lang/shell/posix/functions.sh"
    else
        local file
        for file in "${KOOPA_PREFIX}/lang/shell/posix/functions/"*'.sh'
        do
            # shellcheck source=/dev/null
            . "$file"
        done
    fi
    if [ "${KOOPA_TEST:-0}" -eq 1 ]
    then
        koopa_duration_start || return 1
    fi
    if [ -z "${KOOPA_DEFAULT_SYSTEM_PATH:-}" ]
    then
        export KOOPA_DEFAULT_SYSTEM_PATH="${PATH:-}"
    fi
    case "${KOOPA_ACTIVATE:-0}" in
        '0')
            unalias -a
            if [ "${KOOPA_INSTALL_APP_SUBSHELL:-0}" -eq 0 ]
            then
                PATH='/usr/bin:/bin'
                PATH="${KOOPA_PREFIX}/bin:${PATH}"
                export PATH
            fi
            ;;
        '1')
            __koopa_activate_koopa || return 1
            ;;
    esac
    if [ "${KOOPA_TEST:-0}" -eq 1 ]
    then
        koopa_duration_stop 'posix' || return 1
    fi
    return 0
}

__koopa_activate_koopa() {
    # """
    # Activate koopa in interactive shell.
    # @note Updated 2022-09-02.
    # """
    if [ "${KOOPA_MINIMAL:-0}" -eq 0 ]
    then
        koopa_activate_path_helper || return 1
    fi
    koopa_add_to_path_start "${KOOPA_PREFIX}/bin" || return 1
    koopa_add_to_manpath_start "${KOOPA_PREFIX}/share/man" || return 1
    [ "${KOOPA_MINIMAL:-0}" -eq 0 ] || return 0
    koopa_add_to_path_start \
        '/usr/local/bin'
    koopa_add_to_manpath_start \
        '/usr/local/man' \
        '/usr/local/share/man'
    koopa_add_to_manpath_end '/usr/share/man'
    # > koopa_umask || return 1
    koopa_export_koopa_cpu_count || return 1
    koopa_export_koopa_shell || return 1
    # Edge case for RStudio Server terminal to support dircolors.
    [ -n "${SHELL:-}" ] && export SHELL
    koopa_activate_xdg || return 1
    koopa_export_editor || return 1
    koopa_export_git || return 1
    koopa_export_gnupg || return 1
    koopa_export_history || return 1
    koopa_export_pager || return 1
    koopa_activate_ca_certificates || return 1
    koopa_activate_homebrew || return 1
    koopa_activate_google_cloud_sdk || return 1
    koopa_activate_ruby || return 1
    koopa_activate_julia || return 1
    koopa_activate_python || return 1
    koopa_activate_pipx || return 1
    koopa_activate_bcbio_nextgen || return 1
    koopa_activate_color_mode || return 1
    koopa_activate_alacritty || return 1
    koopa_activate_bat || return 1
    koopa_activate_delta || return 1
    koopa_activate_difftastic || return 1
    koopa_activate_dircolors || return 1
    koopa_activate_fzf || return 0
    koopa_activate_gcc_colors || return 1
    koopa_activate_kitty || return 1
    koopa_activate_lesspipe || return 1
    koopa_activate_secrets || return 1
    koopa_activate_ssh_key || return 1
    koopa_activate_tealdeer || return 1
    if koopa_is_macos
    then
        koopa_macos_activate_cli_colors || return 1
    fi
    case "$(koopa_shell_name)" in
        'zsh')
            alias conda='koopa_alias_conda'
            ;;
        *)
            koopa_activate_conda || return 1
            ;;
    esac
    # Previously included:
    # > "$(koopa_xdg_local_home)/bin"
    koopa_add_to_path_start \
        "$(koopa_scripts_private_prefix)/bin" \
        || return 1
    if ! koopa_is_subshell
    then
        koopa_add_config_link \
            "$(koopa_koopa_prefix)" 'home' \
            "$(koopa_koopa_prefix)/activate" 'activate' \
            "$(koopa_dotfiles_prefix)" 'dotfiles' \
            || return 1
        koopa_activate_today_bucket || return 1
    fi
    koopa_activate_aliases || return 1
    return 0
}

# NOTE Don't pass "$@" here, will pass through in Bash header.
__koopa_posix_header
