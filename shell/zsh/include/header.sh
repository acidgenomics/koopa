#!/usr/bin/env zsh

_koopa_zsh_header() { # {{{1
    # """
    # Zsh header.
    # @note Updated 2020-11-24.
    # """
    local activate checks file local major_version shopts verbose
    activate=0
    checks=0
    shopts=0
    verbose=0
    [[ -n "${KOOPA_ACTIVATE:-}" ]] && activate=1
    [[ -n "${KOOPA_VERBOSE:-}" ]] && verbose=1
    if [[ "$activate" -eq 0 ]]
    then
        checks=1
        shopts=1
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
            printf '%s\n' 'Zsh >= 5 is required.' >&2
            exit 1
        fi
    fi
    if [[ -z "${KOOPA_PREFIX:-}" ]]
    then
        KOOPA_PREFIX="$( \
            cd "$(dirname "$(realpath "${(%):-%N}")")/../../.." \
            >/dev/null 2>&1 \
            && pwd -P \
        )"
        export KOOPA_PREFIX
    fi
    source "${KOOPA_PREFIX}/shell/posix/include/header.sh"
    source "${KOOPA_PREFIX}/shell/zsh/functions/activate.sh"
}

_koopa_zsh_header "$@"
