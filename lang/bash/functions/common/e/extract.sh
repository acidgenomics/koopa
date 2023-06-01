#!/usr/bin/env bash

koopa_extract() {
    # """
    # Extract files from an archive automatically.
    # @note Updated 2023-06-01.
    #
    # As suggested by Mendel Cooper in Advanced Bash Scripting Guide.
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    # - https://en.wikipedia.org/wiki/List_of_archive_formats
    # """
    local -A app dict
    local -a cmd_args contents
    local cmd
    koopa_assert_has_args_le "$#" 2
    dict['file']="${1:?}"
    dict['target']="${2:-}"
    koopa_assert_is_file "${dict['file']}"
    dict['file']="$(koopa_realpath "${dict['file']}")"
    if [[ -z "${dict['target']}" ]]
    then
        dict['target']="$(koopa_parent_dir "${dict['file']}")/\
$(koopa_basename_sans_ext "${dict['file']}")"
    fi
    koopa_assert_is_non_existing "${dict['target']}"
    dict['target']="$(koopa_init_dir "${dict['target']}")"
    koopa_alert "Extracting '${dict['file']}' to '${dict['target']}'."
    dict['tmpdir']="$( \
        koopa_init_dir "$(koopa_parent_dir "${dict['file']}")/\
.koopa-extract-$(koopa_random_string)" \
    )"
    dict['tmpfile']="${dict['tmpdir']}/$(koopa_basename "${dict['file']}")"
    koopa_ln "${dict['file']}" "${dict['tmpfile']}"
    # Ensure that we're matching against case insensitive basename.
    dict['match']="$(koopa_basename "${dict['file']}" | koopa_lowercase)"
    (
        koopa_cd "${dict['tmpdir']}"
        # Archiving only -------------------------------------------------------
        # FIXME a, ar
        case "${dict['match']}" in
            *'.tar' | \
            *'.tar.'* | \
            *'.tbz2' | \
            *'.tgz')
                local -a tar_cmd_args
                tar_cmd_args=(
                    '-f' "${dict['tmpfile']}" # '--file'.
                    '-x' # '--extract'.
                )
                app['tar']="$(koopa_locate_tar --allow-system)"
                koopa_assert_is_executable "${app['tar']}"
                if koopa_is_root && koopa_is_gnu "${app['tar']}"
                then
                    tar_cmd_args+=(
                        '--no-same-owner'
                        '--no-same-permissions'
                    )
                fi
                ;;
        esac
        case "${dict['match']}" in
            *'.tar.bz2' | \
            *'.tar.gz' | \
            *'.tar.lz' | \
            *'.tar.xz' | \
            *'.tbz2' | \
            *'.tgz')
                cmd="${app['tar']}"
                cmd_args=("${tar_cmd_args[@]}")
                case "${dict['tmpfile']}" in
                    *'.bz2' | *'.tbz2')
                        app['cmd2']="$(koopa_locate_bzip2 --allow-system)"
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app['cmd2']}")"
                        cmd_args+=('-j') # '--bzip2'.
                        ;;
                    *'.gz' | *'.tgz')
                        app['cmd2']="$(koopa_locate_gzip --allow-system)"
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app['cmd2']}")"
                        cmd_args+=('-z') # '--gzip'.
                        ;;
                    *'.lz')
                        app['cmd2']="$(koopa_locate_lzip --allow-system)"
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app['cmd2']}")"
                        cmd_args+=('--lzip')
                        ;;
                    *'.xz')
                        app['cmd2']="$(koopa_locate_xz --allow-system)"
                        koopa_add_to_path_start \
                            "$(koopa_dirname "${app['cmd2']}")"
                        cmd_args+=('-J') # '--xz'.
                        ;;
                esac
                ;;
            *'.tar')
                app['cmd']="${app['tar']}"
                cmd_args=("${tar_cmd_args[@]}")
                ;;
            # Archiving and compression ----------------------------------------
            # FIXME 7z
            # FIXME dmg
            # FIXME jar
            *'.7z')
                app['cmd']="$(koopa_locate_7z)"
                cmd_args=(
                    '-x'
                    "${dict['tmpfile']}"
                )
                ;;
            *'.zip')
                app['cmd']="$(koopa_locate_unzip --allow-system)"
                cmd_args=(
                    '-qq'
                    "${dict['tmpfile']}"
                )
                ;;
            # Compression only -------------------------------------------------
            *'.br' | \
            *'.bz2' | \
            *'.gz' | \
            *'.lz' | \
            *'.lz4' | \
            *'.lzma' | \
            *'.xz' | \
            *'.z' | \
            *'.zst')
                cmd='koopa_decompress'
                cmd_args=("${dict['tmpfile']}")
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_stop "Unsupported file: '${dict['file']}'."
                ;;
        esac
        if ! koopa_is_function "$cmd"
        then
            koopa_assert_is_executable "$cmd"
        fi
        "$cmd" "${cmd_args[@]}" # 2>/dev/null
    )
    koopa_rm "${dict['tmpfile']}"
    readarray -t contents <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['tmpdir']}" \
    )"
    if koopa_is_array_empty "${contents[@]}"
    then
        koopa_stop "Empty archive file: '${dict['file']}'."
    fi
    (
        shopt -s dotglob
        if [[ "${#contents[@]}" -eq 1 ]] && [[ -d "${contents[0]}" ]]
        then
            koopa_mv \
                --target-directory="${dict['target']}" \
                "${dict['tmpdir']}"/*/*
        else
            koopa_mv \
                --target-directory="${dict['target']}" \
                "${dict['tmpdir']}"/*
        fi
    )
    koopa_rm "${dict['tmpdir']}"
    return 0
}
