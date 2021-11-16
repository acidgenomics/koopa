#!/usr/bin/env bash

koopa::autopad_zeros() { # {{{1
    # """
    # Autopad zeroes in sample names.
    # @note Updated 2021-09-21.
    # """
    local files newname num padwidth oldname pos prefix stem
    koopa::assert_has_args "$#"
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
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    files=("$@")
    if ! koopa::is_array_non_empty "${files[@]:-}"
    then
        koopa::stop 'No files.'
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
            koopa::mv "$oldname" "$newname"
        else
            koopa::alert_note "Skipping '${file}'."
        fi
    done
    return 0
}

koopa::basename() { # {{{1
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
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        koopa::print "${arg##*/}"
    done
    return 0
}

koopa::basename_sans_ext() { # {{{1
    # """
    # Extract the file basename without extension.
    # @note Updated 2020-06-30.
    #
    # Examples:
    # koopa::basename_sans_ext 'dir/hello-world.txt'
    # ## hello-world
    #
    # koopa::basename_sans_ext 'dir/hello-world.tar.gz'
    # ## hello-world.tar
    #
    # See also: koopa::file_ext
    # """
    local file str
    koopa::assert_has_args "$#"
    for file in "$@"
    do
        str="$(koopa::basename "$file")"
        if koopa::has_file_ext "$str"
        then
            str="${str%.*}"
        fi
        koopa::print "$str"
    done
    return 0
}

koopa::basename_sans_ext2() { # {{{1
    # """
    # Extract the file basename prior to any dots in file name.
    # @note Updated 2021-11-04.
    #
    # Examples:
    # koopa::basename_sans_ext2 'dir/hello-world.tar.gz'
    # ## hello-world
    #
    # See also: koopa::file_ext2
    # """
    local app file str
    koopa::assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
    )
    for file in "$@"
    do
        str="$(koopa::basename "$file")"
        if koopa::has_file_ext "$str"
        then
            str="$( \
                koopa::print "$str" \
                | "${app[cut]}" -d '.' -f 1 \
            )"
        fi
        koopa::print "$str"
    done
    return 0
}

koopa::convert_utf8_nfd_to_nfc() { # {{{1
    # """
    # Convert UTF-8 NFD to NFC.
    # @note Updated 2021-11-04.
    # """
    local app
    koopa::assert_has_args "$#"
    declare -A app=(
        [convmv]="$(koopa::locate_convmv)"
    )
    koopa::assert_is_file "$@"
    "${app[convmv]}" \
        -r \
        -f 'utf8' \
        -t 'utf8' \
        --nfc \
        --notest \
        "$@"
    return 0
}

koopa::delete_adobe_bridge_cache() { # {{{1
    # """
    # Delete Adobe Bridge cache files.
    # @note Updated 2021-11-04.
    # """
    local files prefix
    koopa::assert_has_args "$#"
    prefix="${1:?}"
    koopa::assert_is_dir "$prefix"
    prefix="$(koopa::realpath "$prefix")"
    koopa::alert "Deleting Adobe Bridge cache in '${prefix}'."
    readarray -t files <<< "$( \
        koopa::find \
            --min-depth=1 \
            --prefix="$prefix" \
            --regex='^\.BridgeCache(T)?$' \
            --type='f' \
    )"
    if ! koopa::is_array_non_empty "${files[@]:-}"
    then
        koopa::alert_note 'Failed to detect any Bridge cache files.'
        return 1
    fi
    koopa::rm "${files[@]}"
    return 0
}

koopa::delete_broken_symlinks() { # {{{1
    # """
    # Delete broken symlinks.
    # @note Updated 2020-11-18.
    # """
    local prefix file files
    koopa::assert_has_args "$#"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        readarray -t files <<< "$(koopa::find_broken_symlinks "$prefix")"
        koopa::is_array_non_empty "${files[@]:-}" || continue
        koopa::alert_note "Removing ${#files[@]} broken symlinks."
        # Don't pass single call to rm, as argument list can be too long.
        for file in "${files[@]}"
        do
            [[ -z "$file" ]] && continue
            koopa::alert "Removing '${file}'."
            koopa::rm "$file"
        done
    done
    return 0
}

