#!/bin/sh
# shellcheck disable=SC2039

# FIXME REORDER SO CAN WE PARAMETERIZE?
_koopa_gsub() { # {{{1
    # """
    # Global substitution.
    # @note Updated 2020-06-30.
    #
    # Instead of using '|' in sed here, we can also escape '/'.
    # """
    [ "$#" -ge 2 ] && [ "$#" -le 3 ] || return 1
    _koopa_is_installed sed || return 1
    local pattern replacement string
    string="${1:?}"
    pattern="${2:?}"
    replacement="${3:-}"
    _koopa_print "$string" | sed -E "s|${pattern}|${replacement}|g"
    return 0
}

_koopa_lowercase() { # {{{1
    # """
    # Transform string to lowercase.
    # @note Updated 2020-06-30.
    #
    # awk alternative:
    # _koopa_print "$string" | awk '{print tolower($0)}'
    #
    # @seealso
    # https://stackoverflow.com/questions/2264428
    # """
    [ "$#" -gt 0 ] || return 1
    _koopa_is_installed tr || return 1
    local string
    for string in "$@"
    do
        _koopa_print "$string" | tr "[:upper:]" "[:lower:]"
    done
    return 0
}

_koopa_snake_case() { # {{{1
    # """
    # Simple snake case function.
    # @note Updated 2020-07-01.
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
    [ "$#" -gt 0 ] || return 1
    local string
    string="${1:?}"
    for string in "$@"
    do
        _koopa_gsub "$string" "[^A-Za-z0-9_]" "_"
    done
    return 0
}

# FIXME REORDER SO CAN WE PARAMETERIZE?
_koopa_strip_left() { # {{{1
    # """
    # Strip pattern from left side (start) of string.
    # @note Updated 2020-07-01.
    #
    # @usage _koopa_strip_left "string" "pattern"
    #
    # @examples
    # _koopa_strip_left "The Quick Brown Fox" "The "
    # """
    [ "$#" -eq 2 ] || return 1
    local pattern string
    string="${1:?}"
    pattern="${2:?}"
    printf '%s\n' "${string##$pattern}"
    return 0
}

# FIXME REORDER SO CAN WE PARAMETERIZE?
_koopa_strip_right() { # {{{1
    # """
    # Strip pattern from right side (end) of string.
    # @note Updated 2020-07-01.
    #
    # @usage _koopa_strip_right "string" "pattern"
    #
    # @examples
    # _koopa_strip_right "The Quick Brown Fox" " Fox"
    # """
    local pattern string
    string="${1:?}"
    pattern="${2:?}"
    printf '%s\n' "${string%%$pattern}"
    return 0
}

_koopa_strip_trailing_slash() { # {{{1
    # """
    # Strip trailing slash in file path string.
    # @note Updated 2020-07-01.
    #
    # Alternate approach using sed:
    # > sed 's/\/$//' <<< "$1"
    #
    # @examples
    # _koopa_strip_trailing_slash "./dir1/" "./dir2/"
    # """
    [ "$#" -gt 0 ] || return 1
    local string
    for string in "$@"
    do
        _koopa_strip_right "$string" '/'
    done
    return 0
}

# FIXME REORDER SO CAN WE PARAMETERIZE?
_koopa_sub() { # {{{1
    # """
    # Substitution.
    # @note Updated 2020-07-01.
    #
    # Instead of using '|' in sed here, we can also escape '/'.
    #
    # @seealso _koopa_gsub (for global matching).
    # """
    _koopa_is_installed sed || return 1
    local pattern replacement string
    string="${1:?}"
    pattern="${2:?}"
    replacement="${3:-}"
    _koopa_print "$string" | sed -E "s|${pattern}|${replacement}|"
    return 0
}

_koopa_trim_ws() { # {{{1
    # """
    # Trim leading and trailing white-space from string.
    # @note Updated 2020-07-01.
    #
    # This is an alternative to sed, awk, perl and other tools. The function
    # works by finding all leading and trailing white-space and removing it from
    # the start and end of the string.
    #
    # We're allowing empty string input in this function.
    #
    # @examples
    # _koopa_trim_ws "  hello world  " " foo bar "
    # """
    [ "$#" -gt 0 ] || return 1
    local string
    for string in "$@"
    do
        string="${string#${string%%[![:space:]]*}}"
        string="${string%${string##*[![:space:]]}}"
        _koopa_print "$string"
    done
    return 0
}
