#!/usr/bin/env bash

koopa_rsem_index() {
    # """
    # Create a genome index for RSEM aligner.
    # @note Updated 2023-10-18.
    #
    # @seealso
    # - https://deweylab.github.io/RSEM/rsem-prepare-reference.html
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/rnaseq/rsem.py
    #
    # @examples
    # > koopa_rsem_index \
    # >     --genome-fasta-file='GRCh38.primary_assembly.genome.fa.gz' \
    # >     --gtf-file='gencode.v39.annotation.gtf.gz' \
    # >     --output-dir='rsem-index'
    # """
    local -A app bool dict
    local -a index_args
    app['rsem_prepare_reference']="$(koopa_locate_rsem_prepare_reference)"
    koopa_assert_is_executable "${app[@]}"
    bool['is_tmp_genome_fasta_file']=0
    bool['is_tmp_gtf_file']=0
    dict['compress_ext_pattern']="$(koopa_compress_ext_pattern)"
    # e.g. 'GRCh38.primary_assembly.genome.fa.gz'
    dict['genome_fasta_file']=''
    # e.g. 'gencode.v39.annotation.gtf.gz'
    dict['gtf_file']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=10
    # e.g. 'rsem-index'.
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    dict['tmp_dir']="$(koopa_tmp_dir)"
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
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Generating RSEM index at '${dict['output_dir']}'."
    if koopa_str_detect_regex \
        --string="${dict['genome_fasta_file']}" \
        --pattern="${dict['compress_ext_pattern']}"
    then
        bool['is_tmp_genome_fasta_file']=1
        dict['tmp_genome_fasta_file']="$(koopa_tmp_file)"
        koopa_decompress \
            "${dict['genome_fasta_file']}" \
            "${dict['tmp_genome_fasta_file']}"
    else
        dict['tmp_genome_fasta_file']="${dict['genome_fasta_file']}"
    fi
    if koopa_str_detect_regex \
        --string="${dict['gtf_file']}" \
        --pattern="${dict['compress_ext_pattern']}"
    then
        bool['is_tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(koopa_tmp_file)"
        koopa_decompress \
            "${dict['gtf_file']}" \
            "${dict['tmp_gtf_file']}"
    else
        dict['tmp_gtf_file']="${dict['gtf_file']}"
    fi
    index_args+=(
        '--gtf' "${dict['tmp_gtf_file']}"
        '--num-threads' "${dict['threads']}"
        "${dict['tmp_genome_fasta_file']}"
        'rsem'
    )
    koopa_dl 'Index args' "${index_args[*]}"
    (
        koopa_cd "${dict['output_dir']}"
        "${app['rsem_prepare_reference']}" "${index_args[@]}"
    )
    [[ "${bool['is_tmp_genome_fasta_file']}" -eq 1 ]] && \
        koopa_rm "${dict['tmp_genome_fasta_file']}"
    [[ "${bool['is_tmp_gtf_file']}" -eq 1 ]] && \
        koopa_rm "${dict['tmp_gtf_file']}"
    koopa_alert_success "RSEM index created at '${dict['output_dir']}'."
    return 0
}
