#!/usr/bin/env bash

koopa::autopad_samples() { # {{{1
    # """
    # Autopad samples.
    # @note Updated 2020-07-08.
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
            koopa::note "Skipping '${file}'."
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

koopa::delete_cache() { # {{{1
    # """
    # Delete cache files (on Linux).
    # @note Updated 2020-11-03.
    #
    # Don't clear '/var/log/' here, as this can mess with 'sshd'.
    # """
    if ! koopa::is_linux
    then
        koopa::note 'Cache removal only supported on Linux.'
        return 1
    fi
    if ! koopa::is_docker
    then
        koopa::note 'Cache removal only supported inside Docker images.'
        return 1
    fi
    koopa::h2 'Removing caches, logs, and temporary files.'
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
            x=
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
            x=
        fi
        koopa::print "$x"
    done
    return 0
}

koopa::find_and_replace_in_files() { # {{{1
    # """
    # Find and replace inside files.
    # @note Updated 2020-07-01.
    #
    # Parameterized, supporting multiple files.
    #
    # This step requires GNU sed and won't work with BSD sed currently installed
    # by default on macOS.
    # https://stackoverflow.com/questions/4247068/
    # """
    local file from to
    koopa::assert_has_args_ge "$#" 3
    from="${1:?}"
    to="${2:?}"
    shift 2
    koopa::h1 "Replacing '${from}' with '${to}' in ${#} files."
    if { \
        koopa::str_match "${from}" '/' && ! koopa::str_match "${from}" '\/'; \
    } || { \
        koopa::str_match "${to}" '/' && ! koopa::str_match "${to}" '\/'; \
    }
    then
        koopa::stop 'Unescaped slash detected.'
    fi
    for file in "$@"
    do
        [[ -f "$file" ]] || return 1
        koopa::info "$file"
        sed -i "s/${from}/${to}/g" "$file"
    done
    return 0
}

koopa::find_broken_symlinks() { # {{{1
    # """
    # Find broken symlinks.
    # @note Updated 2020-07-03.
    #
    # Note that 'grep -v' is more compatible with macOS and BusyBox than use of
    # 'grep --invert-match'.
    # """
    local dir
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find grep
    dir="${1:-.}"
    [[ -d "$dir" ]] || return 0
    dir="$(realpath "$dir")"
    local x
    x="$( \
        find "$dir" \
            -xdev \
            -mindepth 1 \
            -xtype l \
            -print \
            2>&1 \
            | grep -v 'Permission denied' \
            | sort \
    )"
    koopa::print "$x"
    return 0
}

koopa::find_dotfiles() { # {{{1
    # """
    # Find dotfiles by type.
    # @note Updated 2020-07-03.
    #
    # This is used internally by 'list-dotfiles' script.
    #
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. 'Files')
    # """
    local header type x
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_installed awk find
    type="${1:?}"
    header="${2:?}"
    x="$( \
        find "$HOME" \
            -mindepth 1 \
            -maxdepth 1 \
            -name '.*' \
            -type "$type" \
            -print0 \
            | xargs -0 -n1 basename \
            | sort \
            | awk '{print "  ",$0}' \
    )"
    koopa::print '\n%s:\n\n' "$header"
    koopa::print "$x"
    return 0
}

koopa::find_empty_dirs() { # {{{1
    # """
    # Find empty directories.
    # @note Updated 2020-07-03.
    # """
    local dir x
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find grep
    dir="${1:-.}"
    dir="$(realpath "$dir")"
    x="$( \
        find "$dir" \
            -xdev \
            -mindepth 1 \
            -type d \
            -not -path '*/.*/*' \
            -empty \
            -print \
            2>&1 \
            | grep -v 'Permission denied' \
            | sort \
    )"
    koopa::print "$x"
    return 0
}

koopa::find_files_without_line_ending() {
    # """
    # Find files without line ending.
    # @note Updated 2020-10-06.
    #
    # Also referred to as EOL, newline, linefeed.
    #
    # @seealso
    # - https://stackoverflow.com/questions/4631068/
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed pcregrep
    pcregrep -LMr '\n$' "$@"
}

