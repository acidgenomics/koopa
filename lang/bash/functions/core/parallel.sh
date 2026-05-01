#!/usr/bin/env bash

_koopa_parallel() {
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
    # - https://stackoverflow.com/questions/23577047/
    #
    # @examples
    # > arg_file="$(_koopa_tmp_file)"
    # > printf '%s\n' 'aaa bbb' 'ccc ddd' 'eee fff' > "$arg_file"
    # > command="printf '[%s] [%s]\n' {}"
    # > _koopa_parallel --arg-file="$arg_file" --command="$command"
    # # [aaa] [bbb]
    # # [ccc] [ddd]
    # # [eee] [fff]
    # > _koopa_rm "$arg_file"
    # """
    local -A app dict
    local -a parallel_args
    _koopa_assert_has_args "$#"
    app['parallel']="$(_koopa_locate_parallel --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['arg_file']=''
    dict['command']=''
    dict['jobs']="$(_koopa_cpu_count)"
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--arg-file' "${dict['arg_file']}" \
        '--command' "${dict['command']}" \
        '--jobs' "${dict['jobs']}"
    _koopa_assert_is_matching_fixed \
        --pattern='{}' \
        --string="${dict['command']}"
    _koopa_assert_is_file "${dict['arg_file']}"
    dict['arg_file']="$(_koopa_realpath "${dict['arg_file']}")"
    parallel_args+=(
        '--arg-file' "${dict['arg_file']}"
        '--bar'
        '--colsep' ' '
        '--eta'
        '--jobs' "${dict['jobs']}"
        '--keep-order'
        '--progress'
        '--will-cite'
        "${dict['command']}"
    )
    "${app['parallel']}" "${parallel_args[@]}"
    return 0
}
