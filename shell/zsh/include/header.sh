#!/usr/bin/env zsh
# koopa nolint=coreutils

# """
# Zsh header.
# @note Updated 2020-08-12.
# """

if [[ "$#" -gt 0 ]]
then
    pos=()
    for i in "$@"
    do
        case "$1" in
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
    unset -v pos
fi

[[ -n "${KOOPA_VERBOSE:-}" ]] && local verbose=1
[[ -z "${activate:-}" ]] && local activate=0
[[ -z "${checks:-}" ]] && local checks=1
[[ -z "${shopts:-}" ]] && local shopts=1
[[ -z "${verbose:-}" ]] && local verbose=0
[[ "$verbose" -eq 1 ]] && export KOOPA_VERBOSE=1
if [[ "$activate" -eq 1 ]]
then
    checks=0
    shopts=0
fi

# Customize optional shell behavior.
# These are not recommended to be set during koopa activation.
if [[ "$shopts" -eq 1 ]]
then
    [[ "$verbose" -eq 1 ]] && setopt xtrace # -x
    setopt errexit # -e
    setopt nounset # -u
    setopt pipefail
fi

# Requiring Zsh >= 5.
if [[ "$checks" -eq 1 ]]
then
    major_version="$(printf '%s\n' "${ZSH_VERSION}" | cut -d '.' -f 1)"
    if [[ ! "$major_version" -ge 5 ]]
    then
        printf '%s\n' 'Zsh >= 5 is required.' >&2
        exit 1
    fi
    unset -v major_version
fi

# Ensure koopa prefix is exported, if necessary.
if [[ -z "${KOOPA_PREFIX:-}" ]]
then
    KOOPA_PREFIX="$( \
        cd "$(dirname "$(realpath "${(%):-%N}")")/../../.." \
        >/dev/null 2>&1 \
        && pwd -P \
    )"
    export KOOPA_PREFIX
fi

# Source POSIX header (which includes functions).
# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/posix/include/header.sh"

# Source Zsh functions.
for file in "${KOOPA_PREFIX}/shell/zsh/functions/"*'.sh'
do
    # shellcheck source=/dev/null
    [[ -f "$file" ]] && source "$file"
done
unset -v file

# Disable user-defined aliases.
# Primarily intended to reset cp, mv, rf for use inside scripts.
[[ "$activate" -eq 0 ]] && unalias -a

unset -v activate checks shopts verbose
