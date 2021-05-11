#!/usr/bin/env zsh
# koopa nolint=coreutils

__koopa_is_installed() { # {{{1
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

__koopa_is_linux() { # {{{1
    # """
    # is the operating system linux?
    # @note updated 2021-05-07.
    # """
    [[ "$(uname -s)" = 'linux' ]]
}

__koopa_is_macos() { # {{{1
    # """
    # is the operating system macos?
    # @note updated 2021-05-07.
    # """
    [[ "$(uname -s)" = 'darwin' ]]
}

__koopa_print() { # {{{1
    # """
    # print a string.
    # @note updated 2021-05-07.
    # """
    local string
    [[ "$#" -gt 0 ]] || return 1
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

__koopa_realpath() { # {{{1
    # """
    # resolve file path.
    # @note updated 2021-05-11.
    # """
    local arg bn dn x
    [[ "$#" -gt 0 ]] || return 1
    if __koopa_is_installed realpath
    then
        x="$(realpath "$@")"
    elif __koopa_is_installed grealpath
    then
        x="$(grealpath "$@")"
    elif __koopa_is_macos
    then
        for arg in "$@"
        do
            bn="$(basename "$arg")"
            dn="$(cd "$(dirname "$arg")" || return 1; pwd -p)"
            x="${dn}/${bn}"
            __koopa_print "$x"
        done
        return 0
    else
        x="$(readlink -f "$@")"
    fi
    [[ -n "$x" ]] || return 1
    __koopa_print "$x"
    return 0
}

__koopa_zsh_header() { # {{{1
    # """
    # Zsh header.
    # @note Updated 2021-05-11.
    # """
    local activate checks file header_path local major_version shopts verbose
    activate=0
    checks=1
    shopts=1
    verbose=0
    [[ -n "${KOOPA_ACTIVATE:-}" ]] && activate="$KOOPA_ACTIVATE"
    [[ -n "${KOOPA_CHECKS:-}" ]] && checks="$KOOPA_CHECKS"
    [[ -n "${KOOPA_VERBOSE:-}" ]] && verbose="$KOOPA_VERBOSE"
    if [[ "$activate" -eq 1 ]]
    then
        checks=0
        shopts=0
        export KOOPA_ACTIVATE=1
    fi
    if [[ "$shopts" -eq 1 ]]
    then
        [[ "$verbose" -eq 1 ]] && setopt xtrace # -x
        setopt errexit # -e
        setopt nounset # -u
        setopt pipefail
    fi
    if [[ "$checks" -eq 1 ]]
    then
        major_version="$(printf '%s\n' "${ZSH_VERSION:?}" | cut -d '.' -f 1)"
        if [[ ! "$major_version" -ge 5 ]]
        then
            printf '%s\n' 'ERROR: Koopa requires Zsh >= 5.' >&2
            printf '%s: %s\n' 'ZSH_VERSION' "$ZSH_VERSION" >&2
            return 1
        fi
    fi
    if [[ -z "${KOOPA_PREFIX:-}" ]]
    then
        header_path="${(%):-%N}"
        if [[ -L "$header_path" ]]
        then
            header_path="$(__koopa_realpath "$header_path")"
        fi
        KOOPA_PREFIX="$( \
            cd "$(dirname "$header_path")/../../../.." \
            >/dev/null 2>&1 \
            && pwd -P \
        )"
        export KOOPA_PREFIX
    fi
    source "${KOOPA_PREFIX}/lang/shell/posix/include/header.sh"
    if [[ "$activate" -eq 1 ]]
    then
        source "${KOOPA_PREFIX}/lang/shell/zsh/functions/activate.sh"
    fi
    return 0
}

__koopa_zsh_header "$@"
