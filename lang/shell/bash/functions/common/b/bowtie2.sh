#!/usr/bin/env bash

# FIXME Rename this to align.
# FIXME This needs to call align per sample.
# FIXME Need to split out the indexer to separate function.

koopa_bowtie2() {
    # """
    # Run bowtie2 on a directory containing multiple FASTQ files.
    # @note Updated 2022-03-22.
    # """
    local dict fastq_r1_file fastq_r1_files
    declare -A dict=(
        [fastq_dir]=''
        [fastq_r1_tail]='' # '_R1_001.fastq.gz'
        [fastq_r2_tail]='' # '_R2_001.fastq.gz'
        [genome_fasta_file]=''
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
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
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--genome-fasta-file='*)
                dict[genome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict[genome_fasta_file]="${2:?}"
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
    koopa_h1 'Running bowtie2.'
    koopa_assert_is_file "${dict[fasta_file]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    dict[index_dir]="${dict[output_dir]}/index"
    dict[index_base]="${dict[index_dir]}/bowtie2"
    dict[samples_dir]="${dict[output_dir]}/samples"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[r1_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_r1_files[@]}" -eq 0 ]]
    then
        koopa_stop "No FASTQ files in '${dict[fastq_dir]}' ending \
with '${dict[r1_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    koopa_bowtie2_index \
        --fasta-file="${dict[fasta_file]}" \
        --output-dir="${dict[index_dir]}"
    koopa_assert_is_dir "${dict[index_dir]}"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local fastq_r2_file
        fastq_r2_file="${fastq_r1_file/${dict[r1_tail]}/${dict[r2_tail]}}"
        koopa_bowtie2_align \
            --fastq-r1="$fastq_r1_file" \
            --fastq-r2="$fastq_r2_file" \
            --index-base="${dict[index_base]}" \
            --output-dir="${dict[samples_dir]}" \
            --r1-tail="${dict[r1_tail]}" \
            --r2-tail="${dict[r2_tail]}"
    done
    # NOTE Need a step to convert SAM to BAM here.
    koopa_alert_success 'bowtie2 alignment completed successfully.'
    return 0
}
