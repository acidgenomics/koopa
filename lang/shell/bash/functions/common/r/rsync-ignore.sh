#!/usr/bin/env bash

koopa_rsync_ignore() {
    # """
    # Run rsync with automatic ignore.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://stackoverflow.com/questions/13713101/
    # """
    local -A dict
    local -a rsync_args
    koopa_assert_has_args "$#"
    dict['ignore_local']='.gitignore'
    dict['ignore_global']="${HOME}/.gitignore"
    rsync_args=(
        '--archive'
        '--exclude=.*'
    )
    if [[ -f "${dict['ignore_local']}" ]]
    then
        rsync_args+=(
            "--filter=dir-merge,- ${dict['ignore_local']}"
        )
    fi
    if [[ -f "${dict['ignore_global']}" ]]
    then
        rsync_args+=("--filter=dir-merge,- ${dict['ignore_global']}")
    fi
    koopa_rsync "${rsync_args[@]}" "$@"
    return 0
}
