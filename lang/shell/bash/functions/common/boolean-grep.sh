#!/usr/bin/env bash

koopa:::file_detect() { # {{{1
    # """
    # Is a string defined in a file?
    # @note Updated 2022-01-10.
    #
    # Uses ripgrep instead of grep when possible (faster).
    #
    # @examples
    # koopa::file_detect_fixed 'FILE' 'PATTERN'
    # koopa::file_detect_regex 'FILE' '^PATTERN.+$'
    #
    # stdin support:
    # echo 'FILE' | koopa::file_detect_fixed - 'PATTERN'
    # echo 'FILE' | koopa::file_detect_regex - '^PATTERN.+$'
    # """
    local engine file grep grep_args mode pattern pos
    koopa::assert_has_args "$#"
    grep="$(koopa::locate_rg 2>/dev/null || true)"
    [[ ! -x "$grep" ]] && grep="$(koopa::locate_grep)"
    engine="$(koopa::basename "$grep")"
    # Converting into an array here so we can prepend sudo, if necessary.
    grep=("$grep")
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--mode='*)
                mode="${1#*=}"
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
        file="${1:?}"
        pattern="${2:?}"
    fi
    grep_args=()
    case "$engine" in
        'rg')
            grep_args+=(
                '--case-sensitive'
                '--engine' 'default'
                '--no-config'
                '--no-ignore'
                '--one-file-system'
                '--quiet'
            )
            case "$mode" in
                'fixed')
                    grep_args+=('--fixed-strings')
                    ;;
                'regex')
                    ;;
            esac
            ;;
        'grep')
            # Using short flags here for BSD compatibility.
            grep_args+=('-q')  # --quiet
            case "$mode" in
                'fixed')
                    grep_args+=('-F')  # --fixed-strings
                    ;;
                'regex')
                    grep_args+=('-E')  # --extended-regexp
                    ;;
            esac
            ;;
    esac
    koopa::assert_is_file "$file"
    koopa::assert_is_readable "$file"
    "${grep[@]}" "${grep_args[@]}" "$pattern" "$file" >/dev/null
}

koopa:::str_detect() { # {{{1
    # """
    # Does the input match a string?
    # @note Updated 2022-01-10.
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
    # koopa::str_detect_fixed 'STRING' 'PATTERN'
    # koopa::str_detect_regex 'STRING' '^PATTERN.+$'
    #
    # stdin support:
    # echo 'STRING' | koopa::str_detect_fixed - 'PATTERN'
    # echo 'STRING' | koopa::str_detect_regex - '^PATTERN.+$'
    #
    # @seealso
    # - https://bugzilla.redhat.com/show_bug.cgi?id=1589997
    # - https://unix.stackexchange.com/questions/233987
    # """
    local engine grep grep_args mode pattern pos string
    koopa::assert_has_args "$#"
    # Converting into an array here so we can prepend sudo, if necessary.
    grep=("$(koopa::locate_grep)")
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--mode='*)
                mode="${1#*=}"
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
        pattern="${2:?}"
    fi
    # Using short flags here for BSD compatibility.
    grep_args=('-q')
    case "$mode" in
        'fixed')
            grep_args+=('-F')  # --fixed-strings
            ;;
        'regex')
            grep_args+=('-E')  # --extended-regexp
            ;;
    esac
    koopa::print "$string" \
        | "${grep[@]}" "${grep_args[@]}" "$pattern" >/dev/null
}

koopa::file_detect_fixed() { # {{{1
    # """
    # Does the input file match a fixed string?
    # @note Updated 2022-01-10.
    # """
    koopa:::file_detect --mode='fixed' "$@"
}

koopa::file_detect_regex() { # {{{1
    # """
    # Does the input file match a regular expression?
    # @note Updated 2022-01-10.
    # """
    koopa:::file_detect --mode='regex' "$@"
}

koopa::str_detect_fixed() { # {{{1
    # """
    # Does the input match a fixed string?
    # @note Updated 2022-01-10.
    # """
    koopa:::str_detect --mode='fixed' "$@"
}

koopa::str_detect_regex() { # {{{1
    # """
    # Does the input match a regular expression?
    # @note Updated 2022-01-10.
    # """
    koopa:::str_detect --mode='regex' "$@"
}
