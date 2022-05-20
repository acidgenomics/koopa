#!/usr/bin/env bash

koopa_star_align_paired_end_per_sample() {
    # """
    # Run STAR aligner on a paired-end sample.
    # @note Updated 2022-03-25.
    #
    # @seealso
    # - https://hbctraining.github.io/Intro-to-rnaseq-hpc-O2/lessons/
    #     03_alignment.html
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/ngsalign/
    #     star.py
    # - https://github.com/nf-core/rnaseq/blob/master/modules/local/
    #     star_align.nf
    # - https://github.com/nf-core/rnaseq/blob/master/subworkflows/local/
    #     align_star.nf
    # - https://www.biostars.org/p/243683/
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
    local align_args app dict
    declare -A app=(
        [star]="$(koopa_locate_star)"
    )
    declare -A dict=(
        # e.g. 'sample1_R1_001.fastq.gz'.
        [fastq_r1_file]=''
        # e.g. '_R1_001.fastq.gz'.
        [fastq_r1_tail]=''
        # e.g. 'sample1_R2_001.fastq.gz'.
        [fastq_r2_file]=''
        # e.g. '_R2_001.fastq.gz'.
        [fastq_r2_tail]=''
        # e.g. 'star-index'.
        [index_dir]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        # e.g. 'star'.
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
    )
    align_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-r1-file='*)
                dict[fastq_r1_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict[fastq_r1_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict[fastq_r2_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict[fastq_r2_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict[fastq_r1_file]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-file' "${dict[fastq_r2_file]}" \
        '--fastq-r2-tail' "${dict[fastq_r2_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "STAR 'alignReads' mode requires ${dict[mem_gb_cutoff]} \
GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    koopa_assert_is_file "${dict[fastq_r1_file]}" "${dict[fastq_r2_file]}"
    dict[fastq_r1_file]="$(koopa_realpath "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="$(koopa_basename "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[fastq_r1_tail]}/}"
    dict[fastq_r2_file]="$(koopa_realpath "${dict[fastq_r2_file]}")"
    dict[fastq_r2_bn]="$(koopa_basename "${dict[fastq_r2_file]}")"
    dict[fastq_r2_bn]="${dict[fastq_r2_bn]/${dict[fastq_r2_tail]}/}"
    koopa_assert_are_identical "${dict[fastq_r1_bn]}" "${dict[fastq_r2_bn]}"
    dict[id]="${dict[fastq_r1_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' in '${dict[output_dir]}'."
    align_args+=(
        '--genomeDir' "${dict[index_dir]}"
        '--outFileNamePrefix' "${dict[output_dir]}/"
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--runMode' 'alignReads'
        '--runThreadN' "${dict[threads]}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app[star]}" "${align_args[@]}" \
        --readFilesIn \
            <(koopa_decompress --stdout "${dict[fastq_r1_file]}") \
            <(koopa_decompress --stdout "${dict[fastq_r2_file]}")
    return 0
}
