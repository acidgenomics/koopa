#!/usr/bin/env bash

koopa_docker_prune_all_images() {
    # """
    # Prune all Docker images.
    # @note Updated 2023-08-21.
    #
    # This is a nuclear option for resetting Docker.
    #
    # Use 'docker buildx rm XXX' to remove danging buildx nodes.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    koopa_alert 'Pruning Docker buildx.'
    "${app['docker']}" buildx prune --all --force --verbose || true
    # > "${app['docker']}" buildx ls
    koopa_alert 'Pruning Docker images.'
    "${app['docker']}" system prune --all --force || true
    "${app['docker']}" images
    return 0
}
