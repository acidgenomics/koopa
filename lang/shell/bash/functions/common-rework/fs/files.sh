#!/usr/bin/env bash

koopa_delete_named_subdirs() {
    # """
    # Delete named subdirectories.
    # @note Updated 2021-11-04.
    # """
    local dict matches
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        [prefix]="${1:?}"
        [subdir_name]="${2:?}"
    )
    readarray -t matches <<< "$( \
        koopa_find \
            --pattern="${dict[subdir_name]}" \
            --prefix="${dict[prefix]}" \
            --type='d' \
    )"
    koopa_is_array_non_empty "${matches[@]:-}" || return 1
    koopa_print "${matches[@]}"
    koopa_rm "${matches[@]}"
    return 0
}

koopa_dirname() {
    # """
    # Extract the file dirname.
    # @note Updated 2021-05-27.
    #
    # Parameterized, supporting multiple basename extractions.
    #
    # @seealso
    # - https://stackoverflow.com/questions/22401091/
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -e "$arg" ]]
        then
            arg="$(koopa_realpath "$arg")"
        fi
        koopa_print "${arg%/*}"
    done
    return 0
}

koopa_ensure_newline_at_end_of_file() {
    # """
    # Ensure output CSV contains trailing line break.
    # @note Updated 2022-02-23.
    #
    # Otherwise 'readr::read_csv()' will skip the last line in R.
    # https://unix.stackexchange.com/questions/31947
    #
    # Slower alternatives:
    # vi -ecwq file
    # paste file 1<> file
    # ed -s file <<< w
    # sed -i -e '$a\' file
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [tail]="$(koopa_locate_tail)"
    )
    declare -A dict=(
        [file]="${1:?}"
    )
    [[ -n "$("${app[tail]}" --bytes=1 "${dict[file]}")" ]] || return 0
    printf '\n' >> "${dict[file]}"
    return 0
}

koopa_file_count() {
    # """
    # Return number of files.
    # @note Updated 2022-02-24.
    #
    # Intentionally doesn't perform this search recursively.
    #
    # Alternate approach:
    # > ls -1 "$prefix" | wc -l
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [wc]="$(koopa_locate_wc)"
    )
    declare -A dict=(
        [prefix]="${1:?}"
    )
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    dict[out]="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --type='f' \
            --prefix="${dict[prefix]}" \
        | "${app[wc]}" -l \
    )"
    [[ -n "${dict[out]}" ]] || return 1
    koopa_print "${dict[out]}"
    return 0
}

koopa_file_ext() {
    # """
    # Extract the file extension from input.
    # @note Updated 2020-07-20.
    #
    # Examples:
    # koopa_file_ext 'hello-world.txt'
    # ## txt
    #
    # koopa_file_ext 'hello-world.tar.gz'
    # ## gz
    #
    # See also: koopa_basename_sans_ext
    # """
    local file x
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        if koopa_has_file_ext "$file"
        then
            x="${file##*.}"
        else
            x=''
        fi
        koopa_print "$x"
    done
    return 0
}

# FIXME Rename to 'ext2'.
koopa_file_ext2() {
    # """
    # Extract the file extension after any dots in the file name.
    # @note Updated 2021-11-04.
    #
    # This assumes file names are not in dotted case.
    #
    # Examples:
    # koopa_file_ext2 'hello-world.tar.gz'
    # ## tar.gz
    #
    # See also: koopa_basename_sans_ext2
    # """
    local app file x
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    for file in "$@"
    do
        if koopa_has_file_ext "$file"
        then
            x="$( \
                koopa_print "$file" \
                | "${app[cut]}" -d '.' -f '2-' \
            )"
        else
            x=''
        fi
        koopa_print "$x"
    done
    return 0
}

koopa_line_count() {
    # """
    # Return the number of lines in a file.
    # @note Updated 2022-02-16.
    #
    # Example: koopa_line_count 'tx2gene.csv'
    # """
    local app file str
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [wc]="$(koopa_locate_wc)"
        [xargs]="$(koopa_locate_xargs)"
    )
    for file in "$@"
    do
        str="$( \
            "${app[wc]}" --lines "$file" \
                | "${app[xargs]}" \
                | "${app[cut]}" -d ' ' -f '1' \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}

koopa_md5sum_check_to_new_md5_file() {
    # """
    # Perform md5sum check on specified files to a new log file.
    # @note Updated 2021-11-04.
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [md5sum]="$(koopa_locate_md5sum)"
        [tee]="$(koopa_locate_tee)"
    )
    declare -A dict=(
        [datetime]="$(koopa_datetime)"
    )
    dict[log_file]="md5sum-${dict[datetime]}.md5"
    koopa_assert_is_not_file "${dict[log_file]}"
    koopa_assert_is_file "$@"
    "${app[md5sum]}" "$@" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

