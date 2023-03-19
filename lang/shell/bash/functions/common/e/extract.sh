#!/usr/bin/env bash

# FIXME Need to support extraction to a desired output directory.

# FIXME Need to support '--strip-components=1' type approach here.
# Perhaps we should extract into temporary directory and then copy in this
# case, but it can be slow across network file systems.

# FIXME Consider adding support for standardizing archive extraction in our
# install recipes and in our STAR alignment functions.

koopa_extract() {
    # """
    # Extract files from an archive automatically.
    # @note Updated 2023-02-15.
    #
    # As suggested by Mendel Cooper in Advanced Bash Scripting Guide.
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    # """
    local app cmd_args dict file
    koopa_assert_has_args "$#"
    declare -A app
    declare -A dict
    # Ensure modifications to 'PATH' are temporary during this function call.
    dict['orig_path']="${PATH:-}"
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
                app['cmd']="$(koopa_locate_tar --allow-system)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-x' # '--extract'.
                )
                case "$file" in
                    *'.bz2')
                        app['cmd2']="$(koopa_locate_bzip2 --allow-system)"
                        [[ -x "${app['cmd2']}" ]] || return 1
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app['cmd2']}")"
                        cmd_args+=('-j') # '--bzip2'.
                        ;;
                    *'.gz')
                        app['cmd2']="$(koopa_locate_gzip --allow-system)"
                        [[ -x "${app['cmd2']}" ]] || return 1
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app['cmd2']}")"
                        cmd_args+=('-z') # '--gzip'.
                        ;;
                    *'.xz')
                        app['cmd2']="$(koopa_locate_xz --allow-system)"
                        [[ -x "${app['cmd2']}" ]] || return 1
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app['cmd2']}")"
                        cmd_args+=('-J') # '--xz'.
                        ;;
                esac
                ;;
            # Single extension.
            *'.bz2')
                app['cmd']="$(koopa_locate_bunzip2 --allow-system)"
                cmd_args=("$file")
                ;;
            *'.gz')
                app['cmd']="$(koopa_locate_gzip --allow-system)"
                cmd_args=(
                    '-d' # '--decompress'.
                    "$file"
                )
                ;;
            *'.tar')
                app['cmd']="$(koopa_locate_tar --allow-system)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-x' # '--extract'.
                )
                ;;
            *'.tbz2')
                app['cmd']="$(koopa_locate_tar --allow-system)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-j' # '--bzip2'.
                    '-x' # '--extract'.
                )
                ;;
            *'.tgz')
                app['cmd']="$(koopa_locate_tar --allow-system)"
                cmd_args=(
                    '-f' "$file" # '--file'.
                    '-x' # '--extract'.
                    '-z' # '--gzip'.
                )
                ;;
            *'.xz')
                app['cmd']="$(koopa_locate_xz --allow-system)"
                cmd_args=(
                    '-d' # '--decompress'.
                    "$file"
                    )
                ;;
            *'.zip')
                app['cmd']="$(koopa_locate_unzip --allow-system)"
                cmd_args=(
                    '-qq'
                    "$file"
                )
                ;;
            *'.Z')
                app['cmd']="$(koopa_locate_uncompress --allow-system)"
                cmd_args=("$file")
                ;;
            *'.7z')
                app['cmd']="$(koopa_locate_7z)"
                cmd_args=(
                    '-x'
                    "$file"
                )
                ;;
            *)
                koopa_stop "Unsupported extension: '${file}'."
                ;;
        esac
        [[ -x "${app['cmd']}" ]] || return 1
        "${app['cmd']}" "${cmd_args[@]}"
    done
    export PATH="${dict['orig_path']}"
    return 0
}
