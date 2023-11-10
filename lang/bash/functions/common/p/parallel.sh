#!/usr/bin/env bash

koopa_parallel() {
    # """
    # Run a command in parallel.
    # @note Updated 2023-11-10.
    #
    # The 'colsep' argument is potentially useful.
    #
    # @seealso
    # - https://www.gnu.org/software/parallel/
    # - https://stackoverflow.com/questions/14428609/
    # - https://stackoverflow.com/questions/6255286/
    #
    # @examples
    # # FIXME Need to add a good working example here with multiple arguments
    # # per line.
    # """
    local -A app dict
    local -a parallel_args
    koopa_assert_has_args "$#"
    app['parallel']="$(koopa_locate_parallel --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['arg_file']=''
    dict['command']=''
    dict['jobs']="$(koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--arg-file='*)
                dict['arg_file']="${1#*=}"
                shift 1
                ;;
            '--arg-file')
                dict['arg_file']="${2:?}"
                shift 2
                ;;
            '--command='*)
                dict['command']="${1#*=}"
                shift 1
                ;;
            '--command')
                dict['command']="${2:?}"
                shift 2
                ;;
            '--jobs='*)
                dict['jobs']="${1#*=}"
                shift 1
                ;;
            '--jobs')
                dict['jobs']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--arg-file' "${dict['arg_file']}" \
        '--command' "${dict['command']}" \
        '--jobs' "${dict['jobs']}"
    koopa_assert_is_matching_fixed \
        --pattern='{}' \
        --string="${dict['command']}"
    koopa_assert_is_file "${dict['arg_file']}"
    dict['arg_file']="$(koopa_realpath "${dict['arg_file']}")"
    parallel_args+=(
        '--arg-file' "${dict['arg_file']}"
        '--bar'
        '--eta'
        '--jobs' "${dict['jobs']}"
        '--progress'
        '--will-cite'
        "${dict['command']}"
    )
    "${app['parallel']}" "${parallel_args[@]}"
    return 0
}
