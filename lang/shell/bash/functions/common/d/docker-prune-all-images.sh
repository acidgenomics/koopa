#!/usr/bin/env bash

koopa_docker_prune_all_images() {
    # """
    # Prune all Docker images.
    # @note Updated 2023-01-06.
    #
    # This is a nuclear option for resetting Docker.
    #
    # Use 'docker buildx rm XXX' to remove danging buildx nodes.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['docker']="$(koopa_locate_docker)"
    )
    [[ -x "${app['docker']}" ]] || exit 1
    koopa_alert 'Pruning Docker images.'
    "${app['docker']}" system prune --all --force || true
    "${app['docker']}" images
    koopa_alert 'Pruning Docker buildx.'
    "${app['docker']}" buildx prune --all --force --verbose || true
    "${app['docker']}" buildx ls
    return 0
}
