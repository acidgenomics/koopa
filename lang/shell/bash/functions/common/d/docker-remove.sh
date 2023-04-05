#!/usr/bin/env bash

koopa_docker_remove() {
    # """
    # Remove docker images by pattern.
    # Updated 2022-02-25.
    #
    # @usage koopa_docker_remove IMAGE...
    #
    # @examples
    # > koopa_docker_remove 'debian' 'ubuntu'
    # """
    local -A app
    local pattern
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk)"
    app['docker']="$(koopa_locate_docker)"
    app['xargs']="$(koopa_locate_xargs)"
    koopa_assert_is_executable "${app[@]}"
    for pattern in "$@"
    do
        # Previous awk approach:
        # returns 'acidgenomics/debian:latest', for example.
        # > | "${app['awk']}" '{print $1 ":" $2}' \
        # New approach matches image ID instead.
        # shellcheck disable=SC2016
        "${app['docker']}" images \
            | koopa_grep --pattern="$pattern" \
            | "${app['awk']}" '{print $3}' \
            | "${app['xargs']}" "${app['docker']}" rmi --force
    done
    return 0
}
