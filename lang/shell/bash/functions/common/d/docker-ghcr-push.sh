#!/usr/bin/env bash

koopa_docker_ghcr_push() {
    # """
    # Push an image to GitHub Container Registry.
    # @note Updated 2022-01-20.
    #
    # @usage koopa_docker_ghcr_push 'OWNER' 'IMAGE_NAME' 'VERSION'
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 3
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    declare -A dict=(
        [image_name]="${2:?}"
        [owner]="${1:?}"
        [server]='ghcr.io'
        [version]="${3:?}"
    )
    dict[url]="${dict[server]}/${dict[owner]}/\
${dict[image_name]}:${dict[version]}"
    koopa_docker_ghcr_login
    "${app[docker]}" push "${dict[url]}"
    return 0
}
