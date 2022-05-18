#!/usr/bin/env bash

koopa_linux_bcbio_nextgen_add_genome() {
    # """
    # Install a natively supported bcbio-nextgen genome (e.g. hg38).
    # @note Updated 2022-01-29.
    #
    # @examples
    # > koopa_linux_bcbio_nextgen_add_genome 'hg38' 'mm10'
    # """
    local app bcbio_args dict genome genomes
    koopa_assert_has_args "$#"
    genomes=("$@")
    declare -A app=(
        [bcbio]="$(koopa_linux_locate_bcbio)"
    )
    declare -A dict=(
        [cores]="$(koopa_cpu_count)"
    )
    bcbio_args=(
        "--cores=${dict[cores]}"
        '--upgrade=skip'
    )
    for genome in "${genomes[@]}"
    do
        bcbio_args+=("--genomes=${genome}")
    done
    koopa_dl \
        'Genomes' "$(koopa_to_string "${genomes[@]}")" \
        'Args' "${bcbio_args[@]}"
    "${app[bcbio]}" upgrade "${bcbio_args[@]}"
    return 0
}
