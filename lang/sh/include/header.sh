#!/bin/sh

__koopa_posix_header() {
    # """
    # POSIX shell header.
    # @note Updated 2024-06-27.
    # """
    if [ -z "${KOOPA_PREFIX:-}" ]
    then
        printf '%s\n' "ERROR: Required 'KOOPA_PREFIX' is unset." >&2
        return 1
    fi
    if [ -f "${KOOPA_PREFIX}/lang/sh/functions.sh" ]
    then
        # shellcheck source=/dev/null
        . "${KOOPA_PREFIX}/lang/sh/functions.sh"
    else
        for __kvar_file in \
            "${KOOPA_PREFIX}/lang/sh/functions/"*'/'*'.sh'
        do
            # shellcheck source=/dev/null
            . "$__kvar_file"
        done
        unset -v __kvar_file
    fi
    if [ "${KOOPA_TEST:-0}" -eq 1 ]
    then
        _koopa_duration_start || return 1
    fi
    if [ -z "${KOOPA_DEFAULT_SYSTEM_PATH:-}" ]
    then
        export KOOPA_DEFAULT_SYSTEM_PATH="${PATH:-}"
    fi
    if [ "${KOOPA_ACTIVATE:-0}" -eq 1 ]
    then
        __koopa_activate_koopa || return 1
    else
        unalias -a
    fi
    if [ "${KOOPA_TEST:-0}" -eq 1 ]
    then
        _koopa_duration_stop 'posix' || return 1
    fi
    return 0
}

__koopa_activate_koopa() {
    # """
    # Activate koopa.
    # @note Updated 2024-07-18.
    # """
    if [ "${KOOPA_MINIMAL:-0}" -eq 0 ]
    then
        _koopa_activate_path_helper || return 1
    fi
    _koopa_add_to_path_start "$(_koopa_bootstrap_prefix)/bin" || return 1
    _koopa_add_to_path_start "${KOOPA_PREFIX}/bin" || return 1
    _koopa_add_to_manpath_start "${KOOPA_PREFIX}/share/man" || return 1
    [ "${KOOPA_MINIMAL:-0}" -eq 0 ] || return 0
    _koopa_export_home || return 1
    _koopa_activate_profile_files || return 1
    _koopa_export_koopa_cpu_count || return 1
    _koopa_export_koopa_shell || return 1
    _koopa_activate_xdg || return 1
    _koopa_export_editor || return 1
    _koopa_export_gnupg || return 1
    _koopa_export_history || return 1
    _koopa_export_pager || return 1
    _koopa_activate_ca_certificates || return 1
    _koopa_activate_ruby || return 1
    _koopa_activate_julia || return 1
    _koopa_activate_python || return 1
    _koopa_activate_pipx || return 1
    _koopa_activate_bcbio_nextgen || return 1
    _koopa_activate_color_mode || return 1
    _koopa_activate_alacritty || return 1
    _koopa_activate_bat || return 1
    _koopa_activate_bottom || return 1
    _koopa_activate_delta || return 1
    _koopa_activate_difftastic || return 1
    _koopa_activate_dircolors || return 1
    _koopa_activate_docker || return 1
    _koopa_activate_fzf || return 0
    _koopa_activate_gcc_colors || return 1
    _koopa_activate_kitty || return 1
    _koopa_activate_lesspipe || return 1
    _koopa_activate_ripgrep || return 1
    # This is problematic for keys with a passkey, so disabling at the moment.
    # > _koopa_activate_ssh_key || return 1
    _koopa_activate_tealdeer || return 1
    if _koopa_is_macos
    then
        _koopa_macos_activate_cli_colors || return 1
        _koopa_macos_activate_egnyte || return 1
        _koopa_macos_activate_homebrew || return 1
    fi
    _koopa_activate_micromamba || return 1
    _koopa_add_to_path_start \
        '/usr/local/sbin' \
        '/usr/local/bin' \
        "$(_koopa_xdg_local_home)/bin" \
        "$(_koopa_scripts_private_prefix)/bin" \
        || return 1
    _koopa_add_to_manpath_start \
        '/usr/local/man' \
        '/usr/local/share/man' \
        || return 1
    _koopa_add_to_manpath_end \
        '/usr/share/man' \
        || return 1
    if ! _koopa_is_subshell
    then
        _koopa_add_config_link \
            "${KOOPA_PREFIX}/activate" 'activate' \
            || return 1
        _koopa_activate_today_bucket || return 1
        _koopa_check_multiple_users || return 1
    fi
    _koopa_activate_aliases || return 1
    return 0
}

# NOTE Don't pass "$@" here, will pass through in Bash header.
__koopa_posix_header
