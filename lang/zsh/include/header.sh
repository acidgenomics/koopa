#!/usr/bin/env zsh

__koopa_is_installed() {
    # """
    # are all of the requested programs installed?
    # @note updated 2021-05-07.
    # """
    local cmd
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

__koopa_print() {
    # """
    # print a string.
    # @note updated 2021-05-07.
    # """
    local string
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

__koopa_realpath() {
    # """
    # Resolve file path.
    # @note Updated 2023-03-23.
    # """
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
    # """
    # Print a warning message to the console.
    # @note Updated 2021-05-14.
    # """
    local string
    for string in "$@"
    do
        printf '%b\n' "$string" >&2
    done
    return 0
}

__koopa_zsh_header() {
    # """
    # Zsh header.
    # @note Updated 2023-03-09.
    # """
    local dict
    [[ "$#" -eq 0 ]] || return 1
    declare -A dict=(
        [activate]=0
        [checks]=1
        [minimal]=0
        [test]=0
        [verbose]=0
    )
    [[ -n "${KOOPA_ACTIVATE:-}" ]] && dict[activate]="$KOOPA_ACTIVATE"
    [[ -n "${KOOPA_CHECKS:-}" ]] && dict[checks]="$KOOPA_CHECKS"
    [[ -n "${KOOPA_MINIMAL:-}" ]] && dict[minimal]="$KOOPA_MINIMAL"
    [[ -n "${KOOPA_TEST:-}" ]] && dict[test]="$KOOPA_TEST"
    [[ -n "${KOOPA_VERBOSE:-}" ]] && dict[verbose]="$KOOPA_VERBOSE"
    if [[ "${dict[activate]}" -eq 1 ]] && [[ "${dict[test]}" -eq 0 ]]
    then
        dict[checks]=0
    fi
    if [[ "${dict[verbose]}" -eq 1 ]]
    then
        setopt sourcetrace
        setopt verbose
        setopt xtrace
    fi
    if [[ "${dict[checks]}" -eq 1 ]]
    then
        setopt errexit
        setopt nounset
        setopt pipefail
    fi
    if [[ -z "${KOOPA_PREFIX:-}" ]]
    then
        dict[header_path]="${(%):-%N}"
        if [[ -L "${dict[header_path]}" ]]
        then
            dict[header_path]="$(__koopa_realpath "${dict[header_path]}")"
        fi
        KOOPA_PREFIX="$( \
            cd "$(dirname "${dict[header_path]}")/../../.." \
            >/dev/null 2>&1 \
            && pwd -P \
        )"
        export KOOPA_PREFIX
    fi
    source "${KOOPA_PREFIX:?}/lang/sh/include/header.sh"
    if [[ "${KOOPA_TEST:-0}" -eq 1 ]]
    then
        _koopa_duration_start || return 1
    fi
    if [[ "${dict[activate]}" -eq 1 ]] && [[ "${dict[minimal]}" -eq 0 ]]
    then
        source "${KOOPA_PREFIX:?}/lang/zsh/functions/activate.sh"
        _koopa_activate_zsh_extras
    fi
    if [[ "${dict[test]}" -eq 1 ]]
    then
        _koopa_duration_stop 'zsh' || return 1
    fi
    return 0
}

__koopa_zsh_header "$@"
