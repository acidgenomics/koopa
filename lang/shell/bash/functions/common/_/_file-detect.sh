#!/usr/bin/env bash

__koopa_file_detect() {
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
