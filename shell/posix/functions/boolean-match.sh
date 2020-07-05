#!/bin/sh

# Details pipe support for reading stdin:
# https://stackoverflow.com/a/58452863/3911732

koopa::file_match() { # {{{1
    # """
    # Is a string defined in a file?
    # @note Updated 2020-04-30.
    #
    # @examples
    # koopa::file_match FILE PATTERN
    # echo FILE | koopa::file_match PATTERN
    # """
    koopa::assert_has_args "$#"
    local file pattern
    if [ "$#" -eq 2 ]
    then
        # Standard input.
        file="${1:?}"
        pattern="${2:?}"
    elif [ "$#" -eq 1 ]
    then
        # Piped input using stdin.
        pattern="${1:?}"
        shift 1
        read -r file
    else
        return 1
    fi
    [ -f "$file" ] || return 1
    grep -Fq "$pattern" "$file" >/dev/null
}

koopa::file_match_regex() { # {{{1
    # """
    # Is a string defined in a file?
    # @note Updated 2020-04-30.
    # """
    koopa::assert_has_args "$#"
    local file pattern
    if [ "$#" -eq 2 ]
    then
        # Standard input.
        file="${1:?}"
        pattern="${2:?}"
    elif [ "$#" -eq 1 ]
    then
        # Piped input using stdin.
        pattern="${1:?}"
        shift 1
        read -r file
    else
        return 1
    fi
    [ -f "$file" ] || return 1
    grep -Eq "$pattern" "$file" >/dev/null
}

koopa::str_match() { # {{{1
    # """
    # Does the input match a fixed string?
    # @note Updated 2020-05-05.
    #
    # Usage of '-q' flag can cause an exit trap in 'set -e' mode.
    # Redirecting output to '/dev/null' works more reliably.
    #
    # @seealso
    # - https://bugzilla.redhat.com/show_bug.cgi?id=1589997
    # - https://unix.stackexchange.com/questions/233987
    #
    # @examples
    # koopa::str_match STRING PATTERN
    # echo STRING | koopa::str_match PATTERN
    # """
    koopa::assert_has_args "$#"
    local string pattern
    if [ "$#" -eq 2 ]
    then
        # Standard input.
        # Note that we're allowing empty string input here.
        string="${1:-}"
        pattern="${2:?}"
    elif [ "$#" -eq 1 ]
    then
        # Piped input using stdin.
        pattern="${1:?}"
        shift 1
        # Handle string with line breaks '\n'.
        read -r -d '' string
    else
        return 1
    fi
    echo "$string" | grep -Fq "$pattern" >/dev/null
}

koopa::str_match_posix() { # {{{1
    # """
    # Evaluate whether a string contains a desired value.
    # @note Updated 2020-04-29.
    #
    # POSIX-compliant function that mimics grepl functionality.
    #
    # @seealso grepl in R.
    # """
    koopa::assert_has_args "$#"
    test "${1#*$2}" != "$1"
}

koopa::str_match_regex() { # {{{1
    # """
    # Does the input match a regular expression?
    # @note Updated 2020-05-05.
    # """
    koopa::assert_has_args "$#"
    local string pattern
    if [ "$#" -eq 2 ]
    then
        # Standard input.
        # Note that we're allowing empty string input here.
        string="${1:-}"
        pattern="${2:?}"
    elif [ "$#" -eq 1 ]
    then
        # Piped input using stdin.
        pattern="${1:?}"
        shift 1
        # Handle string with line breaks '\n'.
        read -r -d '' string
    else
        return 1
    fi
    echo "$string" | grep -Eq "$pattern" >/dev/null
}
