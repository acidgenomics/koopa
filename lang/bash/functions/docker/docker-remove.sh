#!/usr/bin/env bash

_koopa_docker_remove() {
    # """
    # Remove docker images by pattern.
    # Updated 2022-02-25.
    #
    # @usage _koopa_docker_remove IMAGE...
    #
    # @examples
    # > _koopa_docker_remove 'debian' 'ubuntu'
    # """
    local -A app
    local pattern
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk)"
    app['docker']="$(_koopa_locate_docker)"
    app['xargs']="$(_koopa_locate_xargs)"
    _koopa_assert_is_executable "${app[@]}"
    for pattern in "$@"
    do
        # Previous awk approach:
        # returns 'acidgenomics/debian:latest', for example.
        # > | "${app['awk']}" '{print $1 ":" $2}' \
        # New approach matches image ID instead.
        # shellcheck disable=SC2016
        "${app['docker']}" images \
            | _koopa_grep --pattern="$pattern" \
            | "${app['awk']}" '{print $3}' \
            | "${app['xargs']}" "${app['docker']}" rmi --force
    done
    return 0
}
