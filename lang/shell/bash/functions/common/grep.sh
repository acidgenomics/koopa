#!/usr/bin/env bash

koopa_grep() { # {{{1
    # """
    # grep matching: print lines that match patterns in a string or file.
    # @note Updated 2022-02-24.
    #
    # Uses ripgrep instead of grep when possible (faster).
    # Consider passing short flags to 'grep' for BSD compatibility.
    #
    # @section grep matching modes:
    # * -E, --extended-regexp
    # * -F, --fixed strings
    # * -G, --basic-regexp
    # * -P, --perl-regexp
    #
    # Perl-compatible regular expressions (PCREs) support negative
    # lookaheads, which are often very useful. However, Perl regex isn't enabled
    # by default for all installations of grep.
    #
    # Usage of '--quiet' flag can cause an exit trap in 'set -e' mode.
    # Redirecting output to '/dev/null' works more reliably.
    #
    # @examples
    # > koopa_grep --pattern='aaa' --string='aaabbb'
    # """
    local app dict grep_args grep_cmd
    koopa_assert_has_args "$#"
    declare -A app
    declare -A dict=(
        [boolean]=0
        [engine]="${KOOPA_GREP_ENGINE:-}"
        [file]=''
        [invert_match]=0
        [only_matching]=0
        [mode]='fixed'  # or 'regex'
        [pattern]=''
        [stdin]=1
        [string]=''
        [sudo]=0
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--engine='*)
                dict[engine]="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict[engine]="${2:?}"
                shift 2
                ;;
            '--file='*)
                dict[file]="${1#*=}"
                dict[stdin]=0
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                dict[stdin]=0
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
            '--string='*)
                dict[string]="${1#*=}"
                dict[stdin]=0
                shift 1
                ;;
            '--string')
                # Allowing empty string to propagate here.
                dict[string]="${2:-}"
                dict[stdin]=0
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--boolean' | \
            '--quiet')
                dict[boolean]=1
                shift 1
                ;;
            '--regex' | \
            '--extended-regexp')
                dict[mode]='regex'
                shift 1
                ;;
            '--fixed' | \
            '--fixed-strings')
                dict[mode]='fixed'
                shift 1
                ;;
            '--invert-match')
                dict[invert_match]=1
                shift 1
                ;;
            '--only-matching')
                dict[only_matching]=1
                shift 1
                ;;
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict[pattern]}"
    if [[ -z "${dict[engine]}" ]]
    then
        app[grep]="$(koopa_locate_rg 2>/dev/null || true)"
        [[ ! -x "${app[grep]}" ]] && app[grep]="$(koopa_locate_grep)"
        dict[engine]="$(koopa_basename "${app[grep]}")"
    else
        app[grep]="$(koopa_locate_"${dict[engine]}")"
    fi
    koopa_assert_is_installed "${app[grep]}"
    # Piped input using stdin (string mode).
    if [[ "${dict[stdin]}" -eq 1 ]]
    then
        dict[string]="$(</dev/stdin)"
    fi
    # Check that user isn't mixing up file and string mode.
    if [[ -n "${dict[file]}" ]] && [[ -n "${dict[string]}" ]]
    then
        koopa_stop "Use '--file' or '--string', but not both."
    fi
    grep_cmd=("${app[grep]}")
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        grep_cmd=('sudo' "${grep_cmd[@]}")
    fi
    grep_args=()
    case "${dict[engine]}" in
        'grep')
            # Using short flags for BSD compatibility here.
            case "${dict[mode]}" in
                'fixed')
                    grep_args+=('-F')
                    ;;
                'regex')
                    grep_args+=('-E')
                    ;;
            esac
            [[ "${dict[invert_match]}" -eq 1 ]] && \
                grep_args+=('-v')  # --invert-match
            [[ "${dict[only_matching]}" -eq 1 ]] && \
                grep_args+=('-o')  # --only-matching
            [[ "${dict[boolean]}" -eq 1 ]] && \
                grep_args+=('-q')  # --quiet
            ;;
        'rg')
            grep_args+=(
                '--case-sensitive'
            )
            if [[ -n "${dict[file]}" ]]
            then
                grep_args+=(
                    '--no-config'
                    '--no-ignore'
                    '--one-file-system'
                )
            fi
            case "${dict[mode]}" in
                'fixed')
                    grep_args+=('--fixed-strings')
                    ;;
                'regex')
                    grep_args+=('--engine' 'default')
                    ;;
            esac
            [[ "${dict[invert_match]}" -eq 1 ]] && \
                grep_args+=('--invert-match')
            [[ "${dict[only_matching]}" -eq 1 ]] && \
                grep_args+=('--only-matching')
            [[ "${dict[boolean]}" -eq 1 ]] && \
                grep_args+=('--quiet')
            ;;
        *)
            koopa_stop 'Invalid grep engine.'
            ;;
    esac
    grep_args+=("${dict[pattern]}")
    if [[ -n "${dict[file]}" ]]
    then
        # File mode.
        koopa_assert_is_file "${dict[file]}"
        koopa_assert_is_readable "${dict[file]}"
        grep_args+=("${dict[file]}")
        if [[ "${dict[boolean]}" -eq 1 ]]
        then
            "${grep_cmd[@]}" "${grep_args[@]}" >/dev/null
        else
            "${grep_cmd[@]}" "${grep_args[@]}"
        fi
    else
        # String mode.
        if [[ "${dict[boolean]}" -eq 1 ]]
        then
            koopa_print "${dict[string]}" \
                | "${grep_cmd[@]}" "${grep_args[@]}" >/dev/null
        else
            koopa_print "${dict[string]}" \
                | "${grep_cmd[@]}" "${grep_args[@]}"
        fi
    fi
}

