#!/usr/bin/env bash

koopa::move_files_in_batch() { # {{{1
    # Batch move a limited number of files.
    # @note Updated 2021-05-24.
    # """
    local find head mv n sort source_dir target_dir xargs
    koopa::assert_has_args_eq "$#" 3
    find="$(koopa::locate_find)"
    head="$(koopa::locate_head)"
    mv="$(koopa::locate_mv)"
    sort="$(koopa::locate_sort)"
    xargs="$(koopa::locate_xargs)"
    n="${1:?}"
    source_dir="${2:?}"
    target_dir="${3:?}"
    koopa::assert_is_dir "$source_dir" "$target_dir"
    # FIXME Rework using 'koopa::find'.
    # FIXME Need to add support for '--regex' in addition to '--glob'.
    "$find" "$source_dir" \
        -type f \
        -regex '.+/[^.].+$' \
        -print0 \
        | "$sort" -z \
        | "$head" -z -n "$n" \
        | "$xargs" -0 "$mv" -t "$target_dir"
    return 0
}

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
    # @note Updated 2021-11-04.
    # """
    local day file grep_array grep_string month subdir year
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
    grep_string="$(printf '%s' "${grep_array[@]}" $'\n')"
    for file in "$@"
    do
        if [[ "$file" =~ $grep_string ]]
        then
            year="${BASH_REMATCH[1]}"
            month="${BASH_REMATCH[3]}"
            day="${BASH_REMATCH[5]}"
            subdir="${year}/${month}/${day}"
            koopa::mv --target-directory="$subdir" "$file"
        else
            koopa::stop "Does not contain date: '${file}'."
        fi
    done
    return 0
}

koopa::move_into_dated_dirs_by_timestamp() { # {{{1
    # """
    # Move into dated directories by timestamp.
    # @note Updated 2021-11-16.
    # """
    local file subdir
    koopa::assert_has_args "$#"
    for file in "$@"
    do
        subdir="$(koopa::stat_modified '%Y/%m/%d' "$file")"
        koopa::mv --target-directory="$subdir" "$file"
    done
    return 0
}
