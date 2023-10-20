#!/usr/bin/env bash

# FIXME Seeing a segentation fault during kallisto quant:
# > [   em] quantifying the abundances ...
#  Segmentation fault      (core dumped)

# NOTE This currently messes up with GENCODE identifiers.
# Consider correcting the FASTA file here before proceeding.
# This is a known issue/limitation of kallisto.

koopa_kallisto_quant_paired_end_per_sample() {
    # """
    # Run kallisto quant on a paired-end sample.
    # @note Updated 2023-06-16.
    #
    # Consider adding support for '--genomebam' and '--pseudobam' output,
    # which requires GTF file input ('--gtf') and chromosome names
    # ('--chromosomes'), which can be generated from the GTF file or the
    # genome FASTA file.
    #
    # @section Important options:
    #
    # * --bias: Learns parameters for a model of sequences specific bias and
    #   corrects the abundances accordlingly.
    # * --fr-stranded: Run kallisto in strand specific mode, only fragments
    #   where the first read in the pair pseudoaligns to the forward strand of a
    #   transcript are processed. If a fragment pseudoaligns to multiple
    #   transcripts, only the transcripts that are consistent with the first
    #   read are kept.
    # * --rf-stranded: Same as '--fr-stranded', but the first read maps to the
    #   reverse strand of a transcript.
    #
    # @section Stranded mode:
    #
    # Run kallisto in stranded mode, depending on the library type. Using salmon
    # library type codes here, for consistency. Doesn't currently support an
    # auto detection mode, like salmon. Most current libraries are 'ISR' /
    # '--rf-stranded', if unsure.
    #
    # @seealso
    # - kallisto quant --help
    # - https://pachterlab.github.io/kallisto/manual
    # - https://littlebitofdata.com/en/2017/08/strandness_in_rnaseq/
    # - https://salmon.readthedocs.io/en/latest/library_type.html
    # - Usage of GENCODE annotations:
    #   - https://www.biostars.org/p/419605/
    #   - https://groups.google.com/g/kallisto-and-applications/c/
    #       KQ8782UD35E/m/hbqqMOgGBwAJ
    #   - https://support.bioconductor.org/p/9149475/
    #
    # @examples
    # > koopa_kallisto_quant_paired_end_per_sample \
    # >     --fastq-r1-file='fastq/sample1_R1_001.fastq.gz' \
    # >     --fastq-r1-tail='_R1_001.fastq.gz' \
    # >     --fastq-r2-file='fastq/sample1_R2_001.fastq.gz' \
    # >     --fastq-r2-tail="_R2_001.fastq.gz' \
    # >     --index-dir='kallisto-index' \
    # >     --output-dir='kallisto'
    # """
    local -A app dict
    local -a quant_args
    koopa_assert_has_args "$#"
    app['kallisto']="$(koopa_locate_kallisto)"
    koopa_assert_is_executable "${app[@]}"
    # Current recommendation in bcbio-nextgen.
    dict['bootstraps']=30
    # e.g. 'sample1_R1_001.fastq.gz'
    dict['fastq_r1_file']=''
    # e.g. '_R1_001.fastq.gz'.
    dict['fastq_r1_tail']=''
    # e.g. 'sample1_R2_001.fastq.gz'.
    dict['fastq_r2_file']=''
    # e.g. '_R2_001.fastq.gz'.
    dict['fastq_r2_tail']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
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
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
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
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
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
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--fastq-r2-tail' "${dict['fastq_r2_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "kallisto quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['index_file']="${dict['index_dir']}/kallisto.idx"
    koopa_assert_is_file \
        "${dict['fastq_r1_file']}" \
        "${dict['fastq_r2_file']}" \
        "${dict['index_file']}"
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="${dict['fastq_r1_bn']/${dict['fastq_r1_tail']}/}"
    dict['fastq_r2_bn']="$(koopa_basename "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="${dict['fastq_r2_bn']/${dict['fastq_r2_tail']}/}"
    koopa_assert_are_identical "${dict['fastq_r1_bn']}" "${dict['fastq_r2_bn']}"
    dict['id']="${dict['fastq_r1_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['fastq_r1_file']="$(koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r2_file']="$(koopa_realpath "${dict['fastq_r2_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' into '${dict['output_dir']}'."
    quant_args+=(
        '--bias'
        "--bootstrap-samples=${dict['bootstraps']}"
        "--index=${dict['index_file']}"
        "--output-dir=${dict['output_dir']}"
        "--threads=${dict['threads']}"
        '--verbose'
    )
    dict['lib_type']="$( \
        koopa_kallisto_fastq_library_type "${dict['lib_type']}" \
    )"
    if [[ -n "${dict['lib_type']}" ]]
    then
        quant_args+=("${dict['lib_type']}")
    fi
    quant_args+=("${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}")
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['kallisto']}" quant "${quant_args[@]}"
    return 0
}
