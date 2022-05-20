#!/usr/bin/env bash

koopa_docker_tag() {
    # """
    # Add Docker tag.
    # Updated 2022-01-20.
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
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
    if ! koopa_str_detect_fixed \
        --string="${dict[image]}" \
        --pattern='/'
    then
        dict[image]="acidgenomics/${dict[image]}"
    fi
    if [[ "${dict[source_tag]}" == "${dict[dest_tag]}" ]]
    then
        koopa_alert_info "Source tag identical to destination \
('${dict[source_tag]}')."
        return 0
    fi
    koopa_alert "Tagging '${dict[image]}:${dict[source_tag]}' \
as '${dict[dest_tag]}'."
    "${app[docker]}" login "${dict[server]}"
    "${app[docker]}" pull "${dict[server]}/${dict[image]}:${dict[source_tag]}"
    "${app[docker]}" tag \
        "${dict[image]}:${dict[source_tag]}" \
        "${dict[image]}:${dict[dest_tag]}"
    "${app[docker]}" push "${dict[server]}/${dict[image]}:${dict[dest_tag]}"
    return 0
}
