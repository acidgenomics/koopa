#!/usr/bin/env bash

# FIXME Need to locate bowtie2 directly here, rather than activating conda.

koopa_bowtie2_align() {
    # """
    # Run bowtie2 alignment on multiple paired-end FASTQ files.
    # @note Updated 2021-09-21.
    # """
    local app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'bowtie2'
    declare -A app=(
        [tee]="$(koopa_locate_tee)"
    )
    declare -A dict=(
        [threads]="$(koopa_cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            # FIXME Indicate that this is a file more clearly.
            '--fastq-r1='*)
                dict[fastq_r1]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1')
                dict[fastq_r1]="${2:?}"
                shift 2
                ;;
            '--fastq-r2='*)
                dict[fastq_r2]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2')
                dict[fastq_r2]="${2:?}"
                shift 2
                ;;
            '--index-base='*)
                dict[index_base]="${1#*=}"
                shift 1
                ;;
            '--index-base')
                dict[index_base]="${2:?}"
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
            # FIXME Work on including 'fastq' in variable here.
            '--r1-tail='*)
                dict[r1_tail]="${1#*=}"
                shift 1
                ;;
            '--r1-tail')
                dict[r1_tail]="${2:?}"
                shift 2
                ;;
            '--r2-tail='*)
                dict[r2_tail]="${1#*=}"
                shift 1
                ;;
            '--r2-tail')
                dict[r2_tail]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_file "${dict[fastq_r1]}" "${dict[fastq_r2]}"
    dict[fastq_r1_bn]="$(koopa_basename "${dict[fastq_r1]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[r1_tail]}/}"
    dict[fastq_r2_bn]="$(koopa_basename "${dict[fastq_r2]}")"
    dict[fastq_r2_bn]="${dict[fastq_r2_bn]/${dict[r2_tail]}/}"
    koopa_assert_are_identical "${dict[fastq_r1_bn]}" "${dict[fastq_r2_bn]}"
    id="${dict[fastq_r1_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    koopa_h2 "Aligning '${dict[id]}' into '${dict[output_dir]}'."
    koopa_mkdir "${dict[output_dir]}"
    sam_file="${dict[output_dir]}/${dict[id]}.sam"
    log_file="${dict[output_dir]}/align.log"
    align_args=(
        '--local'
        '--sensitive-local'
        '--rg-id' "$id"
        '--rg' 'PL:illumina'
        '--rg' "PU:${id}"
        '--rg' "SM:${id}"
        '--threads' "${dict[threads]}"
        '-1' "$fastq_r1"
        '-2' "$fastq_r2"
        '-S' "$sam_file"
        '-X' 2000
        '-q'
        '-x' "${dict[index_base]}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    bowtie2 "${align_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}
