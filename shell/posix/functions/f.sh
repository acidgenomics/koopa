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



# Find text in any file.
#
# See also: https://github.com/stephenturner/oneliners
#
# Examples:
# _koopa_find_text "mytext" *.txt
#
# Updated 2019-09-05.
_koopa_find_text() {
    find . -name "$2" -exec grep -il "$1" {} \;;
}



# Extract the file extension from input.
#
# Examples:
# _koopa_file_ext "hello-world.txt"
# ## txt
#
# _koopa_file_ext "hello-world.tar.gz"
# ## gz
#
# See also: _koopa_basename_sans_ext
#
# Updated 2019-09-26.
_koopa_file_ext() {
    printf "%s\n" "${1##*.}"
}



# Extract the file extension after any dots in the file name.
# This assumes file names are not in dotted case.
#
# Examples:
# _koopa_file_ext2 "hello-world.tar.gz"
# ## tar.gz
#
# See also: _koopa_basename_sans_ext2
#
# Updated 2019-09-26.
_koopa_file_ext2() {
    echo "$1" | cut -d '.' -f 2-
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
