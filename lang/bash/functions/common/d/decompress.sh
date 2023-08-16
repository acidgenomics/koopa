#!/usr/bin/env bash

koopa_decompress() {
    # """
    # Decompress a single compressed file.
    # @note Updated 2023-08-16.
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
    local -A bool dict
    local -a cmd_args pos
    local cmd
    koopa_assert_has_args "$#"
    bool['passthrough']=0
    bool['stdout']=0
    dict['compress_ext_pattern']="$(koopa_compress_ext_pattern)"
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--stdout')
                bool['stdout']=1
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
    koopa_assert_has_args_le "$#" 2
    dict['source_file']="${1:?}"
    dict['target_file']="${2:-}"
    koopa_assert_is_file "${dict['source_file']}"
    dict['source_file']="$(koopa_realpath "${dict['source_file']}")"
    # Ensure that we're matching against case insensitive basename.
    dict['match']="$(koopa_basename "${dict['source_file']}" | koopa_lowercase)"
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
    if [[ "${bool['stdout']}" -eq 1 ]]
    then
        if [[ -n "${dict['target_file']}" ]]
        then
            koopa_stop 'Target file is not supported for --stdout mode.'
        fi
    else
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
        *'.br' | \
        *'.bz2' | \
        *'.gz' | \
        *'.lz' | \
        *'.lz4' | \
        *'.lzma' | \
        *'.xz' | \
        *'.zstd')
            case "${dict['match']}" in
                *'.br')
                    cmd="$(koopa_locate_brotli)"
                    ;;
                *'.bz2')
                    cmd="$(koopa_locate_pbzip2 --allow-missing)"
                    if [[ -x "$cmd" ]]
                    then
                        cmd_args+=("-p$(koopa_cpu_count)")
                    else
                        cmd="$(koopa_locate_bzip2)"
                    fi
                    ;;
                *'.gz')
                    cmd="$(koopa_locate_pigz --allow-missing)"
                    if [[ -x "$cmd" ]]
                    then
                        cmd_args+=('-p' "$(koopa_cpu_count)")
                    else
                        cmd="$(koopa_locate_gzip)"
                    fi
                    ;;
                *'.lz')
                    cmd="$(koopa_locate_lzip)"
                    ;;
                *'.lz4')
                    cmd="$(koopa_locate_lz4)"
                    ;;
                *'.lzma')
                    cmd="$(koopa_locate_lzma)"
                    ;;
                *'.xz')
                    cmd="$(koopa_locate_xz)"
                    ;;
                *'.zstd')
                    cmd="$(koopa_locate_zstd)"
                    ;;
            esac
            cmd_args+=(
                '-c' # '--stdout'.
                '-d' # '--decompress'.
                '-f' # '--force'.
                '-k' # '--keep'.
                "${dict['source_file']}"
            )
            ;;
    esac
    koopa_assert_is_executable "$cmd"
    if [[ "${bool['stdout']}" -eq 1 ]]
    then
        "$cmd" "${cmd_args[@]}" || true
    else
        koopa_alert "Decompressing '${dict['source_file']}' to \
'${dict['target_file']}'."
        "$cmd" "${cmd_args[@]}" > "${dict['target_file']}"
    fi
    koopa_assert_is_file "${dict['source_file']}"
    if [[ -n "${dict['target_file']}" ]]
    then
        koopa_assert_is_file "${dict['target_file']}"
    fi
    return 0
}
