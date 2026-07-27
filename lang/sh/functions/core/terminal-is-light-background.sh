#!/bin/sh

_koopa_terminal_is_light_background() {
    # """
    # Query terminal background color via OSC 11 escape sequence.
    # Returns 0 (true) if background is light, 1 if dark or unsupported.
    # @note Updated 2026-05-30.
    #
    # Supported terminals: Ghostty, iTerm2, Kitty, WezTerm, Alacritty,
    # foot, Windows Terminal.
    # Not supported: tmux/screen (intercept escape sequences),
    # VS Code/Posit Workbench (xterm.js leaks ST as visible characters).
    # """
    [ -t 0 ] || return 1
    case "${TERM:-}" in screen*|tmux*) return 1 ;; esac
    [ -n "${TMUX:-}" ] && return 1
    [ "${TERM_PROGRAM:-}" = 'vscode' ] && return 1
    local __kvar_old_settings __kvar_response __kvar_rgb __kvar_r __kvar_g __kvar_b __kvar_luma __kvar_result
    __kvar_old_settings="$(stty -g 2>/dev/null)" || return 1
    # Restore tty settings on any exit path (signal or early return) so an
    # interrupted probe never leaves the terminal in raw mode.  POSIX sh has
    # no RETURN pseudo-signal, so we also restore explicitly before every
    # early return below.
    trap 'stty "$__kvar_old_settings" 2>/dev/null; trap - INT TERM' INT TERM
    stty raw -echo min 0 time 2 2>/dev/null
    printf '\033]11;?\033\\' > /dev/tty
    __kvar_response="$(dd bs=64 count=1 2>/dev/null < /dev/tty)"
    stty "$__kvar_old_settings" 2>/dev/null
    trap - INT TERM
    case "$__kvar_response" in
        *'rgb:'*) ;;
        *) unset -v __kvar_old_settings __kvar_response; return 1 ;;
    esac
    __kvar_rgb="${__kvar_response#*rgb:}"
    __kvar_rgb="${__kvar_rgb%%\\*}"
    __kvar_rgb="${__kvar_rgb%%$(printf '\033')*}"
    __kvar_r="$(printf '%d' "0x${__kvar_rgb%%/*}" 2>/dev/null)" || return 1
    __kvar_rgb="${__kvar_rgb#*/}"
    __kvar_g="$(printf '%d' "0x${__kvar_rgb%%/*}" 2>/dev/null)" || return 1
    __kvar_b="$(printf '%d' "0x${__kvar_rgb#*/}" 2>/dev/null)" || return 1
    [ "$__kvar_r" -gt 255 ] && __kvar_r=$((__kvar_r / 256))
    [ "$__kvar_g" -gt 255 ] && __kvar_g=$((__kvar_g / 256))
    [ "$__kvar_b" -gt 255 ] && __kvar_b=$((__kvar_b / 256))
    __kvar_luma=$(( (__kvar_r * 299 + __kvar_g * 587 + __kvar_b * 114) / 1000 ))
    unset -v __kvar_old_settings __kvar_response __kvar_rgb __kvar_r __kvar_g __kvar_b
    [ "$__kvar_luma" -gt 128 ]
    __kvar_result=$?
    unset -v __kvar_luma
    return $__kvar_result
}
