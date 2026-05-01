#!/usr/bin/env bash

_koopa_docker_build_all_tags() {
    # """
    # Build all Docker tags.
    # @note Updated 2023-12-11.
    # """
    _koopa_assert_has_args "$#"
    _koopa_python_script 'docker-build-all-tags.py' "$@"
    return 0
}
