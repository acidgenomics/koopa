#!/usr/bin/env bash

koopa_docker_prune_all_stale_tags() {
    # """
    # Prune (delete) all stale tags on DockerHub for all images.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_no_args "$#"
    koopa_r_koopa 'cliDockerPruneAllStaleTags' "$@"
    return 0
}
