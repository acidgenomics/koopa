#!/bin/sh

koopa_git_repo_has_unstaged_changes() {
    # """
    # Are there unstaged changes in current git repo?
    # @note Updated 2021-08-19.
    #
    # Don't use '--quiet' flag here, as it can cause shell to exit if 'set -e'
    # mode is enabled.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3878624/
    # - https://stackoverflow.com/questions/28296130/
    # """
    local x
    git update-index --refresh >/dev/null 2>&1
    x="$(git diff-index 'HEAD' -- 2>/dev/null)"
    [ -n "$x" ]
}
