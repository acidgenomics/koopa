#!/bin/sh

__koopa_add_to_path_string_end() { # {{{1
    # """
    # Add a directory to the beginning of a PATH string.
    # @note Updated 2021-04-23.
    # """
    local string dir
    [ "$#" -eq 2 ] || return 1
    string="${1:-}"
    dir="${2:?}"
    if _koopa_str_match_posix "$string" ":${dir}"
    then
        string="$(__koopa_remove_from_path_string "$string" "$dir")"
    fi
    string="${string}:${dir}"
    _koopa_print "$string"
    return 0
}

__koopa_add_to_path_string_start() { # {{{1
    # """
    # Add a directory to the beginning of a PATH string.
    # @note Updated 2021-04-23.
    # """
    local string dir
    [ "$#" -eq 2 ] || return 1
    string="${1:-}"
    dir="${2:?}"
    if _koopa_str_match_posix "$string" ":${dir}"
    then
        string="$(__koopa_remove_from_path_string "$string" "$dir")"
    fi
    string="${dir}:${string}"
    _koopa_print "$string"
    return 0
}

__koopa_remove_from_path_string() { # {{{1
    # """
    # Remove directory from PATH string with POSIX conventions.
    # @note Updated 2021-04-23.
    #
    # Alternative non-POSIX approach that works on Bash and Zsh:
    # > PATH="${PATH//:$dir/}"
    # """
    [ "$#" -eq 2 ] || return 1
    _koopa_print "${1:?}" | sed "s|:${2:?}||g"
    return 0
}

_koopa_add_to_fpath_end() { # {{{1
    # """
    # Force add to 'FPATH' end.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    FPATH="${FPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        FPATH="$(__koopa_add_to_path_string_end "$FPATH" "$dir")"
    done
    export FPATH
    return 0
}

_koopa_add_to_fpath_start() { # {{{1
    # """
    # Force add to 'FPATH' start.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    FPATH="${FPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        FPATH="$(__koopa_add_to_path_string_start "$FPATH" "$dir")"
    done
    export FPATH
    return 0
}

_koopa_add_to_manpath_end() { # {{{1
    # """
    # Force add to 'MANPATH' end.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    MANPATH="${MANPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        MANPATH="$(__koopa_add_to_path_string_end "$MANPATH" "$dir")"
    done
    export MANPATH
    return 0
}

_koopa_add_to_manpath_start() { # {{{1
    # """
    # Force add to 'MANPATH' start.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    MANPATH="${MANPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        MANPATH="$(__koopa_add_to_path_string_start "$MANPATH" "$dir")"
    done
    export MANPATH
    return 0
}

_koopa_add_to_path_end() { # {{{1
    # """
    # Force add to 'PATH' end.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    PATH="${PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PATH="$(__koopa_add_to_path_string_end "$PATH" "$dir")"
    done
    export PATH
    return 0
}

_koopa_add_to_path_start() { # {{{1
    # """
    # Force add to 'PATH' start.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    PATH="${PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PATH="$(__koopa_add_to_path_string_start "$PATH" "$dir")"
    done
    export PATH
    return 0
}

_koopa_add_to_pkg_config_path_end() { # {{{1
    # """
    # Force add to end of 'PKG_CONFIG_PATH'.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PKG_CONFIG_PATH="$( \
            __koopa_add_to_path_string_end "$PKG_CONFIG_PATH" "$dir" \
        )"
    done
    export PKG_CONFIG_PATH
    return 0
}

_koopa_add_to_pkg_config_path_start() { # {{{1
    # """
    # Force add to start of 'PKG_CONFIG_PATH'.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        PKG_CONFIG_PATH="$( \
            __koopa_add_to_path_string_start "$PKG_CONFIG_PATH" "$dir" \
        )"
    done
    export PKG_CONFIG_PATH
    return 0
}
