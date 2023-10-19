#!/usr/bin/env bash

koopa_star_index() {
    # """
    # Create a genome index for STAR aligner.
    # @note Updated 2023-10-18.
    #
    # Doesn't currently support compressed files as input.
    #
    # Try using 'r6a.2xlarge' on AWS EC2.
    #
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     ngsalign/star.py
    # - https://github.com/nf-core/rnaseq/blob/master/modules/local/
    #     star_genomegenerate.nf
    #
    # @examples
    # > koopa_star_index \
    # >     --genome-fasta-file='GRCh38.primary_assembly.genome.fa.gz' \
    # >     --gtf-file='gencode.v39.annotation.gtf.gz' \
    # >     --output-dir='star-index'
    # """
    local -A app bool dict
    local -a index_args
    app['star']="$(koopa_locate_star)"
    koopa_assert_is_executable "${app[@]}"
    bool['is_tmp_genome_fasta_file']=0
    bool['is_tmp_gtf_file']=0
    dict['compress_ext_pattern']="$(koopa_compress_ext_pattern)"
    # e.g. 'GRCh38.primary_assembly.genome.fa.gz'
    dict['genome_fasta_file']=''
    # e.g. 'gencode.v39.annotation.gtf.gz'
    dict['gtf_file']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=60
    # e.g. 'star-index'.
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
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
        koopa_stop "STAR 'genomeGenerate' mode requires \
${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    dict['genome_fasta_file']="$(koopa_realpath "${dict['genome_fasta_file']}")"
    dict['gtf_file']="$(koopa_realpath "${dict['gtf_file']}")"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Generating STAR index at '${dict['output_dir']}'."
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
    # Consider erroring instead of merely warning on ALT contig detection,
    # similar to bcbio-nextgen. Currently applies to RefSeq FASTA.
    if koopa_fasta_has_alt_contigs "${dict['tmp_genome_fasta_file']}"
    then
        koopa_warn "ALT contigs detected in '${dict['genome_fasta_file']}'."
    fi
    # Refer to '--limitGenomeGenerateRAM' for memory optimization.
    index_args+=(
        '--genomeDir' "$(koopa_basename "${dict['output_dir']}")"
        '--genomeFastaFiles' "${dict['tmp_genome_fasta_file']}"
        '--runMode' 'genomeGenerate'
        '--runThreadN' "${dict['threads']}"
        '--sjdbGTFfile' "${dict['tmp_gtf_file']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    (
        koopa_cd "$(koopa_dirname "${dict['output_dir']}")"
        koopa_rm "${dict['output_dir']}"
        "${app['star']}" "${index_args[@]}"
        koopa_rm '_STARtmp'
    )
    [[ "${bool['is_tmp_genome_fasta_file']}" -eq 1 ]] && \
        koopa_rm "${dict['tmp_genome_fasta_file']}"
    [[ "${bool['is_tmp_gtf_file']}" -eq 1 ]] && \
        koopa_rm "${dict['tmp_gtf_file']}"
    koopa_alert_success "STAR index created at '${dict['output_dir']}'."
    return 0
}
