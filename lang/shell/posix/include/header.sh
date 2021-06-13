#!/bin/sh

_koopa_posix_header() { # {{{1
    # """
    # POSIX shell header.
    # @note Updated 2021-06-04.
    # """
    local file
    [ "$#" -eq 0 ] || return 1
    unset -v KOOPA_SHELL KOOPA_SUBSHELL
    if [ -z "${KOOPA_PREFIX:-}" ]
    then
        printf '%s\n' "ERROR: Required 'KOOPA_PREFIX' is unset." >&2
        return 1
    fi
    # Source POSIX functions.
    for file in "${KOOPA_PREFIX}/lang/shell/posix/functions/"*'.sh'
    do
        # shellcheck source=/dev/null
        [ -f "$file" ] && . "$file"
    done
    if [ "${KOOPA_TEST:-0}" -eq 1 ]
    then
        _koopa_duration_start || return 1
    fi
    _koopa_check_os || return 1
    _koopa_check_shell || return 1
    _koopa_activate_xdg || return 1
    _koopa_add_config_link \
        "$(_koopa_koopa_prefix)" 'home' \
        || return 1
    _koopa_add_config_link \
        "$(_koopa_koopa_prefix)/activate" 'activate' \
        || return 1
    _koopa_add_config_link \
        "$(_koopa_dotfiles_prefix)" 'dotfiles' \
        || return 1
    _koopa_activate_standard_paths || return 1
    _koopa_activate_pkg_config || return 1
    if [ "${KOOPA_ACTIVATE:-0}" -eq 1 ]
    then
        _koopa_export_cpu_count || return 1
        _koopa_export_editor || return 1
        _koopa_export_git || return 1
        _koopa_export_gnupg || return 1
        _koopa_export_history || return 1
        _koopa_export_pager || return 1
        # FIXME Merge this in with Python activation.
        _koopa_export_python || return 1
        _koopa_export_tmpdir || return 1
        if [ "${KOOPA_MINIMAL:-0}" -eq 0 ]
        then
            if _koopa_is_linux
            then
                _koopa_activate_bcbio_nextgen || return 1
            elif _koopa_is_macos
            then
                # FIXME Consolidate this with Python activation step below.
                _koopa_macos_activate_python || return 1
                _koopa_macos_activate_visual_studio_code || return 1
            fi
            _koopa_activate_homebrew || return 1
            _koopa_activate_emacs || return 1
            _koopa_activate_go || return 1
            _koopa_activate_node || return 1
            _koopa_activate_openjdk || return 1
            _koopa_activate_aspera || return 1
            _koopa_activate_nextflow || return 1
            _koopa_activate_ruby || return 1
            _koopa_activate_rust || return 1
            _koopa_activate_perl || return 1
            # FIXME Need to combine the Python steps here...
            _koopa_activate_python_packages || return 1
            _koopa_activate_python_startup || return 1
        fi
        if [ "${KOOPA_MINIMAL:-0}" -eq 0 ] && _koopa_is_interactive
        then
            if _koopa_is_macos
            then
                _koopa_macos_activate_color_mode || return 1
                _koopa_macos_activate_cli_colors || return 1
                _koopa_macos_activate_iterm || return 1
            fi
            _koopa_activate_aliases || return 1
            _koopa_activate_dircolors || return 1
            _koopa_activate_gcc_colors || return 1
            _koopa_activate_gnu_aliases || return 1
            _koopa_activate_secrets || return 1
            _koopa_activate_ssh_key || return 1
            if ! _koopa_is_subshell
            then
                _koopa_activate_today_bucket || return 1
                _koopa_activate_tmux_sessions || return 1
            fi
        fi
    fi
    _koopa_activate_koopa_paths || return 1
    _koopa_activate_local_paths || return 1
    if [ "${KOOPA_TEST:-0}" -eq 1 ]
    then
        _koopa_duration_stop 'posix' || return 1
    fi
    return 0
}

_koopa_posix_header
