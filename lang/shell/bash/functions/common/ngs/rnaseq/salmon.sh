#!/usr/bin/env bash

# FIXME Don't allow on-the-fly indexing.
# FIXME Require gentrome to always be created for index.
# FIXME Work on improving function consistency with kallisto runners.
# FIXME 'index-dir' input needs to resolve full path on disk, which makes the
# log files more meaningful.
# FIXME Consider renaming the main function to contain 'quant' instead.
# FIXME Consider nesting this under 'koopa app salmon XXX' instead.

# Main functions ===============================================================
koopa_run_salmon_paired_end() { # {{{1
    # """
    # Run salmon on multiple paired-end FASTQ files.
    # @note Updated 2022-02-11.
    #
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
    # Attempting to detect library type (strandedness) automatically by default.
    # """
    local app dict
    local fastq_r1_files fastq_r1_file fastq_r2_file
    koopa_assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa_locate_salmon)"
    )
    declare -A dict=(
        [bootstraps]=30
        [fastq_dir]='fastq'
        [fastq_r1_tail]='_R1_001.fastq.gz'
        [fastq_r2_tail]='_R2_001.fastq.gz'
        [gtf_file]=''
        [index_dir]=''  # FIXME Require this.
        [lib_type]='A'
        [output_dir]='salmon'
        [threads]="$(koopa_cpu_count)"
        [transcriptome_fasta_file]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Defunct ----------------------------------------------------------
            '--fasta-file='* | \
            '--fasta-file')
                koopa_defunct "Use '--transcriptome-fasta-file' instead \
of '--fasta-file'."
                ;;
            '--gff-file='* | \
            '--gff-file')
                koopa_defunct "Use '--gtf-file' instead of '--gff-file'."
                ;;
            # Key-value pairs --------------------------------------------------
            '--bootstraps='*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            '--bootstraps')
                dict[bootstraps]="${2:?}"
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
            '--gtf-file='*)
                dict[gtf_file]="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict[gtf_file]="${2:?}"
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
            '--threads='*)
                dict[threads]="${1#*=}"
                shift 1
                ;;
            '--threads')
                dict[threads]="${2:?}"
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_h1 'Running salmon (paired-end mode).'
    koopa_assert_is_set \
        '--bootstraps' "${dict[bootstraps]}" \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-tail' "${dict[fastq_r1_tail]}" \
        '--gtf-file' "${dict[gtf_file]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--threads' "${dict[threads]}" \
        '--transcriptome-fasta-file' "${dict[transcriptome_fasta_file]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[gtf_file]="$(koopa_realpath "${dict[gtf_file]}")"
    dict[transcriptome_fasta_file]="$( \
        koopa_realpath "${dict[transcriptome_fasta_file]}" \
    )"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_dl \
        'salmon' "${app[salmon]}" \
        'Bootstraps' "${dict[bootstraps]}" \
        'FASTQ R1 tail' "${dict[fastq_r1_tail]}" \
        'FASTQ R2 tail' "${dict[fastq_r2_tail]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'GTF file' "${dict[gtf_file]}" \
        'Index dir' "${dict[index_dir]}" \
        'Output dir' "${dict[output_dir]}" \
        'Threads' "${dict[threads]}" \
        'Transcriptome FASTA file' "${dict[transcriptome_fasta_file]}"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the R1 FASTQ files.
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_r1_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_r1_files[@]}" -eq 0 ]]
    then
        koopa_stop "No FASTQ files in '${dict[fastq_dir]}' ending \
with '${dict[fastq_r1_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    # Index {{{2
    # --------------------------------------------------------------------------
    # FIXME Always need to run this step to generate 'decoys.txt' file
    # and gentrome FASTA file.
    # FIXME Need to call 'koopa_fasta_generate_chromosomes_file'.
    if [[ ! -d "${dict[index_dir]}" ]]
    then
        koopa_salmon_index \
            --output-dir="${dict[index_dir]}" \
            --threads="${dict[threads]}" \
            --transcriptome-fasta-file="${dict[transcriptome_fasta_file]}"
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify with salmon.
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        fastq_r2_file="${fastq_r1_file/\
${dict[fastq_r1_tail]}/${dict[fastq_r2_tail]}}"
        koopa_salmon_quant_paired_end \
            --bootstraps="${dict[bootstraps]}" \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict[fastq_r1_tail]}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict[fastq_r2_tail]}" \
            --gtf-file="${dict[gtf_file]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}" \
            --threads="${dict[threads]}"
    done
    koopa_alert_success "salmon run at '${dict[output_dir]}' \
completed successfully."
    return 0
}

