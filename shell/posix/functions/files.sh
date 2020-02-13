#!/bin/sh
# shellcheck disable=SC2039

_koopa_basename_sans_ext() {                                              # {{{1
    # """
    # Extract the file basename without extension.
    # Updated 2020-01-12.
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
}

_koopa_basename_sans_ext2() {                                             # {{{1
    # """
    # Extract the file basename prior to any dots in file name.
    # Updated 2020-01-12.
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
}

_koopa_delete_dotfile() {                                                 # {{{1
    # """
    # Delete a dot file.
    # Updated 2020-01-21.
    # """
    local name
    name="${1:?}"
    local filepath
    filepath="${HOME}/.${name}"
    if [ -L "$filepath" ]
    then
        _koopa_h2 "Removing '${filepath}'."
        rm -f "$filepath"
    elif [ -f "$filepath" ] || [ -d "$filepath" ]
    then
        _koopa_warning "Not a symlink: '${filepath}'."
    fi
    return 0
}

_koopa_download() {                                                       # {{{1
    # """
    # Download a file.
    # Updated 2020-02-06.
    #
    # Potentially useful curl flags:
    # * --connect-timeout <seconds>
    # * --progress-bar
    # * --stderr
    # * --verbose
    #
    # Alternatively, can use wget instead of curl:
    # > wget -O file url
    # > wget -q -O - url (piped to stdout)
    # > wget -qO-
    # """
    _koopa_assert_is_installed curl
    local url
    url="${1:?}"
    local file
    file="${2:-}"
    if [ -z "$file" ]
    then
        local wd
        wd="$(pwd)"
        local bn
        bn="$(basename "$url")"
        file="${wd}/${bn}"
    fi
    _koopa_info "Downloading '${url}' to '${file}'."
    # Note that '--fail-early' flag is useful, but not supported on old versions
    # of curl (e.g. 7.29.0; RHEL 7).
    curl \
        --create-dirs \
        --fail \
        --location \
        --output "$file" \
        --retry 1 \
        --show-error \
        --silent \
        "$url"
    return 0
}

_koopa_ensure_newline_at_end_of_file() {                                  # {{{1
    # """
    # Ensure output CSV contains trailing line break.
    # Updated 2020-01-12.
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
}

_koopa_extract() {                                                        # {{{1
    # """
    # Extract compressed files automatically.
    # Updated 2020-02-13.
    #
    # As suggested by Mendel Cooper in "Advanced Bash Scripting Guide".
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    # """
    local file
    file="${1:?}"
    if [ ! -f "$file" ]
    then
        _koopa_stop "Invalid file: '${file}'."
    fi
    _koopa_h2 "Extracting '${file}'."
    case "$file" in
        *.tar.bz2)
            tar -xjvf "$file"
            ;;
        *.tar.gz)
            tar -xzvf "$file"
            ;;
        *.tar.xz)
            tar -xJvf "$file"
            ;;
        *.bz2)
            _koopa_assert_is_installed bunzip2
            bunzip2 "$file"
            ;;
        *.gz)
            gunzip "$file"
            ;;
        *.rar)
            _koopa_assert_is_installed unrar
            unrar -x "$file"
            ;;
        *.tar)
            tar -xvf "$file"
            ;;
        *.tbz2)
            tar -xjvf "$file"
            ;;
        *.tgz)
            tar -xzvf "$file"
            ;;
        *.xz)
            _koopa_assert_is_installed xz
            xz --decompress "$file"
            ;;
        *.zip)
            _koopa_assert_is_installed unzip
            unzip "$file"
            ;;
        *.Z)
            uncompress "$file"
            ;;
        *.7z)
            _koopa_assert_is_installed 7z
            7z -x "$file"
            ;;
        *)
            _koopa_stop "Unsupported extension: '${file}'."
            ;;
   esac
   return 0
}

_koopa_file_ext() {                                                       # {{{1
    # """
    # Extract the file extension from input.
    # Updated 2020-01-12.
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
}

_koopa_file_ext2() {                                                      # {{{1
    # """
    # Extract the file extension after any dots in the file name.
    # Updated 2020-01-12.
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
}

_koopa_find_broken_symlinks() {                                           # {{{1
    # """
    # Find broken symlinks.
    # Updated 2020-01-13.
    # """
    dir="${1:-"."}"
    if _koopa_is_macos
    then
        find "$dir" -type l -print0 \
        | xargs -0 file \
        | grep broken \
        | cut -d ':' -f 1
    elif _koopa_is_linux
    then
        find "$dir" -xtype l
    fi
}

_koopa_find_dotfiles() {                                                  # {{{1
    # """
    # Find dotfiles by type.
    # Updated 2020-01-12.
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
}

_koopa_find_text() {                                                      # {{{1
    # """
    # Find text in any file.
    # Updated 2020-01-12.
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
}

_koopa_line_count() {                                                     # {{{1
    # """
    # Return the number of lines in a file.
    # Updated 2020-01-12.
    #
    # Example: _koopa_line_count tx2gene.csv
    # """
    local file
    file="${1:?}"
    wc -l "$file" \
        | xargs \
        | cut -d ' ' -f 1
}

_koopa_rsync_flags() {                                                    # {{{1
    # """
    # rsync flags.
    # Updated 2019-10-28.
    #
    #     --delete-before         receiver deletes before xfer, not during
    #     --iconv=CONVERT_SPEC    request charset conversion of filenames
    #     --numeric-ids           don't map uid/gid values by user/group name
    #     --partial               keep partially transferred files
    #     --progress              show progress during transfer
    # -A, --acls                  preserve ACLs (implies -p)
    # -H, --hard-links            preserve hard links
    # -L, --copy-links            transform symlink into referent file/dir
    # -O, --omit-dir-times        omit directories from --times
    # -P                          same as --partial --progress
    # -S, --sparse                handle sparse files efficiently
    # -X, --xattrs                preserve extended attributes
    # -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
    # -g, --group                 preserve group
    # -h, --human-readable        output numbers in a human-readable format
    # -n, --dry-run               perform a trial run with no changes made
    # -o, --owner                 preserve owner (super-user only)
    # -r, --recursive             recurse into directories
    # -x, --one-file-system       don't cross filesystem boundaries    
    # -z, --compress              compress file data during the transfer
    #
    # Use '--rsync-path="sudo rsync"' to sync across machines with sudo.
    #
    # See also:
    # - https://unix.stackexchange.com/questions/165423
    # """
    echo "--archive --delete-before --human-readable --progress"
}

_koopa_stat_access_human() {                                              # {{{1
    # """
    # Get the current access permissions in human readable form.
    # Updated 2020-01-12.
    # """
    stat -c '%A' "${1:?}"
}

_koopa_stat_access_octal() {                                              # {{{1
    # """
    # Get the current access permissions in octal form.
    # Updated 2020-01-12.
    # """
    stat -c '%a' "${1:?}"
}

_koopa_stat_group() {                                                     # {{{1
    # """
    # Get the current group of a file or directory.
    # Updated 2020-01-12.
    # """
    stat -c '%G' "${1:?}"
}

_koopa_stat_user() {                                                      # {{{1
    # """
    # Get the current user (owner) of a file or directory.
    # Updated 2020-01-12.
    # """
    stat -c '%U' "${1:?}"
}
