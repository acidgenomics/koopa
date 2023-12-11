#!/usr/bin/env bash

koopa_docker_build_all_tags() {
    # """
    # Build all Docker tags.
    # @note Updated 2023-12-11.
    # """
    koopa_assert_has_args "$#"
    koopa_python_script 'docker-build-all-tags.py' "$@"
    return 0
}
