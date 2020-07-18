#!/bin/sh

_koopa_add_to_fpath_end() { # {{{1
    # """
    # Add directory to end of FPATH.
    # @note Updated 2020-06-30.
    # """
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
    local dir
    for dir in "$@"
    do
        _koopa_remove_from_path "$dir"
        _koopa_add_to_path_start "$dir"
    done
    return 0
}

_koopa_remove_from_fpath() { # {{{1
    # """
    # Remove directory from FPATH.
    # @note Updated 2020-06-30.
    # """
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # @note Updated 2020-07-18.
    #
    # Note that this intentionally doesn't resolve symlinks.
    # Use 'koopa_realpath' for that output instead.
    #
    # Example:
    # koopa::which bash
    # ## /usr/local/bin/bash
    # """
    # shellcheck disable=SC2039
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
    # @note Updated 2020-07-18.
    #
    # This resolves symlinks automatically.
    # For 'which' style return, use 'koopa::which' instead.
    #
    # @seealso
    # - https://stackoverflow.com/questions/7665
    # - https://unix.stackexchange.com/questions/85249
    # - https://stackoverflow.com/questions/7522712
    # - https://thoughtbot.com/blog/input-output-redirection-in-the-shell
    #
    # @examples
    # koopa::which_realpath bash vim
    # ## /usr/local/Cellar/bash/5.0.17/bin/bash
    # ## /usr/local/Cellar/vim/8.2.1050/bin/vim
    # """
    # shellcheck disable=SC2039
    local cmd
    for cmd in "$@"
    do
        cmd="$(_koopa_which "$cmd")"
        cmd="$(_koopa_realpath "$cmd")"
        _koopa_print "$cmd"
    done
    return 0
}
