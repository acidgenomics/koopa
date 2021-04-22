#!/usr/bin/env bash

koopa::help() { # {{{1
    # """
    # Show usage via '--help' flag.
    # @note Updated 2020-07-05.
    # """
    local arg args first_arg last_arg man_file prefix script_name
    [[ "$#" -eq 0 ]] && return 0
    [[ "${1:-}" == "" ]] && return 0
    first_arg="${1:?}"
    last_arg="${!#}"
    args=("$first_arg" "$last_arg")
    for arg in "${args[@]}"
    do
        case "$arg" in
            --help|-h)
                koopa::assert_is_installed man
                file="$(koopa::realpath "$0")"
                script_name="$(basename "$file")"
                prefix="$(dirname "$(dirname "$file")")"
                man_file="${prefix}/man/man1/${script_name}.1"
                if [[ -s "$man_file" ]]
                then
                    head -n 10 "$man_file" \
                        | koopa::str_match_regex '^\.TH ' \
                        || koopa::stop "Invalid documentation at '${man_file}'."
                else
                    koopa::stop "No documentation for '${script_name}'."
                fi
                man "$man_file"
                exit 0
                ;;
        esac
    done
    return 0
}
