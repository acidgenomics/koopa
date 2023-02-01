#!/usr/bin/env bash

# FIXME Can rework to extract the FASTA and GTF into the tmp_dir instead.
# FIXME Need to use full path of outputdir here...
# FIXME Consider extracting the annotation files into _STARtmp folder?

koopa_star_index() {
    # """
    # Create a genome index for STAR aligner.
    # @note Updated 2023-02-01.
    #
    # Doesn't currently support compressed files as input.
    #
    # Try using 'r5a.2xlarge' on AWS EC2.
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
    local app dict index_args
    declare -A app=(
        ['star']="$(koopa_locate_star)"
    )
    [[ -x "${app['star']}" ]] || return 1
    declare -A dict=(
        # e.g. 'GRCh38.primary_assembly.genome.fa.gz'
        ['genome_fasta_file']=''
        # e.g. 'gencode.v39.annotation.gtf.gz'
        ['gtf_file']=''
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=60
        # e.g. 'star-index'.
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
        koopa_stop "STAR 'genomeGenerate' mode requires \
${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    dict['genome_fasta_file']="$(koopa_realpath "${dict['genome_fasta_file']}")"
    dict['gtf_file']="$(koopa_realpath "${dict['gtf_file']}")"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    koopa_alert "Generating STAR index at '${dict['output_dir']}'."
    dict['build_name']="$(koopa_basename "${dict['output_dir']}")"
    dict['tmp_genome_fasta_file']="${dict['tmp_dir']}/genome.fa"
    dict['tmp_gtf_file']="${dict['tmp_dir']}/annotation.gtf"
    koopa_decompress \
        "${dict['genome_fasta_file']}" \
        "${dict['tmp_genome_fasta_file']}"
    koopa_decompress \
        "${dict['gtf_file']}" \
        "${dict['tmp_gtf_file']}"
    index_args+=(
        '--genomeDir' "${dict['build_name']}/"
        '--genomeFastaFiles' "${dict['tmp_genome_fasta_file']}"
        '--runMode' 'genomeGenerate'
        '--runThreadN' "${dict['threads']}"
        '--sjdbGTFfile' "${dict['tmp_gtf_file']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    (
        koopa_cd "${dict['tmp_dir']}"
        "${app['star']}" "${index_args[@]}"
        koopa_cp "${dict['build_name']}" "${dict['output_dir']}"
    )
    # FIXME Re-enable this after successful indexing.
    # > koopa_rm "${dict['tmp_dir']}"
    koopa_alert_success "STAR index created at '${dict['output_dir']}'."
    return 0
}
