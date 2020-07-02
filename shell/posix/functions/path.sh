#!/bin/sh
# shellcheck disable=SC2039

_koopa_add_conda_env_to_path() { # {{{1
    # """
    # Add conda environment(s) to PATH.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    _koopa_is_installed conda || return 1
    [ -z "${CONDA_PREFIX:-}" ] || return 1
    local bin_dir name
    for name in "$@"
    do
        bin_dir="${CONDA_PREFIX}/envs/${name}/bin"
        if [ ! -d "$bin_dir" ]
        then
            _koopa_warning "Conda environment missing: '${bin_dir}'."
            return 1
        fi
        _koopa_add_to_path_start "$bin_dir"
    done
    return 0
}

_koopa_add_to_fpath_end() { # {{{1
    # """
    # Add directory to end of FPATH.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    FPATH="${FPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "$FPATH" ":${dir}" && continue
        FPATH="${FPATH}:${dir}"
    done
    export FPATH
    return 0
}

_koopa_add_to_fpath_start() { # {{{1
    # """
    # Add directory to start of FPATH.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    FPATH="${FPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "$FPATH" "${dir}:" && continue
        FPATH="${dir}:${FPATH}"
    done
    export FPATH
    return 0
}

_koopa_add_to_manpath_end() { # {{{1
    # """
    # Add directory to end of MANPATH.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    MANPATH="${MANPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "$MANPATH" ":${dir}" && continue
        MANPATH="${MANPATH}:${dir}"
    done
    export MANPATH
    return 0
}

_koopa_add_to_manpath_start() { # {{{1
    # """
    # Add directory to start of MANPATH.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    MANPATH="${MANPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "$MANPATH" "${dir}:" && continue
        MANPATH="${dir}:${MANPATH}"
    done
    export MANPATH
    return 0
}

_koopa_add_to_path_end() { # {{{1
    # """
    # Add directory to end of PATH.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    PATH="${PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "$PATH" ":${dir}" && continue
        PATH="${PATH}:${dir}"
    done
    export PATH
    return 0
}

_koopa_add_to_path_start() { # {{{1
    # """
    # Add directory to start of PATH.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    PATH="${PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "$PATH" "${dir}:" && continue
        PATH="${dir}:${PATH}"
    done
    export PATH
    return 0
}

_koopa_add_to_pkg_config_end() { # {{{1
    # """
    # Add directory to end of PKG_CONFIG_PATH.
    # @note Updated 2020-07-02.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "$PKG_CONFIG_PATH" ":${dir}" && continue
        PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${dir}"
    done
    export PKG_CONFIG_PATH
    return 0
}

_koopa_add_to_pkg_config_start() { # {{{1
    # """
    # Add directory to start of PKG_CONFIG_PATH.
    # @note Updated 2020-07-02.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "$PKG_CONFIG_PATH" "${dir}:" && continue
        PKG_CONFIG_PATH="${dir}:${PKG_CONFIG_PATH}"
    done
    export PKG_CONFIG_PATH
    return 0
}

_koopa_force_add_to_fpath_end() { # {{{1
    # """
    # Force add to FPATH end.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_remove_from_fpath "$dir"
        _koopa_add_to_fpath_end "$dir"
    done
    return 0
}

_koopa_force_add_to_fpath_start() { # {{{1
    # """
    # Force add to FPATH start.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_remove_from_fpath "$dir"
        _koopa_add_to_fpath_start "$dir"
    done
    return 0
}

_koopa_force_add_to_manpath_end() { # {{{1
    # """
    # Force add to MANPATH end.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_remove_from_manpath "$dir"
        _koopa_add_to_manpath_end "$dir"
    done
    return 0
}

_koopa_force_add_to_manpath_start() { # {{{1
    # """
    # Force add to MANPATH start.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_remove_from_manpath "$dir"
        _koopa_add_to_manpath_start "$dir"
    done
    return 0
}

_koopa_force_add_to_path_end() { # {{{1
    # """
    # Force add to end of PATH.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_remove_from_path "$dir"
        _koopa_add_to_path_end "$dir"
    done
    return 0
}

