#!/bin/sh
# shellcheck disable=SC2039

_koopa_basename_sans_ext() {  # {{{1
    # """
    # Extract the file basename without extension.
    # @note Updated 2020-01-12.
    #
    # Examples:
    # _koopa_basename_sans_ext "dir/hello-world.txt"
    # ## hello-world
    #
    # _koopa_basename_sans_ext "dir/hello-world.tar.gz"
    # ## hello-world.tar
    #
    # See also: _koopa_file_ext
    # """
    local file
    file="${1:?}"
    local bn
    bn="$(basename "$file")"
    if ! _koopa_has_file_ext "$file"
    then
        echo "$bn"
        return 0
    fi
    bn="${bn%.*}"
    echo "$bn"
    return 0
}

_koopa_basename_sans_ext2() {  # {{{1
    # """
    # Extract the file basename prior to any dots in file name.
    # @note Updated 2020-01-12.
    #
    # Examples:
    # _koopa_basename_sans_ext2 "dir/hello-world.tar.gz"
    # ## hello-world
    #
    # See also: _koopa_file_ext2
    # """
    local file
    file="${1:?}"
    local bn
    bn="$(basename "$file")"
    if ! _koopa_has_file_ext "$file"
    then
        echo "$bn"
        return 0
    fi
    echo "$bn" | cut -d '.' -f 1
    return 0
}

_koopa_ensure_newline_at_end_of_file() {  # {{{1
    # """
    # Ensure output CSV contains trailing line break.
    # @note Updated 2020-01-12.
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
    file="${1:?}"
    [ -n "$(tail -c1 "$file")" ] && printf '\n' >>"$file"
    return 0
}

_koopa_file_ext() {  # {{{1
    # """
    # Extract the file extension from input.
    # @note Updated 2020-01-12.
    #
    # Examples:
    # _koopa_file_ext "hello-world.txt"
    # ## txt
    #
    # _koopa_file_ext "hello-world.tar.gz"
    # ## gz
    #
    # See also: _koopa_basename_sans_ext
    # """
    local file
    file="${1:?}"
    _koopa_has_file_ext "$file" || return 0
    printf "%s\n" "${file##*.}"
    return 0
}

_koopa_file_ext2() {  # {{{1
    # """
    # Extract the file extension after any dots in the file name.
    # @note Updated 2020-01-12.
    #
    # This assumes file names are not in dotted case.
    #
    # Examples:
    # _koopa_file_ext2 "hello-world.tar.gz"
    # ## tar.gz
    #
    # See also: _koopa_basename_sans_ext2
    # """
    local file
    file="${1:?}"
    _koopa_has_file_ext "$file" || return 0
    echo "$file" | cut -d '.' -f 2-
    return 0
}

_koopa_find_and_replace_in_files() {  # {{{1
    # """
    # Find and replace inside files.
    # @note Updated 2020-02-26.
    # """
    local from
    from="${1:?}"

    local to
    to="${2:?}"

    local dir
    dir="${3:-"."}"
    dir="$(realpath "$dir")"

    # Check for unescaped slashes.
    if echo "$from" | grep -q "/" && echo "$from" | grep -Fqv "\\"
    then
        _koopa_stop "Unescaped '/' detected: '${from}'."
    elif echo "$to" | grep -q "/" && echo "$to" | grep -Fqv "\\"
    then
        _koopa_stop "Unescaped '/' detected: '${to}'."
    fi

    find "$dir" \
        -xdev \
        -mindepth 1 \
        -maxdepth 1 \
        -type f \
        -exec sed -i "s/${from}/${to}/g" {} \;

    return 0
}

_koopa_find_broken_symlinks() {  # {{{1
    # """
    # Find broken symlinks.
    # @note Updated 2020-02-27.
    #
    # Note that 'grep -v' is more compatible with macOS and BusyBox than use of
    # 'grep --invert-match'.
    # """
    local dir
    dir="${1:-"."}"
    dir="$(realpath "$dir")"

    local x
    x="$( \
        find "$dir" \
            -xdev \
            -mindepth 1 \
            -xtype l \
            2>&1 \
            | grep -v "Permission denied" \
            | sort \
    )"

    echo "$x"
    return 0
}

_koopa_find_dotfiles() {  # {{{1
    # """
    # Find dotfiles by type.
    # @note Updated 2020-02-26.
    #
    # This is used internally by 'list-dotfiles' script.
    #
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. "Files")
    # """
    local type
    type="${1:?}"

    local header
    header="${2:?}"

    local x
    x="$( \
        find "$HOME" \
            -mindepth 1 \
            -maxdepth 1 \
            -name ".*" \
            -type "$type" \
            -print0 \
            | xargs -0 -n1 basename \
            | sort \
            | awk '{print "  ",$0}' \
    )"

    printf "\n%s:\n\n" "$header"
    echo "$x"
    return 0
}

