#!/usr/bin/env bash

koopa::docker_prune_all_images() { # {{{1
    # """
    # Prune all Docker images.
    # @note Updated 2022-01-20.
    #
    # This is a nuclear option for resetting Docker.
    # """
    local app
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
    )
    koopa::alert 'Pruning Docker images.'
    "${app[docker]}" system prune --all --force || true
    "${app[docker]}" images
    koopa::alert 'Pruning Docker buildx.'
    "${app[docker]}" buildx prune --all --force || true
    "${app[docker]}" buildx ls
    return 0
}
