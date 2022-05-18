#!/usr/bin/env bash

koopa_docker_prune_all_images() {
    # """
    # Prune all Docker images.
    # @note Updated 2022-01-20.
    #
    # This is a nuclear option for resetting Docker.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    koopa_alert 'Pruning Docker images.'
    "${app[docker]}" system prune --all --force || true
    "${app[docker]}" images
    koopa_alert 'Pruning Docker buildx.'
    "${app[docker]}" buildx prune --all --force || true
    "${app[docker]}" buildx ls
    return 0
}
