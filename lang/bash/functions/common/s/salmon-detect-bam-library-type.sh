#!/usr/bin/env bash

koopa_salmon_detect_bam_library_type() {
    # """
    # Detect library type (strandedness) of input BAMs.
    # @note Updated 2023-11-13.
    #
    # @seealso
    # - salmon quant --help-alignment | less
    # - https://www.biostars.org/p/98756/
    #
    # @examples
    # Paired-end:
    # > koopa_salmon_detect_bam_library_type \
    # >     --bam-file='DMSO-1.bam' \
    # >     --index-dir='indexes/salmon-gencode'
    # # IU
    #
    # Single-end:
    # > koopa_salmon_detect_bam_library_type \
    # >     --bam-file='DMSO-1.bam' \
    # >     --index-dir='indexes/salmon-gencode'
    # # U
    # """
    local -A app dict
    local -a quant_args
    koopa_assert_has_args "$#"
    app['head']="$(koopa_locate_head --allow-system)"
    app['jq']="$(koopa_locate_jq --allow-system)"
    app['salmon']="$(koopa_locate_salmon)"
    koopa_assert_is_executable "${app[@]}"
    dict['bam_file']=''
    # e.g. 'gencode.v44.transcripts.fa.gz'.
    dict['tx_fasta_file']=''
    dict['n']='400000'
    dict['threads']="$(koopa_cpu_count)"
    dict['tmp_dir']="$(koopa_tmp_dir_in_wd)"
    dict['output_dir']="${dict['tmp_dir']}/quant"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bam-file='*)
                dict['bam_file']="${1#*=}"
                shift 1
                ;;
            '--bam-file')
                dict['bam_file']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['tx_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['tx_fasta_file']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bam-file' "${dict['bam_file']}" \
        '--transcriptome-fasta-file' "${dict['tx_fasta_file']}"
    koopa_assert_is_file \
        "${dict['bam_file']}" \
        "${dict['tx_fasta_file']}"
    quant_args+=(
        "--alignments=${dict['bam_file']}"
        '--libType=A'
        '--no-version-check'
        "--output=${dict['output_dir']}"
        '--quiet'
        '--skipQuant'
        "--targets=${dict['tx_fasta_file']}"
        "--threads=${dict['threads']}"
    )
    # FIXME Add back pipe to dev null here after working version.
    "${app['salmon']}" quant "${quant_args[@]}"
    dict['json_file']="${dict['output_dir']}/lib_format_counts.json"
    koopa_assert_is_file "${dict['json_file']}"
    dict['lib_type']="$( \
        "${app['jq']}" --raw-output '.expected_format' "${dict['json_file']}" \
    )"
    koopa_print "${dict['lib_type']}"
    koopa_rm "${dict['tmp_dir']}"
    return 0
}
