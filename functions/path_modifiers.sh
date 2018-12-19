# PATH modifiers
# https://github.com/MikeMcQuaid/dotfiles/blob/master/shrc.sh

remove_from_path() {
    [[ -d "$1" ]] || return
    # Doesn't work for first item in the PATH.
    export PATH=${PATH//:$1/}
}

add_to_path_start() {
    [[ -d "$1" ]] || return
    remove_from_path "$1"
    export PATH="$1:$PATH"
}

add_to_path_end() {
    [[ -d "$1" ]] || return
    remove_from_path "$1"
    export PATH="$PATH:$1"
}

force_add_to_path_start() {
    remove_from_path "$1"
    export PATH="$1:$PATH"
}
