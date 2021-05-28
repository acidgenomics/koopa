#!/usr/bin/env bash
# koopa nolint=coreutils

__koopa_bash_source_dir() { # {{{1
    # """
    # Source multiple Bash script files inside a directory.
    # @note Updated 2021-05-21.
    #
    # Note that macOS ships with an ancient version of Bash by default that
    # doesn't support readarray/mapfile.
    # """
    local fun_script fun_scripts fun_scripts_arr koopa_prefix prefix
    [[ $(type -t readarray) == 'builtin' ]] || return 1
    koopa_prefix="$(_koopa_prefix)"
    prefix="${koopa_prefix}/lang/shell/bash/functions/${1:?}"
    [[ -d "$prefix" ]] || return 0
    fun_scripts="$( \
        find -L "$prefix" \
            -mindepth 1 \
            -type f \
            -name '*.sh' \
            -print \
    )"
    readarray -t fun_scripts_arr <<< "$fun_scripts"
    for fun_script in "${fun_scripts_arr[@]}"
    do
        # shellcheck source=/dev/null
        . "$fun_script"
    done
    return 0
}

__koopa_is_installed() { # {{{1
    # """
    # Are all of the requested programs installed?
    # @note Updated 2021-05-07.
    # """
    local cmd
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

__koopa_is_macos() { # {{{1
    # """
    # Is the operating system macOS?
    # @note Updated 2021-05-07.
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
    # @note Updated 2021-05-26.
    # """
    local readlink x
    readlink='readlink'
    __koopa_is_macos && readlink='greadlink'
    if ! __koopa_is_installed "$readlink"
    then
        __koopa_warning "Not installed: '${readlink}'."
        __koopa_is_macos && \
            __koopa_warning 'Install Homebrew and GNU coreutils to resolve.'
        return 1
    fi
    x="$("$readlink" -f "$@")"
    [[ -e "$x" ]] || return 1
    __koopa_print "$x"
    return 0
}

__koopa_warning() { # {{{1
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
    # @note Updated 2021-05-26.
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
        # > set -o noglob  # -f
        set -o errexit  # -e
        set -o errtrace  # -E
        set -o nounset  # -u
        set -o pipefail
        # This setting helps protect our conda alias defined in the interactive
        # login shell from messing with 'koopa::activate_conda_env'.
        shopt -u expand_aliases
        dict[major_version]="$( \
            printf '%s\n' "${BASH_VERSION}" \
            | cut -d '.' -f 1 \
        )"
        if [[ ! "${dict[major_version]}" -ge 4 ]]
        then
            __koopa_warning \
                'Koopa requires Bash >= 4.' \
                "Current Bash version: '${BASH_VERSION}'."
            if [[ "$(uname -s)" == "Darwin" ]]
            then
                __koopa_warning \
                    "On macOS, we recommend installing Homebrew." \
                    "Refer to 'https://brew.sh' for instructions." \
                    "Then install Bash with 'brew install bash'."
            fi
            return 1
        fi
        [[ $(type -t readarray) == 'builtin' ]] || return 1
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
        if [[ -z "${_PRESERVED_PROMPT_COMMAND:-}" ]]
        then
            export _PRESERVED_PROMPT_COMMAND=''
        fi
    fi
    if [[ "${dict[activate]}" -eq 0 ]] || \
        [[ "${dict[dev]}" -eq 1 ]]
    then
        __koopa_bash_source_dir 'common'
        dict[os_id]="$(koopa::os_id)"
        if koopa::is_linux
        then
            __koopa_bash_source_dir 'os/linux/common'
            dict[distro_prefix]='os/linux/distro'
            if koopa::is_debian_like
            then
                __koopa_bash_source_dir "${dict[distro_prefix]}/debian"
                koopa::is_ubuntu_like && \
                    __koopa_bash_source_dir "${dict[distro_prefix]}/ubuntu"
            elif koopa::is_fedora_like
            then
                __koopa_bash_source_dir "${dict[distro_prefix]}/fedora"
                koopa::is_rhel_like && \
                    __koopa_bash_source_dir "${dict[distro_prefix]}/rhel"
            fi
            __koopa_bash_source_dir "${dict[distro_prefix]}/${dict[os_id]}"
        else
            __koopa_bash_source_dir "os/${dict[os_id]}"
        fi
        # Check if user is requesting help documentation.
        koopa::help "$@"
        # Require sudo permission to run 'sbin/' scripts.
        koopa::str_match "$0" '/sbin' && koopa::assert_is_admin
        # Disable user-defined aliases.
        unalias -a
    fi
    if [[ "${dict[test]}" -eq 1 ]]
    then
        _koopa_duration_stop 'bash' || return 1
    fi
    # > if [[ "${dict[checks]}" -eq 1 ]]
    # > then
    # >     set +o errexit
    # >     set +o errtrace
    # >     set +o nounset
    # >     set +o pipefail
    # > fi
    # > if [[ "${dict[verbose]}" -eq 1 ]]
    # > then
    # >     set +o xtrace
    # > fi
    return 0
}

__koopa_bash_header "$@"
