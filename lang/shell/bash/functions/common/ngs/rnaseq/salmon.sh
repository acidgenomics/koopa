#!/usr/bin/env bash

# FIXME Need to improve error message on R1, R2 tail mismatch.

# Main functions ===============================================================
koopa::run_salmon_paired_end() { # {{{1
    # """
    # Run salmon on multiple paired-end FASTQ files.
    # @note Updated 2021-09-21.
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
        # FIXME Work on making this optional.
        [gff_file]=''
        [index_dir]=''
        [lib_type]='A'
        [output_dir]='salmon'
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
    # FIXME Improve the variable checks here.
    koopa::h1 'Running salmon (paired-end mode).'
    # FIXME Consider locating conda salmon here instead.
    koopa::activate_conda_env 'salmon'
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
    # Pipe GNU find into array.
    # FIXME Rework using 'koopa::find'.
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
    if [[ ! -d "${dict[index_dir]}" ]]
    then
        koopa::salmon_index \
            --fasta-file="${dict[fasta_file]}" \
            --output-dir="${dict[index_dir]}"
    fi
    koopa::assert_is_dir "${dict[index_dir]}"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify with salmon.
    for fastq_r1 in "${fastq_r1_files[@]}"
    do
        fastq_r2="${fastq_r1/${dict[r1_tail]}/${dict[r2_tail]}}"
        # FIXME Make gff file optional here.
        koopa::salmon_quant_paired_end \
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
    koopa::deactivate_conda
    koopa::alert_success "salmon run at '${dict[output_dir]}' \
completed successfully."
    return 0
}

koopa::run_salmon_single_end() { # {{{1
    # """
    # Run salmon on multiple single-end FASTQ files.
    # @note Updated 2021-09-21.
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
        [index_dir]=''
        [lib_type]='A'
        [output_dir]='salmon'
        [tail]='.fastq.gz'
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bootstraps='*)
                bootstraps="${1#*=}"
                shift 1
                ;;
            '--bootstraps')
                bootstraps="${2:?}"
                shift 2
                ;;
            '--fasta-file='*)
                fasta_file="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                fasta_file="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                fastq_dir="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                fastq_dir="${2:?}"
                shift 2
                ;;
            '--gff-file='*)
                gff_file="${1#*=}"
                shift 1
                ;;
            '--gff-file')
                gff_file="${2:?}"
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
                output_dir="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                output_dir="${2:?}"
                shift 2
                ;;
            '--tail='*)
                tail="${1#*=}"
                shift 1
                ;;
            '--tail')
                tail="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::h1 'Running salmon (single-end mode).'
    # FIXME Consider locating conda salmon here instead.
    koopa::activate_conda_env 'salmon'
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
        'FASTA file' "${dict[fasta_file]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'GFF file' "${dict[gff_file]}" \
        'Index dir' "${dict[index_dir]}" \
        'Output dir' "${dict[output_dir]}" \
        'Tail' "${dict[tail]}"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the FASTQ files.
    # Pipe GNU find into array.
    # FIXME Rework using 'koopa::find'.
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
    if [[ ! -d "${dict[index_dir]}" ]]
    then
        koopa::salmon_index \
            --fasta-file="${dict[fasta_file]}" \
            --output-dir="${dict[index_dir]}"
    fi
    koopa::assert_is_dir "${dict[index_dir]}"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify with salmon.
    for fastq in "${fastq_files[@]}"
    do
        koopa::salmon_quant_single_end \
            --bootstraps="${dict[bootstraps]}" \
            --fastq="$fastq" \
            --gff-file="${dict[gff_file]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[samples_dir]}" \
            --tail="${dict[tail]}"
    done
    koopa::deactivate_conda
    koopa::alert_success "salmon run at '${dict[output_dir]}' \
completed successfully."
    return 0
}

# Individual runners ===========================================================
# FIXME Need to pass '--gencode' flag here for GENCODE reference genome.
# FIXME Attempt to detect this automatically from the file name.
# FIXME Need to add support for decoy handling.
#       Compare with bcbio-nextgen code:
#       https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/rnaseq/salmon.py#L187
# FIXME Don't attempt to process decoys by default on macOS. Bioconda recipe
#       currently doesn't work, which is problematic.
# FIXME Consider exporting this as command-line-accessible 'salmon-index'.
koopa::salmon_index() { # {{{1
    # """
    # Generate salmon index.
    # @note Updated 2022-01-08.
    # """
    local app dict
    koopa::assert_has_args "$#"
    # FIXME Consider locating conda salmon here instead.
    koopa::assert_is_installed 'salmon'
    declare -A app=(
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [decoys]=0
        [fasta_file]=''
        [gencode]=0
        [output_dir]='salmon/index'
        [threads]="$(koopa::cpu_count)"
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
            # Flags ------------------------------------------------------------
            '--decoys')
                dict[decoys]=1
                shift 1
                ;;
            '--gencode')
                dict[gencode]=1
                shift 1
                ;;
            '--no-decoys')
                dict[decoys]=0
                shift 1
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
    # FIXME Automatically detect GENCODE genome, and pass '--gencode', if necessary.
    # See related issue:
    # https://github.com/COMBINE-lab/salmon/issues/15
    # FIXME Look for '^gencode\.' in basename, and enable automatically.
    if [[ "${dict[gencode]}" -eq 1 ]]
    then
        koopa::alert_info 'Indexing against GENCODE reference genome.'
        index_args+=('--gencode')
    fi
    if [[ "${dict[decoys]}" -eq 1 ]]
    then
        koopa::stop 'FIXME Need to add support for this.'
        koopa::salmon_generate_decoy_transcriptome \
            --genome-fasta-file='FIXME' \
            --gtf-file='FIXME' \
            --output-dir='FIXME' \
            --transcriptome-fasta-file='FIXME'
        dict[decoys_file]='FIXME_OUTPUT_DIR/decoys.txt'
        koopa::assert_is_file "${dict[decoys_file]}"
        # FIXME Check that this is right convention.
        index_args+=("--decoys=${dict[decoys_file]}")
    fi
    koopa::dl 'Index args' "${index_args[*]}"
    salmon index "${index_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    koopa::alert_success "Indexing of '${dict[fasta_file]}' at \
