#!/usr/bin/env bash

koopa_linux_bcbio_nextgen_add_ensembl_genome() {
    # """
    # Install bcbio-nextgen genome from Ensembl.
    # @note Updated 2023-04-05.
    #
    # This script can fail on a clean bcbio install if this file is missing:
    # 'install/galaxy/tool-data/sam_fa_indices.loc'.
    #
    # @section Genome download:
    #
    # Use the 'download-ensembl-genome' script to simplify this step.
    # This script prepares top-level standardized files named 'genome.fa.gz'
    # (FASTA) and 'annotation.gtf.gz' (GTF) that we can pass to bcbio script.
    #
    # @examples
    # > local -A dict
    # > dict['genome_build']='GRCh38'
    # > dict['organism']='Homo sapiens'
    # > dict['release']='102'
    # > koopa_download_ensembl_genome \
    # >     --genome_build="${dict['genome_build']}" \
    # >     --organism="${dict['organism']}" \
    # >     --release="${dict['release']}"
    # > local -A dict2
    # > dict2['genome_dir']='homo-sapiens-grch38-ensembl-102'
    # # bcbio expects the genome FASTA, not the transcriptome.
    # > dict2['fasta_file']="${genome_dir}/genome/
    # >     Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
    # # GTF is easier to parse than GFF3.
    # > dict2['gtf_file']="${genome_dir}/annotation/gtf/
    # >     Homo_sapiens.GRCh38.102.gtf.gz"
    # # Now we're ready to call the install script.
    # > koopa_linux_bcbio_nextgen_add_ensembl_genome \
    # >     --fasta-file="${dict2['fasta_file']}" \
    # >     --genome-build="${dict['genome_build']}" \
    # >     --gtf-file="${dict2['gtf_file']}" \
    # >     --index='bowtie2' \
    # >     --index='seq' \
    # >     --index='star' \
    # >     --organism="${dict['organism']}" \
    # >     --release="${dict['release']}"
    # """
    local -A app dict
    local -a indexes
    koopa_assert_has_args "$#"
    app['bcbio_setup_genome']="$(koopa_linux_locate_bcbio_setup_genome)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    app['touch']="$(koopa_locate_touch)"
    koopa_assert_is_executable "${app[@]}"
    dict['cores']="$(koopa_cpu_count)"
    dict['fasta_file']=''
    dict['genome_build']=''
    dict['gtf_file']=''
    dict['organism']=''
    dict['organism_pattern']='^([A-Z][a-z]+)(\s|_)([a-z]+)$'
    dict['provider']='Ensembl'
    dict['release']=''
    indexes=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fasta-file='*)
                dict['fasta_file']="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict['fasta_file']="${2:?}"
                shift 2
                ;;
            '--genome-build='*)
                dict['genome_build']="${1#*=}"
                shift 1
                ;;
            '--genome-build')
                dict['genome_build']="${2:?}"
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
            '--indexes='*)
                indexes+=("${1#*=}")
                shift 1
                ;;
            '--indexes')
                indexes+=("${2:?}")
                shift 2
                ;;
            '--organism='*)
                dict['organism']="${1#*=}"
                shift 1
                ;;
            '--organism')
                dict['organism']="${2:?}"
                shift 2
                ;;
            '--release='*)
                dict['release']="${1#*=}"
                shift 1
                ;;
            '--release')
                dict['release']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fasta-file' "${dict['fasta_file']}" \
        '--genome-build' "${dict['genome_build']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--index' "${indexes[*]}" \
        '--organism' "${dict['organism']}" \
        '--release' "${dict['release']}"
    koopa_assert_is_file "${dict['fasta_file']}" "${dict['gtf_file']}"
    dict['fasta_file']="$(koopa_realpath "${dict['fasta_file']}")"
    dict['gtf_file']="$(koopa_realpath "${dict['gtf_file']}")"
    # Check for valid organism input.
    if ! koopa_str_detect_regex \
        --string="${dict['organism']}" \
        --pattern="${dict['organism_pattern']}"
    then
        koopa_stop "Invalid organism: '${dict['organism']}'."
    fi
    # e.g. "Ensembl 102".
    dict['build_version']="${dict['provider']}_${dict['release']}"
    # e.g. "GRCh38_Ensembl_102".
    dict['bcbio_genome_name']="${dict['build']} \
${dict['provider']} ${dict['release']}"
    dict['bcbio_genome_name']="${dict['bcbio_genome_name']// /_}"
    koopa_alert_install_start "${dict['bcbio_genome_name']}"
    # e.g. 'Hsapiens'.
    dict['bcbio_species_dir']="$( \
        koopa_print "${dict['organism']// /_}" \
            | "${app['sed']}" -E 's/^([A-Z])[a-z]+_([a-z]+)$/\1\2/g' \
    )"
    # Ensure Galaxy is configured correctly for a clean bcbio install.
    # Recursive up from 'install/anaconda/bin/bcbio_setup_genome.py'.
    dict['install_prefix']="$(koopa_parent_dir --num=3 "${dict['script']}")"
    # If the 'sam_fa_indices.loc' file is missing, the script will error.
    dict['tool_data_prefix']="${dict['install_prefix']}/galaxy/tool-data"
    koopa_mkdir "${dict['tool_data_prefix']}"
    "${app['touch']}" "${dict['tool_data_prefix']}/sam_fa_indices.log"
    # This step will download cloudbiolinux, so migrating to a temporary
    # directory is helpful, to avoid clutter.
    koopa_dl \
        'FASTA file' "${dict['fasta_file']}" \
        'GTF file' "${dict['gtf_file']}" \
        'Indexes' "${indexes[*]}"
    # Note that '--buildversion' was added in 2021 and is now required.
    "${app['bcbio_setup_genome']}" \
        --build "${dict['bcbio_genome_name']}" \
        --buildversion "${dict['build_version']}" \
        --cores "${dict['cores']}" \
        --fasta "${dict['fasta_file']}" \
        --gtf "${dict['gtf_file']}" \
        --indexes "${indexes[@]}" \
        --name "${dict['bcbio_species_dir']}"
    koopa_alert_install_success "${dict['bcbio_genome_name']}"
    return 0
}
