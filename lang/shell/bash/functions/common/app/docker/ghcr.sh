#!/usr/bin/env bash

koopa::docker_ghcr_login() { # {{{1
    # """
    # Log in to GitHub Container Registry.
    # @note Updated 2022-01-20.
    #
    # User ('GHCR_USER') and PAT ('GHCR_PAT') are defined by exported globals.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
    )
    declare -A dict=(
        [pat]="${GHCR_PAT:?}"
        [server]='ghcr.io'
        [user]="${GHCR_USER:?}"
    )
    koopa::print "${dict[pat]}" \
        | "${app[docker]}" login \
            "${dict[server]}" \
            -u "${dict[user]}" \
            --password-stdin
    return 0
}

koopa::docker_ghcr_push() { # {{{
    # """
    # Push an image to GitHub Container Registry.
    # @note Updated 2022-01-20.
    #
    # @examples
    # koopa::docker_ghcr_push 'OWNER' 'IMAGE_NAME' 'VERSION'
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 3
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
    )
    declare -A dict=(
        [image_name]="${2:?}"
        [owner]="${1:?}"
        [server]='ghcr.io'
        [version]="${3:?}"
    )
    dict[url]="${dict[server]}/${dict[owner]}/\
${dict[image_name]}:${dict[version]}"
    koopa::docker_ghcr_login
    "${app[docker]}" push "${dict[url]}"
    return 0
}
