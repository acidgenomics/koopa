#!/usr/bin/env bash

_koopa_extract() {
    # """
    # Extract an archive file.
    # @note Updated 2025-03-09.
    #
    # See also:
    # - Mendel Cooper's Advanced Bash Scripting Guide.
    # - https://github.com/stephenturner/oneliners
    # - https://en.wikipedia.org/wiki/List_of_archive_formats
    # - Automatic parallel decompression
    #   https://twitter.com/Sanbomics/status/1691862498419597462
    # """
    local -A app bool dict
    local -a cmd_args contents
    _koopa_assert_has_args_le "$#" 2
    bool['decompress_only']=0
    bool['gnu_tar']=0
    dict['file']="${1:?}"
    dict['target_dir']="${2:-}"
    _koopa_assert_is_file "${dict['file']}"
    dict['bn']="$(_koopa_basename_sans_ext "${dict['file']}")"
    case "${dict['bn']}" in
        *'.tar')
            dict['bn']="$(_koopa_basename_sans_ext "${dict['bn']}")"
            ;;
    esac
    dict['file']="$(_koopa_realpath "${dict['file']}")"
    dict['match']="$( \
        _koopa_basename "${dict['file']}" \
        | _koopa_lowercase \
    )"
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
    if [[ -z "${dict['target_dir']}" ]]
    then
        dict['target_dir']="$(_koopa_parent_dir "${dict['file']}")/${dict['bn']}"
    fi
    dict['target_dir']="$(_koopa_init_dir "${dict['target_dir']}")"
    if [[ "${bool['decompress_only']}" -eq 1 ]]
    then
        dict['output_file']="${dict['target_dir']}/${dict['bn']}"
        _koopa_decompress \
            --input-file="${dict['file']}" \
            --output-file="${dict['output_file']}"
        return 0
    fi
    _koopa_alert "Extracting '${dict['file']}' to '${dict['target_dir']}'."
    dict['tmpdir']="$(_koopa_parent_dir "${dict['file']}")/$(_koopa_tmp_string)"
    dict['tmpdir']="$(_koopa_init_dir "${dict['tmpdir']}")"
    dict['tmpfile']="${dict['tmpdir']}/$(_koopa_basename "${dict['file']}")"
    _koopa_ln "${dict['file']}" "${dict['tmpfile']}"
    # Archiving only -----------------------------------------------------------
    case "${dict['match']}" in
        *'.tar' | \
        *'.tar.'* | \
        *'.tbz2' | \
        *'.tgz')
            local -a tar_cmd_args
            app['tar']="$(_koopa_locate_tar --allow-system --realpath)"
            _koopa_assert_is_executable "${app['tar']}"
            if _koopa_is_gnu "${app['tar']}"
            then
                bool['gnu_tar']=1
            else
                bool['gnu_tar']=0
            fi
            if _koopa_is_root && [[ "${bool['gnu_tar']}" -eq 1 ]]
            then
                tar_cmd_args+=('--no-same-owner' '--no-same-permissions')
            fi
            tar_cmd_args+=(
                '-f' "${dict['tmpfile']}"
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
                            _koopa_locate_pbzip2 --allow-missing --allow-system \
                        )"
                        if [[ ! -x "${app['cmd2']}" ]]
                        then
                            app['cmd2']="$(_koopa_locate_bzip2 --allow-system)"
                        fi
                        ;;
                    *'.gz' | *'.tgz')
                        # Enable parallel decompression, when possible.
                        app['cmd2']="$( \
                            _koopa_locate_pigz --allow-missing --allow-system \
                        )"
                        if [[ ! -x "${app['cmd2']}" ]]
                        then
                            app['cmd2']="$(_koopa_locate_gzip --allow-system)"
                        fi
                        ;;
                    *'.lz')
                        app['cmd2']="$(_koopa_locate_lzip --allow-system)"
                        ;;
                    *'.xz')
                        app['cmd2']="$(_koopa_locate_xz --allow-system)"
                        ;;
                esac
                cmd_args+=('--use-compress-program' "${app['cmd2']}")
            else
                # BSD tar (e.g. on macOS) supports bzip2, gzip, and xz.
                case "${dict['tmpfile']}" in
                    *'.bz2' | *'.tbz2')
                        app['cmd2']="$(_koopa_locate_bzip2 --allow-system)"
                        cmd_args+=('-j')
                        ;;
                    *'.gz' | *'.tgz')
                        app['cmd2']="$(_koopa_locate_gzip --allow-system)"
                        cmd_args+=('-z')
                        ;;
                    *'.xz')
                        app['cmd2']="$(_koopa_locate_xz --allow-system)"
                        cmd_args+=('-J')
                        ;;
                    *)
                        # e.g. lzip not supported here.
                        _koopa_stop "Unsupported file: '${dict['tmpfile']}'."
                        ;;
                esac
            fi
            _koopa_assert_is_executable "${app['cmd2']}"
            ;;
        *'.tar')
            app['cmd']="${app['tar']}"
            cmd_args+=("${tar_cmd_args[@]}")
            ;;
        # Archiving and compression --------------------------------------------
        *'.7z')
            app['cmd']="$(_koopa_locate_7z --allow-system)"
            cmd_args+=('-x' "${dict['tmpfile']}")
            ;;
        *'.zip')
            app['cmd']="$(_koopa_locate_unzip --allow-system)"
            cmd_args+=('-qq' "${dict['tmpfile']}")
            ;;
        # Other ----------------------------------------------------------------
        *)
            _koopa_stop "Unsupported file: '${dict['file']}'."
            ;;
    esac
    _koopa_assert_is_executable "${app['cmd']}"
    (
        _koopa_cd "${dict['tmpdir']}"
        # This step currently only applies to tar operations.
        if [[ "${bool['gnu_tar']}" -eq 0 ]] && [[ -x "${app['cmd2']:-}" ]]
        then
            _koopa_add_to_path_start "$(_koopa_dirname "${app['cmd2']}")"
        fi
        "${app['cmd']}" "${cmd_args[@]}" # 2>/dev/null
    )
    _koopa_rm "${dict['tmpfile']}"
    readarray -t contents <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['tmpdir']}" \
    )"
    if _koopa_is_array_empty "${contents[@]}"
    then
        _koopa_stop "Empty archive file: '${dict['file']}'."
    fi
    (
        shopt -s dotglob
        if [[ "${#contents[@]}" -eq 1 ]] && [[ -d "${contents[0]}" ]]
        then
            _koopa_mv \
                --target-directory="${dict['target_dir']}" \
                "${dict['tmpdir']}"/*/*
        else
            _koopa_mv \
                --target-directory="${dict['target_dir']}" \
                "${dict['tmpdir']}"/*
        fi
    )
    _koopa_rm "${dict['tmpdir']}"
    return 0
}
