#!/usr/bin/env bash

koopa_docker_run() {
    # """
    # Run Docker image.
    # @note Updated 2023-06-01.
    #
    # No longer using bind mounts by default.
    # Use named volumes, which have better cross-platform compatiblity, instead.
    #
    # @seealso
    # - https://docs.docker.com/storage/volumes/
    # - https://docs.docker.com/storage/bind-mounts/
    # """
    local -A app dict
    local -a pos run_args
    koopa_assert_has_args "$#"
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    dict['arm']=0
    dict['bash']=0
    dict['bind']=0
    dict['workdir']='/mnt/work'
    dict['x86']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--arm')
                dict['arm']=1
                shift 1
                ;;
            '--bash')
                dict['bash']=1
                shift 1
                ;;
            '--bind')
                dict['bind']=1
                shift 1
                ;;
            '--x86')
                dict['x86']=1
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
    dict['image']="${1:?}"
    case "${dict['image']}" in
        *'.dkr.ecr.'*'.amazonaws.com/'*)
            koopa_aws_ecr_login_private
            ;;
        'public.ecr.aws/'*)
            koopa_aws_ecr_login_public
            ;;
    esac
    "${app['docker']}" pull "${dict['image']}"
    run_args=('--interactive' '--tty')
    # Legacy bind mounts approach, now disabled by default.
    # Useful for quickly checking whether a local script will run.
    if [[ "${dict['bind']}" -eq 1 ]]
    then
        # This check helps prevent Docker from chewing up a bunch of CPU.
        if [[ "${HOME:?}" == "${PWD:?}" ]]
        then
            koopa_stop "Do not set '--bind' when running at HOME."
        fi
        run_args+=(
            "--volume=${PWD:?}:${dict['workdir']}"
            "--workdir=${dict['workdir']}"
        )
    fi
    # Manually override the platform, if desired.
    if [[ "${dict['arm']}" -eq 1 ]]
    then
        run_args+=('--platform=linux/arm64')
    elif [[ "${dict['x86']}" -eq 1 ]]
    then
        run_args+=('--platform=linux/amd64')
    fi
    run_args+=("${dict['image']}")
    # Enable an interactive Bash login session, if desired.
    if [[ "${dict['bash']}" -eq 1 ]]
    then
        run_args+=('bash' '-il')
    fi
    "${app['docker']}" run "${run_args[@]}"
    return 0
}
