#!/bin/sh
## shellcheck disable=SC2039



## Delete a dot file.
## Updated 2019-06-27.
_koopa_delete_dotfile() {
    local path
    local name

    path="${HOME}/.${1}"
    name="$(basename "$path")"
    
    if [ -L "$path" ]
    then
        printf "Removing '%s'.\n" "$name"
        rm -f "$path"
    elif [ -f "$path" ] || [ -d "$path" ]
    then
        printf "Warning: Not symlink: %s\n" "$name"
    fi
}
