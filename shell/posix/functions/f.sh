#!/bin/sh
# shellcheck disable=SC2039



# Updated 2019-09-24.
_koopa_find_dotfiles() {
    local type="$1"
    local header="$2"
    printf "\n%s:\n\n" "$header"
    find ~ \
        -maxdepth 1 \
        -name ".*" \
        -type "$type" \
        -print0 | \
        xargs -0 -n1 basename | \
        sort |
        awk '{print "  ",$0}'
}



#' Find text in any file.
#'
#' @note Updated 2019-09-05.
#'
#' @seealso
#' - https://github.com/stephenturner/oneliners
#'
#' @examples
#' _koopa_find_text "mytext" *.txt
_koopa_find_text() {
    find . -name "$2" -exec grep -il "$1" {} \;;
}



# Updated 2019-06-27.
_koopa_force_add_to_path_end() {
    local dir
    dir="$1"
    _koopa_remove_from_path "$dir"
    _koopa_add_to_path_end "$dir"
}



# Updated 2019-06-27.
_koopa_force_add_to_path_start() {
    local dir
    dir="$1"
    _koopa_remove_from_path "$dir"
    _koopa_add_to_path_start "$dir"
}
