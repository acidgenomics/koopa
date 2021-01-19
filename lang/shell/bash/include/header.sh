#!/usr/bin/env bash

_koopa_bash_header() { # {{{1
    # """
    # Bash header.
    # @note Updated 2021-01-19.
    # """
    local activate checks dev distro_prefix major_version os_id shopts verbose
    activate=0
    checks=1
    dev=0
    shopts=1
    verbose=0
    [[ -n "${KOOPA_ACTIVATE:-}" ]] && activate="$KOOPA_ACTIVATE"
    [[ -n "${KOOPA_CHECKS:-}" ]] && checks="$KOOPA_CHECKS"
    [[ -n "${KOOPA_DEV:-}" ]] && dev="$KOOPA_DEV"
    [[ -n "${KOOPA_VERBOSE:-}" ]] && verbose="$KOOPA_VERBOSE"
    if [[ "$activate" -eq 1 ]]
    then
        checks=0
        shopts=0
        export KOOPA_ACTIVATE=1
        export KOOPA_INTERACTIVE=1
    fi
    if [[ "$shopts" -eq 1 ]]
    then
        [[ "$verbose" -eq 1 ]] && set -o xtrace # -x
        # > set -o noglob # -f
        set -o errexit # -e
        set -o errtrace # -E
        set -o nounset # -u
        set -o pipefail
    fi
    if [[ "$checks" -eq 1 ]]
    then
        major_version="$(printf '%s\n' "${BASH_VERSION}" | cut -d '.' -f 1)"
        if [[ ! "$major_version" -ge 4 ]]
        then
            printf '%s\n' 'ERROR: Koopa requires Bash >= 4.' >&2
            printf '%s: %s\n' 'BASH_VERSION' "$BASH_VERSION" >&2
            return 1
        fi
        if [[ $(type -t readarray) != 'builtin' ]]
        then
            printf '%s\n' 'ERROR: Bash is missing readarray (mapfile).' >&2
            return 1
        fi
    fi
    if [[ -z "${KOOPA_PREFIX:-}" ]]
    then
        KOOPA_PREFIX="$( \
            cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../../.." \
            &>/dev/null \
            && pwd -P \
        )"
        export KOOPA_PREFIX
    fi
    # shellcheck source=/dev/null
    source "${KOOPA_PREFIX}/lang/shell/posix/include/header.sh"
    # shellcheck source=/dev/null
    source "${KOOPA_PREFIX}/lang/shell/bash/functions/activate.sh"
    if [[ "$activate" -eq 0 ]] || [[ "$dev" -eq 1 ]]
    then
        _koopa_source_dir 'common'
        os_id="$(_koopa_os_id)"
        if _koopa_is_linux
        then
            _koopa_source_dir 'os/linux/common'
            distro_prefix='os/linux/distro'
            if _koopa_is_debian_like
            then
                _koopa_source_dir "${distro_prefix}/debian"
                _koopa_is_ubuntu_like && \
                    _koopa_source_dir "${distro_prefix}/ubuntu"
            elif _koopa_is_fedora_like
            then
                _koopa_activate_prefix "${distro_prefix}/fedora"
                _koopa_is_rhel_like && \
                    _koopa_activate_prefix "${distro_prefix}/rhel"
            fi
            _koopa_source_dir "${distro_prefix}/${os_id}"
        else
            _koopa_source_dir "os/${os_id}"
        fi
        # Check if user is requesting help documentation.
        koopa::help "$@"
        # Require sudo permission to run 'sbin/' scripts.
        koopa::str_match "$0" '/sbin' && koopa::assert_has_sudo
        # Disable user-defined aliases.
        # Primarily intended to reset cp, mv, rf for use inside scripts.
        unalias -a
    fi
    return 0
}

_koopa_bash_header "$@"
