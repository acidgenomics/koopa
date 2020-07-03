#!/bin/sh
# shellcheck disable=SC2039

_koopa_gsub() { # {{{1
    # """
    # Global substitution.
    # @note Updated 2020-07-01.
    #
    # Instead of using '|' in sed here, we can also escape '/'.
    #
    # @examples
    # _koopa_gsub "a" "" "aabb" "aacc"
    # ## bb
    # ## cc
    # """
    _koopa_assert_has_args_ge "$#" 3
    _koopa_assert_is_installed sed
    local pattern replacement string
    pattern="${1:?}"
    replacement="${2:-}"
    shift 2
    for string in "$@"
    do
        _koopa_print "$string" | sed -E "s|${pattern}|${replacement}|g"
    done
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
    _koopa_assert_has_args "$#"
    _koopa_assert_is_installed tr
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
    # @seealso
    # - Exported 'snake-case' that uses R syntactic internally.
    #
    # @examples
    # _koopa_snake_case "hello world"
    # ## hello_world
    #
    # _koopa_snake_case "bcbio-nextgen.py"
    # ## bcbio_nextgen_py
    # """
    _koopa_assert_has_args "$#"
    _koopa_gsub "[^A-Za-z0-9_]" "_" "$@"
    return 0
}

_koopa_strip_left() { # {{{1
    # """
    # Strip pattern from left side (start) of string.
    # @note Updated 2020-07-01.
    #
    # @usage _koopa_strip_left "string" "pattern"
    #
    # @examples
    # _koopa_strip_left "The " "The Quick Brown Fox" "The White Lady"
    # ## Quick Brown Fox
    # ## White Lady
    # """
    _koopa_assert_has_args_ge "$#" 2
    local pattern string
    pattern="${1:?}"
    shift 1
    for string in "$@"
    do
        printf "%s\n" "${string##$pattern}"
    done
    return 0
}

_koopa_strip_right() { # {{{1
    # """
    # Strip pattern from right side (end) of string.
    # @note Updated 2020-07-01.
    #
    # @usage _koopa_strip_right "string" "pattern"
    #
    # @examples
    # _koopa_strip_right " Fox" "The Quick Brown Fox" "Michael J. Fox"
    # ## The Quick Brown
    # ## Michael J.
    # """
    _koopa_assert_has_args_ge "$#" 2
    local pattern string
    pattern="${1:?}"
    shift 1
    for string in "$@"
    do
        printf '%s\n' "${string%%$pattern}"
    done
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
    # ## ./dir1
    # ## ./dir2
    # """
    _koopa_assert_has_args "$#"
    _koopa_strip_right "/" "$@"
    return 0
}

_koopa_sub() { # {{{1
    # """
    # Substitution.
    # @note Updated 2020-07-01.
    #
    # Instead of using '|' in sed here, we can also escape '/'.
    #
    # @seealso _koopa_gsub (for global matching).
    # @examples
    # _koopa_sub "a" "" "aaa" "aaa"
    # ## aa
    # ## aa
    # """
    _koopa_assert_has_args_ge "$#" 3
    _koopa_assert_is_installed sed
    local pattern replacement string
    pattern="${1:?}"
    replacement="${2:-}"
    shift 2
    for string in "$@"
    do
        _koopa_print "$string" | sed -E "s|${pattern}|${replacement}|"
    done
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
    _koopa_assert_has_args "$#"
    local string
    for string in "$@"
    do
        string="${string#${string%%[![:space:]]*}}"
        string="${string%${string##*[![:space:]]}}"
        _koopa_print "$string"
    done
    return 0
}
