#!/usr/bin/env bash

koopa_star_align_paired_end() { # {{{1
    # """
    # Run STAR aligner on multiple paired-end FASTQs in a directory.
    # @note Updated 2022-03-23.
    # """
    local dict fastq_r1_files fastq_r1_file fastq_r2_file
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_r1_tail]='' # '_R1_001.fastq.gz'
        [fastq_r2_tail]='' # '_R2_001.fastq.gz'
        [index_dir]=''
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
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-tail' "${dict[fastq_r1_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running STAR aligner (paired-end mode).'
    koopa_dl \
        'FASTQ R1 tail' "${dict[fastq_r1_tail]}" \
        'FASTQ R2 tail' "${dict[fastq_r2_tail]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'Index dir' "${dict[index_dir]}" \
        'Mode' 'paired-end' \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_r1_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_r1_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        fastq_r2_file="${fastq_r1_file/\
${dict[fastq_r1_tail]}/${dict[fastq_r2_tail]}}"
        koopa_star_align_paired_end_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict[fastq_r1_tail]}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict[fastq_r2_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'STAR alignment was successful.'
    return 0
}

koopa_star_align_paired_end_per_sample() { # {{{1
    # """
    # Run STAR aligner on a paired-end sample.
    # @note Updated 2022-03-23.
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
    # """
    local align_args app dict
    declare -A app=(
        [app]="$(koopa_locate_star)"
    )
    declare -A dict=(
        [fastq_r1_file]=''
        [fastq_r1_tail]='' # '_R1_001.fastq.gz'
        [fastq_r2_file]=''
        [fastq_r2_tail]='' # '_R2_001.fastq.gz'
        [index_dir]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
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
        koopa_stop "STAR 'alignReads' mode requires ${dict[mem_gb_cutoff]} GB \
of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    koopa_assert_is_file "${dict[fastq_r1_file]}" "${dict[fastq_r2_file]}"
    dict[fastq_r1_bn]="$(koopa_basename "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[fastq_r1_tail]}/}"
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
        '--runMode' 'alignReads'
        '--genomeDir' "${dict[index_dir]}"
        '--outFileNamePrefix' "${dict[output_dir]}/"
        '--outSAMtype' 'BAM' 'SortedByCoordinate' # and/or 'Unsorted'
        '--readFilesIn' "${dict[fastq_r1_file]}" "${dict[fastq_r2_file]}"
        '--runThreadN' "${dict[threads]}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app[star]}" "${align_args[@]}"
    return 0
}

koopa_star_align_single_end() { # {{{1
    # """
    # Run STAR aligner on multiple single-end FASTQs in a directory.
    # @note Updated 2022-03-23.
    # """
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_tail]='' # '.fastq.gz'
        [index_dir]=''
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
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
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
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running STAR aligner (single-end mode).'
    koopa_dl \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ tail' "${dict[fastq_tail]}" \
        'Index dir' "${dict[index_dir]}" \
        'Mode' 'single-end' \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_file in "${fastq_files[@]}"
    do
        koopa_star_align_single_end_per_sample \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict[fastq_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'STAR alignment was successful.'
    return 0
}

koopa_star_align_single_end_per_sample() { # {{{1
    # """
    # Run STAR aligner on a single-end sample.
    # @note Updated 2022-03-23.
    # """
    local align_args app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [star]="$(koopa_locate_star)"
    )
    declare -A dict=(
        [fastq_file]=''
        [fastq_tail]='' # '.fastq.gz'
        [index_dir]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
    )
    align_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-file='*)
                dict[fastq_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict[fastq_file]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
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
        '--fastq-file' "${dict[fastq_file]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "salmon quant requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    koopa_assert_is_file "${dict[fastq_file]}"
    dict[fastq_bn]="$(koopa_basename "${dict[fastq_file]}")"
    dict[fastq_bn]="${dict[fastq_bn]/${dict[tail]}/}"
    dict[id]="${dict[fastq_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' in '${dict[output_dir]}'."
    align_args+=(
        '--runMode' 'alignReads'
        '--genomeDir' "${dict[index_dir]}"
        '--outFileNamePrefix' "${dict[output_dir]}/"
        '--outSAMtype' 'BAM' 'SortedByCoordinate' # and/or 'Unsorted'
        '--readFilesIn' "${dict[fastq_file]}"
        '--runThreadN' "${dict[threads]}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app[star]}" "${align_args[@]}"
    return 0
}

koopa_star_index() { # {{{1
    # """
    # Create a genome index for STAR aligner.
    # @note Updated 2022-03-23.
    #
    # Doesn't currently support compressed files as input.
    #
    # Try using 'r5a.2xlarge' on AWS EC2.
    #
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     ngsalign/star.py
    # - https://github.com/nf-core/rnaseq/blob/master/modules/local/
    #     star_genomegenerate.nf
    # """
    local app dict index_args
    declare -A app=(
        [star]="$(koopa_locate_star)"
    )
    declare -A dict=(
        [genome_fasta_file]=''
        [gtf_file]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=62
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
        [tmp_dir]="$(koopa_tmp_dir)"
    )
    dict[tmp_genome_fasta_file]="${dict[tmp_dir]}/genome.fa"
    dict[tmp_gtf_file]="${dict[tmp_dir]}/annotation.gtf"
    index_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--genome-fasta-file='*)
                dict[genome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict[genome_fasta_file]="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict[gtf_file]="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict[gtf_file]="${2:?}"
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
        '--genome-fasta-file' "${dict[genome_fasta_file]}" \
        '--gtf-file' "${dict[gtf_file]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "STAR 'genomeGenerate' mode requires ${dict[mem_gb_cutoff]} \
GB of RAM."
    fi
    koopa_assert_is_file \
        "${dict[genome_fasta_file]}" \
        "${dict[gtf_file]}"
    koopa_alert "Generating STAR index at '${dict[output_dir]}'."
    koopa_alert "Decompressing FASTA and GTF files in '${dict[tmp_dir]}'."
    koopa_decompress \
        "${dict[genome_fasta_file]}" \
        "${dict[tmp_genome_fasta_file]}"
    koopa_decompress \
        "${dict[gtf_file]}" \
        "${dict[tmp_gtf_file]}"
    index_args+=(
        '--runMode' 'genomeGenerate'
        '--genomeDir' "${dict[output_dir]}/"
        '--genomeFastaFiles' "${dict[tmp_genome_fasta_file]}"
        '--runThreadN' "${dict[threads]}"
        '--sjdbGTFfile' "${dict[tmp_gtf_file]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    (
        koopa_cd "${dict[tmp_dir]}"
        "${app[star]}" "${index_args[@]}"
    )
    koopa_rm "${dict[tmp_dir]}"
    koopa_alert_success "STAR index created at '${dict[output_dir]}'."
    return 0
}
