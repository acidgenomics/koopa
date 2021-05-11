#!/usr/bin/env bash
# koopa nolint=coreutils

__koopa_bash_source_dir() { # {{{1
    # """
    # Source multiple Bash script files inside a directory.
    # @note Updated 2021-05-11.
    #
    # Note that macOS ships with an ancient version of Bash by default that
    # doesn't support readarray/mapfile.
    # """
    local prefix fun_script fun_scripts koopa_prefix
    koopa_prefix="$(_koopa_prefix)"
    prefix="${koopa_prefix}/lang/shell/bash/functions/${1:?}"
    [[ -d "$prefix" ]] || return 0
    if [[ $(type -t readarray) != 'builtin' ]]
    then
        printf '%s\n' 'ERROR: Bash is missing readarray (mapfile).' >&2
        return 1
    fi
    readarray -t fun_scripts <<< "$( \
        find -L "$prefix" \
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
    return 0
}

__koopa_is_installed() { # {{{1
    # """
    # are all of the requested programs installed?
    # @note updated 2021-05-07.
    # """
    local cmd
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

__koopa_is_linux() { # {{{1
    # """
    # is the operating system linux?
    # @note updated 2021-05-07.
    # """
    [[ "$(uname -s)" == 'Linux' ]]
}

__koopa_is_macos() { # {{{1
    # """
    # is the operating system macos?
    # @note updated 2021-05-07.
    # """
    [[ "$(uname -s)" == 'Darwin' ]]
}

__koopa_print() { # {{{1
    # """
    # print a string.
    # @note updated 2021-05-07.
    # """
    local string
    [[ "$#" -gt 0 ]] || return 1
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

__koopa_realpath() { # {{{1
    # """
    # resolve file path.
    # @note updated 2021-05-11.
    # """
    local arg bn dn x
    [[ "$#" -gt 0 ]] || return 1
    if __koopa_is_installed realpath
    then
        x="$(realpath "$@")"
    elif __koopa_is_installed grealpath
    then
        x="$(grealpath "$@")"
    elif __koopa_is_macos
    then
        for arg in "$@"
        do
            bn="$(basename "$arg")"
            dn="$(cd "$(dirname "$arg")" || return 1; pwd -p)"
            x="${dn}/${bn}"
            __koopa_print "$x"
        done
        return 0
    else
        x="$(readlink -f "$@")"
    fi
    [[ -n "$x" ]] || return 1
    __koopa_print "$x"
    return 0
}

__koopa_bash_header() { # {{{1
    # """
    # Bash header.
    # @note Updated 2021-05-11.
    # """
    local activate checks dev distro_prefix header_path major_version os_id \
        shopts verbose
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
        header_path="${BASH_SOURCE[0]}"
        if [[ -L "$header_path" ]]
        then
            header_path="$(__koopa_realpath "$header_path")"
        fi
        KOOPA_PREFIX="$( \
            cd "$(dirname "$header_path")/../../../.." \
            &>/dev/null \
            && pwd -P \
        )"
        export KOOPA_PREFIX
    fi
    # shellcheck source=/dev/null
    source "${KOOPA_PREFIX}/lang/shell/posix/include/header.sh"
    if [[ "$activate" -eq 1 ]]
    then
        # shellcheck source=/dev/null
        source "${KOOPA_PREFIX}/lang/shell/bash/functions/activate.sh"
    fi
    if [[ "$activate" -eq 0 ]] || [[ "$dev" -eq 1 ]]
    then
        __koopa_bash_source_dir 'common'
        os_id="$(koopa::os_id)"
        if koopa::is_linux
        then
            __koopa_bash_source_dir 'os/linux/common'
            distro_prefix='os/linux/distro'
            if koopa::is_debian_like
            then
                __koopa_bash_source_dir "${distro_prefix}/debian"
                koopa::is_ubuntu_like && \
                    __koopa_koopa_bash_source_dir "${distro_prefix}/ubuntu"
            elif koopa::is_fedora_like
            then
                __koopa_bash_source_dir "${distro_prefix}/fedora"
                koopa::is_rhel_like && \
                    __koopa_bash_source_dir "${distro_prefix}/rhel"
            fi
            __koopa_bash_source_dir "${distro_prefix}/${os_id}"
        else
            __koopa_bash_source_dir "os/${os_id}"
        fi
        # Ensure we activate GNU coreutils and other tools that are keg-only
        # for Homebrew but preferred default for our Bash scripts.
        koopa::activate_homebrew_keg_only
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

__koopa_bash_header "$@"
