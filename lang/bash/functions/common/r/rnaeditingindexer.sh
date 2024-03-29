#!/usr/bin/env bash

koopa_rnaeditingindexer() {
    # """
    # Run dockerized RNAEditingIndexer pipeline.
    # @note Updated 2023-05-24.
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
    # > koopa_run_rnaeditingindexer --example
    # """
    local -A app dict
    local -a run_args
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    dict['bam_suffix']='.Aligned.sortedByCoord.out.bam'
    dict['docker_image']='public.ecr.aws/acidgenomics/rnaeditingindexer'
    dict['example']=0
    dict['genome']='hg38'
    dict['local_bam_dir']='bam'
    dict['local_output_dir']='rnaedit'
    dict['mnt_bam_dir']='/mnt/bam'
    dict['mnt_output_dir']='/mnt/output'
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bam-dir='*)
                dict['local_bam_dir']="${1#*=}"
                shift 1
                ;;
            '--bam-dir')
                dict['local_bam_dir']="${2:?}"
                shift 2
                ;;
            '--genome='*)
                dict['genome']="${1#*=}"
                shift 1
                ;;
            '--genome')
                dict['genome']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['local_output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['local_output_dir']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--example')
                dict['example']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    run_args=()
    if [[ "${dict['example']}" -eq 1 ]]
    then
        dict['bam_suffix']="_sampled_with_0.1.Aligned.sortedByCoord.out.\
bam.AluChr1Only.bam"
        dict['local_bam_dir']=''
        dict['mnt_bam_dir']='/bin/AEI/RNAEditingIndexer/TestResources/BAMs'
    else
        koopa_assert_is_dir "${dict['local_bam_dir']}"
        dict['local_bam_dir']="$(koopa_realpath "${dict['local_bam_dir']}")"
        koopa_rm "${dict['local_output_dir']}"
        dict['local_output_dir']="$( \
            koopa_init_dir "${dict['local_output_dir']}" \
        )"
        run_args+=(
            -v "${dict['local_bam_dir']}:${dict['mnt_bam_dir']}:ro"
            -v "${dict['local_output_dir']}:${dict['mnt_output_dir']}:rw"
        )
    fi
    run_args+=("${dict['docker_image']}")
    "${app['docker']}" run "${run_args[@]}" \
        RNAEditingIndex \
            --genome "${dict['genome']}" \
            --keep_cmpileup \
            --verbose \
            -d "${dict['mnt_bam_dir']}" \
            -f "${dict['bam_suffix']}" \
            -l "${dict['mnt_output_dir']}/logs" \
            -o "${dict['mnt_output_dir']}/cmpileups" \
            -os "${dict['mnt_output_dir']}/summary"
    return 0
}
