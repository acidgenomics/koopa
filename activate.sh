#!/bin/sh

# Csh is not supported, primarily due to lack of functions.
# > csh -l or csh -i
[ "$0" = 'csh' ] && \
    printf '%s\n' 'koopa does not support csh.' && \
    exit 1

# Tcsh is not supported, primarily due to lack of functions.
# > tcsh -l or tcsh -i
[ "$0" = 'tcsh' ] && \
    printf '%s\n' 'koopa does not support tcsh.' && \
    exit 1

__koopa_activate_usage() {
    # """
    # Koopa activation usage triggered by '--help' flag.
    # @note Updated 2021-10-25.
    # """
    cat << END
usage: activate [--help|-h]

Activate koopa.

supported environment variables:
    KOOPA_FORCE=1
        Force activation inside of non-interactive shells.
        Not generally recommended, but used by koopa installer.
    KOOPA_MINIMAL=1
        Minimal mode.
        Simply load koopa programs into PATH.
        Skips additional program and shell configuration.
    KOOPA_SKIP=1
        Skip activation in current shell session.
        Recommended for users who want to selectively disable activation
        of shared koopa installation.
    KOOPA_TEST=1
        Enable verbose test mode.
        Used for Travis CI checks.

details:
    Bash or Zsh is currently recommended.
    Also supports Ash, Busybox, and Dash POSIX shells.

    For system-wide configuration on Linux, this should be called inside
    '/etc/profile.d/zzz-koopa.sh', owned by root.

    Sourcing of POSIX shell scripts via '.' (POSIX) or 'source' (bash, zsh)
    requires that arguments are passed in at the beginning of the call, rather
    than as positional arguments or flags. Refer to the working examples.

examples:
    # Default mode.
    . /usr/local/koopa/activate

    # Minimal mode.
    export KOOPA_MINIMAL=1
    . /usr/local/koopa/activate
END
}

__koopa_bash_source() {
    # """
    # Bash source file location.
    # @note Updated 2021-05-07.
    # """
    # shellcheck disable=SC3028,SC3054
    __koopa_print "${BASH_SOURCE[0]}"
    return 0
}

__koopa_check_zsh() {
    # """
    # Check that current Zsh configuration is supported.
    # @note Updated 2023-03-21.
    #
    # Zsh currently requires presence of '~/.zshrc' for clean activation.
    # This check will intentionally force early return when activation is
    # attempted from '/etc/profile.d'.
    #
    # Note that sourcing in '/etc/profile' doesn't return script path in
    # '0', which is commonly recommended online in place of 'BASH_SOURCE'.
    # '0' in this case instead returns '_src_etc_profile'.
    #
    # This approach covers both '_src_etc_profile' and '_src_etc_profile_d'.
    #
    # @seealso
    # - https://stackoverflow.com/a/23259585/3911732
    [ -n "${ZSH_VERSION:-}" ] || return 0
    case "$0" in
        '_src_etc_profile'*)
            return 1
            ;;
    esac
    return 0
}

__koopa_export_koopa_prefix() {
    # """
    # Export 'KOOPA_PREFIX' variable.
    # @note Updated 2023-03-09.
    # """
    __kvar_shell="$(__koopa_shell_name)"
    __kvar_script="$("__koopa_${__kvar_shell}_source")"
    if [ ! -e "$__kvar_script" ]
    then
        __koopa_warn 'Failed to locate koopa activate script.'
        return 1
    fi
    # Note that running realpath on the file instead of the directory will
    # properly resolve '~/.config/koopa/activate' symlink case.
    if [ -L "$__kvar_script" ]
    then
        __kvar_script="$(__koopa_realpath "$__kvar_script")"
    fi
    __kvar_prefix="$(__koopa_realpath "$(dirname "$__kvar_script")")"
    KOOPA_PREFIX="$__kvar_prefix"
    export KOOPA_PREFIX
    unset -v __kvar_prefix __kvar_script __kvar_shell
    return 0
}

__koopa_export_koopa_subshell() {
    # """
    # Export 'KOOPA_SUBSHELL' variable.
    # @note Updated 2021-05-26.
    #
    # This function evaluates whether 'KOOPA_PREFIX' is defined, which should be
    # the case only inside a subshell.
    # """
    [ -z "${KOOPA_PREFIX:-}" ] && return 0
    KOOPA_SUBSHELL=1
    export KOOPA_SUBSHELL
    return 0
}

__koopa_header() {
    # """
    # Shared shell header file location.
    # @note Updated 2023-03-09.
    # """
    __kvar_prefix="${KOOPA_PREFIX:?}/lang/shell"
    __kvar_shell="$(__koopa_shell_name)"
    __kvar_file="${__kvar_prefix}/${__kvar_shell}/include/header.sh"
    [ -f "$__kvar_file" ] || return 1
    __koopa_print "$__kvar_file"
    unset -v __kvar_file __kvar_prefix __kvar_shell
    return 0
}

