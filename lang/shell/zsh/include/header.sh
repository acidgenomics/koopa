#!/usr/bin/env zsh
# koopa nolint=coreutils

koopa:::is_installed() { # {{{1
    # """
    # Are all of the requested programs installed?
    # @note Updated 2021-05-07.
    # """
    local cmd
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

koopa:::is_macos() { # {{{1
    # """
    # Is the operating system macOS?
    # @note Updated 2021-05-07.
    # """
    [ "$(uname -s)" = 'Darwin' ]
}

koopa:::print() { # {{{1
    # """
    # Print a string.
    # @note Updated 2021-05-07.
    # """
    local string
    [ "$#" -gt 0 ] || return 1
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

koopa:::realpath() { # {{{1
    # """
    # Resolve file path.
    # @note Updated 2021-05-11.
    # """
    local arg bn dn x
    [ "$#" -gt 0 ] || return 1
    if koopa:::is_installed realpath
    then
        x="$(realpath "$@")"
    elif koopa:::is_installed grealpath
    then
        x="$(grealpath "$@")"
    elif koopa:::is_macos
    then
        for arg in "$@"
        do
            bn="$(basename "$arg")"
            dn="$(cd "$(dirname "$arg")" || return 1; pwd -P)"
            x="${dn}/${bn}"
            koopa:::print "$x"
        done
        return 0
    else
        x="$(readlink -f "$@")"
    fi
    [ -n "$x" ] || return 1
    koopa:::print "$x"
    return 0
}

koopa:::zsh_header() { # {{{1
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
            header_path="$(koopa:::realpath "$header_path")"
        fi
        KOOPA_PREFIX="$( \
            cd "$(dirname "$header_path")/../../../.." \
            >/dev/null 2>&1 \
            && pwd -P \
        )"
        export KOOPA_PREFIX
    fi
    source "${KOOPA_PREFIX}/lang/shell/posix/include/header.sh"
    source "${KOOPA_PREFIX}/lang/shell/zsh/functions/activate.sh"
    return 0
}

koopa:::zsh_header "$@"
