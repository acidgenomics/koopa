#!/usr/bin/env bash

## FIXME Rework this using pure shell variant.

koopa_docker_build_all_tags() {
    # """
    # Build all Docker tags.
    # @note Updated 2020-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDockerBuildAllTags' "$@"
    return 0
}
