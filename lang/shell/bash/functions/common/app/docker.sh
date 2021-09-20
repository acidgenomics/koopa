#!/usr/bin/env bash

koopa::docker_build() { # {{{1
    # """
    # Build and push a multi-architecture Docker image using buildx.
    # Updated 2021-05-23.
    #
    # Potentially useful arguments:
    # * --label='Descriptive metadata about the image'"
    # * --rm
    # * --squash
    # * This can be useful for R packages:
    #   --build-arg "GITHUB_PAT=${DOCKER_GITHUB_PAT:?}"
    #
    # Running the command 'docker buildx install' sets up docker builder
    # command as an alias to 'docker buildx'. This results in the ability to
    # have 'docker build' use the current buildx builder. To remove this
    # alias, run 'docker buildx uninstall'.
    #
    # See also:
    # - docker build --help
    # - https://docs.docker.com/buildx/working-with-buildx/
    # - https://docs.docker.com/config/containers/resource_constraints/
    # - https://docs.docker.com/engine/reference/builder/#arg
    # - https://docs.docker.com/engine/reference/commandline/buildx_build/
    # - https://docs.docker.com/engine/reference/commandline/builder_build/
    # - https://github.com/docker/buildx/issues/396
    # - https://phoenixnap.com/kb/docker-memory-and-cpu-limit
    # - https://jaimyn.com.au/how-to-build-multi-architecture-docker-images-
    #       on-an-m1-mac/
    # """
    local build_name cut delete docker_dir image image_ids memory platforms
    local platforms_file platforms_string pos push server sort source_image
    local tag tags tags_file
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'docker'
    cut="$(koopa::locate_cut)"
    sort="$(koopa::locate_sort)"
    docker_dir="$(koopa::docker_prefix)"
    koopa::assert_is_dir "$docker_dir"
    delete=0
    push=1
    server='docker.io'
    tag='latest'
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--delete')
                delete=1
                shift 1
                ;;
            '--memory='*)
                # e.g. use '8g' for 8 GB limit.
                memory="${1#*=}"
                shift 1
                ;;
            '--no-delete')
                delete=0
                shift 1
                ;;
            '--no-push')
                push=0
                shift 1
                ;;
            '--push')
                push=1
                shift 1
                ;;
            '--server='*)
                server="${1#*=}"
                shift 1
                ;;
            '--tag='*)
                tag="${1#*=}"
                shift 1
                ;;
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
    # e.g. 'acidgenomics/debian'.
    image="${1:?}"
    # Assume acidgenomics recipe by default.
    if ! koopa::str_match "$image" '/'
    then
        image="acidgenomics/${image}"
    fi
    # Handle tag support, if necessary.
    if koopa::str_match "$image" ':'
    then
        tag="$( \
            koopa::print "$image" \
            | "$cut" -d ':' -f 2 \
        )"
        image="$( \
            koopa::print "$image" \
            | "$cut" -d ':' -f 1 \
        )"
    fi
    source_image="${docker_dir}/${image}/${tag}"
    koopa::assert_is_dir "$source_image"
    args=()
    # Tags.
    tags=()
    tags_file="${source_image}/tags.txt"
    [[ -f "$tags_file" ]] && readarray -t tags < "$tags_file"
    if [[ -L "$source_image" ]]
    then
        tags+=("$tag")
        source_image="$(koopa::realpath "$source_image")"
        tag="$(koopa::basename "$source_image")"
    fi
    tags+=("$tag" "${tag}-$(date '+%Y%m%d')")
    # Ensure tags are sorted and unique.
    readarray -t tags <<< "$( \
        koopa::print "${tags[@]}" \
        | "$sort" -u \
    )"
    for tag in "${tags[@]}"
    do
        args+=("--tag=${image}:${tag}")
    done
    # Platforms.
    # Assume x86 by default.
    platforms=('linux/amd64')
    platforms_file="${source_image}/platforms.txt"
    [[ -f "$platforms_file" ]] && readarray -t platforms < "$platforms_file"
    # e.g. 'linux/amd64,linux/arm64'.
    platforms_string="$(koopa::paste0 ',' "${platforms[@]}")"
    args+=("--platform=${platforms_string}")
    # Harden against buildx blowing up memory on a local machine.
    # Consider raising this when we deploy a more powerful build machine.
    # > local memory
    if [[ -n "${memory:-}" ]]
    then
        # If you don't want to use swap, give '--memory' and '--memory-swap'
        # the same values. Don't set '--memory-swap' to 0. Alternatively,
        # set '--memory-swap' to '-1' for unlimited swap.
        args+=(
            "--memory=${memory}"
            "--memory-swap=${memory}"
        )
    fi
    args+=(
        '--no-cache'
        '--progress=auto'
        '--pull'
    )
    [[ "$push" -eq 1 ]] && args+=('--push')
    args+=("$source_image")
    # Force remove any existing locally tagged images before building.
    if [[ "$delete" -eq 1 ]]
    then
        koopa::alert "Pruning images matching '${image}:${tag}'."
        readarray -t image_ids <<< "$( \
            docker image ls \
                --filter reference="${image}:${tag}" \
                --quiet \
        )"
        if koopa::is_array_non_empty "${image_ids[@]:-}"
        then
            docker image rm --force "${image_ids[@]}"
        fi
    fi
    koopa::alert "Building '${source_image}' Docker image."
    koopa::dl 'Build args' "${args[*]}"
    docker login "$server" >/dev/null || return 1
    build_name="$(basename "$image")"
    # Ensure any previous build failres are removed.
    docker buildx rm "$build_name" &>/dev/null || true
    docker buildx create --name="$build_name" --use >/dev/null
    docker buildx build "${args[@]}" || return 1
    docker buildx rm "$build_name"
    docker image ls --filter reference="${image}:${tag}"
    koopa::alert_success "Build of '${source_image}' was successful."
    return 0
}

