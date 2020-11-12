#!/usr/bin/env bash
# koopa nolint=coreutils

# """
# Bash header.
# @note Updated 2020-11-12.
# """

if [[ "$#" -gt 0 ]]
then
    pos=()
    while (("$#"))
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

[[ -n "${KOOPA_VERBOSE:-}" ]] && verbose=1
[[ -z "${activate:-}" ]] && activate=0
[[ -z "${checks:-}" ]] && checks=1
[[ -z "${shopts:-}" ]] && shopts=1
[[ -z "${verbose:-}" ]] && verbose=0
[[ "$verbose" -eq 1 ]] && export KOOPA_VERBOSE=1
if [[ "$activate" -eq 1 ]]
then
    checks=0
    shopts=0
else
    export KOOPA_SKIP_ACTIVATE=1
fi

# Customize optional shell behavior.
# These are not recommended to be set during koopa activation.
if [[ "$shopts" -eq 1 ]]
then
    [[ "$verbose" -eq 1 ]] && set -o xtrace # -x
    # > set -o noglob # -f
    set -o errexit # -e
    set -o errtrace # -E
    set -o nounset # -u
    set -o pipefail
fi

# Requiring Bash >= 4. macOS ships with an ancient version of Bash, due to
# licensing. If we're performing a clean install and loading up Homebrew,
# this step will fail unless we skip checks.
if [[ "$checks" -eq 1 ]]
then
    major_version="$(printf '%s\n' "${BASH_VERSION}" | cut -d '.' -f 1)"
    if [[ ! "$major_version" -ge 4 ]]
    then
        printf '%s\n' 'ERROR: Bash >= 4 is required.' >&2
        printf '%s: %s\n' 'BASH_VERSION' "$BASH_VERSION" >&2
        exit 1
    fi
    # Check that user's Bash has readarray (mapfile) builtin defined.
    # We use this a lot to handle arrays.
    if [[ $(type -t readarray) != 'builtin' ]]
    then
        printf '%s\n' 'ERROR: Bash is missing readarray (mapfile).' >&2
        exit 1
    fi
    unset -v major_version
fi

# Ensure koopa prefix is exported, if necessary.
if [[ -z "${KOOPA_PREFIX:-}" ]]
then
    KOOPA_PREFIX="$( \
        cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../.." \
        &>/dev/null \
        && pwd -P \
    )"
    export KOOPA_PREFIX
fi

# Source POSIX header (which includes functions).
# shellcheck source=/dev/null
. "${KOOPA_PREFIX}/shell/posix/include/header.sh"

# FIXME RETHINK THIS APPROACH.
# FIXME WE NEED TO SOURCE BY OPERATING SYSTEM HERE INSTEAD.

# Source Bash functions.
readarray -t fun_scripts <<< "$( \
    find "${KOOPA_PREFIX}/shell/bash/functions" \
        -mindepth 1 \
        -type f \
        -name '*.sh' \
        -print \
    | sort \
)"
for fun_script in "${fun_scripts[@]}"
do
    # shellcheck source=/dev/null
    . "$fun_script"
done
unset -v fun_script fun_scripts

if [[ "$checks" -eq 1 ]]
then
    # Require sudo permission to run 'sbin/' scripts.
    koopa::str_match "$0" '/sbin' && koopa::assert_has_sudo
fi

if [[ "$activate" -eq 0 ]]
then
    # Disable user-defined aliases.
    # Primarily intended to reset cp, mv, rf for use inside scripts.
    unalias -a
    # Check if we should display help.
    koopa::help "$@"
fi

unset -v activate checks shopts verbose
