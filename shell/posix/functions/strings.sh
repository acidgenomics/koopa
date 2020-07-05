#!/bin/sh

koopa::gsub() { # {{{1
    # """
    # Global substitution.
    # @note Updated 2020-07-01.
    #
    # Instead of using '|' in sed here, we can also escape '/'.
    #
    # @examples
    # koopa::gsub "a" "" "aabb" "aacc"
    # ## bb
    # ## cc
    # """
    koopa::assert_has_args_ge "$#" 3
    koopa::assert_is_installed sed
    local pattern replacement string
    pattern="${1:?}"
    replacement="${2:-}"
    shift 2
    for string in "$@"
    do
        koopa::print "$string" | sed -E "s|${pattern}|${replacement}|g"
    done
    return 0
}

koopa::lowercase() { # {{{1
    # """
    # Transform string to lowercase.
    # @note Updated 2020-06-30.
    #
    # awk alternative:
    # koopa::print "$string" | awk '{print tolower($0)}'
    #
    # @seealso
    # https://stackoverflow.com/questions/2264428
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed tr
    local string
    for string in "$@"
    do
        koopa::print "$string" | tr "[:upper:]" "[:lower:]"
    done
    return 0
}

koopa::snake_case() { # {{{1
    # """
    # Simple snake case function.
    # @note Updated 2020-07-01.
    #
    # @seealso
    # - Exported 'snake-case' that uses R syntactic internally.
    #
    # @examples
    # koopa::snake_case "hello world"
    # ## hello_world
    #
    # koopa::snake_case "bcbio-nextgen.py"
    # ## bcbio_nextgen_py
    # """
    koopa::assert_has_args "$#"
    koopa::gsub "[^A-Za-z0-9_]" "_" "$@"
    return 0
}

koopa::strip_left() { # {{{1
    # """
    # Strip pattern from left side (start) of string.
    # @note Updated 2020-07-01.
    #
    # @usage koopa::strip_left "string" "pattern"
    #
    # @examples
    # koopa::strip_left "The " "The Quick Brown Fox" "The White Lady"
    # ## Quick Brown Fox
    # ## White Lady
    # """
    koopa::assert_has_args_ge "$#" 2
    local pattern string
    pattern="${1:?}"
    shift 1
    for string in "$@"
    do
        printf "%s\n" "${string##$pattern}"
    done
    return 0
}

koopa::strip_right() { # {{{1
    # """
    # Strip pattern from right side (end) of string.
    # @note Updated 2020-07-01.
    #
    # @usage koopa::strip_right "string" "pattern"
    #
    # @examples
    # koopa::strip_right " Fox" "The Quick Brown Fox" "Michael J. Fox"
    # ## The Quick Brown
    # ## Michael J.
    # """
    koopa::assert_has_args_ge "$#" 2
    local pattern string
    pattern="${1:?}"
    shift 1
    for string in "$@"
    do
        printf '%s\n' "${string%%$pattern}"
    done
    return 0
}

koopa::strip_trailing_slash() { # {{{1
    # """
    # Strip trailing slash in file path string.
    # @note Updated 2020-07-01.
    #
    # Alternate approach using sed:
    # > sed 's/\/$//' <<< "$1"
    #
    # @examples
    # koopa::strip_trailing_slash "./dir1/" "./dir2/"
    # ## ./dir1
    # ## ./dir2
    # """
    koopa::assert_has_args "$#"
    koopa::strip_right "/" "$@"
    return 0
}

koopa::sub() { # {{{1
    # """
    # Substitution.
    # @note Updated 2020-07-01.
    #
    # Instead of using '|' in sed here, we can also escape '/'.
    #
    # @seealso koopa::gsub (for global matching).
    # @examples
    # koopa::sub "a" "" "aaa" "aaa"
    # ## aa
    # ## aa
    # """
    koopa::assert_has_args_ge "$#" 3
    koopa::assert_is_installed sed
    local pattern replacement string
    pattern="${1:?}"
    replacement="${2:-}"
    shift 2
    for string in "$@"
    do
        koopa::print "$string" | sed -E "s|${pattern}|${replacement}|"
    done
    return 0
}

koopa::trim_ws() { # {{{1
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
    # koopa::trim_ws "  hello world  " " foo bar "
    # """
    koopa::assert_has_args "$#"
    local string
    for string in "$@"
    do
        string="${string#${string%%[![:space:]]*}}"
        string="${string%${string##*[![:space:]]}}"
        koopa::print "$string"
    done
    return 0
}
