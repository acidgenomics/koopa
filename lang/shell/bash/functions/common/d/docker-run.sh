#!/usr/bin/env bash

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
