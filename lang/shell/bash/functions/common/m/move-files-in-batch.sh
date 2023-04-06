#!/usr/bin/env bash

koopa_move_files_in_batch() {
    # """
    # Batch move a limited number of files.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > koopa_touch \
    # >     'source/aaa.txt' 'source/bbb.txt' \
    # >     'source/ccc.txt' 'source/ddd.txt'
    # > koopa_move_files_in_batch \
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
    koopa_assert_has_args_eq "$#" 3
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--num' "${dict['num']}" \
        '--source-dir' "${dict['source_dir']}" \
        '--target-dir' "${dict['target_dir']}"
    koopa_assert_is_dir "${dict['target_dir']}"
    dict['target_dir']="$(koopa_init_dir "${dict['target_dir']}")"
    readarray -t files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['source_dir']}" \
            --sort \
            --type='f' \
        | "${app['head']}" -n "${dict['num']}" \
    )"
    koopa_is_array_non_empty "${files[@]:-}" || return 1
    koopa_mv --target-directory="${dict['target_dir']}" "${files[@]}"
    return 0
}
