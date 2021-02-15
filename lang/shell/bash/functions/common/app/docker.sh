#!/usr/bin/env bash

koopa::docker_build() { # {{{1
    # """
    # Build and push a docker image.
    # Updated 2020-11-04.
    #
    # Use '--no-cache' flag to disable build cache.
    #
    # Examples:
    # docker-build-image bioconductor release
    # docker-build fedora
    #
    # See also:
    # - docker build --help
    # - https://docs.docker.com/engine/reference/builder/#arg
    # """
    local delete docker_dir image image_ids pos push server source_image \
        symlink_tag symlink_tagged_image symlink_tagged_image_today tag \
        tagged_image tagged_image_today today
    koopa::assert_has_args "$#"
    koopa::assert_is_installed docker
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
            --delete)
                delete=1
                shift 1
                ;;
            --no-delete)
                delete=0
                shift 1
                ;;
            --no-push)
                push=0
                shift 1
                ;;
            --push)
                push=1
                shift 1
                ;;
            --server=*)
                server="${1#*=}"
                shift 1
                ;;
            --tag=*)
                tag="${1#*=}"
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    # e.g. acidgenomics/debian
    image="${1:?}"
    # Assume acidgenomics recipe by default.
    if ! koopa::str_match "$image" '/'
    then
        image="acidgenomics/${image}"
    fi
    # Handle tag support, if necessary.
    if koopa::str_match "$image" ':'
    then
        tag="$(koopa::print "$image" | cut -d ':' -f 2)"
        image="$(koopa::print "$image" | cut -d ':' -f 1)"
    fi
    source_image="${docker_dir}/${image}/${tag}"
    koopa::assert_is_dir "$source_image"
    today="$(date '+%Y%m%d')"
    if [[ -L "$source_image" ]]
    then
        symlink_tag="$(basename "$source_image")"
        symlink_tagged_image="${image}:${symlink_tag}"
        symlink_tagged_image_today="${symlink_tagged_image}-${today}"
        # Now resolve the symlink to real path.
        source_image="$(realpath "$source_image")"
        tag="$(basename "$source_image")"
    fi
    # e.g. acidgenomics/debian:latest
    tagged_image="${image}:${tag}"
    # e.g. acidgenomics/debian:latest-20200101
    tagged_image_today="${tagged_image}-${today}"
    koopa::alert "Building '${tagged_image}' Docker image."
    docker login "$server"
    # Force remove any existing local tagged images.
    if [[ "$delete" -eq 1 ]]
    then
        readarray -t image_ids <<< "$( \
            docker image ls \
                --filter reference="$tagged_image" \
                --quiet \
        )"
        if koopa::is_array_non_empty "${image_ids[@]}"
        then
            docker image rm --force "${image_ids[@]}"
        fi
    fi
    # Build a local copy of the image.
    # This can be useful for R packages:
    # > --build-arg "GITHUB_PAT=${DOCKER_GITHUB_PAT:?}"
    # NOTE This step doesn't error consistently on build failures.
    # How to harden against this case?
    # https://github.com/moby/moby/issues/1875
    docker build \
        --no-cache \
        --tag="$tagged_image_today" \
        "$source_image" \
        || return 1
    docker tag "$tagged_image_today" "$tagged_image"
    if [[ -n "${symlink_tag:-}" ]]
    then
        docker tag "$tagged_image_today" "$symlink_tagged_image_today"
        docker tag "$symlink_tagged_image_today" "$symlink_tagged_image"
    fi
    if [[ "$push" -eq 1 ]]
    then
        docker push "${server}/${tagged_image_today}"
        docker push "${server}/${tagged_image}"
        if [[ -n "${symlink_tag:-}" ]]
        then
            docker push "${server}/${symlink_tagged_image_today}"
            docker push "${server}/${symlink_tagged_image}"
        fi
    fi
    docker image ls --filter reference="$tagged_image"
    koopa::success "Build of '${tagged_image}' was successful."
    return 0
}

koopa::docker_build_all_images() { # {{{1
    # """
    # Build all Docker images.
    # @note Updated 2020-11-03.
    # """
    local build_file build_args days force image images prune pos \
        repo repos repo_name
    koopa::assert_is_installed 'docker' 'docker-build-all-tags'
    days=2
    force=0
    prune=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --days=*)
                days="${1#*=}"
                shift 1
                ;;
            --force)
                force=1
                shift 1
                ;;
            --prune)
                prune=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
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
        repo_name="$(basename "$(realpath "$repo")")"
        koopa::h1 "Building '${repo_name}' images."
        build_file="${repo}/build.txt"
        if [[ -f "$build_file" ]]
        then
            readarray -t images <<< "$( \
                grep -E '^[-_a-z0-9]+$' "$build_file" \
            )"
        else
            readarray -t images <<< "$( \
                find . \
                    -mindepth 1 \
                    -maxdepth 1 \
                    -type d \
                    -print0 \
                | sort -z \
                | xargs -0 -n1 basename \
            )"
        fi
        koopa::assert_is_array_non_empty "${images[@]}"
        koopa::dl \
            "${#images[@]} images" \
            "$(koopa::to_string "${images[@]}")"
        for image in "${images[@]}"
        do
            image="${repo_name}/${image}"
            # Skip image if pushed recently.
            if [[ "$force" -eq 0 ]]
            then
                if koopa::is_docker_build_recent "$image"
                then
                    koopa::note "'${image}' was built recently. Skipping."
                    continue
                fi
            fi
            docker-build-all-tags "${build_args[@]}" "$image"
        done
    done
    [[ "$prune" -eq 1 ]] && koopa::docker_prune_all_images
    koopa::success 'All Docker images built successfully.'
    return 0
}

