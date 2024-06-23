#!/usr/bin/env bash

koopa_docker_build() {
    # """
    # Build and push a multi-architecture Docker image using buildx.
    # @note Updated 2024-06-23.
    #
    # @details
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
    # @seealso
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
    #
    # @examples
    # > local="${HOME}/monorepo/docker/acidgenomics/koopa/debian"
    # > remote='public.ecr.aws/acidgenomics/koopa:debian'
    # > koopa app docker build --local="$local" --remote="$remote"
    # """
    local -A app dict
    local -a build_args image_ids platforms tags
    local tag
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut)"
    app['date']="$(koopa_locate_date)"
    app['docker']="$(koopa_locate_docker --realpath)"
    app['sort']="$(koopa_locate_sort)"
    koopa_assert_is_executable "${app[@]}"
    dict['default_tag']='latest'
    dict['delete']=1
    dict['local_dir']=''
    dict['memory']=''
    dict['push']=1
    dict['remote_url']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--local='*)
                dict['local_dir']="${1#*=}"
                shift 1
                ;;
            '--local')
                dict['local_dir']="${2:?}"
                shift 2
                ;;
            '--memory='*)
                # e.g. use '8g' for 8 GB limit.
                dict['memory']="${1#*=}"
                shift 1
                ;;
            '--memory')
                dict['memory']="${2:?}"
                shift 2
                ;;
            '--remote='*)
                dict['remote_url']="${1#*=}"
                shift 1
                ;;
            '--remote')
                dict['remote_url']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--no-push')
                dict['push']=0
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--local' "${dict['local_dir']}" \
        '--remote' "${dict['remote_url']}"
    koopa_assert_is_dir "${dict['local_dir']}"
    koopa_assert_is_file "${dict['local_dir']}/Dockerfile"
    dict['docker_bin']="$(koopa_parent_dir "${app['docker']}")"
    koopa_add_to_path_start "${dict['docker_bin']}"
    build_args=()
    platforms=()
    tags=()
    if ! koopa_str_detect_fixed \
        --string="${dict['remote_url']}" \
        --pattern=':'
    then
        dict['remote_url']="${dict['remote_url']}:${dict['default_tag']}"
    fi
    koopa_assert_is_matching_regex \
        --pattern='^(.+)/(.+)/(.+):(.+)$' \
        --string="${dict['remote_url']}"
    dict['remote_str']="$( \
        koopa_sub \
            --fixed \
            --pattern=':' \
            --replacement='/' \
            "${dict['remote_url']}"
    )"
    dict['server']="$( \
        koopa_print "${dict['remote_str']}" \
        | "${app['cut']}" -d '/' -f '1' \
    )"
    dict['image_name']="$( \
        koopa_print "${dict['remote_str']}" \
        | "${app['cut']}" -d '/' -f '1-3' \
    )"
    dict['tag']="$( \
        koopa_print "${dict['remote_str']}" \
        | "${app['cut']}" -d '/' -f '4' \
    )"
    # Authenticate with remote repository, if necessary.
    if [[ "${dict['push']}" -eq 1 ]]
    then
        case "${dict['server']}" in
            *'.dkr.ecr.'*'.amazonaws.com')
                koopa_aws_ecr_login_private
                ;;
            'public.ecr.aws')
                koopa_aws_ecr_login_public
                ;;
            *)
                koopa_alert "Logging into '${dict['server']}'."
                "${app['docker']}" logout "${dict['server']}" \
                    >/dev/null || true
                "${app['docker']}" login "${dict['server']}" \
                    >/dev/null || return 1
                ;;
        esac
    fi
    # Tags.
    dict['tags_file']="${dict['local_dir']}/tags.txt"
    if [[ -f "${dict['tags_file']}" ]]
    then
        readarray -t tags < "${dict['tags_file']}"
    fi
    if [[ -L "${dict['local_dir']}" ]]
    then
        tags+=("${dict['tag']}")
        dict['local_dir']="$(koopa_realpath "${dict['local_dir']}")"
        dict['tag']="$(koopa_basename "${dict['local_dir']}")"
    fi
    tags+=(
        "${dict['tag']}"
        "${dict['tag']}-$(${app['date']} '+%Y%m%d')"
    )
    # Ensure tags are sorted and unique.
    readarray -t tags <<< "$( \
        koopa_print "${tags[@]}" \
        | "${app['sort']}" -u \
    )"
    for tag in "${tags[@]}"
    do
        build_args+=("--tag=${dict['image_name']}:${tag}")
    done
    # Platforms.
    # Assume x86 by default.
    platforms=('linux/amd64')
    dict['platforms_file']="${dict['local_dir']}/platforms.txt"
    if [[ -f "${dict['platforms_file']}" ]]
    then
        readarray -t platforms < "${dict['platforms_file']}"
    fi
    # e.g. 'linux/amd64,linux/arm64'.
    dict['platforms_string']="$(koopa_paste --sep=',' "${platforms[@]}")"
    build_args+=("--platform=${dict['platforms_string']}")
    # Harden against buildx blowing up memory on a local machine.
    # Consider raising this when we deploy a more powerful build machine.
    # > local memory
    if [[ -n "${dict['memory']}" ]]
    then
        # If you don't want to use swap, give '--memory' and '--memory-swap'
        # the same values. Don't set '--memory-swap' to 0. Alternatively,
        # set '--memory-swap' to '-1' for unlimited swap.
        build_args+=(
            "--memory=${dict['memory']}"
            "--memory-swap=${dict['memory']}"
        )
    fi
    build_args+=(
        '--no-cache'
        '--progress=auto'
        '--pull'
    )
    if [[ "${dict['push']}" -eq 1 ]]
    then
        build_args+=('--push')
    fi
    build_args+=("${dict['local_dir']}")
    # Force remove any existing locally tagged images before building.
    if [[ "${dict['delete']}" -eq 1 ]]
    then
        koopa_alert "Pruning images '${dict['remote_url']}'."
        readarray -t image_ids <<< "$( \
            "${app['docker']}" image ls \
                --filter reference="${dict['remote_url']}" \
                --quiet \
        )"
        if koopa_is_array_non_empty "${image_ids[@]:-}"
        then
            "${app['docker']}" image rm --force "${image_ids[@]}"
        fi
    fi
    koopa_alert "Building '${dict['remote_url']}' Docker image."
    koopa_dl 'Build args' "${build_args[*]}"
    dict['build_name']="$(koopa_basename "${dict['image_name']}")"
    # Ensure any previous build failures are removed.
    "${app['docker']}" buildx rm \
        "${dict['build_name']}" \
        &>/dev/null \
        || true
    "${app['docker']}" buildx create \
        --name="${dict['build_name']}" \
        --use \
        >/dev/null
    "${app['docker']}" buildx build "${build_args[@]}"
    "${app['docker']}" buildx rm "${dict['build_name']}"
    "${app['docker']}" image ls \
        --filter \
        reference="${dict['remote_url']}"
    if [[ "${dict['push']}" -eq 1 ]]
    then
        "${app['docker']}" logout "${dict['server']}" \
            >/dev/null || true
    fi
    koopa_alert_success "Build of '${dict['remote_url']}' was successful."
    return 0
}
