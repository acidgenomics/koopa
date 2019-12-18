#!/bin/sh
# shellcheck disable=SC2039

_koopa_add_to_path_start() {                                              # {{{1
    # """
    # Add directory to start of PATH.
    # Updated 2019-11-11.
    # """
    [ ! -d "$1" ] && return 0
    echo "${PATH:-}" | grep -q "$1" && return 0
    export PATH="${1}:${PATH:-}"
}

_koopa_add_to_path_end() {                                                # {{{1
    # """
    # Add directory to end of PATH.
    # Updated 2019-11-11.
    # """
    [ ! -d "$1" ] && return 0
    echo "${PATH:-}" | grep -q "$1" && return 0
    export PATH="${PATH:-}:${1}"
}

_koopa_force_add_to_path_end() {                                          # {{{1
    _koopa_remove_from_path "$1"
    _koopa_add_to_path_end "$1"
}

_koopa_force_add_to_path_start() {                                        # {{{1
    _koopa_remove_from_path "$1"
    _koopa_add_to_path_start "$1"
}

_koopa_remove_from_path() {                                               # {{{1
    # """
    # Remove directory from PATH.
    # Updated 2019-10-14.
    #
    # Look into an improved POSIX method here.
    # This works for bash and ksh.
    # Note that this won't work on the first item in PATH.
    #
    # Alternate approach using sed:
    # > echo "$PATH" | sed "s|:${dir}||g"
    # """
    export PATH="${PATH//:$1/}"
}

_koopa_add_to_fpath_start() {                                             # {{{1
    # """
    # Add directory to start of FPATH.
    # Updated 2019-11-11.
    #
    # Currently only useful for ZSH activation.
    # """
    [ ! -d "$1" ] && return 0
    echo "${FPATH:-}" | grep -q "$1" && return 0
    export FPATH="${1}:${FPATH:-}"
}

_koopa_add_to_fpath_end() {                                               # {{{1
    # """
    # Add directory to end of FPATH.
    # Updated 2019-11-11.
    #
    # Currently only useful for ZSH activation.
    # """
    [ ! -d "$1" ] && return 0
    echo "${FPATH:-}" | grep -q "$1" && return 0
    export FPATH="${FPATH:-}:${1}"
}

_koopa_force_add_to_fpath_start() {                                       # {{{1
    _koopa_remove_from_fpath "$1"
    _koopa_add_to_fpath_start "$1"
}

_koopa_force_add_to_fpath_end() {                                         # {{{1
    _koopa_remove_from_fpath "$1"
    _koopa_add_to_fpath_end "$1"
}

_koopa_remove_from_fpath() {                                              # {{{1
    # """
    # Remove directory from FPATH.
    # Updated 2019-10-27.
    # """
    export FPATH="${FPATH//:$1/}"
}

_koopa_add_to_manpath_start() {                                           # {{{1
    # """
    # Add directory to start of MANPATH.
    # Updated 2019-11-11.
    # """
    [ ! -d "$1" ] && return 0
    echo "${MANPATH:-}" | grep -q "$1" && return 0
    export MANPATH="${1}:${MANPATH:-}"
}

_koopa_add_to_manpath_end() {                                             # {{{1
    # """
    # Add directory to start of MANPATH.
    # Updated 2019-11-11.
    # """
    [ ! -d "$1" ] && return 0
    echo "${MANPATH:-}" | grep -q "$1" && return 0
    export MANPATH="${MANPATH:-}:${1}"
}

_koopa_force_add_to_manpath_start() {                                     # {{{1
    _koopa_remove_from_manpath "$1"
    _koopa_add_to_manpath_start "$1"
}

_koopa_force_add_to_manpath_end() {                                       # {{{1
    _koopa_remove_from_manpath "$1"
    _koopa_add_to_manpath_end "$1"
}

_koopa_remove_from_manpath() {                                            # {{{1
    # """
    # Remove directory from MANPATH.
    # Updated 2019-10-14.
    # """
    export MANPATH="${MANPATH//:$1/}"
}

_koopa_add_conda_env_to_path() {                                          # {{{1
    # """
    # Add conda environment to PATH.
    # Updated 2019-10-21.
    #
    # Consider warning if the environment is missing.
    # """
    _koopa_is_installed conda || return 0
    [ -n "${CONDA_PREFIX:-}" ] || return 0
    local bin_dir
    bin_dir="${CONDA_PREFIX}/envs/${1}/bin"
    [ -d "$bin_dir" ] || return 0
    _koopa_add_to_path_start "$bin_dir"
}

_koopa_list_path_priority() {                                             # {{{1
    # """
    # Split PATH string by ':' delim into lines.
    # Updated 2019-10-27.
    #
    # Bash parameter expansion:
    # > echo "${PATH//:/$'\n'}"
    #
    # Can generate a unique PATH string with:
    # > _koopa_list_path_priority \
    # >     | tac \
    # >     | awk '!a[$0]++' \
    # >     | tac
    #
    # see also:
    # - https://askubuntu.com/questions/600018
    # """
    tr ':' '\n' <<< "${1:-$PATH}"
}

_koopa_which() {                                                          # {{{1
    # """
    # Locate which program.
    # Updated 2019-10-08.
    #
    # Note that this intentionally doesn't resolve symlinks.
    # Use 'koopa_realpath' for that output instead.
    #
    # Example:
    # _koopa_which bash
    # ## /usr/local/bin/bash
    # """
    command -v "$1"
}

_koopa_which_realpath() {                                                 # {{{1
    # """
    # Locate the realpath of a program.
    # Updated 2019-11-16.
    #
    # This resolves symlinks automatically.
    # For 'which' style return, use '_koopa_which' instead.
    #
    # See also:
    # - https://stackoverflow.com/questions/7665
    # - https://unix.stackexchange.com/questions/85249
    # - https://stackoverflow.com/questions/7522712
    # - https://thoughtbot.com/blog/input-output-redirection-in-the-shell
    #
    # Examples:
    # _koopa_which_realpath bash
    # ## /usr/local/Cellar/bash/5.0.11/bin/bash
    # """
    realpath "$(_koopa_which "$1")"
}
