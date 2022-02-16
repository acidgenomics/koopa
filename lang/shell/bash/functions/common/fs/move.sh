#!/usr/bin/env bash

koopa::move_files_in_batch() { # {{{1
    # """
    # Batch move a limited number of files.
    # @note Updated 2022-02-16.
    #
    # @examples
    # koopa::move_files_in_batch 100 'source_dir' 'target_dir'
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 3
    declare -A app=(
        [head]="$(koopa::locate_head)"
        [mv]="$(koopa::locate_gnu_mv)"
        [xargs]="$(koopa::locate_xargs)"
    )
    declare -A dict=(
        [num]="${1:?}"
        [source_dir]="${2:?}"
        [target_dir]="${3:?}"
    )
    [[ ! -d "${dict[target_dir]}" ]] && koopa::mkdir "${dict[target_dir]}"
    koopa::assert_is_dir "${dict[source_dir]}" "${dict[target_dir]}"
    koopa::find \
        --max-depth=1 \
        --min-depth=1 \
        --prefix="${dict[source_dir]}" \
        --print0 \
        --sort \
        --type='f' \
    | "${app[head]}" \
        --lines="${dict[num]}" \
        --zero-terminated \
    | "${app[xargs]}" --null \
        "${app[mv]}" \
            --target-directory "${dict[target_dir]}" \
            --verbose
    return 0
}

# FIXME Rework using app/dict approach.
# FIXME Rework this using 'koopa::find'.
# FIXME Rework this using xargs?
koopa::move_files_up_1_level() { # {{{1
    # """
    # Move files up 1 level.
    # @note Updated 2021-10-25.
    # """
    local prefix
    find="$(koopa::locate_find)"
    prefix="${1:-.}"
    koopa::assert_is_dir "$prefix"
    "$find" \
        "$prefix" \
        -mindepth 2 \
        -type 'f' \
        -exec koopa::mv --target-directory="$prefix" {} \;
    return 0
}

koopa::move_into_dated_dirs_by_filename() { # {{{1
    # """
    # Move into dated directories by filename.
    # @note Updated 2022-02-16.
    # """
    local file grep_array grep_string
    koopa::assert_has_args "$#"
    grep_array=(
        '^([0-9]{4})'
        '([-_])?'
        '([0-9]{2})'
        '([-_])?'
        '([0-9]{2})'
        '([-_])?'
        '(.+)$'
    )
    grep_string="$(koopa::paste0 "${grep_array[@]}")"
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
            koopa::mv --target-directory="${dict[subdir]}" "${dict[file]}"
        else
            koopa::stop "Does not contain date: '${dict[file]}'."
        fi
    done
    return 0
}

koopa::move_into_dated_dirs_by_timestamp() { # {{{1
    # """
    # Move into dated directories by timestamp.
    # @note Updated 2022-02-16.
    # """
    local file
    koopa::assert_has_args "$#"
    for file in "$@"
    do
        local subdir
        subdir="$(koopa::stat_modified '%Y/%m/%d' "$file")"
        koopa::mv --target-directory="$subdir" "$file"
    done
    return 0
}
