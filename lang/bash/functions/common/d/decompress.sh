#!/usr/bin/env bash

# FIXME Ensure that file extension matching is case insensitive.
# FIXME Don't support compression formats that allow for decompression of
# multiple files here: e.g. zip.
# FIXME Add support for brotli here.
# FIXME Migrate support for '.Z' from extract here.
# FIXME Remove support for xz from extract and use code here instead.
# FIXME What's the difference here between decompress and extract?
# NOTE Add support for lzip (lz).
# NOTE Add support for zstd (zst).

koopa_decompress() {
    # """
    # Decompress a single compressed file.
    # @note Updated 2023-05-31.
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
    local -A dict
    local -a cmd_args pos
    local cmd
    koopa_assert_has_args "$#"
    dict['compress_ext_pattern']="$(koopa_compress_ext_pattern)"
    dict['stdout']=0
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--stdout')
                dict['stdout']=1
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
    case "${dict['stdout']}" in
        '0')
            if [[ -z "${dict['target_file']}" ]]
            then
                dict['target_file']="$( \
                    koopa_sub \
                        --pattern="${dict['compress_ext_pattern']}" \
                        --replacement='' \
                        "${dict['source_file']}" \
                )"
            fi
            if [[ "${dict['source_file']}" == "${dict['target_file']}" ]]
            then
                return 0
            fi
            ;;
        '1')
            [[ -z "${dict['target_file']}" ]] || return 1
            ;;
    esac
    dict['source_file']="$(koopa_realpath "${dict['source_file']}")"
    # FIXME Consider not always redicting to stdout here -- see '-c' flag usage
    # below. Instead, only do that when stdout is desired.
    # FIXME Add support for:
    # - 7z (p7zip)
    # - Z (uncompress)
    # - lz (lzip)
    # - zst (zstd)
    # - lzma
    # For 7z can use '-x' flag.
    # For Z, don't need an argument.
    case "${dict['source_file']}" in
        *'.bz2' | *'.gz' | *'.xz')
            case "${dict['source_file']}" in
                *'.bz2')
                    cmd="$(koopa_locate_bzip2)"
                    ;;
                *'.gz')
                    cmd="$(koopa_locate_gzip)"
                    ;;
                *'.xz')
                    cmd="$(koopa_locate_xz)"
                    ;;
            esac
            [[ -x "$cmd" ]] || return 1
            cmd_args=(
                # FIXME Only use '--stdout' when piping to stdout...rethink.
                '-c' # '--stdout'.
                '-d' # '--decompress'.
                '-f' # '--force'.
                '-k' # '--keep'.
                "${dict['source_file']}"
            )
            case "${dict['stdout']}" in
                '0')
                    "$cmd" "${cmd_args[@]}" > "${dict['target_file']}"
                    ;;
                '1')
                    "$cmd" "${cmd_args[@]}" || true
                    ;;
            esac
            ;;
        *)
            case "${dict['stdout']}" in
                '0')
                    koopa_cp "${dict['source_file']}" "${dict['target_file']}"
                    ;;
                '1')
                    cmd="$(koopa_locate_cat --allow-system)"
                    [[ -x "$cmd" ]] || return 1
                    "$cmd" "${dict['source_file']}" || true
                    ;;
            esac
            ;;
    esac
    if [[ "${dict['stdout']}" -eq 0 ]]
    then
        koopa_assert_is_file "${dict['target_file']}"
    fi
    return 0
}