koopa::docker_build_all_images() { # {{{1
    # """
    # Build all Docker images.
    # @note Updated 2021-05-22.
    # """
    local basename build_file build_args days force grep image images prune pos
    local repo repos repo_name sort xargs
    koopa::assert_is_installed 'docker'
    basename="$(koopa::locate_basename)"
    grep="$(koopa::locate_grep)"
    sort="$(koopa::locate_sort)"
    xargs="$(koopa::locate_xargs)"
    days=7
    force=0
    prune=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--days='*)
                days="${1#*=}"
                shift 1
                ;;
            '--force')
                force=1
                shift 1
                ;;
            '--prune')
                prune=1
                shift 1
                ;;
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
    [[ "$force" -eq 1 ]] && build_args+=('--force')
    if [[ "$#" -gt 0 ]]
    then
        repos=("$@")
    else
        repos=("$(koopa::docker_prefix)/acidgenomics")
    fi
    koopa::assert_is_dir "${repos[@]}"
    [[ "$prune" -eq 1 ]] && koopa::docker_prune_all_images
    docker login
    build_args=("--days=${days}")
    [[ "$force" -eq 1 ]] && build_args+=('--force')
    for repo in "${repos[@]}"
    do
        repo_name="$(basename "$(koopa::realpath "$repo")")"
        koopa::h1 "Building '${repo_name}' images."
        build_file="${repo}/build.txt"
        if [[ -f "$build_file" ]]
        then
            readarray -t images <<< "$( \
                "$grep" -E '^[-_a-z0-9]+$' "$build_file" \
            )"
        else
            readarray -t images <<< "$( \
                koopa::find \
                    --max-depth=1 \
                    --min-depth=1 \
                    --prefix='.' \
                    --print0 \
                    --type='d' \
                | "$sort" -z \
                | "$xargs" -0 -n1 "$basename" \
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
            if [[ "$force" -eq 0 ]]
            then
                # NOTE This step currently pulls the image and checks the
                # timestamp locally. We likely can speed this step up
                # significantly by querying the DockerHub API directly instead.
                # Refer to 'docker-prune-stale-tags' approach for example code,
                # which is currently written in R instead of Bash.
                if koopa::is_docker_build_recent --days="$days" "$image"
                then
                    koopa::alert_note "'${image}' was built recently. Skipping."
                    continue
                fi
            fi
            koopa::docker_build_all_tags "${build_args[@]}" "$image"
        done
    done
    [[ "$prune" -eq 1 ]] && koopa::docker_prune_all_images
    koopa::alert_success 'All Docker images built successfully.'
    return 0
}

