#!/usr/bin/env bash

koopa_decompress() {
    # """
    # Decompress multiple files.
    # @note Updated 2023-11-07.
    #
    # @examples
    # # Default usage decompresses the file, but keeps the compressed original.
    # > koopa_decompress 'sample.fastq.gz'
    # # Creates 'sample.fastq' file.
    #
    # # Alternatively, can specify the path of the decompressed file.
    # > koopa_decompress \
    # >     --input-file='sample.fastq.gz' \
    # >     --output-file='/tmp/sample.fastq'
    #
    # # If file is uncompressed, it will simply be copied.
    # > koopa_decompress \
    # >     --input-file='sample.fastq' \
    # >     --output-file='/tmp/sample.fastq'
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
    local -a flags pos
    local input_file
    koopa_assert_has_args "$#"
    bool['single_file']=0
    dict['input_file']=''
    dict['output_file']=''
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--input-file='*)
                bool['single_file']=1
                dict['input_file']="${1#*=}"
                shift 1
                ;;
            '--input-file')
                bool['single_file']=1
                dict['input_file']="${2:?}"
                shift 2
                ;;
            '--output-file='*)
                bool['single_file']=1
                dict['output_file']="${1#*=}"
                shift 1
                ;;
            '--output-file')
                bool['single_file']=1
                dict['output_file']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--'*)
                flags+=("$1")
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "${bool['single_file']}" -eq 1 ]]
    then
        koopa_assert_has_no_args "$#"
        koopa_assert_is_set \
            '--input-file' "${dict['input_file']}" \
            '--output-file' "${dict['output_file']}"
        koopa_assert_is_file "${dict['input_file']}"
        koopa_assert_is_not_file "${dict['output_file']}"
        koopa_decompress_single_file \
            "${flags[@]}" \
            "${dict['input_file']}" \
            "${dict['output_file']}"
    else
        koopa_assert_has_args "$#"
        koopa_assert_is_file "$@"
        for input_file in "$@"
        do
            koopa_decompress_single_file "${flags[@]}" "$input_file"
        done
    fi
    return 0
}
