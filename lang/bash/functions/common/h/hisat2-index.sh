#!/usr/bin/env bash

koopa_hisat2_index() {
    # """
    # Create a genome index for HISAT2 aligner.
    # @note Updated 2023-10-18.
    #
    # HISAT2 comes with several index types:
    # - Hierarchical FM index (HFM) for a reference genome (index base: genome).
    # - Hierarchical Graph FM index (HGFM) for a reference genome plus SNPs
    #   (index base: genome_snp).
    # - Hierarchical Graph FM index (HGFM) for a reference genome plus
    #   transcripts (index base: genome_tran).
    # - Hierarchical Graph FM index (HGFM) for a reference genome plus SNPs and
    #   transcripts (index base: genome_snp_tran).
    #
    # Try using 'r6a.8xlarge' or 'r5a.8xlarge' instance on AWS EC2.
    #
    # Doesn't currently support compressed files as input.
    #
    # If you use '--snp', '--ss', and/or '--exon', hisat2-build will need about
    # 200 GB RAM for the human genome size as index building involves a graph
    # construction. Otherwise, you will be able to build an index on your
    # desktop with 8 GB RAM.
    #
    # @seealso
    # - hisat2-build --help
    # - http://daehwankimlab.github.io/hisat2/howto/
    # - https://daehwankimlab.github.io/hisat2/manual/
    # - https://daehwankimlab.github.io/hisat2/download/#h-sapiens
    # - https://www.biostars.org/p/286647/
    # - https://github.com/nf-core/rnaseq/blob/master/modules/nf-core/
    #     modules/hisat2/build/main.nf
    # - https://github.com/chapmanb/cloudbiolinux/blob/master/utils/
    #     prepare_tx_gff.py
    # - https://rnabio.org/module-01-inputs/0001/04/01/Indexing/
    # """
    local -A app dict
    local -a index_args
    app['hisat2_build']="$(koopa_locate_hisat2_build)"
    app['hisat2_extract_exons']="$(koopa_locate_hisat2_extract_exons)"
    app['hisat2_extract_splice_sites']="$( \
        koopa_locate_hisat2_extract_splice_sites \
    )"
    koopa_assert_is_executable "${app[@]}"
    dict['compress_ext_pattern']="$(koopa_compress_ext_pattern)"
    # e.g. 'GRCh38.primary_assembly.genome.fa.gz'
    dict['genome_fasta_file']=''
    # e.g. 'gencode.v39.annotation.gtf.gz'
    dict['gtf_file']=''
    # FIXME Rework this as 'bool' instead of 'dict'.
    dict['is_tmp_genome_fasta_file']=0
    dict['is_tmp_gtf_file']=0
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=160
    dict['output_dir']=''
    dict['seed']=42
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
        '--output-dir' "${dict['output_dir']}"
    dict['ht2_base']="${dict['output_dir']}/index"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "'hisat2-build' requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    dict['genome_fasta_file']="$(koopa_realpath "${dict['genome_fasta_file']}")"
    dict['gtf_file']="$(koopa_realpath "${dict['gtf_file']}")"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Generating HISAT2 index at '${dict['output_dir']}'."
    if koopa_str_detect_regex \
        --string="${dict['genome_fasta_file']}" \
        --pattern="${dict['compress_ext_pattern']}"
    then
        dict['is_tmp_genome_fasta_file']=1
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
        dict['is_tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(koopa_tmp_file)"
        koopa_decompress \
            "${dict['gtf_file']}" \
            "${dict['tmp_gtf_file']}"
    else
        dict['tmp_gtf_file']="${dict['gtf_file']}"
    fi
    dict['exons_file']="${dict['output_dir']}/exons.tsv"
    dict['splice_sites_file']="${dict['output_dir']}/splicesites.tsv"
    "${app['hisat2_extract_exons']}" \
        "${dict['tmp_gtf_file']}" \
        > "${dict['exons_file']}"
    "${app['hisat2_extract_splice_sites']}" \
        "${dict['tmp_gtf_file']}" \
        > "${dict['splice_sites_file']}"
    index_args+=(
        '-p' "${dict['threads']}"
        '--exons' "${dict['exons_file']}"
        '--seed' "${dict['seed']}"
        '--ss' "${dict['splice_sites_file']}"
        "${dict['genome_fasta_file']}"
        "${dict['ht2_base']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app['hisat2_build']}" "${index_args[@]}"
    [[ "${dict['is_tmp_genome_fasta_file']}" -eq 1 ]] && \
        koopa_rm "${dict['tmp_genome_fasta_file']}"
    [[ "${dict['is_tmp_gtf_file']}" -eq 1 ]] && \
        koopa_rm "${dict['tmp_gtf_file']}"
    koopa_alert_success "HISAT2 index created at '${dict['output_dir']}'."
    return 0
}