# FIXME Rename this to contain 'quant' instead (see above).
koopa_run_salmon_single_end() { # {{{1
    # """
    # Run salmon on multiple single-end FASTQ files.
    # @note Updated 2022-02-11.
    #
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
    # Attempting to detect library type (strandedness) automatically by default.
    # """
    local app dict
    local fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa_locate_salmon)"
    )
    declare -A dict=(
        [bootstraps]=30
        [fastq_dir]='fastq'
        [fastq_tail]='.fastq.gz'
        [index_dir]=''  # FIXME Require this.
        [lib_type]='A'
        [output_dir]='salmon'
        [threads]="$(koopa_cpu_count)"
        [transcriptome_fasta_file]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Defunct ----------------------------------------------------------
            '--fasta-file='* | \
            '--fasta-file')
                koopa_defunct "Use '--transcriptome-fasta-file' instead \
of '--fasta-file'."
                ;;
            '--gff-file='* | \
            '--gff-file')
                koopa_defunct "Use '--gtf-file' instead of '--gff-file'."
                ;;
            # Key-value pairs --------------------------------------------------
            '--bootstraps='*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            '--bootstraps')
                dict[bootstraps]="${2:?}"
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
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
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
            '--threads='*)
                dict[threads]="${1#*=}"
                shift 1
                ;;
            '--threads')
                dict[threads]="${2:?}"
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_h1 'Running salmon (single-end mode).'
    koopa_assert_is_set \
        '--bootstraps' "${dict[bootstraps]}" \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--gtf-file' "${dict[gtf_file]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--threads' "${dict[threads]}" \
        '--transcriptome-fasta-file' "${dict[transcriptome_fasta_file]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[gtf_file]="$(koopa_realpath "${dict[gtf_file]}")"
    dict[transcriptome_fasta_file]="$( \
        koopa_realpath "${dict[transcriptome_fasta_file]}" \
    )"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_dl \
        'salmon' "${app[salmon]}" \
        'Bootstraps' "${dict[bootstraps]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ tail' "${dict[fastq_tail]}" \
        'GTF file' "${dict[gtf_file]}" \
        'Index dir' "${dict[index_dir]}" \
        'Output dir' "${dict[output_dir]}" \
        'Threads' "${dict[threads]}" \
        'Transcriptome FASTA file' "${dict[transcriptome_fasta_file]}"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the FASTQ files.
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa_stop "No FASTQ files in '${dict[fastq_dir]}' ending \
with '${dict[fastq_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    # Index {{{2
    # --------------------------------------------------------------------------
    if [[ ! -d "${dict[index_dir]}" ]]
    then
        koopa_salmon_index \
            --no-decoy-aware \
            --output-dir="${dict[index_dir]}" \
            --threads="${dict[threads]}" \
            --transcriptome-fasta-file="${dict[transcriptome_fasta_file]}"
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify with salmon.
    for fastq_file in "${fastq_files[@]}"
    do
        koopa_salmon_quant_single_end \
            --bootstraps="${dict[bootstraps]}" \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict[fastq_tail]}" \
            --gtf-file="${dict[gtf_file]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}" \
            --threads="${dict[threads]}"
    done
    koopa_alert_success "salmon run at '${dict[output_dir]}' \
completed successfully."
    return 0
}

# Individual runners ===========================================================

