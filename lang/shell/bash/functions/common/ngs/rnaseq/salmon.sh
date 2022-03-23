#!/usr/bin/env bash

koopa_salmon_index() { # {{{1
    # """
    # Generate salmon index.
    # @note Updated 2022-03-23.
    #
    # @section GENCODE:
    #
    # Need to pass '--gencode' flag here for GENCODE reference genome.
    # Function attempts to detect this automatically from the file name.
    #
    # @seealso
    # - salmon index --help
    # - https://combine-lab.github.io/alevin-tutorial/2019/selective-alignment/
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    # - https://github.com/refgenie/refgenieserver/issues/63
    # """
    local app dict index_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa_locate_salmon)"
    )
    declare -A dict=(
        [decoys]=1
        [gencode]=0
        [genome_fasta_file]=''
        [kmer_length]=31
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]='' # 'salmon-index'
        [threads]="$(koopa_cpu_count)"
        [transcriptome_fasta_file]=''
        [type]='puff' # default
    )
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict[genome_fasta_file]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--transcriptome-fasta-file' "${dict[transcriptome_fasta_file]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "salmon index requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_file \
        "${dict[genome_fasta_file]}" \
        "${dict[transcriptome_fasta_file]}"
    koopa_assert_is_not_dir "${dict[output_dir]}"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    dict[genome_fasta_file]="$(koopa_realpath "${dict[genome_fasta_file]}")"
    dict[transcriptome_fasta_file]="$( \
        koopa_realpath "${dict[transcriptome_fasta_file]}" \
    )"
    koopa_alert "Generating salmon index at '${dict[output_dir]}'."
    if [[ "${dict[gencode]}" -eq 0 ]] && \
        koopa_str_detect_regex \
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
    if [[ "${dict[decoys]}" -eq 1 ]]
    then
        dict[tmp_dir]="$(koopa_tmp_dir)"
        dict[decoys_file]="${dict[tmp_dir]}/decoys.txt"
        dict[gentrome_fasta_file]="${dict[tmp_dir]}/gentrome.fa.gz"
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
            "--transcripts=${dict[gentrome_fasta_file]}"
        )
    else
        index_args+=(
            "--transcripts=${dict[transcriptome_fasta_file]}"
        )
    fi
    index_args+=(
        "--index=${dict[output_dir]}"
        "--kmerLen=${dict[kmer_length]}"
        '--no-version-check'
        "--threads=${dict[threads]}"
        "--type=${dict[type]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app[salmon]}" index "${index_args[@]}"
    koopa_alert_success "salmon index created at '${dict[output_dir]}'."
    return 0
}

koopa_salmon_quant_paired_end() { # {{{1
    # """
    # Run salmon quant on multiple paired-end FASTQs in a directory.
    # @note Updated 2022-03-22.
    # """
    local dict fastq_r1_files fastq_r1_file fastq_r2_file
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_r1_tail]='' # '_R1_001.fastq.gz'
        [fastq_r2_tail]='' # '_R2_001.fastq.gz'
        [index_dir]=''
        [lib_type]='A' # automatic strandedness detection
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
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running salmon quant (paired-end mode).'
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
        koopa_salmon_quant_paired_end_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict[fastq_r1_tail]}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict[fastq_r2_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'salmon quant was successful.'
    return 0
}

koopa_salmon_quant_paired_end_per_sample() { # {{{1
    # """
    # Run salmon quant on a paired-end sample.
    # @note Updated 2022-03-22.
    #
    # Attempting to detect library type (strandedness) automatically by default.
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
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
        [fastq_r1_tail]='' # '_R1_001.fastq.gz'
        [fastq_r2_file]=''
        [fastq_r2_tail]='' # '_R2_001.fastq.gz'
        [index_dir]=''
        [lib_type]='A'
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
    )
    quant_args=()
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
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "salmon quant requires ${dict[mem_gb_cutoff]} GB of RAM."
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
    quant_args+=(
        '--gcBias' # Recommended for DESeq2.
        "--index=${dict[index_dir]}"
        "--libType=${dict[lib_type]}"
        "--mates1=${dict[fastq_r1_file]}"
        "--mates2=${dict[fastq_r2_file]}"
        '--no-version-check'
        "--numBootstraps=${dict[bootstraps]}"
        "--output=${dict[output_dir]}"
        '--seqBias'
        "--threads=${dict[threads]}"
        '--useVBOpt'
    )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app[salmon]}" quant "${quant_args[@]}"
    return 0
}

koopa_salmon_quant_single_end() { # {{{1
    # """
    # Run salmon quant on multiple single-end FASTQs in a directory.
    # @note Updated 2022-03-22.
    # """
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_tail]='' # '.fastq.gz'
        [index_dir]=''
        [lib_type]='A'
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
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running salmon quant (single-end mode).'
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
        koopa_salmon_quant_single_end_per_sample \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict[fastq_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'salmon quant was successful.'
    return 0
}

koopa_salmon_quant_single_end_per_sample() { # {{{1
    # """
    # Run salmon quant on a single-end sample.
    # @note Updated 2022-03-17.
    #
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
    # Attempting to detect library type (strandedness) automatically by default.
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
        [fastq_tail]='' # '.fastq.gz'
        [index_dir]=''
        [lib_type]='A'
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
    )
    quant_args=()
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
        '--lib-type' "${dict[lib_type]}" \
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
    quant_args+=(
        "--index=${dict[index_dir]}"
        "--libType=${dict[lib_type]}"
        "--numBootstraps=${dict[bootstraps]}"
        '--no-version-check'
        "--output=${dict[output_dir]}"
        '--seqBias'
        "--threads=${dict[threads]}"
        "--unmatedReads=${dict[fastq]}"
        '--useVBOpt'
    )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app[salmon]}" quant "${quant_args[@]}"
    return 0
}