koopa::find_large_dirs() { # {{{1
    # """
    # Find large directories.
    # @note Updated 2020-07-01.
    # """
    local dir x
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed du
    dir="${1:-.}"
    dir="$(realpath "$dir")"
    x="$( \
        du \
            --max-depth=20 \
            --threshold=100000000 \
            "${dir}"/* \
            2>/dev/null \
        | sort -n \
        | head -n 100 \
        || true \
    )"
    koopa::print "$x"
    return 0
}

koopa::find_large_files() { # {{{1
    # """
    # Find large files.
    # @note Updated 2020-07-03.
    #
    # Note that use of 'grep --null-data' requires GNU grep.
    #
    # Usage of '-size +100M' isn't POSIX.
    #
    # @seealso
    # https://unix.stackexchange.com/questions/140367/
    # """
    local dir x
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find grep
    dir="${1:-.}"
    dir="$(realpath "$dir")"
    x="$( \
        find "$dir" \
            -xdev \
            -mindepth 1 \
            -type f \
            -size +100000000c \
            -print0 \
            2>&1 \
            | grep \
                --null-data \
                --invert-match 'Permission denied' \
            | xargs -0 du \
            | sort -n \
            | tail -n 100 \
    )"
    koopa::print "$x"
    return 0
}

koopa::find_non_cellar_make_files() { # {{{1
    # """
    # Find non-cellar make files.
    # @note Updated 2020-06-30.
    #
    # Standard directories: bin, etc, include, lib, lib64, libexec, man, sbin,
    # share, src.
    # """
    local prefix x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed find || return 1
    prefix="$(koopa::make_prefix)"
    x="$( \
        find "$prefix" \
            -xdev \
            -mindepth 1 \
            -type f \
            -not -path "${prefix}/cellar/*" \
            -not -path "${prefix}/koopa/*" \
            -not -path "${prefix}/opt/*" \
            -not -path "${prefix}/share/applications/mimeinfo.cache" \
            -not -path "${prefix}/share/emacs/site-lisp/*" \
            -not -path "${prefix}/share/zsh/site-functions/*" \
            | sort \
    )"
    koopa::print "$x"
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
    local datetime log_file
    koopa::assert_has_args "$#"
    datetime="$(koopa::datetime)"
    log_file="md5sum-${datetime}.md5"
    md5sum "$@" 2>&1 | tee "$log_file"
    return 0
}

koopa::nfiletypes() { # {{{1
    local dir
    koopa::assert_has_args_ne "$#" 1
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

koopa::remove_broken_symlinks() { # {{{1
    # """
    # Remove broken symlinks.
    # @note Updated 2020-08-06.
    # """
    local prefix file files
    koopa::assert_has_args "$#"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        readarray -t files <<< "$(koopa::find_broken_symlinks "$prefix")"
        koopa::is_array_non_empty "${files[@]}" || continue
        koopa::note "Removing ${#files[@]} broken symlinks."
        # Don't pass single call to rm, as argument list can be too long.
        for file in "${files[@]}"
        do
            [[ -z "$file" ]] && continue
            koopa::info "Removing '${file}'."
            koopa::rm "$file"
        done
    done
    return 0
}

koopa::remove_empty_dirs() { # {{{1
    # """
    # Remove empty directories.
    # @note Updated 2020-08-06.
    # """
    local dir dirs prefix
    koopa::assert_has_args "$#"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        readarray -t dirs <<< "$(koopa::find_empty_dirs "$prefix")"
        koopa::is_array_non_empty "${dirs[@]}" || continue
        koopa::note "Removing ${#dirs[@]} empty directories."
        # Don't pass single call to rm, as argument list can be too long.
        for dir in "${dirs[@]}"
        do
            [[ -z "$dir" ]] && continue
            koopa::info "Removing '${dir}'."
            koopa::rm "$dir"
        done
    done
    return 0
}

koopa::reset_permissions() { # {{{1
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

koopa::trash() { # {{{1
    local trash_dir
    koopa::assert_has_args "$#"
    trash_dir="${HOME}/.trash/"
    koopa::mkdir "$trash_dir"
    koopa::mv -t "$trash_dir" "$@"
    return 0
}

