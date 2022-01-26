#!/usr/bin/env bash

koopa::docker_remove() { # {{{1
    # """
    # Remove docker images by pattern.
    # Updated 2021-10-25.
    # """
    local app pattern
    koopa::assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [docker]="$(koopa::locate_docker)"
        [xargs]="$(koopa::locate_xargs)"
    )
    for pattern in "$@"
    do
        # shellcheck disable=SC2016
        "${app[docker]}" images \
            | koopa::grep "$pattern" \
            | "${app[awk]}" '{print $1 ":" $2}' \
            | "${app[xargs]}" docker rmi
    done
    return 0
}
