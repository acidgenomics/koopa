#!/usr/bin/env bash

# FIXME Add step to generate BAM and CRAM files from SAM.

koopa:::salmon_index() { # {{{1
    # """
    # Generate salmon index.
    # @note Updated 2021-08-16.
    # """
    local app dict
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'salmon'
    declare -A app=(
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [fasta_file]=''
        [output_dir]=''
        [threads]="$(koopa::cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            --fasta-file=*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_file "${dict[fasta_file]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa::alert_note \
            "Salmon transcriptome index exists at '${dict[output_dir]}'." \
            "Skipping on-the-fly indexing of '${dict[fasta_file]}'."
        return 0
    fi
    koopa::h2 "Generating salmon index at '${dict[output_dir]}'."
    koopa::mkdir "${dict[output_dir]}"
    dict[log_file]="${dict[output_dir]}/index.log"
    index_args=(
        "--index=${dict[output_dir]}"
        '--kmerLen=31'
        "--threads=${dict[threads]}"
        "--transcripts=${dict[fasta_file]}"
    )
    koopa::dl 'Index args' "${index_args[*]}"
    salmon index "${index_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

koopa:::salmon_quant_paired_end() { # {{{1
    # """
    # Run salmon quant (per paired-end sample).
    # @note Updated 2021-08-16.
    #
    # Quartz is currently using only '--validateMappings' and '--gcBias' flags.
    #
    # Important options:
    # * --libType='A': Enable ability to automatically infer (i.e. guess) the
    #   library type based on how the first few thousand reads map to the
    #   transcriptome. Note that most commercial vendors use Illumina TruSeq,
    #   which is dUTP, corresponding to 'ISR' for salmon.
    # * --validateMappings: Enables selective alignment of the sequencing reads
    #   when mapping them to the transcriptome. This can improve both the
    #   sensitivity and specificity of mapping and, as a result, can improve
    #   quantification accuracy.
    # * --numBootstraps: Compute bootstrapped abundance estimates. This is done
    #   by resampling (with replacement) from the counts assigned to the
    #   fragment equivalence classes, and then re-running the optimization
    #   procedure.
    # * --seqBias: Enable salmon to learn and correct for sequence-specific
    #   biases in the input data. Specifically, this model will attempt to
    #   correct for random hexamer priming bias, which results in the
    #   preferential sequencing of fragments starting with certain nucleotide
    #   motifs.
    # * --gcBias: Learn and correct for fragment-level GC biases in the input
    #   data. Specifically, this model will attempt to correct for biases in how
    #   likely a sequence is to be observed based on its internal GC content.
    # * --posBias: Experimental. Enable modeling of a position-specific fragment
    #   start distribution. This is meant to model non-uniform coverage biases
    #   that are sometimes present in RNA-seq data (e.g. 5' or 3' positional
    #   bias).
    #
    # Consider use of '--numGibbsSamples' instead of '--numBootstraps'.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       rnaseq/salmon.py
    # - How to output pseudobams:
    #   https://github.com/COMBINE-lab/salmon/issues/38
    # """
    local app dict quant_args
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'salmon'
    declare -A app=(
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [sam_file]='output.sam'
        [threads]="$(koopa::cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            --bootstraps=*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            --fastq-r1=*)
                dict[fastq_r1]="${1#*=}"
                shift 1
                ;;
            --fastq-r2=*)
                dict[fastq_r2]="${1#*=}"
                shift 1
                ;;
            --gff-file=*)
                dict[gff_file]="${1#*=}"
                shift 1
                ;;
            --index-dir=*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            --lib-type=*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            --r1-tail=*)
                dict[r1_tail]="${1#*=}"
                shift 1
                ;;
            --r2-tail=*)
                dict[r2_tail]="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_file "${dict[fastq_r1]}" "${dict[fastq_r2]}"
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
        '--gcBias'
        "--geneMap=${dict[gff_file]}"
        "--index=${dict[index_dir]}"
        "--libType=${dict[lib_type]}"
        "--mates1=${dict[fastq_r1]}"
        "--mates2=${dict[fastq_r2]}"
        "--numBootstraps=${dict[bootstraps]}"
        '--no-version-check'
        "--output=${dict[output_dir]}"
        '--seqBias'
        "--threads=${dict[threads]}"
        "--writeMappings=${dict[sam_file]}"
    )
    koopa::dl 'Quant args' "${quant_args[*]}"
    salmon quant "${quant_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

