#!/usr/bin/env bash

koopa::docker_prune_stale_tags() { # {{{1
    # """
    # Prune (delete) all stale tags on DockerHub for a specific image.
    # @note Updated 2021-08-14.
    #
    # NOTE This doesn't currently work when 2FA and PAT are enabled.
    # This issue may be resolved by the end of 2021-07.
    # See also:
    # - https://github.com/docker/roadmap/issues/115
    # - https://github.com/docker/hub-feedback/issues/1914
    # - https://github.com/docker/hub-feedback/issues/1927
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDockerPruneStaleTags' "$@"
    return 0
}
