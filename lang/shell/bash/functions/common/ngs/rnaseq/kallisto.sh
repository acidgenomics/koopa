#!/usr/bin/env bash

# FIXME Need to harden these functions, matching our conventions in salmon.
# FIXME Rename '--gff' to '--gtf'.
# FIXME Ensure naming conventions here match salmon runners.
# FIXME Need to add improved input checks, similar to salmon functions.
# FIXME Rename 'fasta-file' to 'transcriptome-fasta-file'.
# FIXME Rework using 'koopa::locate_kallisto'.
# FIXME Need to improve consistency of 'fastq' prefix in variable names.
# FIXME Check for unnecessary '--print' calls in 'koopa::find' across package.

# Main functions ===============================================================
koopa::run_kallisto_paired_end() { # {{{1
    # """
    # Run kallisto on multiple samples.
    # @note Updated 2022-02-11.
    #
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
    # """
    local dict
    local fastq_r1_files fastq_r1 fastq_r2
    koopa::assert_has_args "$#"
    declare -A dict=(
        [bootstraps]=30
        [fastq_dir]='fastq'
        [index_dir]=''
        [lib_type]='A'
        [output_dir]='kallisto'
        [r1_tail]='_R1_001.fastq.gz'
        [r2_tail]='_R2_001.fastq.gz'
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bootstraps='*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            '--bootstraps')
                dict[bootstraps]="${2:?}"
                shift 2
                ;;
            '--chromosomes-file='*)
                dict[chromosomes_file]="${1#*=}"
                shift 1
                ;;
            '--chromosomes-file')
                dict[chromosomes_file]="${2:?}"
                shift 2
                ;;
            '--fasta-file='*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict[fasta_file]="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--gff-file='*)
                dict[gff_file]="${1#*=}"
                shift 1
                ;;
            '--gff-file')
                dict[gff_file]="${2:?}"
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
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
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
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::h1 'Running kallisto (paired-end mode).'
    # FIXME Can we generate this file dynamically from the genome input?
    dict[chromosomes_file]="$(koopa::realpath "${dict[chromosomes_file]}")"
    dict[fasta_file]="$(koopa::realpath "${dict[fasta_file]}")"
    dict[fastq_dir]="$(koopa::realpath "${dict[fastq_dir]}")"
    dict[gff_file]="$(koopa::realpath "${dict[gff_file]}")"
    dict[output_dir]="$(koopa::init_dir "${dict[output_dir]}")"
    dict[samples_dir]="${dict[output_dir]}/samples"
    if [[ -z "${dict[index_dir]}" ]]
    then
        dict[index_dir]="${dict[output_dir]}/index"
    fi
    koopa::dl \
        'Bootstraps' "${dict[bootstraps]}" \
        'Chromosomes file' "${dict[chromosomes_file]}" \
        'FASTA file' "${dict[fasta_file]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'GFF file' "${dict[gff_file]}" \
        'Index dir' "${dict[index_dir]}" \
        'Output dir' "${dict[output_dir]}" \
        'R1 tail' "${dict[r1_tail]}" \
        'R2 tail' "${dict[r2_tail]}"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the R1 FASTQ files.
    readarray -t fastq_r1_files <<< "$( \
        koopa::find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[r1_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type 'f' \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_r1_files[@]}" -eq 0 ]]
    then
        koopa::stop "No FASTQ files in '${dict[fastq_dir]}' ending \
with '${dict[r1_tail]}'."
    fi
    koopa::alert_info "$(koopa::ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    # Index {{{2
    # --------------------------------------------------------------------------
    if [[ ! -d "${dict[index_dir]}" ]]
    then
        koopa::kallisto_index \
            --fasta-file="${dict[fasta_file]}" \
            --output-dir="${dict[index_dir]}"
    fi
    koopa::assert_is_dir "${dict[index_dir]}"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify.
    for fastq_r1 in "${fastq_r1_files[@]}"
    do
        fastq_r2="${fastq_r1/${dict[r1_tail]}/${dict[r2_tail]}}"
        koopa::kallisto_quant_paired_end \
            --bootstraps="${dict[bootstraps]}" \
            --chromosomes-file="${dict[chromosomes_file]}" \
            --fastq-r1="$fastq_r1" \
            --fastq-r2="$fastq_r2" \
            --gff-file="${dict[gff_file]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}" \
            --r1-tail="${dict[r1_tail]}" \
            --r2-tail="${dict[r2_tail]}"
    done
    koopa::alert_success "kallisto run at '${dict[output_dir]}' \
completed successfully."
    return 0
}

