#!/usr/bin/env bash

koopa_docker_push() {
    # """
    # Push a local Docker build.
    # Updated 2022-01-20.
    #
    # Useful if GPG agent causes push failure.
    #
    # @seealso
    # - https://docs.docker.com/config/formatting/
    #
    # @examples
    # > koopa_docker_push 'acidgenomics/debian:latest'
    # """
    local app dict pattern
    koopa_assert_has_args "$#"
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
        [sed]="$(koopa_locate_sed)"
        [sort]="$(koopa_locate_sort)"
        [tr]="$(koopa_locate_tr)"
    )
    declare -A dict=(
        # Consider allowing user to define, so we can support quay.io.
        [server]='docker.io'
    )
    for pattern in "$@"
    do
        local dict2 image images
        declare -A dict2=(
            [pattern]="$pattern"
        )
        koopa_assert_is_matching_regex \
            --string="${dict2[pattern]}" \
            --pattern='^.+/.+$'
        dict2[json]="$( \
            "${app[docker]}" inspect \
                --format="{{json .RepoTags}}" \
                "${dict2[pattern]}" \
        )"
        # Convert JSON to lines.
        readarray -t images <<< "$( \
            koopa_print "${dict2[json]}" \
                | "${app[tr]}" ',' '\n' \
                | "${app[sed]}" 's/^\[//' \
                | "${app[sed]}" 's/\]$//' \
                | "${app[sed]}" 's/^\"//g' \
                | "${app[sed]}" 's/\"$//g' \
                | "${app[sort]}" \
        )"
        if koopa_is_array_empty "${images[@]:-}"
        then
            koopa_stop "Failed to match any images with '${dict2[pattern]}'."
        fi
        for image in "${images[@]}"
        do
            koopa_alert "Pushing '${image}' to '${dict[server]}'."
            "${app[docker]}" push "${dict[server]}/${image}"
        done
    done
    return 0
}