koopa::docker_build_all_tags() { # {{{1
    # """
    # Build all Docker tags.
    # @note Updated 2020-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDockerBuildAllTags' "$@"
    return 0
}

koopa::docker_prune_all_images() { # {{{1
    # """
    # Prune all Docker images.
    # @note Updated 2021-04-01.
    #
    # This is a nuclear option for resetting Docker.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_installed 'docker'
    koopa::alert 'Pruning Docker images.'
    docker system prune --all --force
    docker images
    koopa::alert 'Pruning Docker buildx.'
    docker buildx prune --all --force || true
    docker buildx ls
    return 0
}

koopa::docker_prune_all_stale_tags() { # {{{1
    # """
    # Prune (delete) all stale tags on DockerHub for all images.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::r_koopa 'cliDockerPruneAllStaleTags' "$@"
    return 0
}

koopa::docker_prune_old_images() { # {{{
    # """
    # Prune old Docker images.
    # @note Updated 2020-11-03.
    #
    # 2160h = 24 hours/day * 30 days/month * 3 months.
    #
    # @seealso
    # - https://docs.docker.com/config/pruning/#prune-images
    # - https://docs.docker.com/engine/reference/commandline/image_prune/
    # - https://stackoverflow.com/questions/32723111
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_installed 'docker'
    koopa::alert 'Pruning Docker images older than 3 months.'
    docker image prune \
        --all \
        --filter 'until=2160h' \
        --force
    # Clean any remaining dangling images.
    docker image prune --force
    return 0
}

koopa::docker_prune_stale_tags() { # {{{1
    # """
    # Prune (delete) all stale tags on DockerHub for a specific image.
    # @note Updated 2021-08-14.
    #
    # NOTE This doesn't currently work when 2FA and PAT are enabled.
    # This issue may be resolved by the end of 2021-07.
    # See also:
    # - https://github.com/docker/roadmap/issues/115
    # - https://github.com/docker/hub-feedback/issues/1914
    # - https://github.com/docker/hub-feedback/issues/1927
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDockerPruneStaleTags' "$@"
    return 0
}

koopa::docker_push() { # {{{1
    # """
    # Push a local Docker build.
    # Updated 2021-05-21.
    #
    # Useful if GPG agent causes push failure.
    #
    # @seealso
    # - https://docs.docker.com/config/formatting/
    #
    # @examples
    # docker-push acidgenomics/debian:latest
    # """
    local image images json pattern sed server sort tr
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'docker'
    sed="$(koopa::locate_sed)"
    sort="$(koopa::locate_sort)"
    tr="$(koopa::locate_tr)"
    # Consider allowing user to define, so we can support quay.io, for example.
    server='docker.io'
    for pattern in "$@"
    do
        koopa::alert "Pushing images matching '${pattern}' to ${server}."
        koopa::assert_is_matching_regex "$pattern" '^.+/.+$'
        json="$(docker inspect --format="{{json .RepoTags}}" "$pattern")"
        # Convert JSON to lines.
        readarray -t images <<< "$( \
            koopa::print "$json" \
                | "$tr" ',' '\n' \
                | "$sed" 's/^\[//' \
                | "$sed" 's/\]$//' \
                | "$sed" 's/^\"//g' \
                | "$sed" 's/\"$//g' \
                | "$sort" \
        )"
        if ! koopa::is_array_non_empty "${images[@]:-}"
        then
            docker image ls
            koopa::stop "'${image}' failed to match any images."
        fi
        for image in "${images[@]}"
        do
            koopa::alert "Pushing '${image}'."
            docker push "${server}/${image}"
        done
    done
    return 0
}

koopa::docker_remove() { # {{{1
    # """
    # Remove docker images by pattern.
    # Updated 2021-05-21.
    # """
    local awk grep pattern xargs
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'docker'
    awk="$(koopa::locate_awk)"
    grep="$(koopa::locate_grep)"
    xargs="$(koopa::locate_xargs)"
    for pattern in "$@"
    do
        # shellcheck disable=SC2016
        docker images \
            | "$grep" "$pattern" \
            | "$awk" '{print $1 ":" $2}' \
            | "$xargs" docker rmi
    done
    return 0
}

