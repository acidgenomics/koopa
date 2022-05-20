#!/usr/bin/env bash

koopa_docker_prune_stale_tags() {
    # """
    # Prune (delete) all stale tags on DockerHub for a specific image.
    # @note Updated 2021-08-14.
    #
    # This doesn't currently work when 2FA and PAT are enabled.
    # This issue may be resolved by the end of 2021-07.
    #
    # See also:
    # - https://github.com/docker/roadmap/issues/115
    # - https://github.com/docker/hub-feedback/issues/1914
    # - https://github.com/docker/hub-feedback/issues/1927
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDockerPruneStaleTags' "$@"
    return 0
}
