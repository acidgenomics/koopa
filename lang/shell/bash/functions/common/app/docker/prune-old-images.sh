#!/usr/bin/env bash

# FIXME Rework using app/dict approach.
koopa::docker_prune_old_images() { # {{{
    # """
    # Prune old Docker images.
    # @note Updated 2021-10-25.
    #
    # 2160h = 24 hours/day * 30 days/month * 3 months.
    #
    # @seealso
    # - https://docs.docker.com/config/pruning/#prune-images
    # - https://docs.docker.com/engine/reference/commandline/image_prune/
    # - https://stackoverflow.com/questions/32723111
    # """
    local docker
    koopa::assert_has_no_args "$#"
    docker="$(koopa::locate_docker)"
    koopa::alert 'Pruning Docker images older than 3 months.'
    "$docker" image prune \
        --all \
        --filter 'until=2160h' \
        --force \
        || true
    # Clean any remaining dangling images.
    "$docker" image prune --force || true
    return 0
}
