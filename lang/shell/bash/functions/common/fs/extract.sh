#!/usr/bin/env bash

koopa_extract() { # {{{1
    # """
    # Extract files from an archive automatically.
    # @note Updated 2022-01-11.
    #
    # As suggested by Mendel Cooper in Advanced Bash Scripting Guide.
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    # """
    local cmd cmd_args file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        koopa_assert_is_file "$file"
        file="$(koopa_realpath "$file")"
        koopa_alert "Extracting '${file}'."
        case "$file" in
            # Two extensions (must come first).
            *'.tar.bz2')
                cmd="$(koopa_locate_tar)"
                cmd_args=(-xj -f "$file")
                ;;
            *'.tar.gz')
                cmd="$(koopa_locate_tar)"
                cmd_args=(-xz -f "$file")
                ;;
            *'.tar.xz')
                if koopa_is_macos
                then
                    koopa_activate_homebrew_opt_prefix 'xz'
                fi
                cmd="$(koopa_locate_tar)"
                cmd_args=(-xJ -f "$file")
                ;;
            # Single extension.
            *'.bz2')
                cmd="$(koopa_locate_bunzip2)"
                cmd_args=("$file")
                ;;
            *'.gz')
                cmd="$(koopa_locate_gunzip)"
                cmd_args=("$file")
                ;;
            *'.tar')
                cmd="$(koopa_locate_tar)"
                cmd_args=(-x -f "$file")
                ;;
            *'.tbz2')
                cmd="$(koopa_locate_tar)"
                cmd_args=(-xj -f "$file")
                ;;
            *'.tgz')
                cmd="$(koopa_locate_tar)"
                cmd_args=(-xz -f "$file")
                ;;
            *'.xz')
                cmd="$(koopa_locate_xz)"
                cmd_args=(--decompress "$file")
                ;;
            *'.zip')
                cmd="$(koopa_locate_unzip)"
                cmd_args=(-qq "$file")
                ;;
            *'.Z')
                cmd="$(koopa_locate_uncompress)"
                cmd_args=("$file")
                ;;
            *'.7z')
                cmd="$(koopa_locate_7z)"
                cmd_args=(-x "$file")
                ;;
            *)
                koopa_stop "Unsupported extension: '${file}'."
                ;;
        esac
        koopa_assert_is_installed "$cmd"
        "$cmd" "${cmd_args[@]}"
    done
    return 0
}
