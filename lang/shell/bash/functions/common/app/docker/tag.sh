#!/usr/bin/env bash

koopa::docker_tag() { # {{{1
    # """
    # Add Docker tag.
    # Updated 2022-01-20.
    # """
    local app dict
    koopa::assert_has_args "$#"
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
    )
    declare -A dict=(
        [dest_tag]="${3:-}"
        [image]="${1:?}"
        # Consider allowing this to be user-definable in the future.
        [server]='docker.io'
        [source_tag]="${2:?}"
    )
    [[ -z "${dict[dest_tag]}" ]] && dict[dest_tag]='latest'
    # Assume acidgenomics recipe by default.
    if ! koopa::str_detect_fixed "${dict[image]}" '/'
    then
        dict[image]="acidgenomics/${dict[image]}"
    fi
    if [[ "${dict[source_tag]}" == "${dict[dest_tag]}" ]]
    then
        koopa::alert_info "Source tag identical to destination \
('${dict[source_tag]}')."
        return 0
    fi
    koopa::alert "Tagging '${dict[image]}:${dict[source_tag]}' \
as '${dict[dest_tag]}'."
    "${app[docker]}" login "${dict[server]}"
    "${app[docker]}" pull "${dict[server]}/${dict[image]}:${dict[source_tag]}"
    "${app[docker]}" tag \
        "${dict[image]}:${dict[source_tag]}" \
        "${dict[image]}:${dict[dest_tag]}"
    "${app[docker]}" push "${dict[server]}/${dict[image]}:${dict[dest_tag]}"
    return 0
}
