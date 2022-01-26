#!/usr/bin/env bash

koopa::docker_prune_all_stale_tags() { # {{{1
    # """
    # Prune (delete) all stale tags on DockerHub for all images.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::r_koopa 'cliDockerPruneAllStaleTags' "$@"
    return 0
}
