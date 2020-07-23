#!/usr/bin/env bash
# koopa nolint=coreutils

# """
# Bash header.
# @note Updated 2020-07-23.
# """

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

if [[ "$activate" -eq 1 ]]
then
    checks=0
    shopts=0
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
source "${KOOPA_PREFIX}/shell/posix/include/header.sh"

# Source Bash functions.
_koopa_source_dir "${KOOPA_PREFIX}/shell/bash/functions"

# Check if we should display help.
koopa::help "$@"

# Source OS-specific functions.
os_fun_dir="${KOOPA_PREFIX}/shell/bash/functions/os"
if koopa::is_macos
then
    koopa::source_dir "${os_fun_dir}/macos"
elif koopa::is_linux
then
    koopa::source_dir "${os_fun_dir}/linux"
    os_id="$(koopa::os_id)"
    # Debian derivatives.
    if koopa::is_debian
    then
        [[ "$os_id" != 'debian' ]] && \
            koopa::source_dir "${os_fun_dir}/debian"
        koopa::is_ubuntu && \
            [[ "$os_id" != 'ubuntu' ]] && \
            koopa::source_dir "${os_fun_dir}/ubuntu"
    # Fedora derivatives.
    elif koopa::is_fedora
    then
        [[ "$os_id" != 'fedora' ]] && \
            koopa::source_dir "${os_fun_dir}/fedora"
        koopa::is_rhel && \
            [[ "$os_id" != 'rhel' ]] && \
            koopa::source_dir "${os_fun_dir}/rhel"
        koopa::is_centos && \
            [[ "$os_id" != 'centos' ]] && \
            koopa::source_dir "${os_fun_dir}/centos"
    fi
    # Other Linux distros.
    koopa::source_dir "${os_fun_dir}/${os_id}"
fi

if [[ "$checks" -eq 1 ]]
then
    # Require sudo permission to run 'sbin/' scripts.
    koopa::str_match "$0" '/sbin' && koopa::assert_has_sudo
fi

# Disable user-defined aliases.
# Primarily intended to reset cp, mv, rf for use inside scripts.
[[ "$activate" -eq 0 ]] && unalias -a

unset -v activate checks file os_fun_dir os_id shopts verbose
