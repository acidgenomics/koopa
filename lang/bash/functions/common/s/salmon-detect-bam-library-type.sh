#!/usr/bin/env bash

koopa_salmon_detect_bam_library_type() {
    # """
    # Detect library type (strandedness) of input BAMs.
    # @note Updated 2023-11-13.
    #
    # @seealso
    # - salmon quant --help-alignment | less
    # - https://github.com/COMBINE-lab/salmon/blob/master/src/LibraryFormat.cpp
    # - https://www.biostars.org/p/98756/
    #
    # @examples
    # STAR GENCODE genome-level:
    # > koopa_salmon_detect_bam_library_type \
    # >     --bam-file='Aligned.sortedByCoord.out.bam' \
    # >     --fasta-file='GRCh38.primary_assembly.genome.fa.gz'
    # # MU
    #
    # STAR GENCODE transcriptome-level:
    # > koopa_salmon_detect_bam_library_type \
    # >     --bam-file='Aligned.toTranscriptome.out.bam' \
    # >     --fasta-file='gencode.v44.transcripts.fa.gz'
    # # IU
    # """
    local -A app bool dict
    local -a quant_args
    koopa_assert_has_args "$#"
    app['head']="$(koopa_locate_head --allow-system)"
    app['jq']="$(koopa_locate_jq --allow-system)"
    app['salmon']="$(koopa_locate_salmon)"
    app['samtools']="$(koopa_locate_samtools)"
    koopa_assert_is_executable "${app[@]}"
    bool['gencode']=0
    # e.g. 'Aligned.toTranscriptome.out.bam'.
    dict['bam_file']=''
    # e.g. 'gencode.v44.transcripts_fixed.fa.gz'.
    dict['fasta_file']=''
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
            '--fasta-file='*)
                dict['fasta_file']="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict['fasta_file']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--gencode')
                bool['gencode']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bam-file' "${dict['bam_file']}" \
        '--fasta-file' "${dict['fasta_file']}"
    koopa_assert_is_file \
        "${dict['bam_file']}" \
        "${dict['fasta_file']}"
    dict['alignments']="${dict['tmp_dir']}/alignments.sam"
    if [[ "${bool['gencode']}" -eq 0 ]] && \
        koopa_str_detect_regex \
            --string="$(koopa_basename "${dict['transcriptome_fasta_file']}")" \
            --pattern='^gencode\.'
    then
        bool['gencode']=1
    fi
    "${app['samtools']}" view \
            -@ "${dict['threads']}" \
            -h \
            "${dict['bam_file']}" \
        | "${app['head']}" -n "${dict['n']}" \
        > "${dict['alignments']}" \
        || true
    if [[ "${bool['gencode']}" -eq 1 ]]
    then
        quant_args+=('--gencode')
    fi
    quant_args+=(
        "--alignments=${dict['alignments']}"
        '--libType=A'
        '--no-version-check'
        "--output=${dict['output_dir']}"
        '--quiet'
        '--skipQuant'
        "--targets=${dict['fasta_file']}"
        "--threads=${dict['threads']}"
    )
    # FIXME Re-enable this after debugging:
    # > "${app['salmon']}" quant "${quant_args[@]}" &>/dev/null
    "${app['salmon']}" quant "${quant_args[@]}"
    dict['json_file']="${dict['output_dir']}/aux_info/meta_info.json"
    koopa_assert_is_file "${dict['json_file']}"
    dict['lib_type']="$( \
        "${app['jq']}" \
            --raw-output \
            '.library_types.[]' \
            "${dict['json_file']}" \
    )"
    koopa_print "${dict['lib_type']}"
    koopa_rm "${dict['tmp_dir']}"
    return 0
}