koopa::run_kallisto_single_end() { # {{{1
    # """
    # Run kallisto on multiple single-end FASTQ files.
    # @note Updated 2022-02-11.
    # """
    local dict fastq_files fastq
    koopa::assert_has_args "$#"
    declare -A dict=(
        [bootstraps]=30
        [fastq_dir]='fastq'
        [fragment_length]=200
        [index_dir]=''
        [output_dir]='kallisto'
        [sd]=30
        # FIXME Rename this variable to include 'fastq'.
        [tail]='.fastq.gz'
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bootstraps='*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            '--bootstraps')
                dict[bootstraps]="${2:?}"
                shift 2
                ;;
            '--chromosomes-file='*)
                dict[chromosomes_file]="${1#*=}"
                shift 1
                ;;
            '--chromosomes-file')
                dict[chromosomes_file]="${2:?}"
                shift 2
                ;;
            '--fasta-file='*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict[fasta_file]="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fragment-length='*)
                dict[fragment_length]="${1#*=}"
                shift 1
                ;;
            '--fragment-length')
                dict[fragment_length]="${2:?}"
                shift 2
                ;;
            '--gff-file='*)
                dict[gff_file]="${1#*=}"
                shift 1
                ;;
            '--gff-file')
                dict[gff_file]="${2:?}"
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
            '--sd='*)
                dict[sd]="${1#*=}"
                shift 1
                ;;
            '--sd')
                dict[sd]="${2:?}"
                shift 2
                ;;
            '--tail='*)
                dict[tail]="${1#*=}"
                shift 1
                ;;
            '--tail')
                dict[tail]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::h1 'Running kallisto (single-end mode).'
    dict[chromosomes_file]="$(koopa::realpath "${dict[chromosomes_file]}")"
    dict[fasta_file]="$(koopa::realpath "${dict[fasta_file]}")"
    dict[fastq_dir]="$(koopa::realpath "${dict[fastq_dir]}")"
    dict[gff_file]="$(koopa::realpath "${dict[gff_file]}")"
    dict[output_dir]="$(koopa::init_dir "${dict[output_dir]}")"
    dict[samples_dir]="${dict[output_dir]}/samples"
    if [[ -z "${dict[index_dir]}" ]]
    then
        dict[index_dir]="${dict[output_dir]}/index"
    fi
    koopa::dl \
        'Bootstraps' "${dict[bootstraps]}" \
        'Chromosomes file' "${dict[chromosomes_file]}" \
        'FASTA file' "${dict[fasta_file]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'GFF file' "${dict[gff_file]}" \
        'Index dir' "${dict[index_dir]}" \
        'Output dir' "${dict[output_dir]}" \
        'Tail' "${dict[tail]}"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the FASTQ files.
    # FIXME Need to confirm that this works.
    readarray -t fastq_files <<< "$( \
        koopa::find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa::stop "No FASTQ files in '${dict[fastq_dir]}' ending \
with '${dict[tail]}'."
    fi
    koopa::alert_info "$(koopa::ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='sampes' \
        --suffix=' detected.' \
    )"
    # Index {{{2
    # --------------------------------------------------------------------------
    if [[ ! -d "${dict[index_dir]}" ]]
    then
        koopa::kallisto_index \
            --fasta-file="${dict[fasta_file]}" \
            --output-dir="${dict[index_dir]}"
    fi
    koopa::assert_is_dir "${dict[index_dir]}"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify with salmon.
    for fastq in "${fastq_files[@]}"
    do
        koopa::kallisto_quant_single_end \
            --bootstraps="${dict[bootstraps]}" \
            --chromosomes-file="${dict[chromosomes_file]}" \
            --fastq="$fastq" \
            --fragment-length="${dict[fragment_length]}" \
            --gff-file="${dict[gff_file]}" \
            --index-dir="${dict[index_dir]}" \
            --output-dir="${dict[samples_dir]}" \
            --sd="${dict[sd]}" \
            --tail="${dict[tail]}"
    done
    koopa::alert_success "kallisto run at '${dict[output_dir]}' \
completed successfully."
    return 0
}

