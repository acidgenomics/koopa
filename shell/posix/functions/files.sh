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

_koopa_find_broken_symlinks() {  # {{{1
    # """
    # Find broken symlinks.
    # @note Updated 2020-02-16.
    # """
    local dir
    dir="${1:-"."}"
    local x
    if _koopa_is_macos
    then
        x="$( \
            find "$dir" -type l -print0 2>&1 \
                | grep -v "Permission denied" \
                | xargs -0 file \
                | grep broken \
                | cut -d ':' -f 1 \
        )"
    elif _koopa_is_linux
    then
        x="$( \
            find "$dir" -xtype l 2>&1 \
                | grep -v "Permission denied" \
        )"
    fi
    echo "$x"
    return 0
}

_koopa_find_dotfiles() {  # {{{1
    # """
    # Find dotfiles by type.
    # @note Updated 2020-01-12.
    #
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. "Files")
    # """
    local type
    type="${1:?}"
    local header
    header="${2:?}"
    printf "\n%s:\n\n" "$header"
    find "$HOME" \
        -maxdepth 1 \
        -name ".*" \
        -type "$type" \
        -print0 \
        | xargs -0 -n1 basename \
        | sort \
        | awk '{print "  ",$0}'
    return 0
}

_koopa_find_text() {  # {{{1
    # """
    # Find text in any file.
    # @note Updated 2020-01-12.
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
    find . -name "$file_name" -exec grep -il "$pattern" {} \;;
    return 0
}

_koopa_line_count() {  # {{{1
    # """
    # Return the number of lines in a file.
    # @note Updated 2020-01-12.
    #
    # Example: _koopa_line_count tx2gene.csv
    # """
    local file
    file="${1:?}"
    wc -l "$file" \
        | xargs \
        | cut -d ' ' -f 1
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

_koopa_stat_user() {  # {{{1
    # """
    # Get the current user (owner) of a file or directory.
    # @note Updated 2020-01-12.
    # """
    stat -c '%U' "${1:?}"
    return 0
}
