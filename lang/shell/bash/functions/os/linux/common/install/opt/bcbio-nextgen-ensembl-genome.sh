#!/usr/bin/env bash

koopa::linux_install_bcbio_nextgen_ensembl_genome() { # {{{1
    # """
    # Install bcbio-nextgen genome from Ensembl.
    # @note Updated 2021-09-21.
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
    local bcbio_genome_name bcbio_species_dir build cores fasta gtf indexes
    local install_prefix organism provider release script sed tee tmp_dir
    local tool_data_prefix
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    koopa::activate_bcbio_nextgen
    script='bcbio_setup_genome.py'
    koopa::assert_is_installed "$script"
    sed="$(koopa::locate_sed)"
    tee="$(koopa::locate_tee)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--build='*)
                build="${1#*=}"
                shift 1
                ;;
            '--build')
                build="${2:?}"
                shift 2
                ;;
            '--fasta='*)
                fasta="${1#*=}"
                shift 1
                ;;
            '--fasta')
                fasta="${2:?}"
                shift 2
                ;;
            '--gtf='*)
                gtf="${1#*=}"
                shift 1
                ;;
            '--gtf')
                gtf="${2:?}"
                shift 2
                ;;
            '--indexes='*)
                indexes="${1#*=}"
                shift 1
                ;;
            '--indexes')
                indexes="${2:?}"
                shift 2
                ;;
            '--organism='*)
                organism="${1#*=}"
                shift 1
                ;;
            '--organism')
                organism="${2:?}"
                shift 2
                ;;
            '--release='*)
                release="${1#*=}"
                shift 1
                ;;
            '--release')
                release="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    [[ -z "${indexes:-}" ]] && indexes='bowtie2 seq star'
    koopa::assert_is_set 'build' 'fasta' 'gtf' 'indexes' 'organism' 'release'
    koopa::assert_is_file "$fasta" "$gtf"
    script="$(koopa::which_realpath "$script")"
    fasta="$(koopa::realpath "$fasta")"
    gtf="$(koopa::realpath "$gtf")"
    # Convert space-delimited string to array.
    IFS=" " read -r -a indexes <<< "$indexes"
    # Check for valid organism input.
    if ! koopa::str_match_regex "$organism" '^([A-Z][a-z]+)(\s|_)([a-z]+)$'
    then
        koopa::stop "Invalid organism: '${organism}'."
    fi
    provider='Ensembl'
    # e.g. "GRCh38_Ensembl_102".
    bcbio_genome_name="${build} ${provider} ${release}"
    bcbio_genome_name="${bcbio_genome_name// /_}"
    koopa::install_start "$bcbio_genome_name"
    # e.g. 'Hsapiens'.
    bcbio_species_dir="$( \
        koopa::print "${organism// /_}" \
            | "$sed" -r 's/^([A-Z])[a-z]+_([a-z]+)$/\1\2/g' \
    )"
    tmp_dir="$(koopa::tmp_dir)"
    cores="$(koopa::cpu_count)"
    # Ensure Galaxy is configured correctly for a clean bcbio install.
    # Recursive up from 'install/anaconda/bin/bcbio_setup_genome.py'.
    install_prefix="$(koopa::parent_dir --num=3 "$script")"
    # If the 'sam_fa_indices.loc' file is missing, the script will error.
    tool_data_prefix="${install_prefix}/galaxy/tool-data"
    koopa::mkdir "$tool_data_prefix"
    touch "${tool_data_prefix}/sam_fa_indices.log"
    (
        # This step will download cloudbiolinux, so migrating to a temporary
        # directory is helpful, to avoid clutter.
        set -x
        koopa::cd "$tmp_dir"
        koopa::dl \
            'FASTA file' "$fasta" \
            'GTF file' "$gtf" \
            'Indexes' "${indexes[*]}"
        # Note that '--buildversion' was added in 2021 and is now required.
        "$script" \
            --build "$bcbio_genome_name" \
            --buildversion "${provider}_${release}" \
            --cores "$cores" \
            --fasta "$fasta" \
            --gtf "$gtf" \
            --indexes "${indexes[@]}" \
            --name "$bcbio_species_dir"
        set +x
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$bcbio_genome_name"
    return 0
}
