#!/usr/bin/env zsh

__koopa_is_installed() {
    # """
    # Are all of the requested programs installed?
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
    # Print a string.
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
    # @note Updated 2024-09-19.
    # """
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
        '5.7' | '5.7.'* | \
        '5.8' | '5.8.'*)
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
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        setopt sourcetrace
        setopt verbose
        setopt xtrace
    fi
    if [[ "${bool['checks']}" -eq 1 ]]
    then
        setopt errexit
        setopt nounset
        setopt pipefail
    fi
    if [[ -z "${KOOPA_PREFIX:-}" ]]
    then
        bool['header_path']="${(%):-%N}"
        if [[ -L "${bool['header_path']}" ]]
        then
            bool[header_path]="$(__koopa_realpath "${bool['header_path']}")"
        fi
        KOOPA_PREFIX="$( \
            cd "$(dirname "${bool['header_path']}")/../../.." \
            >/dev/null 2>&1 \
            && pwd -P \
        )"
        export KOOPA_PREFIX
    fi
    source "${KOOPA_PREFIX:?}/lang/sh/include/header.sh"
    if [[ "${bool['test']}" -eq 1 ]]
    then
        _koopa_duration_start || return 1
    fi
    if [[ "${bool['activate']}" -eq 1 ]] && [[ "${bool['minimal']}" -eq 0 ]]
    then
        source "${KOOPA_PREFIX:?}/lang/zsh/functions/activate.sh"
        _koopa_activate_zsh_extras
    fi
    if [[ "${bool['test']}" -eq 1 ]]
    then
        _koopa_duration_stop 'zsh' || return 1
    fi
    return 0
}

__koopa_zsh_header "$@"
