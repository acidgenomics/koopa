#!/usr/bin/env bash

koopa::autopad_zeros() { # {{{1
    # """
    # Autopad zeroes in sample names.
    # @note Updated 2021-05-08.
    # """
    local files newname num padwidth oldname pos prefix stem
    koopa::assert_has_args "$#"
    prefix='sample'
    padwidth=2
    pos=()
    while (("$#"))
    do
        case "$1" in
            --padwidth=*)
                padwidth="${1#*=}"
                shift 1
                ;;
            --prefix=*)
                prefix="${1#*=}"
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
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
    if ! koopa::is_array_non_empty "${files[@]}"
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
    # @note Updated 2020-06-30.
    #
    # Parameterized, supporting multiple basename extractions.
    # """
    local arg
    koopa::assert_has_args "$#"
    if koopa::is_installed basename
    then
        koopa::print "$(basename -a "$@")"
    else
        for arg in "$@"
        do
            koopa::print "${arg##*/}"
        done
    fi
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
    # @note Updated 2020-06-30.
    #
    # Examples:
    # koopa::basename_sans_ext2 'dir/hello-world.tar.gz'
    # ## hello-world
    #
    # See also: koopa::file_ext2
    # """
    local file str
    koopa::assert_has_args "$#"
    for file in "$@"
    do
        str="$(koopa::basename "$file")"
        if koopa::has_file_ext "$str"
        then
            str="$(koopa::print "$str" | cut -d '.' -f 1)"
        fi
        koopa::print "$str"
    done
    return 0
}

koopa::convert_utf8_nfd_to_nfc() { # {{{1
    # """
    # Convert UTF-8 NFD to NFC.
    # @note Updated 2020-07-15.
    # """
    koopa::assert_has_args "$#"
    koopa::is_installed convmv
    convmv -r -f utf8 -t utf8 --nfc --notest "$@"
    return 0
}

