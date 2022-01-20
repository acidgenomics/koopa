#!/usr/bin/env bash

# FIXME Rework using app/dict approach.
koopa::docker_prune_all_images() { # {{{1
    # """
    # Prune all Docker images.
    # @note Updated 2021-10-25.
    #
    # This is a nuclear option for resetting Docker.
    # """
    local docker
    koopa::assert_has_no_args "$#"
    docker="$(koopa::locate_docker)"
    koopa::alert 'Pruning Docker images.'
    "$docker" system prune --all --force || true
    "$docker" images
    koopa::alert 'Pruning Docker buildx.'
    "$docker" buildx prune --all --force || true
    "$docker" buildx ls
    return 0
}