# Individual runners ===========================================================
koopa::kallisto_index() { # {{{1
    # """
    # Generate kallisto index.
    # @note Updated 2021-09-23.
    # """
    local app dict index_args
    koopa::assert_has_args "$#"
    declare -A app=(
        [kallisto]="$(koopa::locate_kallisto)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [output_dir]='kallisto/index'
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
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_file "${dict[fasta_file]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa::alert_note \
            "Kallisto transcriptome index exists at '${dict[output_dir]}'." \
            "Skipping on-the-fly indexing of '${dict[fasta_file]}'."
        return 0
    fi
    koopa::h2 "Generating kallisto index at '${dict[output_dir]}'."
    koopa::mkdir "${dict[output_dir]}"
    dict[index_file]="${dict[output_dir]}/kallisto.idx"
    dict[log_file]="${dict[output_dir]}/index.log"
    index_args=(
        "--index=${dict[index_file]}"
        '--kmer-size=31'
        '--make-unique'
        "${dict[fasta_file]}"
    )
    koopa::dl 'Index args' "${index_args[*]}"
    "${app[kallisto]}" index "${index_args[@]}" \
        2>&1 | "${app[tee]}" "${dict[log_file]}"
    koopa::alert_success "Indexing of '${dict[fasta_file]}' at \
'${dict[index_file]}' was successful."
    return 0
}

koopa::kallisto_quant_paired_end() { # {{{1
    # """
    # Run kallisto quant (per paired-end sample).
    # @note Updated 2022-02-11.
    #
    # Important options:
    # * --bias: Learns parameters for a model of sequences specific bias and
    #   corrects the abundances accordlingly.
    # * --fr-stranded: Run kallisto in strand specific mode, only fragments
    #   where the first read in the pair pseudoaligns to the forward strand of a
    #   transcript are processed. If a fragment pseudoaligns to multiple
    #   transcripts, only the transcripts that are consistent with the first
    #   read are kept.
    # * --rf-stranded: Same as '--fr-stranded', but the first read maps to the
    #   reverse strand of a transcript.

    # @seealso
    # - https://pachterlab.github.io/kallisto/manual
    # - https://littlebitofdata.com/en/2017/08/strandness_in_rnaseq/
    # - https://salmon.readthedocs.io/en/latest/library_type.html
    # """
    local app dict quant_args
    koopa::assert_has_args "$#"
    declare -A app=(
        [kallisto]="$(koopa::locate_kallisto)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [threads]="$(koopa::cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bootstraps='*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            '--bootstraps')
                dict[bootstraps]="${2:?}"
                shift 2
                ;;
            '--chromosomes-file='*)
                dict[chromosomes_file]="${1#*=}"
                shift 1
                ;;
            '--chromosomes-file')
                dict[chromosomes_file]="${2:?}"
                shift 2
                ;;
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
            '--gff-file='*)
                dict[gff_file]="${1#*=}"
                shift 1
                ;;
            '--gff-file')
                dict[gff_file]="${2:?}"
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
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
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
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    dict[index_file]="${dict[index_dir]}/kallisto.idx"
    koopa::assert_is_file \
        "${dict[fastq_r1]}" \
        "${dict[fastq_r2]}" \
        "${dict[gff_file]}" \
        "${dict[index_file]}"
    dict[fastq_r1_bn]="$(koopa::basename "${dict[fastq_r1]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[r1_tail]}/}"
    dict[fastq_r2_bn]="$(koopa::basename "${dict[fastq_r2]}")"
    dict[fastq_r2_bn]="${dict[fastq_r2_bn]/${dict[r2_tail]}/}"
    koopa::assert_are_identical "${dict[fastq_r1_bn]}" "${dict[fastq_r2_bn]}"
    dict[id]="${dict[fastq_r1_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa::alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    koopa::h2 "Quantifying '${dict[id]}' into '${dict[output_dir]}'."
    koopa::mkdir "${dict[output_dir]}"
    dict[log_file]="${dict[output_dir]}/quant.log"
    quant_args=(
        '--bias'
        "--bootstrap-samples=${dict[bootstraps]}"
        "--chromosomes=${dict[chromosomes_file]}"
        '--genomebam'
        "--gtf=${dict[gff_file]}"
        "--index=${dict[index_file]}"
        "--output-dir=${dict[output_dir]}"
        '--pseudobam'
        "--threads=${dict[threads]}"
        '--verbose'
    )
    # Run kallisto in stranded mode, depending on the library type. Using salmon
    # library type codes here, for consistency. Doesn't currently support an
    # auto detection mode, like salmon. Most current libraries are 'ISR' /
    # '--rf-stranded', if unsure.
    case "${dict[lib_type]}" in
        'A')
            ;;
        'ISF')
            quant_args+=('--fr-stranded')
            ;;
        'ISR')
            quant_args+=('--rf-stranded')
            ;;
        *)
            koopa::invalid_arg "${dict[lib_type]}"
            ;;
    esac
    quant_args+=("${dict[fastq_r1]}" "${dict[fastq_r2]}")
    koopa::dl 'Quant args' "${quant_args[*]}"
    "${app[kallisto]}" quant "${quant_args[@]}" \
        2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

