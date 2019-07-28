#!/bin/sh
# shellcheck disable=SC2039



# Get version stored internally in versions.txt file.
# Updated 2019-06-27.
_koopa_variable() {
    local what
    local file
    local match

    what="$1"
    file="${KOOPA_HOME}/system/include/variables.txt"
    match="$(grep -E "^${what}=" "$file" || echo "")"

    if [ -n "$match" ]
    then
        echo "$match" | cut -d "\"" -f 2
    else
        >&2 printf "Error: %s not defined in %s.\n" "$what" "$file"
        return 1
    fi
}