koopa::docker_run() { # {{{1
    # """
    # Run Docker image.
    # @note Updated 2021-03-17.
    #
    # No longer using bind mounts by default.
    # Use named volumes, which have better cross-platform compatiblity, instead.
    #
    # @seealso
    # - https://docs.docker.com/storage/volumes/
    # - https://docs.docker.com/storage/bind-mounts/
    # """
    local dict image pos run_args workdir
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'docker'
    declare -A dict=(
        [arm]=0
        [bash]=0
        [bind]=0
        [x86]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
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
    koopa::assert_has_args_eq "$#" 1
    image="${1:?}"
    docker pull "$image"
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
            koopa::stop "Do not set '--bind' when running at HOME."
        fi
        workdir='/mnt/work'
        run_args+=(
            "--volume=${PWD:?}:${workdir}"
            "--workdir=${workdir}"
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
    run_args+=("$image")
    # Enable an interactive Bash login session, if desired.
    if [[ "${dict[bash]}" -eq 1 ]]
    then
        run_args+=('bash' '-il')
    fi
    docker run "${run_args[@]}"
    return 0
}

koopa::docker_tag() { # {{{1
    # """
    # Add Docker tag.
    # Updated 2021-03-25.
    # """
    local dest_tag image server source_tag
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'docker'
    image="${1:?}"
    source_tag="${2:?}"
    dest_tag="${3:-latest}"
    # Consider allowing this to be user-definable in a future update.
    server='docker.io'
    # Assume acidgenomics recipe by default.
    if ! koopa::str_match "$image" '/'
    then
        image="acidgenomics/${image}"
    fi
    if [[ "$source_tag" == "$dest_tag" ]]
    then
        koopa::print "Source tag identical to destination ('${source_tag}')."
        return 0
    fi
    koopa::alert "Tagging '${image}:${source_tag}' as '${dest_tag}'."
    docker login "$server"
    docker pull "${server}/${image}:${source_tag}"
    docker tag "${image}:${source_tag}" "${image}:${dest_tag}"
    docker push "${server}/${image}:${dest_tag}"
    return 0
}

koopa::is_docker_build_recent() { # {{{1
    # """
    # Has the requested Docker image been built recently?
    # @note Updated 2021-05-20.
    #
    # @seealso
    # - Corresponding 'isDockerBuildRecent()' R function.
    # - https://stackoverflow.com/questions/8903239/
    # - https://unix.stackexchange.com/questions/27013/
    # """
    local created current date days diff grep image json seconds sed
    koopa::assert_has_args "$#"
    date="$(koopa::locate_date)"
    grep="$(koopa::locate_grep)"
    sed="$(koopa::locate_sed)"
    days=7
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--days='*)
                days="${1#*=}"
                shift 1
                ;;
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
    koopa::assert_has_args "$#"
    # 24 hours * 60 minutes * 60 seconds = 86400.
    seconds="$((days * 86400))"
    current="$("$date" -u '+%s')"
    for image in "$@"
    do
        docker pull "$image" >/dev/null
        json="$(docker inspect --format='{{json .Created}}' "$image")"
        created="$( \
            koopa::print "$json" \
                | "$grep" -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}' \
                | "$sed" 's/T/ /' \
                | "$sed" 's/\$/ UTC/'
        )"
        created="$("$date" -u -d "$created" '+%s')"
        diff=$((current - created))
        [[ "$diff" -gt "$seconds" ]] && return 1
    done
    return 0
}

koopa::ghcr_docker_login() { # {{{1
    # """
    # Log in to GitHub Container Registry.
    # @note Updated 2020-10-08.
    #
    # User and PAT are defined by exported globals.
    # """
    local pat server user
    koopa::assert_has_no_args
    pat="${GHCR_PAT:?}"
    server='ghcr.io'
    user="${GHCR_USER:?}"
    koopa::print "$pat" \
        | docker login "$server" -u "$user" --password-stdin
    return 0
}

koopa::ghcr_docker_push() { # {{{
    # """
    # Push an image to GitHub Container Registry.
    # @note Updated 2020-10-08.
    # """
    local image_name owner server url version
    koopa::assert_has_args_eq "$#" 3
    server='ghcr.io'
    owner="${1:?}"
    image_name="${2:?}"
    version="${3:?}"
    koopa::ghcr_docker_login
    url="${server}/${owner}/${image_name}:${version}"
    docker push "$url"
    return 0
}
