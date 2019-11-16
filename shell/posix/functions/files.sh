#!/bin/sh
# shellcheck disable=SC2039

_koopa_basename_sans_ext() {                                              # {{{3
    # """
    # Extract the file basename without extension.
    # Updated 2019-10-08.
    #
    # Examples:
    # _koopa_basename_sans_ext "hello-world.txt"
    # ## hello-world
    #
    # _koopa_basename_sans_ext "hello-world.tar.gz"
    # ## hello-world.tar
    #
    # See also: _koopa_file_ext
    # """
    local x
    x="$1"
    if ! _koopa_has_file_ext "$x"
    then
        echo "$x"
        return 0
    fi
    x="$(basename "$x")"
    x="${x%.*}"
    echo "$x"
}

_koopa_basename_sans_ext2() {                                             # {{{3
    # """
    # Extract the file basename prior to any dots in file name.
    # Updated 2019-10-08.
    #
    # Examples:
    # _koopa_basename_sans_ext2 "hello-world.tar.gz"
    # ## hello-world
    #
    # See also: _koopa_file_ext2
    # """
    local x
    x="$1"
    if ! _koopa_has_file_ext "$x"
    then
        echo "$x"
        return 0
    fi
    basename "$x" | cut -d '.' -f 1
}

_koopa_delete_dotfile() {                                                 # {{{3
    # """
    # Delete a dot file.
    # Updated 2019-06-27.
    # """
    local path
    local name
    path="${HOME}/.${1}"
    name="$(basename "$path")"
    if [ -L "$path" ]
    then
        _koopa_message "Removing '${name}'."
        rm -f "$path"
    elif [ -f "$path" ] || [ -d "$path" ]
    then
        _koopa_warning "Not a symlink: '${name}'."
    fi
}

_koopa_download() {                                                       # {{{3
    # """
    # Download a file.
    # Updated 2019-11-04.
    #
    # Alternatively, can use wget instead of curl:
    # > wget -O file url
    # > wget -q -O - url (piped to stdout)
    # > wget -qO-
    # """
    _koopa_assert_is_installed curl
    local url
    url="$1"
    local file
    file="${2:-}"
    if [ -z "$file" ]
    then
        file="$(basename "$url")"
    fi
    curl -L -o "$file" "$url"
}

_koopa_ensure_newline_at_end_of_file() {                                  # {{{3
    # """
    # Ensure output CSV contains trailing line break.
    # Updated 2019-10-11.
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
    [ -n "$(tail -c1 "$1")" ] && printf '\n' >>"$1"
}

_koopa_extract() {                                                        # {{{3
    # """
    # Extract compressed files automatically.
    # Updated 2019-10-27.
    #
    # As suggested by Mendel Cooper in "Advanced Bash Scripting Guide".
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    # """
    local file
    file="$1"
    if [ ! -f "$file" ]
    then
        _koopa_stop "Invalid file: '${file}'."
    fi
    _koopa_message "Extracting '${file}'."
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
            bunzip2 "$file"
            ;;
        *.gz)
            gunzip "$file"
            ;;
        *.rar)
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
        *.zip)
            unzip "$file"
            ;;
        *.Z)
            uncompress "$file"
            ;;
        *.7z)
            7z -x "$file"
            ;;
        *)
            _koopa_stop "Unsupported extension: '${file}'."
            ;;
   esac
}

_koopa_file_ext() {                                                       # {{{3
    # """
    # Extract the file extension from input.
    # Updated 2019-10-08.
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
    _koopa_has_file_ext "$1" || return 0
    printf "%s\n" "${1##*.}"
}

_koopa_file_ext2() {                                                      # {{{3
    # """
    # Extract the file extension after any dots in the file name.
    # Updated 2019-10-08.
    #
    # This assumes file names are not in dotted case.
    #
    # Examples:
    # _koopa_file_ext2 "hello-world.tar.gz"
    # ## tar.gz
    #
    # See also: _koopa_basename_sans_ext2
    # """
    _koopa_has_file_ext "$1" || return 0
    echo "$1" | cut -d '.' -f 2-
}

_koopa_find_dotfiles() {                                                  # {{{3
    # """
    # Find dotfiles by type.
    # Updated 2019-10-22.
    #
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. "Files")
    # """
    local type="$1"
    local header="$2"
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

_koopa_find_text() {                                                      # {{{3
    # """
    # Find text in any file.
    # Updated 2019-09-05.
    #
    # See also: https://github.com/stephenturner/oneliners
    #
    # Examples:
    # _koopa_find_text "mytext" *.txt
    # """
    find . -name "$2" -exec grep -il "$1" {} \;;
}

_koopa_github_latest_release() {                                          # {{{3
    # """
    # Get the latest release version from GitHub.
    # Updated 2019-10-24.
    #
    # Example: _koopa_github_latest_release "acidgenomics/koopa"
    # """
    curl -s "https://github.com/${1}/releases/latest" 2>&1 \
        | grep -Eo '/tag/[.0-9v]+' \
        | cut -d '/' -f 3 \
        | sed 's/^v//'
}

_koopa_line_count() {                                                     # {{{3
    # """
    # Return the number of lines in a file.
    # Updated 2019-10-27.
    #
    # Example: _koopa_line_count tx2gene.csv
    # """
    wc -l "$1" \
        | xargs \
        | cut -d ' ' -f 1
}

_koopa_rsync_flags() {                                                    # {{{3
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

_koopa_stat_access_human() {                                              # {{{3
    # """
    # Get the current access permissions in human readable form.
    # Updated 2019-10-31.
    # """
    stat -c '%A' "$1"
}

_koopa_stat_access_octal() {                                              # {{{3
    # """
    # Get the current access permissions in octal form.
    # Updated 2019-10-31.
    # """
    stat -c '%a' "$1"
}

_koopa_stat_group() {                                                     # {{{3
    # """
    # Get the current group of a file or directory.
    # Updated 2019-10-31.
    # """
    stat -c '%G' "$1"
}

_koopa_stat_user() {                                                      # {{{3
    # """
    # Get the current user (owner) of a file or directory.
    # Updated 2019-10-31.
    # """
    stat -c '%U' "$1"
}
