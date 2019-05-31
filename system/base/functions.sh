#!/bin/sh

# Path modifiers.
# Modified from Mike McQuaid's dotfiles.
# https://github.com/MikeMcQuaid/dotfiles/blob/master/shrc.sh



# pathmunge is defined in RHEL `/etc/profile`.
# Copied here for cross platform support.
pathmunge () {
    case ":${PATH}:" in
        *:"$1":*) ;;
        *)
            if [ "$2" = "after" ]
            then
                PATH="$PATH:$1"
            else
                PATH="$1:$PATH"
            fi
    esac
}



# Look into an improved POSIX method here. This works for bash and ksh.
# Note that this won't work on the first item in PATH.
remove_from_path() {
    [ -d "$1" ] || return
    # SC2039: In POSIX sh, string replacement is undefined.
    # shellcheck disable=SC2039
    export PATH="${PATH//:$1/}"
}

add_to_path_start() {
    # Early return if not a directory.
    [ -d "$1" ] || return
    # Early return if directory is already in PATH.
    echo "$PATH" | grep -qv "$1" || return
    remove_from_path "$1"
    export PATH="${1}:${PATH}"
}

add_to_path_end() {
    # Early return if not a directory.
    [ -d "$1" ] || return
    # Early return if directory is already in PATH.
    echo "$PATH" | grep -qv "$1" || return
    remove_from_path "$1"
    export PATH="${PATH}:${1}"
}

force_add_to_path_start() {
  remove_from_path "$1"
  export PATH="${1}:${PATH}"
}

force_add_to_path_end() {
  remove_from_path "$1"
  export PATH="${PATH}:${1}"
}



# Regular expression matching that is POSIX compliant.
# https://stackoverflow.com/questions/21115121
# Avoid using `[[ =~ ]]` in sh config files.
# expr is faster than using case.
quiet_expr() {
    expr "$1" : "$2" 1>/dev/null
}

# Don't use `&>` here, it isn't POSIX.
# https://unix.stackexchange.com/a/80632
quiet_which() {
    # command -v "$1" >/dev/null
    command -v "$1" >/dev/null 2>&1
}
