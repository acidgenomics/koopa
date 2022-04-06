#!/bin/sh

__koopa_posix_header() { # {{{1
    # """
    # POSIX shell header.
    # @note Updated 2022-04-05.
    # """
    local shell
    [ "$#" -eq 0 ] || return 1
    if [ -z "${KOOPA_PREFIX:-}" ]
    then
        printf '%s\n' "ERROR: Required 'KOOPA_PREFIX' is unset." >&2
        return 1
    fi
    # shellcheck source=/dev/null
    . "${KOOPA_PREFIX}/lang/shell/posix/functions.sh"
    if [ "${KOOPA_TEST:-0}" -eq 1 ]
    then
        koopa_duration_start || return 1
    fi
    if [ -z "${KOOPA_DEFAULT_SYSTEM_PATH:-}" ]
    then
        export KOOPA_DEFAULT_SYSTEM_PATH="${PATH:-}"
    fi
    if [ -z "${KOOPA_DEFAULT_SYSTEM_PKG_CONFIG_PATH:-}" ]
    then
        export KOOPA_DEFAULT_SYSTEM_PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    fi
    if [ "${KOOPA_ACTIVATE:-0}" -eq 0 ]
    then
        export PATH="${KOOPA_DEFAULT_SYSTEM_PATH:?}"
    fi
    koopa_add_to_manpath_end '/usr/share/man'
    koopa_activate_make_paths || return 1
    koopa_activate_pkg_config || return 1
    if [ "${KOOPA_MINIMAL:-0}" -eq 0 ]
    then
        # > koopa_umask || return 1
        koopa_export_koopa_shell || return 1
        # Edge case for RStudio Server terminal to support dircolors correctly.
        [ -n "${SHELL:-}" ] && export SHELL
        koopa_activate_xdg || return 1
        koopa_add_koopa_config_link \
            "$(koopa_koopa_prefix)" 'home' \
            "$(koopa_koopa_prefix)/activate" 'activate' \
            "$(koopa_dotfiles_prefix)" 'dotfiles' \
            || return 1
        koopa_activate_homebrew || return 1
        koopa_activate_go || return 1
        koopa_activate_nim || return 1
        koopa_activate_ruby || return 1
        koopa_activate_node || return 1
        koopa_activate_julia || return 1
        koopa_activate_perl || return 1
        koopa_activate_python || return 1
        koopa_activate_pipx || return 1
        koopa_activate_rust || return 1
        koopa_activate_bcbio_nextgen || return 1
        if koopa_is_macos
        then
            koopa_macos_activate_google_cloud_sdk
        fi
        if [ "${KOOPA_ACTIVATE:-0}" -eq 1 ]
        then
            koopa_export_editor || return 1
            koopa_export_git || return 1
            koopa_export_gnupg || return 1
            koopa_export_history || return 1
            koopa_export_pager || return 1
            koopa_activate_color_mode || return 1
            koopa_activate_bat || return 1
            koopa_activate_dircolors || return 1
            koopa_activate_gcc_colors || return 1
            koopa_activate_lesspipe || return 1
            koopa_activate_secrets || return 1
            koopa_activate_ssh_key || return 1
            koopa_activate_tealdeer || return 1
            if koopa_is_macos
            then
                koopa_macos_activate_cli_colors || return 1
            fi
            shell="$(koopa_shell_name)"
            case "$shell" in
                'zsh')
                    alias conda='koopa_alias_conda'
                    ;;
                *)
                    koopa_activate_conda || return 1
                    ;;
            esac
            koopa_activate_aliases || return 1
            if ! koopa_is_subshell
            then
                koopa_activate_today_bucket || return 1
                # > koopa_activate_tmux_sessions || return 1
            fi
        fi
    fi
    koopa_activate_prefix "$(koopa_koopa_prefix)" || return 1
    koopa_add_to_path_start "$(koopa_scripts_private_prefix)/bin" || return 1
    if [ "${KOOPA_TEST:-0}" -eq 1 ]
    then
        koopa_duration_stop 'posix' || return 1
    fi
    return 0
}

# NOTE Don't pass "$@" here, will pass through in Bash header.
__koopa_posix_header
