#!/bin/sh

# FIXME THIS IS WORKING BETTER...MUCH FASTER.

__koopa_add_to_fpath_end() { # {{{1
    # """
    # Add directory to end of 'FPATH'.
    # @note Updated 2021-04-23.
    # """
    [ "$#" -eq 1 ] || return 1
    FPATH="${FPATH:-}:${1:?}"
    export FPATH
    return 0
}

__koopa_add_to_fpath_start() { # {{{1
    # """
    # Add directory to start of 'FPATH'.
    # @note Updated 2021-04-23.
    # """
    [ "$#" -eq 1 ] || return 1
    FPATH="${1:?}:${FPATH:-}"
    export FPATH
    return 0
}

__koopa_add_to_manpath_end() { # {{{1
    # """
    # Add directory to end of 'MANPATH'.
    # @note Updated 2021-04-23.
    # """
    [ "$#" -eq 1 ] || return 1
    MANPATH="${MANPATH:-}:${1:?}"
    export MANPATH
    return 0
}

__koopa_add_to_manpath_start() { # {{{1
    # """
    # Add directory to start of 'MANPATH'.
    # @note Updated 2021-04-23.
    # """
    [ "$#" -eq 1 ] || return 1
    MANPATH="${1:?}:${MANPATH:-}"
    export MANPATH
    return 0
}

__koopa_add_to_path_end() { # {{{1
    # """
    # Add directory to end of 'PATH'.
    # @note Updated 2021-04-23.
    # """
    [ "$#" -eq 1 ] || return 1
    PATH="${PATH:-}:${1:?}"
    export PATH
    return 0
}

__koopa_add_to_path_start() { # {{{1
    # """
    # Add directory to start of 'PATH'.
    # @note Updated 2021-04-23.
    # """
    [ "$#" -eq 1 ] || return 1
    PATH="${1:?}:${PATH:-}"
    export PATH
    return 0
}

__koopa_add_to_pkg_config_path_end() { # {{{1
    # """
    # Add directory to end of 'PKG_CONFIG_PATH'.
    # @note Updated 2021-04-23.
    # """
    [ "$#" -eq 1 ] || return 1
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}:${1:?}"
    export PKG_CONFIG_PATH
    return 0
}

__koopa_add_to_pkg_config_path_start() { # {{{1
    # """
    # Add directory to start of 'PKG_CONFIG_PATH'.
    # @note Updated 2021-04-23.
    # """
    [ "$#" -eq 1 ] || return 1
    PKG_CONFIG_PATH="${1:?}:${PKG_CONFIG_PATH:-}"
    export PKG_CONFIG_PATH
    return 0
}

# USE A SHARED FUNCTION HERE TO DO REPLACEMENT EASIER...
__koopa_remove_from_fpath() { # {{{1
    # """
    # Remove directory from 'FPATH'.
    # @note Updated 2021-04-23.
    # """
    [ "$#" -eq 1 ] || return 1
    FPATH="$( \
        _koopa_print "${FPATH:-}" \
        | sed "s|:${1:?}||g" \
    )"
    export FPATH
    return 0
}

# USE A SHARED FUNCTION HERE TO DO REPLACEMENT EASIER...
__koopa_remove_from_manpath() { # {{{1
    # """
    # Remove directory from 'MANPATH'.
    # @note Updated 2021-04-23.
    # """
    [ "$#" -eq 1 ] || return 1
    MANPATH="$( \
        _koopa_print "${MANPATH:-}" \
        | sed "s|:${1:?}||g" \
    )"
    export MANPATH
    return 0
}

# USE A SHARED FUNCTION HERE TO DO REPLACEMENT EASIER...
__koopa_remove_from_path() { # {{{1
    # """
    # Remove directory from 'PATH'.
    # @note Updated 2021-04-23.
    #
    # Alternative non-POSIX approach that works on Bash and Zsh:
    # > PATH="${PATH//:$dir/}"
    # """
    [ "$#" -eq 1 ] || return 1
    PATH="$( \
        _koopa_print "${PATH:-}" \
        | sed "s|:${1:?}||g" \
    )"
    export PATH
    return 0
}

# USE A SHARED FUNCTION HERE TO DO REPLACEMENT EASIER...
__koopa_remove_from_pkg_config_path() { # {{{1
    # """
    # Remove directory from 'PKG_CONFIG_PATH'.
    # @note Updated 2021-04-23.
    # """
    [ "$#" -eq 1 ] || return 1
    PKG_CONFIG_PATH="$( \
        _koopa_print "${PKG_CONFIG_PATH:-}" \
        | sed "s|:${1:?}||g" \
    )"
    export PKG_CONFIG_PATH
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
        _koopa_str_match_posix "$FPATH" ":${dir}" && \
            # FIXME MAKE THIS MORE GENERAL...
            __koopa_remove_from_fpath "$dir"
        __koopa_add_to_fpath_end "$dir"
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
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "${FPATH:-}" ":${dir}" && \
            __koopa_remove_from_fpath "$dir"
        __koopa_add_to_fpath_start "$dir"
    done
    return 0
}

_koopa_add_to_manpath_end() { # {{{1
    # """
    # Force add to 'MANPATH' end.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "${MANPATH:-}" ":${dir}" && \
            __koopa_remove_from_manpath "$dir"
        __koopa_add_to_manpath_end "$dir"
    done
    return 0
}

_koopa_add_to_manpath_start() { # {{{1
    # """
    # Force add to 'MANPATH' start.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "${MANPATH:-}" ":${dir}" && \
            __koopa_remove_from_manpath "$dir"
        __koopa_add_to_manpath_start "$dir"
    done
    return 0
}

_koopa_add_to_path_end() { # {{{1
    # """
    # Force add to 'PATH' end.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "${PATH:-}" ":${dir}" && \
            __koopa_remove_from_path "$dir"
        __koopa_add_to_path_end "$dir"
    done
    return 0
}

_koopa_add_to_path_start() { # {{{1
    # """
    # Force add to 'PATH' start.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    for dir in "$@"
    do
        _koopa_str_match_posix "${PATH:-}" ":${dir}" && \
            __koopa_remove_from_path "$dir"
        __koopa_add_to_path_start "$dir"
    done
    return 0
}

_koopa_add_to_pkg_config_path_end() { # {{{1
    # """
    # Force add to end of 'PKG_CONFIG_PATH'.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "${PKG_CONFIG_PATH:-}" ":${dir}" && \
            __koopa_remove_from_pkg_config_path "$dir"
        __koopa_add_to_pkg_config_path_end "$dir"
    done
    return 0
}

_koopa_add_to_pkg_config_path_start() { # {{{1
    # """
    # Force add to start of 'PKG_CONFIG_PATH'.
    # @note Updated 2021-04-23.
    # """
    local dir
    [ "$#" -gt 0 ] || return 1
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        _koopa_str_match_posix "${PKG_CONFIG_PATH:-}" ":${dir}" && \
            __koopa_remove_from_pkg_config_path "$dir"
        __koopa_add_to_pkg_config_path_start "$dir"
    done
    return 0
}
