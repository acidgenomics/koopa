#!/usr/bin/env zsh

_koopa_zsh_header() { # {{{1
    # """
    # Zsh header.
    # @note Updated 2020-06-30.
    # """
    local file major_version pos
    [[ -n "${KOOPA_VERBOSE:-}" ]] && local verbose=1
    [[ -z "${activate:-}" ]] && local activate=0
    [[ -z "${checks:-}" ]] && local checks=1
    [[ -z "${shopts:-}" ]] && local shopts=1
    [[ -z "${verbose:-}" ]] && local verbose=0
    if [[ "$#" -gt 0 ]]
    then
        pos=()
        for i in "$@"
        do
            case "$1" in
                --activate)
                    activate=1
                    shift 1
                    ;;
                --no-header-checks)
                    checks=0
                    shift 1
                    ;;
                --no-set-opts)
                    shopts=0
                    shift 1
                    ;;
                --verbose)
                    verbose=1
                    shift 1
                    ;;
                *)
                    pos+=("$1")
                    shift 1
                    ;;
            esac
        done
        [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    fi
    if [[ "$activate" -eq 1 ]]
    then
        checks=0
        shopts=0
    fi
    # Customize optional shell behavior.
    # These are not recommended to be set during koopa activation.
    #
    # See also:
    # > setopt
    # - https://scriptingosx.com/2019/06/moving-to-zsh-part-3-shell-options/
    if [[ "$shopts" -eq 1 ]]
    then
        [[ "$verbose" -eq 1 ]] && setopt xtrace                             # -x
        setopt errexit                                                      # -e
        setopt nounset                                                      # -u
        setopt pipefail
    fi
    # Requiring Zsh >= 5 for exported scripts.
    if [[ "$checks" -eq 1 ]]
    then
        major_version="$(printf '%s\n' "${ZSH_VERSION}" | cut -d '.' -f 1)"
        if [[ ! "$major_version" -ge 5 ]]
        then
            >&2 printf '%s\n' 'Zsh >= 5 is required.'
            exit 1
        fi
    fi
    # Ensure koopa prefix is exported, if necessary.
    if [[ -z "${KOOPA_PREFIX:-}" ]]
    then
        KOOPA_PREFIX="$(cd "$(dirname "${(%):-%N}")/../../.." \
            >/dev/null 2>&1 && pwd -P)"
        export KOOPA_PREFIX
    fi
    # Source POSIX header (which includes functions).
    # shellcheck source=/dev/null
    source "${KOOPA_PREFIX}/shell/posix/include/header.sh"
    # Source Zsh functions.
    for file in "${KOOPA_PREFIX}/shell/zsh/functions/"*".sh"
    do
        # shellcheck source=/dev/null
        [[ -f "$file" ]] && source "$file"
    done
    # Source Bash and Zsh shared functions.
    for file in "${KOOPA_PREFIX}/shell/bash-and-zsh/functions/"*".sh"
    do
        # shellcheck source=/dev/null
        [[ -f "$file" ]] && source "$file"
    done
    _koopa_help "$@"
    # Require sudo permission to run 'sbin/' scripts.
    if [[ "$checks" -eq 1 ]]
    then
        if _koopa_str_match "$0" "/sbin"
        then
            _koopa_assert_has_sudo
        fi
    fi
    # Disable user-defined aliases.
    # Primarily intended to reset cp, mv, rf for use inside scripts.
    if [[ "$activate" -eq 0 ]]
    then
        unalias -a
    fi
    unset -v activate checks shopts verbose
    return 0
}

_koopa_zsh_header "$@"
