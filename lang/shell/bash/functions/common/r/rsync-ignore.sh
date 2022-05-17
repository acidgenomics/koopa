#!/usr/bin/env bash

koopa_rsync_ignore() {
    # """
    # Run rsync with automatic ignore.
    # @note Updated 2022-04-04.
    #
    # @seealso
    # - https://stackoverflow.com/questions/13713101/
    # """
    local dict rsync_args
    koopa_assert_has_args "$#"
    declare -A dict=(
        [ignore_local]='.gitignore'
        [ignore_global]="${HOME}/.gitignore"
    )
    rsync_args=(
        '--archive'
        '--exclude=.*'
    )
    if [[ -f "${dict[ignore_local]}" ]]
    then
        rsync_args+=(
            "--filter=dir-merge,- ${dict[ignore_local]}"
        )
    fi
    if [[ -f "${dict[ignore_global]}" ]]
    then
        rsync_args+=("--filter=dir-merge,- ${dict[ignore_global]}")
    fi
    koopa_rsync "${rsync_args[@]}" "$@"
    return 0
}
