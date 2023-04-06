#!/usr/bin/env bash

koopa_linux_bcbio_nextgen_add_genome() {
    # """
    # Install a natively supported bcbio-nextgen genome (e.g. hg38).
    # @note Updated 2023-04-05.
    #
    # @examples
    # > koopa_linux_bcbio_nextgen_add_genome 'hg38' 'mm10'
    # """
    local -A app dict
    local -a bcbio_args
    local genome
    koopa_assert_has_args "$#"
    app['bcbio']="$(koopa_linux_locate_bcbio)"
    koopa_assert_is_executable "${app[@]}"
    dict['cores']="$(koopa_cpu_count)"
    bcbio_args=(
        "--cores=${dict['cores']}"
        '--upgrade=skip'
    )
    for genome in "$@"
    do
        bcbio_args+=("--genomes=${genome}")
    done
    "${app['bcbio']}" upgrade "${bcbio_args[@]}"
    return 0
}
