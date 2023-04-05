#!/usr/bin/env bash

koopa_docker_ghcr_push() {
    # """
    # Push an image to GitHub Container Registry.
    # @note Updated 2022-01-20.
    #
    # @usage koopa_docker_ghcr_push 'OWNER' 'IMAGE_NAME' 'VERSION'
    # """
    local app dict
    local -A app dict
    koopa_assert_has_args_eq "$#" 3
    app['docker']="$(koopa_locate_docker)"
    [[ -x "${app['docker']}" ]] || exit 1
    dict['image_name']="${2:?}"
    dict['owner']="${1:?}"
    dict['server']='ghcr.io'
    dict['version']="${3:?}"
    dict['url']="${dict['server']}/${dict['owner']}/\
${dict['image_name']}:${dict['version']}"
    koopa_docker_ghcr_login
    "${app['docker']}" push "${dict['url']}"
    return 0
}
