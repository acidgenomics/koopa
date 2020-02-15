#!/bin/sh
# shellcheck disable=SC2039

_koopa_add_conda_env_to_path() {  # {{{1
    # """
    # Add conda environment to PATH.
    # Updated 2020-01-12.
    #
    # Consider warning if the environment is missing.
    # """
    local name
    name="${1:?}"
    _koopa_is_installed conda || return 0
    [ -n "${CONDA_PREFIX:-}" ] || return 0
    local bin_dir
    bin_dir="${CONDA_PREFIX}/envs/${name}/bin"
    [ -d "$bin_dir" ] || return 0
    _koopa_add_to_path_start "$bin_dir"
    return 0
}

_koopa_add_to_fpath_end() {  # {{{1
    # """
    # Add directory to end of FPATH.
    # Updated 2020-01-12.
    #
    # Currently only useful for ZSH activation.
    # """
    local dir
    dir="${1:?}"
    [ ! -d "$dir" ] && return 0
    echo "${FPATH:-}" | grep -q "$dir" && return 0
    export FPATH="${FPATH:-}:${dir}"
    return 0
}

_koopa_add_to_fpath_start() {  # {{{1
    # """
    # Add directory to start of FPATH.
    # Updated 2020-01-12.
    #
    # Currently only useful for ZSH activation.
    # """
    local dir
    dir="${1:?}"
    [ ! -d "$dir" ] && return 0
    echo "${FPATH:-}" | grep -q "$dir" && return 0
    export FPATH="${dir}:${FPATH:-}"
    return 0
}

_koopa_add_to_manpath_end() {  # {{{1
    # """
    # Add directory to end of MANPATH.
    # Updated 2020-01-12.
    # """
    local dir
    dir="${1:?}"
    [ ! -d "$dir" ] && return 0
    echo "${MANPATH:-}" | grep -q "$dir" && return 0
    export MANPATH="${MANPATH:-}:${dir}"
    return 0
}

_koopa_add_to_manpath_start() {  # {{{1
    # """
    # Add directory to start of MANPATH.
    # Updated 2020-01-12.
    # """
    local dir
    dir="${1:?}"
    [ ! -d "$dir" ] && return 0
    echo "${MANPATH:-}" | grep -q "$dir" && return 0
    export MANPATH="${dir}:${MANPATH:-}"
    return 0
}

_koopa_add_to_path_end() {  # {{{1
    # """
    # Add directory to end of PATH.
    # Updated 2020-01-12.
    # """
    local dir
    dir="${1:?}"
    [ ! -d "$dir" ] && return 0
    echo "${PATH:-}" | grep -q "$dir" && return 0
    export PATH="${PATH:-}:${dir}"
    return 0
}

_koopa_add_to_path_start() {  # {{{1
    # """
    # Add directory to start of PATH.
    # Updated 2020-01-12.
    # """
    local dir
    dir="${1:?}"
    [ ! -d "$dir" ] && return 0
    echo "${PATH:-}" | grep -q "$dir" && return 0
    export PATH="${dir}:${PATH:-}"
    return 0
}

_koopa_force_add_to_fpath_end() {  # {{{1
    # """
    # Force add to FPATH end.
    # Updated 2020-01-12.
    # """
    local dir
    dir="${1:?}"
    _koopa_remove_from_fpath "$dir"
    _koopa_add_to_fpath_end "$dir"
    return 0
}

_koopa_force_add_to_fpath_start() {  # {{{1
    # """
    # Force add to FPATH start.
    # Updated 2020-01-12.
    # """
    local dir
    dir="${1:?}"
    _koopa_remove_from_fpath "$dir"
    _koopa_add_to_fpath_start "$dir"
    return 0
}

_koopa_force_add_to_manpath_end() {  # {{{1
    # """
    # Force add to MANPATH end.
    # Updated 2020-01-12.
    # """
    local dir
    dir="${1:?}"
    _koopa_remove_from_manpath "$dir"
    _koopa_add_to_manpath_end "$dir"
    return 0
}

_koopa_force_add_to_manpath_start() {  # {{{1
    # """
    # Force add to MANPATH start.
    # Updated 2020-01-12.
    # """
    local dir
    dir="${1:?}"
    _koopa_remove_from_manpath "$dir"
    _koopa_add_to_manpath_start "$dir"
    return 0
}