__koopa_is_installed() {
    # """
    # Are all of the requested programs installed?
    # @note Updated 2023-03-09.
    # """
    for __kvar_cmd in "$@"
    do
        command -v "$__kvar_cmd" >/dev/null || return 1
    done
    unset -v __kvar_cmd
    return 0
}

__koopa_is_interactive() {
    # """
    # Is the current shell interactive?
    # @note Updated 2021-10-25.
    # """
    __koopa_str_detect "$-" 'i'
}

__koopa_posix_source() {
    # """
    # POSIX source file location.
    # @note Updated 2023-03-09.
    #
    # POSIX doesn't support file path resolution of sourced dot scripts.
    # """
    __kvar_prefix="${KOOPA_PREFIX:-}"
    if [ -z "$__kvar_prefix" ] && [ -d '/opt/koopa' ]
    then
        __kvar_prefix='/opt/koopa'
    fi
    if [ ! -d "$__kvar_prefix" ]
    then
        __koopa_warn \
            'Failed to locate koopa activation script.' \
            "Required 'KOOPA_PREFIX' variable is unset."
        return 1
    fi
    __koopa_print "${__kvar_prefix}/activate"
    unset -v __kvar_prefix
    return 0
}

__koopa_preflight() {
    # """
    # Run pre-flight checks.
    # @note Updated 2021-10-25.
    # """
    [ "${KOOPA_SKIP:-0}" -eq 1 ] && return 1
    [ "${KOOPA_FORCE:-0}" -eq 1 ] && return 0
    __koopa_check_zsh || return 1
    __koopa_is_interactive || return 1
    return 0
}

__koopa_print() {
    # """
    # Print a string.
    # @note Updated 2023-03-09.
    # """
    for __kvar_string in "$@"
    do
        printf '%b\n' "$__kvar_string"
    done
    unset -v __kvar_string
    return 0
}

__koopa_realpath() {
    # """
    # Resolve file path.
    # @note Updated 2023-03-23.
    # """
    for __kvar_arg in "$@"
    do
        __kvar_string="$( \
            readlink -f "$__kvar_arg" \
            2>/dev/null \
            || true \
        )"
        if [ -z "$__kvar_string" ]
        then
            __kvar_string="$( \
                perl -MCwd -le \
                    'print Cwd::abs_path shift' \
                    "$__kvar_arg" \
                2>/dev/null \
                || true \
            )"
        fi
        if [ -z "$__kvar_string" ]
        then
            __kvar_string="$( \
                python3 -c \
                    "import os; print(os.path.realpath('${__kvar_arg}'))" \
                2>/dev/null \
                || true \
            )"
        fi
        if [ -z "$__kvar_string" ]
        then
            unset -v __kvar_arg _kvar_string
            return 1
        fi
        __koopa_print "$__kvar_string"
    done
    unset -v __kvar_arg __kvar_string
    return 0
}

__koopa_shell_name() {
    # """
    # Shell name.
    # @note Updated 2023-03-09.
    # """
    if [ -n "${BASH_VERSION:-}" ]
    then
        __kvar_string='bash'
    elif [ -n "${ZSH_VERSION:-}" ]
    then
        __kvar_string='zsh'
    else
        __kvar_string='posix'
    fi
    __koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}

__koopa_str_detect() {
    # """
    # Evaluate whether a string contains a desired value.
    # @note Updated 2023-03-10.
    # """
    test "${1#*"$2"}" != "$1"
}

__koopa_warn() {
    # """
    # Print a warning message to the console.
    # @note Updated 2021-05-14.
    # """
    for __kvar_string in "$@"
    do
        printf '%b\n' "$__kvar_string" >&2
    done
    unset -v __kvar_string
    return 0
}

__koopa_zsh_source() {
    # """
    # Zsh source file location.
    # @note Updated 2021-11-18.
    #
    # Use '%x' not '%N' when called inside function.
    # https://stackoverflow.com/a/23259585/3911732
    # """
    # shellcheck disable=SC2296
    __koopa_print "${(%):-%x}"
    return 0
}

__koopa_activate() {
    # """
    # Activate koopa bootloader inside shell session.
    # @note Updated 2022-09-02.
    # """
    case "${1:-}" in
        '--help' | '-h')
            __koopa_activate_usage
            return 0
            ;;
    esac
    __koopa_preflight || return 0
    __koopa_export_koopa_subshell || return 1
    __koopa_export_koopa_prefix || return 1
    KOOPA_ACTIVATE="${KOOPA_ACTIVATE:-1}"
    export KOOPA_ACTIVATE
    # shellcheck source=/dev/null
    . "$(__koopa_header)" || return 1
    unset -v KOOPA_ACTIVATE
    return 0
}

__koopa_activate "$@"

# NOTE Don't attempt to unset functions here, can cause hash table warnings
# with active interactive Zsh session.
