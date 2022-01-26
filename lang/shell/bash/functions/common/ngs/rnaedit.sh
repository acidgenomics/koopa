#!/usr/bin/env bash

# NOTE Need to migrate these functions to r-koopa.

koopa::run_rnaeditingindexer() { # {{{1
    # """
    # Run RNAEditingIndexer.
    # @note Updated 2021-09-21.
    #
    # Genome must be indexed by BEDGenomeIndexer.
    # Note that '--verbose' flag includes more output in summary CSV.
    #
    # @seealso
    # - https://github.com/a2iEditing/RNAEditingIndexer/blob/master/Docs/
    #       Docker.README.md
    # - https://github.com/a2iEditing/RNAEditingIndexer/
    #       search?q=index+file&unscoped_q=index+file
    # """
    local bam_dir bam_suffix bam_suffix_arr example genome output_dir
    koopa::assert_is_installed 'docker'
    bam_dir='bam'
    bam_suffix='.Aligned.sortedByCoord.out.bam'
    genome='hg38'
    output_dir='rnaedit'
    example=0
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bam-dir='*)
                bam_dir="${1#*=}"
                shift 1
                ;;
            '--bam-dir')
                bam_dir="${2:?}"
                shift 2
                ;;
            '--genome='*)
                genome="${1#*=}"
                shift 1
                ;;
            '--genome')
                genome="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                output_dir="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                output_dir="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--example')
                example=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    # Ensure 'bam_dir' and 'output_dir' are absolute paths, otherwise
    # RNAEditingIndex can fail on relative paths.
    bam_dir="$(koopa::which_realpath "$bam_dir")"
    output_dir="$(koopa::which_realpath "$output_dir")"
    koopa::rm "$output_dir"
    koopa::mkdir "$output_dir"
    mnt_bam_dir='/mnt/bam'
    mnt_output_dir='/mnt/output'
    # Minimal example:
    if [[ "$example" -eq 1 ]]
    then
        bam_dir='/bin/AEI/RNAEditingIndexer/TestResources/BAMs'
        bam_suffix_arr=(
            '_sampled_with_0.1'
            'Aligned'
            'sortedByCoord'
            'out'
            'bam'
            'AluChr1Only'
            'bam'
        )
        bam_suffix="$(koopa::paste --sep='.' "${bam_suffix_arr[@]}")"
    fi
    # Note that genome indexing to generate 'ucscHg38Genome.fa.fai' is currently
    # failing due to root permission requirement.
    # Otherwise, set permissions as current user for better output.
    docker run \
        -v "${bam_dir}:${mnt_bam_dir}:ro" \
        -v "${output_dir}:${mnt_output_dir}:rw" \
        'acidgenomics/rnaeditingindexer' \
        RNAEditingIndex \
            --genome "$genome" \
            --keep_cmpileup \
            --verbose \
            -d "$mnt_bam_dir" \
            -f "$bam_suffix" \
            -l "${mnt_output_dir}/logs" \
            -o "${mnt_output_dir}/cmpileups" \
            -os "${mnt_output_dir}/summary"
    return 0
}