koopa:::salmon_quant_single_end() { # {{{1
    # """
    # Run salmon quant (per single-end sample).
    # @note Updated 2021-08-16.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    # """
    local app dict quant_args
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'salmon'
    declare -A app=(
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [sam_file]='output.sam'
        [threads]="$(koopa::cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            --bootstraps=*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            --fastq=*)
                dict[fastq]="${1#*=}"
                shift 1
                ;;
            --gff-file=*)
                dict[gff_file]="${1#*=}"
                shift 1
                ;;
            --index-dir=*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            --lib-type=*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            --tail=*)
                dict[tail]="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_file "${dict[fastq]}"
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
    # Don't set '--gcBias' here, considered beta for single-end reads.
    quant_args=(
        "--geneMap=${dict[gff_file]}"
        "--index=${dict[index_dir]}"
        "--libType=${dict[lib_type]}"
        "--numBootstraps=${dict[bootstraps]}"
        '--no-version-check'
        "--output=${dict[output_dir]}"
        '--seqBias'
        "--threads=${dict[threads]}"
        "--unmatedReads=${dict[fastq]}"
        "--writeMappings=${dict[sam_file]}"
    )
    koopa::dl 'Quant args' "${quant_args[*]}"
    salmon quant "${quant_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

koopa::run_salmon_paired_end() { # {{{1
    # """
    # Run salmon on multiple paired-end FASTQ files.
    # @note Updated 2021-08-16.
    #
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
    # Attempting to detect library type (strandedness) automatically by default.
    # """
    local app dict
    local fastq_r1_files fastq_r1 fastq_r2 str
    koopa::assert_has_args "$#"
    declare -A app=(
        [find]="$(koopa::locate_find)"
        [sort]="$(koopa::locate_sort)"
    )
    declare -A dict=(
        [bootstraps]=30
        [fastq_dir]='fastq'
        [lib_type]='A'
        [output_dir]='salmon'
        [r1_tail]='_R1_001.fastq.gz'
        [r2_tail]='_R2_001.fastq.gz'
    )
    while (("$#"))
    do
        case "$1" in
            --bootstraps=*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            --fasta-file=*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            --fastq-dir=*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            --gff-file=*)
                dict[gff_file]="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            --r1-tail=*)
                dict[r1_tail]="${1#*=}"
                shift 1
                ;;
            --r2-tail=*)
                dict[r2_tail]="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::h1 'Running salmon.'
    koopa::activate_conda_env 'salmon'
    dict[fasta_file]="$(koopa::realpath "${dict[fasta_file]}")"
    dict[fastq_dir]="$(koopa::realpath "${dict[fastq_dir]}")"
    dict[gff_file]="$(koopa::realpath "${dict[fasta_file]}")"
    # FIXME Rework this using 'init_dir' approach.
    koopa::mkdir "${dict[output_dir]}"
    dict[output_dir]="$(koopa::realpath "${dict[output_dir]}")"
    dict[index_dir]="${dict[output_dir]}/index"
    dict[samples_dir]="${dict[output_dir]}/samples"
    koopa::dl \
        'Bootstraps' "${dict[bootstraps]}" \
        'FASTA file' "${dict[fasta_file]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'GFF file' "${dict[gff_file]}" \
        'Output dir' "${dict[output_dir]}" \
        'R1 tail' "${dict[r1_tail]}" \
        'R2 tail' "${dict[r2_tail]}"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the R1 FASTQ files.
    # Pipe GNU find into array.
    readarray -t fastq_r1_files <<< "$( \
        "${app[find]}" "${dict[fastq_dir]}" \
            -maxdepth 1 \
            -mindepth 1 \
            -type 'f' \
            -name "*${dict[r1_tail]}" \
            -not -name '._*' \
            -print \
        | "${app[sort]}" \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_r1_files[@]}" -eq 0 ]]
    then
        koopa::stop "No FASTQ files in '${dict[fastq_dir]}' ending \
with '${dict[r1_tail]}'."
    fi
    str="$(koopa::ngettext "${#fastq_r1_files[@]}" 'sample' 'samples')"
    koopa::alert_info "${#fastq_r1_files[@]} ${str} detected."
    # Index {{{2
    # --------------------------------------------------------------------------
    koopa:::salmon_index \
        --fasta-file="${dict[fasta_file]}" \
        --output-dir="${dict[index_dir]}"
    koopa::assert_is_dir "${dict[index_dir]}"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify with salmon.
    for fastq_r1 in "${fastq_r1_files[@]}"
    do
        fastq_r2="${fastq_r1/${dict[r1_tail]}/${dict[r2_tail]}}"
        koopa:::salmon_quant_paired_end \
            --bootstraps="${dict[bootstraps]}" \
            --fastq-r1="$fastq_r1" \
            --fastq-r2="$fastq_r2" \
            --gff-file="${dict[gff_file]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[samples_dir]}" \
            --r1-tail="${dict[r1_tail]}" \
            --r2-tail="${dict[r2_tail]}"
    done
    # Convert SAM-to-BAM {{{2
    # --------------------------------------------------------------------------
    # FIXME Work on a SAM-to-BAM conversion step here.
    koopa::alert_success 'salmon run completed successfully.'
    return 0
}