koopa_salmon_index() { # {{{1
    # """
    # Generate salmon index.
    # @note Updated 2022-03-16.
    #
    # @section GENCODE:
    #
    # Need to pass '--gencode' flag here for GENCODE reference genome.
    # Function attempts to detect this automatically from the file name.
    #
    # @seealso
    # - salmon index --help
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa_locate_salmon)"
    )
    declare -A dict=(
        [gencode]=0
        [genome_fasta_file]=''
        [kmer_length]=31
        [output_dir]='salmon-index'
        [threads]="$(koopa_cpu_count)"
        [tmp_dir]="$(koopa_tmp_dir)"
        [transcriptome_fasta_file]=''
        [type]='puff'
    )
    dict[decoys_file]="${dict[tmp_dir]}/decoys.txt"
    dict[gentrome_fasta_file]="${dict[tmp_dir]}/gentrome.fa.gz"
    index_args=()
    while (("$#"))
    do
        case "$1" in
            # Defunct ----------------------------------------------------------
            '--fasta-file='* | \
            '--fasta-file')
                koopa_defunct "Use '--transcriptome-fasta-file' instead \
of '--fasta-file'."
                ;;
            # Key-value pairs --------------------------------------------------
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
            '--threads='*)
                dict[threads]="${1#*=}"
                shift 1
                ;;
            '--threads')
                dict[threads]="${2:?}"
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
            # Flags ------------------------------------------------------------
            '--gencode')
                dict[gencode]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict[genome_fasta_file]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--threads' "${dict[threads]}" \
        '--transcriptome-fasta-file' "${dict[transcriptome_fasta_file]}"
    koopa_assert_is_not_dir "${dict[output_dir]}"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_assert_is_file \
        "${dict[genome_fasta_file]}" \
        "${dict[transcriptome_fasta_file]}"
    dict[genome_fasta_file]="$(koopa_realpath "${dict[genome_fasta_file]}")"
    dict[transcriptome_fasta_file]="$( \
        koopa_realpath "${dict[transcriptome_fasta_file]}" \
    )"
    koopa_alert "Generating salmon index at '${dict[output_dir]}'."
    if koopa_str_detect_regex \
        --string="$(koopa_basename "${dict[transcriptome_fasta_file]}")" \
        --pattern='^gencode\.'
    then
        dict[gencode]=1
    fi
    if [[ "${dict[gencode]}" -eq 1 ]]
    then
        koopa_alert_info 'Indexing against GENCODE reference genome.'
        index_args+=('--gencode')
    fi
    koopa_fasta_generate_chromosomes_file \
        --genome-fasta-file="${dict[genome_fasta_file]}" \
        --output-file="${dict[decoys_file]}"
    koopa_assert_is_file "${dict[decoys_file]}"
    koopa_fasta_generate_decoy_transcriptome_file \
        --genome-fasta-file="${dict[genome_fasta_file]}" \
        --output-file="${dict[gentrome_fasta_file]}" \
        --transcriptome-fasta-file="${dict[transcriptome_fasta_file]}"
    koopa_assert_is_file "${dict[gentrome_fasta_file]}"
    index_args+=(
        "--decoys=${dict[decoys_file]}"
        "--index=${dict[output_dir]}"
        "--kmerLen=${dict[kmer_length]}"
        '--no-version-check'
        "--threads=${dict[threads]}"
        "--transcripts=${dict[gentrome_fasta_file]}"
        "--type=${dict[type]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app[salmon]}" index "${index_args[@]}"
    koopa_alert_success "Generation of salmon index at '${dict[output_dir]}' \
was successful."
    return 0
}

