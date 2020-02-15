#!/bin/sh
# shellcheck disable=SC2039

_koopa_gsub() {  # {{{1
    # """
    # Global substitution.
    # @note Updated 2020-01-12.
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    local replacement
    replacement="${3:?}"
    echo "$string" | sed -E "s/${pattern}/${replacement}/g"
}

_koopa_snake_case() {  # {{{1
    # """
    # Simple snake case function.
    # @note Updated 2020-02-07.
    #
    # @seealso Exported 'snake-case' that uses R syntactic internally.
    #
    # @examples
    # _koopa_snake_case "hello world"
    # ## hello_world
    #
    # _koopa_snake_case "bcbio-nextgen.py"
    # ## bcbio_nextgen_py
    # """
    _koopa_gsub "${1:?}" "[^A-Za-z0-9_]" "_"
}

_koopa_strip_left() {  # {{{1
    # """
    # Strip pattern from left side (start) of string.
    # @note Updated 2019-09-22.
    #
    # @usage _koopa_strip_left "string" "pattern"
    #
    # @examples
    # _koopa_strip_left "The Quick Brown Fox" "The "
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    printf '%s\n' "${string##$pattern}"
}

_koopa_strip_right() {  # {{{1
    # """
    # Strip pattern from right side (end) of string.
    # @note Updated 2020-01-12.
    #
    # @usage _koopa_strip_right "string" "pattern"
    #
    # @examples
    # _koopa_strip_right "The Quick Brown Fox" " Fox"
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    printf '%s\n' "${string%%$pattern}"
}

_koopa_strip_trailing_slash() {  # {{{1
    # """
    # Strip trailing slash in file path string.
    # @note Updated 2020-01-12.
    #
    # Alternate approach using sed:
    # > sed 's/\/$//' <<< "$1"
    #
    # @examples
    # _koopa_strip_trailing_slash "dir/"
    # """
    local file
    file="${1:?}"
    _koopa_strip_right "$file" "/"
}

_koopa_sub() {  # {{{1
    # """
    # Substitution.
    # @note Updated 2020-01-12.
    # @seealso _koopa_gsub (for global matching).
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    local replacement
    replacement="${3:?}"
    echo "$string" | sed -E "s/${pattern}/${replacement}/"
}

_koopa_trim_ws() {  # {{{1
    # """
    # Trim leading and trailing white-space from string.
    # @note Updated 2020-01-12.
    #
    # This is an alternative to sed, awk, perl and other tools. The function
    # works by finding all leading and trailing white-space and removing it from
    # the start and end of the string.
    #
    # @examples
    # _koopa_trim_ws "    Hello,  World    "
    # """
    local string
    string="${1:?}"
    string="${string#${string%%[![:space:]]*}}"
    string="${string%${string##*[![:space:]]}}"
    printf '%s\n' "$string"
}