koopa::delete_empty_dirs() { # {{{1
    # """
    # Delete empty directories.
    # @note Updated 2021-06-16.
    #
    # Don't pass a single call to 'rm' here, as argument list can be too
    # long to parse.
    #
    # @examples
    # koopa::mkdir 'a/aa/aaa/aaaa' 'b/bb/bbb/bbbb'
    # koopa::delete_empty_dirs 'a' 'b'
    #
    # @seealso
    # - While loop
    #   https://www.cyberciti.biz/faq/bash-while-loop/
    # """
    local dir dirs prefix
    koopa::assert_has_args "$#"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        while [[ -d "$prefix" ]] && \
            [[ -n "$(koopa::find_empty_dirs "$prefix")" ]]
        do
            readarray -t dirs <<< "$(koopa::find_empty_dirs "$prefix")"
            koopa::is_array_non_empty "${dirs[@]:-}" || continue
            for dir in "${dirs[@]}"
            do
                [[ -d "$dir" ]] || continue
                koopa::alert "Deleting '${dir}'."
                koopa::rm "$dir"
            done
        done
    done
    return 0
}

koopa::delete_file_system_cruft() { # {{{1
    # """
    # Delete file system cruft.
    # @note Updated 2021-11-04.
    # """
    local app dict
    koopa::assert_has_args "$#"
    declare -A app=(
        [find]="$(koopa::locate_find)"
    )
    declare -A dict=(
        [prefix]="${1:?}"
    )
    koopa::assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa::realpath "${dict[prefix]}")"
    "${app[find]}" \
        "${dict[prefix]}" \
        -type 'f' \
        \( \
               -name '.DS_Store' \
            -o -name '._*' \
            -o -name 'Thumbs.db*' \
        \) \
        -delete \
        -print
    return 0
}

koopa::delete_named_subdirs() { # {{{1
    # """
    # Delete named subdirectories.
    # @note Updated 2021-11-04.
    # """
    local dict matches
    koopa::assert_has_args_eq "$#" 2
    declare -A dict=(
        [prefix]="${1:?}"
        [subdir_name]="${2:?}"
    )
    readarray -t matches <<< "$( \
        koopa::find \
            --glob="${dict[subdir_name]}" \
            --prefix="${dict[prefix]}" \
            --type='d' \
    )"
    koopa::is_array_non_empty "${matches[@]:-}" || return 1
    koopa::print "${matches[@]}"
    koopa::rm "${matches[@]}"
    return 0
}

koopa::dirname() { # {{{1
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
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -e "$arg" ]]
        then
            arg="$(koopa::realpath "$arg")"
        fi
        koopa::print "${arg%/*}"
    done
    return 0
}

koopa::ensure_newline_at_end_of_file() { # {{{1
    # """
    # Ensure output CSV contains trailing line break.
    # @note Updated 2021-11-04.
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
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [tail]="$(koopa::locate_tail)"
    )
    declare -A dict=(
        [file]="${1:?}"
    )
    [[ -n "$("${app[tail]}" -c1 "${dict[file]}")" ]] || return 0
    printf '\n' >> "${dict[file]}"
    return 0
}

koopa::file_count() { # {{{1
    # """
    # Return number of files.
    # @note Updated 2021-11-04.
    #
    # Intentionally doesn't perform this search recursively.
    #
    # Alternate approach:
    # > ls -1 "$prefix" | wc -l
    # """
    local find prefix wc x
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [wc]="$(koopa::locate_wc)"
    )
    declare -A dict=(
        [prefix]="${1:?}"
    )
    koopa::assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa::realpath "${dict[prefix]}")"
    dict[out]="$( \
        koopa::find \
            --max-depth=1 \
            --min-depth=1 \
            --type='f' \
            --prefix="${dict[prefix]}" \
        | "${app[wc]}" -l \
    )"
    [[ -n "${dict[out]}" ]] || return 1
    koopa::print "${dict[out]}"
    return 0
}

