#!/usr/bin/env bash

# FIXME Rename this to align.
# FIXME This needs to call align per sample.
# FIXME Need to split out the indexer to separate function.

koopa_bowtie2() { # {{{1
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
    # Index {{{2
    # --------------------------------------------------------------------------
    koopa_bowtie2_index \
        --fasta-file="${dict[fasta_file]}" \
        --output-dir="${dict[index_dir]}"
    koopa_assert_is_dir "${dict[index_dir]}"
    # Alignment {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and align.
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

# Individual runners ===========================================================
# FIXME Need to locate bowtie2 directly here, rather than activating conda.
koopa_bowtie2_align() { # {{{1
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

koopa_bowtie2_index() { # {{{1
    # """
    # Generate bowtie2 index.
    # @note Updated 2021-09-21.
    # """
    local app dict index_args
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'bowtie2-build'
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
            '--fasta-file='*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict[fasta_file]="${2:?}"
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
    koopa_assert_is_file "${dict[fasta_file]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note \
            "bowtie2 genome index exists at '${dict[output_dir]}'." \
            "Skipping on-the-fly indexing of '${dict[fasta_file]}'."
        return 0
    fi
    koopa_h2 "Generating bowtie2 index at '${dict[output_dir]}'."
    koopa_mkdir "${dict[output_dir]}"
    # This step adds 'bowtie2.*' prefix to the files created in the output.
    dict[index_base]="${dict[output_dir]}/bowtie2"
    dict[log_file]="${dict[output_dir]}/index.log"
    index_args=(
        "--threads=${dict[threads]}"
        '--verbose'
        "${dict[fasta_file]}"
        "${dict[index_base]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    # FIXME Need to locate this directly.
    bowtie2-build "${index_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}
