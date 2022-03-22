#!/usr/bin/env bash

koopa_strip_left() { # {{{1
    # """
    # Strip pattern from left side (start) of string.
    # @note Updated 2022-03-01.
    #
    # @usage koopa_strip_left --pattern=PATTERN STRING...
    #
    # @examples
    # > koopa_strip_left \
    # >     --pattern='The ' \
    # >     'The Quick Brown Fox' \
    # >     'The White Lady'
    # # Quick Brown Fox
    # # White Lady
    # """
    local dict pos str
    declare -A dict=(
        [pattern]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict[pattern]}"
    [[ "${#pos[@]}" -eq 0 ]] && pos=("$(</dev/stdin)")
    for str in "${pos[@]}"
    do
        printf '%s\n' "${str##"${dict[pattern]}"}"
    done
    return 0
}

koopa_strip_right() { # {{{1
    # """
    # Strip pattern from right side (end) of string.
    # @note Updated 2022-03-01.
    #
    # @usage koopa_strip_right --pattern=PATTERN STRING...
    #
    # @examples
    # > koopa_strip_right \
    # >     --pattern=' Fox' \
    # >     'The Quick Brown Fox' \
    # >     'Michael J. Fox'
    # # The Quick Brown
    # # Michael J.
    # """
    local dict pos str
    declare -A dict=(
        [pattern]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict[pattern]}"
    [[ "${#pos[@]}" -eq 0 ]] && pos=("$(</dev/stdin)")
    for str in "${pos[@]}"
    do
        printf '%s\n' "${str%%"${dict[pattern]}"}"
    done
    return 0
}

koopa_strip_trailing_slash() { # {{{1
    # """
    # Strip trailing slash in file path string.
    # @note Updated 2022-03-01.
    #
    # Alternate approach using sed:
    # > sed 's/\/$//' <<< "$1"
    #
    # @usage koopa_strip_trailing_slash STRING...
    #
    # @examples
    # > koopa_strip_trailing_slash './dir1/' './dir2/'
    # # ./dir1
    # # ./dir2
    # """
    local args
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    koopa_strip_right --pattern='/' "${args[@]}"
    return 0
}

koopa_trim_ws() { # {{{1
    # """
    # Trim leading and trailing white-space from string.
    # @note Updated 2022-03-01.
    #
    # This is an alternative to sed, awk, perl and other tools. The function
    # works by finding all leading and trailing white-space and removing it from
    # the start and end of the string.
    #
    # We're allowing empty string input in this function.
    #
    # @examples
    # > koopa_trim_ws '  hello world  ' ' foo bar '
    # # hello world
    # # foo bar
    # """
    local args str
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for str in "${args[@]}"
    do
        str="${str#"${str%%[![:space:]]*}"}"
        str="${str%"${str##*[![:space:]]}"}"
        koopa_print "$str"
    done
    return 0
}
