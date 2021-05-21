#!/usr/bin/env bash

koopa::extract() { # {{{1
    # """
    # Extract compressed files automatically.
    # @note Updated 2021-05-21.
    #
    # As suggested by Mendel Cooper in Advanced Bash Scripting Guide.
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    # """
    local cmd cmd_args file
    koopa::assert_has_args "$#"
    for file in "$@"
    do
        koopa::assert_is_file "$file"
        file="$(koopa::realpath "$file")"
        koopa::alert "Extracting '${file}'."
        case "$file" in
            # Two extensions (must come first).
            *.tar.bz2)
                cmd="$(koopa::locate_tar)"
                cmd_args=(-xj -f "$file")
                ;;
            *.tar.gz)
                cmd="$(koopa::locate_tar)"
                cmd_args=(-xz -f "$file")
                ;;
            *.tar.xz)
                cmd="$(koopa::locate_tar)"
                cmd_args=(-xJ -f "$file")
                ;;
            # Single extension.
            *.bz2)
                cmd="$(koopa::locate_bunzip2)"
                cmd_args=("$file")
                ;;
            *.gz)
                cmd="$(koopa::locate_gunzip)"
                cmd_args=("$file")
                ;;
            *.tar)
                cmd="$(koopa::locate_tar)"
                cmd_args=(-x -f "$file")
                ;;
            *.tbz2)
                cmd="$(koopa::locate_tar)"
                cmd_args=(-xj -f "$file")
                ;;
            *.tgz)
                cmd="$(koopa::locate_tar)"
                cmd_args=(-xz -f "$file")
                ;;
            *.xz)
                cmd="$(koopa::locate_xz)"
                cmd_args=(--decompress "$file")
                ;;
            *.zip)
                cmd="$(koopa::locate_unzip)"
                cmd_args=(-qq "$file")
                ;;
            *.Z)
                cmd="$(koopa::locate_uncompress)"
                cmd_args=("$file")
                ;;
            *.7z)
                cmd="$(koopa::locate_7z)"
                cmd_args=(-x "$file")
                ;;
            *)
                koopa::stop "Unsupported extension: '${file}'."
                ;;
        esac
        koopa::assert_is_installed "$cmd"
        "$cmd" "${cmd_args[@]}"
    done
    return 0
}
