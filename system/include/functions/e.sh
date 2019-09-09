#!/bin/sh
# shellcheck disable=SC2039



# Extract compressed files automatically.
#
# As suggested by Mendel Cooper in "Advanced Bash Scripting Guide".
#
# See also:
# - https://github.com/stephenturner/oneliners
#
# Updated 2019-09-09.
_koopa_extract() {
    local file
    file="$1"
    if [ ! -f "$file" ]
    then
        >&2 printf "Error: Invalid file: %s\n" "$file"
        exit 1
    fi
    case "$file" in
        *.tar.bz2)
            tar xvjf "$file"
            ;;
        *.tar.gz)
            tar xvzf "$file"
            ;;
        *.tar.xz)
            tar Jxvf "$file"
            ;;
        *.bz2)
            bunzip2 "$file"
            ;;
        *.gz)
            gunzip "$file"
            ;;
        *.rar)
            unrar x "$file"
            ;;
        *.tar)
            tar xvf "$file"
            ;;
        *.tbz2)
            tar xvjf "$file"
            ;;
        *.tgz)
            tar xvzf "$file"
            ;;
        *.zip)
            unzip "$file"
            ;;
        *.Z)
            uncompress "$file"
            ;;
        *.7z)
            7z x "$file"
            ;;
        *)
            >&2 printf "Error: Unsupported extension: %s\n" "$file"
            ;;
   esac
}