koopa_salmon_quant_paired_end() { # {{{1
    # """
    # Run salmon quant (per paired-end sample).
    # @note Updated 2022-03-16.
    #
    # Quartz is currently using only '--gcBias', not '--seqBias'.
    # Consider use of '--numGibbsSamples' instead of '--numBootstraps'.
    #
    # Relevant options:
    # * '--gcBias': Learn and correct for fragment-level GC biases in the input
    #   data. Specifically, this model will attempt to correct for biases in how
    #   likely a sequence is to be observed based on its internal GC content.
    #   Recommended for use with DESeq2 by Mike Love.
    # * "--libType='A'": Enable ability to automatically infer (i.e. guess) the
    #   library type based on how the first few thousand reads map to the
    #   transcriptome. Note that most commercial vendors use Illumina TruSeq,
    #   which is dUTP, corresponding to 'ISR' for salmon.
    # * '--numBootstraps': Compute bootstrapped abundance estimates. This is
    #   done by resampling (with replacement) from the counts assigned to the
    #   fragment equivalence classes, and then re-running the optimization
    #   procedure.
    # * '--seqBias': Enable salmon to learn and correct for sequence-specific
    #   biases in the input data. Specifically, this model will attempt to
    #   correct for random hexamer priming bias, which results in the
    #   preferential sequencing of fragments starting with certain nucleotide
    #   motifs.
    # * '--useVBOpt': Use the Variational Bayesian EM [default].
    #
    # Experimental but potentially interesting options:
    # * '--numGibbsSamples': Just as with the '--numBootstraps' procedure, this
    #   option produces samples that allow us to estimate the variance in
    #   abundance estimates. However, in this case the samples are generated
    #   using posterior Gibbs sampling over the fragment equivalence classes
    #   rather than bootstrapping.
    # * '--posBias': Enable modeling of a position-specific fragment start
    #   distribution. This is meant to model non-uniform coverage biases that
    #   are sometimes present in RNA-seq data (e.g. 5' or 3' positional bias).
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    # - The '--gcBias' flag is recommended for DESeq2:
    #   https://bioconductor.org/packages/release/bioc/vignettes/DESeq2/
    #     inst/doc/DESeq2.html
    # - How to output pseudobams:
    #   https://github.com/COMBINE-lab/salmon/issues/38
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     rnaseq/salmon.py
    # - https://github.com/nf-core/rnaseq/blob/master/modules/nf-core/modules/
    #     salmon/quant/main.nf
    # - https://github.com/hbctraining/Intro-to-rnaseq-hpc-salmon-flipped/
    # - https://www.biostars.org/p/386982/
    # - https://github.com/dohlee/snakemake-salmon-sleuth/blob/
    #     master/config.yaml
    # - https://github.com/yujijun/BD_projects_bulkseq/blob/master/script/
    #     reference/RNAseq_pipeline/salmon.wdl
    # """
    local app dict quant_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa_locate_salmon)"
    )
    declare -A dict=(
        [bootstraps]=30
        [fastq_r1_file]=''
        [fastq_r1_tail]='_R1_001.fastq.gz'
        [fastq_r2_file]=''
        [fastq_r2_tail]='_R2_001.fastq.gz'
        [gtf_file]=''
        [index_dir]=''
        [lib_type]='A'
        [output_dir]='salmon'
        [threads]="$(koopa_cpu_count)"
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
            '--gtf-file='*)
                dict[gtf_file]="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict[gtf_file]="${2:?}"
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
            '--threads='*)
                dict[threads]="${1#*=}"
                shift 1
                ;;
            '--threads')
                dict[threads]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bootstraps' "${dict[bootstraps]}" \
        '--fastq-r1-file' "${dict[fastq_r1_file]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-file' "${dict[fastq_r2_file]}" \
        '--fastq-r2-tail' "${dict[fastq_r2_tail]}" \
        '--gtf-file' "${dict[gtf_file]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--threads' "${dict[threads]}"
    koopa_assert_is_file \
        "${dict[fastq_r1_file]}" \
        "${dict[fastq_r2_file]}" \
        "${dict[gtf_file]}"
    koopa_assert_is_dir "${dict[index_dir]}"
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
    koopa_alert "Quantifying '${dict[id]}' into '${dict[output_dir]}'."
    quant_args=(
        '--gcBias'
        "--geneMap=${dict[gtf_file]}"
        "--index=${dict[index_dir]}"
        "--libType=${dict[lib_type]}"
        "--mates1=${dict[fastq_r1_file]}"
        "--mates2=${dict[fastq_r2_file]}"
        "--numBootstraps=${dict[bootstraps]}"
        '--no-version-check'
        "--output=${dict[output_dir]}"
        '--seqBias'
        "--threads=${dict[threads]}"
        '--useVBOpt'
    )
    # Writing mappings to SAM file blows up disk space too much.
    # > dict[sam_file]="${dict[output_dir]}/output.sam"
    # > quant_args+=(
    # >     "--writeMappings=${dict[sam_file]}"
    # > )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app[salmon]}" quant "${quant_args[@]}"
    return 0
}

koopa_salmon_quant_single_end() { # {{{1
    # """
    # Run salmon quant (per single-end sample).
    # @note Updated 2022-03-16.
    #
    # Don't set '--gcBias' here, considered experimental for single-end reads.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    # """
    local app dict quant_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa_locate_salmon)"
    )
    declare -A dict=(
        [bootstraps]=30
        [fastq_file]=''
        [fastq_tail]='.fastq.gz'
        [gtf_file]=''
        [index_dir]=''
        [lib_type]='A'
        [output_dir]='salmon'
        [threads]="$(koopa_cpu_count)"
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
            '--gtf-file='*)
                dict[gtf_file]="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict[gtf_file]="${2:?}"
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
            '--threads='*)
                dict[threads]="${1#*=}"
                shift 1
                ;;
            '--threads')
                dict[threads]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bootstraps' "${dict[bootstraps]}" \
        '--fastq-file' "${dict[fastq_file]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--gtf-file' "${dict[gtf_file]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--threads' "${dict[threads]}"
    koopa_assert_is_file \
        "${dict[fastq_file]}" \
        "${dict[gtf_file]}"
    koopa_assert_is_dir "${dict[index_dir]}"
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
    koopa_alert "Quantifying '${dict[id]}' into '${dict[output_dir]}'."
    quant_args=(
        "--geneMap=${dict[gtf_file]}"
        "--index=${dict[index_dir]}"
        "--libType=${dict[lib_type]}"
        "--numBootstraps=${dict[bootstraps]}"
        '--no-version-check'
        "--output=${dict[output_dir]}"
        '--seqBias'
        "--threads=${dict[threads]}"
        "--unmatedReads=${dict[fastq]}"
    )
    # Writing mappings to SAM file blows up disk space too much.
    # > dict[sam_file]="${dict[output_dir]}/output.sam"
    # > quant_args+=(
    # >     "--writeMappings=${dict[sam_file]}"
    # > )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app[salmon]}" quant "${quant_args[@]}"
    return 0
}
