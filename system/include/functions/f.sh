#!/bin/sh
## shellcheck disable=SC2039



## Updated 2019-06-27.
_koopa_force_add_to_path_end() {
    local dir
    dir="$1"
    _koopa_remove_from_path "$dir"
    _koopa_add_to_path_end "$dir"
}



## Updated 2019-06-27.
_koopa_force_add_to_path_start() {
    local dir
    dir="$1"
    _koopa_remove_from_path "$dir"
    _koopa_add_to_path_start "$dir"
}
