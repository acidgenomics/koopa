#!/usr/bin/env bash

koopa_docker_ghcr_login() {
    # """
    # Log in to GitHub Container Registry.
    # @note Updated 2022-01-20.
    #
    # User ('GHCR_USER') and PAT ('GHCR_PAT') are defined by exported globals.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    declare -A dict=(
        [pat]="${GHCR_PAT:?}"
        [server]='ghcr.io'
        [user]="${GHCR_USER:?}"
    )
    koopa_print "${dict[pat]}" \
        | "${app[docker]}" login \
            "${dict[server]}" \
            -u "${dict[user]}" \
            --password-stdin
    return 0
}
