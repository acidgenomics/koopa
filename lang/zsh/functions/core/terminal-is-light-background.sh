#!/usr/bin/env zsh

_koopa_terminal_is_light_background() {
    [[ -t 0 ]] || return 1
    [[ -n "${TMUX:-}" || "${TERM:-}" == screen* || "${TERM:-}" == tmux* ]] && return 1
    [[ "${TERM_PROGRAM:-}" == 'vscode' ]] && return 1
    local __kvar_old_settings __kvar_response __kvar_rgb __kvar_r __kvar_g __kvar_b __kvar_luma
    __kvar_old_settings="$(stty -g 2>/dev/null)" || return 1
    # Restore tty settings on any exit path (normal return, error branch, or
    # signal) so an interrupted probe never leaves the terminal in raw mode.
    trap 'stty "$__kvar_old_settings" 2>/dev/null; trap - EXIT INT TERM' \
        EXIT INT TERM
    stty raw -echo min 0 time 2 2>/dev/null
    printf '\033]11;?\033\\' > /dev/tty
    __kvar_response="$(dd bs=64 count=1 2>/dev/null < /dev/tty)"
    stty "$__kvar_old_settings" 2>/dev/null
    case "$__kvar_response" in
        *'rgb:'*) ;;
        *) unset -v __kvar_old_settings __kvar_response; return 1 ;;
    esac
    __kvar_rgb="${__kvar_response#*rgb:}"
    __kvar_rgb="${__kvar_rgb%%\\*}"
    __kvar_rgb="${__kvar_rgb%%$'\033'*}"
    __kvar_r="$(printf '%d' "0x${__kvar_rgb%%/*}" 2>/dev/null)" || return 1
    __kvar_rgb="${__kvar_rgb#*/}"
    __kvar_g="$(printf '%d' "0x${__kvar_rgb%%/*}" 2>/dev/null)" || return 1
    __kvar_b="$(printf '%d' "0x${__kvar_rgb#*/}" 2>/dev/null)" || return 1
    [[ "$__kvar_r" -gt 255 ]] && __kvar_r=$((__kvar_r / 256))
    [[ "$__kvar_g" -gt 255 ]] && __kvar_g=$((__kvar_g / 256))
    [[ "$__kvar_b" -gt 255 ]] && __kvar_b=$((__kvar_b / 256))
    __kvar_luma=$(( (__kvar_r * 299 + __kvar_g * 587 + __kvar_b * 114) / 1000 ))
    unset -v __kvar_old_settings __kvar_response __kvar_rgb __kvar_r __kvar_g __kvar_b
    [[ "$__kvar_luma" -gt 128 ]]
    local __kvar_result=$?
    unset -v __kvar_luma
    return $__kvar_result
}