koopa::docker_build_all_tags() { # {{{1
    # """
    # Build all Docker tags.
    # @note Updated 2020-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'dockerBuildAllTags' "$@"
    return 0
}

koopa::docker_prune_all_images() { # {{{1
    # """
    # Prune all Docker images.
    # @note Updated 2020-11-03.
    #
    # This is a nuclear option for resetting Docker.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_installed docker
    koopa::alert 'Pruning all Docker images.'
    docker system prune --all --force
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
    koopa::is_installed docker
    koopa::alert 'Pruning Docker images older than 3 months.'
    docker image prune \
        --all \
        --filter 'until=2160h' \
        --force
    # Clean any remaining dangling images.
    docker image prune --force
    return 0
}

koopa::docker_push() { # {{{1
    # """
    # Push a local Docker build.
    # Updated 2020-02-18.
    #
    # Useful if GPG agent causes push failure.
    #
    # @seealso
    # - https://docs.docker.com/config/formatting/
    #
    # @examples
    # docker-push acidgenomics/debian:latest
    # """
    local image images json pattern server
    koopa::assert_has_args "$#"
    koopa::assert_is_installed docker
    server='docker.io'
    for pattern in "$@"
    do
        koopa::h1 "Pushing images matching '${pattern}' to ${server}."
        koopa::assert_is_matching_regex "$pattern" '^.+/.+$'
        json="$(docker inspect --format="{{json .RepoTags}}" "$pattern")"
        # Convert JSON to lines.
        # shellcheck disable=SC2001
        readarray -t images <<< "$( \
            koopa::print "$json" \
                | tr ',' '\n' \
                | sed 's/^\[//' \
                | sed 's/\]$//' \
                | sed 's/^\"//g' \
                | sed 's/\"$//g' \
                | sort \
        )"
        if ! koopa::is_array_non_empty "${images[@]}"
        then
            docker image ls
            koopa::stop "'${image}' failed to match any images."
        fi
        for image in "${images[@]}"
        do
            koopa::h2 "Pushing '${image}'."
            docker push "${server}/${image}"
        done
    done
    return 0
}

koopa::docker_remove() { # {{{1
    # """
    # Remove docker images by pattern.
    # Updated 2020-07-01.
    # """
    local pattern
    koopa::assert_has_args "$#"
    koopa::assert_is_installed docker
    for pattern in "$@"
    do
        docker images \
            | grep "$pattern" \
            | awk '{print $1 ":" $2}' \
            | xargs docker rmi
    done
    return 0
}

koopa::docker_run() { # {{{1
    # """
    # Run Docker image.
    # @note Updated 2020-07-01.
    # """
    local bash flags image pos workdir
    koopa::assert_has_args "$#"
    koopa::assert_is_installed docker
    bash=0
    workdir='/mnt/work'
    pos=()
    while (("$#"))
    do
        case "$1" in
            --bash)
                bash=1
                shift 1
                ;;
            --workdir=*)
                workdir="${1#*=}"
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    image="$1"
    workdir="$(koopa::strip_trailing_slash "$workdir")"
    docker pull "$image"
    flags=(
        "--volume=${PWD}:${workdir}"
        "--workdir=${workdir}"
        '--interactive'
        '--tty'
        "$image"
    )
    if [[ "$bash" -eq 1 ]]
    then
        flags+=('bash' '-il')
    fi
    docker run "${flags[@]}"
    return 0
}

koopa::docker_run_wine() { # {{{1
    # """
    # Run Wine Docker image.
    # @note Updated 2020-07-20.
    #
    # Allow access from localhost.
    # > xhost + "$HOSTNAME"
    # """
    local image workdir
    koopa::assert_is_installed docker xhost
    image='acidgenomics/wine'
    workdir='/mnt/work'
    xhost + '127.0.0.1'
    docker run \
        --interactive \
        --privileged \
        --tty \
        --volume="${PWD}:${workdir}" \
        --workdir="${workdir}" \
        -e 'DISPLAY=host.docker.internal:0' \
        "$image" \
        "$@"
    return 0
}

koopa::docker_tag() { # {{{1
    # """
    # Add Docker tag.
    # Updated 2020-02-18.
    # """
    local dest_tag image server source_tag
    koopa::assert_has_args "$#"
    koopa::assert_is_installed docker
    image="${1:?}"
    source_tag="${2:?}"
    dest_tag="${3:-latest}"
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
    koopa::h1 "Tagging '${image}' image tag '${source_tag}' as '${dest_tag}'."
    docker login "$server"
    docker pull "${server}/${image}:${source_tag}"
    docker tag "${image}:${source_tag}" "${image}:${dest_tag}"
    docker push "${server}/${image}:${dest_tag}"
    return 0
}

koopa::is_docker_build_recent() { # {{{1
    # """
    # Has the requested Docker image been built recently?
    # @note Updated 2020-08-07.
    #
    # @seealso
    # - Corresponding 'isDockerBuildRecent()' R function.
    # - https://stackoverflow.com/questions/8903239/
    # - https://unix.stackexchange.com/questions/27013/
    # """
    local created current days diff image json seconds
    koopa::assert_has_args "$#"
    koopa::assert_is_installed docker
    days=2
    pos=()
    while (("$#"))
    do
        case "$1" in
            --days=*)
                days="${1#*=}"
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
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
    seconds=$((days * 86400))
    current="$(date -u '+%s')"
    for image in "$@"
    do
        docker pull "$image" >/dev/null
        json="$(docker inspect --format='{{json .Created}}' "$image")"
        created="$( \
            koopa::print "$json" \
                | grep -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}' \
                | sed 's/T/ /' \
                | sed 's/\$/ UTC/'
        )"
        created="$(date -u -d "$created" '+%s')"
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