_koopa_force_add_to_path_end() {  # {{{1
    # """
    # Force add to end of PATH.
    # Updated 2020-01-12.
    # """
    local dir
    dir="${1:?}"
    _koopa_remove_from_path "$dir"
    _koopa_add_to_path_end "$dir"
    return 0
}

_koopa_force_add_to_path_start() {  # {{{1
    # """
    # Force add to start of PATH.
    # Updated 2020-01-12.
    # """
    local dir
    dir="${1:?}"
    _koopa_remove_from_path "$dir"
    _koopa_add_to_path_start "$dir"
    return 0
}

_koopa_list_path_priority() {  # {{{1
    # """
    # Split PATH string by ':' delim into lines.
    # Updated 2019-10-27.
    #
    # Note that we're using awk approach here because it is shell agnostic.
    #
    # Bash here string parsing approach (non-POSIX):
    # Refer to heredoc format in 'man bash' for details.
    # > tr ':' '\n' <<< "$str"
    #
    # Bash parameter expansion approach:
    # > echo "${PATH//:/$'\n'}"
    #
    # see also:
    # - https://askubuntu.com/questions/600018
    # - https://stackoverflow.com/questions/26849247
    # - https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html
    # - https://www.unix.com/shell-programming-and-scripting/
    #       77199-splitting-string-awk.html
    # """
    _koopa_assert_is_installed awk
    local str
    str="${1:-$PATH}"
    echo "$str"| \
        awk '{split($0,array,":")} END { for (i in array) print array[i] }'
}

_koopa_list_path_priority_unique() {  # {{{1
    # """
    # Split PATH string by ':' delim into lines but only return uniques.
    # Updated 2020-02-06.
    # """
    _koopa_assert_is_installed awk tac
    _koopa_list_path_priority "$@" \
        | tac \
        | awk '!a[$0]++' \
        | tac
}

_koopa_remove_from_fpath() {  # {{{1
    # """
    # Remove directory from FPATH.
    # Updated 2020-01-12.
    # """
    local dir
    dir="${1:?}"
    export FPATH="${FPATH//:$dir/}"
    return 0
}

_koopa_remove_from_manpath() {  # {{{1
    # """
    # Remove directory from MANPATH.
    # Updated 2019-10-14.
    # """
    local dir
    dir="${1:?}"
    export MANPATH="${MANPATH//:$dir/}"
    return 0
}

_koopa_remove_from_path() {  # {{{1
    # """
    # Remove directory from PATH.
    # Updated 2020-01-12.
    #
    # Look into an improved POSIX method here.
    # This works for bash and ksh.
    # Note that this won't work on the first item in PATH.
    #
    # Alternate approach using sed:
    # > echo "$PATH" | sed "s|:${dir}||g"
    # """
    local dir
    dir="${1:?}"
    export PATH="${PATH//:$dir/}"
    return 0
}

_koopa_which() {  # {{{1
    # """
    # Locate which program.
    # Updated 2020-02-06.
    #
    # Note that this intentionally doesn't resolve symlinks.
    # Use 'koopa_realpath' for that output instead.
    #
    # Example:
    # _koopa_which bash
    # ## /usr/local/bin/bash
    # """
    local cmd
    cmd="${1:?}"
    _koopa_is_installed "$cmd" || return 1
    local app_path
    if _koopa_is_alias "$cmd"
    then
        app_path="$(unalias "$cmd"; command -v "$cmd")"
    else
        app_path="$(command -v "$cmd")"
    fi
    echo "$app_path"
}

_koopa_which_realpath() {  # {{{1
    # """
    # Locate the realpath of a program.
    # Updated 2020-02-06.
    #
    # This resolves symlinks automatically.
    # For 'which' style return, use '_koopa_which' instead.
    #
    # @seealso
    # - https://stackoverflow.com/questions/7665
    # - https://unix.stackexchange.com/questions/85249
    # - https://stackoverflow.com/questions/7522712
    # - https://thoughtbot.com/blog/input-output-redirection-in-the-shell
    #
    # @examples
    # _koopa_which_realpath bash
    # ## /usr/local/Cellar/bash/5.0.11/bin/bash
    # """
    local cmd
    cmd="${1:?}"
    _koopa_is_installed "$cmd" || return 1
    local app_path
    app_path="$(_koopa_which "$cmd")"
    realpath "$app_path"
}
