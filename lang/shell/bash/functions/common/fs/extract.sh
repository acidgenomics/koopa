#!/usr/bin/env bash

koopa_extract() { # {{{1
    # """
    # Extract files from an archive automatically.
    # @note Updated 2022-03-28.
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
            *'.tar.bz2' | \
            *'.tar.gz' | \
            *'.tar.xz')
                cmd="$(koopa_locate_tar)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-x' # '-x'  # '--extract'.
                )
                case "$file" in
                    *'.bz2')
                        cmd_args+=('-j') # '--bzip2'.
                        ;;
                    *'.gz')
                        cmd_args+=('-z') # '--gzip'.
                        ;;
                    *'.xz')
                        if koopa_is_macos
                        then
                            koopa_activate_homebrew_opt_prefix 'xz'
                        fi
                        cmd_args+=('-J') # '--xz'.
                        ;;
                esac
                ;;
            # Single extension.
            *'.bz2')
                cmd="$(koopa_locate_bunzip2)"
                cmd_args=("$file")
                ;;
            *'.gz')
                cmd="$(koopa_locate_gzip)"
                cmd_args=(
                    '-d' # '--decompress'.
                    "$file"
                )
                ;;
            *'.tar')
                cmd="$(koopa_locate_tar)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-x' # '--extract'.
                )
                ;;
            *'.tbz2')
                cmd="$(koopa_locate_tar)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-j' # '--bzip2'.
                    '-x' # '--extract'.
                )
                ;;
            *'.tgz')
                cmd="$(koopa_locate_tar)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-x' # '--extract'.
                    '-z' # '--gzip'.
                )
                ;;
            *'.xz')
                cmd="$(koopa_locate_xz)"
                cmd_args=(
                    '-d' # '--decompress'.
                    "$file"
                    )
                ;;
            *'.zip')
                cmd="$(koopa_locate_unzip)"
                cmd_args=(
                    '-qq'
                    "$file"
                )
                ;;
            *'.Z')
                cmd="$(koopa_locate_uncompress)"
                cmd_args=("$file")
                ;;
            *'.7z')
                cmd="$(koopa_locate_7z)"
                cmd_args=(
                    '-x'
                    "$file"
                )
                ;;
            *)
                koopa_stop "Unsupported extension: '${file}'."
                ;;
        esac
        "$cmd" "${cmd_args[@]}"
    done
    return 0
}
