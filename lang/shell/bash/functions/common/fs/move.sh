#!/usr/bin/env bash

koopa_move_files_in_batch() { # {{{1
    # """
    # Batch move a limited number of files.
    # @note Updated 2022-02-16.
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
    local app dict files
    koopa_assert_has_args_eq "$#" 3
    declare -A app=(
        [head]="$(koopa_locate_head)"
    )
    declare -A dict=(
        [num]=''
        [source_dir]=''
        [target_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--num='*)
                dict[num]="${1#*=}"
                shift 1
                ;;
            '--num')
                dict[num]="${2:?}"
                shift 2
                ;;
            '--source-dir='*)
                dict[source_dir]="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict[source_dir]="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--num' "${dict[num]}" \
        '--source-dir' "${dict[source_dir]}" \
        '--target-dir' "${dict[target_dir]}"
    koopa_assert_is_dir "${dict[target_dir]}"
    dict[target_dir]="$(koopa_init_dir "${dict[target_dir]}")"
    readarray -t files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[source_dir]}" \
            --sort \
            --type='f' \
        | "${app[head]}" --lines="${dict[num]}" \
    )"
    koopa_is_array_non_empty "${files[@]:-}" || return 1
    koopa_mv --target-directory="${dict[target_dir]}" "${files[@]}"
    return 0
}

koopa_move_files_up_1_level() { # {{{1
    # """
    # Move files up 1 level.
    # @note Updated 2022-02-16.
    #
    # @examples
    # > koopa_touch 'a/aa/aaa.txt'
    # > koopa_move_files_up_1_level 'a/'
    # # Silent, but returns this structure:
    # # 'a/aa'
    # # 'a/aaa.txt'
    # """
    local dict files
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="${PWD:?}"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    readarray -t files <<< "$( \
        koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict[prefix]}" \
            --type='f' \
    )"
    koopa_is_array_non_empty "${files[@]:-}" || return 1
    koopa_mv --target-directory="${dict[prefix]}" "${files[@]}"
    return 0
}

koopa_move_into_dated_dirs_by_filename() { # {{{1
    # """
    # Move into dated directories by filename.
    # @note Updated 2022-02-16.
    # """
    local file grep_array grep_string
    koopa_assert_has_args "$#"
    grep_array=(
        '^([0-9]{4})'
        '([-_])?'
        '([0-9]{2})'
        '([-_])?'
        '([0-9]{2})'
        '([-_])?'
        '(.+)$'
    )
    grep_string="$(koopa_paste0 "${grep_array[@]}")"
    for file in "$@"
    do
        local dict
        declare -A dict=(
            [file]="$file"
        )
        # NOTE Don't quote '$grep_string' here.
        if [[ "${dict[file]}" =~ $grep_string ]]
        then
            dict[year]="${BASH_REMATCH[1]}"
            dict[month]="${BASH_REMATCH[3]}"
            dict[day]="${BASH_REMATCH[5]}"
            dict[subdir]="${dict[year]}/${dict[month]}/${dict[day]}"
            koopa_mv --target-directory="${dict[subdir]}" "${dict[file]}"
        else
            koopa_stop "Does not contain date: '${dict[file]}'."
        fi
    done
    return 0
}

koopa_move_into_dated_dirs_by_timestamp() { # {{{1
    # """
    # Move into dated directories by timestamp.
    # @note Updated 2022-02-16.
    # """
    local file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        local subdir
        subdir="$(koopa_stat_modified '%Y/%m/%d' "$file")"
        koopa_mv --target-directory="$subdir" "$file"
    done
    return 0
}