'${dict[output_dir]}' was successful."
    return 0
}

koopa::salmon_quant_paired_end() { # {{{1
    # """
    # Run salmon quant (per paired-end sample).
    # @note Updated 2021-09-21.
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
    # FIXME Consider locating conda salmon here instead.
    koopa::assert_is_installed 'salmon'
    declare -A app=(
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
    # > dict[sam_file]="${dict[output_dir]}/output.sam"
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
        # > "--writeMappings=${dict[sam_file]}"
    )
    koopa::dl 'Quant args' "${quant_args[*]}"
    salmon quant "${quant_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

koopa::salmon_quant_single_end() { # {{{1
    # """
    # Run salmon quant (per single-end sample).
    # @note Updated 2021-09-21.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    # """
    local app dict quant_args
    koopa::assert_has_args "$#"
    # FIXME Consider locating conda salmon here instead.
    koopa::assert_is_installed 'salmon'
    declare -A app=(
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
                shift 1
                ;;
            '--fastq='*)
                dict[fastq]="${1#*=}"
                shift 1
                ;;
            '--fastq')
                dict[fastq]="${2:?}"
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
    # > dict[sam_file]="${dict[output_dir]}/output.sam"
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
        # > "--writeMappings=${dict[sam_file]}"
    )
    koopa::dl 'Quant args' "${quant_args[*]}"
    salmon quant "${quant_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}




# FIXME Need to add function that generates decoy sequences.
# FIXME Require mashmap conda environment.
# FIXME Compare results of original script to our function, and confirm that
#       output is consistent, before proceeding.
# FIXME Note that mashmap conda recipe may only be working correctly on Linux.
#       Check this and confirm.
# FIXME Inform the user when skipping decoys on macOS.

