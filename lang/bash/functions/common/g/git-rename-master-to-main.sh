#!/usr/bin/env bash

koopa_git_rename_master_to_main() {
    # """
    # Rename default branch from "master" to "main".
    # @note Updated 2023-04-06.
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
    local -A app dict
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['origin']='origin'
    dict['old_branch']='master'
    dict['new_branch']='main'
    koopa_assert_is_git_repo "$@"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "$@"
        do
            koopa_cd "$repo"
            # Switch to the old branch.
            "${app['git']}" switch "${dict['old_branch']}"
            # Rename (move) to the new branch.
            "${app['git']}" branch --move \
                "${dict['old_branch']}" \
                "${dict['new_branch']}"
            # Switch to the new branch.
            "${app['git']}" switch "${dict['new_branch']}"
            # Get the latest comments (and branches) from the remote.
            "${app['git']}" fetch --all --prune "${dict['origin']}"
            # Remove the existing tracking connection.
            "${app['git']}" branch --unset-upstream
            # Create a new tracking connection.
            "${app['git']}" branch \
                --set-upstream-to="${dict['origin']}/${dict['new_branch']}" \
                "${dict['new_branch']}"
            # Push the renamed branch to remote.
            "${app['git']}" push --set-upstream \
                "${dict['origin']}" \
                "${dict['new_branch']}"
            # Delete the old branch from remote. This may fail if branch is
            # protected on the remote platform.
            "${app['git']}" push \
                "${dict['origin']}" \
                --delete "${dict['old_branch']}" \
                || true
            # Set the remote HEAD.
            "${app['git']}" remote set-head "${dict['origin']}" --auto
        done
    )
    return 0
}
