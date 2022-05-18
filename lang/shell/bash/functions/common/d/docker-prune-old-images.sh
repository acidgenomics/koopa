#!/usr/bin/env bash

koopa_docker_prune_old_images() {
    # """
    # Prune old Docker images.
    # @note Updated 2022-01-20.
    #
    # 2160h = 24 hours/day * 30 days/month * 3 months.
    #
    # @seealso
    # - https://docs.docker.com/config/pruning/#prune-images
    # - https://docs.docker.com/engine/reference/commandline/image_prune/
    # - https://stackoverflow.com/questions/32723111
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    koopa_alert 'Pruning Docker images older than 3 months.'
    "${app[docker]}" image prune \
        --all \
        --filter 'until=2160h' \
        --force \
        || true
    # Clean any remaining dangling images.
    "${app[docker]}" image prune --force || true
    return 0
}