koopa::salmon_generate_decoy_transcriptome() { # {{{1
    # """
    # Generate decoy transcriptome for salmon index.
    # @note Updated 2022-01-07.
    #
    # @section Documentation on original COMBINE lab script:
    #
    # generateDecoyTranscriptome.sh: This is a preprocessing script for creating
    # augmented hybrid FASTA file for 'salmon index'. It consumes a genome
    # FASTA, transcriptome FASTA, and the annotation GTF file to create a new
    # hybrid FASTA file which contains the decoy sequences from the genome,
    # concatenated with the transcriptome, resulting in 'gentrome.fa'. It runs
    # mashmap to align transcriptome to an exon masked genome, with 80%
    # homology, and extracts the mapped genomic interval. It uses awk and
    # bedtools to merge the contiguosly mapped interval, and extracts decoy
    # sequences from the genome. It also dumps 'decoys.txt' file, which contains
    # the name/identifier of the decoy sequences. Both 'gentrome.fa' and
    # 'decoys.txt' can be used with 'salmon index' with salmon >=0.14.0.
    #
    # @section Arguments from original COMBINE lab script:
    #
    # * [-j <N> =1 default]
    # * [-b <bedtools binary path> =bedtools default]
    # * [-m <mashmap binary path> =mashmap default]
    # * -a <gtf file>
    # * -g <genome fasta>
    # * -t <txome fasta>
    # * -o <output path>
    #
    # @seealso
    # - https://github.com/COMBINE-lab/SalmonTools/blob/master/
    #       scripts/generateDecoyTranscriptome.sh
    # - https://github.com/COMBINE-lab/SalmonTools/blob/master/README.md
    # - https://salmon.readthedocs.io/en/latest/
    #       salmon.html#quantifying-in-mapping-based-mode
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       rnaseq/salmon.py#L244
    # - https://github.com/marbl/MashMap/
    # """
    local app dict
    koopa::assert_has_args "$#"
    # Linux check currently required until Bioconda recipe is fixed for macOS.
    # See issue:
    # https://github.com/bioconda/bioconda-recipes/issues/32329
    koopa::assert_is_linux
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [bedtools]="$(koopa::locate_conda_bedtools)"  # FIXME Need to add this.
        [cat]="$(koopa::locate_cat)"
        [grep]="$(koopa::locate_grep)"
        [mashmap]="$(koopa::locate_conda_mashmap)"  # FIXME Need to add this.
        [sort]="$(koopa::locate_sort)"
    )
    declare -A dict=(
        [decoys_fasta_file]='decoys.fa'
        [decoys_txt_file]='decoys.txt'
        [exons_bed_file]='exons.bed'
        [genome_found_fasta_file]='genome_found.fa'
        [genome_found_merged_bed_file]='genome_found_merged.bed'
        [genome_found_sorted_bed_file]='genome_found.sorted.bed'
        [gentrome_fasta_file]='gentrome.fa'
        [mashmap_output_file]='mashmap.out'
        [masked_genome_fasta_file]='reference.masked.genome.fa'
        [output_dir]="${PWD:?}"
        [threads]="$(koopa::cpu_count)"
        [tmp_dir]="$(koopa::tmp_dir)"
    )
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
            '--transcriptome-fasta-file='*)
                dict[transcriptome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict[transcriptome_fasta_file]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set \
        '--genome-fasta-file' "${dict[genome_fasta_file]}" \
        '--gtf-file' "${dict[gtf_file]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--transcriptome-fasta-file' "${dict[transcriptome_fasta_file]}"
    koopa::assert_is_file \
        "${dict[genome_fasta_file]}" \
        "${dict[gtf_file]}" \
        "${dict[transcriptome_fasta_file]}"
    koopa::mkdir "${dict[output_dir]}"
    (
        koopa::cd "${dict[tmp_dir]}"
        koopa::alert 'Extracting exonic features from the GTF.'
        # shellcheck disable=SC2016
        "${app[awk]}" -v OFS='\t' \
            '{if ($3=="exon") {print $1,$4,$5}}' \
            "${dict[gtf_file]}" > "${dict[exons_bed_file]}"
        koopa::alert 'Masking the genome FASTA.'
        "${app[bedtools]}" maskfasta \
            -bed "${dict[exons_bed_file]}" \
            -fi "${dict[genome_fasta_file]}" \
            -fo "${dict[masked_genome_fasta_file]}"
        koopa::alert 'Aligning transcriptome to genome.'
        "${app[mashmap]}" \
            --filter_mode 'map' \
            --kmer 16 \
            --output "${dict[mashmap_output_file]}" \
            --perc_identity 80 \
            --query "${dict[transcriptome_fasta_file]}" \
            --ref "${dict[masked_genome_fasta_file]}" \
            --segLength 500 \
            --threads "${dict[threads]}"
        koopa::assert_is_file "${dict[mashmap_output_file]}"
        koopa::alert 'Extracting intervals from mashmap alignments.'
        # shellcheck disable=SC2016
        "${app[awk]}" -v OFS='\t' \
            '{print $6,$8,$9}' \
            "${dict[mashmap_output_file]}" \
            | "${app[sort]}" -k1,1 -k2,2n - \
            > "${dict[genome_found_sorted_bed_file]}"
        koopa::alert 'Merging the intervals.'
        "${app[bedtools]}" merge \
            -i "${dict[genome_found_sorted_bed_file]}" \
            > "${dict[genome_found_merged_bed_file]}"
        koopa::alert 'Extracting sequences from the genome.'
        "${app[bedtools]}" getfasta \
            -bed "${dict[genome_found_merged_bed_file]}" \
            -fi "${dict[masked_genome_fasta_file]}" \
            -fo "${dict[genome_found_fasta_file]}"
        koopa::alert 'Concatenating FASTA to get decoy sequences.'
        # FIXME Can we rework this to split over multiple lines, and therefore
        # conform to 80 character width limit?
        # shellcheck disable=SC2016
        "${app[awk]}" '{a=$0; getline;split(a, b, ":");  r[b[1]] = r[b[1]]""$0} END { for (k in r) { print k"\n"r[k] } }' \
            'genome_found.fa' \
            > "${dict[decoys_fasta_file]}"
        koopa::alert 'Making gentrome FASTA file.'
        "${app[cat]}" \
            "${dict[transcriptome_fasta_file]}" \
            "${dict[decoys_fasta_file]}" \
            > "${dict[gentrome_fasta_file]}"
        koopa::alert 'Extracting decoy sequence identifiers.'
        # shellcheck disable=SC2016
        "${app[grep]}" '>' "${dict[decoys_fasta_file]}" \
            | "${app[awk]}" '{print substr($1,2); }' \
            > "${dict[decoys_txt_file]}"
        koopa::cp \
            "${dict[gentrome_fasta_file]}" \
            "${dict[output_dir]}/${dict[gentrome_fasta_file]}"
        koopa::cp \
            "${dict[decoys_txt_file]}" \
            "${dict[output_dir]}/${dict[decoys_txt_file]}"
    )
    koopa::rm "${dict[tmp_dir]}"
    return 0
}
