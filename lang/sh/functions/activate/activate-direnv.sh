#!/bin/sh

_koopa_activate_direnv() {
    # """
    # Activate direnv.
    # @note Updated 2026-07-29.
    #
    # 'direnv export' evaluates the '.envrc' in the current directory, which
    # is arbitrary code (e.g. 'sleep 60') that can hang activation, and
    # re-runs on every 'cd' via the 'precmd'/'chpwd'/'PROMPT_COMMAND' hook
    # that 'direnv hook' installs, not just at shell startup. Both call sites
    # are bound with 'gtimeout' so a pathological '.envrc' can't wedge the
    # shell on startup OR on a later 'cd'. The hook body must reference
    # 'KOOPA_PREFIX' / 'KOOPA_DIRENV_TIMEOUT' directly rather than local vars
    # from this function, since '_direnv_hook' fires from 'PROMPT_COMMAND' /
    # 'precmd_functions' long after this function has returned and its
    # locals have gone out of scope.
    #
    # 'gtimeout' (without '-v') writes nothing of its own to stdout or
    # stderr; direnv's own "direnv: loading ..." notice on stderr still
    # passes through either way, since it's outside the '$(...)' capture.
    # On timeout, the captured stdout is empty, so the 'eval' is a no-op and
    # the shell continues without direnv's exports for that directory. Set
    # 'KOOPA_DIRENV_TIMEOUT=0' to disable the bound entirely (matches legacy
    # behavior).
    #
    # @seealso
    # - https://direnv.net/docs/hook.html
    # """
    __kvar_direnv="${KOOPA_PREFIX:?}/bin/direnv"
    if [ ! -x "$__kvar_direnv" ]
    then
        unset -v __kvar_direnv
        return 0
    fi
    __kvar_shell="${KOOPA_SHELL##*/}"
    __kvar_nounset=0
    case "$-" in *u*) __kvar_nounset=1 ;; esac
    [ "$__kvar_nounset" -eq 1 ] && set +u
    # Harden against stale, transient values inherited from parent app process.
    unset -v \
        DIRENV_DIFF \
        DIRENV_DIR \
        DIRENV_FILE \
        DIRENV_WATCHES
    __kvar_timeout="${KOOPA_DIRENV_TIMEOUT:-5}"
    __kvar_gtimeout="${KOOPA_PREFIX:?}/bin/gtimeout"
    case "$__kvar_shell" in
        'bash')
            eval "$("$__kvar_direnv" hook bash)"
            # shellcheck disable=SC2317
            _direnv_hook() {
                __kvar_hook_status=$?
                trap -- '' SIGINT
                __kvar_hook_timeout="${KOOPA_DIRENV_TIMEOUT:-5}"
                __kvar_hook_gtimeout="${KOOPA_PREFIX:?}/bin/gtimeout"
                if [ "$__kvar_hook_timeout" -gt 0 ] && [ -x "$__kvar_hook_gtimeout" ]
                then
                    eval "$("$__kvar_hook_gtimeout" "$__kvar_hook_timeout" "${KOOPA_PREFIX:?}/bin/direnv" export bash)"
                else
                    eval "$("${KOOPA_PREFIX:?}/bin/direnv" export bash)"
                fi
                trap - SIGINT
                unset -v __kvar_hook_gtimeout __kvar_hook_timeout
                return "$__kvar_hook_status"
            }
            ;;
        'zsh')
            eval "$("$__kvar_direnv" hook zsh)"
            # shellcheck disable=SC2317
            _direnv_hook() {
                trap -- '' SIGINT
                __kvar_hook_timeout="${KOOPA_DIRENV_TIMEOUT:-5}"
                __kvar_hook_gtimeout="${KOOPA_PREFIX:?}/bin/gtimeout"
                if [ "$__kvar_hook_timeout" -gt 0 ] && [ -x "$__kvar_hook_gtimeout" ]
                then
                    eval "$("$__kvar_hook_gtimeout" "$__kvar_hook_timeout" "${KOOPA_PREFIX:?}/bin/direnv" export zsh)"
                else
                    eval "$("${KOOPA_PREFIX:?}/bin/direnv" export zsh)"
                fi
                trap - SIGINT
                unset -v __kvar_hook_gtimeout __kvar_hook_timeout
            }
            ;;
    esac
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            if [ "$__kvar_timeout" -gt 0 ] && [ -x "$__kvar_gtimeout" ]
            then
                eval "$("$__kvar_gtimeout" "$__kvar_timeout" "$__kvar_direnv" export "$__kvar_shell")"
            else
                eval "$("$__kvar_direnv" export "$__kvar_shell")"
            fi
            ;;
    esac
    [ "$__kvar_nounset" -eq 1 ] && set -u
    unset -v \
        __kvar_direnv \
        __kvar_gtimeout \
        __kvar_nounset \
        __kvar_shell \
        __kvar_timeout
    return 0
}
