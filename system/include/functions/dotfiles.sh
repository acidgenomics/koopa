#!/bin/sh

# Dot files helpers.
# Modified 2019-06-20.



# Delete a dot file.
# Modified 2019-06-20.
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