__koopa_file_detect() { # {{{1
    # """
    # Is a pattern defined in a file?
    # @note Updated 2022-02-23.
    #
    # Uses ripgrep instead of grep when possible (faster).
    #
    # @usage
    # koopa_file_detect_fixed --file=FILE --pattern='PATTERN'
    # koopa_file_detect_regex --file=FILE --pattern='^PATTERN.+$'
    #
    # stdin support:
    # echo FILE | koopa_file_detect_fixed --pattern='PATTERN'
    # echo FILE | koopa_file_detect_regex --pattern='^PATTERN.+$'
    # """
    local dict grep_args
    koopa_assert_has_args "$#"
    declare -A dict=(
        [file]=''
        [mode]=''
        [pattern]=''
        [stdin]=1
        [sudo]=0
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict[file]="${1#*=}"
                dict[stdin]=0
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                dict[stdin]=0
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    # Piped input using stdin (file mode).
    if [[ "${dict[stdin]}" -eq 1 ]]
    then
        dict[file]="$(</dev/stdin)"
    fi
    koopa_assert_is_set \
        '--file' "${dict[file]}" \
        '--mode' "${dict[mode]}" \
        '--pattern' "${dict[pattern]}"
    grep_args=(
        '--boolean'
        '--file' "${dict[file]}"
        '--mode' "${dict[mode]}"
        '--pattern' "${dict[pattern]}"
    )
    [[ "${dict[sudo]}" -eq 1 ]] && grep_args+=('--sudo')
    koopa_grep "${grep_args[@]}"
}

__koopa_str_detect() { # {{{1
    # """
    # Does the input pattern match a string?
    # @note Updated 2022-02-23.
    #
    # @usage
    # koopa_str_detect_fixed --string=STRING --pattern='PATTERN'
    # koopa_str_detect_regex --string=STRING --pattern='^PATTERN.+$'
    #
    # stdin support:
    # echo STRING | koopa_str_detect_fixed --pattern='PATTERN'
    # echo STRING | koopa_str_detect_regex --pattern='^PATTERN.+$'
    #
    # @seealso
    # - https://bugzilla.redhat.com/show_bug.cgi?id=1589997
    # - https://unix.stackexchange.com/questions/233987
    # """
    local dict grep_args
    koopa_assert_has_args "$#"
    declare -A dict=(
        [mode]=''
        [pattern]=''
        [stdin]=1
        [string]=''
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
                dict[string]="${1#*=}"
                dict[stdin]=0
                shift 1
                ;;
            '--string')
                # Allowing empty string to propagate here.
                dict[string]="${2:-}"
                dict[stdin]=0
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    # Piped input using stdin (string mode).
    if [[ "${dict[stdin]}" -eq 1 ]]
    then
        dict[string]="$(</dev/stdin)"
    fi
    # Note that we're allowing empty string input here.
    koopa_assert_is_set \
        '--mode' "${dict[mode]}" \
        '--pattern' "${dict[pattern]}"
    grep_args=(
        '--boolean'
        '--mode' "${dict[mode]}"
        '--pattern' "${dict[pattern]}"
        '--string' "${dict[string]}"
    )
    [[ "${dict[sudo]}" -eq 1 ]] && grep_args+=('--sudo')
    koopa_grep "${grep_args[@]}"
}

koopa_file_detect_fixed() { # {{{1
    __koopa_file_detect --mode='fixed' "$@"
}

koopa_file_detect_regex() { # {{{1
    __koopa_file_detect --mode='regex' "$@"
}

koopa_str_detect_fixed() { # {{{1
    __koopa_str_detect --mode='fixed' "$@"
}

koopa_str_detect_regex() { # {{{1
    __koopa_str_detect --mode='regex' "$@"
}
