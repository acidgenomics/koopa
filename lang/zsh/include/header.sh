#!/usr/bin/env zsh

__koopa_is_installed() {
    local cmd
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

__koopa_print() {
    local string
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

__koopa_realpath() {
    local arg string
    for arg in "$@"
    do
        string="$( \
            readlink -f "$arg" \
            2>/dev/null \
            || true \
        )"
        if [[ -z "$string" ]]
        then
            string="$( \
                perl -MCwd -le \
                    'print Cwd::abs_path shift' \
                    "$arg" \
                2>/dev/null \
                || true \
            )"
        fi
        if [[ -z "$string" ]]
        then
            string="$( \
                python3 -c \
                    "import os; print(os.path.realpath('${arg}'))" \
                2>/dev/null \
                || true \
            )"
        fi
        [[ -n "$string" ]] || return 1
        __koopa_print "$string"
    done
    return 0
}

__koopa_warn() {
    local string
    for string in "$@"
    do
        printf '%b\n' "$string" >&2
    done
    return 0
}

__koopa_activate_koopa() {
    if [[ "${KOOPA_MINIMAL:-0}" -eq 0 ]]
    then
        _koopa_activate_path_helper || return 1
    fi
    _koopa_activate_bootstrap || return 1
    _koopa_add_to_path_start "${KOOPA_PREFIX}/bin" || return 1
    _koopa_add_to_manpath_start "${KOOPA_PREFIX}/share/man" || return 1
    [[ "${KOOPA_MINIMAL:-0}" -eq 0 ]] || return 0
    _koopa_export_home || return 1
    _koopa_activate_profile_files || return 1
    _koopa_export_koopa_cpu_count || return 1
    _koopa_export_koopa_shell || return 1
    _koopa_activate_xdg || return 1
    _koopa_export_editor || return 1
    _koopa_export_gnupg || return 1
    _koopa_export_history || return 1
    _koopa_export_manpager || return 1
    _koopa_export_pager || return 1
    _koopa_activate_ca_certificates || return 1
    _koopa_activate_ruby || return 1
    _koopa_activate_julia || return 1
    _koopa_activate_python || return 1
    _koopa_activate_pipx || return 1
    _koopa_activate_color_mode || return 1
    _koopa_activate_alacritty || return 1
    _koopa_activate_bat || return 1
    _koopa_activate_bottom || return 1
    _koopa_activate_delta || return 1
    _koopa_activate_difftastic || return 1
    _koopa_activate_dircolors || return 1
    _koopa_activate_direnv || return 1
    _koopa_activate_docker || return 1
    _koopa_activate_fzf || return 0
    _koopa_activate_gcc_colors || return 1
    _koopa_activate_kitty || return 1
    _koopa_activate_lesspipe || return 1
    _koopa_activate_pyright || return 1
    _koopa_activate_ripgrep || return 1
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
        "$(_koopa_scripts_private_prefix)/bin" \
        "$(_koopa_xdg_local_home)/bin" \
        "${HOME:?}/.bin" \
        "${HOME:?}/bin" \
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
        _koopa_activate_today_bucket || return 1
        _koopa_check_multiple_users || return 1
    fi
    _koopa_activate_aliases || return 1
    return 0
}

__koopa_zsh_header() {
    case "${ZSH_VERSION:-}" in
        '1.'* | \
        '2.'* | \
        '3.'* | \
        '4.'* | \
        '5.0' | '5.0.'* | \
        '5.1' | '5.1.'* | \
        '5.2' | '5.2.'* | \
        '5.3' | '5.3.'* | \
        '5.4' | '5.4.'* | \
        '5.5' | '5.5.'* | \
        '5.6' | '5.6.'* | \
        '5.7' | '5.7.'*)
            return 0
            ;;
    esac
    local -A bool
    bool['activate']=0
    bool['checks']=1
    bool['minimal']=0
    bool['test']=0
    bool['verbose']=0
    [[ -n "${KOOPA_ACTIVATE:-}" ]] && bool['activate']="$KOOPA_ACTIVATE"
    [[ -n "${KOOPA_CHECKS:-}" ]] && bool['checks']="$KOOPA_CHECKS"
    [[ -n "${KOOPA_MINIMAL:-}" ]] && bool['minimal']="$KOOPA_MINIMAL"
    [[ -n "${KOOPA_TEST:-}" ]] && bool['test']="$KOOPA_TEST"
    [[ -n "${KOOPA_VERBOSE:-}" ]] && bool['verbose']="$KOOPA_VERBOSE"
    if [[ "${bool['activate']}" -eq 1 ]] && [[ "${bool['test']}" -eq 0 ]]
    then
        bool['checks']=0
    fi
    setopt alwaystoend
    setopt autocd
    setopt autopushd
    unsetopt banghist
    unsetopt beep
    unsetopt chasedots
    unsetopt chaselinks
    setopt combiningchars
    setopt completealiases
    setopt completeinword
    setopt extendedglob
    setopt extendedhistory
    unsetopt flowcontrol
    setopt histexpiredupsfirst
    setopt histignoredups
    setopt histignorespace
    setopt histverify
    setopt incappendhistory
    setopt interactivecomments
    setopt longlistjobs
    setopt markdirs
    setopt pushdignoredups
    setopt pushdminus
    setopt sharehistory
    unsetopt vi
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        setopt sourcetrace
        setopt verbose
        setopt xtrace
    else
        unsetopt sourcetrace
        unsetopt verbose
        unsetopt xtrace
    fi
    if [[ "${bool['checks']}" -eq 1 ]]
    then
        setopt errexit
        setopt nounset
        setopt pipefail
    else
        unsetopt errexit
        unsetopt nounset
        unsetopt pipefail
    fi
    bindkey '^[[3~' delete-char
    bindkey '^[[H' beginning-of-line
    bindkey '^[[F' end-of-line
    if [[ -z "${KOOPA_PREFIX:-}" ]]
    then
        bool['header_path']="${(%):-%N}"
        if [[ -L "${bool['header_path']}" ]]
        then
            bool['header_path']="$(__koopa_realpath "${bool['header_path']}")"
        fi
        KOOPA_PREFIX="$( \
            cd "$(dirname "${bool['header_path']}")/../../.." \
            >/dev/null 2>&1 \
            && pwd -P \
        )"
        export KOOPA_PREFIX
    fi
    if [[ -f "${KOOPA_PREFIX}/lang/zsh/functions.sh" ]]
    then
        source "${KOOPA_PREFIX}/lang/zsh/functions.sh"
    else
        local __kvar_file
        for __kvar_file in "${KOOPA_PREFIX}"/lang/zsh/functions/*/*.sh
        do
            source "$__kvar_file"
        done
        unset __kvar_file
    fi
    if [[ -z "${KOOPA_DEFAULT_SYSTEM_PATH:-}" ]]
    then
        export KOOPA_DEFAULT_SYSTEM_PATH="${PATH:-}"
    fi
    if [[ "${bool['test']}" -eq 1 ]]
    then
        _koopa_duration_start || return 1
    fi
    if [[ "${bool['activate']}" -eq 1 ]]
    then
        __koopa_activate_koopa || return 1
    fi
    if [[ "${bool['activate']}" -eq 1 ]] && [[ "${bool['minimal']}" -eq 0 ]]
    then
        _koopa_activate_zsh_extras
    fi
    if [[ "${bool['test']}" -eq 1 ]]
    then
        _koopa_duration_stop 'zsh' || return 1
    fi
    return 0
}

__koopa_zsh_header "$@"
