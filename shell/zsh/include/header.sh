#!/usr/bin/env zsh

# """
# Zsh shared header script.
# @note Updated 2020-06-03.
# """

[[ -z "${activate:-}" ]] && activate=0
[[ -z "${checks:-}" ]] && checks=1
[[ -z "${shopts:-}" ]] && shopts=1

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
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    if [[ "${#pos[@]}" -gt 0 ]]
    then
        set -- "${pos[@]}"
    fi
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
    setopt errexit
    setopt nounset
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
# > for file in "${KOOPA_PREFIX}/shell/zsh/functions/"*".sh"
# > do
# >     # shellcheck source=/dev/null
# >     [[ -f "$file" ]] && source "$file"
# > done

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
    if printf '%s\n' "$0" | grep -q "/sbin/"
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