koopa::file_ext() { # {{{1
    # """
    # Extract the file extension from input.
    # @note Updated 2020-07-20.
    #
    # Examples:
    # koopa::file_ext 'hello-world.txt'
    # ## txt
    #
    # koopa::file_ext 'hello-world.tar.gz'
    # ## gz
    #
    # See also: koopa::basename_sans_ext
    # """
    local file x
    koopa::assert_has_args "$#"
    for file in "$@"
    do
        if koopa::has_file_ext "$file"
        then
            x="${file##*.}"
        else
            x=''
        fi
        koopa::print "$x"
    done
    return 0
}

koopa::file_ext2() { # {{{1
    # """
    # Extract the file extension after any dots in the file name.
    # @note Updated 2021-11-04.
    #
    # This assumes file names are not in dotted case.
    #
    # Examples:
    # koopa::file_ext2 'hello-world.tar.gz'
    # ## tar.gz
    #
    # See also: koopa::basename_sans_ext2
    # """
    local app file x
    koopa::assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
    )
    for file in "$@"
    do
        if koopa::has_file_ext "$file"
        then
            x="$( \
                koopa::print "$file" \
                | "${app[cut]}" -d '.' -f '2-' \
            )"
        else
            x=''
        fi
        koopa::print "$x"
    done
    return 0
}

koopa::line_count() { # {{{1
    # """
    # Return the number of lines in a file.
    # @note Updated 2021-11-04.
    #
    # Example: koopa::line_count tx2gene.csv
    # """
    local app file x
    koopa::assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [wc]="$(koopa::locate_wc)"
        [xargs]="$(koopa::locate_xargs)"
    )
    for file in "$@"
    do
        x="$( \
            "${app[wc]}" -l "$file" \
                | "${app[xargs]}" \
                | "${app[cut]}" -d ' ' -f 1 \
        )"
        koopa::print "$x"
    done    
    return 0
}

koopa::md5sum_check_to_new_md5_file() { # {{{1
    # """
    # Perform md5sum check on specified files to a new log file.
    # @note Updated 2021-11-04.
    # """
    local app dict
    koopa::assert_has_args "$#"
    declare -A app=(
        [md5sum]="$(koopa::locate_md5sum)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [datetime]="$(koopa::datetime)"
    )
    dict[log_file]="md5sum-${dict[datetime]}.md5"
    koopa::assert_is_not_file "${dict[log_file]}"
    koopa::assert_is_file "$@"
    "${app[md5sum]}" "$@" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

koopa::nfiletypes() { # {{{1
    # """
    # Return the number of file types in a specific directory.
    # @note Updated 2021-11-04.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [sed]="$(koopa::locate_sed)"
        [sort]="$(koopa::locate_sort)"
        [uniq]="$(koopa::locate_uniq)"
    )
    declare -A dict=(
        [prefix]="${1:?}"
    )
    koopa::assert_is_dir "${dict[prefix]}"
    dict[out]="$( \
        koopa::find \
            --prefix="${dict[prefix]}" \
            --max-depth 1 \
            --min-depth 1 \
            --type 'f' \
            --regex '^.+\.[A-Za-z0-9]+$' \
        | "${app[sed]}" 's/.*\.//' \
        | "${app[sort]}" \
        | "${app[uniq]}" --count \
        | "${app[sort]}" --numeric-sort \
        | "${app[sed]}" 's/^ *//g' \
        | "${app[sed]}" 's/ /\t/g' \
    )"
    [[ -n "${dict[out]}" ]] || return 1
    koopa::print "${dict[out]}"
    return 0
}

