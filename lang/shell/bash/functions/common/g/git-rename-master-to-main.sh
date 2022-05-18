#!/usr/bin/env bash

koopa_git_rename_master_to_main() {
    # """
    # Rename default branch from "master" to "main".
    # @note Updated 2022-03-03.
    #
    # @seealso
    # - https://hackernoon.com/how-to-rename-your-git-repositories-
    #     from-master-to-main-6i1u3wsu
    # - https://www.hanselman.com/blog/easily-rename-your-git-default-branch-
    #     from-master-to-main
    # - https://www.git-tower.com/learn/git/faq/git-rename-master-to-main
    #
    # @examples
    # > koopa_git_rename_master_to_main "${HOME}/git/example"
    # """
    local app dict repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    declare -A dict=(
        [origin]='origin'
        [old_branch]='master'
        [new_branch]='main'
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            # Switch to the old branch.
            "${app[git]}" switch "${dict[old_branch]}"
            # Rename (move) to the new branch.
            "${app[git]}" branch --move \
                "${dict[old_branch]}" \
                "${dict[new_branch]}"
            # Switch to the new branch.
            "${app[git]}" switch "${dict[new_branch]}"
            # Get the latest comments (and branches) from the remote.
            "${app[git]}" fetch --all --prune "${dict[origin]}"
            # Remove the existing tracking connection.
            "${app[git]}" branch --unset-upstream
            # Create a new tracking connection.
            "${app[git]}" branch \
                --set-upstream-to="${dict[origin]}/${dict[new_branch]}" \
                "${dict[new_branch]}"
            # Push the renamed branch to remote.
            "${app[git]}" push --set-upstream \
                "${dict[origin]}" \
                "${dict[new_branch]}"
            # Delete the old branch from remote. This may fail if branch is
            # protected on the remote platform.
            "${app[git]}" push \
                "${dict[origin]}" \
                --delete "${dict[old_branch]}" \
                || true
            # Set the remote HEAD.
            "${app[git]}" remote set-head "${dict[origin]}" --auto
        done
    )
    return 0
}
