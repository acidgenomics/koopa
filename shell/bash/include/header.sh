#!/usr/bin/env bash

# """
# Bash shared header script.
# @note Updated 2020-05-07.
# """

[[ -z "${activate:-}" ]] && activate=0
[[ -z "${checks:-}" ]] && checks=1
[[ -z "${shopts:-}" ]] && shopts=1

if [[ "$#" -gt 0 ]]
then
    pos=()
    while (("$#"))
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
                set -o xtrace  # -x
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
# > set --help
# > shopt
if [[ "$shopts" -eq 1 ]]
then
    # > set -o noglob   # -f
    set -o errexit      # -e
    set -o errtrace     # -E
    set -o nounset      # -u
    set -o pipefail
fi

# Requiring Bash >= 4 for exported scripts.
# macOS ships with an ancient version of Bash, due to licensing.
# If we're performing a clean install and loading up Homebrew, this step will
# fail unless we skip checks.
if [[ "$checks" -eq 1 ]]
then
    major_version="$(printf '%s\n' "${BASH_VERSION}" | cut -d '.' -f 1)"
    if [[ ! "$major_version" -ge 4 ]]
    then
        >&2 printf '%s\n' 'ERROR: Bash >= 4 is required.'
        >&2 printf 'BASH_VERSION: %s\n' "$BASH_VERSION"
        exit 1
    fi
    # Check that user's Bash has mapfile builtin defined.
    # We use this a lot to handle arrays.
    if [[ $(type -t mapfile) != "builtin" ]]
    then
        >&2 printf '%s\n' 'ERROR: Bash is missing mapfile.'
        exit 1
    fi
fi

# Ensure koopa prefix is exported, if necessary.
if [[ -z "${KOOPA_PREFIX:-}" ]]
then
    KOOPA_PREFIX="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." \
        >/dev/null 2>&1 && pwd -P)"
    export KOOPA_PREFIX
fi

# Source POSIX header (which includes functions).
# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/posix/include/header.sh"

# Source Bash functions.
for file in "${KOOPA_PREFIX}/shell/bash/functions/"*".sh"
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
