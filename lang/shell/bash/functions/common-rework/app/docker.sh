#!/usr/bin/env bash

koopa_docker_prune_all_images() {
    # """
    # Prune all Docker images.
    # @note Updated 2022-01-20.
    #
    # This is a nuclear option for resetting Docker.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    koopa_alert 'Pruning Docker images.'
    "${app[docker]}" system prune --all --force || true
    "${app[docker]}" images
    koopa_alert 'Pruning Docker buildx.'
    "${app[docker]}" buildx prune --all --force || true
    "${app[docker]}" buildx ls
    return 0
}

koopa_docker_prune_old_images() {
    # """
    # Prune old Docker images.
    # @note Updated 2022-01-20.
    #
    # 2160h = 24 hours/day * 30 days/month * 3 months.
    #
    # @seealso
    # - https://docs.docker.com/config/pruning/#prune-images
    # - https://docs.docker.com/engine/reference/commandline/image_prune/
    # - https://stackoverflow.com/questions/32723111
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    koopa_alert 'Pruning Docker images older than 3 months.'
    "${app[docker]}" image prune \
        --all \
        --filter 'until=2160h' \
        --force \
        || true
    # Clean any remaining dangling images.
    "${app[docker]}" image prune --force || true
    return 0
}

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

koopa_docker_remove() {
    # """
    # Remove docker images by pattern.
    # Updated 2022-02-25.
    #
    # @usage koopa_docker_remove IMAGE...
    #
    # @examples
    # > koopa_docker_remove 'debian' 'ubuntu'
    # """
    local app pattern
    koopa_assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [docker]="$(koopa_locate_docker)"
        [xargs]="$(koopa_locate_xargs)"
    )
    for pattern in "$@"
    do
        # Previous awk approach:
        # returns 'acidgenomics/debian:latest', for example.
        # > | "${app[awk]}" '{print $1 ":" $2}' \
        # New approach matches image ID instead.
        # shellcheck disable=SC2016
        "${app[docker]}" images \
            | koopa_grep --pattern="$pattern" \
            | "${app[awk]}" '{print $3}' \
            | "${app[xargs]}" "${app[docker]}" rmi --force
    done
    return 0
}

koopa_docker_run() {
    # """
    # Run Docker image.
    # @note Updated 2022-02-17.
    #
    # No longer using bind mounts by default.
    # Use named volumes, which have better cross-platform compatiblity, instead.
    #
    # @seealso
    # - https://docs.docker.com/storage/volumes/
    # - https://docs.docker.com/storage/bind-mounts/
    # """
    local app dict pos run_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [docker]="$(koopa_locate_docker)"
    )
    declare -A dict=(
        [arm]=0
        [bash]=0
        [bind]=0
        [workdir]='/mnt/work'
        [x86]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--arm')
                dict[arm]=1
                shift 1
                ;;
            '--bash')
                dict[bash]=1
                shift 1
                ;;
            '--bind')
                dict[bind]=1
                shift 1
                ;;
            '--x86')
                dict[x86]=1
                shift 1
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
    koopa_assert_has_args_eq "$#" 1
    dict[image]="${1:?}"
    "${app[docker]}" pull "${dict[image]}"
    run_args=(
        '--interactive'
        '--tty'
    )
    # Legacy bind mounts approach, now disabled by default.
    # Useful for quickly checking whether a local script will run.
    if [[ "${dict[bind]}" -eq 1 ]]
    then
        # This check helps prevent Docker from chewing up a bunch of CPU.
        if [[ "${HOME:?}" == "${PWD:?}" ]]
        then
            koopa_stop "Do not set '--bind' when running at HOME."
        fi
        run_args+=(
            "--volume=${PWD:?}:${dict[workdir]}"
            "--workdir=${dict[workdir]}"
        )
    fi
    # Manually override the platform, if desired.
    if [[ "${dict[arm]}" -eq 1 ]]
    then
        run_args+=('--platform=linux/arm64')
    elif [[ "${dict[x86]}" -eq 1 ]]
    then
        run_args+=('--platform=linux/amd64')
    fi
    run_args+=("${dict[image]}")
    # Enable an interactive Bash login session, if desired.
    if [[ "${dict[bash]}" -eq 1 ]]
    then
        run_args+=('bash' '-il')
    fi
    "${app[docker]}" run "${run_args[@]}"
    return 0
}

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
