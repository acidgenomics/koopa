#!/bin/sh

# POSIX-compliant functions.
# Modified 2019-06-14.



# Quiet variants                                                            {{{1
# ==============================================================================

quiet_cd() {
    cd "$@" >/dev/null || return 1
}

# Regular expression matching that is POSIX compliant.
# https://stackoverflow.com/questions/21115121
# Avoid using `[[ =~ ]]` in sh config files.
# expr is faster than using case.

quiet_expr() {
    expr "$1" : "$2" 1>/dev/null
}

# Consider not using `&>` here, it isn't POSIX.
# https://unix.stackexchange.com/a/80632

quiet_which() {
    # command -v "$1" >/dev/null
    command -v "$1" >/dev/null 2>&1
}



# Sudo permission                                                           {{{1
# ==============================================================================

# Currently performing a simple check by verifying wheel group.
#
# Alternatively, can use `sudo -nv 2>/dev/null`.
# However, this approach doesn't work well unless sudo is passwordless, which
# isn't common on all Linux distros.
#
# - wheel: darwin, fedora
# - sudo: debian

has_sudo() {
    groups | grep -Eq "\b(sudo|wheel)\b"
}



# Path modifiers                                                            {{{1
# ==============================================================================

# Modified from Mike McQuaid's dotfiles.
# https://github.com/MikeMcQuaid/dotfiles/blob/master/shrc.sh

# Look into an improved POSIX method here. This works for bash and ksh.
# Note that this won't work on the first item in PATH.
remove_from_path() {
    [ -d "$1" ] || return 0
    # SC2039: In POSIX sh, string replacement is undefined.
    # shellcheck disable=SC2039
    export PATH="${PATH//:$1/}"
}

add_to_path_start() {
    # Early return if not a directory.
    [ -d "$1" ] || return 0
    # Early return if directory is already in PATH.
    echo "$PATH" | grep -qv "$1" || return 0
    remove_from_path "$1"
    export PATH="${1}:${PATH}"
}

add_to_path_end() {
    # Early return if not a directory.
    [ -d "$1" ] || return 0
    # Early return if directory is already in PATH.
    echo "$PATH" | grep -qv "$1" || return 0
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

# pathmunge is defined in RHEL `/etc/profile`.
# Copied here for cross platform support.
pathmunge() {
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



# Miscellaneous                                                             {{{1
# ==============================================================================

# Get version stored internally in versions.txt file.
# Modified 2019-06-14.
koopa_version() {
    what="$1"
    file="${KOOPA_DIR}/include/versions.txt"
    match="$(grep -E "^${what}=" "$file" || echo "")"
    if [ -n "$match" ]
    then
        echo "$match" | cut -d "\"" -f 2
    else
        >&2 echo "Error: ${what} not defined in versions file."
        >&2 echo "Refer to ${file}."
        return 1
    fi
}

