#!/usr/bin/env bash

koopa_git_repo_has_unstaged_changes() {
    # """
    # Are there unstaged changes in current git repo?
    # @note Updated 2023-03-12.
    #
    # Don't use '--quiet' flag here, as it can cause shell to exit if 'set -e'
    # mode is enabled.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3878624/
    # - https://stackoverflow.com/questions/28296130/
    # """
    local -A app dict
    app['git']="$(koopa_locate_git)"
    koopa_assert_is_executable "${app[@]}"
    "${app['git']}" update-index --refresh &>/dev/null
    dict['string']="$("${app['git']}" diff-index 'HEAD' -- 2>/dev/null)"
    [[ -n "${dict['string']}" ]]
}
