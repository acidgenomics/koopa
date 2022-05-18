#!/usr/bin/env bash

koopa_git_rm_submodule() {
    # """
    # Remove a git submodule from current repository.
    # @note Updated 2021-11-18.
    #
    # @seealso
    # - https://stackoverflow.com/questions/1260748/
    # - https://gist.github.com/myusuf3/7f645819ded92bda6677
    #
    # @examples
    # > cd "${HOME}/git/monorepo"
    # > koopa_git_rm_submodule 'XXX' 'YYY'
    # """
    local app module
    koopa_assert_has_args "$#"
    koopa_assert_is_git_repo
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    for module in "$@"
    do
        # Remove the submodule entry from '.git/config'.
        "${app[git]}" submodule deinit -f "$module"
        # Remove the submodule directory from the superproject's '.git/modules'
        # directory.
        koopa_rm ".git/modules/${module}"
        # Remove the entry in '.gitmodules' and remove the submodule directory
        # located at 'path/to/submodule'.
        "${app[git]}" rm -f "$module"
        # Update gitmodules file and commit.
        "${app[git]}" add '.gitmodules'
        "${app[git]}" commit -m "Removed submodule '${module}'."
    done
    return 0
}
