#!/bin/sh
# shellcheck disable=SC2039



# Delete a dot file.
# Updated 2019-06-27.
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



# Check that disk has enough free space.
# Updated 2019-08-15.
_koopa_disk_check() {
    local used
    local limit
    used="$(_koopa_disk_pct_used)"
    limit="90"
    if [ "$used" -gt "$limit" ]
    then
        >&2 printf "Warning: Disk usage is %d%%.\n" "$used"
    fi
}



# Check disk usage on main drive.
# Updated 2019-08-15.
_koopa_disk_pct_used() {
    local disk
    disk="${1:-/}"
    df "$disk" | \
        head -n 2  | \
        sed -n '2p' | \
        grep -Eo "([.0-9]+%)" | \
        head -n 1 | \
        sed 's/%$//'
}
