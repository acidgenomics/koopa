#!/usr/bin/env bash

__koopa_bash_source_dir() { # {{{1
    # """
    # Source multiple Bash script files inside a directory.
    # @note Updated 2021-05-21.
    #
    # Note that macOS ships with an ancient version of Bash by default that
    # doesn't support readarray/mapfile.
    # """
    local fun_script fun_scripts fun_scripts_arr koopa_prefix prefix
    [[ "$#" -eq 1 ]] || return 1
    [[ $(type -t readarray) == 'builtin' ]] || return 1
    koopa_prefix="$(_koopa_koopa_prefix)"
    prefix="${koopa_prefix}/lang/shell/bash/functions/${1:?}"
    [[ -d "$prefix" ]] || return 0
    fun_scripts="$( \
        find -L "$prefix" \
            -mindepth 1 \
            -type 'f' \
            -name '*.sh' \
            -print \
    )"
    readarray -t fun_scripts_arr <<< "$fun_scripts"
    for fun_script in "${fun_scripts_arr[@]}"
    do
        # shellcheck source=/dev/null
        source "$fun_script"
    done
    return 0
}

__koopa_is_installed() { # {{{1
    # """
    # Are all of the requested programs installed?
    # @note Updated 2021-06-16.
    # """
    local cmd
    [[ "$#" -gt 0 ]] || return 1
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

__koopa_is_macos() { # {{{1
    # """
    # Is the operating system macOS?
    # @note Updated 2021-06-04.
    # """
    [[ "$(uname -s)" == 'Darwin' ]]
}

__koopa_print() { # {{{1
    # """
    # Print a string.
    # @note Updated 2021-05-07.
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
    # Resolve file path.
    # @note Updated 2021-06-04.
    # """
    local readlink x
    [[ "$#" -gt 0 ]] || return 1
    readlink='readlink'
    __koopa_is_macos && readlink='greadlink'
    if ! __koopa_is_installed "$readlink"
    then
        __koopa_warn "Not installed: '${readlink}'."
        __koopa_is_macos && \
            __koopa_warn 'Install Homebrew and GNU coreutils to resolve.'
        return 1
    fi
    x="$("$readlink" -f "$@")"
    [[ -n "$x" ]] || return 1
    __koopa_print "$x"
    return 0
}

__koopa_warn() { # {{{1
    # """
    # Print a warning message to the console.
    # @note Updated 2021-05-14.
    # """
    local string
    [[ "$#" -gt 0 ]] || return 1
    for string in "$@"
    do
        printf '%b\n' "$string" >&2
    done
    return 0
}



__koopa_bash_header() { # {{{1
    # """
    # Bash header.
    # @note Updated 2021-09-16.
    # """
    local dict
    declare -A dict=(
        [activate]=0
        [checks]=1
        [dev]=0
        [minimal]=0
        [test]=0
        [verbose]=0
    )
    [[ -n "${KOOPA_ACTIVATE:-}" ]] && dict[activate]="$KOOPA_ACTIVATE"
    [[ -n "${KOOPA_CHECKS:-}" ]] && dict[checks]="$KOOPA_CHECKS"
    [[ -n "${KOOPA_DEV:-}" ]] && dict[dev]="$KOOPA_DEV"
    [[ -n "${KOOPA_MINIMAL:-}" ]] && dict[minimal]="$KOOPA_MINIMAL"
    [[ -n "${KOOPA_TEST:-}" ]] && dict[test]="$KOOPA_TEST"
    [[ -n "${KOOPA_VERBOSE:-}" ]] && dict[verbose]="$KOOPA_VERBOSE"
    if [[ "${dict[activate]}" -eq 1 ]] && \
        [[ "${dict[dev]}" -eq 0 ]] && \
        [[ "${dict[test]}" -eq 0 ]]
    then
        dict[checks]=0
    fi
    if [[ "${dict[activate]}" -eq 0 ]] || [[ "${dict[dev]}" -eq 1 ]]
    then
        unalias -a
    fi
    if [[ "${dict[verbose]}" -eq 1 ]]
    then
        set -o xtrace  # -x
    fi
    if [[ "${dict[checks]}" -eq 1 ]]
    then
        # Can check these settings with 'shopt'.
        # https://www.gnu.org/software/bash/manual/
        #   html_node/The-Shopt-Builtin.html
        # Bash POSIX mode is too strict and errors on our function names.
        # > set -o posix
        # > set -o noglob  # -f
        set -o errexit  # -e
        set -o errtrace  # -E
        set -o nounset  # -u
        set -o pipefail
        # Try to enforce that command substitution stops on first error code.
        # https://unix.stackexchange.com/questions/541682/
        shopt -s inherit_errexit
        # This setting helps protect our conda alias defined in the interactive
        # login shell from messing with 'koopa::activate_conda_env'.
        shopt -u expand_aliases
        # Check for readarray / mapfile, which is in Bash 4+.
        [[ "$(type -t 'readarray')" == 'builtin' ]] || return 1
        # Fix for RHEL/CentOS/Rocky Linux 'BASHRCSOURCED' unbound variable.
        # https://100things.wzzrd.com/2018/07/11/
        #   The-confusing-Bash-configuration-files.html
        [[ -z "${BASHRCSOURCED:-}" ]] && export BASHRCSOURCED='Y'
        [[ -z "${KOOPA_PROCESS_ID:-}" ]] && export KOOPA_PROCESS_ID="${$}"
    fi
    if [[ -z "${KOOPA_PREFIX:-}" ]]
    then
        dict[header_path]="${BASH_SOURCE[0]}"
        if [[ -L "${dict[header_path]}" ]]
        then
            dict[header_path]="$(__koopa_realpath "${dict[header_path]}")"
        fi
        KOOPA_PREFIX="$( \
            cd "$(dirname "${dict[header_path]}")/../../../.." \
            &>/dev/null \
            && pwd -P \
        )"
        export KOOPA_PREFIX
    fi
    # shellcheck source=/dev/null
    source "${KOOPA_PREFIX:?}/lang/shell/posix/include/header.sh"
    if [[ "${dict[test]}" -eq 1 ]]
    then
        _koopa_duration_start || return 1
    fi
    if [[ "${dict[activate]}" -eq 1 ]]
    then
        # shellcheck source=/dev/null
        source "${KOOPA_PREFIX:?}/lang/shell/bash/functions/activate.sh"
        if [[ "${dict[minimal]}" -eq 0 ]]
        then
            _koopa_activate_bash_extras
        fi
    fi
    if [[ "${dict[activate]}" -eq 0 ]] || \
        [[ "${dict[dev]}" -eq 1 ]]
    then
        __koopa_bash_source_dir 'common'
        dict[os_id]="$(koopa::os_id)"
        if koopa::is_linux
        then
            dict[linux_prefix]='os/linux'
            __koopa_bash_source_dir "${dict[linux_prefix]}/common"
            if koopa::is_debian_like
            then
                __koopa_bash_source_dir "${dict[linux_prefix]}/debian"
                koopa::is_ubuntu_like && \
                    __koopa_bash_source_dir "${dict[linux_prefix]}/ubuntu"
            elif koopa::is_fedora_like
            then
                __koopa_bash_source_dir "${dict[linux_prefix]}/fedora"
                koopa::is_rhel_like && \
                    __koopa_bash_source_dir "${dict[linux_prefix]}/rhel"
            fi
            __koopa_bash_source_dir "${dict[linux_prefix]}/${dict[os_id]}"
        else
            __koopa_bash_source_dir "os/${dict[os_id]}"
        fi
        # Check if user is requesting help documentation.
        case "${1:-}" in
            '--help' | \
            '-h')
                dict[script_file]="$(koopa::realpath "$0")"
                dict[script_name]="$(koopa::basename "${dict[script_file]}")"
                dict[man_prefix]="$( \
                    koopa::parent_dir --num=2 "${dict[script_file]}" \
                )"
                dict[man_file]="${dict[man_prefix]}/man/\
man1/${dict[script_name]}.1"
                koopa::help "${dict[man_file]}"
                return 0
                ;;
        esac
        if [[ -z "${KOOPA_ADMIN:-}" ]]
        then
            if koopa::is_shared_install && koopa::is_admin
            then
                export KOOPA_ADMIN=1
            else
                export KOOPA_ADMIN=0
            fi
        fi
        # Require admin account to run 'sbin/' scripts.
        if koopa::str_detect_fixed --string="$0" --pattern='/sbin'
        then
            koopa::assert_is_admin
        fi
        # Disable user-defined aliases.
        unalias -a
    fi
    if [[ "${dict[test]}" -eq 1 ]]
    then
        _koopa_duration_stop 'bash' || return 1
    fi
    return 0
}

__koopa_bash_header "$@"
