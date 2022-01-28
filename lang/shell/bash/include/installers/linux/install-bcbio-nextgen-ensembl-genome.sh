#!/usr/bin/env bash

koopa:::linux_install_bcbio_nextgen_ensembl_genome() { # {{{1
    # """
    # Install bcbio-nextgen genome from Ensembl.
    # @note Updated 2022-01-28.
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
    # declare -A dict=(
    #     [genome_build]='GRCh38'
    #     [organism]='Homo sapiens'
    #     [release]='102'
    # )
    # download-ensembl-genome \
    #     --genome_build="${dict[genome_build]}" \
    #     --organism="${dict[organism]}" \
    #     --release="${dict[release]}"
    #
    # declare -A dict2=(
    #     [genome_dir]='homo-sapiens-grch38-ensembl-102'
    # )
    # # bcbio expects the genome FASTA, not the transcriptome.
    # dict2[fasta_file]="${genome_dir}/genome/
    #     Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
    # # GTF is easier to parse than GFF3.
    # dict2[gtf_file]="${genome_dir}/annotation/gtf/
    #     Homo_sapiens.GRCh38.102.gtf.gz"
    #
    # # Now we're ready to call the install script.
    # koopa install bcbio-nextgen-ensembl-genome \
    #     --fasta-file="${dict2[fasta_file]}" \
    #     --genome-build="${dict[genome_build]}" \
    #     --gtf-file="${dict2[gtf_file]}" \
    #     --index='bowtie2' \
    #     --index='seq' \
    #     --index='star' \
    #     --organism="${dict[organism]}" \
    #     --release="${dict[release]}"
    # """
    local app dict indexes
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    declare -A app=(
        [bcbio_setup_genome]='bcbio_setup_genome.py'
        [sed]="$(koopa::locate_sed)"
        [touch]="$(koopa::locate_touch)"
    )
    declare -A dict=(
        [cores]="$(koopa::cpu_count)"
        [fasta_file]=''
        [genome_build]=''
        [gtf_file]=''
        [organism]=''
        [organism_pattern]='^([A-Z][a-z]+)(\s|_)([a-z]+)$'
        [provider]='Ensembl'
        [release]=''
    )
    indexes=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fasta-file='*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict[fasta_file]="${2:?}"
                shift 2
                ;;
            '--genome-build='*)
                dict[genome_build]="${1#*=}"
                shift 1
                ;;
            '--genome-build')
                dict[genome_build]="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict[gtf_file]="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict[gtf_file]="${2:?}"
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
                dict[organism]="${1#*=}"
                shift 1
                ;;
            '--organism')
                dict[organism]="${2:?}"
                shift 2
                ;;
            '--release='*)
                dict[release]="${1#*=}"
                shift 1
                ;;
            '--release')
                dict[release]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set \
        '--fasta-file' "${dict[fasta_file]}" \
        '--genome-build' "${dict[genome_build]}" \
        '--gtf-file' "${dict[gtf_file]}" \
        '--index' "${indexes[*]}" \
        '--organism' "${dict[organism]}" \
        '--release' "${dict[release]}"
    koopa::activate_bcbio_nextgen
    koopa::assert_is_installed "${app[bcbio_setup_genome]}"
    koopa::assert_is_file "${dict[fasta_file]}" "${dict[gtf_file]}"
    dict[fasta_file]="$(koopa::realpath "${dict[fasta_file]}")"
    dict[gtf_file]="$(koopa::realpath "${dict[gtf_file]}")"
    # Check for valid organism input.
    if ! koopa::str_detect_regex "${dict[organism]}" "${dict[organism_pattern]}"
    then
        koopa::stop "Invalid organism: '${dict[organism]}'."
    fi
    # e.g. "Ensembl 102".
    dict[build_version]="${dict[provider]}_${dict[release]}"
    # e.g. "GRCh38_Ensembl_102".
    dict[bcbio_genome_name]="${dict[build]} ${dict[provider]} ${dict[release]}"
    dict[bcbio_genome_name]="${dict[bcbio_genome_name]// /_}"
    koopa::alert_install_start "${dict[bcbio_genome_name]}"
    # e.g. 'Hsapiens'.
    dict[bcbio_species_dir]="$( \
        koopa::print "${dict[organism]// /_}" \
            | "${app[sed]}" -r 's/^([A-Z])[a-z]+_([a-z]+)$/\1\2/g' \
    )"
    # Ensure Galaxy is configured correctly for a clean bcbio install.
    # Recursive up from 'install/anaconda/bin/bcbio_setup_genome.py'.
    dict[install_prefix]="$(koopa::parent_dir --num=3 "${dict[script]}")"
    # If the 'sam_fa_indices.loc' file is missing, the script will error.
    dict[tool_data_prefix]="${dict[install_prefix]}/galaxy/tool-data"
    koopa::mkdir "${dict[tool_data_prefix]}"
    "${app[touch]}" "${dict[tool_data_prefix]}/sam_fa_indices.log"
    # This step will download cloudbiolinux, so migrating to a temporary
    # directory is helpful, to avoid clutter.
    koopa::dl \
        'FASTA file' "${dict[fasta_file]}" \
        'GTF file' "${dict[gtf_file]}" \
        'Indexes' "${indexes[*]}"
    # Note that '--buildversion' was added in 2021 and is now required.
    "${app[bcbio_setup_genome]}" \
        --build "${dict[bcbio_genome_name]}" \
        --buildversion "${dict[build_version]}" \
        --cores "${dict[cores]}" \
        --fasta "${dict[fasta_file]}" \
        --gtf "${dict[gtf_file]}" \
        --indexes "${indexes[@]}" \
        --name "${dict[bcbio_species_dir]}"
    koopa::alert_install_success "${dict[bcbio_genome_name]}"
    return 0
}
