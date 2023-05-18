#!/usr/bin/env bash

# FIXME Add support for lz (lzip).
# FIXME Add support for zstd.

koopa_extract() {
    # """
    # Extract files from an archive automatically.
    # @note Updated 2023-03-24.
    #
    # As suggested by Mendel Cooper in Advanced Bash Scripting Guide.
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    # """
    local -A app dict
    local -a cmd_args
    koopa_assert_has_args_le "$#" 2
    dict['file']="${1:?}"
    dict['target']="${2:-}"
    dict['wd']="${PWD:?}"
    [[ -z "${dict['target']}" ]] && dict['target']="${dict['wd']}"
    if [[ "${dict['target']}" != "${dict['wd']}"  ]]
    then
        dict['move_into_target']=1
    else
        dict['move_into_target']=0
    fi
    koopa_assert_is_file "${dict['file']}"
    dict['file']="$(koopa_realpath "${dict['file']}")"
    if [[ "${dict['move_into_target']}" -eq 1 ]]
    then
        dict['target']="$(koopa_init_dir "${dict['target']}")"
        koopa_alert "Extracting '${dict['file']}' to '${dict['target']}'."
        dict['tmpdir']="$( \
            koopa_init_dir "$(koopa_parent_dir "${dict['file']}")/\
.koopa-extract-$(koopa_random_string)" \
        )"
        dict['tmpfile']="${dict['tmpdir']}/$(koopa_basename "${dict['file']}")"
        koopa_ln "${dict['file']}" "${dict['tmpfile']}"
        dict['file']="${dict['tmpfile']}"
    else
        koopa_alert "Extracting '${dict['file']}'."
        dict['tmpdir']="${dict['wd']}"
    fi
    (
        koopa_cd "${dict['tmpdir']}"
        case "${dict['file']}" in
            *'.tar' | \
            *'.tar.'* | \
            *'.tgz')
                local -a tar_cmd_args
                tar_cmd_args=(
                    '-f' "${dict['file']}" # '--file'.
                    '-x' # '--extract'.
                )
                app['tar']="$(koopa_locate_tar --allow-system)"
                if koopa_is_root && koopa_is_gnu "${app['tar']}"
                then
                    tar_cmd_args+=(
                        '--no-same-owner'
                        '--no-same-permissions'
                    )
                fi
                ;;
        esac
        case "${dict['file']}" in
            *'.tar.bz2' | \
            *'.tar.gz' | \
            *'.tar.lz' | \
            *'.tar.xz' | \
            *'.tbz2' | \
            *'.tgz')
                app['cmd']="${app['tar']}"
                cmd_args=("${tar_cmd_args[@]}")
                case "${dict['file']}" in
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
            *'.bz2')
                app['cmd']="$(koopa_locate_bunzip2 --allow-system)"
                cmd_args=("${dict['file']}")
                ;;
            *'.gz')
                app['cmd']="$(koopa_locate_gzip --allow-system)"
                cmd_args=(
                    '-d' # '--decompress'.
                    "${dict['file']}"
                )
                ;;
            *'.tar')
                app['cmd']="${app['tar']}"
                cmd_args=("${tar_cmd_args[@]}")
                ;;
            *'.xz')
                app['cmd']="$(koopa_locate_xz --allow-system)"
                cmd_args=(
                    '-d' # '--decompress'.
                    "${dict['file']}"
                    )
                ;;
            *'.zip')
                app['cmd']="$(koopa_locate_unzip --allow-system)"
                cmd_args=(
                    '-qq'
                    "${dict['file']}"
                )
                ;;
            *'.Z')
                app['cmd']="$(koopa_locate_uncompress --allow-system)"
                cmd_args=("${dict['file']}")
                ;;
            *'.7z')
                app['cmd']="$(koopa_locate_7z)"
                cmd_args=(
                    '-x'
                    "${dict['file']}"
                )
                ;;
            *)
                koopa_stop 'Unsupported file type.'
                ;;
        esac
        koopa_assert_is_executable "${app[@]}"
        "${app['cmd']}" "${cmd_args[@]}" 2>/dev/null
    )
    if [[ "${dict['move_into_target']}" -eq 1 ]]
    then
        koopa_rm "${dict['tmpfile']}"
        app['wc']="$(koopa_locate_wc --allow-system)"
        koopa_assert_is_executable "${app['wc']}"
        dict['count']="$( \
            koopa_find \
                --max-depth=1 \
                --min-depth=1 \
                --prefix="${dict['tmpdir']}" \
            | "${app['wc']}" -l \
        )"
        [[ "${dict['count']}" -gt 0 ]] || return 1
        (
            shopt -s dotglob
            if [[ "${dict['count']}" -eq 1 ]]
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
    fi
    return 0
}