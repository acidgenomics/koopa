#!/usr/bin/env bash

koopa::docker_build() { # {{{1
    # """
    # Build and push a multi-architecture Docker image using buildx.
    # Updated 2022-01-20.
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
    local app build_args build_name image image_ids memory platforms
    local platforms_file platforms_string pos source_image tags tags_file
    koopa::assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [date]="$(koopa::locate_date)"
        [docker]="$(koopa::locate_docker)"
        [sort]="$(koopa::locate_sort)"
    )
    declare -A dict=(
        [docker_dir]="$(koopa::docker_prefix)"
        [delete]=0
        [memory]=''
        [push]=1
        [server]='docker.io'
        [tag]='latest'
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--docker-dir='*)
                dict[docker_dir]="${1#*=}"
                shift 1
                ;;
            '--docker-dir')
                dict[docker_dir]="${2:?}"
                shift 2
                ;;
            '--memory='*)
                # e.g. use '8g' for 8 GB limit.
                dict[memory]="${1#*=}"
                shift 1
                ;;
            '--memory')
                dict[memory]="${2:?}"
                shift 2
                ;;
            '--server='*)
                dict[server]="${1#*=}"
                shift 1
                ;;
            '--server')
                dict[server]="${2:?}"
                shift 2
                ;;
            '--tag='*)
                dict[tag]="${1#*=}"
                shift 1
                ;;
            '--tag')
                dict[tag]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--delete')
                dict[delete]=1
                shift 1
                ;;
            '--no-delete')
                dict[delete]=0
                shift 1
                ;;
            '--no-push')
                dict[push]=0
                shift 1
                ;;
            '--push')
                dict[push]=1
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
    koopa::assert_has_args "$#"
    for image in "$@"
    do
        # FIXME Consider using dict2 here, to reduce number of local variable
        # calls needed.
        # Assume input is an Acid Genomics Docker recipe by default.
        if ! koopa::str_detect_fixed "$image" '/'
        then
            image="acidgenomics/${image}"
        fi
        # Handle tag support, if necessary.
        if koopa::str_detect_fixed "$image" ':'
        then
            tag="$( \
                koopa::print "$image" \
                | "${app[cut]}" -d ':' -f 2 \
            )"
            image="$( \
                koopa::print "$image" \
                | "${app[cut]}" -d ':' -f 1 \
            )"
        fi
        source_image="${dict[docker_dir]}/${image}/${tag}"
        koopa::assert_is_dir "$source_image"
        build_args=()
        # Tags.
        tags=()
        tags_file="${source_image}/tags.txt"
        if [[ -f "$tags_file" ]]
        then
            readarray -t tags < "$tags_file"
        fi
        if [[ -L "$source_image" ]]
        then
            tags+=("$tag")
            source_image="$(koopa::realpath "$source_image")"
            tag="$(koopa::basename "$source_image")"
        fi
        tags+=("$tag" "${tag}-$(${app[date]} '+%Y%m%d')")
        # Ensure tags are sorted and unique.
        readarray -t tags <<< "$( \
            koopa::print "${tags[@]}" \
            | "${app[sort]}" -u \
        )"
        for tag in "${tags[@]}"
        do
            build_args+=("--tag=${image}:${tag}")
        done
        # Platforms.
        # Assume x86 by default.
        platforms=('linux/amd64')
        platforms_file="${source_image}/platforms.txt"
        if [[ -f "$platforms_file" ]]
        then
            readarray -t platforms < "$platforms_file"
        fi
        # e.g. 'linux/amd64,linux/arm64'.
        platforms_string="$(koopa::paste --sep=',' "${platforms[@]}")"
        build_args+=("--platform=${platforms_string}")
        # Harden against buildx blowing up memory on a local machine.
        # Consider raising this when we deploy a more powerful build machine.
        # > local memory
        if [[ -n "${dict[memory]}" ]]
        then
            # If you don't want to use swap, give '--memory' and '--memory-swap'
            # the same values. Don't set '--memory-swap' to 0. Alternatively,
            # set '--memory-swap' to '-1' for unlimited swap.
            build_args+=(
                "--memory=${dict[memory]}"
                "--memory-swap=${dict[memory]}"
            )
        fi
        build_args+=(
            '--no-cache'
            '--progress=auto'
            '--pull'
        )
        if [[ "${dict[push]}" -eq 1 ]]
        then
            build_args+=('--push')
        fi
        build_args+=("$source_image")
        # Force remove any existing locally tagged images before building.
        if [[ "${dict[delete]}" -eq 1 ]]
        then
            koopa::alert "Pruning images matching '${image}:${tag}'."
            readarray -t image_ids <<< "$( \
                "${app[docker]}" image ls \
                    --filter reference="${image}:${tag}" \
                    --quiet \
            )"
            if koopa::is_array_non_empty "${image_ids[@]:-}"
            then
                "${app[docker]}" image rm --force "${image_ids[@]}"
            fi
        fi
        koopa::alert "Building '${source_image}' Docker image."
        koopa::dl 'Build args' "${build_args[*]}"
        "${app[docker]}" login "${dict[server]}" >/dev/null || return 1
        build_name="$(koopa::basename "$image")"
        # Ensure any previous build failres are removed.
        "${app[docker]}" buildx rm "$build_name" &>/dev/null || true
        "${app[docker]}" buildx create --name="$build_name" --use >/dev/null
        "${app[docker]}" buildx build "${build_args[@]}" || return 1
        "${app[docker]}" buildx rm "$build_name"
        "${app[docker]}" image ls --filter reference="${image}:${tag}"
        koopa::alert_success "Build of '${source_image}' was successful."
    done
    return 0
}
