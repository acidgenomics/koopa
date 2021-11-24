#!/usr/bin/env bash

koopa:::install_rbenv() { # {{{1
    # """
    # Install rbenv.
    # @note Updated 2021-11-24.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url1]='https://github.com/sstephenson/rbenv.git'
        [url2]='https://github.com/sstephenson/ruby-build.git'
    )
    koopa::git_clone "${dict[url1]}" "${dict[prefix]}"
    koopa::mkdir "${dict[prefix]}/plugins"
    koopa::git_clone "${dict[url2]}" "${dict[prefix]}/plugins/ruby-build"
    return 0
}

koopa:::update_rbenv() { # {{{1
    # """
    # Update rbenv.
    # @note Updated 2021-11-24.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    koopa::git_pull "${dict[prefix]}"
    return 0
}
