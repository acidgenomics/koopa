#!/usr/bin/env bash

koopa::grep() { # {{{1
    # """
    # grep matching.
    # @note Updated 2021-10-27.
    # """
    local grep pos string
    koopa::assert_has_args "$#"
    grep=("$(koopa::locate_grep)")
    grep_args=()
    pos=()
    while (("$#"))
    do
        ## Passing short flags here for BSD compatibility.
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--extended-regexp')
                grep_args+=('-E')
                shift 1
                ;;
            '--invert-match')
                grep_args+=('-v')
                shift 1
                ;;
            '--only-matching')
                grep_args+=('-o')
                shift 1
                ;;
            # Flags ------------------------------------------------------------
            '--sudo')
                grep=('sudo' "${grep[@]}")
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
        pattern="${1:?}"
        shift 1
        read -r -d '' string
        koopa::print "$string" | "${grep[@]}" "${grep_args[@]}" "$pattern"
    else
        # File mode.
        koopa::assert_has_args_eq "$#" 2
        pattern="${1:?}"
        file="${2:?}"
        koopa::assert_is_file "$file"
        koopa::assert_is_readable "$file"
        "${grep[@]}" "${grep_args[@]}" "$pattern" "$file"
    fi
    return 0
}
