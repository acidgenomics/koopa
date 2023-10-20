#!/usr/bin/env bash

koopa_star_align_single_end_per_sample() {
    # """
    # Run STAR aligner on a single-end sample.
    # @note Updated 2023-10-20.
    #
    # @seealso
    # - https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/
    #     Expression_mRNA_Pipeline/
    #
    # @examples
    # > koopa_star_align_single_end_per_sample \
    # >     --fastq-file='fastq/sample1_001.fastq.gz' \
    # >     --index-dir='indexes/star-gencode' \
    # >     --output-dir='quant/star-gencode/sample1'
    # """
    local -A app bool dict
    local -a align_args
    koopa_assert_has_args "$#"
    app['star']="$(koopa_locate_star)"
    koopa_assert_is_executable "${app[@]}"
    bool['tmp_fastq_file']=0
    # e.g. 'fastq'.
    dict['fastq_file']=''
    # e.g. 'star-index'.
    dict['index_dir']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=60
    # e.g. 'star'.
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict['fastq_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "STAR 'alignReads' mode requires ${dict['mem_gb_cutoff']} \
GB of RAM."
    fi
    dict['limit_bam_sort_ram']=$(( dict['mem_gb'] * 1000000000 ))
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_file']}"
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['fastq_bn']}' in '${dict['output_dir']}'."
    if koopa_is_compressed_file "${dict['fastq_file']}"
    then
        bool['tmp_fastq_file']=1
        dict['tmp_fastq_file']="$(koopa_tmp_file_in_wd)"
        koopa_alert "Decompressing '${dict['fastq_file']}' to \
'${dict['tmp_fastq_file']}"
        koopa_decompress \
            "${dict['fastq_file']}" \
            "${dict['tmp_fastq_file']}"
        dict['fastq_file']="${dict['tmp_fastq_file']}"
    fi
    align_args+=(
        '--genomeDir' "${dict['index_dir']}"
        '--limitBAMsortRAM' "${dict['limit_bam_sort_ram']}"
        '--outFileNamePrefix' "${dict['output_dir']}/"
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--quantMode' 'TranscriptomeSAM'
        '--readFilesIn' "${dict['fastq_file']}"
        '--runMode' 'alignReads'
        '--runRNGseed' '0'
        '--runThreadN' "${dict['threads']}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['star']}" "${align_args[@]}"
    if [[ "${bool['tmp_fastq_file']}" ]]
    then
        koopa_rm "${dict['fastq_file']}"
    fi
    koopa_rm "${dict['output_dir']}/_STAR"*
    # Ensure genome-level BAM file is indexed for IGV. Can skip indexing of
    # transcriptome-level 'Aligned.toTranscriptome.out.bam' file.
    dict['bam_file']="${dict['output_dir']}/Aligned.sortedByCoord.out.bam"
    koopa_assert_is_file "${dict['bam_file']}"
    koopa_alert "Indexing BAM file '${dict['bam_file']}'."
    koopa_samtools_index_bam "${dict['bam_file']}"
    return 0
}
