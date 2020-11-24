#!/usr/bin/env zsh
# koopa nolint=coreutils

[[ -n "${KOOPA_VERBOSE:-}" ]] && local verbose=1

[[ -z "${activate:-}" ]] && local activate=0
[[ -z "${checks:-}" ]] && local checks=1
[[ -z "${shopts:-}" ]] && local shopts=1
[[ -z "${verbose:-}" ]] && local verbose=0

_koopa_zsh_header() { # {{{1
    # """
    # Zsh header.
    # @note Updated 2020-11-24.
    # """
    local activate checks file local major_version shopts verbose
    if [[ "${activate:-0}" -eq 1 ]]
    then
        checks=0
        shopts=0
    fi
    [[ "$verbose" -eq 1 ]] && export KOOPA_VERBOSE=1
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
    # shellcheck source=/dev/null
    source "${KOOPA_PREFIX}/shell/posix/include/header.sh"
    for file in "${KOOPA_PREFIX}/shell/zsh/functions/"*'.sh'
    do
        # shellcheck source=/dev/null
        [[ -f "$file" ]] && source "$file"
    done
}

_koopa_zsh_header "$@"
