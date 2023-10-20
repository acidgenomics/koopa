#!/usr/bin/env bash

koopa_salmon_quant_paired_end_per_sample() {
    # """
    # Run salmon quant on a paired-end sample.
    # @note Updated 2023-10-20.
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
    #
    # @examples
    # > koopa_salmon_quant_paired_end_per_sample \
    # >     --fastq-r1-file='fastq/sample1_R1_001.fastq.gz' \
    # >     --fastq-r2-file='fastq/sample1_R2_001.fastq.gz' \
    # >     --index-dir='indexes/salmon-gencode' \
    # >     --output-dir='quant/salmon-gencode/sample1'
    # """
    local -A app dict
    local -a quant_args
    koopa_assert_has_args "$#"
    app['salmon']="$(koopa_locate_salmon)"
    koopa_assert_is_executable "${app[@]}"
    # Current recommendation in bcbio-nextgen.
    dict['bootstraps']=30
    # e.g. 'sample1_R1_001.fastq.gz'.
    dict['fastq_r1_file']=''
    # e.g. 'sample1_R2_001.fastq.gz'.
    dict['fastq_r2_file']=''
    # e.g. 'salmon-index'.
    dict['index_dir']=''
    # Detect library fragment type (strandedness) automatically.
    dict['lib_type']='A'
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    # e.g. 'salmon'.
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "salmon quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
    dict['fastq_r1_file']="$(koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r2_file']="$(koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r2_bn']="$(koopa_basename "${dict['fastq_r2_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['fastq_r1_bn']}' and \
'${dict['fastq_r2_bn']}' in '${dict['output_dir']}'."
    quant_args+=(
        '--gcBias'
        "--index=${dict['index_dir']}"
        "--libType=${dict['lib_type']}"
        "--mates1=${dict['fastq_r1_file']}"
        "--mates2=${dict['fastq_r2_file']}"
        '--no-version-check'
        "--numBootstraps=${dict['bootstraps']}"
        "--output=${dict['output_dir']}"
        '--seqBias'
        "--threads=${dict['threads']}"
        '--useVBOpt'
    )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['salmon']}" quant "${quant_args[@]}"
    return 0
}
