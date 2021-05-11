#!/usr/bin/env zsh
# koopa nolint=coreutils

_koopa_zsh_header() { # {{{1
    # """
    # Zsh header.
    # @note Updated 2021-05-07.
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
            header_path="$(_koopa_realpath "$header_path")"
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

_koopa_realpath() { # {{{1
    if [[ "$(uname -s)" == 'Darwin' ]]
    then
        perl -MCwd -e 'print Cwd::abs_path shift' "$1"
    else
        readlink -f "$@"
    fi
}

_koopa_zsh_header "$@"
