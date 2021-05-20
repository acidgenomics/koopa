#!/usr/bin/env bash

# FIXME Harden this by using Homebrew / GNU versions on macOS when possible.
koopa::extract() { # {{{1
    # """
    # Extract compressed files automatically.
    # @note Updated 2020-07-05.
    #
    # As suggested by Mendel Cooper in Advanced Bash Scripting Guide.
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    # """
    local file
    koopa::assert_has_args "$#"
    for file in "$@"
    do
        pwd
        koopa::assert_is_file "$file"
        file="$(koopa::realpath "$file")"
        koopa::alert "Extracting '${file}'."
        case "$file" in
            *.tar.bz2)
                koopa::assert_is_installed tar
                tar -xj -f "$file"
                ;;
            *.tar.gz)
                koopa::assert_is_installed tar
                tar -xz -f "$file"
                ;;
            *.tar.xz)
                koopa::assert_is_installed tar
                tar -xJ -f "$file"
                ;;
            *.bz2)
                koopa::assert_is_installed bunzip2
                bunzip2 "$file"
                ;;
            *.gz)
                koopa::assert_is_installed gunzip
                gunzip "$file"
                ;;
            *.rar)
                koopa::assert_is_installed unrar
                unrar -x "$file"
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
                koopa::assert_is_installed 7z
                7z -x "$file"
                ;;
            *)
                koopa::stop "Unsupported extension: '${file}'."
                ;;
        esac
    done
    return 0
}
