#!/usr/bin/env bash

koopa:::file_detect() { # {{{1
    # """
    # Is a string defined in a file?
    # @note Updated 2022-02-17.
    #
    # Uses ripgrep instead of grep when possible (faster).
    #
    # @usage
    # koopa::file_detect_fixed --file=FILE --pattern='PATTERN'
    # koopa::file_detect_regex --file=FILE --pattern='^PATTERN.+$'
    #
    # stdin support:
    # echo FILE | koopa::file_detect_fixed - --pattern='PATTERN'
    # echo FILE | koopa::file_detect_regex - --pattern='^PATTERN.+$'
    # """
    local app dict grep grep_args
    koopa::assert_has_args "$#"
    declare -A app=(
        [grep]="$(koopa::locate_rg 2>/dev/null || true)"
    )
    [[ ! -x "${app[grep]}" ]] && app[grep]="$(koopa::locate_grep)"
    declare -A dict=(
        [engine]="$(koopa::basename "${app[grep]}")"
        [file]=''
        [mode]=''
        [pattern]=''
        [stdin]=0
        [sudo]=0
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict[file]="${1#*=}"
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                shift 2
                ;;
            '--mode='*)
                dict[mode]="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict[mode]="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--sudo')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-')
                dict[stdin]=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    # Piped input using stdin.
    if [[ "${dict[stdin]}" -eq 1 ]]
    then
        read -r -d '' "dict[file]"
    fi
    koopa::assert_is_set \
        '--file' "${dict[file]}" \
        '--mode' "${dict[mode]}" \
        '--pattern' "${dict[pattern]}"
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        grep=('sudo' "${grep[@]}")
    else
        grep=("${app[grep]}")
    fi
    grep_args=()
    case "${dict[engine]}" in
        'rg')
            grep_args+=(
                '--case-sensitive'
                '--engine' 'default'
                '--no-config'
                '--no-ignore'
                '--one-file-system'
                '--quiet'
            )
            case "${dict[mode]}" in
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
            case "${dict[mode]}" in
                'fixed')
                    grep_args+=('-F')  # --fixed-strings
                    ;;
                'regex')
                    grep_args+=('-E')  # --extended-regexp
                    ;;
            esac
            ;;
    esac
    koopa::assert_is_file "${dict[file]}"
    koopa::assert_is_readable "${dict[file]}"
    grep_args+=("${dict[pattern]}" "${dict[file]}")
    "${grep[@]}" "${grep_args[@]}" >/dev/null
}

koopa:::str_detect() { # {{{1
    # """
    # Does the input match a string?
    # @note Updated 2022-02-17.
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
    # @usage
    # koopa::str_detect_fixed --string=STRING --pattern='PATTERN'
    # koopa::str_detect_regex --string=STRING --pattern='^PATTERN.+$'
    #
    # stdin support:
    # echo STRING | koopa::str_detect_fixed - --pattern='PATTERN'
    # echo STRING | koopa::str_detect_regex - --pattern='^PATTERN.+$'
    #
    # @seealso
    # - https://bugzilla.redhat.com/show_bug.cgi?id=1589997
    # - https://unix.stackexchange.com/questions/233987
    # """
    local app dict grep grep_args
    koopa::assert_has_args "$#"
    declare -A app=(
        [grep]="$(koopa::locate_grep)"
    )
    declare -A dict=(
        [mode]=''
        [pattern]=''
        [stdin]=0
        [str]=''
        [sudo]=0
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--mode='*)
                dict[mode]="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict[mode]="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict[str]="${1#*=}"
                shift 1
                ;;
            '--string')
                dict[str]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--sudo')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-')
                dict[stdin]=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    # Piped input using stdin.
    if [[ "${dict[stdin]}" -eq 1 ]]
    then
        read -r -d '' "dict[str]"
    fi
    # Note that we're allowing empty string input here.
    koopa::assert_is_set \
        '--mode' "${dict[mode]}" \
        '--pattern' "${dict[pattern]}"
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        grep=('sudo' "${grep[@]}")
    else
        grep=("${app[grep]}")
    fi
    # Using short flags here for BSD compatibility.
    grep_args=('-q')
    case "${dict[mode]}" in
        'fixed')
            grep_args+=('-F')  # --fixed-strings
            ;;
        'regex')
            grep_args+=('-E')  # --extended-regexp
            ;;
    esac
    grep_args+=("${dict[pattern]}")
    koopa::print "${dict[str]}" \
        | "${grep[@]}" "${grep_args[@]}" >/dev/null
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
