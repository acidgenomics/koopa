#!/bin/sh

_koopa_print() {
    # """
    # Print a string.
    # @note Updated 2023-03-11.
    #
    # printf vs. echo
    # - http://www.etalabs.net/sh_tricks.html
    # - https://unix.stackexchange.com/questions/65803
    # - https://www.freecodecamp.org/news/
    #       how-print-newlines-command-line-output/
    # """
    if [ "$#" -eq 0 ]
    then
        printf '\n'
        return 0
    fi
    for __kvar_string in "$@"
    do
        printf '%b\n' "$__kvar_string"
    done
    unset __kvar_string
    return 0
}
