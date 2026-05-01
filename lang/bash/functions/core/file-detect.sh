#!/usr/bin/env bash

_koopa_file_detect() {
    # """
    # Is a pattern defined in a file?
    # @note Updated 2022-02-23.
    #
    # Uses ripgrep instead of grep when possible (faster).
    #
    # @usage
    # _koopa_file_detect_fixed --file=FILE --pattern='PATTERN'
    # _koopa_file_detect_regex --file=FILE --pattern='^PATTERN.+$'
    #
    # stdin support:
    # echo FILE | _koopa_file_detect_fixed --pattern='PATTERN'
    # echo FILE | _koopa_file_detect_regex --pattern='^PATTERN.+$'
    # """
    local -A dict
    local -a grep_args
    _koopa_assert_has_args "$#"
    dict['file']=''
    dict['mode']=''
    dict['pattern']=''
    dict['stdin']=1
    dict['sudo']=0
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
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
            # Flags ------------------------------------------------------------
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    # Piped input using stdin (file mode).
    if [[ "${dict['stdin']}" -eq 1 ]]
    then
        dict['file']="$(</dev/stdin)"
    fi
    _koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--mode' "${dict['mode']}" \
        '--pattern' "${dict['pattern']}"
    grep_args=(
        '--boolean'
        '--file' "${dict['file']}"
        '--mode' "${dict['mode']}"
        '--pattern' "${dict['pattern']}"
    )
    [[ "${dict['sudo']}" -eq 1 ]] && grep_args+=('--sudo')
    _koopa_grep "${grep_args[@]}"
}
