#!/bin/sh
# shellcheck disable=SC2039

# PATH string modifiers
# Modified 2019-07-10.

# See also:
# - https://github.com/MikeMcQuaid/dotfiles/blob/master/shrc.sh



# Add both 'bin/' and 'sbin/' to PATH.
# Modified 2019-06-27.
_koopa_add_bins_to_path() {
    local relpath
    local prefix
    relpath="${1:-}"
    prefix="$KOOPA_HOME"
    [ -n "$relpath" ] && prefix="${prefix}/${relpath}"
    _koopa_has_sudo && _koopa_add_to_path_start "${prefix}/sbin"
    _koopa_add_to_path_start "${prefix}/bin"
}



# Modified 2019-06-27.
_koopa_add_to_path_start() {
    local dir
    dir="$1"
    [ ! -d "$dir" ] && _koopa_remove_from_path "$dir" && return 0
    echo "$PATH" | grep -q "$dir" && return 0
    export PATH="${dir}:${PATH}"
}



# Modified 2019-06-27.
_koopa_add_to_path_end() {
    local dir
    dir="$1"
    [ ! -d "$dir" ] && _koopa_remove_from_path "$dir" && return 0
    echo "$PATH" | grep -q "$dir" && return 0
    export PATH="${PATH}:${dir}"
}



# Modified 2019-06-27.
_koopa_force_add_to_path_start() {
    local dir
    dir="$1"
    _koopa_remove_from_path "$dir"
    _koopa_add_to_path_start "$dir"
}



# Modified 2019-06-27.
_koopa_force_add_to_path_end() {
    local dir
    dir="$1"
    _koopa_remove_from_path "$dir"
    _koopa_add_to_path_end "$dir"
}



# Look into an improved POSIX method here. This works for bash and ksh.
# Note that this won't work on the first item in PATH.
#
# Alternate approach using sed:
# > echo "$PATH" | sed "s|:${dir}||g"
#
# Modified 2019-07-10.
_koopa_remove_from_path() {
    local dir
    dir="$1"
    export PATH="${PATH//:$dir/}"
}
