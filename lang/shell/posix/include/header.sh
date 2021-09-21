#!/bin/sh

_koopa_posix_header() { # {{{1
    # """
    # POSIX shell header.
    # @note Updated 2021-09-21.
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
    _koopa_check_os || return 1
    _koopa_check_shell || return 1
    _koopa_activate_xdg || return 1
    _koopa_add_koopa_config_link \
        "$(_koopa_koopa_prefix)" 'home' \
        "$(_koopa_koopa_prefix)/activate" 'activate' \
        "$(_koopa_dotfiles_prefix)" 'dotfiles' \
        || return 1
    if [ "${KOOPA_MINIMAL:-0}" -eq 0 ]
    then
        _koopa_activate_homebrew || return 1
    fi
    _koopa_activate_make_paths || return 1
    _koopa_activate_pkg_config || return 1
    if [ "${KOOPA_MINIMAL:-0}" -eq 0 ]
    then
        # FIXME _koopa_activate_conda || return 1
        # FIXME _koopa_activate_emacs || return 1
        # FIXME _koopa_activate_go || return 1
        # FIXME _koopa_activate_node || return 1
        # FIXME _koopa_activate_openjdk || return 1
        # FIXME _koopa_activate_aspera || return 1
        # FIXME _koopa_activate_julia || return 1
        # FIXME _koopa_activate_nextflow || return 1
        # FIXME _koopa_activate_perl || return 1
        # FIXME _koopa_activate_python || return 1
        # FIXME _koopa_activate_ruby || return 1
        # FIXME _koopa_activate_rust || return 1
        if _koopa_is_linux
        then
            _koopa_activate_bcbio_nextgen || return 1
        elif _koopa_is_macos
        then
            _koopa_macos_activate_r || return 1
            _koopa_macos_activate_visual_studio_code || return 1
        fi
    fi
    _koopa_activate_koopa_paths || return 1
    _koopa_activate_local_paths || return 1
    if [ "${KOOPA_ACTIVATE:-0}" -eq 1 ]
    then
        _koopa_export_cpu_count || return 1
        _koopa_export_editor || return 1
        _koopa_export_git || return 1
        _koopa_export_gnupg || return 1
        _koopa_export_history || return 1
        _koopa_export_pager || return 1
        _koopa_export_tmpdir || return 1
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
            _koopa_activate_lesspipe || return 1
            _koopa_activate_secrets || return 1
            _koopa_activate_ssh_key || return 1
            _koopa_activate_tealdeer || return 1
            if ! _koopa_is_subshell
            then
                _koopa_activate_today_bucket || return 1
                _koopa_activate_tmux_sessions || return 1
            fi
        fi
    fi
    if [ "${KOOPA_TEST:-0}" -eq 1 ]
    then
        _koopa_duration_stop 'posix' || return 1
    fi
    return 0
}

_koopa_posix_header
