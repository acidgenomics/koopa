#!/usr/bin/env bash

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
    if [[ "$#" -eq 2 ]]
    then
        # Standard input.
        file="${1:?}"
        pattern="${2:?}"
    elif [[ "$#" -eq 1 ]]
    then
        # Piped input using stdin.
        pattern="${1:?}"
        shift 1
        read -r file
    else
        return 1
    fi
    [[ -f "$file" ]] || return 1
    grep -Fq "$pattern" "$file" >/dev/null
}

koopa::file_match_regex() { # {{{1
    # """
    # Is a string defined in a file?
    # @note Updated 2020-04-30.
    # """
    local file pattern
    koopa::assert_has_args "$#"
    if [[ "$#" -eq 2 ]]
    then
        # Standard input.
        file="${1:?}"
        pattern="${2:?}"
    elif [[ "$#" -eq 1 ]]
    then
        # Piped input using stdin.
        pattern="${1:?}"
        shift 1
        read -r file
    else
        return 1
    fi
    [[ -f "$file" ]] || return 1
    grep -Eq "$pattern" "$file" >/dev/null
}