_koopa_find_empty_dirs() {  # {{{1
    # """
    # Find empty directories.
    # @note Updated 2020-02-26.
    # """
    local dir
    dir="${1:-"."}"
    dir="$(realpath "$dir")"

    local x
    x="$( \
        find "$dir" \
            -mindepth 1 \
            -type d \
            -not -path "*/.*/*" \
            -empty \
            -print \
            | sort \
    )"

    echo "$x"
    return 0
}

_koopa_find_large_dirs() {  # {{{1
    # """
    # Find large directories.
    # @note Updated 2020-02-27.
    # """
    local dir
    dir="${1:-"."}"
    dir="$(realpath "$dir")"

    local x
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

    echo "$x"
    return 0
}

_koopa_find_large_files() {  # {{{1
    # """
    # Find large files.
    # @note Updated 2020-02-26.
    #
    # Note that use of 'grep --null-data' requires GNU grep.
    #
    # Usage of '-size +100M' isn't POSIX.
    #
    # @seealso
    # https://unix.stackexchange.com/questions/140367/
    # """
    local dir
    dir="${1:-"."}"
    dir="$(realpath "$dir")"

    local x
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
                --invert-match "Permission denied" \
            | xargs -0 du \
            | sort -n \
            | tail -n 100 \
    )"

    echo "$x"
    return 0
}

_koopa_find_non_cellar_make_files() {  # {{{1
    # """
    # Find non-cellar make files.
    # @note Updated 2020-02-26.
    #
    # Standard directories: bin, etc, include, lib, lib64, libexec, man, sbin,
    # share, src.
    # """
    local prefix
    prefix="$(_koopa_make_prefix)"

    local x
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

    echo "$x"
    return 0
}

_koopa_find_text() {  # {{{1
    # """
    # Find text in any file.
    # @note Updated 2020-02-26.
    #
    # See also: https://github.com/stephenturner/oneliners
    #
    # Examples:
    # _koopa_find_text "mytext" *.txt
    # """
    local pattern
    pattern="${1:?}"

    local file_name
    file_name="${2:?}"

    local dir
    dir="${3:-"."}"
    dir="$(realpath "$dir")"

    local x
    x="$( \
        find "$dir" \
            -mindepth 1 \
            -type f \
            -name "$file_name" \
            -exec grep -il "$pattern" {} \;; \
    )"

    echo "$x"
    return 0
}

_koopa_line_count() {  # {{{1
    # """
    # Return the number of lines in a file.
    # @note Updated 2020-02-26.
    #
    # Example: _koopa_line_count tx2gene.csv
    # """
    local file
    file="${1:?}"

    local x
    x="$( \
        wc -l "$file" \
            | xargs \
            | cut -d ' ' -f 1 \
    )"

    echo "$x"
    return 0
}

_koopa_rm_empty_dirs() {  # {{{1
    # """
    # Remove empty directories.
    # @note Updated 2020-03-05.
    # """
    local dir
    dir="${1:-"."}"
    dir="$(realpath "$dir")"
    find "$dir" \
        -mindepth 1 \
        -type d \
        -not -path "*/.*/*" \
        -empty \
        -delete \
        > /dev/null 2>&1
    return 0
}

_koopa_stat_access_human() {  # {{{1
    # """
    # Get the current access permissions in human readable form.
    # @note Updated 2020-01-12.
    # """
    stat -c '%A' "${1:?}"
    return 0
}

_koopa_stat_access_octal() {  # {{{1
    # """
    # Get the current access permissions in octal form.
    # @note Updated 2020-01-12.
    # """
    stat -c '%a' "${1:?}"
    return 0
}

_koopa_stat_group() {  # {{{1
    # """
    # Get the current group of a file or directory.
    # @note Updated 2020-01-12.
    # """
    stat -c '%G' "${1:?}"
    return 0
}

_koopa_stat_modified() {
    # """
    # Get file modification time.
    # @note Updated 2020-02-26.
    #
    # Linux uses GNU coreutils variant.
    # macOS uses BSD variant.
    #
    # Both approaches return seconds since Unix epoch with 'stat' and then
    # pass to 'date' with flags for expected epoch seconds input. Note that
    # '@' usage in date for Linux requires coreutils 5.3.0+.
    #
    # _koopa_stat_modified 'file.pdf' '%Y-%m-%d'
    # """
    local file
    file="${1:?}"

    local format
    format="${2:?}"

    local x
    if _koopa_is_macos
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

    echo "$x"
    return 0
}

_koopa_stat_user() {  # {{{1
    # """
    # Get the current user (owner) of a file or directory.
    # @note Updated 2020-01-12.
    # """
    stat -c '%U' "${1:?}"
    return 0
}
