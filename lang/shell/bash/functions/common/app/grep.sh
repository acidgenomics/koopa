#!/usr/bin/env bash

koopa::grep() { # {{{1
    # """
    # grep matching.
    # @note Updated 2022-01-20.
    # """
    local app dict grep_cmd pos
    koopa::assert_has_args "$#"
    declare -A app=(
        [grep]="$(koopa::locate_grep)"
    )
    declare -A dict
    grep_cmd=("${app[grep]}")
    pos=()
    while (("$#"))
    do
        ## Passing short flags here for BSD compatibility.
        case "$1" in
            # Flags ------------------------------------------------------------
            '--extended-regexp')
                grep_cmd+=('-E')
                shift 1
                ;;
            '--fixed-strings')
                grep_cmd+=('-F')
                shift 1
                ;;
            '--invert-match')
                grep_cmd+=('-v')
                shift 1
                ;;
            '--only-matching')
                grep_cmd+=('-o')
                shift 1
                ;;
            '--sudo')
                grep_cmd=('sudo' "${grep_cmd[@]}")
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-')
                shift 1
                ;;
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    if [[ "$#" -eq 1 ]]
    then
        # Piped input using stdin.
        dict[pattern]="${1:?}"
        shift 1
        read -r -d '' "dict[string]"
        koopa::print "${dict[string]}" | "${grep_cmd[@]}" "${dict[pattern]}"
    else
        # File mode.
        koopa::assert_has_args_eq "$#" 2
        dict[pattern]="${1:?}"
        dict[file]="${2:?}"
        koopa::assert_is_file "${dict[file]}"
        koopa::assert_is_readable "${dict[file]}"
        "${grep_cmd[@]}" "${dict[pattern]}" "${dict[file]}"
    fi
    return 0
}
