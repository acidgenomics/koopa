#!/usr/bin/env bash

koopa::docker_build() { # {{{1
    # """
    # Build and push a docker image.
    # Updated 2020-06-02.
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
            --server)
                server="$2"
                shift 2
                ;;
            --tag=*)
                tag="${1#*=}"
                shift 1
                ;;
            --tag)
                tag="$2"
                shift 2
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
    koopa::h1 "Building '${tagged_image}' Docker image."
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
    docker build \
        --build-arg "GITHUB_PAT=${DOCKER_GITHUB_PAT:?}" \
        --no-cache \
        --tag="$tagged_image_today" \
        "$source_image"
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

koopa::docker_build_all_batch_images() { # {{{1
    # """
    # Build all AWS Batch Docker images.
    # @note Updated 2020-07-20.
    # """
    local batch_dirs flags force images prefix
    koopa::assert_is_installed docker-build-all-images
    force=0
    while (("$#"))
    do
        case "$1" in
            --force)
                force=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    flags=()
    if [[ "$force" -eq 1 ]]
    then
        flags+=('--force')
    fi
    prefix="$(koopa::docker_prefix)"
    batch_dirs="$( \
        find "${prefix}/acidgenomics" \
            -name 'aws-batch*' \
            -type d \
        | sort \
    )"
    batch_dirs="$(koopa::sub "${prefix}/" "" "$batch_dirs")"
    readarray -t images <<< "$(koopa::print "$batch_dirs")"
    docker-build-all-images "${flags[@]}" "${images[@]}"
    return 0
}

koopa::docker_build_all_images() { # {{{1
    # """
    # Build all Docker images.
    # @note Updated 2020-08-05.
    # """
    local batch_arr batch_dirs extra force image images json prefix prune pos \
        timestamp today utc_timestamp
    koopa::assert_is_installed docker docker-build-all-tags
    extra=0
    force=0
    prune=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --extra)
                extra=1
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
    # Define images array. If empty, define default images.
    if [[ "$#" -eq 0 ]]
    then
        prefix="$(koopa::docker_prefix)"
        images=()
        # Recommended Linux images.
        images+=(
            'acidgenomics/debian'
            'acidgenomics/ubuntu'
            'acidgenomics/fedora'
            'acidgenomics/centos'
        )
        # Extra Linux images.
        images+=(
            'acidgenomics/alpine'
            'acidgenomics/amzn'
            'acidgenomics/arch'
            'acidgenomics/opensuse'
        )
        # Minimal bioinformatics images.
        images+=(
            'acidgenomics/miniconda3'
            'acidgenomics/biocontainers'
        )
        # R images.
        images+=(
            'acidgenomics/bioconductor'
            'acidgenomics/r-basejump'
            'acidgenomics/r-bcbiornaseq'
            'acidgenomics/r-bcbiosinglecell'
            'acidgenomics/r-rnaseq'
            'acidgenomics/r-singlecell'
        )
        # AWS batch images.
        # Ensure we build these after the other images.
        batch_dirs="$( \
            find "$prefix" \
                -name 'aws-batch*' \
                -type d \
                | sort \
        )"
        batch_dirs="$(koopa::sub "${prefix}/" "" "$batch_dirs")"
        readarray -t batch_arr <<< "$(koopa::print "$batch_dirs")"
        images=("${images[@]}" "${batch_arr[@]}")
        # Large bioinformatics images.
        # These don't need to be updated frequently and can be built manually.
        if [[ "$extra" -eq 1 ]]
        then
            images+=(
                'acidgenomics/bcbio'
                'acidgenomics/rnaeditingindexer'
                'acidgenomics/maestro'
            )
    fi
    else
        images=("$@")
    fi
    koopa::h1 "Building ${#images[@]} Docker images."
    docker login
    for image in "${images[@]}"
    do
        # This will force remove all images, if desired.
        [[ "$prune" -eq 1 ]] && koopa::docker_prune
        # Skip image if pushed already today.
        if [[ "$force" -ne 1 ]]
        then
            # FIXME RETHINK THIS, CHECKING PER TAG INSTEAD.
            # FIXME NEED TO MOVE THIS INTO R CODE INSTEAD.
            koopa::is_docker_build_today "$image" && continue
        fi
        docker-build-all-tags "$image"
    done
    [[ "$prune" -eq 1 ]] && koopa::docker_prune
    koopa::success 'All Docker images built successfully.'
    return 0
}

koopa::docker_prune() { # {{{1
    # """
    # Docker prune.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_installed docker
    docker system prune --all --force
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
            --workdir)
                workdir="$2"
                shift 2
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

koopa::is_docker_build_today() { # {{{1
    # """
    # Check if a Docker image has been built today.
    # @note Updated 2020-07-02.
    # """
    local image json timestamp today utc_timestamp
    koopa::assert_has_args "$#"
    koopa::assert_is_installed docker
    today="$(date '+%Y-%m-%d')"
    for image in "$@"
    do
        docker pull "$image" >/dev/null
        json="$( \
            docker inspect \
            --format='{{json .Created}}' \
            "$image" \
        )"
        # Note that we need to convert UTC to local time.
        utc_timestamp="$( \
            koopa::print "$json" \
                | grep -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}' \
                | sed 's/T/ /' \
                | sed 's/\$/ UTC/'
        )"
        timestamp="$(date -d "$utc_timestamp" '+%Y-%m-%d')"
        [[ "$timestamp" != "$today" ]] && return 1
    done
    return 0
}
