#!/usr/bin/env bash

koopa_docker_build_all_tags() {
    # """
    # Build all Docker tags.
    # @note Updated 2023-12-05.
    # """
    local cmd
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'python3'
    cmd="$(koopa_python_prefix)/docker-build-all-tags.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$@"
    return 0
}
