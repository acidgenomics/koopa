#!/usr/bin/env bash

# FIXME Harden this by using Homebrew / GNU versions on macOS when possible.
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
    # FIXME This may cause install scripts to fail if some of these programs
    # aren't installed...may want to reconsider approach here...
    #declare -A xxxx=(
    #    [7z]='7z'                                                        # FIXME not on macos system
    #    [bunzip2]="$(koopa::locate_bunzip2)"
    #    [gunzip]="$(koopa::gnu_gunzip)"
    #    [tar]="$(koopa::gnu_tar)"
    #    [uncompress]="$(koopa::gnu_uncompress)"
    #    [unrar]='unrar'  # Commerical
    #    [xz]='xz'                                                        # FIXME not on macos system
    #    [unzip]='FIXME'
    #)
    for file in "$@"
    do
        koopa::assert_is_file "$file"
        file="$(koopa::realpath "$file")"
        koopa::alert "Extracting '${file}'."
        case "$file" in
            # Two extensions (must come first).
            *.tar.bz2)
                cmd="$(koopa::gnu_tar)"
                cmd_args=(-xj -f "$file")
                ;;
            *.tar.gz)
                cmd="$(koopa::gnu_tar)"
                cmd_args=(-xz -f "$file")
                ;;
            *.tar.xz)
                koopa::assert_is_installed tar
                tar -xJ -f "$file"
                ;;
            # Single extension.
            *.bz2)
                koopa::assert_is_installed bunzip2
                bunzip2 "$file"
                ;;
            *.gz)
                koopa::assert_is_installed gunzip
                gunzip "$file"
                ;;
            *.rar)
                cmd='unrar'
                koopa::assert_is_installed "$cmd"
                "$cmd" -x "$file"
                ;;
            *.tar)
                koopa::assert_is_installed tar
                tar -x -f "$file"
                ;;
            *.tbz2)
                koopa::assert_is_installed tar
                tar -xj -f "$file"
                ;;
            *.tgz)
                koopa::assert_is_installed tar
                tar -xz -f "$file"
                ;;
            *.xz)
                koopa::assert_is_installed xz
                xz --decompress "$file"
                ;;
            *.zip)
                koopa::assert_is_installed unzip
                unzip -qq "$file"
                ;;
            *.Z)
                koopa::assert_is_installed uncompress
                uncompress "$file"
                ;;
            *.7z)
                cmd="$(koopa::locate_7z)"
                koopa::assert_is_installed "$cmd"
                "$cmd" -x "$file"
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
