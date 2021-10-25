#!/usr/bin/env bash

koopa:::file_match() { # {{{1
    # """
    # Is a string defined in a file?
    # @note Updated 2021-10-25.
    #
    # @examples
    # koopa::file_match_fixed 'FILE' 'PATTERN'
    # koopa::file_match_regex 'FILE' '^PATTERN.+$'
    #
    # stdin support:
    # echo 'FILE' | koopa::file_match_fixed - 'PATTERN'
    # echo 'FILE' | koopa::file_match_regex - '^PATTERN.+$'
    # """
    local file grep grep_args pattern pos
    koopa::assert_has_args "$#"
    # FIXME Add support for ripgrep.
    grep="$(koopa::locate_grep)"
    grep_args=()
    grep_args+=('--quiet')  # -q
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--extended-regexp')
                grep_args+=('--extended-regexp')  # -E
                shift 1
                ;;
            '--fixed-strings')
                grep_args+=('--fixed-strings')  # -F
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -eq 1 ]]
    then
        # Piped input using stdin.
        pattern="${1:?}"
        shift 1
        read -r -d '' file
    else
        # Positional variable input.
        # Note that we're allowing empty string input here.
        koopa::assert_has_args_eq "$#" 2
        file="${1:-}"
        # Alternate piped input using stdin, with string set to '-'.
        [[ "$file" == '-' ]] && read -r -d '' file
        pattern="${2:?}"
    fi
    "$grep" "${grep_args[@]}" "$pattern" "$file" >/dev/null
}

koopa:::str_match() { # {{{1
    # """
    # Does the input match a string?
    # @note Updated 2021-10-25.
    #
    # Modes:
    # * -E, --extended-regexp
    # * -F, --fixed strings
    # * -G, --basic-regexp
    # * -P, --perl-regexp
    #
    # Perl-compatible regular expressions (PCREs) support negative
    # lookaheads, which are often very useful. However, Perl regex isn't enabled
    # by default for all installations of grep.
    #
    # Usage of '-q' flag can cause an exit trap in 'set -e' mode.
    # Redirecting output to '/dev/null' works more reliably.
    #
    # @examples
    # koopa::str_match_fixed 'STRING' 'PATTERN'
    # koopa::str_match_regex 'STRING' '^PATTERN.+$'
    #
    # stdin support:
    # echo 'STRING' | koopa::str_match_fixed - 'PATTERN'
    # echo 'STRING' | koopa::str_match_regex - '^PATTERN.+$'
    #
    # @seealso
    # - https://bugzilla.redhat.com/show_bug.cgi?id=1589997
    # - https://unix.stackexchange.com/questions/233987
    # """
    local grep grep_args pattern pos string
    koopa::assert_has_args "$#"
    grep="$(koopa::locate_grep)"
    grep_args=()
    grep_args+=('--quiet')  # -q
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--extended-regexp')
                grep_args+=('--extended-regexp')  # -E
                shift 1
                ;;
            '--fixed-strings')
                grep_args+=('--fixed-strings')  # -F
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -eq 1 ]]
    then
        # Piped input using stdin.
        pattern="${1:?}"
        shift 1
        read -r -d '' string
    else
        # Positional variable input.
        # Note that we're allowing empty string input here.
        koopa::assert_has_args_eq "$#" 2
        string="${1:-}"
        # Alternate piped input using stdin, with string set to '-'.
        [[ "$string" == '-' ]] && read -r -d '' string
        pattern="${2:?}"
    fi
    _koopa_print "$string" \
        | "$grep" "${grep_args[@]}" "$pattern" >/dev/null
}

koopa::file_match_fixed() { # {{{1
    # """
    # Does the input file match a fixed string?
    # @note Updated 2021-10-25.
    # """
    koopa:::file_match --fixed-strings "$@"
}

koopa::file_match_regex() { # {{{1
    # """
    # Does the input file match a regular expression?
    # @note Updated 2021-10-25.
    # """
    koopa:::file_match --extended-regexp "$@"
}

koopa::str_match_fixed() { # {{{1
    # """
    # Does the input match a fixed string?
    # @note Updated 2021-10-25.
    # """
    koopa:::str_match --fixed-strings "$@"
}

koopa::str_match_regex() { # {{{1
    # """
    # Does the input match a regular expression?
    # @note Updated 2021-10-25.
    # """
    koopa:::str_match --extended-regexp "$@"
}