koopa_nfiletypes() {
    # """
    # Return the number of file types in a specific directory.
    # @note Updated 2022-02-27.
    #
    # @examples
    # > koopa_nfiletypes "$PWD"
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [sed]="$(koopa_locate_sed)"
        [sort]="$(koopa_locate_sort)"
        [uniq]="$(koopa_locate_uniq)"
    )
    declare -A dict=(
        [prefix]="${1:?}"
    )
    koopa_assert_is_dir "${dict[prefix]}"
    dict[out]="$( \
        koopa_find \
            --exclude='.*' \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.*' \
            --prefix="${dict[prefix]}" \
            --type='f' \
        | "${app[sed]}" 's/.*\.//' \
        | "${app[sort]}" \
        | "${app[uniq]}" --count \
        | "${app[sort]}" --numeric-sort \
        | "${app[sed]}" 's/^ *//g' \
        | "${app[sed]}" 's/ /\t/g' \
    )"
    [[ -n "${dict[out]}" ]] || return 1
    koopa_print "${dict[out]}"
    return 0
}

koopa_reset_permissions() {
    # """
    # Reset default permissions on a specified directory recursively.
    # @note Updated 2022-02-27.
    #
    # @examples
    # > koopa_reset_permissions "$PWD"
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [chmod]="$(koopa_locate_chmod)"
        [xargs]="$(koopa_locate_xargs)"
    )
    declare -A dict=(
        [group]="$(koopa_group)"
        [prefix]="${1:?}"
        [user]="$(koopa_user)"
    )
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    koopa_chown --recursive "${dict[user]}:${dict[group]}" "${dict[prefix]}"
    # Directories.
    koopa_find \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='d' \
    | "${app[xargs]}" -0 -I {} \
        "${app[chmod]}" 'u=rwx,g=rwx,o=rx' {}
    # Files.
    koopa_find \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='f' \
    | "${app[xargs]}" -0 -I {} \
        "${app[chmod]}" 'u=rw,g=rw,o=r' {}
    # Executable (shell) scripts.
    koopa_find \
        --pattern='*.sh' \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='f' \
    | "${app[xargs]}" -0 -I {} \
        "${app[chmod]}" 'u=rwx,g=rwx,o=rx' {}
    return 0
}

koopa_stat() {
    # """
    # Display file or file system status.
    # @note Updated 2022-02-28.
    #
    # @examples
    # > koopa_stat '%A' '/tmp/'
    # # drwxrwxrwt
    # """
    local app dict
    koopa_assert_has_args_ge "$#" 2
    declare -A app=(
        [stat]="$(koopa_locate_stat)"
    )
    declare -A dict=(
        [format]="${1:?}"
    )
    shift 1
    dict[out]="$("${app[stat]}" --format="${dict[format]}" "$@")"
    [[ -n "${dict[out]}" ]] || return 1
    koopa_print "${dict[out]}"
    return 0
}

koopa_stat_access_human() {
    # """
    # Get the current access permissions in human readable form.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa_stat_access_human '/tmp'
    # # lrwxr-xr-x
    # """
    koopa_stat '%A' "$@"
}

koopa_stat_access_octal() {
    # """
    # Get the current access permissions in octal form.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa_stat_access_octal '/tmp'
    # # 755
    # """
    koopa_stat '%a' "$@"
}

koopa_stat_dereference() {
    # """
    # Dereference input files.
    # @note Updated 2021-11-16.
    #
    # Return quoted file with dereference if symbolic link.
    #
    # @examples
    # > koopa_stat_dereference '/tmp'
    # # '/tmp' -> 'private/tmp'
    # """
    koopa_stat '%N' "$@"
}

koopa_stat_group() {
    # """
    # Get the current group of a file or directory.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa_stat_group '/tmp'
    # # wheel
    # """
    koopa_stat '%G' "$@"
}

koopa_stat_modified() {
    # """
    # Get file modification time.
    # @note Updated 2021-11-16.
    #
    # @seealso
    # - Convert seconds since Epoch into a useful format.
    #   https://www.gnu.org/software/coreutils/manual/html_node/
    #     Examples-of-date.html
    #
    # @examples
    # > koopa_stat_modified '%Y-%m-%d' '/tmp'
    # # 2021-10-17
    # """
    local app dict timestamp timestamps x
    koopa_assert_has_args_ge "$#" 2
    declare -A app=(
        [date]="$(koopa_locate_date)"
    )
    declare -A dict=(
        [format]="${1:?}"
    )
    shift 1
    readarray -t timestamps <<< "$(koopa_stat '%Y' "$@")"
    for timestamp in "${timestamps[@]}"
    do
        x="$("${app[date]}" -d "@${timestamp}" +"${dict[format]}")"
        [[ -n "$x" ]] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_stat_user() {
    # """
    # Get the current user (owner) of a file or directory.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa_stat_user '/tmp'
    # # root
    # """
    koopa_stat '%U' "$@"
}
