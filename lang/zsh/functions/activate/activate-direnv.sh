#!/usr/bin/env zsh

_koopa_activate_direnv() {
    # """
    # 'direnv export' evaluates the '.envrc' in the current directory, which
    # is arbitrary code (e.g. 'sleep 60') that can hang activation, and
    # re-runs on every 'cd' via the 'precmd'/'chpwd'/'PROMPT_COMMAND' hook
    # that 'direnv hook' installs, not just at shell startup. Both call sites
    # are bound with 'gtimeout' so a pathological '.envrc' can't wedge the
    # shell on startup OR on a later 'cd'. '_direnv_hook' is redefined (after
    # sourcing the cached hook) to reference 'KOOPA_PREFIX' /
    # 'KOOPA_DIRENV_TIMEOUT' directly rather than this function's locals,
    # since it fires from 'precmd_functions' / 'PROMPT_COMMAND' long after
    # this function has returned and its locals have gone out of scope.
    #
    # 'gtimeout' (without '-v') writes nothing of its own to stdout or
    # stderr; direnv's own "direnv: loading ..." notice on stderr still
    # passes through either way, since it's outside the '$(...)' capture.
    # On timeout, the captured stdout is empty, so the 'eval' is a no-op and
    # the shell continues without direnv's exports for that directory. Set
    # 'KOOPA_DIRENV_TIMEOUT=0' to disable the bound entirely (matches legacy
    # behavior).
    # """
    local direnv
    direnv="${KOOPA_PREFIX:?}/bin/direnv"
    if [[ ! -x "$direnv" ]]
    then
        return 0
    fi
    local shell
    shell="${KOOPA_SHELL##*/}"
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    unset -v \
        DIRENV_DIFF \
        DIRENV_DIR \
        DIRENV_FILE \
        DIRENV_WATCHES
    case "$shell" in
        'bash' | \
        'zsh')
            local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/direnv-hook-${shell}.sh"
            if [[ ! -f "$cache_file" ]] || [[ "$direnv" -nt "$cache_file" ]]; then
                mkdir -p "${cache_file%/*}"
                "$direnv" hook "$shell" > "$cache_file"
            fi
            source "$cache_file"
            if [[ "$shell" == 'bash' ]]
            then
                _direnv_hook() {
                    local previous_exit_status=$?
                    trap -- '' SIGINT
                    local hook_timeout="${KOOPA_DIRENV_TIMEOUT:-5}"
                    local hook_gtimeout="${KOOPA_PREFIX:?}/bin/gtimeout"
                    if [[ "$hook_timeout" -gt 0 ]] && [[ -x "$hook_gtimeout" ]]
                    then
                        eval "$("$hook_gtimeout" "$hook_timeout" "${KOOPA_PREFIX:?}/bin/direnv" export bash)"
                    else
                        eval "$("${KOOPA_PREFIX:?}/bin/direnv" export bash)"
                    fi
                    trap - SIGINT
                    return "$previous_exit_status"
                }
            else
                _direnv_hook() {
                    trap -- '' SIGINT
                    local hook_timeout="${KOOPA_DIRENV_TIMEOUT:-5}"
                    local hook_gtimeout="${KOOPA_PREFIX:?}/bin/gtimeout"
                    if [[ "$hook_timeout" -gt 0 ]] && [[ -x "$hook_gtimeout" ]]
                    then
                        eval "$("$hook_gtimeout" "$hook_timeout" "${KOOPA_PREFIX:?}/bin/direnv" export zsh)"
                    else
                        eval "$("${KOOPA_PREFIX:?}/bin/direnv" export zsh)"
                    fi
                    trap - SIGINT
                }
            fi
            local timeout="${KOOPA_DIRENV_TIMEOUT:-5}"
            local gtimeout="${KOOPA_PREFIX:?}/bin/gtimeout"
            if [[ "$timeout" -gt 0 ]] && [[ -x "$gtimeout" ]]
            then
                eval "$("$gtimeout" "$timeout" "$direnv" export "$shell")"
            else
                eval "$("$direnv" export "$shell")"
            fi
            ;;
    esac
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
