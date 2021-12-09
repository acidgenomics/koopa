#!/usr/bin/env bash

# FIXME Rework the '--indexes' approach to use '--index' multiple times instead.
# FIXME Rework using app and dict approach.
# FIXME Consider wrapping this in our 'install_app' call.
koopa::linux_install_bcbio_nextgen_ensembl_genome() { # {{{1
    # """
    # Install bcbio-nextgen genome from Ensembl.
    # @note Updated 2021-12-09.
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
    # Ensure bcbio is in PATH.
    # export PATH="/opt/koopa/opt/bcbio-nextgen/tools/bin:${PATH}"
    # organism='Homo sapiens'
    # build='GRCh38'
    # release='102'
    # download-ensembl-genome \
    #     --organism="$organism" \
    #     --build="$build" \
    #     --release="$release"
    # genome_dir='homo-sapiens-grch38-ensembl-102'
    # # bcbio expects the genome FASTA, not the transcriptome.
    # fasta="${genome_dir}/genome/
    #     Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
    # # GTF is easier to parse than GFF3.
    # gtf="${genome_dir}/annotation/gtf/Homo_sapiens.GRCh38.102.gtf.gz"
    # # Now we're ready to call the install script.
    # koopa install bcbio-nextgen-ensembl-genome \
    #     --build="$build" \
    #     --fasta="$fasta" \
    #     --gtf="$gtf" \
    #     --indexes="bowtie2 seq star" \
    #     --organism="$organism" \
    #     --release="$release"
    # """
    local app dict indexes
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    declare -A app=(
        [bcbio_setup_genome]='bcbio_setup_genome.py'
        [sed]="$(koopa::locate_sed)"
        [tee]="$(koopa::locate_tee)"
        [touch]="$(koopa::locate_touch)"
    )
    declare -A dict=(
        [build]=''
        [cores]="$(koopa::cpu_count)"
        [fasta]=''
        [gtf]=''
        [indexes]='bowtie2 seq star'
        [organism]=''
        [release]=''
        [tmp_dir]="$(koopa::tmp_dir)"
        [tmp_log_file]="$(koopa::tmp_log_file)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--build='*)
                dict[build]="${1#*=}"
                shift 1
                ;;
            '--build')
                dict[build]="${2:?}"
                shift 2
                ;;
            '--fasta='*)
                dict[fasta]="${1#*=}"
                shift 1
                ;;
            '--fasta')
                dict[fasta]="${2:?}"
                shift 2
                ;;
            '--gtf='*)
                dict[gtf]="${1#*=}"
                shift 1
                ;;
            '--gtf')
                dict[gtf]="${2:?}"
                shift 2
                ;;
            '--indexes='*)
                dict[indexes]="${1#*=}"
                shift 1
                ;;
            '--indexes')
                dict[indexes]="${2:?}"
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
        '--build' "${dict[build]}" \
        '--fasta' "${dict[fasta]}" \
        '--gtf' "${dict[gtf]}" \
        '--indexes' "${dict[indexes]}" \
        '--organism' "${dict[organism]}" \
        '--release' "${dict[release]}"
    koopa::activate_bcbio_nextgen
    koopa::assert_is_installed "${app[bcbio_setup_genome]}"
    koopa::assert_is_file "${dict[fasta]}" "${dict[gtf]}"
    dict[fasta]="$(koopa::realpath "${dict[fasta]}")"
    dict[gtf]="$(koopa::realpath "${dict[gtf]}")"
    # Convert space-delimited string to array.
    IFS=" " read -r -a indexes <<< "${dict[indexes]}"
    # Check for valid organism input.
    if ! koopa::str_match_regex \
        "${dict[organism]}" \
        '^([A-Z][a-z]+)(\s|_)([a-z]+)$'
    then
        koopa::stop "Invalid organism: '${dict[organism]}'."
    fi
    dict[provider]='Ensembl'
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
    koopa::mkdir "$tool_data_prefix"
    "${app[touch]}" "${tool_data_prefix}/sam_fa_indices.log"
    (
        # This step will download cloudbiolinux, so migrating to a temporary
        # directory is helpful, to avoid clutter.
        set -x
        koopa::cd "${dict[tmp_dir]}"
        koopa::dl \
            'FASTA file' "$fasta" \
            'GTF file' "$gtf" \
            'Indexes' "${indexes[*]}"
        # Note that '--buildversion' was added in 2021 and is now required.
        "${app[bcbio_setup_genome]}" \
            --build "$bcbio_genome_name" \
            --buildversion "${provider}_${release}" \
            --cores "${dict[cores]}" \
            --fasta "$fasta" \
            --gtf "$gtf" \
            --indexes "${indexes[@]}" \
            --name "$bcbio_species_dir"
    ) 2>&1 | "${app[tee]}" "${dict[tmp_log_file]}"
    koopa::rm "${dict[tmp_dir]}"
    koopa::alert_install_success "${dict[bcbio_genome_name]}"
    return 0
}
