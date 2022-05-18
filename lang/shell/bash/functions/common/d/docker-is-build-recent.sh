#!/usr/bin/env bash

koopa_docker_is_build_recent() {
    # """
    # Has the requested Docker image been built recently?
    # @note Updated 2022-01-20.
    #
    # @seealso
    # - Corresponding 'isDockerBuildRecent()' R function.
    # - https://stackoverflow.com/questions/8903239/
    # - https://unix.stackexchange.com/questions/27013/
    # """
    local app dict image pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [date]="$(koopa_locate_date)"
        [docker]="$(koopa_locate_docker)"
        [sed]="$(koopa_locate_sed)"
    )
    declare -A dict=(
        [days]=7
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--days='*)
                dict[days]="${1#*=}"
                shift 1
                ;;
            '--days')
                dict[days]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    # 24 hours * 60 minutes * 60 seconds = 86400.
    dict[seconds]="$((dict[days] * 86400))"
    for image in "$@"
    do
        local dict2
        declare -A dict2=(
            [current]="$("${app[date]}" -u '+%s')"
            [image]="$image"
        )
        "${app[docker]}" pull "${dict2[image]}" >/dev/null
        dict2[json]="$( \
            "${app[docker]}" inspect \
                --format='{{json .Created}}' \
                "${dict2[image]}" \
        )"
        dict2[created]="$( \
            koopa_grep \
                --only-matching \
                --pattern='[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}' \
                --regex \
                --string="${dict2[json]}" \
            | "${app[sed]}" 's/T/ /' \
            | "${app[sed]}" 's/\$/ UTC/'
        )"
        dict2[created]="$( \
            "${app[date]}" --utc --date="${dict2[created]}" '+%s' \
        )"
        dict2[diff]=$((dict2[current] - dict2[created]))
        [[ "${dict2[diff]}" -le "${dict[seconds]}" ]] && continue
        return 1
    done
    return 0
}
