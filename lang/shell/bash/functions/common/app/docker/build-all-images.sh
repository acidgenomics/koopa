#!/usr/bin/env bash

koopa::docker_build_all_images() { # {{{1
    # """
    # Build all Docker images.
    # @note Updated 2021-10-27.
    # """
    local app build_file build_args image images
    local pos repo repos repo_name 
    declare -A app=(
        [basename]="$(koopa::locate_basename)"
        [docker]="$(koopa::locate_docker)"
        [xargs]="$(koopa::locate_xargs)"
    )
    declare -A dict=(
        [days]=7
        [docker_dir]="$(koopa::docker_prefix)"
        [force]=0
        [prune]=0
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
            '--docker-dir='*)
                dict[docker_dir]="${1#*=}"
                shift 1
                ;;
            '--docker-dir')
                dict[docker_dir]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--force')
                dict[force]=1
                shift 1
                ;;
            '--prune')
                dict[prune]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    build_args=("--days=${dict[days]}")
    if [[ "${dict[force]}" -eq 1 ]]
    then
        build_args+=('--force')
    fi
    if [[ "$#" -gt 0 ]]
    then
        repos=("$@")
    else
        repos=("${dict[docker_dir]}/acidgenomics")
    fi
    koopa::assert_is_dir "${repos[@]}"
    if [[ "${dict[prune]}" -eq 1 ]]
    then
        koopa::docker_prune_all_images
    fi
    "${app[docker]}" login
    for repo in "${repos[@]}"
    do
        repo_name="$(koopa::basename "$(koopa::realpath "$repo")")"
        koopa::h1 "Building '${repo_name}' images."
        build_file="${repo}/build.txt"
        if [[ -f "$build_file" ]]
        then
            readarray -t images <<< "$( \
                koopa::grep \
                    --extended-regexp \
                    '^[-_a-z0-9]+$' \
                    "$build_file" \
            )"
        else
            readarray -t images <<< "$( \
                koopa::find \
                    --max-depth=1 \
                    --min-depth=1 \
                    --prefix="${PWD:?}" \
                    --print0 \
                    --sort \
                    --type='d' \
                | "${app[xargs]}" -0 -n1 "${app[basename]}" \
            )"
        fi
        koopa::assert_is_array_non_empty "${images[@]:-}"
        koopa::dl \
            "${#images[@]} images" \
            "$(koopa::to_string "${images[@]}")"
        for image in "${images[@]}"
        do
            image="${repo_name}/${image}"
            # Skip image if pushed recently.
            if [[ "${dict[force]}" -eq 0 ]]
            then
                # NOTE This step currently pulls the image and checks the
                # timestamp locally. We likely can speed this step up
                # significantly by querying the DockerHub API directly instead.
                # Refer to 'docker-prune-stale-tags' approach for example code,
                # which is currently written in R instead of Bash.
                if koopa::is_docker_build_recent \
                    --days="${dict[days]}" \
                    "$image"
                then
                    koopa::alert_note "'${image}' was built recently. Skipping."
                    continue
                fi
            fi
            koopa::docker_build_all_tags "${build_args[@]}" "$image"
        done
    done
    [[ "${dict[prune]}" -eq 1 ]] && koopa::docker_prune_all_images
    koopa::alert_success 'All Docker images built successfully.'
    return 0
}
