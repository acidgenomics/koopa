#!/bin/sh

# PATH string modifiers
# Modified 2019-06-24.

# See also:
# - https://github.com/MikeMcQuaid/dotfiles/blob/master/shrc.sh



# Add both 'bin/' and 'sbin/' to PATH.
# Modified 2019-06-26.
_koopa_add_bins_to_path() {
    relpath="${1:-}"
    prefix="$KOOPA_HOME"
    [ ! -z "$relpath" ] && prefix="${prefix}/${relpath}"
    _koopa_has_sudo && _koopa_add_to_path_start "${prefix}/sbin"
    _koopa_add_to_path_start "${prefix}/bin"
    unset -v prefix relpath
}



# Modified 2019-06-26.
_koopa_add_to_path_start() {
    dir="$1"
    [ ! -d "$dir" ] && _koopa_remove_from_path "$dir" && return
    echo "$PATH" | grep -q "$dir" && return
    dir="$(realpath "$dir")"
    export PATH="${dir}:${PATH}"
    unset -v dir
}



# Modified 2019-06-26.
_koopa_add_to_path_end() {
    dir="$1"
    [ ! -d "$dir" ] && _koopa_remove_from_path "$dir" && return
    echo "$PATH" | grep -q "$dir" && return
    dir="$(realpath "$dir")"
    export PATH="${PATH}:${dir}"
    unset -v dir
}



# Modified 2019-06-24.
_koopa_force_add_to_path_start() {
    dir="$1"
    _koopa_remove_from_path "$dir"
    dir="$(realpath "$dir")"
    export PATH="${dir}:${PATH}"
    unset -v dir
}



# Modified 2019-06-24.
_koopa_force_add_to_path_end() {
    dir="$1"
    _koopa_remove_from_path "$dir"
    dir="$(realpath "$dir")"
    export PATH="${PATH}:${dir}"
    unset -v dir
}



# Look into an improved POSIX method here. This works for bash and ksh.
# Note that this won't work on the first item in PATH.
# Modified 2019-06-26.
_koopa_remove_from_path() {
    dir="$1"
    # FIXME Switch to using sed here instead.
    export PATH="${PATH//:$dir/}"
    unset -v dir
}
