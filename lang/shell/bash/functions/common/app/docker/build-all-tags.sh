#!/usr/bin/env bash

koopa::docker_build_all_tags() { # {{{1
    # """
    # Build all Docker tags.
    # @note Updated 2020-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDockerBuildAllTags' "$@"
    return 0
}
