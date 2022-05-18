#!/usr/bin/env bash

koopa_docker_build() {
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
    local app dict pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [date]="$(koopa_locate_date)"
        [docker]="$(koopa_locate_docker)"
        [sort]="$(koopa_locate_sort)"
    )
    declare -A dict=(
        [docker_dir]="$(koopa_docker_prefix)"
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
    for image in "$@"
    do
        local build_args dict2 image_ids platforms tag tags
        declare -A dict2
        dict2[image]="$image"
        build_args=()
        platforms=()
        tags=()
        # Assume input is an Acid Genomics Docker recipe by default.
        if ! koopa_str_detect_fixed \
            --string="${dict2[image]}" \
            --pattern='/'
        then
            dict2[image]="acidgenomics/${dict2[image]}"
        fi
        # Handle tag support, if necessary.
        if koopa_str_detect_fixed \
            --string="${dict2[image]}" \
            --pattern=':'
        then
            dict2[tag]="$( \
                koopa_print "${dict2[image]}" \
                | "${app[cut]}" -d ':' -f '2' \
            )"
            dict2[image]="$( \
                koopa_print "${dict2[image]}" \
                | "${app[cut]}" -d ':' -f '1' \
            )"
        else
            dict2[tag]="${dict[tag]}"
        fi
        dict2[source_image]="${dict[docker_dir]}/${dict2[image]}/${dict2[tag]}"
        koopa_assert_is_dir "${dict2[source_image]}"
        # Tags.
        dict2[tags_file]="${dict2[source_image]}/tags.txt"
        if [[ -f "${dict2[tags_file]}" ]]
        then
            readarray -t tags < "${dict2[tags_file]}"
        fi
        if [[ -L "${dict2[source_image]}" ]]
        then
            tags+=("${dict2[tag]}")
            dict2[source_image]="$(koopa_realpath "${dict2[source_image]}")"
            dict2[tag]="$(koopa_basename "${dict2[source_image]}")"
        fi
        tags+=(
            "${dict2[tag]}"
            "${dict2[tag]}-$(${app[date]} '+%Y%m%d')"
        )
        # Ensure tags are sorted and unique.
        readarray -t tags <<< "$( \
            koopa_print "${tags[@]}" \
            | "${app[sort]}" -u \
        )"
        for tag in "${tags[@]}"
        do
            build_args+=("--tag=${dict2[image]}:${tag}")
        done
        # Platforms.
        # Assume x86 by default.
        platforms=('linux/amd64')
        dict2[platforms_file]="${dict2[source_image]}/platforms.txt"
        if [[ -f "${dict2[platforms_file]}" ]]
        then
            readarray -t platforms < "${dict2[platforms_file]}"
        fi
        # e.g. 'linux/amd64,linux/arm64'.
        dict2[platforms_string]="$(koopa_paste --sep=',' "${platforms[@]}")"
        build_args+=("--platform=${dict2[platforms_string]}")
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
        build_args+=("${dict2[source_image]}")
        # Force remove any existing locally tagged images before building.
        if [[ "${dict[delete]}" -eq 1 ]]
        then
            koopa_alert "Pruning images '${dict2[image]}:${dict2[tag]}'."
            readarray -t image_ids <<< "$( \
                "${app[docker]}" image ls \
                    --filter reference="${dict2[image]}:${dict2[tag]}" \
                    --quiet \
            )"
            if koopa_is_array_non_empty "${image_ids[@]:-}"
            then
                "${app[docker]}" image rm --force "${image_ids[@]}"
            fi
        fi
        koopa_alert "Building '${dict2[source_image]}' Docker image."
        koopa_dl 'Build args' "${build_args[*]}"
        "${app[docker]}" login "${dict[server]}" >/dev/null || return 1
        dict2[build_name]="$(koopa_basename "${dict2[image]}")"
        # Ensure any previous build failres are removed.
        "${app[docker]}" buildx rm \
            "${dict2[build_name]}" \
            &>/dev/null \
            || true
        "${app[docker]}" buildx create \
            --name="${dict2[build_name]}" \
            --use \
            >/dev/null
        "${app[docker]}" buildx build "${build_args[@]}" || return 1
        "${app[docker]}" buildx rm "${dict2[build_name]}"
        "${app[docker]}" image ls \
            --filter \
            reference="${dict2[image]}:${dict2[tag]}"
        koopa_alert_success "Build of '${dict2[source_image]}' was successful."
    done
    return 0
}