_koopa_force_add_to_path_start() { # {{{1
    # """
    # Force add to start of PATH.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    for dir in "$@"
    do
        _koopa_remove_from_path "$dir"
        _koopa_add_to_path_start "$dir"
    done
    return 0
}

_koopa_list_path_priority() { # {{{1
    # """
    # Split PATH string by ':' delim into lines.
    # @note Updated 2019-10-27.
    #
    # Note that we're using awk approach here because it is shell agnostic.
    #
    # Bash here string parsing approach (non-POSIX):
    # Refer to heredoc format in 'man bash' for details.
    # > tr ':' '\n' <<< "$str"
    #
    # Bash parameter expansion approach:
    # > _koopa_print "${PATH//:/$'\n'}"
    #
    # see also:
    # - https://askubuntu.com/questions/600018
    # - https://stackoverflow.com/questions/26849247
    # - https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html
    # - https://www.unix.com/shell-programming-and-scripting/
    #       77199-splitting-string-awk.html
    # """
    [ "$#" -le 1 ] || return 1
    _koopa_is_installed awk || return 1
    local str
    str="${1:-$PATH}"
    x="$( \
        _koopa_print "$str" \
        | awk '{split($0,array,":")} END { for (i in array) print array[i] }' \
    )"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_list_path_priority_unique() { # {{{1
    # """
    # Split PATH string by ':' delim into lines but only return uniques.
    # @note Updated 2020-06-30.
    # """
    _koopa_is_installed awk tac || return 1
    local x
    x="$( \
        _koopa_list_path_priority "$@" \
            | tac \
            | awk '!a[$0]++' \
            | tac \
    )"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_remove_from_fpath() { # {{{1
    # """
    # Remove directory from FPATH.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    FPATH="${FPATH:-}"
    for dir in "$@"
    do
        FPATH="$(_koopa_print "$FPATH" | sed "s|:${dir}||g")"
    done
    export FPATH
    return 0
}

_koopa_remove_from_manpath() { # {{{1
    # """
    # Remove directory from MANPATH.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    FPATH="${FPATH:-}"
    for dir in "$@"
    do
        MANPATH="$(_koopa_print "$MANPATH" | sed "s|:${dir}||g")"
    done
    export MANPATH
    return 0
}

_koopa_remove_from_path() { # {{{1
    # """
    # Remove directory from PATH.
    # @note Updated 2020-06-30.
    #
    # Alternative non-POSIX approach that works on Bash and Zsh:
    # > PATH="${PATH//:$dir/}"
    # """
    [ "$#" -gt 0 ] || return 1
    local dir
    PATH="${PATH:-}"
    for dir in "$@"
    do
        PATH="$(_koopa_print "$PATH" | sed "s|:${dir}||g")"
    done
    export PATH
    return 0
}

_koopa_which() { # {{{1
    # """
    # Locate which program.
    # @note Updated 2020-06-30.
    #
    # Note that this intentionally doesn't resolve symlinks.
    # Use 'koopa_realpath' for that output instead.
    #
    # Example:
    # _koopa_which bash
    # ## /usr/local/bin/bash
    # """
    [ "$#" -gt 0 ] || return 1
    _koopa_assert_is_installed "$@"
    local cmd
    for cmd in "$@"
    do
        _koopa_is_alias "$cmd" && cmd="$(unalias "$cmd")"
        cmd="$(command -v "$cmd")"
        _koopa_print "$cmd"
    done
    return 0
}

_koopa_which_realpath() { # {{{1
    # """
    # Locate the realpath of a program.
    # @note Updated 2020-06-30.
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
    # _koopa_which_realpath bash vim
    # ## /usr/local/Cellar/bash/5.0.17/bin/bash
    # ## /usr/local/Cellar/vim/8.2.1050/bin/vim
    # """
    [ "$#" -gt 0 ] || return 1
    local cmd
    for cmd in "$@"
    do
        cmd="$(_koopa_which "$cmd")"
        cmd="$(_koopa_realpath "$cmd")"
        _koopa_print "$cmd"
    done
    return 0
}
