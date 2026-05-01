#!/usr/bin/env bash

_koopa_samtools_convert_sam_to_bam() {
    # """
    # Convert a SAM file to BAM format.
    # @note Updated 2023-11-07.
    #
    # samtools view --help
    # Useful flags:
    # -1                    use fast BAM compression (implies -b)
    # -@, --threads         number of threads
    # -C                    output CRAM (requires -T)
    # -O, --output-fmt      specify output format (SAM, BAM, CRAM)
    # -T, --reference       reference sequence FASTA file
    # -b                    output BAM
    # -o FILE               output file name [stdout]
    # -u                    uncompressed BAM output (implies -b)
    # """
    local -A app bool dict
    local -a pos
    local file
    _koopa_assert_has_args "$#"
    app['samtools']="$(_koopa_locate_samtools)"
    _koopa_assert_is_executable "${app[@]}"
    bool['keep']=0
    dict['threads']="$(_koopa_cpu_count)"
    pos=()
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
            # Other ------------------------------------------------------------
            '-'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    for file in "$@"
    do
        local -A dict2
        dict2['sam_file']="$file"
        _koopa_assert_is_matching_regex \
            --pattern='\.sam$' \
            --string="${dict2['sam_file']}"
        dict2['bam_file']="$( \
            _koopa_sub \
                --pattern='\.sam$' \
                --regex \
                --replacement='.bam' \
                "${dict2['sam_file']}" \
        )"
        if [[ -f "${dict2['bam_file']}" ]]
        then
            _koopa_alert_note "Skipping '${dict2['bam_file']}'."
            return 0
        fi
        _koopa_alert "Converting '${dict2['sam_file']}' to \
'${dict2['bam_file']}'."
        "${app['samtools']}" view \
            -@ "${dict['threads']}" \
            -b \
            -h \
            -o "${dict2['bam_file']}" \
            "${dict2['sam_file']}"
        _koopa_assert_is_file \
            "${dict2['bam_file']}" \
            "${dict2['sam_file']}"
        if [[ "${bool['keep']}" -eq 0 ]]
        then
            _koopa_rm "${dict2['sam_file']}"
        fi
    done
    return 0
}
