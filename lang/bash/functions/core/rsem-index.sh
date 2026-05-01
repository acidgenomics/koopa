#!/usr/bin/env bash

# TODO Add support for pushing to S3 as a tarball.

_koopa_rsem_index() {
    # """
    # Create a genome index for RSEM aligner.
    # @note Updated 2023-10-20.
    #
    # @seealso
    # - https://deweylab.github.io/RSEM/rsem-prepare-reference.html
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/rnaseq/rsem.py
    #
    # @examples
    # > _koopa_rsem_index \
    # >     --genome-fasta-file='GRCh38.primary_assembly.genome.fa.gz' \
    # >     --gtf-file='gencode.v39.annotation.gtf.gz' \
    # >     --output-dir='rsem-index'
    # """
    local -A app bool dict
    local -a index_args
    app['rsem_prepare_reference']="$(_koopa_locate_rsem_prepare_reference)"
    _koopa_assert_is_executable "${app[@]}"
    bool['tmp_genome_fasta_file']=0
    bool['tmp_gtf_file']=0
    # e.g. 'GRCh38.primary_assembly.genome.fa.gz'
    dict['genome_fasta_file']=''
    # e.g. 'gencode.v39.annotation.gtf.gz'
    dict['gtf_file']=''
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=10
    # e.g. 'rsem-index'.
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "RSEM requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_file \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    dict['genome_fasta_file']="$(_koopa_realpath "${dict['genome_fasta_file']}")"
    dict['gtf_file']="$(_koopa_realpath "${dict['gtf_file']}")"
    _koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Generating RSEM index at '${dict['output_dir']}'."
    if _koopa_is_compressed_file "${dict['genome_fasta_file']}"
    then
        bool['tmp_genome_fasta_file']=1
        dict['tmp_genome_fasta_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['genome_fasta_file']}" \
            --output-file="${dict['tmp_genome_fasta_file']}"
        dict['genome_fasta_file']="${dict['tmp_genome_fasta_file']}"
    fi
    if _koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(_koopa_tmp_file_in_wd)"
        _koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    index_args+=(
        '--gtf' "${dict['gtf_file']}"
        '--num-threads' "${dict['threads']}"
        "${dict['genome_fasta_file']}"
        'rsem'
    )
    _koopa_dl 'Index args' "${index_args[*]}"
    (
        _koopa_cd "${dict['output_dir']}"
        "${app['rsem_prepare_reference']}" "${index_args[@]}"
    )
    if [[ "${bool['tmp_genome_fasta_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['genome_fasta_file']}"
    fi
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        _koopa_rm "${dict['gtf_file']}"
    fi
    _koopa_alert_success "RSEM index created at '${dict['output_dir']}'."
    return 0
}
