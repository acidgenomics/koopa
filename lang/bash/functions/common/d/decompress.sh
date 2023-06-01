#!/usr/bin/env bash

# FIXME brotli (br)
# FIXME lz (lzip)
# FIXME lz4 (???)
# FIXME Z (uncompress)
# FIXME zst (zstd)

# FIXME Add support for:
# - 7z (p7zip)
# - Z (uncompress)
# - lz (lzip)
# - zst (zstd)
# For 7z can use '-x' flag.
# For Z, don't need an argument.

koopa_decompress() {
    # """
    # Decompress a single compressed file.
    # @note Updated 2023-06-01.
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
    # FIXME br
    # FIXME lz
    # FIXME lz4
    # FIXME z
    # FIXME zstd
    case "${dict['match']}" in
        *'.bz2' | *'.gz' | *'.lzma' | *'.xz')
            case "${dict['source_file']}" in
                *'.bz2')
                    cmd="$(koopa_locate_bzip2)"
                    ;;
                *'.gz')
                    cmd="$(koopa_locate_gzip)"
                    ;;
                *'.lzma')
                    cmd="$(koopa_locate_lzma)"
                    ;;
                *'.xz')
                    cmd="$(koopa_locate_xz)"
                    ;;
            esac
            koopa_assert_is_executable "$cmd"
            cmd_args=(
                '-c' # '--stdout'.
                '-d' # '--decompress'.
                '-f' # '--force'.
                '-k' # '--keep'.
                "${dict['source_file']}"
            )
            if [[ "${bool['stdout']}" -eq 1 ]]
            then
                "$cmd" "${cmd_args[@]}" || true
            else
                koopa_alert "Decompressing '${dict['source_file']}' to \
'${dict['target_file']}'."
                "$cmd" "${cmd_args[@]}" > "${dict['target_file']}"
            fi
            ;;
        *)
            if [[ "${bool['stdout']}" -eq 1 ]]
            then
                app['cat']="$(koopa_locate_cat --allow-system)"
                koopa_assert_is_executable "${app['cat']}"
                "${app['cat']}" "${dict['source_file']}" || true
            else
                koopa_alert "Copying '${dict['source_file']}' to \
'${dict['target_file']}'."
                koopa_cp "${dict['source_file']}" "${dict['target_file']}"
            fi
            ;;
    esac
    if [[ "${bool['stdout']}" -eq 0 ]]
    then
        koopa_assert_is_file "${dict['target_file']}"
    fi
    return 0
}
