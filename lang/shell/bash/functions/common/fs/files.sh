#!/usr/bin/env bash

koopa_autopad_zeros() { # {{{1
    # """
    # Autopad zeroes in sample names.
    # @note Updated 2021-09-21.
    # """
    local files newname num padwidth oldname pos prefix stem
    koopa_assert_has_args "$#"
    prefix='sample'
    padwidth=2
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--padwidth='*)
                padwidth="${1#*=}"
                shift 1
                ;;
            '--padwidth')
                padwidth="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                prefix="${1#*=}"
                shift 1
                ;;
            '--prefix')
                prefix="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    files=("$@")
    if koopa_is_array_empty "${files[@]:-}"
    then
        koopa_stop 'No files.'
    fi
    for file in "${files[@]}"
    do
        if [[ "$file" =~ ^([0-9]+)(.*)$ ]]
        then
            oldname="${BASH_REMATCH[0]}"
            num=${BASH_REMATCH[1]}
            # Now pad the number prefix.
            num=$(printf "%.${padwidth}d" "$num")
            stem=${BASH_REMATCH[2]}
            # Combine with prefix to create desired file name.
            newname="${prefix}_${num}${stem}"
            koopa_mv "$oldname" "$newname"
        else
            koopa_alert_note "Skipping '${file}'."
        fi
    done
    return 0
}

koopa_basename() { # {{{1
    # """
    # Extract the file basename.
    # @note Updated 2021-05-21.
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
        koopa_print "${arg##*/}"
    done
    return 0
}

koopa_basename_sans_ext() { # {{{1
    # """
    # Extract the file basename without extension.
    # @note Updated 2020-06-30.
    #
    # Examples:
    # koopa_basename_sans_ext 'dir/hello-world.txt'
    # ## hello-world
    #
    # koopa_basename_sans_ext 'dir/hello-world.tar.gz'
    # ## hello-world.tar
    #
    # See also: koopa_file_ext
    # """
    local file str
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        str="$(koopa_basename "$file")"
        if koopa_has_file_ext "$str"
        then
            str="${str%.*}"
        fi
        koopa_print "$str"
    done
    return 0
}

koopa_basename_sans_ext2() { # {{{1
    # """
    # Extract the file basename prior to any dots in file name.
    # @note Updated 2021-11-04.
    #
    # Examples:
    # koopa_basename_sans_ext2 'dir/hello-world.tar.gz'
    # ## hello-world
    #
    # See also: koopa_file_ext2
    # """
    local app file str
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    for file in "$@"
    do
        str="$(koopa_basename "$file")"
        if koopa_has_file_ext "$str"
        then
            str="$( \
                koopa_print "$str" \
                | "${app[cut]}" --delimiter='.' --fields='1' \
            )"
        fi
        koopa_print "$str"
    done
    return 0
}

koopa_convert_utf8_nfd_to_nfc() { # {{{1
    # """
    # Convert UTF-8 NFD to NFC.
    # @note Updated 2021-11-04.
    # """
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        [convmv]="$(koopa_locate_convmv)"
    )
    koopa_assert_is_file "$@"
    "${app[convmv]}" \
        -r \
        -f 'utf8' \
        -t 'utf8' \
        --nfc \
        --notest \
        "$@"
    return 0
}

koopa_delete_broken_symlinks() { # {{{1
    # """
    # Delete broken symlinks.
    # @note Updated 2020-11-18.
    # """
    local prefix file files
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        readarray -t files <<< "$(koopa_find_broken_symlinks "$prefix")"
        koopa_is_array_non_empty "${files[@]:-}" || continue
        koopa_alert_note "Removing ${#files[@]} broken symlinks."
        # Don't pass single call to rm, as argument list can be too long.
        for file in "${files[@]}"
        do
            [[ -z "$file" ]] && continue
            koopa_alert "Removing '${file}'."
            koopa_rm "$file"
        done
    done
    return 0
}

koopa_delete_empty_dirs() { # {{{1
    # """
    # Delete empty directories.
    # @note Updated 2021-06-16.
    #
    # Don't pass a single call to 'rm' here, as argument list can be too
    # long to parse.
    #
    # @examples
    # koopa_mkdir 'a/aa/aaa/aaaa' 'b/bb/bbb/bbbb'
    # koopa_delete_empty_dirs 'a' 'b'
    #
    # @seealso
    # - While loop
    #   https://www.cyberciti.biz/faq/bash-while-loop/
    # """
    local dir dirs prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        while [[ -d "$prefix" ]] && \
            [[ -n "$(koopa_find_empty_dirs "$prefix")" ]]
        do
            readarray -t dirs <<< "$(koopa_find_empty_dirs "$prefix")"
            koopa_is_array_non_empty "${dirs[@]:-}" || continue
            for dir in "${dirs[@]}"
            do
                [[ -d "$dir" ]] || continue
                koopa_alert "Deleting '${dir}'."
                koopa_rm "$dir"
            done
        done
    done
    return 0
}

koopa_delete_named_subdirs() { # {{{1
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

koopa_dirname() { # {{{1
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

koopa_ensure_newline_at_end_of_file() { # {{{1
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

koopa_file_count() { # {{{1
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

koopa_file_ext() { # {{{1
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

koopa_file_ext2() { # {{{1
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
                | "${app[cut]}" --delimiter='.' --fields='2-' \
            )"
        else
            x=''
        fi
        koopa_print "$x"
    done
    return 0
}

koopa_line_count() { # {{{1
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
                | "${app[xargs]}" --no-run-if-empty \
                | "${app[cut]}" --delimiter=' ' --fields='1' \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}

koopa_md5sum_check_to_new_md5_file() { # {{{1
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

# FIXME This doesn't seem to work any more.
koopa_nfiletypes() { # {{{1
    # """
    # Return the number of file types in a specific directory.
    # @note Updated 2022-02-24.
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

koopa_reset_permissions() { # {{{1
    # """
    # Reset default permissions on a specified directory recursively.
    # @note Updated 2022-02-24.
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
    | "${app[xargs]}" \
        --no-run-if-empty \
        --null \
        -I {} \
        "${app[chmod]}" 'u=rwx,g=rwx,o=rx' {}
    # Files.
    koopa_find \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='f' \
    | "${app[xargs]}" \
        --no-run-if-empty \
        --null \
        -I {} \
        "${app[chmod]}" 'u=rw,g=rw,o=r' {}
    # Executable (shell) scripts.
    koopa_find \
        --pattern='*.sh' \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='f' \
    | "${app[xargs]}" \
        --no-run-if-empty \
        --null \
        -I {} \
        "${app[chmod]}" 'u=rwx,g=rwx,o=rx' {}
    return 0
}

koopa_stat() { # {{{1
    # """
    # Display file or file system status.
    # @note Updated 2021-11-16.
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

koopa_stat_access_human() { # {{{1
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

koopa_stat_access_octal() { # {{{1
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

koopa_stat_dereference() { # {{{1
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

koopa_stat_group() { # {{{1
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

koopa_stat_modified() { # {{{1
    # """
    # Get file modification time.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa_stat_modified '%Y-%m-%d' '/tmp'
    # # 2021-10-17
    #
    # @seealso
    # - Convert seconds since Epoch into a useful format.
    #   https://www.gnu.org/software/coreutils/manual/html_node/
    #     Examples-of-date.html
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

koopa_stat_user() { # {{{1
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