koopa::reset_permissions() { # {{{1
    # """
    # Reset default permissions on a specified directory recursively.
    # @note Updated 2021-11-04.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [chmod]="$(koopa::locate_chmod)"
        [find]="$(koopa::locate_find)"
        [xargs]="$(koopa::locate_xargs)"
    )
    declare -A dict=(
        [group]="$(koopa::group)"
        [prefix]="${1:?}"
        [user]="$(koopa::user)"
    )
    koopa::assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa::realpath "${dict[prefix]}")"
    koopa::chown --recursive "${dict[user]}:${dict[group]}" "${dict[prefix]}"
    # Directories.
    koopa::find \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='d' \
    | "${app[xargs]}" -0 -I {} \
        "${app[chmod]}" 'u=rwx,g=rwx,o=rx' {}
    # Files.
    koopa::find \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='f' \
    | "${app[xargs]}" -0 -I {} \
        "${app[chmod]}" 'u=rw,g=rw,o=r' {}
    # Executable (shell) scripts.
    koopa::find \
        --glob='*.sh' \
        --prefix="${dict[prefix]}" \
        --print0 \
        --type='f' \
    | "${app[xargs]}" -0 -I {} \
        "${app[chmod]}" 'u=rwx,g=rwx,o=rx' {}
    return 0
}

koopa::stat() { # {{{1
    # """
    # Display file or file system status.
    # @note Updated 2021-11-16.
    # """
    local app dict
    koopa::assert_has_args_ge "$#" 2
    declare -A app=(
        [stat]="$(koopa::locate_stat)"
    )
    declare -A dict=(
        [format]="${1:?}"
    )
    shift 1
    dict[out]="$("${app[stat]}" --format="${dict[format]}" "$@")"
    [[ -n "${dict[out]}" ]] || return 1
    koopa::print "${dict[out]}"
    return 0
}

koopa::stat_access_human() { # {{{1
    # """
    # Get the current access permissions in human readable form.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa::stat_access_human '/tmp'
    # # lrwxr-xr-x
    # """
    koopa::stat '%A' "$@"
}

koopa::stat_access_octal() { # {{{1
    # """
    # Get the current access permissions in octal form.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa::stat_access_octal '/tmp'
    # # 755
    # """
    koopa::stat '%a' "$@"
}

koopa::stat_dereference() { # {{{1
    # """
    # Dereference input files.
    # @note Updated 2021-11-16.
    #
    # Return quoted file with dereference if symbolic link.
    #
    # @examples
    # > koopa::stat_dereference '/tmp'
    # # '/tmp' -> 'private/tmp'
    # """
    koopa::stat '%N' "$@"
}

koopa::stat_group() { # {{{1
    # """
    # Get the current group of a file or directory.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa::stat_group '/tmp'
    # # wheel
    # """
    koopa::stat '%G' "$@"
}

koopa::stat_modified() { # {{{1
    # """
    # Get file modification time.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa::stat_modified '%Y-%m-%d' '/tmp'
    # # 2021-10-17
    #
    # @seealso
    # - Convert seconds since Epoch into a useful format.
    #   https://www.gnu.org/software/coreutils/manual/html_node/
    #     Examples-of-date.html
    # """
    local app dict timestamp timestamps x
    koopa::assert_has_args_ge "$#" 2
    declare -A app=(
        [date]="$(koopa::locate_date)"
    )
    declare -A dict=(
        [format]="${1:?}"
    )
    shift 1
    readarray -t timestamps <<< "$(koopa::stat '%Y' "$@")"
    for timestamp in "${timestamps[@]}"
    do
        x="$("${app[date]}" -d "@${timestamp}" +"${dict[format]}")"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::stat_user() { # {{{1
    # """
    # Get the current user (owner) of a file or directory.
    # @note Updated 2021-11-16.
    #
    # @examples
    # > koopa::stat_user '/tmp'
    # # root
    # """
    koopa::stat '%U' "$@"
}
