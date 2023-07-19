#!/usr/bin/env bash

# FIXME Add support for AWS S3 URI FASTQ input.
# FIXME Ensure we index all BAM files with samtools.
# But only do this for 'Aligned.sortedByCoord.out.bam' file,
# not the 'Aligned.toTranscriptome.out.bam' output.

koopa_star_align_paired_end_per_sample() {
    # """
    # Run STAR aligner on a paired-end sample.
    # @note Updated 2023-07-18.
    #
    # @seealso
    # - https://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf
    # - https://github.com/nf-core/rnaseq/blob/master/modules/nf-core/
    #     star/align/main.nf
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/ngsalign/
    #     star.py
    # - https://www.biostars.org/p/243683/
    # - https://github.com/hbctraining/Intro-to-rnaseq-hpc-O2/blob/
    #     master/lessons/03_alignment.md
    #
    # @examples
    # > koopa_star_align_paired_end_per_sample \
    # >     --fastq-r1-file='fastq/sample1_R1_001.fastq.gz' \
    # >     --fastq-r1-tail='_R1_001.fastq.gz' \
    # >     --fastq-r2-file='fastq/sample1_R2_001.fastq.gz' \
    # >     --fastq-r2-tail="_R2_001.fastq.gz' \
    # >     --index-dir='star-index' \
    # >     --output-dir='star'
    # """
    local -A app dict
    local -a align_args
    app['star']="$(koopa_locate_star)"
    koopa_assert_is_executable "${app[@]}"
    # e.g. 'default'
    dict['aws_profile']=''
    # e.g. 's3://bioinfo/rnaseq/sample1'
    dict['aws_s3_uri']=''
    # e.g. 'sample1_R1_001.fastq.gz'.
    dict['fastq_r1_file']=''
    # e.g. 'sample1_R2_001.fastq.gz'.
    dict['fastq_r2_file']=''
    # e.g. 'star-index'.
    dict['index_dir']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=60
    # e.g. 'star/sample1'.
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    align_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--aws-s3-uri='*)
                dict['aws_s3_uri']="${1#*=}"
                shift 1
                ;;
            '--aws-s3-uri')
                dict['aws_s3_uri']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
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
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
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
    koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r2_bn']="$(koopa_basename "${dict['fastq_r2_file']}")"
    koopa_alert "Quantifying '${dict['fastq_r1_bn']}' and \
'${dict['fastq_r2_bn']}' in '${dict['output_dir']}'."
    dict['tmp_fastq_r1_file']="$(koopa_tmp_file)"
    dict['tmp_fastq_r2_file']="$(koopa_tmp_file)"
    # FIXME Decompress into temporary inside working directory instead.
    # Use 'koopa_random_string' to generate a random file basename.
    koopa_alert "Decompressing '${dict['fastq_r1_file']}' \
to '${dict['tmp_fastq_r1_file']}"
    koopa_decompress "${dict['fastq_r1_file']}" "${dict['tmp_fastq_r1_file']}"
    # FIXME Decompress into temporary inside working directory instead.
    # Use 'koopa_random_string' to generate a random file basename.
    koopa_alert "Decompressing '${dict['fastq_r2_file']}' \
to '${dict['tmp_fastq_r2_file']}"
    koopa_decompress "${dict['fastq_r2_file']}" "${dict['tmp_fastq_r2_file']}"
    align_args+=(
        '--genomeDir' "${dict['index_dir']}"
        '--limitBAMsortRAM' "${dict['limit_bam_sort_ram']}"
        '--outFileNamePrefix' "${dict['output_dir']}/"
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--quantMode' 'TranscriptomeSAM'
        '--readFilesIn' \
            "${dict['tmp_fastq_r1_file']}" \
            "${dict['tmp_fastq_r2_file']}"
        '--runMode' 'alignReads'
        '--runRNGseed' '0'
        '--runThreadN' "${dict['threads']}"
        '--twopassMode' 'Basic'
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['star']}" "${align_args[@]}"
    koopa_rm \
        "${dict['output_dir']}/_STAR"* \
        "${dict['tmp_fastq_r1_file']}" \
        "${dict['tmp_fastq_r2_file']}"
    if [[ -n "${dict['aws_s3_uri']}" ]]
    then
        app['aws']="$(koopa_locate_aws --allow-system)"
        koopa_assert_is_executable "${app['aws']}"
        koopa_alert "Syncing '${dict['output_dir']}' \
to '${dict['aws_s3_uri']}'."
        "${app['aws']}" s3 sync \
            --profile "${dict['aws_profile']}" \
            "${dict['output_dir']}/" \
            "${dict['aws_s3_uri']}/"
        koopa_rm "${dict['output_dir']}"
        koopa_mkdir "${dict['output_dir']}"
    fi
    return 0
}
