#!/usr/bin/env bash

# FIXME Need to harden this by using GNU mv ... koopa::mv
koopa::move_files_in_batch() { # {{{1
    # Batch move a limited number of files.
    # @note Updated 2020-07-08.
    # """
    local n source_dir target_dir
    koopa::assert_has_args_eq "$#" 3
    koopa::assert_is_installed find
    n="${1:?}"
    source_dir="${2:?}"
    target_dir="${3:?}"
    koopa::assert_is_dir "$source_dir" "$target_dir"
    find "$source_dir" \
        -type f \
        -regex '.+/[^.].+$' \
        -print0 \
        | sort -z \
        | head -z -n "$n" \
        | xargs -0 mv -t "$target_dir"
    return 0
}

koopa::move_files_up_1_level() { # {{{1
    # """
    # Move files up 1 level.
    # @note Updated 2020-07-08.
    # """
    local dir
    dir="${1:-.}"
    (
        koopa::cd "$dir"
        find . -type f -mindepth 2 -exec koopa::mv {} . \;
        find . -mindepth 2
        find . -type d -delete -print
    )
    return 0
}

koopa::move_into_dated_dirs_by_filename() { # {{{1
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
    grep_string="$(printf %s "${grep_array[@]}" $'\n')"
    for file in "$@"
    do
        if [[ "$file" =~ $grep_string ]]
        then
            year="${BASH_REMATCH[1]}"
            month="${BASH_REMATCH[3]}"
            day="${BASH_REMATCH[5]}"
            subdir="${year}/${month}/${day}"
            koopa::mv -t "$subdir" "$file"
        else
            koopa::stop "Does not contain date: '${file}'."
        fi
    done
    return 0
}

koopa::move_into_dated_dirs_by_timestamp() { # {{{1
    local file subdir
    koopa::assert_has_args "$#"
    for file in "$@"
    do
        subdir="$(koopa::stat_modified "$file" '%Y/%m/%d')"
        koopa::mv -t "$subdir" "$file"
    done
    return 0
}

