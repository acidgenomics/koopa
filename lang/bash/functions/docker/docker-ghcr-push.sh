#!/usr/bin/env bash

_koopa_docker_ghcr_push() {
    # """
    # Push an image to GitHub Container Registry.
    # @note Updated 2022-01-20.
    #
    # @usage _koopa_docker_ghcr_push 'OWNER' 'IMAGE_NAME' 'VERSION'
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 3
    app['docker']="$(_koopa_locate_docker)"
    _koopa_assert_is_executable "${app[@]}"
    dict['image_name']="${2:?}"
    dict['owner']="${1:?}"
    dict['server']='ghcr.io'
    dict['version']="${3:?}"
    dict['url']="${dict['server']}/${dict['owner']}/\
${dict['image_name']}:${dict['version']}"
    _koopa_docker_ghcr_login
    "${app['docker']}" push "${dict['url']}"
    return 0
}
