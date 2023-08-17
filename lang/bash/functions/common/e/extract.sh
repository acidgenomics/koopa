#!/usr/bin/env bash

koopa_extract() {
    # """
    # Extract files from an archive automatically.
    # @note Updated 2023-08-17.
    #
    # As suggested by Mendel Cooper in Advanced Bash Scripting Guide.
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    # - https://en.wikipedia.org/wiki/List_of_archive_formats
    # - Automatic parallel decompression
    #   https://twitter.com/Sanbomics/status/1691862498419597462
    # """
    local -A app bool dict
    local -a cmd_args contents
    koopa_assert_has_args_le "$#" 2
    bool['decompress_only']=0
    dict['file']="${1:?}"
    dict['target_dir']="${2:-}"
    koopa_assert_is_file "${dict['file']}"
    dict['bn']="$(koopa_basename_sans_ext "${dict['file']}")"
    case "${dict['bn']}" in
        *'.tar')
            dict['bn']="$(koopa_basename_sans_ext "${dict['bn']}")"
            ;;
    esac
    dict['file']="$(koopa_realpath "${dict['file']}")"
    dict['match']="$(koopa_basename "${dict['file']}" | koopa_lowercase)"
    case "${dict['match']}" in
        *'.tar.bz2' | \
        *'.tar.gz' | \
        *'.tar.lz' | \
        *'.tar.xz')
            bool['decompress_only']=0
            ;;
        *'.br' | \
        *'.bz2' | \
        *'.gz' | \
        *'.lz' | \
        *'.lz4' | \
        *'.lzma' | \
        *'.xz' | \
        *'.z' | \
        *'.zst')
            bool['decompress_only']=1
            ;;
    esac
    if [[ "${bool['decompress_only']}" -eq 1 ]]
    then
        cmd_args+=("${dict['file']}")
        if [[ -n "${dict['target_dir']}" ]]
        then
            dict['target_dir']="$(koopa_init_dir "${dict['target_dir']}")"
            dict['target_file']="${dict['target_dir']}/${dict['bn']}"
            cmd_args+=("${dict['target_file']}")
        fi
        koopa_decompress "${cmd_args[@]}"
        return 0
    fi
    if [[ -z "${dict['target_dir']}" ]]
    then
        dict['target_dir']="$(koopa_parent_dir "${dict['file']}")/${dict['bn']}"
    fi
    dict['target_dir']="$(koopa_init_dir "${dict['target_dir']}")"
    koopa_alert "Extracting '${dict['file']}' to '${dict['target_dir']}'."
    dict['tmpdir']="$( \
        koopa_init_dir "$(koopa_parent_dir "${dict['file']}")/\
.koopa-extract-$(koopa_random_string)" \
    )"
    dict['tmpfile']="${dict['tmpdir']}/$(koopa_basename "${dict['file']}")"
    koopa_ln "${dict['file']}" "${dict['tmpfile']}"
    # Archiving only -----------------------------------------------------------
    case "${dict['match']}" in
        *'.tar' | \
        *'.tar.'* | \
        *'.tbz2' | \
        *'.tgz')
            local -a tar_cmd_args
            app['tar']="$(koopa_locate_tar --allow-system)"
            koopa_assert_is_executable "${app['tar']}"
            if koopa_is_gnu "${app['tar']}"
            then
                bool['gnu_tar']=1
            else
                bool['gnu_tar']=0
            fi
            if koopa_is_root && [[ "${bool['gnu_tar']}" -eq 1 ]]
            then
                tar_cmd_args+=('--no-same-owner' '--no-same-permissions')
            fi
            tar_cmd_args+=(
                # GNU: '--file'.
                '-f' "${dict['tmpfile']}"
                # GNU: '--extract'.
                '-x'
            )
            ;;
    esac
    case "${dict['match']}" in
        *'.tar.bz2' | \
        *'.tar.gz' | \
        *'.tar.lz' | \
        *'.tar.xz' | \
        *'.tbz2' | \
        *'.tgz')
            app['cmd']="${app['tar']}"
            app['cmd2']=''
            cmd_args+=("${tar_cmd_args[@]}")
            if [[ "${bool['gnu_tar']}" -eq 1 ]]
            then
                case "${dict['tmpfile']}" in
                    *'.bz2' | *'.tbz2')
                        # Enable parallel decompression, when possible.
                        app['cmd2']="$( \
                            koopa_locate_pbzip2 --allow-missing --allow-system \
                        )"
                        if [[ ! -x "${app['cmd2']}" ]]
                        then
                            app['cmd2']="$(koopa_locate_bzip2 --allow-system)"
                        fi
                        ;;
                    *'.gz' | *'.tgz')
                        # Enable parallel decompression, when possible.
                        app['cmd2']="$( \
                            koopa_locate_pigz --allow-missing --allow-system \
                        )"
                        if [[ ! -x "${app['cmd2']}" ]]
                        then
                            app['cmd2']="$(koopa_locate_gzip --allow-system)"
                        fi
                        ;;
                    *'.lz')
                        app['cmd2']="$(koopa_locate_lzip --allow-system)"
                        ;;
                    *'.xz')
                        app['cmd2']="$(koopa_locate_xz --allow-system)"
                        ;;
                esac
                cmd_args+=('--use-compress-program' "${app['cmd2']}")
            else
                # BSD tar (e.g. on macOS) supports bzip2, gzip, and xz.
                case "${dict['tmpfile']}" in
                    *'.bz2' | *'.tbz2')
                        app['cmd2']="$(koopa_locate_bzip2 --allow-system)"
                        cmd_args+=('-j')
                        ;;
                    *'.gz' | *'.tgz')
                        app['cmd2']="$(koopa_locate_gzip --allow-system)"
                        cmd_args+=('-z')
                        ;;
                    *'.xz')
                        app['cmd2']="$(koopa_locate_xz --allow-system)"
                        cmd_args+=('-J')
                        ;;
                    *)
                        # e.g. lzip not supported here.
                        koopa_stop 'Unsupported file.'
                        ;;
                esac
            fi
            koopa_assert_is_executable "${app['cmd2']}"
            ;;
        *'.tar')
            app['cmd']="${app['tar']}"
            cmd_args+=("${tar_cmd_args[@]}")
            ;;
        # Archiving and compression --------------------------------------------
        *'.7z')
            app['cmd']="$(koopa_locate_7z --allow-system)"
            cmd_args+=('-x' "${dict['tmpfile']}")
            ;;
        *'.zip')
            app['cmd']="$(koopa_locate_unzip --allow-system)"
            cmd_args+=('-qq' "${dict['tmpfile']}")
            ;;
        # Other ----------------------------------------------------------------
        *)
            koopa_stop "Unsupported file: '${dict['file']}'."
            ;;
    esac
    koopa_assert_is_executable "${app['cmd']}"
    (
        koopa_cd "${dict['tmpdir']}"
        if [[ "${bool['gnu_tar']}" -eq 0 ]]
        then
            koopa_add_to_path_start "$(koopa_dirname "${app['cmd2']}")"
        fi
        "${app['cmd']}" "${cmd_args[@]}" # 2>/dev/null
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
                --target-directory="${dict['target_dir']}" \
                "${dict['tmpdir']}"/*/*
        else
            koopa_mv \
                --target-directory="${dict['target_dir']}" \
                "${dict['tmpdir']}"/*
        fi
    )
    koopa_rm "${dict['tmpdir']}"
    return 0
}