koopa::run_salmon_single_end() { # {{{1
    # """
    # Run salmon on multiple single-end FASTQ files.
    # @note Updated 2021-08-16.
    #
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
    # Attempting to detect library type (strandedness) automatically by default.
    # """
    local app dict
    local fastq_files fastq str
    koopa::assert_has_args "$#"
    declare -A app=(
        [find]="$(koopa::locate_find)"
        [sort]="$(koopa::locate_sort)"
    )
    declare -A dict=(
        [bootstraps]=30
        [fastq_dir]='fastq'
        [lib_type]='A'
        [output_dir]='salmon'
        [tail]='.fastq.gz'
    )
    while (("$#"))
    do
        case "$1" in
            --bootstraps=*)
                bootstraps="${1#*=}"
                shift 1
                ;;
            --fasta-file=*)
                fasta_file="${1#*=}"
                shift 1
                ;;
            --fastq-dir=*)
                fastq_dir="${1#*=}"
                shift 1
                ;;
            --gff-file=*)
                gff_file="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                output_dir="${1#*=}"
                shift 1
                ;;
            --tail=*)
                tail="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::h1 'Running salmon.'
    koopa::activate_conda_env 'salmon'
    dict[fasta_file]="$(koopa::realpath "${dict[fasta_file]}")"
    dict[fastq_dir]="$(koopa::realpath "${dict[fastq_dir]}")"
    # FIXME Rework this using 'init_dir' approach.
    koopa::mkdir "${dict[output_dir]}"
    dict[output_dir]="$(koopa::realpath "${dict[output_dir]}")"
    dict[index_dir]="${dict[output_dir]}/index"
    dict[samples_dir]="${dict[output_dir]}/samples"
    koopa::dl \
        'Bootstraps' "${dict[bootstraps]}" \
        'FASTA file' "${dict[fasta_file]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'GFF file' "${dict[gff_file]}" \
        'Output dir' "${dict[output_dir]}" \
        'Tail' "${dict[tail]}"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the FASTQ files.
    # Pipe GNU find into array.
    readarray -t fastq_files <<< "$( \
        "${app[find]}" "$fastq_dir" \
            -maxdepth 1 \
            -mindepth 1 \
            -type 'f' \
            -name "*${tail}" \
            -not -name '._*' \
            -print \
        | "${app[sort]}" \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa::stop "No FASTQ files in '${dict[fastq_dir]}' ending \
with '${dict[tail]}'."
    fi
    str="$(koopa::ngettext "${#fastq_files[@]}" 'sample' 'samples')"
    koopa::alert_info "${#fastq_files[@]} ${str} detected."
    # Index {{{2
    # --------------------------------------------------------------------------
    koopa:::salmon_index \
        --fasta-file="${dict[fasta_file]}" \
        --output-dir="${dict[index_dir]}"
    koopa::assert_is_dir "${dict[index_dir]}"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify with salmon.
    for fastq in "${fastq_files[@]}"
    do
        koopa:::salmon_quant_single_end \
            --bootstraps="${dict[bootstraps]}" \
            --fastq="$fastq" \
            --gff-file="${dict[gff_file]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[samples_dir]}" \
            --tail="${dict[tail]}"
    done
    # Convert SAM to BAM {{{2
    # --------------------------------------------------------------------------
    # FIXME Work on a SAM-to-BAM conversion step here.
    koopa::alert_success 'salmon run completed successfully.'
    return 0
}
