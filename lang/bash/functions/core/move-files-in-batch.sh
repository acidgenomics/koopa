#!/usr/bin/env bash

_koopa_move_files_in_batch() {
    # """
    # Batch move a limited number of files.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > _koopa_touch \
    # >     'source/aaa.txt' 'source/bbb.txt' \
    # >     'source/ccc.txt' 'source/ddd.txt'
    # > _koopa_move_files_in_batch \
    # >     --num=2 \
    # >     --source-dir='source/' \
    # >     --target-dir='target/'
    # # Silent, but returns these file paths:
    # # source/ccc.txt
    # # source/ddd.txt
    # # target/aaa.txt
    # # target/bbb.txt
    # """
    local -A app dict
    local files
    _koopa_assert_has_args_eq "$#" 3
    app['head']="$(_koopa_locate_head --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['num']=''
    dict['source_dir']=''
    dict['target_dir']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--num='*)
                dict['num']="${1#*=}"
                shift 1
                ;;
            '--num')
                dict['num']="${2:?}"
                shift 2
                ;;
            '--source-dir='*)
                dict['source_dir']="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict['source_dir']="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--num' "${dict['num']}" \
        '--source-dir' "${dict['source_dir']}" \
        '--target-dir' "${dict['target_dir']}"
    _koopa_assert_is_dir "${dict['target_dir']}"
    dict['target_dir']="$(_koopa_init_dir "${dict['target_dir']}")"
    readarray -t files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['source_dir']}" \
            --sort \
            --type='f' \
        | "${app['head']}" -n "${dict['num']}" \
    )"
    _koopa_is_array_non_empty "${files[@]:-}" || return 1
    _koopa_mv --target-directory="${dict['target_dir']}" "${files[@]}"
    return 0
}
