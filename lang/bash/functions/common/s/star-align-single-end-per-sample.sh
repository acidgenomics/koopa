#!/usr/bin/env bash

koopa_star_align_single_end_per_sample() {
    # """
    # Run STAR aligner on a single-end sample.
    # @note Updated 2023-11-10.
    #
    # These settings are optimized for Homo sapiens GRCh38 reference genome.
    # Recommend using at least r6a.2xlarge AWS EC2 instance.
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
    app['star']="$(koopa_locate_star --realpath)"
    koopa_assert_is_executable "${app[@]}"
    bool['tmp_fastq_file']=0
    bool['tmp_gtf_file']=0
    # e.g. 'fastq'.
    dict['fastq_file']=''
    # e.g. 'gencode.v39.annotation.gtf.gz'
    dict['gtf_file']=''
    # e.g. 'star-index'.
    dict['index_dir']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=40
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
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
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
        '--gtf-file' "${dict['gtf_file']}" \
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
    koopa_assert_is_file "${dict['fastq_file']}" "${dict['gtf_file']}"
    dict['gtf_file']="$(koopa_realpath "${dict['gtf_file']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['fastq_bn']}' in '${dict['output_dir']}'."
    if koopa_is_compressed_file "${dict['fastq_file']}"
    then
        bool['tmp_fastq_file']=1
        dict['tmp_fastq_file']="$(koopa_tmp_file_in_wd)"
        koopa_decompress \
            --input-file="${dict['fastq_file']}" \
            --output-file="${dict['tmp_fastq_file']}"
        dict['fastq_file']="${dict['tmp_fastq_file']}"
    fi
    if koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(koopa_tmp_file_in_wd)"
        koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    koopa_alert "Detecting read length in '${dict['fastq_r1_file']}'."
    dict['read_length']="$(koopa_fastq_read_length "${dict['fastq_file']}")"
    koopa_dl 'Read length' "${dict['read_length']}"
    dict['sjdb_overhang']="$((dict['read_length'] - 1))"
    align_args+=(
        '--alignIntronMax' 1000000
        '--alignIntronMin' 20
        '--alignMatesGapMax' 1000000
        '--alignSJDBoverhangMin' 1
        '--alignSJoverhangMin' 8
        '--genomeDir' "${dict['index_dir']}"
        '--limitBAMsortRAM' "${dict['limit_bam_sort_ram']}"
        '--limitOutSJcollapsed' 2000000
        '--outFileNamePrefix' "${dict['output_dir']}/"
        '--outFilterMismatchNmax' 999
        '--outFilterMismatchNoverReadLmax' 0.04
        '--outFilterMultimapNmax' 20
        '--outFilterType' 'BySJout'
        '--outReadsUnmapped' 'Fastx'
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--quantMode' 'TranscriptomeSAM'
        '--readFilesIn' "${dict['fastq_file']}"
        '--runMode' 'alignReads'
        '--runRNGseed' 0
        '--runThreadN' "${dict['threads']}"
        '--sjdbGTFfile' "${dict['gtf_file']}"
        '--sjdbOverhang' "${dict['sjdb_overhang']}"
        '--twopassMode' 'Basic'
    )
    koopa_dl 'Align args' "${align_args[*]}"
    koopa_write_string \
        --file="${dict['output_dir']}/star-align-cmd.log" \
        --string="${app['star']} ${align_args[*]}"
    "${app['star']}" "${align_args[@]}"
    if [[ "${bool['tmp_fastq_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['fastq_file']}"
    fi
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['gtf_file']}"
    fi
    koopa_rm "${dict['output_dir']}/_STAR"*
    dict['bam_file']="${dict['output_dir']}/Aligned.sortedByCoord.out.bam"
    koopa_assert_is_file "${dict['bam_file']}"
    koopa_alert "Indexing BAM file '${dict['bam_file']}'."
    koopa_samtools_index_bam "${dict['bam_file']}"
    return 0
}
