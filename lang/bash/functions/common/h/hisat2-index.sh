#!/usr/bin/env bash

# FIXME HISAT2 includes 'hisat2_extract_exons.py' that does this.
# FIXME HISAT2 includes 'hisat2_extract_splice_sites.py' which does this.
# FIXME Need to include splice site info:
# > hisat2_extract_splice_sites.py Homo_sapiens.GRCh38.86.gtf > splicesites.tsv
# > hisat2_extract_exons.py Homo_sapiens.GRCh38.86.gtf > exons.tsv
# > hisat2-build -p 4 --ss splicesites.tsv --exon exons.tsv Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa Homo_sapiens.GRCh38.dna_sm.primary_assembly

koopa_hisat2_index() {
    # """
    # Create a genome index for HISAT2 aligner.
    # @note Updated 2023-10-18.
    #
    # Doesn't currently support compressed files as input.
    #
    # Try using 'r6a.8xlarge' or 'r5a.8xlarge' instance on AWS EC2.
    #
    # If you use '--snp', '--ss', and/or '--exon', hisat2-build will need about
    # 200 GB RAM for the human genome size as index building involves a graph
    # construction. Otherwise, you will be able to build an index on your
    # desktop with 8 GB RAM.
    #
    # @seealso
    # - hisat2-build --help
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
    koopa_assert_is_executable "${app[@]}"
    # e.g. 'GRCh38.primary_assembly.genome.fa.gz'
    dict['genome_fasta_file']=''
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
    koopa_assert_is_file "${dict['genome_fasta_file']}"
    koopa_assert_is_matching_regex \
        --pattern='\.fa\.gz$' \
        --string="${dict['genome_fasta_file']}"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    koopa_alert "Generating HISAT2 index at '${dict['output_dir']}'."
    # FIXME Need to prepare splice sites and exons here.
    # > hisat2_extract_splice_sites.py Homo_sapiens.GRCh38.86.gtf > splicesites.tsv
    # > hisat2_extract_exons.py Homo_sapiens.GRCh38.86.gtf > exons.tsv
    # FIXME Need to set '--ss' here.
    # FIXME Need to set '--exons' here.
    index_args+=(
        '--seed' "${dict['seed']}"
        '-f'
        '-p' "${dict['threads']}"
        "${dict['genome_fasta_file']}"
        "${dict['ht2_base']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app['hisat2_build']}" "${index_args[@]}"
    koopa_alert_success "HISAT2 index created at '${dict['output_dir']}'."
    return 0
}