koopa::kallisto_quant_single_end() { # {{{1
    # """
    # Run kallisto quant (per single-end sample).
    # @note Updated 2022-02-11.
    #
    # Must supply the length and standard deviation of the fragment length
    # (not the read length).
    #
    # Fragment length refers to the length of the fragments loaded onto the
    # sequencer. If this is your own dataset, then either you or whoever did the
    # sequencing should know this (it can be estimated from a bioanalyzer plot).
    # If this is a public dataset, then hopefully the value is written down
    # somewhere.
    #
    # @section Potentially useful arguments to support:
    #
    # * --genomebam: Project pseudoalignments to genome sorted BAM file
    # * --pseudobam: Save pseudoalignments to transcriptome to BAM file
    #
    # @seealso
    # - https://www.biostars.org/p/252823/
    # """
    local app dict quant_args
    declare -A app=(
        [kallisto]="$(koopa::locate_kallisto)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bootstraps='*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            '--bootstraps')
                dict[bootstraps]="${2:?}"
                shift 2
                ;;
            '--chromosomes-file='*)
                dict[chromosomes_file]="${1#*=}"
                shift 1
                ;;
            '--chromosomes-file')
                dict[chromosomes_file]="${2:?}"
                shift 2
                ;;
            # FIXME Rename this to 'fastq-file'.
            '--fastq='*)
                dict[fastq]="${1#*=}"
                shift 1
                ;;
            '--fastq')
                dict[fastq]="${2:?}"
                shift 2
                ;;
            '--fragment-length='*)
                dict[fragment_length]="${1#*=}"
                shift 1
                ;;
            '--fragment-length')
                dict[fragment_length]="${2:?}"
                shift 2
                ;;
            '--gff-file='*)
                dict[gff_file]="${1#*=}"
                shift 1
                ;;
            '--gff-file')
                dict[gff_file]="${2:?}"
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
            '--sd='*)
                dict[sd]="${1#*=}"
                shift 1
                ;;
            '--sd')
                dict[sd]="${2:?}"
                shift 2
                ;;
            '--tail='*)
                dict[tail]="${1#*=}"
                shift 1
                ;;
            '--tail')
                dict[tail]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    dict[index_file]="${dict[index_dir]}/kallisto.idx"
    koopa::assert_is_file \
        "${dict[fastq]}" \
        "${dict[index_file]}"
    dict[fastq_bn]="$(koopa::basename "${dict[fastq]}")"
    dict[fastq_bn]="${dict[fastq_bn]/${dict[tail]}/}"
    dict[id]="${dict[fastq_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa::alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    koopa::h2 "Quantifying '${dict[id]}' into '${dict[output_dir]}'."
    koopa::mkdir "${dict[output_dir]}"
    dict[log_file]="${dict[output_dir]}/quant.log"
    quant_args=(
        "--bootstrap-samples=${dict[bootstraps]}"
        "--chromosomes=${dict[chromosomes_file]}"
        "--fragment-length=${dict[fragment_length]}"
        "--gtf=${dict[gff_file]}"
        "--index=${dict[index_file]}"
        "--output-dir=${dict[output_dir]}"
        "--sd=${dict[sd]}"
        '--single'
        "--threads=${dict[threads]}"
        '--verbose'
    )
    quant_args+=("$fastq")
    koopa::dl 'Quant args' "${quant_args[*]}"
    "${app[kallisto]}" quant "${quant_args[@]}" \
        2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

