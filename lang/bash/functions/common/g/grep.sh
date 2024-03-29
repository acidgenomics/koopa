#!/usr/bin/env bash

koopa_grep() {
    # """
    # grep matching: print lines that match patterns in a string or file.
    # @note Updated 2023-04-06.
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
    local -A app dict
    local -a grep_args grep_cmd
    koopa_assert_has_args "$#"
    dict['boolean']=0
    dict['engine']="${KOOPA_GREP_ENGINE:-}"
    dict['file']=''
    dict['invert_match']=0
    dict['only_matching']=0
    dict['mode']='fixed' # or 'regex'.
    dict['pattern']=''
    dict['stdin']=1
    dict['string']=''
    dict['sudo']=0
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--engine='*)
                dict['engine']="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict['engine']="${2:?}"
                shift 2
                ;;
            '--file='*)
                dict['file']="${1#*=}"
                dict['stdin']=0
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                dict['stdin']=0
                shift 2
                ;;
            '--mode='*)
                dict['mode']="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict['mode']="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict['string']="${1#*=}"
                dict['stdin']=0
                shift 1
                ;;
            '--string')
                # Allowing empty string to propagate here.
                dict['string']="${2:-}"
                dict['stdin']=0
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--boolean' | \
            '--quiet')
                dict['boolean']=1
                shift 1
                ;;
            '--regex' | \
            '--extended-regexp')
                dict['mode']='regex'
                shift 1
                ;;
            '--fixed' | \
            '--fixed-strings')
                dict['mode']='fixed'
                shift 1
                ;;
            '--invert-match')
                dict['invert_match']=1
                shift 1
                ;;
            '--only-matching')
                dict['only_matching']=1
                shift 1
                ;;
            '--sudo')
                dict['sudo']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-')
                dict['stdin']=1
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict['pattern']}"
    case "${dict['engine']}" in
        '')
            app['grep']="$(koopa_locate_rg --allow-missing)"
            [[ -x "${app['grep']}" ]] && dict['engine']='rg'
            if [[ -z "${dict['engine']}" ]]
            then
                dict['engine']='grep'
                app['grep']="$(koopa_locate_grep --allow-system)"
            fi
            ;;
        'grep')
            app['grep']="$(koopa_locate_grep --allow-system)"
            ;;
        'rg')
            app['grep']="$(koopa_locate_ripgrep)"
            ;;
    esac
    # Piped input using stdin (string mode).
    if [[ "${dict['stdin']}" -eq 1 ]]
    then
        dict['string']="$(</dev/stdin)"
    fi
    # Check that user isn't mixing up file and string mode.
    if [[ -n "${dict['file']}" ]] && [[ -n "${dict['string']}" ]]
    then
        koopa_stop "Use '--file' or '--string', but not both."
    fi
    grep_cmd=("${app['grep']}")
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        grep_cmd=('koopa_sudo' "${grep_cmd[@]}")
    fi
    grep_args=()
    case "${dict['engine']}" in
        'grep')
            # Using short flags for BSD compatibility here.
            case "${dict['mode']}" in
                'fixed')
                    grep_args+=('-F')
                    ;;
                'regex')
                    grep_args+=('-E')
                    ;;
            esac
            [[ "${dict['invert_match']}" -eq 1 ]] && \
                grep_args+=('-v')  # --invert-match
            [[ "${dict['only_matching']}" -eq 1 ]] && \
                grep_args+=('-o')  # --only-matching
            [[ "${dict['boolean']}" -eq 1 ]] && \
                grep_args+=('-q')  # --quiet
            ;;
        'rg')
            grep_args+=('--no-config' '--case-sensitive')
            if [[ -n "${dict['file']}" ]]
            then
                grep_args+=('--no-ignore' '--one-file-system')
            fi
            case "${dict['mode']}" in
                'fixed')
                    grep_args+=('--fixed-strings')
                    ;;
                'regex')
                    grep_args+=('--engine' 'default')
                    ;;
            esac
            [[ "${dict['invert_match']}" -eq 1 ]] && \
                grep_args+=('--invert-match')
            [[ "${dict['only_matching']}" -eq 1 ]] && \
                grep_args+=('--only-matching')
            [[ "${dict['boolean']}" -eq 1 ]] && \
                grep_args+=('--quiet')
            ;;
        *)
            koopa_stop 'Invalid grep engine.'
            ;;
    esac
    grep_args+=("${dict['pattern']}")
    koopa_assert_is_executable "${app[@]}"
    if [[ -n "${dict['file']}" ]]
    then
        # File mode.
        koopa_assert_is_file "${dict['file']}"
        koopa_assert_is_readable "${dict['file']}"
        grep_args+=("${dict['file']}")
        if [[ "${dict['boolean']}" -eq 1 ]]
        then
            "${grep_cmd[@]}" "${grep_args[@]}" >/dev/null
        else
            "${grep_cmd[@]}" "${grep_args[@]}"
        fi
    else
        # String mode.
        if [[ "${dict['boolean']}" -eq 1 ]]
        then
            koopa_print "${dict['string']}" \
                | "${grep_cmd[@]}" "${grep_args[@]}" >/dev/null
        else
            koopa_print "${dict['string']}" \
                | "${grep_cmd[@]}" "${grep_args[@]}"
        fi
    fi
}
