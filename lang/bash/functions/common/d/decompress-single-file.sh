#!/usr/bin/env bash

koopa_decompress_single_file() {
    # """
    # Decompress a single compressed file.
    # @note Updated 2023-11-07.
    #
    # Intentionally supports only compression formats. For mixed archiving
    # and compression formats, use 'koopa_extract' instead.
    #
    # Intentionally allows uncompressed files to pass through. Useful for
    # pipelining handling of large compressed genomics files, such as FASTQ.
    #
    # @examples
    # # Default usage decompresses the file, but keeps the compressed original.
    # > koopa_decompress 'sample.fastq.gz'
    # # Creates 'sample.fastq' file.
    #
    # # Alternatively, can specify the path of the decompressed file.
    # > koopa_decompress 'sample.fastq.gz' '/tmp/sample.fastq'
    #
    # # If file is uncompressed, it will simply be copied.
    # > koopa_decompress 'sample.fastq' '/tmp/sample.fastq'
    #
    # # How to make a program "gzip aware", by redirecting via process
    # # substitution. Particularly useful for some NGS tools like STAR.
    # > head -n 1 <(koopa_decompress --stdout 'sample.fastq.gz')
    # # @A01587:114:GW2203131905th:2:1101:5791:1031 1:N:0:CGATCAGT+TTAGAGAG
    #
    # # Passthrough of uncompressed file is supported.
    # # head -n 1 <(koopa_decompress --stdout 'sample.fastq')
    # # @A01587:114:GW2203131905th:2:1101:5791:1031 1:N:0:CGATCAGT+TTAGAGAG
    #
    # @seealso
    # - https://en.wikipedia.org/wiki/List_of_archive_formats
    # """
    local -A app bool dict
    local -a cmd_args pos
    koopa_assert_has_args "$#"
    bool['keep']=1
    bool['passthrough']=0
    bool['stdout']=0
    bool['verbose']=0
    dict['compress_ext_pattern']="$(koopa_compress_ext_pattern)"
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--keep')
                bool['keep']=1
                shift 1
                ;;
            '--no-keep' | '--remove')
                bool['keep']=0
                shift 1
                ;;
            '--stdout')
                bool['stdout']=1
                shift 1
                ;;
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-')
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    dict['source_file']="${1:?}"
    koopa_assert_is_file "${dict['source_file']}"
    dict['source_file']="$(koopa_realpath "${dict['source_file']}")"
    if [[ "${bool['stdout']}" -eq 1 ]]
    then
        koopa_assert_has_args_eq "$#" 1
        dict['target_file']=''
    else
        koopa_assert_has_args_le "$#" 2
        dict['target_file']="${2:-}"
        if [[ -z "${dict['target_file']}" ]]
        then
            dict['target_file']="$( \
                koopa_sub \
                    --pattern="${dict['compress_ext_pattern']}" \
                    --regex \
                    --replacement='' \
                    "${dict['source_file']}" \
            )"
        fi
        # Return unmodified for non-compressed files.
        if [[ "${dict['source_file']}" == "${dict['target_file']}" ]]
        then
            return 0
        fi
    fi
    # Ensure that we're matching against case insensitive basename.
    dict['match']="$( \
        koopa_basename "${dict['source_file']}" \
        | koopa_lowercase \
    )"
    # Intentionally error on archive formats.
    case "${dict['match']}" in
        *'.z')
            koopa_stop "Use 'uncompress' directly on '.Z' files."
            ;;
        *'.7z' | \
        *'.a' | \
        *'.tar' | \
        *'.tar.'* | \
        *'.tbz2' | \
        *'.tgz' | \
        *'.zip')
            koopa_stop \
                "Unsupported archive file: '${dict['source_file']}'." \
                "Use 'koopa_extract' instead of 'koopa_decompress'."
            ;;
        *'.br' | \
        *'.bz2' | \
        *'.gz' | \
        *'.lz' | \
        *'.lz4' | \
        *'.lzma' | \
        *'.xz' | \
        *'.zstd')
            bool['passthrough']=0
            ;;
        *)
            bool['passthrough']=1
            ;;
    esac
    if [[ "${bool['passthrough']}" -eq 1 ]]
    then
        if [[ "${bool['stdout']}" -eq 1 ]]
        then
            app['cat']="$(koopa_locate_cat --allow-system)"
            koopa_assert_is_executable "${app['cat']}"
            "${app['cat']}" "${dict['source_file']}" || true
        else
            koopa_alert "Passthrough mode. Copying '${dict['source_file']}' to \
'${dict['target_file']}'."
            koopa_cp "${dict['source_file']}" "${dict['target_file']}"
        fi
        return 0
    fi
    case "${dict['match']}" in
        *'.br')
            app['cmd']="$(koopa_locate_brotli --allow-system)"
            ;;
        *'.bz2')
            app['cmd']="$( \
                koopa_locate_pbzip2 --allow-missing --allow-system \
            )"
            if [[ -x "${app['cmd']}" ]]
            then
                cmd_args+=("-p$(koopa_cpu_count)")
            else
                app['cmd']="$(koopa_locate_bzip2 --allow-system)"
            fi
            ;;
        *'.gz')
            app['cmd']="$( \
                koopa_locate_pigz --allow-missing --allow-system \
            )"
            if [[ -x "${app['cmd']}" ]]
            then
                cmd_args+=('-p' "$(koopa_cpu_count)")
            else
                app['cmd']="$(koopa_locate_gzip --allow-system)"
            fi
            ;;
        *'.lz')
            app['cmd']="$(koopa_locate_lzip --allow-system)"
            ;;
        *'.lz4')
            app['cmd']="$(koopa_locate_lz4 --allow-system)"
            ;;
        *'.lzma')
            app['cmd']="$(koopa_locate_lzma --allow-system)"
            ;;
        *'.xz')
            app['cmd']="$(koopa_locate_xz --allow-system)"
            ;;
        *'.zstd')
            app['cmd']="$(koopa_locate_zstd --allow-system)"
            ;;
    esac
    koopa_assert_is_executable "${app['cmd']}"
    cmd_args+=('-c' '-d' '-k')
    [[ "${bool['verbose']}" -eq 1 ]] && cmd_args+=('-v')
    cmd_args+=("${dict['source_file']}")
    if [[ "${bool['stdout']}" -eq 1 ]]
    then
        "${app['cmd']}" "${cmd_args[@]}" || true
    else
        koopa_alert "Decompressing '${dict['source_file']}' to \
'${dict['target_file']}'."
        "${app['cmd']}" "${cmd_args[@]}" > "${dict['target_file']}"
        koopa_assert_is_file "${dict['target_file']}"
    fi
    koopa_assert_is_file "${dict['source_file']}"
    if [[ "${bool['keep']}" -eq 0 ]]
    then
        koopa_rm "${dict['source_file']}"
    fi
    return 0
}
