#!/usr/bin/env bash

koopa_kallisto_quant_single_end_per_sample() {
    # """
    # Run kallisto quant (per single-end sample).
    # @note Updated 2023-10-20.
    #
    # Consider adding support for '--genomebam' and '--pseudobam' output,
    # which requires GTF file input ('--gtf') and chromosome names
    # ('--chromosomes'), which can be generated from the GTF file or the
    # genome FASTA file.
    #
    # @section Fragment length:
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
    # @seealso
    # - https://www.biostars.org/p/252823/
    #
    # @examples
    # > koopa_kallisto_quant_single_end_per_sample \
    # >     --fastq-file='fastq/sample1_001.fastq.gz' \
    # >     --index-dir='indexes/kallisto-gencode' \
    # >     --output-dir='quant/kallisto-gencode/sample1'
    # """
    local -A app dict
    local -a quant_args
    app['kallisto']="$(koopa_locate_kallisto)"
    koopa_assert_is_executable "${app[@]}"
    # Current recommendation in bcbio-nextgen.
    dict['bootstraps']=30
    # e.g. 'sample1_001.fastq.gz'.
    dict['fastq_file']=''
    # Current recommendation in bcbio-nextgen.
    dict['fragment_length']=200
    # e.g. 'kallisto-index'.
    dict['index_dir']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    # e.g. 'kallisto'.
    dict['output_dir']=''
    # Current recommendation in bcbio-nextgen.
    dict['sd']=25
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
                shift 2
                ;;
            '--fragment-length='*)
                dict['fragment_length']="${1#*=}"
                shift 1
                ;;
            '--fragment-length')
                dict['fragment_length']="${2:?}"
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
        '--fastq-file' "${dict['fastq_file']}" \
        '--fragment-length' "${dict['fragment_length']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "kallisto quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['index_file']="${dict['index_dir']}/kallisto.idx"
    koopa_assert_is_file "${dict['fastq_file']}" "${dict['index_file']}"
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['fastq_bn']}' into \
'${dict['output_dir']}'."
    quant_args+=(
        "--bootstrap-samples=${dict['bootstraps']}"
        "--fragment-length=${dict['fragment_length']}"
        "--index=${dict['index_file']}"
        "--output-dir=${dict['output_dir']}"
        "--sd=${dict['sd']}"
        '--single'
        "--threads=${dict['threads']}"
        '--verbose'
    )
    quant_args+=("$fastq_file")
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['kallisto']}" quant "${quant_args[@]}"
    return 0
}