koopa::delete_adobe_bridge_cache() { # {{{1
    # """
    # Delete Adobe Bridge cache files.
    # @note Updated 2020-07-16.
    # """
    local dir
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find
    dir="${1:-.}"
    koopa::assert_is_dir "$dir"
    koopa::h1 "Deleting Adobe Bridge cache in '${dir}'."
    find "$dir" \
        -mindepth 1 \
        -type f \
        \( \
            -name '.BridgeCache' -o \
            -name '.BridgeCacheT' \
        \) \
        -delete \
        -print
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
        koopa::is_array_non_empty "${files[@]}" || continue
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

koopa::delete_cache() { # {{{1
    # """
    # Delete cache files (on Linux).
    # @note Updated 2020-11-03.
    #
    # Don't clear '/var/log/' here, as this can mess with 'sshd'.
    # """
    if ! koopa::is_linux
    then
        koopa::stop 'Cache removal only supported on Linux.'
    fi
    if ! koopa::is_docker
    then
        koopa::stop 'Cache removal only supported inside Docker images.'
    fi
    koopa::alert 'Removing caches, logs, and temporary files.'
    koopa::rm -S \
        '/root/.cache' \
        '/tmp/'* \
        '/var/backups/'* \
        '/var/cache/'*
    if koopa::is_debian_like
    then
        koopa::rm -S '/var/lib/apt/lists/'*
    fi
    return 0
}

koopa::delete_empty_dirs() { # {{{1
    # """
    # Delete empty directories.
    # @note Updated 2020-11-18.
    # """
    local dir dirs prefix
    koopa::assert_has_args "$#"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        readarray -t dirs <<< "$(koopa::find_empty_dirs "$prefix")"
        koopa::is_array_non_empty "${dirs[@]}" || continue
        koopa::alert_note "Removing ${#dirs[@]} empty directories."
        # Don't pass single call to rm, as argument list can be too long.
        for dir in "${dirs[@]}"
        do
            [[ -z "$dir" ]] && continue
            koopa::alert "Removing '${dir}'."
            koopa::rm "$dir"
        done
    done
    return 0
}

koopa::delete_file_system_cruft() { # {{{1
    # """
    # Delete file system cruft.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    find "$dir" \
        -type f \
        \( \
            -name '.DS_Store' -o \
            -name '._*' -o \
            -name 'Thumbs.db*' \
        \) \
        -delete \
        -print
    return 0
}

koopa::delete_named_subdirs() { # {{{1
    # """
    # Delete named subdirectories.
    # @note Updated 2020-07-08.
    # """
    local dir subdir_name
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_installed find
    dir="${1:?}"
    subdir_name="${2:?}"
    find "$dir" \
        -type d \
        -name "$subdir_name" \
        -print0 \
        | xargs -0 -I {} rm -frv {}
    return 0
}

koopa::ensure_newline_at_end_of_file() { # {{{1
    # """
    # Ensure output CSV contains trailing line break.
    # @note Updated 2020-07-07.
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
    local file
    koopa::assert_has_args_eq "$#" 1
    file="${1:?}"
    [[ -n "$(tail -c1 "$file")" ]] || return 0
    printf '\n' >>"$file"
    return 0
}

koopa::file_count() { # {{{1
    # """
    # Return number of files.
    # @note Updated 2020-07-11.
    #
    # Alternate approach:
    # > ls -1 "$prefix" | wc -l
    # """
    local prefix x
    koopa::assert_is_installed find wc
    prefix="${1:?}"
    x="$(find "$prefix" -mindepth 1 -type f -printf '.' | wc -c)"
    koopa::print "$x"
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
    # @note Updated 2020-07-20.
    #
    # This assumes file names are not in dotted case.
    #
    # Examples:
    # koopa::file_ext2 'hello-world.tar.gz'
    # ## tar.gz
    #
    # See also: koopa::basename_sans_ext2
    # """
    local file x
    koopa::assert_has_args "$#"
    for file in "$@"
    do
        if koopa::has_file_ext "$file"
        then
            x="$(koopa::print "$file" | cut -d '.' -f 2-)"
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
    # @note Updated 2020-06-30.
    #
    # Example: koopa::line_count tx2gene.csv
    # """
    local file x
    koopa::assert_has_args "$#"
    for file in "$@"
    do
        x="$( \
            wc -l "$file" \
                | xargs \
                | cut -d ' ' -f 1 \
        )"
        koopa::print "$x"
    done    
    return 0
}

koopa::md5sum_check_to_new_md5_file() { # {{{1
    # """
    # Perform md5sum check on specified files to a new log file.
    # @note Updated 2021-05-08.
    # """
    local datetime log_file
    koopa::assert_has_args "$#"
    datetime="$(koopa::datetime)"
    log_file="md5sum-${datetime}.md5"
    md5sum "$@" 2>&1 | tee "$log_file"
    return 0
}

koopa::nfiletypes() { # {{{1
    # """
    # Return the number of file types in a specific directory.
    # @note Updated 2021-05-08.
    # """
    local dir
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find
    dir="${1:-.}"
    find "$dir" \
        -maxdepth 1 \
        -type f \
        | sed 's/.*\.//' \
        | sort \
        | uniq -c \
        | sed 's/^ *//g' \
        | sed 's/ /\t/g'
    return 0
}

koopa::reset_permissions() { # {{{1
    # """
    # Reset default permissions on a specified directory recursively.
    # @note Updated 2021-05-08.
    # """
    local dir group user
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    user="$(koopa::user)"
    group="$(koopa::group)"
    chown -R "${user}:${group}" "$dir"
    find "$dir" -type d -print0 \
        | xargs -0 -I {} chmod 'u=rwx,g=rwx,o=rx' {}
    find "$dir" -type f -print0 \
        | xargs -0 -I {} chmod 'u=rw,g=rw,o=r' {}
    find "$dir" -name '*.sh' -type f -print0 \
        | xargs -0 -I {} chmod 'u=rwx,g=rwx,o=rx' {}
    return 0
}

koopa::stat_access_human() { # {{{1
    # """
    # Get the current access permissions in human readable form.
    # @note Updated 2020-06-30.
    # """
    local x
    koopa::assert_has_args "$#"
    x="$(stat -c '%A' "$@")"
    koopa::print "$x"
    return 0
}

koopa::stat_access_octal() { # {{{1
    # """
    # Get the current access permissions in octal form.
    # @note Updated 2020-06-30.
    # """
    local x
    koopa::assert_has_args "$#"
    x="$(stat -c '%a' "$@")"
    koopa::print "$x"
    return 0
}

koopa::stat_dereference() { # {{{1
    # """
    # Dereference input files.
    # @note Updated 2020-06-30.
    #
    # Return quoted file with dereference if symbolic link.
    # """
    local x
    koopa::assert_has_args "$#"
    x="$(stat --printf='%N\n' "$@")"
    koopa::print "$x"
    return 0
}

koopa::stat_group() { # {{{1
    # """
    # Get the current group of a file or directory.
    # @note Updated 2020-06-30.
    # """
    local x
    koopa::assert_has_args "$#"
    x="$(stat -c '%G' "$@")"
    koopa::print "$x"
    return 0
}

koopa::stat_modified() { # {{{1
    # """
    # Get file modification time.
    # @note Updated 2020-03-06.
    #
    # Linux uses GNU coreutils variant.
    # macOS uses BSD variant.
    #
    # Both approaches return seconds since Unix epoch with 'stat' and then
    # pass to 'date' with flags for expected epoch seconds input. Note that
    # '@' usage in date for Linux requires coreutils 5.3.0+.
    #
    # koopa::stat_modified 'file.pdf' '%Y-%m-%d'
    # """
    local file format x
    koopa::assert_has_args_eq "$#" 2
    file="${1:?}"
    format="${2:?}"
    if koopa::is_macos
    then
        x="$(/usr/bin/stat -f '%m' "$file")"
        # Convert seconds since Epoch into a useful format.
        x="$(/bin/date -j -f '%s' "$x" +"$format")"
    else
        x="$(stat -c '%Y' "$file")"
        # Convert seconds since Epoch into a useful format.
        # https://www.gnu.org/software/coreutils/manual/html_node/
        #     Examples-of-date.html
        x="$(date -d "@${x}" +"$format")"
    fi
    koopa::print "$x"
    return 0
}

koopa::stat_user() { # {{{1
    # """
    # Get the current user (owner) of a file or directory.
    # @note Updated 2020-06-30.
    # """
    local x
    koopa::assert_has_args "$#"
    x="$(stat -c '%U' "$@")"
    koopa::print "$x"
    return 0
}
