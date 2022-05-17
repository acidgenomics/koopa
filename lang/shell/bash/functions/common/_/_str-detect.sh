#!/usr/bin/env bash

__koopa_str_detect() {
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
