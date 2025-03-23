#!/usr/bin/env bash

koopa_salmon_quant_single_end_per_sample() {
    # """
    # Run salmon quant on a single-end sample.
    # @note Updated 2023-10-20.
    #
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
    # Attempting to detect library type (strandedness) automatically by default.
    # Don't set '--gcBias' here, considered experimental for single-end reads.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    #
    # @examples
    # > koopa_salmon_quant_single_end_per_sample \
    # >     --fastq-file='fastq/sample1_001.fastq.gz' \
    # >     --index-dir='indexes/salmon-gencode' \
    # >     --output-dir='quant/salmon-gencode/sample1'
    # """
    local -A app dict
    local -a quant_args
    koopa_assert_has_args "$#"
    app['salmon']="$(koopa_locate_salmon)"
    koopa_assert_is_executable "${app[@]}"
    dict['bootstraps']=30
    # e.g. 'sample1.fastq.gz'.
    dict['fastq_file']=''
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
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
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
        '--fastq-file' "${dict['fastq_file']}" \
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
    koopa_assert_is_file "${dict['fastq_file']}"
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    # Don't set '--gcBias' here.
    quant_args+=(
        "--index=${dict['index_dir']}"
        "--libType=${dict['lib_type']}"
        "--numBootstraps=${dict['bootstraps']}"
        '--no-version-check'
        "--output=${dict['output_dir']}"
        '--seqBias'
        "--threads=${dict['threads']}"
        "--unmatedReads=${dict['fastq']}"
        '--useVBOpt'
    )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['salmon']}" quant "${quant_args[@]}"
    return 0
}
