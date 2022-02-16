#!/usr/bin/env bash

koopa::run_rnaeditingindexer() { # {{{1
    # """
    # Run dockerized RNAEditingIndexer pipeline.
    # @note Updated 2022-02-16.
    #
    # Genome must be indexed by BEDGenomeIndexer.
    # Note that '--verbose' flag includes more output in summary CSV.
    #
    # Genome indexing to generate 'ucscHg38Genome.fa.fai' is currently failing
    # due to root permission requirement. Otherwise, set permissions as current
    # user for better output.
    #
    # @seealso
    # - https://github.com/a2iEditing/RNAEditingIndexer/blob/master/Docs/
    #       Docker.README.md
    # - https://github.com/a2iEditing/RNAEditingIndexer/
    #       search?q=index+file&unscoped_q=index+file
    # - https://hub.docker.com/r/acidgenomics/rnaeditingindexer
    #
    # @examples
    # > koopa::run_rnaeditingindexer --example
    # """
    local app dict
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
    )
    declare -A dict=(
        [bam_dir]='bam'
        [bam_suffix]='.Aligned.sortedByCoord.out.bam'
        [docker_image]='acidgenomics/rnaeditingindexer'
        [example]=0
        [genome]='hg38'
        [mnt_bam_dir]='/mnt/bam'
        [mnt_output_dir]='/mnt/output'
        [output_dir]='rnaedit'
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bam-dir='*)
                dict[bam_dir]="${1#*=}"
                shift 1
                ;;
            '--bam-dir')
                dict[bam_dir]="${2:?}"
                shift 2
                ;;
            '--genome='*)
                dict[genome]="${1#*=}"
                shift 1
                ;;
            '--genome')
                dict[genome]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--example')
                dict[example]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${dict[example]}" -eq 1 ]]
    then
        dict[bam_dir]='/bin/AEI/RNAEditingIndexer/TestResources/BAMs'
        dict[bam_suffix]="_sampled_with_0.1.Aligned.sortedByCoord.out\
.bam.AluChr1Only.bam"
    else
        koopa::assert_is_dir "${dict[bam_dir]}"
        dict[bam_dir]="$(koopa::realpath "${dict[bam_dir]}")"
    fi
    koopa::rm "${dict[output_dir]}"
    dict[output_dir]="$(koopa::init_dir "${dict[output_dir]}")"
    "${app[docker]}" run \
        -v "${dict[bam_dir]}:${dict[mnt_bam_dir]}:ro" \
        -v "${dict[output_dir]}:${dict[mnt_output_dir]}:rw" \
        "${dict[docker_image]}" \
        RNAEditingIndex \
            --genome "${dict[genome]}" \
            --keep_cmpileup \
            --verbose \
            -d "${dict[mnt_bam_dir]}" \
            -f "${dict[bam_suffix]}" \
            -l "${dict[mnt_output_dir]}/logs" \
            -o "${dict[mnt_output_dir]}/cmpileups" \
            -os "${dict[mnt_output_dir]}/summary"
    return 0
}

