#!/usr/bin/env bash

koopa_star_index() {
    # """
    # Create a genome index for RSEM aligner.
    # @note Updated 2023-03-01.
    #
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/rnaseq/rsem.py
    #
    # @examples
    # > koopa_rsem_index \
    # >     --genome-fasta-file='GRCh38.primary_assembly.genome.fa.gz' \
    # >     --gtf-file='gencode.v39.annotation.gtf.gz' \
    # >     --output-dir='rsem-index'
    # """
    local app dict index_args
    declare -A app=(
        ['rsem_prepare_reference']="$(koopa_locate_rsem_prepare_reference)"
    )
    [[ -x "${app['rsem_prepare_reference']}" ]] || return 1
    declare -A dict=(
        # e.g. 'GRCh38.primary_assembly.genome.fa.gz'
        ['genome_fasta_file']=''
        # e.g. 'gencode.v39.annotation.gtf.gz'
        ['gtf_file']=''
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=10
        # e.g. 'rsem-index'.
        ['output_dir']=''
        ['threads']="$(koopa_cpu_count)"
        ['tmp_dir']="$(koopa_tmp_dir)"
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
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
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "RSEM requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    dict['genome_fasta_file']="$(koopa_realpath "${dict['genome_fasta_file']}")"
    dict['gtf_file']="$(koopa_realpath "${dict['gtf_file']}")"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    koopa_alert "Generating RSEM index at '${dict['output_dir']}'."
    dict['build_name']="$(koopa_basename "${dict['output_dir']}")"
    index_args+=(
        '--gtf' "${dict['gtf_file']}"
        '--num-threads' "${dict['jobs']}"
        "${dict['genome_fasta_file']}"
        "${dict['build_name']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app['rsem_prepare_reference']}" "${index_args[@]}"
    # FIXME Build in temporary directory and the copy to target.
    koopa_alert_success "RSEM index created at '${dict['output_dir']}'."
    return 0
}
