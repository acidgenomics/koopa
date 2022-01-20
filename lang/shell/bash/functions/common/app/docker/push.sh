#!/usr/bin/env bash

# FIXME Rework and improve dict approach.
koopa::docker_push() { # {{{1
    # """
    # Push a local Docker build.
    # Updated 2021-10-25.
    #
    # Useful if GPG agent causes push failure.
    #
    # @seealso
    # - https://docs.docker.com/config/formatting/
    #
    # @examples
    # docker-push acidgenomics/debian:latest
    # """
    local app image images json pattern server
    koopa::assert_has_args "$#"
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
        [sed]="$(koopa::locate_sed)"
        [sort]="$(koopa::locate_sort)"
        [tr]="$(koopa::locate_tr)"
    )
    # Consider allowing user to define, so we can support quay.io, for example.
    server='docker.io'
    for pattern in "$@"
    do
        # FIXME Use dict2 array approach here.
        koopa::alert "Pushing images matching '${pattern}' to ${server}."
        koopa::assert_is_matching_regex "$pattern" '^.+/.+$'
        json="$( \
            "${app[docker]}" inspect \
                --format="{{json .RepoTags}}" \
                "$pattern" \
        )"
        # Convert JSON to lines.
        readarray -t images <<< "$( \
            koopa::print "$json" \
                | "${app[tr]}" ',' '\n' \
                | "${app[sed]}" 's/^\[//' \
                | "${app[sed]}" 's/\]$//' \
                | "${app[sed]}" 's/^\"//g' \
                | "${app[sed]}" 's/\"$//g' \
                | "${app[sort]}" \
        )"
        if ! koopa::is_array_non_empty "${images[@]:-}"
        then
            "${app[docker]}" image ls
            koopa::stop "'${image}' failed to match any images."
        fi
        for image in "${images[@]}"
        do
            koopa::alert "Pushing '${image}'."
            "${app[docker]}" push "${server}/${image}"
        done
    done
    return 0
}
